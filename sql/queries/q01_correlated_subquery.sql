-- ============================================================================
-- TRUY VẤN Q1: CORRELATED SUBQUERY (TRUY VẤN CON TƯƠNG QUAN)
-- Nghiệp vụ: Tìm những bệnh nhân có số lượt xét nghiệm có cảnh báo bất thường 
--           ('CAO' hoặc 'NGUY_HIEM') vượt quá mức trung bình của toàn viện.
-- Kỹ thuật: Correlated Subquery lồng trong mệnh đề WHERE và SELECT,
--           kết hợp phép tính toán gom nhóm mức toàn thể.
-- ============================================================================

SELECT 
    bn.ma_benh_nhan,
    n.ho_ten,
    bn.nhom_mau,
    -- Subquery tương quan trong SELECT để đếm số lần bất thường của từng bệnh nhân
    (
        SELECT COUNT(*) 
        FROM ket_qua_dinh_luong dl
        JOIN phieu_chi_dinh_xet_nghiem p ON dl.ma_phieu_chi_dinh = p.ma_phieu_chi_dinh
        JOIN ho_so_kham_benh hs ON p.ma_ho_so = hs.ma_ho_so
        WHERE hs.ma_benh_nhan = bn.ma_benh_nhan 
          AND dl.muc_do_canh_bao IN ('CAO', 'NGUY_HIEM')
          AND dl.is_deleted = FALSE
    ) AS so_lan_xet_nghiem_bat_thuong
FROM benh_nhan bn
JOIN nguoi n ON bn.ma_dinh_danh = n.ma_dinh_danh
WHERE (
    -- Subquery tương quan trong WHERE lọc bệnh nhân vượt ngưỡng trung bình toàn viện
    SELECT COUNT(*) 
    FROM ket_qua_dinh_luong dl
    JOIN phieu_chi_dinh_xet_nghiem p ON dl.ma_phieu_chi_dinh = p.ma_phieu_chi_dinh
    JOIN ho_so_kham_benh hs ON p.ma_ho_so = hs.ma_ho_so
    WHERE hs.ma_benh_nhan = bn.ma_benh_nhan 
      AND dl.muc_do_canh_bao IN ('CAO', 'NGUY_HIEM')
      AND dl.is_deleted = FALSE
) > (
    -- Mức trung bình số lần bất thường tính trên mỗi bệnh nhân có xét nghiệm
    SELECT AVG(so_lan) 
    FROM (
        SELECT COUNT(*) AS so_lan
        FROM ket_qua_dinh_luong dl2
        JOIN phieu_chi_dinh_xet_nghiem p2 ON dl2.ma_phieu_chi_dinh = p2.ma_phieu_chi_dinh
        JOIN ho_so_kham_benh hs2 ON p2.ma_ho_so = hs2.ma_ho_so
        WHERE dl2.muc_do_canh_bao IN ('CAO', 'NGUY_HIEM') 
          AND dl2.is_deleted = FALSE
        GROUP BY hs2.ma_benh_nhan
    ) sub
)
ORDER BY so_lan_xet_nghiem_bat_thuong DESC;

