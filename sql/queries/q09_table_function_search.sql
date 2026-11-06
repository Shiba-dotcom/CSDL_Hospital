-- ============================================================================
-- TRUY VẤN Q9: STORED FUNCTION TRẢ VỀ KIỂU BẢNG (RETURNS TABLE)
-- Nghiệp vụ: Chức năng tìm kiếm hồ sơ bệnh nhân thông minh đa tiêu chí:
--           Tìm kiếm mờ (Fuzzy Search) theo Họ tên, CCCD, Mã bệnh nhân, hoặc Số ĐT;
--           kết hợp lọc nhóm máu và khoảng độ tuổi lâm sàng.
-- Kỹ thuật: Stored Function trả về bảng dữ liệu (RETURNS TABLE), tính tuổi dẫn xuất,
--           tìm kiếm trên kiểu mảng (ANY(so_dien_thoai)), và tổng hợp lịch sử khám.
-- ============================================================================

DROP FUNCTION IF EXISTS fn_tim_kiem_benh_nhan_nang_cao (TEXT, nhom_mau_enum, INT, INT);

CREATE OR REPLACE FUNCTION fn_tim_kiem_benh_nhan_nang_cao(
    p_tu_khoa       TEXT DEFAULT NULL,
    p_nhom_mau      nhom_mau_enum DEFAULT NULL,
    p_tuoi_min      INT DEFAULT NULL,
    p_tuoi_max      INT DEFAULT NULL
)
RETURNS TABLE (
    ma_benh_nhan        ma_bn_domain,
    ho_ten              VARCHAR(100),
    tuoi                INT,
    gioi_tinh           gioi_tinh_enum,
    nhom_mau            nhom_mau_enum,
    so_dien_thoai_chinh TEXT,
    tien_su_di_ung      TEXT,
    tong_so_lan_kham    BIGINT,
    ngay_kham_gan_nhat  DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bn.ma_benh_nhan,
        n.ho_ten,
        (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM n.ngay_sinh))::INT AS tuoi,
        n.gioi_tinh,
        bn.nhom_mau,
        COALESCE(n.so_dien_thoai[1], 'Chưa có SĐT')::TEXT AS so_dien_thoai_chinh,
        bn.tien_su_di_ung,
        COUNT(hs.ma_ho_so) AS tong_so_lan_kham,
        MAX(DATE(hs.thoi_gian_kham)) AS ngay_kham_gan_nhat
    FROM benh_nhan bn
    JOIN nguoi n ON bn.ma_dinh_danh = n.ma_dinh_danh
    LEFT JOIN ho_so_kham_benh hs ON bn.ma_benh_nhan = hs.ma_benh_nhan AND hs.is_deleted = FALSE
    WHERE 
        -- 1. Tìm kiếm theo từ khóa (Họ tên, Mã BN, CCCD hoặc Số điện thoại)
        (
            p_tu_khoa IS NULL 
            OR n.ho_ten ILIKE '%' || p_tu_khoa || '%'
            OR bn.ma_benh_nhan ILIKE '%' || p_tu_khoa || '%'
            OR n.ma_dinh_danh::TEXT ILIKE '%' || p_tu_khoa || '%'
            OR p_tu_khoa = ANY(n.so_dien_thoai)
        )
        -- 2. Lọc theo nhóm máu
        AND (p_nhom_mau IS NULL OR bn.nhom_mau = p_nhom_mau)
        -- 3. Lọc theo độ tuổi tối thiểu
        AND (
            p_tuoi_min IS NULL 
            OR (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM n.ngay_sinh)) >= p_tuoi_min
        )
        -- 4. Lọc theo độ tuổi tối đa
        AND (
            p_tuoi_max IS NULL 
            OR (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM n.ngay_sinh)) <= p_tuoi_max
        )
    GROUP BY 
        bn.ma_benh_nhan, n.ho_ten, n.ngay_sinh, n.gioi_tinh, bn.nhom_mau, n.so_dien_thoai, bn.tien_su_di_ung
    ORDER BY 
        tong_so_lan_kham DESC, n.ho_ten ASC;
END;
$$;

-- ============================================================================
-- CÂU LỆNH GỌI HÀM TÌM KIẾM BỆNH NHÂN (BÔI ĐEN VÀ CHẠY DÒNG NÀY):
-- ============================================================================

-- Ví dụ 1: Tìm tất cả bệnh nhân họ 'Nguyễn' có độ tuổi từ 40 đến 70:
SELECT *
FROM
    fn_tim_kiem_benh_nhan_nang_cao ('Nguyễn', NULL, 40, 70);

-- Ví dụ 2: Tìm bệnh nhân theo số điện thoại (ví dụ: '0910185175'):
SELECT * FROM fn_tim_kiem_benh_nhan_nang_cao ('0910185175');