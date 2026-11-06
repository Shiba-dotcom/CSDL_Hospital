-- ============================================================================
-- TUẦN 11: TRANSACTION & KIỂM THỬ TƯƠNG TRANH (CONCURRENCY)
-- Kịch bản 3: PHÒNG CHỐNG XUNG ĐỘT CẬP NHẬT (LOST UPDATE & PESSIMISTIC LOCKING)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '----------------------------------------------------------------------'
\echo 'BẮT ĐẦU KỊCH BẢN 3: MÔ PHỎNG VÀ XỬ LÝ TRANH CHẤP TƯƠNG TRANH GIỮA 2 PHIÊN'
\echo '----------------------------------------------------------------------'

-- BƯỚC 1: Kiểm tra trạng thái hiện tại của kết quả xét nghiệm được chọn làm mẫu
SELECT 
    kq.ma_ket_qua,
    kq.ma_danh_muc_xn,
    kq.gia_tri_do,
    kq.so_phien_ban,
    kq.muc_do_canh_bao
FROM ket_qua_dinh_luong kq
WHERE kq.ma_ket_qua = 1;

-- BƯỚC 2: Mô phỏng cơ chế Khóa bi quan (Pessimistic Locking qua SELECT FOR UPDATE)
-- Đảm bảo an toàn tuyệt đối khi nhiều kỹ thuật viên cùng thao tác
DO $$
DECLARE
    v_kq RECORD;
    v_gia_tri_cu NUMERIC;
BEGIN
    RAISE NOTICE '>>> [PHIÊN 1] Đang bắt đầu giao dịch và giữ khóa dòng (ROW-LEVEL EXCLUSIVE LOCK)...';

    -- 1. Giữ khóa độc quyền trên dòng ma_ket_qua = 1
    SELECT ma_ket_qua, gia_tri_do, so_phien_ban
    INTO v_kq
    FROM ket_qua_dinh_luong
    WHERE ma_ket_qua = 1
    FOR UPDATE;

    v_gia_tri_cu := v_kq.gia_tri_do;
    RAISE NOTICE '[PHIÊN 1] Đã khóa thành công dòng kết quả ID = 1 (Giá trị đo hiện thời: %)', v_gia_tri_cu;

    -- 2. Thực hiện cập nhật giá trị mới
    UPDATE ket_qua_dinh_luong
    SET gia_tri_do = 8.50,
        so_phien_ban = so_phien_ban + 1
    WHERE ma_ket_qua = 1;

    RAISE NOTICE '[PHIÊN 1] Đã cập nhật giá trị mới: 8.50. Chuẩn bị COMMIT...';
END $$;

-- BƯỚC 3: Mô phỏng cơ chế Khóa lạc quan (Optimistic Concurrency Control - OCC)
-- Áp dụng điều kiện so khớp phiên bản (so_phien_ban = expected_version)
DO $$
DECLARE
    v_rows_affected INT;
    v_expected_version INT := 1; -- Giả sử phiên 2 đọc được phiên bản cũ là 1
BEGIN
    RAISE NOTICE '>>> [PHIÊN 2] Cố gắng cập nhật với phiên bản cũ (v_expected_version = %)...', v_expected_version;

    UPDATE ket_qua_dinh_luong
    SET gia_tri_do = 9.20,
        so_phien_ban = so_phien_ban + 1
    WHERE ma_ket_qua = 1 
      AND so_phien_ban = v_expected_version;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected = 0 THEN
        RAISE WARNING 'XUNG ĐỘT TƯƠNG TRANH (OCC CONFLICT): Dữ liệu kết quả ID = 1 đã bị phiên khác thay đổi trước đó!';
        RAISE WARNING 'Hệ thống đã ngăn chặn thành công hiện tượng Mất cập nhật (Lost Update)!';
    ELSE
        RAISE NOTICE '[PHIÊN 2] Cập nhật thành công không có xung đột.';
    END IF;
END $$;

-- BƯỚC 4: Kiểm tra trạng thái cuối cùng sau khi xử lý xung đột
SELECT 
    kq.ma_ket_qua,
    kq.ma_danh_muc_xn,
    kq.gia_tri_do,
    kq.so_phien_ban,
    kq.muc_do_canh_bao
FROM ket_qua_dinh_luong kq
WHERE kq.ma_ket_qua = 1;
