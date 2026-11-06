-- ============================================================================
-- TRUY VẤN Q12: FUNCTION & TRIGGER HỖ TRỢ QUYẾT ĐỊNH LÂM SÀNG (CDSS)
-- Nghiệp vụ: Cảnh báo và ngăn chặn Bác sĩ kê đơn thuốc xung đột với tiền sử dị ứng
--           của Bệnh nhân (Ví dụ: Bệnh nhân dị ứng Penicillin nhưng kê Amoxicillin / Augmentin).
-- Kỹ thuật: Trigger liên bảng (Cross-table Trigger), duyệt quan hệ đa cấp:
--           ChiTietDonThuoc -> DonThuoc -> HoSoKhamBenh -> BenhNhan -> TienSuDiUng,
--           sử dụng biểu thức so khớp mờ ILIKE để cảnh báo an toàn y tế tức thì.
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_kiem_tra_di_ung_thuoc()
RETURNS TRIGGER AS $$
DECLARE
    v_tien_su_di_ung    TEXT;
    v_hoat_chat         VARCHAR(150);
    v_ten_thuoc         VARCHAR(150);
    v_ten_benh_nhan     VARCHAR(100);
BEGIN
    -- 1. Lấy hoạt chất và tên thuốc sắp được kê
    SELECT hoat_chat, ten_thuoc 
    INTO v_hoat_chat, v_ten_thuoc
    FROM thuoc 
    WHERE ma_thuoc = NEW.ma_thuoc;

    -- 2. Truy vết tìm tiền sử dị ứng và tên bệnh nhân nhận đơn thuốc này
    SELECT bn.tien_su_di_ung, n.ho_ten
    INTO v_tien_su_di_ung, v_ten_benh_nhan
    FROM don_thuoc dt
    JOIN ho_so_kham_benh hs ON dt.ma_ho_so = hs.ma_ho_so
    JOIN benh_nhan bn ON hs.ma_benh_nhan = bn.ma_benh_nhan
    JOIN nguoi n ON bn.ma_dinh_danh = n.ma_dinh_danh
    WHERE dt.ma_don_thuoc = NEW.ma_don_thuoc;

    -- 3. Kiểm tra xung đột dị ứng lâm sàng (Ví dụ nhóm kháng sinh Beta-lactam / Penicillin)
    IF v_tien_su_di_ung IS NOT NULL AND LENGTH(TRIM(v_tien_su_di_ung)) > 0 THEN
        -- Kiểm tra dị ứng Penicillin với các hoạt chất dẫn xuất (Amoxicillin, Augmentin, Penicillin...)
        IF (v_tien_su_di_ung ILIKE '%Penicillin%' OR v_tien_su_di_ung ILIKE '%Amoxicillin%')
           AND (v_hoat_chat ILIKE '%Amoxicillin%' OR v_hoat_chat ILIKE '%Penicillin%') THEN
            RAISE EXCEPTION 'CẢNH BÁO AN TOÀN DƯỢC (CDSS): Bệnh nhân [%] có tiền sử dị ứng: "%"! Hệ thống từ chối kê đơn thuốc [%] (Hoạt chất: %) để bảo vệ an toàn tính mạng bệnh nhân!',
                v_ten_benh_nhan, v_tien_su_di_ung, v_ten_thuoc, v_hoat_chat
                USING ERRCODE = 'check_violation';
        END IF;

        -- Kiểm tra dị ứng Paracetamol
        IF (v_tien_su_di_ung ILIKE '%Paracetamol%') AND (v_hoat_chat ILIKE '%Paracetamol%') THEN
            RAISE EXCEPTION 'CẢNH BÁO AN TOÀN DƯỢC (CDSS): Bệnh nhân [%] có tiền sử dị ứng Paracetamol! Không thể kê thuốc [%]!',
                v_ten_benh_nhan, v_ten_thuoc
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Gắn trigger vào bảng chi_tiet_don_thuoc trước khi INSERT hoặc UPDATE thuốc
DROP TRIGGER IF EXISTS trg_kiem_tra_di_ung ON chi_tiet_don_thuoc;
CREATE TRIGGER trg_kiem_tra_di_ung
    BEFORE INSERT OR UPDATE OF ma_thuoc ON chi_tiet_don_thuoc
    FOR EACH ROW
    EXECUTE FUNCTION fn_kiem_tra_di_ung_thuoc();
