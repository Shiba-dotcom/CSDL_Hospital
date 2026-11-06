-- ============================================================================
-- TRUY VẤN Q11: PIVOT / CROSSTAB (BẢNG TỔNG HỢP CHÉO MA TRẬN 2 CHIỀU)
-- Nghiệp vụ: Ma trận phân tích xu hướng chỉ định cận lâm sàng của từng Bác sĩ:
--           Xoay trục dữ liệu để thể hiện số lượng từng nhóm xét nghiệm
--           (Sinh hóa, Huyết học, Chiếu chụp, Vi sinh) thành các cột ngang riêng biệt.
-- Kỹ thuật: Kỹ thuật PIVOT hiện đại trong PostgreSQL bằng mệnh đề FILTER (WHERE ...),
--           kết hợp tính toán tỷ lệ phần trăm phân bổ dịch vụ cận lâm sàng.
-- ============================================================================

SELECT 
    bs.ma_nhan_vien AS ma_bac_si,
    n.ho_ten AS ho_ten_bac_si,
    bs.chuyen_khoa_chinh,
    kp.ten_khoa_phong AS khoa_lam_viec,
    
    -- Cột 1: Nhóm xét nghiệm Sinh hóa (Dùng FILTER WHERE để Pivot)
    COUNT(*) FILTER (WHERE dm.nhom_xet_nghiem = 'SINH_HOA') AS so_xn_sinh_hoa,
    
    -- Cột 2: Nhóm xét nghiệm Huyết học
    COUNT(*) FILTER (WHERE dm.nhom_xet_nghiem = 'HUYET_HOC') AS so_xn_huyet_hoc,
    
    -- Cột 3: Nhóm Chẩn đoán hình ảnh (X-quang, CT, Siêu âm)
    COUNT(*) FILTER (WHERE dm.nhom_xet_nghiem = 'CHIEU_CHUP') AS so_xn_chieu_chup,
    
    -- Cột 4: Nhóm Thăm dò chức năng
    COUNT(*) FILTER (WHERE dm.nhom_xet_nghiem = 'THAM_DO_CN') AS so_xn_tham_do_cn,
    
    -- Cột 5: Nhóm Vi sinh & Kháng sinh đồ
    COUNT(*) FILTER (WHERE dm.nhom_xet_nghiem = 'VI_SINH') AS so_xn_vi_sinh,
    
    -- Tổng cộng dòng
    COUNT(*) AS tong_so_chi_dinh,
    
    -- Phân tích tỷ trọng: Tỷ lệ chỉ định Chẩn đoán hình ảnh (%)
    ROUND(
        (COUNT(*) FILTER (WHERE dm.nhom_xet_nghiem = 'CHIEU_CHUP') * 100.0 / NULLIF(COUNT(*), 0)),
        2
    ) AS ty_le_chieu_chup_pct

FROM bac_si bs
JOIN nhan_vien_y_te nv ON bs.ma_nhan_vien = nv.ma_nhan_vien
JOIN nguoi n ON nv.ma_dinh_danh = n.ma_dinh_danh
JOIN khoa_phong kp ON nv.ma_khoa_phong = kp.ma_khoa_phong
JOIN phieu_chi_dinh_xet_nghiem p ON bs.ma_nhan_vien = p.ma_bac_si_chi_dinh AND p.is_deleted = FALSE
JOIN ket_qua_xet_nghiem kq ON p.ma_phieu_chi_dinh = kq.ma_phieu_chi_dinh AND kq.is_deleted = FALSE
JOIN danh_muc_xet_nghiem dm ON kq.ma_danh_muc_xn = dm.ma_danh_muc_xn
GROUP BY 
    bs.ma_nhan_vien, n.ho_ten, bs.chuyen_khoa_chinh, kp.ten_khoa_phong
ORDER BY 
    tong_so_chi_dinh DESC;
