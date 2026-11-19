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

-- PostgreSQL Table Inheritance không tự động kế thừa Trigger -> gắn cho cả 3 bảng con kết quả
DROP TRIGGER IF EXISTS trg_prevent_delete_kq_dl ON ket_qua_dinh_luong;
CREATE TRIGGER trg_prevent_delete_kq_dl
    BEFORE DELETE ON ket_qua_dinh_luong
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_hard_delete();

DROP TRIGGER IF EXISTS trg_prevent_delete_kq_ha ON ket_qua_hinh_anh;
CREATE TRIGGER trg_prevent_delete_kq_ha
    BEFORE DELETE ON ket_qua_hinh_anh
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_hard_delete();

DROP TRIGGER IF EXISTS trg_prevent_delete_kq_dt ON ket_qua_dinh_tinh;
CREATE TRIGGER trg_prevent_delete_kq_dt
    BEFORE DELETE ON ket_qua_dinh_tinh
    FOR EACH ROW EXECUTE FUNCTION fn_prevent_hard_delete();

DROP TRIGGER IF EXISTS trg_prevent_delete_don_thuoc ON don_thuoc;
CREATE TRIGGER trg_prevent_delete_don_thuoc
    BEFORE DELETE ON don_thuoc
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

-- Helper dùng chung để lấy ngữ cảnh người thực hiện, lý do và loại thao tác Audit
CREATE OR REPLACE FUNCTION fn_resolve_audit_context(
    p_default_user          ma_nv_domain,
    p_is_soft_delete        BOOLEAN,
    p_default_update_reason TEXT,
    p_default_delete_reason TEXT,
    OUT o_nguoi_thuc_hien   ma_nv_domain,
    OUT o_ly_do_sua         TEXT,
    OUT o_thao_tac          thao_tac_audit_enum
)
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN
        o_nguoi_thuc_hien := NULLIF(TRIM(current_setting('app.current_user_id', true)), '')::ma_nv_domain;
    EXCEPTION WHEN OTHERS THEN
        o_nguoi_thuc_hien := NULL;
    END;

    IF o_nguoi_thuc_hien IS NULL THEN
        o_nguoi_thuc_hien := p_default_user;
    END IF;

    o_thao_tac := CASE WHEN p_is_soft_delete THEN 'SOFT_DELETE'::thao_tac_audit_enum ELSE 'UPDATE'::thao_tac_audit_enum END;

    o_ly_do_sua := current_setting('app.current_reason', true);
    IF o_ly_do_sua IS NULL OR LENGTH(TRIM(o_ly_do_sua)) < 5 THEN
        o_ly_do_sua := CASE WHEN p_is_soft_delete THEN p_default_delete_reason ELSE p_default_update_reason END;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION fn_audit_ket_qua_xet_nghiem()
RETURNS TRIGGER AS $$
DECLARE
    v_ctx RECORD;
BEGIN
    SELECT * INTO v_ctx
    FROM fn_resolve_audit_context(
        COALESCE(NEW.ma_ktv_thuc_hien, OLD.ma_ktv_thuc_hien, 'NV-00001'),
        (NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE),
        'Đính chính kết quả xét nghiệm / Cập nhật chỉ số phân tích',
        'Hủy bỏ kết quả xét nghiệm theo yêu cầu lâm sàng (Soft Delete)'
    );

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
        v_ctx.o_thao_tac,
        to_jsonb(OLD),
        to_jsonb(NEW),
        v_ctx.o_ly_do_sua,
        v_ctx.o_nguoi_thuc_hien,
        CURRENT_TIMESTAMP
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger Audit Trail cho bảng Hồ sơ khám bệnh (ghi vết cập nhật chẩn đoán & xóa mềm)
CREATE OR REPLACE FUNCTION fn_audit_ho_so_kham_benh()
RETURNS TRIGGER AS $$
DECLARE
    v_ctx          RECORD;
    v_so_phien_ban INTEGER;
BEGIN
    SELECT * INTO v_ctx
    FROM fn_resolve_audit_context(
        COALESCE(NEW.ma_bac_si_kham, OLD.ma_bac_si_kham, 'NV-00001'),
        (NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE),
        'Cập nhật thông tin lâm sàng / chẩn đoán trên hồ sơ khám bệnh',
        'Hủy bỏ hồ sơ khám bệnh theo yêu cầu nghiệp vụ (Soft Delete)'
    );

    SELECT COALESCE(MAX(so_phien_ban), 0) + 1 INTO v_so_phien_ban
    FROM lich_su_chinh_sua
    WHERE ten_bang = TG_TABLE_NAME
      AND ma_ban_ghi = OLD.ma_ho_so::VARCHAR(50);

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
        OLD.ma_ho_so::VARCHAR(50),
        v_so_phien_ban,
        v_ctx.o_thao_tac,
        to_jsonb(OLD),
        to_jsonb(NEW),
        v_ctx.o_ly_do_sua,
        v_ctx.o_nguoi_thuc_hien,
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

DROP TRIGGER IF EXISTS trg_audit_ho_so ON ho_so_kham_benh;
CREATE TRIGGER trg_audit_ho_so
    BEFORE UPDATE ON ho_so_kham_benh
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION fn_audit_ho_so_kham_benh();

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
        muc_do_canh_bao = CASE
            WHEN p_gia_tri_moi < (chi_so_min_chuan * 0.75) OR p_gia_tri_moi > (chi_so_max_chuan * 1.25) THEN 'NGUY_HIEM'::canh_bao_enum
            WHEN p_gia_tri_moi < chi_so_min_chuan THEN 'THAP'::canh_bao_enum
            WHEN p_gia_tri_moi > chi_so_max_chuan THEN 'CAO'::canh_bao_enum
            ELSE 'BINH_THUONG'::canh_bao_enum
        END,
        ket_luan_tong_quat = CASE
            WHEN p_gia_tri_moi < (chi_so_min_chuan * 0.75) OR p_gia_tri_moi > (chi_so_max_chuan * 1.25) THEN 'Chỉ số vượt ngưỡng nguy hiểm sau đính chính - Cần xử trí lâm sàng khẩn'
            WHEN p_gia_tri_moi < chi_so_min_chuan THEN 'Chỉ số thấp hơn ngưỡng tham chiếu sau đính chính'
            WHEN p_gia_tri_moi > chi_so_max_chuan THEN 'Chỉ số cao hơn ngưỡng tham chiếu sau đính chính'
            ELSE 'Chỉ số trong giới hạn tham chiếu bình thường sau đính chính'
        END,
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

-- ----------------------------------------------------------------------------
-- 5. TRIGGER HỖ TRỢ QUYẾT ĐỊNH LÂM SÀNG (CDSS) CẢNH BÁO DỊ ỨNG THUỐC
-- ----------------------------------------------------------------------------
-- Tự động kiểm tra xung đột hoạt chất thuốc kê đơn với tiền sử dị ứng bệnh nhân

CREATE OR REPLACE FUNCTION fn_kiem_tra_di_ung_thuoc()
RETURNS TRIGGER AS $$
DECLARE
    v_tien_su_di_ung    TEXT;
    v_hoat_chat         VARCHAR(150);
    v_ten_thuoc         VARCHAR(150);
    v_ten_benh_nhan     VARCHAR(100);
BEGIN
    SELECT hoat_chat, ten_thuoc 
    INTO v_hoat_chat, v_ten_thuoc
    FROM thuoc 
    WHERE ma_thuoc = NEW.ma_thuoc;

    SELECT bn.tien_su_di_ung, n.ho_ten
    INTO v_tien_su_di_ung, v_ten_benh_nhan
    FROM don_thuoc dt
    JOIN ho_so_kham_benh hs ON dt.ma_ho_so = hs.ma_ho_so
    JOIN benh_nhan bn ON hs.ma_benh_nhan = bn.ma_benh_nhan
    JOIN nguoi n ON bn.ma_dinh_danh = n.ma_dinh_danh
    WHERE dt.ma_don_thuoc = NEW.ma_don_thuoc;

    IF v_tien_su_di_ung IS NOT NULL AND LENGTH(TRIM(v_tien_su_di_ung)) > 0 THEN
        IF (v_tien_su_di_ung ILIKE '%Penicillin%' OR v_tien_su_di_ung ILIKE '%Amoxicillin%')
           AND (v_hoat_chat ILIKE '%Amoxicillin%' OR v_hoat_chat ILIKE '%Penicillin%') THEN
            RAISE EXCEPTION 'CẢNH BÁO AN TOÀN DƯỢC (CDSS): Bệnh nhân [%] có tiền sử dị ứng: "%"! Hệ thống từ chối kê đơn thuốc [%] (Hoạt chất: %) để bảo vệ an toàn tính mạng bệnh nhân!',
                v_ten_benh_nhan, v_tien_su_di_ung, v_ten_thuoc, v_hoat_chat
                USING ERRCODE = 'check_violation';
        END IF;

        IF (v_tien_su_di_ung ILIKE '%Paracetamol%') AND (v_hoat_chat ILIKE '%Paracetamol%') THEN
            RAISE EXCEPTION 'CẢNH BÁO AN TOÀN DƯỢC (CDSS): Bệnh nhân [%] có tiền sử dị ứng Paracetamol! Không thể kê thuốc [%]!',
                v_ten_benh_nhan, v_ten_thuoc
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_kiem_tra_di_ung ON chi_tiet_don_thuoc;
CREATE TRIGGER trg_kiem_tra_di_ung
    BEFORE INSERT OR UPDATE OF ma_thuoc ON chi_tiet_don_thuoc
    FOR EACH ROW
    EXECUTE FUNCTION fn_kiem_tra_di_ung_thuoc();

