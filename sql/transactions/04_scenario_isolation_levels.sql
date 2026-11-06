-- ============================================================================
-- TUẦN 11: TRANSACTION & KIỂM THỬ TƯƠNG TRANH (CONCURRENCY)
-- Kịch bản 4: ĐỐI CHIẾU CÁC CẤP ĐỘ CÔ LẬP GIAO DỊCH (ISOLATION LEVELS)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '----------------------------------------------------------------------'
\echo 'BẮT ĐẦU KỊCH BẢN 4: SO SÁNH READ COMMITTED vs REPEATABLE READ vs SERIALIZABLE'
\echo '----------------------------------------------------------------------'

-- ============================================================================
-- PHẦN 1: THỬ NGHIỆM MỨC REPEATABLE READ VỚI LỖI CONCURRENT UPDATE SERIALIZATION
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '>>> KIỂM TRA ĐẶC TÍNH REPEATABLE READ TRONG POSTGRESQL:';
    RAISE NOTICE '- Cấp độ REPEATABLE READ bảo đảm một giao dịch luôn nhìn thấy snapshot dữ liệu nhất quán tại thời điểm bắt đầu.';
    RAISE NOTICE '- Ngăn chặn hoàn toàn các dị thường: Dirty Read, Non-Repeatable Read và Phantom Read.';
    RAISE NOTICE '- Khi phát hiện phiên đồng thời đã sửa đổi dòng dữ liệu đang được truy cập, PostgreSQL sẽ ném lỗi: could not serialize access due to concurrent update (SQLSTATE 40001).';
END $$;

-- Mô phỏng bắt lỗi 40001 (Serialization Failure) trong khối lệnh
DO $$
DECLARE
    v_val NUMERIC;
BEGIN
    -- Thiết lập mức cô lập REPEATABLE READ cho phiên
    -- (Trong mô phỏng khối DO, kiểm tra logic xử lý ngoại lệ serialization)
    BEGIN
        SELECT gia_tri_do INTO v_val FROM ket_qua_dinh_luong WHERE ma_ket_qua = 2;
        RAISE NOTICE 'Giá trị đo đọc được trong phiên: %', v_val;

        -- Giả định có xung đột tương tranh xảy ra từ phiên khác
        -- Khi đó hệ thống sẽ quăng ngoại lệ serialization_failure
    EXCEPTION 
        WHEN serialization_failure THEN
            RAISE WARNING 'BẮT ĐƯỢC LỖI SERIALIZATION FAILURE (40001): Ứng dụng tự động RETRY giao dịch!';
    END;
END $$;

-- ============================================================================
-- PHẦN 2: BẢNG SO SÁNH CÁC HIỆN TƯỢNG BẤT THƯỜNG TRÊN POSTGRESQL
-- ============================================================================

SELECT 
    'Read Committed' AS cap_do_co_lap,
    'KHÔNG' AS dirty_read,
    'CÓ THỂ XẢY RA' AS non_repeatable_read,
    'CÓ THỂ XẢY RA' AS phantom_read,
    'CÓ THỂ XẢY RA' AS serialization_anomaly,
    'Mặc định của PostgreSQL' AS ghi_chu
UNION ALL
SELECT 
    'Repeatable Read',
    'KHÔNG',
    'KHÔNG',
    'KHÔNG (Khác với chuẩn SQL:92)',
    'CÓ THỂ XẢY RA (Write Skew)',
    'Dùng snapshot cô lập'
UNION ALL
SELECT 
    'Serializable',
    'KHÔNG',
    'KHÔNG',
    'KHÔNG',
    'KHÔNG (An toàn tuyệt đối)',
    'Cơ chế SSI (Serializable Snapshot Isolation)';
