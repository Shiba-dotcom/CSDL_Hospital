-- ============================================================================
-- SCRIPT THỰC THI 6 TRUY VẤN SQL NÂNG CAO (TUẦN 7: Q1 ĐẾN Q6)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '======================================================================'
\echo 'TRUY VẤN Q1: CORRELATED SUBQUERY - BỆNH NHÂN CÓ XN BẤT THƯỜNG VƯỢT MỨC TB'
\echo '======================================================================'
\i sql/queries/q01_correlated_subquery.sql

\echo '======================================================================'
\echo 'TRUY VẤN Q2: MULTI-TABLE JOIN + AGGREGATION - HIỆU SUẤT KHÁM CỦA BÁC SĨ'
\echo '======================================================================'
\i sql/queries/q02_multitable_join_agg.sql

\echo '======================================================================'
\echo 'TRUY VẤN Q3: WINDOW FUNCTIONS - PHÂN TÍCH XU HƯỚNG ĐƯỜNG HUYẾT THEO THỜI GIAN'
\echo '======================================================================'
\i sql/queries/q03_window_function_trend.sql

\echo '======================================================================'
\echo 'TRUY VẤN Q4: CTE RECURSIVE - TRUY VẾT LỘ TRÌNH ĐIỀU TRỊ VÀ TÁI KHÁM'
\echo '======================================================================'
\i sql/queries/q04_recursive_cte_pathway.sql

\echo '======================================================================'
\echo 'TRUY VẤN Q5: GROUP BY + HAVING SUBQUERY - CÁC XÉT NGHIỆM CÓ TỶ LỆ BẤT THƯỜNG CAO'
\echo '======================================================================'
\i sql/queries/q05_having_subquery_stats.sql

\echo '======================================================================'
\echo 'TRUY VẤN Q6: RELATIONAL DIVISION (DOUBLE NOT EXISTS) - BÁC SĨ CHỈ ĐỊNH ĐỦ SINH HÓA'
\echo '======================================================================'
\i sql/queries/q06_not_exists_set_division.sql

