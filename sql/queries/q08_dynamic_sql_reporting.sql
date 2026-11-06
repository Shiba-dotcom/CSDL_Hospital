-- ============================================================================
-- TRUY VẤN Q8: DYNAMIC SQL (SQL ĐỘNG VỚI HÀM EXECUTE FORMAT)
-- Nghiệp vụ: Báo cáo phân tích doanh thu & số lượng khám bệnh linh hoạt:
--           Cho phép người dùng chọn tiêu chí gom nhóm động ('BAC_SI', 'KHOA_PHONG', 'THANG'),
--           kèm bộ lọc khoảng thời gian tùy chọn.
-- Kỹ thuật: Dynamic SQL với cú pháp EXECUTE FORMAT, phòng chống SQL Injection
--           bằng %I (Identifier) và %L (Literal), trả về bảng kết quả động (RETURNS TABLE).
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_thong_ke_kham_benh_dong(
    p_nhom_theo         VARCHAR(20),     -- 'BAC_SI', 'KHOA_PHONG', hoặc 'THANG'
    p_tu_ngay           DATE DEFAULT NULL,
    p_den_ngay          DATE DEFAULT NULL
)
RETURNS TABLE (
    tieu_chi_nhom       TEXT,
    ten_doi_tuong       TEXT,
    so_luot_kham        BIGINT,
    so_don_thuoc        BIGINT,
    tong_tien_thuoc_vnd NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_select_col TEXT;
    v_name_col TEXT;
    v_group_col TEXT;
    v_where_clause TEXT := 'WHERE hs.is_deleted = FALSE';
BEGIN
    -- 1. Xác định cột gom nhóm an toàn dựa trên tham số đầu vào
    IF UPPER(p_nhom_theo) = 'BAC_SI' THEN
        v_select_col := 'bs.ma_nhan_vien::TEXT';
        v_name_col   := 'n.ho_ten::TEXT';
        v_group_col  := 'bs.ma_nhan_vien, n.ho_ten';
    ELSIF UPPER(p_nhom_theo) = 'KHOA_PHONG' THEN
        v_select_col := 'kp.ma_khoa_phong::TEXT';
        v_name_col   := 'kp.ten_khoa_phong::TEXT';
        v_group_col  := 'kp.ma_khoa_phong, kp.ten_khoa_phong';
    ELSIF UPPER(p_nhom_theo) = 'THANG' THEN
        v_select_col := 'TO_CHAR(hs.thoi_gian_kham, ''YYYY-MM'')::TEXT';
        v_name_col   := '''Tháng '' || TO_CHAR(hs.thoi_gian_kham, ''MM/YYYY'')::TEXT';
        v_group_col  := 'TO_CHAR(hs.thoi_gian_kham, ''YYYY-MM''), TO_CHAR(hs.thoi_gian_kham, ''MM/YYYY'')';
    ELSE
        RAISE EXCEPTION 'Tham số p_nhom_theo không hợp lệ! Chỉ chấp nhận: BAC_SI, KHOA_PHONG, THANG.';
    END IF;

    -- 2. Ghép điều kiện thời gian an toàn bằng %L
    IF p_tu_ngay IS NOT NULL THEN
        v_where_clause := v_where_clause || format(' AND hs.thoi_gian_kham >= %L::DATE', p_tu_ngay);
    END IF;
    IF p_den_ngay IS NOT NULL THEN
        v_where_clause := v_where_clause || format(' AND hs.thoi_gian_kham <= %L::DATE', p_den_ngay);
    END IF;

    -- 3. Xây dựng câu lệnh Dynamic SQL hoàn chỉnh
    v_sql := format('
        SELECT 
            %s AS tieu_chi_nhom,
            %s AS ten_doi_tuong,
            COUNT(DISTINCT hs.ma_ho_so) AS so_luot_kham,
            COUNT(DISTINCT dt.ma_don_thuoc) AS so_don_thuoc,
            COALESCE(SUM(ct.so_luong * t.don_gia), 0)::NUMERIC AS tong_tien_thuoc_vnd
        FROM ho_so_kham_benh hs
        JOIN bac_si bs ON hs.ma_bac_si_kham = bs.ma_nhan_vien
        JOIN nhan_vien_y_te nv ON bs.ma_nhan_vien = nv.ma_nhan_vien
        JOIN nguoi n ON nv.ma_dinh_danh = n.ma_dinh_danh
        JOIN khoa_phong kp ON hs.ma_phong_kham = kp.ma_khoa_phong
        LEFT JOIN don_thuoc dt ON hs.ma_ho_so = dt.ma_ho_so AND dt.is_deleted = FALSE
        LEFT JOIN chi_tiet_don_thuoc ct ON dt.ma_don_thuoc = ct.ma_don_thuoc
        LEFT JOIN thuoc t ON ct.ma_thuoc = t.ma_thuoc
        %s
        GROUP BY %s
        ORDER BY so_luot_kham DESC',
        v_select_col, v_name_col, v_where_clause, v_group_col
    );

    -- 4. Thực thi câu lệnh SQL động và trả về bảng kết quả
    RETURN QUERY EXECUTE v_sql;
END;
$$;
