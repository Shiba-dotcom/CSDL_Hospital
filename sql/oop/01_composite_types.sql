-- ============================================================================
-- TUẦN 9: CƠ SỞ DỮ LIỆU HƯỚNG ĐỐI TƯỢNG (OBJECT-RELATIONAL DATABASE)
-- Tệp 01: ĐỊNH NGHĨA CÁC KIỂU PHỨC HỢP (COMPOSITE TYPES)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

-- Tạo schema riêng 'oop' để đóng gói mô hình hướng đối tượng
CREATE SCHEMA IF NOT EXISTS oop;

-- 1. Kiểu phức hợp Địa chỉ (dia_chi_type): Đóng gói cấu trúc phân cấp địa lý
DROP TYPE IF EXISTS oop.dia_chi_type CASCADE;
CREATE TYPE oop.dia_chi_type AS (
    so_nha          VARCHAR(50),
    duong           VARCHAR(100),
    phuong_xa       VARCHAR(100),
    quan_huyen      VARCHAR(100),
    tinh_thanh      VARCHAR(100)
);

-- 2. Kiểu phức hợp Chỉ số sinh tồn (chi_so_sinh_ton_type):
-- Đóng gói toàn bộ thông số khám thực thể lâm sàng
DROP TYPE IF EXISTS oop.chi_so_sinh_ton_type CASCADE;
CREATE TYPE oop.chi_so_sinh_ton_type AS (
    mach                INTEGER,        -- lần/phút
    nhiet_do            NUMERIC(4,1),   -- độ C
    huyet_ap_tam_thu    INTEGER,        -- mmHg
    huyet_ap_tam_truong INTEGER,        -- mmHg
    chieu_cao           NUMERIC(5,2),   -- cm
    can_nang            NUMERIC(5,2)    -- kg
);

-- 3. Kiểu phức hợp Bằng cấp / Chứng chỉ y khoa (bang_cap_type):
DROP TYPE IF EXISTS oop.bang_cap_type CASCADE;
CREATE TYPE oop.bang_cap_type AS (
    trinh_do            VARCHAR(50),    -- 'BS.CKI', 'BS.CKII', 'Thạc sĩ', 'Tiến sĩ'
    chuyen_nganh        VARCHAR(100),   -- 'Tim mạch', 'Nội tổng quát', 'Hô hấp'
    noi_dao_tao         VARCHAR(150),   -- 'ĐH Y Dược TP.HCM', 'ĐH Y Hà Nội'
    nam_tot_nghiep      INTEGER
);
