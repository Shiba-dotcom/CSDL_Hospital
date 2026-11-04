-- ============================================================================
-- SCRIPT 04: THIẾT KẾ TRIGGER TỰ ĐỘNG HÓA AUDIT TRAIL & KIỂM SOÁT BẤT BIẾN
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- DBMS: PostgreSQL 16+
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. HÀM TRIGGER CHỐNG XÓA CỨNG (PREVENT HARD DELETE)
-- ----------------------------------------------------------------------------
-- Trong lĩnh vực y tế, luật cấm xóa bỏ hồ sơ bệnh án hoặc kết quả cận lâm sàng.
-- Mọi thao tác DELETE vật lý đều bị chặn lại và hướng dẫn dùng Soft Delete.

CREATE OR REPLACE FUNCTION fn_prevent_hard_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'LỖI PHÁP LÝ Y TẾ: Không được phép xóa cứng (HARD DELETE) bản ghi từ bảng %. Vui lòng sử dụng cờ is_deleted = TRUE (Soft Delete)!', TG_TABLE_NAME
        USING ERRCODE = 'integrity_constraint_violation';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Gắn trigger chặn DELETE lên các bảng nhạy cảm
DROP TRIGGER IF EXISTS trg_prevent_delete_ho_so ON ho_so_kham_benh;
CREATE TRIGGER trg_prevent_delete_ho_so
    BEFORE DELETE ON ho_so_kham_benh
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_hard_delete();

DROP TRIGGER IF EXISTS trg_prevent_delete_phieu ON phieu_chi_dinh_xet_nghiem;
CREATE TRIGGER trg_prevent_delete_phieu
    BEFORE DELETE ON phieu_chi_dinh_xet_nghiem
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_hard_delete();

DROP TRIGGER IF EXISTS trg_prevent_delete_kq ON ket_qua_xet_nghiem;
CREATE TRIGGER trg_prevent_delete_kq
    BEFORE DELETE ON ket_qua_xet_nghiem
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_hard_delete();

-- ----------------------------------------------------------------------------
-- 2. HÀM TRIGGER TỰ ĐỘNG TÍNH BMI KHI GHI NHẬN CHỈ SỐ SINH TỒN
-- ----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_calc_bmi()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.chieu_cao IS NOT NULL AND NEW.can_nang IS NOT NULL AND NEW.chieu_cao > 0 THEN
        -- BMI = Cân nặng (kg) / (Chiều cao (m) ^ 2)
        NEW.chi_so_bmi := ROUND(NEW.can_nang / POWER(NEW.chieu_cao / 100.0, 2), 2);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_calc_bmi ON ho_so_kham_benh;
CREATE TRIGGER trg_calc_bmi
    BEFORE INSERT OR UPDATE OF chieu_cao, can_nang ON ho_so_kham_benh
    FOR EACH ROW EXECUTE FUNCTION fn_calc_bmi();

-- ----------------------------------------------------------------------------
-- 3. HÀM TRIGGER AUDIT TRAIL CHO KẾT QUẢ XÉT NGHIỆM
-- ----------------------------------------------------------------------------
-- Tự động:
--   1. Tăng số phiên bản (so_phien_ban = OLD.so_phien_ban + 1)
--   2. Lấy thông tin người sửa và lý do sửa từ Session Context hoặc giá trị mặc định
--   3. Ghi lại snapshot JSONB của toàn bộ bản ghi cũ và bản ghi mới

CREATE OR REPLACE FUNCTION fn_audit_ket_qua_xet_nghiem()
RETURNS TRIGGER AS $$
DECLARE
    v_nguoi_thuc_hien ma_nv_domain;
    v_ly_do_sua       TEXT;
    v_thao_tac        thao_tac_audit_enum;
BEGIN
    -- Lấy thông tin phiên làm việc nếu có thiết lập qua SET LOCAL app.current_user_id
    BEGIN
        v_nguoi_thuc_hien := current_setting('app.current_user_id', true)::ma_nv_domain;
    EXCEPTION WHEN OTHERS THEN
        v_nguoi_thuc_hien := NULL;
    END;

    -- Nếu không có trong context phiên, lấy người thực hiện từ chính bản ghi (KTV thực hiện)
    IF v_nguoi_thuc_hien IS NULL THEN
        v_nguoi_thuc_hien := COALESCE(NEW.ma_ktv_thuc_hien, OLD.ma_ktv_thuc_hien, 'NV-00001');
    END IF;

    -- Lấy lý do chỉnh sửa từ context phiên
    v_ly_do_sua := current_setting('app.current_reason', true);
    IF v_ly_do_sua IS NULL OR LENGTH(TRIM(v_ly_do_sua)) < 5 THEN
        -- Nếu là thao tác xóa mềm
        IF NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE THEN
            v_ly_do_sua := 'Hủy bỏ kết quả xét nghiệm theo yêu cầu lâm sàng (Soft Delete)';
            v_thao_tac := 'SOFT_DELETE';
        ELSE
            v_ly_do_sua := 'Đính chính kết quả xét nghiệm / Cập nhật chỉ số phân tích';
            v_thao_tac := 'UPDATE';
        END IF;
    ELSE
        IF NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE THEN
            v_thao_tac := 'SOFT_DELETE';
        ELSE
            v_thao_tac := 'UPDATE';
        END IF;
    END IF;

    -- Tự động tăng số phiên bản nếu đây là thao tác UPDATE nội dung
    NEW.so_phien_ban := OLD.so_phien_ban + 1;
    NEW.trang_thai_ket_qua := 'DINH_CHINH';

    -- Ghi nhận vết vào bảng lich_su_chinh_sua
    INSERT INTO lich_su_chinh_sua (
        ten_bang,
        ma_ban_ghi,
        so_phien_ban,
        loai_thao_tac,
        du_lieu_cu,
        du_lieu_moi,
        ly_do_sua,
        nguoi_thuc_hien,
        thoi_gian_sua
    ) VALUES (
        TG_TABLE_NAME,
        OLD.ma_ket_qua::VARCHAR(50),
        OLD.so_phien_ban,
        v_thao_tac,
        to_jsonb(OLD),
        to_jsonb(NEW),
        v_ly_do_sua,
        v_nguoi_thuc_hien,
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Gắn trigger cho bảng cha và các bảng kế thừa đa hình
DROP TRIGGER IF EXISTS trg_audit_kq_base ON ket_qua_xet_nghiem;
CREATE TRIGGER trg_audit_kq_base
    BEFORE UPDATE ON ket_qua_xet_nghiem
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION fn_audit_ket_qua_xet_nghiem();

DROP TRIGGER IF EXISTS trg_audit_kq_dinh_luong ON ket_qua_dinh_luong;
CREATE TRIGGER trg_audit_kq_dinh_luong
    BEFORE UPDATE ON ket_qua_dinh_luong
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION fn_audit_ket_qua_xet_nghiem();

DROP TRIGGER IF EXISTS trg_audit_kq_hinh_anh ON ket_qua_hinh_anh;
CREATE TRIGGER trg_audit_kq_hinh_anh
    BEFORE UPDATE ON ket_qua_hinh_anh
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION fn_audit_ket_qua_xet_nghiem();

DROP TRIGGER IF EXISTS trg_audit_kq_dinh_tinh ON ket_qua_dinh_tinh;
CREATE TRIGGER trg_audit_kq_dinh_tinh
    BEFORE UPDATE ON ket_qua_dinh_tinh
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION fn_audit_ket_qua_xet_nghiem();

-- ----------------------------------------------------------------------------
-- 4. HÀM THỦ TỤC AN TOÀN ĐỂ SỬA KẾT QUẢ KÈM LÝ DO BẮT BUỘC
-- ----------------------------------------------------------------------------
-- Bác sĩ / KTV gọi thủ tục này để sửa kết quả, đảm bảo luôn có lý do giải trình

CREATE OR REPLACE PROCEDURE sp_cap_nhat_ket_qua_dinh_luong(
    p_ma_ket_qua        BIGINT,
    p_gia_tri_moi       NUMERIC,
    p_ma_ktv            ma_nv_domain,
    p_ly_do_chinh_sua   TEXT,
    p_phien_ban_hien_tai INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_affected INTEGER;
BEGIN
    -- Ràng buộc bắt buộc nhập lý do y khoa
    IF p_ly_do_chinh_sua IS NULL OR LENGTH(TRIM(p_ly_do_chinh_sua)) < 5 THEN
        RAISE EXCEPTION 'LỖI QUY CHẾ: Bắt buộc phải cung cấp lý do đính chính y khoa từ 5 ký tự trở lên!';
    END IF;

    -- Thiết lập ngữ cảnh phiên làm việc cho Trigger đọc
    PERFORM set_config('app.current_user_id', p_ma_ktv, true);
    PERFORM set_config('app.current_reason', p_ly_do_chinh_sua, true);

    -- Thực hiện cập nhật với Khóa lạc quan (Optimistic Locking)
    UPDATE ket_qua_dinh_luong
    SET gia_tri_do = p_gia_tri_moi,
        ma_ktv_thuc_hien = p_ma_ktv,
        thoi_gian_co_ket_qua = CURRENT_TIMESTAMP
    WHERE ma_ket_qua = p_ma_ket_qua 
      AND so_phien_ban = p_phien_ban_hien_tai;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected = 0 THEN
        RAISE EXCEPTION 'XUNG ĐỘT DỮ LIỆU (Optimistic Lock Failure): Bản ghi kết quả (ID: %) đã bị thay đổi bởi người khác hoặc không tồn tại!', p_ma_ket_qua
            USING ERRCODE = 'serialization_failure';
    END IF;
END;
$$;

