-- ============================================================================
-- SCRIPT 03: THIẾT LẬP CHỈ MỤC (B-TREE, GIN & PARTIAL INDEXES)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- DBMS: PostgreSQL 16+
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. CHỈ MỤC B-TREE TRÊN CÁC KHÓA NGOẠI (TỐI ƯU HÓA PHÉP NỐI JOIN)
-- ----------------------------------------------------------------------------

-- Khóa ngoại trên hồ sơ khám bệnh
CREATE INDEX IF NOT EXISTS idx_ho_so_benh_nhan ON ho_so_kham_benh (ma_benh_nhan);
CREATE INDEX IF NOT EXISTS idx_ho_so_bac_si ON ho_so_kham_benh (ma_bac_si_kham);
CREATE INDEX IF NOT EXISTS idx_ho_so_phong ON ho_so_kham_benh (ma_phong_kham);
CREATE INDEX IF NOT EXISTS idx_ho_so_thoi_gian ON ho_so_kham_benh (thoi_gian_tiep_nhan DESC);

-- Khóa ngoại trên phiếu chỉ định xét nghiệm
CREATE INDEX IF NOT EXISTS idx_phieu_ho_so ON phieu_chi_dinh_xet_nghiem (ma_ho_so);
CREATE INDEX IF NOT EXISTS idx_phieu_bac_si ON phieu_chi_dinh_xet_nghiem (ma_bac_si_chi_dinh);

-- Khóa ngoại trên kết quả xét nghiệm (bảng cha và các bảng kế thừa)
CREATE INDEX IF NOT EXISTS idx_kq_phieu ON ket_qua_xet_nghiem (ma_phieu_chi_dinh);
CREATE INDEX IF NOT EXISTS idx_kq_danhmuc ON ket_qua_xet_nghiem (ma_danh_muc_xn);
CREATE INDEX IF NOT EXISTS idx_kq_ktv ON ket_qua_xet_nghiem (ma_ktv_thuc_hien);

-- Khóa ngoại trên phân hệ đơn thuốc
CREATE INDEX IF NOT EXISTS idx_don_thuoc_bac_si ON don_thuoc (ma_bac_si_ke);
CREATE INDEX IF NOT EXISTS idx_ctdt_thuoc ON chi_tiet_don_thuoc (ma_thuoc);

-- Khóa ngoại trên nhân sự
CREATE INDEX IF NOT EXISTS idx_nhan_vien_khoa ON nhan_vien_y_te (ma_khoa_phong);

-- ----------------------------------------------------------------------------
-- 2. CHỈ MỤC BỘ PHẬN (PARTIAL INDEXES - TỐI ƯU HÓA TRUY VẤN DỮ LIỆU HIỆN HÀNH)
-- ----------------------------------------------------------------------------

-- Bác sĩ chỉ truy vấn các hồ sơ chưa bị xóa mềm
CREATE INDEX IF NOT EXISTS idx_ho_so_active 
ON ho_so_kham_benh (ma_benh_nhan, thoi_gian_tiep_nhan DESC) 
WHERE is_deleted = FALSE;

-- Phiếu xét nghiệm đang hoạt động
CREATE INDEX IF NOT EXISTS idx_phieu_active 
ON phieu_chi_dinh_xet_nghiem (ma_ho_so) 
WHERE is_deleted = FALSE;

-- Kết quả xét nghiệm đang hoạt động
CREATE INDEX IF NOT EXISTS idx_kq_active 
ON ket_qua_xet_nghiem (ma_phieu_chi_dinh, ma_danh_muc_xn) 
WHERE is_deleted = FALSE;

-- ----------------------------------------------------------------------------
-- 3. CHỈ MỤC GIN (GENERALIZED INVERTED INDEX - MẢNG & JSONB)
-- ----------------------------------------------------------------------------

-- GIN Index trên mảng số điện thoại của bảng người (Tìm kiếm nhanh theo SĐT)
CREATE INDEX IF NOT EXISTS idx_gin_nguoi_sdt 
ON nguoi USING GIN (so_dien_thoai);

-- GIN Index trên mảng kháng sinh nhạy cảm của xét nghiệm vi sinh
CREATE INDEX IF NOT EXISTS idx_gin_kq_khang_sinh 
ON ket_qua_dinh_tinh USING GIN (khang_sinh_nhay_cam);

-- GIN Index trên các trường JSONB của bảng lịch sử chỉnh sửa (Audit Trail)
-- Cho phép truy vấn thần tốc các trường lồng nhau bên trong snapshot JSONB
CREATE INDEX IF NOT EXISTS idx_gin_audit_cu 
ON lich_su_chinh_sua USING GIN (du_lieu_cu);

CREATE INDEX IF NOT EXISTS idx_gin_audit_moi 
ON lich_su_chinh_sua USING GIN (du_lieu_moi);

-- Chỉ mục tìm kiếm theo bảng và bản ghi bị sửa đổi
CREATE INDEX IF NOT EXISTS idx_audit_lookup 
ON lich_su_chinh_sua (ten_bang, ma_ban_ghi, thoi_gian_sua DESC);

