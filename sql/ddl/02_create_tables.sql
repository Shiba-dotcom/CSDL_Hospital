-- ============================================================================
-- SCRIPT 02: TẠO CÁC BẢNG DỮ LIỆU (RELATIONAL & OBJECT-RELATIONAL TABLES)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- DBMS: PostgreSQL 16+
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. PHÂN HỆ NHÂN KHẨU HỌC & TỔ CHỨC BỆNH VIỆN
-- ----------------------------------------------------------------------------

-- Bảng siêu lớp: Định danh nhân thân duy nhất (Single Source of Truth)
CREATE TABLE IF NOT EXISTS nguoi (
    ma_dinh_danh    cccd_domain PRIMARY KEY,
    ho_ten          VARCHAR(100) NOT NULL CHECK (LENGTH(TRIM(ho_ten)) >= 2),
    ngay_sinh       DATE NOT NULL CHECK (ngay_sinh <= CURRENT_DATE),
    gioi_tinh       gioi_tinh_enum NOT NULL,
    dia_chi         VARCHAR(255),
    so_dien_thoai   TEXT[] NOT NULL DEFAULT '{}',
    ngay_tao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Bảng con: Bệnh nhân (Kế thừa chồng lặp từ nguoi)
CREATE TABLE IF NOT EXISTS benh_nhan (
    ma_benh_nhan    ma_bn_domain PRIMARY KEY,
    ma_dinh_danh    cccd_domain NOT NULL UNIQUE,
    nhom_mau        nhom_mau_enum,
    tien_su_di_ung  TEXT,
    tien_su_benh    TEXT,
    CONSTRAINT fk_benh_nhan_nguoi 
        FOREIGN KEY (ma_dinh_danh) REFERENCES nguoi(ma_dinh_danh) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Bảng Khoa phòng & Phòng khám
CREATE TABLE IF NOT EXISTS khoa_phong (
    ma_khoa_phong   VARCHAR(10) PRIMARY KEY CHECK (ma_khoa_phong ~ '^[A-Z0-9_]{3,10}$'),
    ten_khoa_phong  VARCHAR(100) NOT NULL CHECK (LENGTH(TRIM(ten_khoa_phong)) >= 3),
    loai_phong      loai_phong_enum NOT NULL,
    vi_tri_tang     VARCHAR(50)
);

-- Bảng con: Cán bộ y tế (Kế thừa chồng lặp từ nguoi)
CREATE TABLE IF NOT EXISTS nhan_vien_y_te (
    ma_nhan_vien        ma_nv_domain PRIMARY KEY,
    ma_dinh_danh        cccd_domain NOT NULL UNIQUE,
    ma_khoa_phong       VARCHAR(10) NOT NULL,
    hoc_vi              VARCHAR(50),
    chuc_vu             VARCHAR(50) NOT NULL DEFAULT 'NHAN_VIEN',
    trang_thai_lam_viec trang_thai_lam_viec_enum NOT NULL DEFAULT 'DANG_LAM_VIEC',
    CONSTRAINT fk_nhan_vien_nguoi 
        FOREIGN KEY (ma_dinh_danh) REFERENCES nguoi(ma_dinh_danh) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_nhan_vien_khoa 
        FOREIGN KEY (ma_khoa_phong) REFERENCES khoa_phong(ma_khoa_phong) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Bác sĩ (Kế thừa rời rạc từ nhan_vien_y_te)
CREATE TABLE IF NOT EXISTS bac_si (
    ma_nhan_vien        ma_nv_domain PRIMARY KEY,
    chung_chi_hanh_nghe VARCHAR(30) NOT NULL UNIQUE CHECK (LENGTH(TRIM(chung_chi_hanh_nghe)) > 0),
    chuyen_khoa_chinh   VARCHAR(100) NOT NULL,
    CONSTRAINT fk_bac_si_nhan_vien 
        FOREIGN KEY (ma_nhan_vien) REFERENCES nhan_vien_y_te(ma_nhan_vien) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Kỹ thuật viên (Kế thừa rời rạc từ nhan_vien_y_te)
CREATE TABLE IF NOT EXISTS ky_thuat_vien (
    ma_nhan_vien                ma_nv_domain PRIMARY KEY,
    linh_vuc_chuyen_trach       VARCHAR(50) NOT NULL,
    chung_chi_an_toan_buc_xa    VARCHAR(30),
    CONSTRAINT fk_ktv_nhan_vien 
        FOREIGN KEY (ma_nhan_vien) REFERENCES nhan_vien_y_te(ma_nhan_vien) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Nhân viên tiếp nhận (Kế thừa rời rạc từ nhan_vien_y_te)
CREATE TABLE IF NOT EXISTS nhan_vien_tiep_nhan (
    ma_nhan_vien    ma_nv_domain PRIMARY KEY,
    quay_tiep_nhan  VARCHAR(30) NOT NULL,
    CONSTRAINT fk_tiep_nhan_nhan_vien 
        FOREIGN KEY (ma_nhan_vien) REFERENCES nhan_vien_y_te(ma_nhan_vien) 
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 2. PHÂN HỆ HỒ SƠ KHÁM BỆNH LÂM SÀNG
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ho_so_kham_benh (
    ma_ho_so                BIGSERIAL PRIMARY KEY,
    ma_benh_nhan            ma_bn_domain NOT NULL,
    ma_bac_si_kham          ma_nv_domain NOT NULL,
    ma_phong_kham           VARCHAR(10) NOT NULL,
    thoi_gian_tiep_nhan     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    thoi_gian_kham          TIMESTAMP,
    mach                    INTEGER CHECK (mach BETWEEN 30 AND 220),
    nhiet_do                NUMERIC(3,1) CHECK (nhiet_do BETWEEN 34.0 AND 43.0),
    huyet_ap_tam_thu        INTEGER CHECK (huyet_ap_tam_thu BETWEEN 60 AND 250),
    huyet_ap_tam_truong     INTEGER CHECK (huyet_ap_tam_truong >= 40 AND huyet_ap_tam_truong < huyet_ap_tam_thu),
    chieu_cao               NUMERIC(4,1) CHECK (chieu_cao BETWEEN 40.0 AND 250.0),
    can_nang                NUMERIC(4,1) CHECK (can_nang BETWEEN 2.0 AND 300.0),
    chi_so_bmi              NUMERIC(4,2),
    ly_do_kham              TEXT NOT NULL CHECK (LENGTH(TRIM(ly_do_kham)) > 0),
    chan_doan_so_bo         TEXT,
    chan_doan_xac_dinh      TEXT,
    loi_dan_bac_si          TEXT,
    ngay_hen_tai_kham       DATE CHECK (ngay_hen_tai_kham > DATE(thoi_gian_tiep_nhan)),
    trang_thai_kham         trang_thai_kham_enum NOT NULL DEFAULT 'CHO_KHAM',
    is_deleted              BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_ho_so_benh_nhan 
        FOREIGN KEY (ma_benh_nhan) REFERENCES benh_nhan(ma_benh_nhan) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ho_so_bac_si 
        FOREIGN KEY (ma_bac_si_kham) REFERENCES bac_si(ma_nhan_vien) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ho_so_phong 
        FOREIGN KEY (ma_phong_kham) REFERENCES khoa_phong(ma_khoa_phong) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_thoi_gian_kham 
        CHECK (thoi_gian_kham IS NULL OR thoi_gian_kham >= thoi_gian_tiep_nhan)
);

-- ----------------------------------------------------------------------------
-- 3. PHÂN HỆ CẬN LÂM SÀNG & KẾT QUẢ XÉT NGHIỆM ĐA HÌNH
-- ----------------------------------------------------------------------------

-- Danh mục kỹ thuật xét nghiệm
CREATE TABLE IF NOT EXISTS danh_muc_xet_nghiem (
    ma_danh_muc_xn          VARCHAR(15) PRIMARY KEY CHECK (ma_danh_muc_xn ~ '^[A-Z0-9_]{3,15}$'),
    ten_xet_nghiem          VARCHAR(150) NOT NULL,
    nhom_xet_nghiem         nhom_xet_nghiem_enum NOT NULL,
    hinh_thai_ket_qua       hinh_thai_kq_enum NOT NULL,
    don_gia_dich_vu         NUMERIC(12,2) NOT NULL CHECK (don_gia_dich_vu >= 0),
    thoi_gian_chuan_tra_kq  INTEGER NOT NULL DEFAULT 60 CHECK (thoi_gian_chuan_tra_kq > 0)
);

-- Phiếu chỉ định cận lâm sàng
CREATE TABLE IF NOT EXISTS phieu_chi_dinh_xet_nghiem (
    ma_phieu_chi_dinh       BIGSERIAL PRIMARY KEY,
    ma_ho_so                BIGINT NOT NULL,
    ma_bac_si_chi_dinh      ma_nv_domain NOT NULL,
    thoi_gian_chi_dinh      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    trang_thai_phieu        trang_thai_phieu_enum NOT NULL DEFAULT 'CHO_THUC_HIEN',
    ghi_chu_lam_sang        TEXT,
    is_deleted              BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_phieu_ho_so 
        FOREIGN KEY (ma_ho_so) REFERENCES ho_so_kham_benh(ma_ho_so) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_phieu_bac_si 
        FOREIGN KEY (ma_bac_si_chi_dinh) REFERENCES bac_si(ma_nhan_vien) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Sequence chung cho khóa chính của phân cấp kết quả xét nghiệm
CREATE SEQUENCE IF NOT EXISTS seq_ket_qua_xet_nghiem_id START 1;

-- Bảng cha: Siêu lớp Kết quả xét nghiệm (Object-Relational Base Table)
CREATE TABLE IF NOT EXISTS ket_qua_xet_nghiem (
    ma_ket_qua              BIGINT PRIMARY KEY DEFAULT nextval('seq_ket_qua_xet_nghiem_id'),
    ma_phieu_chi_dinh       BIGINT NOT NULL,
    ma_danh_muc_xn          VARCHAR(15) NOT NULL,
    ma_ktv_thuc_hien        ma_nv_domain,
    thoi_gian_tiep_nhan_mau TIMESTAMP,
    thoi_gian_co_ket_qua    TIMESTAMP,
    trang_thai_ket_qua      trang_thai_kq_enum NOT NULL DEFAULT 'CHO_KET_QUA',
    ket_luan_tong_quat      TEXT,
    so_phien_ban            INTEGER NOT NULL DEFAULT 1 CHECK (so_phien_ban >= 1),
    is_deleted              BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_kq_phieu 
        FOREIGN KEY (ma_phieu_chi_dinh) REFERENCES phieu_chi_dinh_xet_nghiem(ma_phieu_chi_dinh) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_kq_danhmuc 
        FOREIGN KEY (ma_danh_muc_xn) REFERENCES danh_muc_xet_nghiem(ma_danh_muc_xn) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_kq_ktv 
        FOREIGN KEY (ma_ktv_thuc_hien) REFERENCES ky_thuat_vien(ma_nhan_vien) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_thoi_gian_ket_qua 
        CHECK (thoi_gian_co_ket_qua IS NULL OR thoi_gian_tiep_nhan_mau IS NULL OR thoi_gian_co_ket_qua >= thoi_gian_tiep_nhan_mau)
);

-- Lớp con 1: Kết quả xét nghiệm Định lượng (Số học) kế thừa bảng cha
CREATE TABLE IF NOT EXISTS ket_qua_dinh_luong (
    gia_tri_do          NUMERIC(10,3) NOT NULL,
    don_vi_tinh         VARCHAR(30) NOT NULL,
    chi_so_min_chuan    NUMERIC(10,3) NOT NULL,
    chi_so_max_chuan    NUMERIC(10,3) NOT NULL CHECK (chi_so_max_chuan > chi_so_min_chuan),
    muc_do_canh_bao     canh_bao_enum NOT NULL DEFAULT 'BINH_THUONG'
) INHERITS (ket_qua_xet_nghiem);

-- Lớp con 2: Kết quả Chẩn đoán hình ảnh kế thừa bảng cha
CREATE TABLE IF NOT EXISTS ket_qua_hinh_anh (
    duong_dan_tep_anh   TEXT NOT NULL CHECK (LENGTH(TRIM(duong_dan_tep_anh)) > 0),
    ky_thuat_chup       VARCHAR(100) NOT NULL,
    vung_khao_sat       VARCHAR(100) NOT NULL,
    mo_ta_ton_thuong    TEXT NOT NULL
) INHERITS (ket_qua_xet_nghiem);

-- Lớp con 3: Kết quả xét nghiệm Định tính & Vi sinh kế thừa bảng cha
CREATE TABLE IF NOT EXISTS ket_qua_dinh_tinh (
    ket_qua_danh_gia    danh_gia_dinh_tinh_enum NOT NULL,
    ten_chung_vi_khuan  VARCHAR(150),
    mo_ta_vi_sinh       TEXT,
    khang_sinh_nhay_cam TEXT[] NOT NULL DEFAULT '{}'
) INHERITS (ket_qua_xet_nghiem);

-- ----------------------------------------------------------------------------
-- 4. PHÂN HỆ KÊ ĐƠN & DƯỢC PHẨM
-- ----------------------------------------------------------------------------

-- Danh mục Thuốc
CREATE TABLE IF NOT EXISTS thuoc (
    ma_thuoc        VARCHAR(15) PRIMARY KEY CHECK (ma_thuoc ~ '^[A-Z0-9_]{3,15}$'),
    ten_thuoc       VARCHAR(150) NOT NULL,
    hoat_chat       VARCHAR(150) NOT NULL,
    ham_luong       VARCHAR(50) NOT NULL,
    dang_bao_che    VARCHAR(50) NOT NULL,
    don_vi_tinh     VARCHAR(20) NOT NULL,
    don_gia         NUMERIC(12,2) NOT NULL CHECK (don_gia >= 0)
);

-- Bảng Đơn thuốc (Quan hệ 1-1 với Hồ sơ khám bệnh)
CREATE TABLE IF NOT EXISTS don_thuoc (
    ma_don_thuoc    BIGSERIAL PRIMARY KEY,
    ma_ho_so        BIGINT NOT NULL UNIQUE,
    ma_bac_si_ke    ma_nv_domain NOT NULL,
    ngay_ke_don     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    loi_dan_chung   TEXT,
    is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_don_thuoc_ho_so 
        FOREIGN KEY (ma_ho_so) REFERENCES ho_so_kham_benh(ma_ho_so) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_don_thuoc_bac_si 
        FOREIGN KEY (ma_bac_si_ke) REFERENCES bac_si(ma_nhan_vien) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Thực thể yếu: Chi tiết đơn thuốc (Quan hệ định danh với don_thuoc)
CREATE TABLE IF NOT EXISTS chi_tiet_don_thuoc (
    ma_don_thuoc        BIGINT NOT NULL,
    so_thu_tu_dong      INTEGER NOT NULL CHECK (so_thu_tu_dong > 0),
    ma_thuoc            VARCHAR(15) NOT NULL,
    so_luong            INTEGER NOT NULL CHECK (so_luong > 0),
    lieu_dung_moi_lan   VARCHAR(50) NOT NULL,
    so_lan_uong_ngay    INTEGER NOT NULL CHECK (so_lan_uong_ngay BETWEEN 1 AND 6),
    thoi_diem_uong      VARCHAR(100) NOT NULL,
    so_ngay_dung        INTEGER NOT NULL CHECK (so_ngay_dung > 0),
    PRIMARY KEY (ma_don_thuoc, so_thu_tu_dong),
    CONSTRAINT fk_chi_tiet_don_thuoc 
        FOREIGN KEY (ma_don_thuoc) REFERENCES don_thuoc(ma_don_thuoc) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_chi_tiet_thuoc 
        FOREIGN KEY (ma_thuoc) REFERENCES thuoc(ma_thuoc) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 5. PHÂN HỆ KIỂM TOÁN & LỊCH SỬ CHỈNH SỬA (AUDIT TRAIL)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS lich_su_chinh_sua (
    ma_lich_su          BIGSERIAL PRIMARY KEY,
    ten_bang            VARCHAR(50) NOT NULL,
    ma_ban_ghi          VARCHAR(50) NOT NULL,
    so_phien_ban        INTEGER NOT NULL CHECK (so_phien_ban >= 1),
    loai_thao_tac       thao_tac_audit_enum NOT NULL,
    du_lieu_cu          JSONB,
    du_lieu_moi         JSONB NOT NULL,
    ly_do_sua           TEXT NOT NULL CHECK (LENGTH(TRIM(ly_do_sua)) >= 5),
    nguoi_thuc_hien     ma_nv_domain NOT NULL,
    thoi_gian_sua       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_nhan_vien 
        FOREIGN KEY (nguoi_thuc_hien) REFERENCES nhan_vien_y_te(ma_nhan_vien) 
        ON DELETE RESTRICT ON UPDATE CASCADE
);

