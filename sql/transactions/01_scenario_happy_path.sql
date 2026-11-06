-- ============================================================================
-- TUẦN 11: TRANSACTION & KIỂM THỬ TƯƠNG TRANH (CONCURRENCY)
-- Kịch bản 1: GIAO DỊCH THÀNH CÔNG HOÀN TOÀN (HAPPY PATH)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

\echo '----------------------------------------------------------------------'
\echo 'BẮT ĐẦU KỊCH BẢN 1: KHỞI TẠO CA KHÁM VÀ KÊ ĐƠN TRONG 1 TRANSACTION'
\echo '----------------------------------------------------------------------'

DO $$
DECLARE
    v_hs_id         BIGINT;
    v_phieu_id      BIGINT;
    v_don_id        BIGINT;
    v_bn_id         ma_bn_domain := 'BN-000002';
    v_bs_id         ma_nv_domain := 'NV-00001';
    v_phong_id      VARCHAR(10)  := 'P_101';
    v_bmi_calc      NUMERIC(4,2);
    v_so_kq_created INT;
    v_so_ct_created INT;
BEGIN
    -- BƯỚC 1: Khởi tạo Hồ sơ khám bệnh lâm sàng
    INSERT INTO ho_so_kham_benh (
        ma_benh_nhan, ma_bac_si_kham, ma_phong_kham,
        thoi_gian_tiep_nhan, thoi_gian_kham,
        mach, nhiet_do, huyet_ap_tam_thu, huyet_ap_tam_truong,
        chieu_cao, can_nang,
        ly_do_kham, chan_doan_xac_dinh, loi_dan_bac_si,
        trang_thai_kham
    ) VALUES (
        v_bn_id, v_bs_id, v_phong_id,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
        80, 36.6, 125, 82,
        170.0, 68.0, -- BMI lý thuyết: 68 / (1.70^2) = 23.53
        'Khám sức khỏe tổng quát theo dõi định kỳ',
        'Sức khỏe ổn định - Tiền đái tháo đường nhẹ',
        'Hạn chế tinh bột, tái khám sau 3 tháng',
        'HOAN_THANH'
    ) RETURNING ma_ho_so, chi_so_bmi INTO v_hs_id, v_bmi_calc;

    RAISE NOTICE '[1/4] Đã tạo Hồ sơ khám bệnh ID = % (BMI tự động tính qua Trigger: %)', v_hs_id, v_bmi_calc;

    -- BƯỚC 2: Khởi tạo Phiếu chỉ định xét nghiệm cận lâm sàng
    INSERT INTO phieu_chi_dinh_xet_nghiem (
        ma_ho_so, ma_bac_si_chi_dinh, thoi_gian_chi_dinh, trang_thai_phieu, ghi_chu_lam_sang
    ) VALUES (
        v_hs_id, v_bs_id, CURRENT_TIMESTAMP, 'DA_CO_KET_QUA', 'Kiểm tra đường huyết và mỡ máu'
    ) RETURNING ma_phieu_chi_dinh INTO v_phieu_id;

    RAISE NOTICE '[2/4] Đã tạo Phiếu chỉ định xét nghiệm ID = %', v_phieu_id;

    -- BƯỚC 3: Ghi nhận các kết quả xét nghiệm định lượng
    INSERT INTO ket_qua_dinh_luong (
        ma_phieu_chi_dinh, ma_danh_muc_xn, gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan, muc_do_canh_bao
    ) VALUES 
    (v_phieu_id, 'GLUCOSE', 6.85, 'mmol/L', 3.90, 6.40, 'CAO'),
    (v_phieu_id, 'CHOLESTEROL', 5.10, 'mmol/L', 3.60, 5.20, 'BINH_THUONG');

    GET DIAGNOSTICS v_so_kq_created = ROW_COUNT;
    RAISE NOTICE '[3/4] Đã ghi nhận % kết quả xét nghiệm định lượng cho phiếu ID = %', v_so_kq_created, v_phieu_id;

    -- BƯỚC 4: Khởi tạo Đơn thuốc điện tử và các dòng thuốc chi tiết
    INSERT INTO don_thuoc (
        ma_ho_so, ma_bac_si_ke, ngay_ke_don, loi_dan_chung
    ) VALUES (
        v_hs_id, v_bs_id, CURRENT_TIMESTAMP, 'Uống thuốc đúng giờ sau ăn'
    ) RETURNING ma_don_thuoc INTO v_don_id;

    INSERT INTO chi_tiet_don_thuoc (
        ma_don_thuoc, so_thu_tu_dong, ma_thuoc, so_luong,
        lieu_dung_moi_lan, so_lan_uong_ngay, thoi_diem_uong, so_ngay_dung
    ) VALUES 
    (v_don_id, 1, 'MED_METFORMIN', 30, '1 viên', 2, 'Sau bữa ăn sáng và tối', 15),
    (v_don_id, 2, 'MED_ATORVA20', 15, '1 viên', 1, 'Tối trước khi đi ngủ', 15);

    GET DIAGNOSTICS v_so_ct_created = ROW_COUNT;
    RAISE NOTICE '[4/4] Đã tạo Đơn thuốc ID = % với % khoản mục thuốc', v_don_id, v_so_ct_created;

    RAISE NOTICE '===> KỊCH BẢN 1 HOÀN TẤT THÀNH CÔNG: Mọi dữ liệu đã cam kết (COMMIT) toàn vẹn!';
END $$;

-- Xác minh dữ liệu đã thực sự lưu vào CSDL
SELECT 
    hs.ma_ho_so,
    hs.ma_benh_nhan,
    hs.chi_so_bmi,
    p.ma_phieu_chi_dinh,
    COUNT(DISTINCT kq.ma_ket_qua) AS so_luong_ket_qua_xn,
    dt.ma_don_thuoc,
    COUNT(DISTINCT ct.so_thu_tu_dong) AS so_khoan_muc_thuoc
FROM ho_so_kham_benh hs
JOIN phieu_chi_dinh_xet_nghiem p ON hs.ma_ho_so = p.ma_ho_so
LEFT JOIN ket_qua_xet_nghiem kq ON p.ma_phieu_chi_dinh = kq.ma_phieu_chi_dinh
JOIN don_thuoc dt ON hs.ma_ho_so = dt.ma_ho_so
JOIN chi_tiet_don_thuoc ct ON dt.ma_don_thuoc = ct.ma_don_thuoc
WHERE hs.ma_ho_so = (SELECT MAX(ma_ho_so) FROM ho_so_kham_benh)
GROUP BY hs.ma_ho_so, hs.ma_benh_nhan, hs.chi_so_bmi, p.ma_phieu_chi_dinh, dt.ma_don_thuoc;
