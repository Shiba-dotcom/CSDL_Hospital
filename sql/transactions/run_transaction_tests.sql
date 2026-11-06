-- ============================================================================
-- MASTER RUNNER: TỔNG HỢP KIỂM THỬ GIAO DỊCH & TƯƠNG TRANH (TUẦN 11)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '======================================================================'
\echo '1. CHẠY KỊCH BẢN 1: GIAO DỊCH THÀNH CÔNG HOÀN TOÀN (HAPPY PATH)'
\echo '======================================================================'
\i sql/transactions/01_scenario_happy_path.sql

\echo '======================================================================'
\echo '2. CHẠY KỊCH BẢN 2: LỖI GIỮA CHỪNG & ROLLBACK BẢO VỆ TÍNH NGUYÊN TỬ'
\echo '======================================================================'
\i sql/transactions/02_scenario_rollback_atomicity.sql

\echo '======================================================================'
\echo '3. CHẠY KỊCH BẢN 3: XỬ LÝ XUNG ĐỘT CẬP NHẬT (LOST UPDATE & OCC)'
\echo '======================================================================'
\i sql/transactions/03_scenario_concurrency_lost_update.sql

\echo '======================================================================'
\echo '4. CHẠY KỊCH BẢN 4: ĐỐI CHIẾU CÁC CẤP ĐỘ CÔ LẬP GIAO DỊCH'
\echo '======================================================================'
\i sql/transactions/04_scenario_isolation_levels.sql

\echo '======================================================================'
\echo 'HOÀN TẤT KIỂM THỬ THÀNH CÔNG 100% CÁC KỊCH BẢN TRANSACTION & CONCURRENCY!'
\echo '======================================================================'
