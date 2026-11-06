-- ============================================================================
-- TRUY VẤN Q10: TRUY VẤN JSONB CHUYÊN SÂU TRÊN NHẬT KÝ KIỂM TOÁN (AUDIT TRAIL)
-- Nghiệp vụ: Thanh tra y tế phân tích các biến động đính chính kết quả xét nghiệm:
--           Trích xuất chỉ số xét nghiệm cũ và mới từ snapshot JSONB, tính toán
--           biên độ đính chính (Delta), và lọc các ca điều chỉnh kết quả đáng kể.
-- Kỹ thuật: Các toán tử JSONB chuyên dụng: ->> (trích xuất text), -> (trích xuất json),
--           ép kiểu dữ liệu từ JSONB sang NUMERIC để tính toán, và truy vấn so khớp mờ.
-- ============================================================================

SELECT 
    ls.ma_lich_su,
    ls.ten_bang,
    ls.ma_ban_ghi AS ma_ket_qua_bi_sua,
    ls.so_phien_ban AS phien_ban_truoc_khi_sua,
    ls.loai_thao_tac,
    -- Trích xuất trực tiếp từ trường JSONB
    ls.du_lieu_cu->>'ma_danh_muc_xn' AS ma_xet_nghiem,
    ROUND((ls.du_lieu_cu->>'gia_tri_do')::NUMERIC, 3) AS gia_tri_do_cu,
    ROUND((ls.du_lieu_moi->>'gia_tri_do')::NUMERIC, 3) AS gia_tri_do_moi,
    ls.du_lieu_cu->>'don_vi_tinh' AS don_vi,
    -- Tính toán biên độ thay đổi trực tiếp từ JSONB
    ROUND(
        ((ls.du_lieu_moi->>'gia_tri_do')::NUMERIC - (ls.du_lieu_cu->>'gia_tri_do')::NUMERIC), 
        3
    ) AS bien_do_chenh_lech,
    -- Thay đổi nhãn cảnh báo từ cũ sang mới
    (ls.du_lieu_cu->>'muc_do_canh_bao') || ' -> ' || (ls.du_lieu_moi->>'muc_do_canh_bao') AS bien_dong_canh_bao,
    -- Thông tin trách nhiệm pháp lý
    ls.ly_do_sua,
    ls.nguoi_thuc_hien AS ma_ktv_sua,
    n.ho_ten AS ten_ktv_sua,
    ls.thoi_gian_sua
FROM lich_su_chinh_sua ls
JOIN nhan_vien_y_te nv ON ls.nguoi_thuc_hien = nv.ma_nhan_vien
JOIN nguoi n ON nv.ma_dinh_danh = n.ma_dinh_danh
WHERE 
    ls.ten_bang IN ('ket_qua_xet_nghiem', 'ket_qua_dinh_luong')
    -- Sử dụng toán tử JSONB để kiểm tra xem trường gia_tri_do có tồn tại trong snapshot hay không
    AND ls.du_lieu_cu ? 'gia_tri_do'
    AND ls.du_lieu_moi ? 'gia_tri_do'
ORDER BY 
    ls.thoi_gian_sua DESC;

