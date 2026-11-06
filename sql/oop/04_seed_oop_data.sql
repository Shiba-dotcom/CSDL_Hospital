-- ============================================================================
-- TUẦN 9: CƠ SỞ DỮ LIỆU HƯỚNG ĐỐI TƯỢNG (OBJECT-RELATIONAL DATABASE)
-- Tệp 04: NẠP DỮ LIỆU ĐỐI TƯỢNG MẪU (SEED OOP OBJECT DATA)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

-- ============================================================================
-- 1. NẠP DỮ LIỆU BÁC SĨ (LỚP CON CỦA NGUOI, CÓ MẢNG ĐỐI TƯỢNG BẰNG CẤP)
-- ============================================================================

INSERT INTO oop.bac_si (
    ma_dinh_danh, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, dia_chi,
    ma_bac_si, chuyen_khoa_chinh, so_nam_kinh_nghiem, chung_chi_hanh_nghe, danh_sach_bang_cap
) VALUES 
(
    '079080000001', 'BS.CKII. Trần Đình Khoa', '1980-05-12', 'NAM',
    ARRAY['0903112233', '0918112233'],
    ROW('120', 'Nguyễn Tri Phương', 'Phường 7', 'Quận 5', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'BS-001', 'Nội Tổng Quát', 18, 'CCHN-00129-HCM',
    ARRAY[
        ROW('Bác sĩ đa khoa', 'Y đa khoa', 'ĐH Y Dược TP.HCM', 2004)::oop.bang_cap_type,
        ROW('BS.CKII', 'Nội khoa', 'ĐH Y Dược TP.HCM', 2015)::oop.bang_cap_type
    ]
),
(
    '079085000002', 'ThS.BS. Lê Thị Mai Lan', '1985-09-20', 'NU',
    ARRAY['0908223344'],
    ROW('45/3', 'Lê Văn Sỹ', 'Phường 13', 'Quận 3', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'BS-002', 'Tim Mạch & Chuyển Hóa', 12, 'CCHN-00341-HCM',
    ARRAY[
        ROW('Bác sĩ đa khoa', 'Y đa khoa', 'ĐH Y Khoa Phạm Ngọc Thạch', 2009)::oop.bang_cap_type,
        ROW('Thạc sĩ', 'Tim mạch học', 'ĐH Y Dược TP.HCM', 2016)::oop.bang_cap_type
    ]
),
(
    '079090000003', 'BS.CKI. Nguyễn Hoàng Nam', '1990-03-15', 'NAM',
    ARRAY['0912334455', '0988334455'],
    ROW('88', 'Nguyễn Thị Minh Khai', 'Phường Bến Thành', 'Quận 1', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'BS-003', 'Hô Hấp', 7, 'CCHN-00512-HCM',
    ARRAY[
        ROW('Bác sĩ đa khoa', 'Y đa khoa', 'ĐH Y Dược Cần Thơ', 2014)::oop.bang_cap_type,
        ROW('BS.CKI', 'Nội Hô hấp', 'ĐH Y Dược TP.HCM', 2020)::oop.bang_cap_type
    ]
);

-- ============================================================================
-- 2. NẠP DỮ LIỆU KỸ THUẬT VIÊN (LỚP CON CỦA NGUOI)
-- ============================================================================

INSERT INTO oop.ky_thuat_vien (
    ma_dinh_danh, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, dia_chi,
    ma_ktv, phong_xet_nghiem, chung_chi_atsh
) VALUES 
(
    '079092000004', 'KTV. Đỗ Văn Hùng', '1992-11-05', 'NAM',
    ARRAY['0934556677'],
    ROW('15', 'Hùng Vương', 'Phường 4', 'Quận 5', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'KTV-001', 'Phòng Sinh Hóa - Miễn Dịch', 'ATSH-CAP2-2021'
),
(
    '079095000005', 'KTV. Phạm Thị Thu', '1995-07-18', 'NU',
    ARRAY['0945667788', '0977667788'],
    ROW('202', 'Lý Thường Kiệt', 'Phường 14', 'Quận 10', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'KTV-002', 'Phòng Chẩn Đoán Hình Ảnh', 'ATBX-CAP1-2022'
);

-- ============================================================================
-- 3. NẠP DỮ LIỆU BỆNH NHÂN (LỚP CON CỦA NGUOI, CÓ CHỈ SỐ SINH TỒN PHỨC HỢP)
-- ============================================================================

INSERT INTO oop.benh_nhan (
    ma_dinh_danh, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, dia_chi,
    ma_benh_nhan, nhom_mau, tien_su_di_ung, chi_so_gan_nhat
) VALUES 
(
    '079065000010', 'Nguyễn Văn An', '1965-02-14', 'NAM',
    ARRAY['0909123456', '0913123456'],
    ROW('12', 'Trần Hưng Đạo', 'Phường Cầu Ông Lãnh', 'Quận 1', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'BN-OOP-01', 'O+', ARRAY['Penicillin', 'Aspirin'],
    ROW(78, 36.8, 135, 85, 168.0, 74.5)::oop.chi_so_sinh_ton_type
),
(
    '079072000011', 'Trần Thị Mai', '1972-08-25', 'NU',
    ARRAY['0987654321'],
    ROW('56/2', 'Điện Biên Phủ', 'Phường 15', 'Quận Bình Thạnh', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'BN-OOP-02', 'A+', ARRAY['Hải sản'],
    ROW(72, 36.5, 120, 80, 158.0, 52.0)::oop.chi_so_sinh_ton_type
),
(
    '079088000012', 'Lê Hoàng Long', '1988-12-03', 'NAM',
    ARRAY['0918776655'],
    ROW('104', 'Hoàng Văn Thụ', 'Phường 9', 'Quận Phú Nhuận', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'BN-OOP-03', 'B+', NULL,
    ROW(82, 37.2, 140, 90, 175.0, 88.0)::oop.chi_so_sinh_ton_type
),
(
    '079099000013', 'Vũ Minh Anh', '1999-04-10', 'NU',
    ARRAY['0966332211', '0933221100'],
    ROW('25', 'Nguyễn Thị Minh Khai', 'Phường Đa Kao', 'Quận 1', 'TP. Hồ Chí Minh')::oop.dia_chi_type,
    'BN-OOP-04', 'AB-', ARRAY['Paracetamol'],
    ROW(68, 36.7, 110, 70, 162.0, 48.0)::oop.chi_so_sinh_ton_type
);

-- ============================================================================
-- 4. NẠP DỮ LIỆU KẾT QUẢ XÉT NGHIỆM ĐA HÌNH (POLYMORPHIC LAB RESULTS)
-- ============================================================================

-- 4.1. Kết quả Định lượng (Quantitative)
INSERT INTO oop.ket_qua_dinh_luong (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ten_xet_nghiem, thoi_gian_thuc_hien, trang_thai,
    gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan, muc_do_canh_bao
) VALUES 
(1001, 'GLUCOSE', 'Định lượng Glucose máu', '2026-11-01 08:30:00', 'HOAN_THANH', 8.450, 'mmol/L', 3.900, 6.400, 'CAO'),
(1001, 'CHOLESTEROL', 'Định lượng Cholesterol toàn phần', '2026-11-01 08:30:00', 'HOAN_THANH', 6.200, 'mmol/L', 3.600, 5.200, 'CAO'),
(1002, 'URE_MAU', 'Định lượng Ure huyết thanh', '2026-11-02 09:15:00', 'HOAN_THANH', 4.500, 'mmol/L', 2.500, 7.500, 'BINH_THUONG'),
(1003, 'TRIGLYCERID', 'Định lượng Triglycerid máu', '2026-11-03 10:00:00', 'HOAN_THANH', 3.800, 'mmol/L', 0.400, 1.880, 'NGUY_HIEM_CAO');

-- 4.2. Kết quả Hình ảnh (Imaging)
INSERT INTO oop.ket_qua_hinh_anh (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ten_xet_nghiem, thoi_gian_thuc_hien, trang_thai,
    duong_dan_tep_anh, ky_thuat_chup, vung_khao_sat, mo_ta_ton_thuong
) VALUES 
(1001, 'XQ_NGUC', 'Chụp X-quang tim phổi thẳng', '2026-11-01 09:00:00', 'HOAN_THANH', '/dicom/2026/11/01/xq_001.dcm', 'Kỹ thuật số CR/DR', 'Lồng ngực', 'Bóng tim to nhẹ, phế trường 2 bên sáng đều, không thấy thâm nhiễm'),
(1003, 'SIEU_AM_BUNG', 'Siêu âm ổ bụng tổng quát', '2026-11-03 10:30:00', 'HOAN_THANH', '/images/2026/11/03/sa_003.png', 'Siêu âm Doppler màu', 'Gan, mật, tụy, thận', 'Gan nhiễm mỡ độ 2, nhu mô thô nhẹ, cấu trúc hồi âm dày');

-- 4.3. Kết quả Định tính / Vi sinh (Qualitative / Microbiology)
INSERT INTO oop.ket_qua_dinh_tinh (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ten_xet_nghiem, thoi_gian_thuc_hien, trang_thai,
    ket_qua_danh_gia, mo_ta_vi_sinh
) VALUES 
(1002, 'HBSAG', 'Xét nghiệm Viêm gan B (HBsAg nhanh)', '2026-11-02 09:45:00', 'HOAN_THANH', 'AM_TINH', 'Không phát hiện kháng nguyên bề mặt virus viêm gan B'),
(1004, 'HP_TEST', 'Test vi khuẩn H.Pylori dạ dày', '2026-11-04 14:00:00', 'HOAN_THANH', 'DUONG_TINH', 'Dương tính rõ rệt với Helicobacter Pylori qua test thở Ure');

-- ============================================================================
-- 5. NẠP DỮ LIỆU HỒ SƠ KHÁM BỆNH KẾT NỐI ĐỐI TƯỢNG (OBJECT LINKING)
-- ============================================================================

INSERT INTO oop.ho_so_kham_benh (
    ma_benh_nhan, ma_bac_si_kham, thoi_gian_kham, chi_so_kham, chan_doan, cac_ma_xet_nghiem
) VALUES 
(
    'BN-OOP-01', 'BS-001', '2026-11-01 08:00:00',
    ROW(78, 36.8, 135, 85, 168.0, 74.5)::oop.chi_so_sinh_ton_type,
    'Tăng huyết áp độ 1 - Rối loạn lipid máu',
    ARRAY['GLUCOSE', 'CHOLESTEROL', 'XQ_NGUC']
),
(
    'BN-OOP-02', 'BS-002', '2026-11-02 08:30:00',
    ROW(72, 36.5, 120, 80, 158.0, 52.0)::oop.chi_so_sinh_ton_type,
    'Khám sức khỏe tổng quát định kỳ',
    ARRAY['URE_MAU', 'HBSAG']
),
(
    'BN-OOP-03', 'BS-002', '2026-11-03 09:15:00',
    ROW(82, 37.2, 140, 90, 175.0, 88.0)::oop.chi_so_sinh_ton_type,
    'Béo phì độ 1 - Nghi ngờ gan nhiễm mỡ',
    ARRAY['TRIGLYCERID', 'SIEU_AM_BUNG']
),
(
    'BN-OOP-04', 'BS-003', '2026-11-04 13:30:00',
    ROW(68, 36.7, 110, 70, 162.0, 48.0)::oop.chi_so_sinh_ton_type,
    'Viêm dạ dày trào ngược - Chỉ định kiểm tra vi khuẩn HP',
    ARRAY['HP_TEST']
);
