-- ============================================================================
-- TUẦN 10: THỰC NGHIỆM ĐO HIỆU NĂNG & TỐI ƯU HÓA TRUY VẤN (EXPLAIN ANALYZE)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '======================================================================'
\echo '1. BENCHMARK 1: TÌM KIẾM CHỈ SỐ XÉT NGHIỆM ĐỊNH LƯỢNG (GLUCOSE >= 7.0)'
\echo '======================================================================'

-- 1.1. Chưa dùng Index (Seq Scan cưỡng bức)
\echo '--> [1.1] Kế hoạch thực thi khi QUÉT TUẦN TỰ (Sequential Scan):'
SET enable_indexscan = off;
SET enable_bitmapscan = off;

EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT 
    kq.ma_ket_qua,
    kq.ma_danh_muc_xn,
    kq.gia_tri_do,
    kq.don_vi_tinh,
    kq.muc_do_canh_bao
FROM ket_qua_dinh_luong kq
WHERE kq.ma_danh_muc_xn = 'GLUCOSE' 
  AND kq.gia_tri_do >= 7.0;

-- 1.2. Sử dụng Composite B-Tree Index (idx_kqdl_dm_giatri)
\echo '--> [1.2] Kế hoạch thực thi khi DÙNG COMPOSITE B-TREE INDEX:'
SET enable_indexscan = on;
SET enable_bitmapscan = on;

-- Đảm bảo index tổng hợp tồn tại
CREATE INDEX IF NOT EXISTS idx_kqdl_dm_giatri 
ON ket_qua_dinh_luong (ma_danh_muc_xn, gia_tri_do);

EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT 
    kq.ma_ket_qua,
    kq.ma_danh_muc_xn,
    kq.gia_tri_do,
    kq.don_vi_tinh,
    kq.muc_do_canh_bao
FROM ket_qua_dinh_luong kq
WHERE kq.ma_danh_muc_xn = 'GLUCOSE' 
  AND kq.gia_tri_do >= 7.0;


\echo '======================================================================'
\echo '2. BENCHMARK 2: TRUY VẤN AUDIT TRAIL TRÊN TRƯỜNG DỮ LIỆU BÁN CẤU TRÚC JSONB'
\echo '======================================================================'

-- 2.1. Quét tuần tự JSONB không dùng GIN Index
\echo '--> [2.1] Kế hoạch thực thi JSONB khi QUÉT TUẦN TỰ (Seq Scan):'
SET enable_bitmapscan = off;
SET enable_indexscan = off;

EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT 
    ls.ma_lich_su,
    ls.ten_bang,
    ls.ma_ban_ghi,
    ls.du_lieu_cu->>'gia_tri_do' AS gia_tri_cu,
    ls.du_lieu_moi->>'gia_tri_do' AS gia_tri_moi,
    ls.thoi_gian_sua
FROM lich_su_chinh_sua ls
WHERE ls.du_lieu_moi ? 'gia_tri_do';

-- 2.2. Dùng GIN Index chuyên dụng cho JSONB
\echo '--> [2.2] Kế hoạch thực thi JSONB khi DÙNG GIN INDEX:'
SET enable_bitmapscan = on;
SET enable_indexscan = on;

CREATE INDEX IF NOT EXISTS idx_audit_du_lieu_moi_gin 
ON lich_su_chinh_sua USING GIN (du_lieu_moi);

EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT 
    ls.ma_lich_su,
    ls.ten_bang,
    ls.ma_ban_ghi,
    ls.du_lieu_cu->>'gia_tri_do' AS gia_tri_cu,
    ls.du_lieu_moi->>'gia_tri_do' AS gia_tri_moi,
    ls.thoi_gian_sua
FROM lich_su_chinh_sua ls
WHERE ls.du_lieu_moi ? 'gia_tri_do';


\echo '======================================================================'
\echo '3. BENCHMARK 3: LỌC HỒ SƠ KHÁM THEO KHOẢNG THỜI GIAN (RANGE QUERY)'
\echo '======================================================================'

-- 3.1. Quét tuần tự bảng ho_so_kham_benh
\echo '--> [3.1] Lọc thời gian khi QUÉT TUẦN TỰ (Seq Scan):'
SET enable_indexscan = off;
SET enable_bitmapscan = off;

EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT 
    hs.ma_ho_so,
    hs.ma_benh_nhan,
    hs.ma_bac_si_kham,
    hs.thoi_gian_kham,
    hs.chan_doan_xac_dinh
FROM ho_so_kham_benh hs
WHERE hs.thoi_gian_kham >= '2026-10-01 00:00:00' 
  AND hs.thoi_gian_kham < '2026-11-01 00:00:00'
  AND hs.is_deleted = FALSE;

-- 3.2. Dùng B-Tree Index trên thoi_gian_kham
\echo '--> [3.2] Lọc thời gian khi DÙNG B-TREE INDEX (Index Scan):'
SET enable_indexscan = on;
SET enable_bitmapscan = on;

CREATE INDEX IF NOT EXISTS idx_ho_so_thoi_gian_kham 
ON ho_so_kham_benh (thoi_gian_kham) 
WHERE is_deleted = FALSE;

EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT 
    hs.ma_ho_so,
    hs.ma_benh_nhan,
    hs.ma_bac_si_kham,
    hs.thoi_gian_kham,
    hs.chan_doan_xac_dinh
FROM ho_so_kham_benh hs
WHERE hs.thoi_gian_kham >= '2026-10-01 00:00:00' 
  AND hs.thoi_gian_kham < '2026-11-01 00:00:00'
  AND hs.is_deleted = FALSE;


\echo '======================================================================'
\echo '4. BENCHMARK 4: PHÂN TÍCH WINDOW FUNCTION & GIẢI THUẬT SẮP XẾP BỘ ĐỆM'
\echo '======================================================================'

EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT 
    bn.ma_benh_nhan,
    kq.gia_tri_do,
    DENSE_RANK() OVER (PARTITION BY bn.ma_benh_nhan ORDER BY hs.thoi_gian_kham ASC) AS lan_do,
    LAG(kq.gia_tri_do, 1) OVER (PARTITION BY bn.ma_benh_nhan ORDER BY hs.thoi_gian_kham ASC) AS gia_tri_lan_truoc
FROM benh_nhan bn
JOIN ho_so_kham_benh hs ON bn.ma_benh_nhan = hs.ma_benh_nhan AND hs.is_deleted = FALSE
JOIN phieu_chi_dinh_xet_nghiem p ON hs.ma_ho_so = p.ma_ho_so AND p.is_deleted = FALSE
JOIN ket_qua_dinh_luong kq ON p.ma_phieu_chi_dinh = kq.ma_phieu_chi_dinh AND kq.is_deleted = FALSE
WHERE kq.ma_danh_muc_xn = 'GLUCOSE';


\echo '======================================================================'
\echo '5. BENCHMARK 5: TRUY VẤN ĐA HÌNH KẾ THỪA (APPEND NODE SCAN vs ONLY)'
\echo '======================================================================'

\echo '--> [5.1] Quét toàn bộ cây kế thừa (Polymorphic Append Scan):'
EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT ma_ket_qua, ma_phieu_chi_dinh, ma_danh_muc_xn 
FROM ket_qua_xet_nghiem;

\echo '--> [5.2] Quét DUY NHẤT bảng cha không quét bảng con (Mệnh đề ONLY):'
EXPLAIN (ANALYZE, BUFFERS, COSTS, TIMING, SUMMARY)
SELECT ma_ket_qua, ma_phieu_chi_dinh, ma_danh_muc_xn 
FROM ONLY ket_qua_xet_nghiem;

-- Khôi phục cấu hình tối ưu hóa chuẩn của PostgreSQL
RESET enable_seqscan;
RESET enable_indexscan;
RESET enable_bitmapscan;
