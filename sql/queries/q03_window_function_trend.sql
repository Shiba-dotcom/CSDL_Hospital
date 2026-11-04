-- ============================================================================
-- TRUY VẤN Q3: WINDOW FUNCTIONS (LAG, LEAD, DENSE_RANK, OVER PARTITION BY)
-- Nghiệp vụ: Theo dõi xu hướng diễn tiến chỉ số Đường huyết (Glucose) của bệnh nhân:
--           Xác định thứ tự lần đo, so sánh giá trị hiện tại với lần đo trước (LAG),
--           tính độ biến thiên (Delta) và phân loại xu hướng (TĂNG / GIẢM / ỔN ĐỊNH).
-- Kỹ thuật: Phân vùng dữ liệu (PARTITION BY ma_benh_nhan), sắp xếp thời gian (ORDER BY),
--           và hàm phân tích chuỗi thời gian LAG/LEAD mà không cần tự kết nối (Self-JOIN).
-- ============================================================================

WITH glucose_timeline AS (
    SELECT 
        bn.ma_benh_nhan,
        n.ho_ten AS ho_ten_benh_nhan,
        hs.ma_ho_so,
        dl.ma_ket_qua,
        dl.thoi_gian_co_ket_qua,
        dl.gia_tri_do AS glucose_hien_tai,
        dl.don_vi_tinh,
        dl.muc_do_canh_bao,
        -- Đánh số thứ tự lần xét nghiệm Glucose của từng bệnh nhân
        DENSE_RANK() OVER (
            PARTITION BY bn.ma_benh_nhan 
            ORDER BY dl.thoi_gian_co_ket_qua ASC
        ) AS lan_do_thu,
        -- Lấy giá trị của lần xét nghiệm ngay trước đó
        LAG(dl.gia_tri_do, 1) OVER (
            PARTITION BY bn.ma_benh_nhan 
            ORDER BY dl.thoi_gian_co_ket_qua ASC
        ) AS glucose_lan_truoc,
        -- Lấy thời điểm của lần xét nghiệm ngay trước đó
        LAG(dl.thoi_gian_co_ket_qua, 1) OVER (
            PARTITION BY bn.ma_benh_nhan 
            ORDER BY dl.thoi_gian_co_ket_qua ASC
        ) AS thoi_gian_lan_truoc
    FROM ket_qua_dinh_luong dl
    JOIN phieu_chi_dinh_xet_nghiem p ON dl.ma_phieu_chi_dinh = p.ma_phieu_chi_dinh
    JOIN ho_so_kham_benh hs ON p.ma_ho_so = hs.ma_ho_so
    JOIN benh_nhan bn ON hs.ma_benh_nhan = bn.ma_benh_nhan
    JOIN nguoi n ON bn.ma_dinh_danh = n.ma_dinh_danh
    WHERE dl.ma_danh_muc_xn = 'GLUCOSE' 
      AND dl.is_deleted = FALSE
)
SELECT 
    ma_benh_nhan,
    ho_ten_benh_nhan,
    lan_do_thu,
    thoi_gian_co_ket_qua,
    glucose_hien_tai,
    don_vi_tinh,
    muc_do_canh_bao,
    glucose_lan_truoc,
    -- Độ chênh lệch so với lần khám trước
    ROUND((glucose_hien_tai - glucose_lan_truoc)::numeric, 2) AS do_bien_thien_delta,
    -- Đánh giá xu hướng lâm sàng
    CASE 
        WHEN glucose_lan_truoc IS NULL THEN 'LẦN ĐO ĐẦU TIÊN (BASELINE)'
        WHEN glucose_hien_tai > glucose_lan_truoc THEN 'XU HƯỚNG TĂNG ↗'
        WHEN glucose_hien_tai < glucose_lan_truoc THEN 'XU HƯỚNG GIẢM ↘'
        ELSE 'ỔN ĐỊNH →'
    END AS danh_gia_xu_huong
FROM glucose_timeline
ORDER BY 
    ma_benh_nhan, lan_do_thu ASC;
