-- ============================================================================
-- SCRIPT 01: KHỞI TẠO CUSTOM TYPES, ENUMS VÀ DOMAINS
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- DBMS: PostgreSQL 16+
-- ============================================================================

-- Bật extension kiểm tra UUID và chuỗi nếu cần
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ----------------------------------------------------------------------------
-- 1. CÁC KIỂU DỮ LIỆU LIỆT KÊ (ENUM TYPES)
-- ----------------------------------------------------------------------------

-- Giới tính sinh học
DO $$ BEGIN
    CREATE TYPE gioi_tinh_enum AS ENUM ('NAM', 'NU', 'KHAC');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Nhóm máu hệ ABO và Rh
DO $$ BEGIN
    CREATE TYPE nhom_mau_enum AS ENUM ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Trạng thái công tác nhân sự y tế
DO $$ BEGIN
    CREATE TYPE trang_thai_lam_viec_enum AS ENUM ('DANG_LAM_VIEC', 'NGHI_PHEP', 'DA_NGHI_VIEC');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Phân loại chức năng phòng khoa
DO $$ BEGIN
    CREATE TYPE loai_phong_enum AS ENUM (
        'KHOA_CHUYEN_MON', 
        'PHONG_KHAM_LAMSANG', 
        'PHONG_XET_NGHIEM', 
        'PHONG_CHUP_CHIEU', 
        'QUAY_TIEP_DON'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Trạng thái tiến trình đợt khám bệnh
DO $$ BEGIN
    CREATE TYPE trang_thai_kham_enum AS ENUM (
        'CHO_KHAM', 
        'DANG_KHAM', 
        'CHO_KET_QUA_XN', 
        'HOAN_THANH', 
        'DA_HUY'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Phân nhóm dịch vụ xét nghiệm
DO $$ BEGIN
    CREATE TYPE nhom_xet_nghiem_enum AS ENUM (
        'SINH_HOA', 
        'HUYET_HOC', 
        'VI_SINH', 
        'CHIEU_CHUP', 
        'THAM_DO_CN'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Hình thái cấu trúc kết quả (quyết định đa hình)
DO $$ BEGIN
    CREATE TYPE hinh_thai_kq_enum AS ENUM (
        'DINH_LUONG', 
        'HINH_ANH', 
        'DINH_TINH'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Trạng thái xử lý phiếu chỉ định
DO $$ BEGIN
    CREATE TYPE trang_thai_phieu_enum AS ENUM (
        'CHO_THUC_HIEN', 
        'DANG_THUC_HIEN', 
        'DA_CO_KET_QUA', 
        'DA_HUY'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Trạng thái kết quả xét nghiệm
DO $$ BEGIN
    CREATE TYPE trang_thai_kq_enum AS ENUM (
        'CHO_KET_QUA', 
        'SO_BO', 
        'CHINH_THUC', 
        'DINH_CHINH'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Mức độ cảnh báo chỉ số xét nghiệm số học
DO $$ BEGIN
    CREATE TYPE canh_bao_enum AS ENUM (
        'BINH_THUONG', 
        'THAP', 
        'CAO', 
        'NGUY_HIEM'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Kết quả đánh giá định tính vi sinh
DO $$ BEGIN
    CREATE TYPE danh_gia_dinh_tinh_enum AS ENUM (
        'AM_TINH', 
        'DUONG_TINH', 
        'NGHI_NGO'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Loại thao tác nhật ký kiểm toán (Audit Trail)
DO $$ BEGIN
    CREATE TYPE thao_tac_audit_enum AS ENUM (
        'INSERT', 
        'UPDATE', 
        'SOFT_DELETE'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ----------------------------------------------------------------------------
-- 2. CÁC MIỀN GIÁ TRỊ TỰ ĐỊNH NGHĨA (DOMAINS)
-- ----------------------------------------------------------------------------

-- Domain Căn cước công dân: Đúng 12 ký số
DO $$ BEGIN
    CREATE DOMAIN cccd_domain AS CHAR(12)
    CHECK (VALUE ~ '^[0-9]{12}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Domain Mã bệnh nhân: Định dạng BN-XXXXXX hoặc BN-XXXXXXX
DO $$ BEGIN
    CREATE DOMAIN ma_bn_domain AS VARCHAR(10)
    CHECK (VALUE ~ '^BN-[0-9]{6,7}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Domain Mã nhân viên y tế: Định dạng NV-XXXXX (5 chữ số)
DO $$ BEGIN
    CREATE DOMAIN ma_nv_domain AS CHAR(8)
    CHECK (VALUE ~ '^NV-[0-9]{5}$');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
