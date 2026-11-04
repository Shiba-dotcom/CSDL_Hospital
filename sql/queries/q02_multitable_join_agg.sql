-- ============================================================================
-- TRUY VẤN Q2: MULTI-TABLE JOIN + GROUP BY + HAVING + AGGREGATION
-- Nghiệp vụ: Báo cáo tổng hợp hiệu suất công tác lâm sàng của từng Bác sĩ:
--           Số lượt khám, số phiếu XN đã chỉ định, số đơn thuốc đã kê,
--           và tổng doanh thu tiền thuốc phát sinh từ các đơn đã kê.
-- Kỹ thuật: Kết nối nhiều bảng (7 bảng), sử dụng COUNT(DISTINCT) để khử trùng
--           lặp Cartesian, kết hợp COALESCE và điều kiện lọc nhóm HAVING.
-- ============================================================================

SELECT 
    bs.ma_nhan_vien AS ma_bac_si,
    n.ho_ten AS ho_ten_bac_si,
    bs.chuyen_khoa_chinh,
    kp.ten_khoa_phong AS phong_lam_viec_chinh,
    -- Số lượng hồ sơ khám bệnh đã hoàn thành
    COUNT(DISTINCT hs.ma_ho_so) AS tong_so_luot_kham,
    -- Số phiếu chỉ định cận lâm sàng đã ban hành
    COUNT(DISTINCT p.ma_phieu_chi_dinh) AS tong_so_phieu_xn,
    -- Số đơn thuốc đã kê
    COUNT(DISTINCT dt.ma_don_thuoc) AS tong_so_don_thuoc,
    -- Tổng giá trị tiền thuốc phát sinh (Số lượng * Đơn giá)
    COALESCE(SUM(ct.so_luong * t.don_gia), 0) AS tong_doanh_thu_thuoc_vnd
FROM bac_si bs
JOIN nhan_vien_y_te nv ON bs.ma_nhan_vien = nv.ma_nhan_vien
JOIN nguoi n ON nv.ma_dinh_danh = n.ma_dinh_danh
JOIN khoa_phong kp ON nv.ma_khoa_phong = kp.ma_khoa_phong
LEFT JOIN ho_so_kham_benh hs ON bs.ma_nhan_vien = hs.ma_bac_si_kham AND hs.is_deleted = FALSE
LEFT JOIN phieu_chi_dinh_xet_nghiem p ON hs.ma_ho_so = p.ma_ho_so AND p.is_deleted = FALSE
LEFT JOIN don_thuoc dt ON hs.ma_ho_so = dt.ma_ho_so AND dt.is_deleted = FALSE
LEFT JOIN chi_tiet_don_thuoc ct ON dt.ma_don_thuoc = ct.ma_don_thuoc
LEFT JOIN thuoc t ON ct.ma_thuoc = t.ma_thuoc
GROUP BY 
    bs.ma_nhan_vien, n.ho_ten, bs.chuyen_khoa_chinh, kp.ten_khoa_phong
HAVING 
    COUNT(DISTINCT hs.ma_ho_so) >= 10
ORDER BY 
    tong_so_luot_kham DESC;
