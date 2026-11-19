-- ============================================================================
-- SCRIPT KIỂM THỬ TỔNG HỢP 6 TRUY VẤN SQL NÂNG CAO (TUẦN 8: Q7 ĐẾN Q12)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '======================================================================'
\echo '1. KHỞI TẠO VÀ THỰC THI Q7: STORED PROCEDURE QUY TRÌNH KHÁM BỆNH'
\echo '======================================================================'
\i sql/queries/q07_stored_procedure_workflow.sql

\echo '======================================================================'
\echo '2. KHỞI TẠO VÀ THỰC THI Q8: DYNAMIC SQL THỐNG KÊ LINH HOẠT'
\echo '======================================================================'
\i sql/queries/q08_dynamic_sql_reporting.sql

\echo '======================================================================'
\echo '3. KHỞI TẠO VÀ THỰC THI Q9: FUNCTION TÌM KIẾM BỆNH NHÂN ĐA TIÊU CHÍ'
\echo '======================================================================'
\i sql/queries/q09_table_function_search.sql

\echo '======================================================================'
\echo '4. THỰC THI Q10: TRUY VẤN JSONB NHẬT KÝ KIỂM TOÁN (AUDIT TRAIL)'
\echo '======================================================================'
\i sql/queries/q10_jsonb_audit_query.sql

\echo '======================================================================'
\echo '5. THỰC THI Q11: PIVOT / CROSSTAB MA TRẬN PHÂN BỔ XÉT NGHIỆM'
\echo '======================================================================'
\i sql/queries/q11_pivot_crosstab.sql

\echo '======================================================================'
\echo '6. KHỞI TẠO VÀ KIỂM THỬ Q12: TRIGGER CẢNH BÁO AN TOÀN DƯỢC (CDSS)'
\echo '======================================================================'
\i sql/queries/q12_business_safety_trigger.sql

\echo '======================================================================'
\echo 'HOÀN TẤT KIỂM THỬ THÀNH CÔNG 100% TOÀN BỘ 12 TRUY VẤN SQL NÂNG CAO!'
\echo '======================================================================'
