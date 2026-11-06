-- ============================================================================
-- TUẦN 11: TRANSACTION & KIỂM THỬ TƯƠNG TRANH (CONCURRENCY)
-- Kịch bản 2: LỖI GIỮA CHỪNG & ROLLBACK BẢO VỆ TÍNH NGUYÊN TỬ (ATOMICITY)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '----------------------------------------------------------------------'
\echo 'BẮT ĐẦU KỊCH BẢN 2: MÔ PHỎNG SỰ CỐ VÀ KIỂM CHỨNG TÍNH NGUYÊN TỬ (ALL-OR-NOTHING)'
\echo '----------------------------------------------------------------------'

-- 1. Ghi nhận số lượng bản ghi ban đầu của hệ thống
SELECT 
    (SELECT COUNT(*) FROM ho_so_kham_benh) AS tong_hs_truoc_khi_chay,
    (SELECT COUNT(*) FROM phieu_chi_dinh_xet_nghiem) AS tong_phieu_truoc_khi_chay,
    (SELECT COUNT(*) FROM ket_qua_xet_nghiem) AS tong_kq_truoc_khi_chay;

-- 2. BẮT ĐẦU GIAO DỊCH VỚI BEGIN
BEGIN;

\echo '>>> [Bước 1] Thêm Hồ sơ khám bệnh vào giao dịch (Tạm thời thành công)...'
INSERT INTO ho_so_kham_benh (
    ma_benh_nhan, ma_bac_si_kham, ma_phong_kham,
    thoi_gian_tiep_nhan, thoi_gian_kham, ly_do_kham, chan_doan_xac_dinh
) VALUES (
    'BN-000003', 'NV-00001', 'P_101',
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
    'Kiểm thử Rollback Atomicity Tuần 11', 'Nghi ngờ thiếu máu cơ tim'
);

\echo '>>> [Bước 2] Thêm Phiếu chỉ định xét nghiệm vào giao dịch (Tạm thời thành công)...'
INSERT INTO phieu_chi_dinh_xet_nghiem (
    ma_ho_so, ma_bac_si_chi_dinh, thoi_gian_chi_dinh, trang_thai_phieu, ghi_chu_lam_sang
) VALUES (
    (SELECT MAX(ma_ho_so) FROM ho_so_kham_benh), 'NV-00001', CURRENT_TIMESTAMP, 'CHO_THUC_HIEN', 'Chỉ định điện tim và men tim khẩn'
);

\echo '>>> [Bước 3] CỐ Ý GÂY LỖI: Chèn kết quả xét nghiệm vi phạm CHECK constraint (min=10.0 > max=2.0)...'
-- Lệnh dưới đây sẽ phát sinh lỗi vi phạm CHECK constraint: chi_so_max_chuan > chi_so_min_chuan
INSERT INTO ket_qua_dinh_luong (
    ma_phieu_chi_dinh, ma_danh_muc_xn, gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan
) VALUES (
    (SELECT MAX(ma_phieu_chi_dinh) FROM phieu_chi_dinh_xet_nghiem), 'GLUCOSE', 5.50, 'mmol/L', 10.00, 2.00
);

\echo '>>> [Bước 4] PHÁT LỆNH ROLLBACK ĐỂ HỦY BỎ VÀ HOÀN TÁC TOÀN BỘ GIAO DỊCH...'
ROLLBACK;

-- 3. ĐỐI CHỨNG TÍNH NGUYÊN TỬ (ALL-OR-NOTHING):
\echo '----------------------------------------------------------------------'
\echo 'KẾT QUẢ ĐỐI CHỨNG: SỐ LƯỢNG BẢN GHI SAU KHI ROLLBACK'
\echo '----------------------------------------------------------------------'
SELECT 
    (SELECT COUNT(*) FROM ho_so_kham_benh) AS tong_hs_sau_khi_loi,
    (SELECT COUNT(*) FROM phieu_chi_dinh_xet_nghiem) AS tong_phieu_sau_khi_loi,
    (SELECT COUNT(*) FROM ket_qua_xet_nghiem) AS tong_kq_sau_khi_loi;

-- Chứng minh không có bất kỳ Hồ sơ rác mồ côi nào lọt vào hệ thống (phải bằng 0)
SELECT COUNT(*) AS so_ho_so_rac_mo_coi
FROM ho_so_kham_benh
WHERE ly_do_kham = 'Kiểm thử Rollback Atomicity Tuần 11';
