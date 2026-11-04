-- ============================================================================
-- TRUY VẤN Q5: GROUP BY + HAVING VỚI TRUY VẤN CON & TÍNH TỶ LỆ PHẦN TRĂM
-- Nghiệp vụ: Thống kê các kỹ thuật xét nghiệm định lượng có tỷ lệ kết quả bất thường
--           ('CAO' hoặc 'NGUY_HIEM') vượt quá tỷ lệ bất thường bình quân của toàn viện,
--           đồng thời có số lượng mẫu thực hiện tối thiểu từ 30 lượt trở lên.
-- Kỹ thuật: Gom nhóm (GROUP BY), tính toán tỷ lệ phần trăm động (CASE WHEN SUM),
--           và lọc tập nhóm bằng biểu thức subquery trong mệnh đề HAVING.
-- ============================================================================

SELECT 
    dm.ma_danh_muc_xn,
    dm.ten_xet_nghiem,
    dm.nhom_xet_nghiem,
    -- Tổng số lượt thực hiện xét nghiệm
    COUNT(*) AS tong_so_luot_xet_nghiem,
    -- Số lượt cho kết quả bình thường
    COUNT(CASE WHEN dl.muc_do_canh_bao = 'BINH_THUONG' THEN 1 END) AS so_luot_binh_thuong,
    -- Số lượt cảnh báo vượt ngưỡng
    COUNT(CASE WHEN dl.muc_do_canh_bao IN ('CAO', 'NGUY_HIEM') THEN 1 END) AS so_luot_bat_thuong,
    -- Tính tỷ lệ phần trăm bất thường (%)
    ROUND(
        (COUNT(CASE WHEN dl.muc_do_canh_bao IN ('CAO', 'NGUY_HIEM') THEN 1 END) * 100.0 / COUNT(*)), 
        2
    ) AS ty_le_bat_thuong_pct
FROM ket_qua_dinh_luong dl
JOIN danh_muc_xet_nghiem dm ON dl.ma_danh_muc_xn = dm.ma_danh_muc_xn
WHERE dl.is_deleted = FALSE
GROUP BY 
    dm.ma_danh_muc_xn, dm.ten_xet_nghiem, dm.nhom_xet_nghiem
HAVING 
    COUNT(*) >= 30
    AND (
        COUNT(CASE WHEN dl.muc_do_canh_bao IN ('CAO', 'NGUY_HIEM') THEN 1 END) * 1.0 / COUNT(*)
    ) > (
        -- Subquery: Tính tỷ lệ bất thường trung bình của toàn bộ các xét nghiệm định lượng
        SELECT 
            COUNT(CASE WHEN muc_do_canh_bao IN ('CAO', 'NGUY_HIEM') THEN 1 END) * 1.0 / COUNT(*)
        FROM ket_qua_dinh_luong
        WHERE is_deleted = FALSE
    )
ORDER BY 
    ty_le_bat_thuong_pct DESC;
