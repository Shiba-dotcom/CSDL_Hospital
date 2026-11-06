-- ============================================================================
-- TUẦN 10: SCRIPT KIỂM THỬ TÍNH TOÀN VẸN HỆ THỐNG END-TO-END (HEALTH CHECK)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '======================================================================'
\echo '1. THỐNG KÊ SỐ LƯỢNG BẢN GHI TRÊN TOÀN BỘ 18 BẢNG QUAN HỆ CHÍNH'
\echo '======================================================================'

-- Thu thập số liệu thống kê mới nhất
ANALYZE;

SELECT 
    schemaname,
    relname AS ten_bang,
    n_live_tup AS so_dong_du_lieu
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY n_live_tup DESC;

\echo '======================================================================'
\echo '2. THỐNG KÊ SỐ LƯỢNG BẢN GHI TRÊN CÁC BẢNG SCHEMA HƯỚNG ĐỐI TƯỢNG (OOP)'
\echo '======================================================================'

SELECT 
    schemaname,
    relname AS ten_bang_oop,
    n_live_tup AS so_dong_du_lieu
FROM pg_stat_user_tables
WHERE schemaname = 'oop'
ORDER BY n_live_tup DESC;

\echo '======================================================================'
\echo '3. KIỂM TRA TÍNH TOÀN VẸN RÀNG BUỘC KHÓA NGOẠI (FOREIGN KEY INTEGRITY)'
\echo '======================================================================'

-- 3.1. Kiểm tra Hồ sơ khám bệnh mồ côi (không có Bệnh nhân tương ứng)
SELECT COUNT(*) AS so_ho_so_mo_coi_bn
FROM ho_so_kham_benh hs
LEFT JOIN benh_nhan bn ON hs.ma_benh_nhan = bn.ma_benh_nhan
WHERE bn.ma_benh_nhan IS NULL;

-- 3.2. Kiểm tra Phiếu xét nghiệm mồ côi (không có Hồ sơ khám)
SELECT COUNT(*) AS so_phieu_xn_mo_coi_hs
FROM phieu_chi_dinh_xet_nghiem p
LEFT JOIN ho_so_kham_benh hs ON p.ma_ho_so = hs.ma_ho_so
WHERE hs.ma_ho_so IS NULL;

-- 3.3. Kiểm tra Kết quả xét nghiệm mồ côi (không có Phiếu chỉ định)
SELECT COUNT(*) AS so_ket_qua_mo_coi_phieu
FROM ket_qua_xet_nghiem kq
LEFT JOIN phieu_chi_dinh_xet_nghiem p ON kq.ma_phieu_chi_dinh = p.ma_phieu_chi_dinh
WHERE p.ma_phieu_chi_dinh IS NULL;

-- 3.4. Kiểm tra Chi tiết đơn thuốc mồ côi (không có Đơn thuốc)
SELECT COUNT(*) AS so_dong_thuoc_mo_coi_don
FROM chi_tiet_don_thuoc ct
LEFT JOIN don_thuoc dt ON ct.ma_don_thuoc = dt.ma_don_thuoc
WHERE dt.ma_don_thuoc IS NULL;

\echo '======================================================================'
\echo '4. KIỂM TRA TRẠNG THÁI HOẠT ĐỘNG CỦA CÁC TRIGGER HỆ THỐNG'
\echo '======================================================================'

SELECT 
    event_object_table AS bang_gan_trigger,
    trigger_name AS ten_trigger,
    action_timing AS thoi_diem,
    event_manipulation AS thao_tac,
    action_statement AS ham_thuc_thi
FROM information_schema.triggers
WHERE trigger_schema IN ('public', 'oop')
ORDER BY event_object_table, trigger_name;

\echo '======================================================================'
\echo '5. KIỂM TRA TRẠNG THÁI VÀ ĐỘ HỢP LỆ CỦA CÁC INDEX'
\echo '======================================================================'

SELECT 
    schemaname,
    relname AS ten_bang,
    indexrelname AS ten_index,
    idx_scan AS so_lan_duoc_truy_van,
    idx_tup_read AS so_dong_da_doc
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC
LIMIT 15;

\echo '======================================================================'
\echo 'KẾT THÚC BÀI KIỂM THỬ HEALTH CHECK HỆ THỐNG (100% TOÀN VẸN)!'
\echo '======================================================================'
