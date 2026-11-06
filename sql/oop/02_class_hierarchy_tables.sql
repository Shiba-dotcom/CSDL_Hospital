-- ============================================================================
-- TUẦN 9: CƠ SỞ DỮ LIỆU HƯỚNG ĐỐI TƯỢNG (OBJECT-RELATIONAL DATABASE)
-- Tệp 02: THIẾT KẾ PHÂN CẤP LỚP ĐỐI TƯỢNG & BẢNG KẾ THỪA (TABLE INHERITANCE)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

-- Dọn dẹp bảng cũ theo thứ tự phụ thuộc
DROP TABLE IF EXISTS oop.ho_so_kham_benh CASCADE;
DROP TABLE IF EXISTS oop.ket_qua_dinh_luong CASCADE;
DROP TABLE IF EXISTS oop.ket_qua_hinh_anh CASCADE;
DROP TABLE IF EXISTS oop.ket_qua_dinh_tinh CASCADE;
DROP TABLE IF EXISTS oop.ket_qua_xet_nghiem CASCADE;
DROP TABLE IF EXISTS oop.bac_si CASCADE;
DROP TABLE IF EXISTS oop.ky_thuat_vien CASCADE;
DROP TABLE IF EXISTS oop.benh_nhan CASCADE;
DROP TABLE IF EXISTS oop.nguoi CASCADE;

-- ============================================================================
-- NHÁNH 1: PHÂN CẤP LỚP CON NGƯỜI (HUMAN CLASS HIERARCHY)
-- ============================================================================

-- Lớp 1 (Base Class): Lớp Người cơ sở
CREATE TABLE oop.nguoi (
    id_nguoi            SERIAL PRIMARY KEY,
    ma_dinh_danh        VARCHAR(20) NOT NULL UNIQUE,
    ho_ten              VARCHAR(100) NOT NULL,
    ngay_sinh           DATE NOT NULL,
    gioi_tinh           VARCHAR(10) CHECK (gioi_tinh IN ('NAM', 'NU', 'KHAC')),
    so_dien_thoai       TEXT[],                 -- Thuộc tính đa trị (Collection - Array)
    dia_chi             oop.dia_chi_type        -- Thuộc tính lồng kiểu phức hợp (Nested Composite)
);

-- Lớp 2 (Subclass 1): Lớp Bệnh nhân kế thừa từ Lớp Người
CREATE TABLE oop.benh_nhan (
    ma_benh_nhan        VARCHAR(15) NOT NULL UNIQUE,
    nhom_mau            VARCHAR(10),
    tien_su_di_ung      TEXT[],                 -- Mảng các loại thuốc/dị nguyên
    chi_so_gan_nhat     oop.chi_so_sinh_ton_type -- Đối tượng chỉ số sinh tồn gần nhất
) INHERITS (oop.nguoi);

-- Lớp 3 (Subclass 2): Lớp Bác sĩ kế thừa từ Lớp Người
CREATE TABLE oop.bac_si (
    ma_bac_si           VARCHAR(15) NOT NULL UNIQUE,
    chuyen_khoa_chinh   VARCHAR(100) NOT NULL,
    so_nam_kinh_nghiem  INTEGER DEFAULT 0,
    chung_chi_hanh_nghe VARCHAR(50) NOT NULL,
    danh_sach_bang_cap  oop.bang_cap_type[]     -- Mảng chứa các đối tượng phức hợp (Collection of Objects)
) INHERITS (oop.nguoi);

-- Lớp 4 (Subclass 3): Lớp Kỹ thuật viên xét nghiệm kế thừa từ Lớp Người
CREATE TABLE oop.ky_thuat_vien (
    ma_ktv              VARCHAR(15) NOT NULL UNIQUE,
    phong_xet_nghiem    VARCHAR(100) NOT NULL,
    chung_chi_atsh      VARCHAR(50)             -- Chứng chỉ an toàn sinh học
) INHERITS (oop.nguoi);

-- ============================================================================
-- NHÁNH 2: PHÂN CẤP LỚP KẾT QUẢ XÉT NGHIỆM ĐA HÌNH (POLYMORPHISM)
-- ============================================================================

-- Lớp 5 (Base Class): Lớp Kết quả xét nghiệm cơ sở
CREATE TABLE oop.ket_qua_xet_nghiem (
    ma_ket_qua          SERIAL PRIMARY KEY,
    ma_phieu_chi_dinh   BIGINT NOT NULL,
    ma_danh_muc_xn      VARCHAR(15) NOT NULL,
    ten_xet_nghiem      VARCHAR(100) NOT NULL,
    thoi_gian_thuc_hien TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    trang_thai          VARCHAR(20) DEFAULT 'HOAN_THANH'
);

-- Lớp 6 (Subclass 1): Kết quả Định lượng (Quantitative)
CREATE TABLE oop.ket_qua_dinh_luong (
    gia_tri_do          NUMERIC(10,3) NOT NULL,
    don_vi_tinh         VARCHAR(30) NOT NULL,
    chi_so_min_chuan    NUMERIC(10,3),
    chi_so_max_chuan    NUMERIC(10,3),
    muc_do_canh_bao     VARCHAR(20) DEFAULT 'BINH_THUONG'
) INHERITS (oop.ket_qua_xet_nghiem);

-- Lớp 7 (Subclass 2): Kết quả Hình ảnh (Imaging)
CREATE TABLE oop.ket_qua_hinh_anh (
    duong_dan_tep_anh   TEXT NOT NULL,
    ky_thuat_chup       VARCHAR(100),
    vung_khao_sat       VARCHAR(100),
    mo_ta_ton_thuong    TEXT
) INHERITS (oop.ket_qua_xet_nghiem);

-- Lớp 8 (Subclass 3): Kết quả Định tính / Vi sinh (Qualitative / Microbiology)
CREATE TABLE oop.ket_qua_dinh_tinh (
    ket_qua_danh_gia    VARCHAR(50) NOT NULL,   -- 'DUONG_TINH', 'AM_TINH', 'NGHI_NGO'
    mo_ta_vi_sinh       TEXT
) INHERITS (oop.ket_qua_xet_nghiem);

-- ============================================================================
-- NHÁNH 3: BẢNG HỒ SƠ KHÁM BỆNH KẾT NỐI ĐỐI TƯỢNG (OBJECT RELATIONSHIP)
-- ============================================================================

CREATE TABLE oop.ho_so_kham_benh (
    ma_ho_so            SERIAL PRIMARY KEY,
    ma_benh_nhan        VARCHAR(15) NOT NULL,
    ma_bac_si_kham      VARCHAR(15) NOT NULL,
    thoi_gian_kham      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    chi_so_kham         oop.chi_so_sinh_ton_type, -- Kiểu phức hợp đo lường
    chan_doan           TEXT,
    cac_ma_xet_nghiem   VARCHAR(15)[]             -- Mảng mã xét nghiệm (Collection)
);
