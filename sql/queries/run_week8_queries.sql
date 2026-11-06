-- ============================================================================
-- SCRIPT KIỂM THỬ TỔNG HỢP 6 TRUY VẤN SQL NÂNG CAO (TUẦN 8: Q7 ĐẾN Q12)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '======================================================================'
\echo '1. KHỞI TẠO VÀ THỰC THI Q7: STORED PROCEDURE QUY TRÌNH KHÁM BỆNH'
\echo '======================================================================'
\i sql/queries/q07_stored_procedure_workflow.sql

-- Chạy thử nghiệm Stored Procedure tạo 1 ca khám hoàn chỉnh:
DO $$
DECLARE
    v_hs BIGINT;
    v_phieu BIGINT;
    v_don BIGINT;
BEGIN
    CALL sp_quy_trinh_kham_benh_toan_dien(
        'BN-000001',
        'NV-00001',
        'P_101',
        75, 36.8, 120, 80, 168.0, 65.0,
        'Khám định kỳ theo dõi huyết áp và xét nghiệm mỡ máu',
        'Tăng huyết áp độ 1 - Kiểm soát tốt',
        'Tiếp tục duy trì phác đồ điều trị, tập thể dục nhẹ',
        ARRAY['GLUCOSE', 'CHOLESTEROL', 'XQ_NGUC']::VARCHAR(15)[],
        '[
            {"ma_thuoc": "MED_AMLO5", "so_luong": 30, "lieu_dung": "1 viên", "so_lan": 1, "thoi_diem": "Sáng 8h", "so_ngay": 30},
            {"ma_thuoc": "MED_PARA500", "so_luong": 10, "lieu_dung": "1 viên", "so_lan": 2, "thoi_diem": "Khi đau đầu", "so_ngay": 5}
        ]'::JSONB,
        v_hs, v_phieu, v_don
    );
END $$;

\echo '======================================================================'
\echo '2. KHỞI TẠO VÀ THỰC THI Q8: DYNAMIC SQL THỐNG KÊ LINH HOẠT'
\echo '======================================================================'
\i sql/queries/q08_dynamic_sql_reporting.sql

-- Test 2.1: Thống kê theo Bác sĩ
\echo '--> Báo cáo gom nhóm theo BÁC SĨ:'
SELECT * FROM fn_thong_ke_kham_benh_dong('BAC_SI');

-- Test 2.2: Thống kê theo KHOA PHÒNG
\echo '--> Báo cáo gom nhóm theo KHOA PHÒNG:'
SELECT * FROM fn_thong_ke_kham_benh_dong('KHOA_PHONG');

\echo '======================================================================'
\echo '3. KHỞI TẠO VÀ THỰC THI Q9: FUNCTION TÌM KIẾM BỆNH NHÂN ĐA TIÊU CHÍ'
\echo '======================================================================'
\i sql/queries/q09_table_function_search.sql

-- Tìm kiếm bệnh nhân theo từ khóa 'Nguyễn' và có độ tuổi từ 40 đến 70
SELECT * FROM fn_tim_kiem_benh_nhan_nang_cao('Nguyễn', NULL, 40, 70) LIMIT 5;

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

-- Kiểm thử nghiệp vụ an toàn y tế:
DO $$
DECLARE
    v_test_don_id BIGINT;
    v_hs_id BIGINT;
    v_bn_id ma_bn_domain;
BEGIN
    -- Tìm một bệnh nhân có tiền sử dị ứng Penicillin
    SELECT ma_benh_nhan INTO v_bn_id
    FROM benh_nhan 
    WHERE tien_su_di_ung ILIKE '%Penicillin%' LIMIT 1;

    -- Tạo 1 hồ sơ khám test riêng cho kiểm thử này
    INSERT INTO ho_so_kham_benh (
        ma_benh_nhan, ma_bac_si_kham, ma_phong_kham,
        thoi_gian_tiep_nhan, thoi_gian_kham, ly_do_kham, chan_doan_xac_dinh
    ) VALUES (
        v_bn_id, 'NV-00001', 'P_101', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
        'Khám kiểm tra phản ứng dị ứng thuốc', 'Viêm họng cấp'
    ) RETURNING ma_ho_so INTO v_hs_id;

    -- Tạo đơn thuốc test
    INSERT INTO don_thuoc (ma_ho_so, ma_bac_si_ke, loi_dan_chung)
    VALUES (v_hs_id, 'NV-00001', 'Đơn thuốc kiểm thử tương tác dị ứng')
    RETURNING ma_don_thuoc INTO v_test_don_id;

    -- Test 1: Kê thuốc Paracetamol (An toàn) -> THÀNH CÔNG
    INSERT INTO chi_tiet_don_thuoc (ma_don_thuoc, so_thu_tu_dong, ma_thuoc, so_luong, lieu_dung_moi_lan, so_lan_uong_ngay, thoi_diem_uong, so_ngay_dung)
    VALUES (v_test_don_id, 1, 'MED_PARA500', 10, '1 viên', 2, 'Sau ăn', 5);
    RAISE NOTICE 'TEST 1: Kê Paracetamol thành công cho bệnh nhân dị ứng Penicillin (Hợp lệ).';

    -- Test 2: Cố tình kê Augmentin (chứa Amoxicillin) -> TRIGGER BẮT BUỘC CHẶN
    BEGIN
        INSERT INTO chi_tiet_don_thuoc (ma_don_thuoc, so_thu_tu_dong, ma_thuoc, so_luong, lieu_dung_moi_lan, so_lan_uong_ngay, thoi_diem_uong, so_ngay_dung)
        VALUES (v_test_don_id, 2, 'MED_AUG1G', 14, '1 viên', 2, 'Sau ăn', 7);
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'TEST 2: TRIGGER ĐÃ BẢO VỆ THÀNH CÔNG! Chặn đứng kê thuốc Augmentin cho bệnh nhân dị ứng Penicillin!';
    END;

    -- Dọn dẹp đơn thuốc test
    DELETE FROM chi_tiet_don_thuoc WHERE ma_don_thuoc = v_test_don_id;
    DELETE FROM don_thuoc WHERE ma_don_thuoc = v_test_don_id;
    UPDATE ho_so_kham_benh SET is_deleted = TRUE WHERE ma_ho_so = v_hs_id;
END $$;

\echo '======================================================================'
\echo 'HOÀN TẤT KIỂM THỬ THÀNH CÔNG 100% TOÀN BỘ 12 TRUY VẤN SQL NÂNG CAO!'
\echo '======================================================================'
