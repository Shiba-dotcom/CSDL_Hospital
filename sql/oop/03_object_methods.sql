-- ============================================================================
-- TUẦN 9: CƠ SỞ DỮ LIỆU HƯỚNG ĐỐI TƯỢNG (OBJECT-RELATIONAL DATABASE)
-- Tệp 03: ĐỊNH NGHĨA CÁC PHƯƠNG THỨC THÀNH VIÊN (OBJECT METHODS / FUNCTIONS)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

-- ============================================================================
-- 1. PHƯƠNG THỨC TRÊN LỚP ĐỐI TƯỢNG NGUOI (VÀ CÁC LỚP CON KẾ THỪA)
-- Cú pháp OOP tương đương: nguoi.tinh_tuoi()
-- ============================================================================

CREATE OR REPLACE FUNCTION oop.tinh_tuoi(p oop.nguoi)
RETURNS INTEGER
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM p.ngay_sinh))::INTEGER;
$$;

-- ============================================================================
-- 2. PHƯƠNG THỨC TRÊN KIỂU PHỨC HỢP DIA_CHI_TYPE
-- Cú pháp OOP tương đương: dia_chi.lay_dia_chi_day_du()
-- ============================================================================

CREATE OR REPLACE FUNCTION oop.lay_dia_chi_day_du(d oop.dia_chi_type)
RETURNS TEXT
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CONCAT_WS(', ', 
        NULLIF('Số ' || TRIM(COALESCE(d.so_nha, '')), 'Số '),
        NULLIF(TRIM(COALESCE(d.duong, '')), ''),
        NULLIF(TRIM(COALESCE(d.phuong_xa, '')), ''),
        NULLIF(TRIM(COALESCE(d.quan_huyen, '')), ''),
        NULLIF(TRIM(COALESCE(d.tinh_thanh, '')), '')
    );
$$;

-- ============================================================================
-- 3. PHƯƠNG THỨC TRÊN KIỂU PHỨC HỢP CHI_SO_SINH_TON_TYPE: TÍNH BMI
-- Cú pháp OOP tương đương: chi_so.tinh_bmi()
-- ============================================================================

CREATE OR REPLACE FUNCTION oop.tinh_bmi(cs oop.chi_so_sinh_ton_type)
RETURNS NUMERIC(4,2)
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT CASE 
        WHEN cs.chieu_cao IS NULL OR cs.chieu_cao <= 0 OR cs.can_nang IS NULL THEN NULL
        ELSE ROUND((cs.can_nang / POWER(cs.chieu_cao / 100.0, 2))::NUMERIC, 2)
    END;
$$;

-- ============================================================================
-- 4. PHƯƠNG THỨC ĐÁNH GIÁ THỂ TRẠNG TỪ CHỈ SỐ SINH TỒN
-- Cú pháp OOP tương đương: chi_so.danh_gia_the_trang()
-- ============================================================================

CREATE OR REPLACE FUNCTION oop.danh_gia_the_trang(cs oop.chi_so_sinh_ton_type)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_bmi NUMERIC(4,2);
BEGIN
    v_bmi := oop.tinh_bmi(cs);
    IF v_bmi IS NULL THEN
        RETURN 'Chưa đủ dữ liệu đo';
    ELSIF v_bmi < 18.5 THEN
        RETURN 'Gầy / Thiếu cân';
    ELSIF v_bmi < 23.0 THEN
        RETURN 'Bình thường (Chuẩn IDI & WPRO)';
    ELSIF v_bmi < 25.0 THEN
        RETURN 'Tiền béo phì (Thừa cân)';
    ELSIF v_bmi < 30.0 THEN
        RETURN 'Béo phì độ I';
    ELSE
        RETURN 'Béo phì độ II (Nguy hiểm)';
    END IF;
END;
$$;

-- ============================================================================
-- 5. PHƯƠNG THỨC ĐÁNH GIÁ KẾT QUẢ ĐỊNH LƯỢNG
-- Cú pháp OOP tương đương: ket_qua_dinh_luong.danh_gia_muc_canh_bao()
-- ============================================================================

CREATE OR REPLACE FUNCTION oop.danh_gia_muc_canh_bao(kq oop.ket_qua_dinh_luong)
RETURNS VARCHAR(20)
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    IF kq.chi_so_min_chuan IS NULL OR kq.chi_so_max_chuan IS NULL THEN
        RETURN 'CHUA_XAC_DINH';
    ELSIF kq.gia_tri_do < (kq.chi_so_min_chuan * 0.7) THEN
        RETURN 'NGUY_HIEM_THAP';
    ELSIF kq.gia_tri_do < kq.chi_so_min_chuan THEN
        RETURN 'THAP';
    ELSIF kq.gia_tri_do > (kq.chi_so_max_chuan * 1.5) THEN
        RETURN 'NGUY_HIEM_CAO';
    ELSIF kq.gia_tri_do > kq.chi_so_max_chuan THEN
        RETURN 'CAO';
    ELSE
        RETURN 'BINH_THUONG';
    END IF;
END;
$$;

-- ============================================================================
-- 6. PHƯƠNG THỨC KIỂM TRA DỊ ỨNG TRÊN ĐỐI TƯỢNG BỆNH NHÂN
-- Cú pháp OOP tương đương: benh_nhan.kiem_tra_di_ung('Penicillin')
-- ============================================================================

CREATE OR REPLACE FUNCTION oop.kiem_tra_di_ung(bn oop.benh_nhan, p_ten_thuoc TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_di_ung TEXT;
BEGIN
    IF bn.tien_su_di_ung IS NULL OR array_length(bn.tien_su_di_ung, 1) = 0 THEN
        RETURN FALSE;
    END IF;

    FOREACH v_di_ung IN ARRAY bn.tien_su_di_ung LOOP
        IF p_ten_thuoc ILIKE '%' || v_di_ung || '%' OR v_di_ung ILIKE '%' || p_ten_thuoc || '%' THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;
END;
$$;

-- ============================================================================
-- 7. PHƯƠNG THỨC TRÊN LỚP BÁC SĨ: KIỂM TRA BÁC SĨ CHUYÊN GIA
-- Cú pháp OOP tương đương: bac_si.la_chuyen_gia()
-- ============================================================================

CREATE OR REPLACE FUNCTION oop.la_chuyen_gia(bs oop.bac_si)
RETURNS BOOLEAN
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    v_bc oop.bang_cap_type;
BEGIN
    IF bs.so_nam_kinh_nghiem >= 10 THEN
        RETURN TRUE;
    END IF;

    IF bs.danh_sach_bang_cap IS NOT NULL THEN
        FOREACH v_bc IN ARRAY bs.danh_sach_bang_cap LOOP
            IF v_bc.trinh_do IN ('BS.CKII', 'Tiến sĩ', 'Phó Giáo sư') THEN
                RETURN TRUE;
            END IF;
        END LOOP;
    END IF;

    RETURN FALSE;
END;
$$;

