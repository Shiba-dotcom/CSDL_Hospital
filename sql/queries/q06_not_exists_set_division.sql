-- ============================================================================
-- TRUY VẤN Q6: PHÉP CHIA QUAN HỆ VỚI PHỦ ĐỊNH KÉP (DOUBLE NOT EXISTS)
-- Nghiệp vụ: Tìm những Bác sĩ đã từng chỉ định TẤT CẢ các danh mục xét nghiệm 
--           thuộc nhóm chuyên môn 'SINH_HOA' do bệnh viện cung cấp.
-- Kỹ thuật: Hiện thực hóa Phép chia quan hệ (Relational Division: R ÷ S) trong SQL
--           thông qua cấu trúc NOT EXISTS lồng nhau (Double NOT EXISTS).
-- Biểu thức Đại số quan hệ:
--   π_ma_bac_si (PhieuChiDinh ⋈ KetQua) ÷ π_ma_danh_muc_xn (σ_nhom='SINH_HOA' (DanhMucXetNghiem))
-- ============================================================================

SELECT 
    bs.ma_nhan_vien AS ma_bac_si,
    n.ho_ten AS ho_ten_bac_si,
    bs.chuyen_khoa_chinh,
    kp.ten_khoa_phong AS khoa_lam_viec
FROM bac_si bs
JOIN nhan_vien_y_te nv ON bs.ma_nhan_vien = nv.ma_nhan_vien
JOIN nguoi n ON nv.ma_dinh_danh = n.ma_dinh_danh
JOIN khoa_phong kp ON nv.ma_khoa_phong = kp.ma_khoa_phong
WHERE NOT EXISTS (
    -- Tập S: Tất cả các loại xét nghiệm thuộc nhóm 'SINH_HOA'
    SELECT dm.ma_danh_muc_xn
    FROM danh_muc_xet_nghiem dm
    WHERE dm.nhom_xet_nghiem = 'SINH_HOA'
      AND NOT EXISTS (
          -- Kiểm tra xem Bác sĩ này đã từng chỉ định xét nghiệm dm.ma_danh_muc_xn hay chưa
          SELECT 1
          FROM phieu_chi_dinh_xet_nghiem p
          JOIN ket_qua_xet_nghiem kq ON p.ma_phieu_chi_dinh = kq.ma_phieu_chi_dinh
          WHERE p.ma_bac_si_chi_dinh = bs.ma_nhan_vien
            AND kq.ma_danh_muc_xn = dm.ma_danh_muc_xn
            AND p.is_deleted = FALSE
            AND kq.is_deleted = FALSE
      )
)
ORDER BY 
    bs.ma_nhan_vien;

