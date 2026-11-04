-- ============================================================================
-- SCRIPT 05: TẠO CÁC KHUNG NHÌN TIỆN ÍCH (VIEWS & REPORTING VIEWS)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- DBMS: PostgreSQL 16+
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. VIEW HỒ SƠ KHÁM BỆNH ĐẦY ĐỦ THÔNG TIN BỆNH NHÂN & BÁC SĨ
-- ----------------------------------------------------------------------------
-- Giúp bác sĩ tra cứu nhanh toàn bộ thông tin bệnh nhân, số điện thoại, chỉ số sinh tồn và BMI

CREATE OR REPLACE VIEW v_ho_so_kham_chi_tiet AS
SELECT 
    hs.ma_ho_so,
    hs.thoi_gian_tiep_nhan,
    hs.thoi_gian_kham,
    -- Thông tin bệnh nhân
    bn.ma_benh_nhan,
    n_bn.ho_ten AS ho_ten_benh_nhan,
    n_bn.ngay_sinh,
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM n_bn.ngay_sinh) AS tuoi,
    n_bn.gioi_tinh,
    n_bn.so_dien_thoai AS sdt_benh_nhan,
    bn.nhom_mau,
    bn.tien_su_di_ung,
    -- Chỉ số sinh tồn
    hs.mach,
    hs.nhiet_do,
    hs.huyet_ap_tam_thu,
    hs.huyet_ap_tam_truong,
    hs.chieu_cao,
    hs.can_nang,
    hs.chi_so_bmi,
    -- Chẩn đoán & Y lệnh
    hs.ly_do_kham,
    hs.chan_doan_so_bo,
    hs.chan_doan_xac_dinh,
    hs.loi_dan_bac_si,
    hs.ngay_hen_tai_kham,
    hs.trang_thai_kham,
    -- Thông tin Bác sĩ khám
    bs.ma_nhan_vien AS ma_bac_si,
    n_bs.ho_ten AS ho_ten_bac_si,
    bs.chuyen_khoa_chinh,
    -- Phòng khám
    kp.ten_khoa_phong AS phong_kham
FROM ho_so_kham_benh hs
JOIN benh_nhan bn ON hs.ma_benh_nhan = bn.ma_benh_nhan
JOIN nguoi n_bn ON bn.ma_dinh_danh = n_bn.ma_dinh_danh
JOIN bac_si bs ON hs.ma_bac_si_kham = bs.ma_nhan_vien
JOIN nhan_vien_y_te nv_bs ON bs.ma_nhan_vien = nv_bs.ma_nhan_vien
JOIN nguoi n_bs ON nv_bs.ma_dinh_danh = n_bs.ma_dinh_danh
JOIN khoa_phong kp ON hs.ma_phong_kham = kp.ma_khoa_phong
WHERE hs.is_deleted = FALSE;

-- ----------------------------------------------------------------------------
-- 2. VIEW TỔNG HỢP KẾT QUẢ XÉT NGHIỆM ĐA HÌNH
-- ----------------------------------------------------------------------------
-- Tận dụng tính đa hình: Gom kết quả định lượng, hình ảnh và vi sinh vào 1 giao diện duy nhất

CREATE OR REPLACE VIEW v_ket_qua_xet_nghiem_tong_hop AS
SELECT 
    kq.ma_ket_qua,
    p.ma_phieu_chi_dinh,
    p.ma_ho_so,
    dm.ma_danh_muc_xn,
    dm.ten_xet_nghiem,
    dm.nhom_xet_nghiem,
    dm.hinh_thai_ket_qua,
    -- Phân loại kết quả chi tiết
    CASE 
        WHEN dl.ma_ket_qua IS NOT NULL THEN 'ĐỊNH LƯỢNG'
        WHEN ha.ma_ket_qua IS NOT NULL THEN 'HÌNH ẢNH'
        WHEN dt.ma_ket_qua IS NOT NULL THEN 'VI SINH / ĐỊNH TÍNH'
        ELSE 'CHƯA PHÂN LOẠI'
    END AS loai_ket_qua_chi_tiet,
    -- Giá trị hiển thị linh hoạt
    COALESCE(
        dl.gia_tri_do::TEXT || ' ' || dl.don_vi_tinh,
        dt.ket_qua_danh_gia::TEXT,
        ha.vung_khao_sat
    ) AS gia_tri_hien_thi,
    dl.muc_do_canh_bao,
    ha.duong_dan_tep_anh,
    ha.mo_ta_ton_thuong,
    dt.ten_chung_vi_khuan,
    dt.khang_sinh_nhay_cam,
    kq.trang_thai_ket_qua,
    kq.so_phien_ban,
    kq.thoi_gian_co_ket_qua,
    n_ktv.ho_ten AS ktv_thuc_hien
FROM ket_qua_xet_nghiem kq
JOIN phieu_chi_dinh_xet_nghiem p ON kq.ma_phieu_chi_dinh = p.ma_phieu_chi_dinh
JOIN danh_muc_xet_nghiem dm ON kq.ma_danh_muc_xn = dm.ma_danh_muc_xn
LEFT JOIN ket_qua_dinh_luong dl ON kq.ma_ket_qua = dl.ma_ket_qua
LEFT JOIN ket_qua_hinh_anh ha ON kq.ma_ket_qua = ha.ma_ket_qua
LEFT JOIN ket_qua_dinh_tinh dt ON kq.ma_ket_qua = dt.ma_ket_qua
LEFT JOIN ky_thuat_vien ktv ON kq.ma_ktv_thuc_hien = ktv.ma_nhan_vien
LEFT JOIN nhan_vien_y_te nv_ktv ON ktv.ma_nhan_vien = nv_ktv.ma_nhan_vien
LEFT JOIN nguoi n_ktv ON nv_ktv.ma_dinh_danh = n_ktv.ma_dinh_danh
WHERE kq.is_deleted = FALSE;

-- ----------------------------------------------------------------------------
-- 3. VIEW BẢNG THEO DÕI NHẬT KÝ KIỂM TOÁN (AUDIT TRAIL VIEW)
-- ----------------------------------------------------------------------------
-- Hiển thị lịch sử chỉnh sửa rõ ràng với thông tin nhân viên thao tác và so sánh dữ liệu

CREATE OR REPLACE VIEW v_lich_su_chinh_sua_chi_tiet AS
SELECT 
    ls.ma_lich_su,
    ls.ten_bang,
    ls.ma_ban_ghi,
    ls.so_phien_ban,
    ls.loai_thao_tac,
    ls.ly_do_sua,
    ls.thoi_gian_sua,
    ls.nguoi_thuc_hien AS ma_nhan_vien_sua,
    n.ho_ten AS ten_nguoi_sua,
    nv.chuc_vu,
    ls.du_lieu_cu,
    ls.du_lieu_moi
FROM lich_su_chinh_sua ls
JOIN nhan_vien_y_te nv ON ls.nguoi_thuc_hien = nv.ma_nhan_vien
JOIN nguoi n ON nv.ma_dinh_danh = n.ma_dinh_danh
ORDER BY ls.thoi_gian_sua DESC;

