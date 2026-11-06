-- ============================================================================
-- TRUY VẤN Q4: CTE RECURSIVE (TRUY VẤN ĐỆ QUY XÂY DỰNG CHUỖI TÁI KHÁM)
-- Nghiệp vụ: Truy vết lộ trình điều trị liên tục (Longitudinal Care Pathway) của bệnh nhân:
--           Từ đợt khám khởi đầu (Anchor), đệ quy tìm các đợt tái khám kế tiếp,
--           xây dựng chuỗi mã hồ sơ (Path Traversal) và tính tổng chi phí điều trị lũy kế.
-- Kỹ thuật: WITH RECURSIVE kết hợp điều kiện dừng (Recursion Termination),
--           phép ghép chuỗi đường dẫn (Path Construction) và tính tổng tích lũy.
-- ============================================================================

WITH RECURSIVE 
-- Bảng tạm đánh số thứ tự các lượt khám theo thời gian của từng bệnh nhân
numbered_visits AS (
    SELECT 
        hs.ma_ho_so,
        hs.ma_benh_nhan,
        n.ho_ten AS ten_benh_nhan,
        hs.thoi_gian_kham,
        hs.chan_doan_xac_dinh,
        -- Tính chi phí đơn thuốc của đợt khám này
        COALESCE((
            SELECT SUM(ct.so_luong * t.don_gia)
            FROM don_thuoc dt
            JOIN chi_tiet_don_thuoc ct ON dt.ma_don_thuoc = ct.ma_don_thuoc
            JOIN thuoc t ON ct.ma_thuoc = t.ma_thuoc
            WHERE dt.ma_ho_so = hs.ma_ho_so AND dt.is_deleted = FALSE
        ), 0) AS chi_phi_dot_nay,
        ROW_NUMBER() OVER (
            PARTITION BY hs.ma_benh_nhan 
            ORDER BY hs.thoi_gian_kham ASC
        ) AS visit_seq
    FROM ho_so_kham_benh hs
    JOIN benh_nhan bn ON hs.ma_benh_nhan = bn.ma_benh_nhan
    JOIN nguoi n ON bn.ma_dinh_danh = n.ma_dinh_danh
    WHERE hs.is_deleted = FALSE
),

-- ĐỆ QUY: Truy vết chuỗi khám bệnh từ đợt 1 -> đợt 2 -> đợt 3...
patient_care_pathway AS (
    -- 1. ANCHOR MEMBER (Điểm neo ban đầu: Lượt khám đầu tiên visit_seq = 1)
    SELECT 
        nv.ma_benh_nhan,
        nv.ten_benh_nhan,
        nv.ma_ho_so AS ma_ho_so_hien_tai,
        nv.visit_seq AS cap_do_tai_kham,
        nv.thoi_gian_kham,
        nv.chan_doan_xac_dinh,
        CAST('HS-' || nv.ma_ho_so AS TEXT) AS chuoi_lo_trinh_kham,
        nv.chi_phi_dot_nay AS tong_chi_phi_luy_ke
    FROM numbered_visits nv
    WHERE nv.visit_seq = 1

    UNION ALL

    -- 2. RECURSIVE MEMBER (Đệ quy: Kết nối lượt khám thứ n với lượt khám thứ n + 1)
    SELECT 
        next_v.ma_benh_nhan,
        next_v.ten_benh_nhan,
        next_v.ma_ho_so AS ma_ho_so_hien_tai,
        next_v.visit_seq AS cap_do_tai_kham,
        next_v.thoi_gian_kham,
        next_v.chan_doan_xac_dinh,
        pcp.chuoi_lo_trinh_kham || ' -> HS-' || next_v.ma_ho_so,
        pcp.tong_chi_phi_luy_ke + next_v.chi_phi_dot_nay
    FROM patient_care_pathway pcp
    JOIN numbered_visits next_v 
      ON pcp.ma_benh_nhan = next_v.ma_benh_nhan 
     AND next_v.visit_seq = pcp.cap_do_tai_kham + 1
)

-- Trích xuất các bệnh nhân có chuỗi theo dõi điều trị sâu nhất (từ 3 lần tái khám trở lên)
SELECT 
    ma_benh_nhan,
    ten_benh_nhan,
    cap_do_tai_kham AS tong_so_lan_kham,
    chuoi_lo_trinh_kham,
    thoi_gian_kham AS thoi_diem_kham_gan_nhat,
    chan_doan_xac_dinh AS chan_doan_moi_nhat,
    tong_chi_phi_luy_ke AS tong_tien_thuoc_luy_ke_vnd
FROM patient_care_pathway
WHERE cap_do_tai_kham >= 3
ORDER BY 
    cap_do_tai_kham DESC, ma_benh_nhan;

