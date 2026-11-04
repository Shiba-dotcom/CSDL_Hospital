-- ============================================================================
-- SCRIPT DML: NẠP DỮ LIỆU MẪU QUY MÔ LỚN (SEED DATA)
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- Quy mô: >= 50 Bệnh nhân, >= 200 Hồ sơ khám, >= 500 Kết quả xét nghiệm
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 1. NẠP DANH MỤC KHOA PHÒNG (8 Khoa/Phòng)
-- ----------------------------------------------------------------------------
INSERT INTO khoa_phong (ma_khoa_phong, ten_khoa_phong, loai_phong, vi_tri_tang) VALUES
('K_KHAM',     'Khoa Khám Bệnh Đa Khoa',      'KHOA_CHUYEN_MON',     'Tầng 1 - Tòa A'),
('P_101',      'Phòng Khám Nội Tổng Quát 101', 'PHONG_KHAM_LAMSANG',  'Tầng 1 - Tòa A'),
('P_102',      'Phòng Khám Tim Mạch 102',      'PHONG_KHAM_LAMSANG',  'Tầng 1 - Tòa A'),
('P_103',      'Phòng Khám Hô Hấp 103',        'PHONG_KHAM_LAMSANG',  'Tầng 1 - Tòa A'),
('K_XN',       'Khoa Xét Nghiệm Trung Tâm',   'PHONG_XET_NGHIEM',    'Tầng 2 - Tòa B'),
('P_XQ',       'Phòng Chụp X-Quang Kỹ Thuật Số', 'PHONG_CHUP_CHIEU', 'Tầng 1 - Tòa B'),
('P_CT',       'Phòng Cắt Lớp Vi Tính (CT-Scanner)', 'PHONG_CHUP_CHIEU', 'Tầng 1 - Tòa B'),
('QUAY_01',    'Quầy Tiếp Nhận & Phân Luồng 01', 'QUAY_TIEP_DON',    'Sảnh chính Tòa A')
ON CONFLICT (ma_khoa_phong) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 2. NẠP DANH MỤC XÉT NGHIỆM CHUẨN (10 Dịch vụ)
-- ----------------------------------------------------------------------------
INSERT INTO danh_muc_xet_nghiem (ma_danh_muc_xn, ten_xet_nghiem, nhom_xet_nghiem, hinh_thai_ket_qua, don_gia_dich_vu, thoi_gian_chuan_tra_kq) VALUES
('GLUCOSE',     'Định lượng Glucose máu (Mao mạch/Tĩnh mạch)', 'SINH_HOA',  'DINH_LUONG',  45000.00,  30),
('URE_MAU',     'Định lượng Ure trong máu',                  'SINH_HOA',  'DINH_LUONG',  50000.00,  45),
('CREATININE',  'Định lượng Creatinine huyết thanh',          'SINH_HOA',  'DINH_LUONG',  55000.00,  45),
('CHOLESTEROL', 'Định lượng Cholesterol toàn phần',          'SINH_HOA',  'DINH_LUONG',  60000.00,  45),
('TRIGLYCERID', 'Định lượng Triglyceride trong máu',          'SINH_HOA',  'DINH_LUONG',  60000.00,  45),
('CONG_THUC_MAU','Tổng phân tích tế bào máu ngoại vi (18 chỉ số)','HUYET_HOC','DINH_LUONG',80000.00, 30),
('XQ_NGUC',     'Chụp X-quang ngực thẳng tiêu chuẩn',        'CHIEU_CHUP','HINH_ANH',   120000.00,  20),
('CT_SO_NAO',   'Chụp CT Scanner Sọ Não đa dãy',             'CHIEU_CHUP','HINH_ANH',   850000.00,  60),
('SIEU_AM_BUNG','Siêu âm màu ổ bụng tổng quát',              'THAM_DO_CN','HINH_ANH',   150000.00,  25),
('VI_SINH_DOM', 'Nuôi cấy vi sinh đờm & Kháng sinh đồ',      'VI_SINH',   'DINH_TINH',  250000.00, 1440)
ON CONFLICT (ma_danh_muc_xn) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 3. NẠP DANH MỤC THUỐC THIẾT YẾU (15 Thuốc)
-- ----------------------------------------------------------------------------
INSERT INTO thuoc (ma_thuoc, ten_thuoc, hoat_chat, ham_luong, dang_bao_che, don_vi_tinh, don_gia) VALUES
('MED_PARA500',  'Hapacol 500',       'Paracetamol',        '500mg',   'Viên nén',    'Viên',    1500.00),
('MED_AMOX500',  'Amoxicillin 500mg', 'Amoxicillin',        '500mg',   'Viên nang',   'Viên',    2500.00),
('MED_AUG1G',    'Augmentin 1g',      'Amoxicillin/Clavulanate','1000mg','Viên bao',   'Viên',   18000.00),
('MED_METFORMIN','Glucophage 850mg',  'Metformin HCl',      '850mg',   'Viên nén',    'Viên',    4500.00),
('MED_AMLO5',    'Amlor 5mg',         'Amlodipine',         '5mg',     'Viên nang',   'Viên',    7200.00),
('MED_LOSARTAN', 'Cozaar 50mg',       'Losartan Potassium', '50mg',    'Viên nén',    'Viên',    9500.00),
('MED_ATORVA20', 'Lipitor 20mg',      'Atorvastatin',       '20mg',    'Viên bao',    'Viên',   16000.00),
('MED_OMEPRA20', 'Losec Mups 20mg',   'Omeprazole',         '20mg',    'Viên nén',    'Viên',   12000.00),
('MED_PANTOP40', 'Pantoloc 40mg',     'Pantoprazole',       '40mg',    'Viên bao tan','Viên',   19500.00),
('MED_BERBERIN', 'Berberin 100mg',    'Berberin clorid',    '100mg',   'Viên nén',    'Viên',     800.00),
('MED_CEFU500',  'Zinnat 500mg',      'Cefuroxime Axetil',  '500mg',   'Viên bao',    'Viên',   22000.00),
('MED_AZITHRO',  'Zithromax 500mg',   'Azithromycin',       '500mg',   'Viên bao',    'Viên',   35000.00),
('MED_SALBU',    'Ventolin Inhaler',  'Salbutamol',         '100mcg/liều','Bình xịt', 'Lọ',    95000.00),
('MED_GINKGO',   'Tanakan 40mg',      'Ginkgo Biloba',      '40mg',    'Viên bao',    'Viên',    4500.00),
('MED_VITAC500', 'Vitamin C 500mg',   'Acid Ascorbic',      '500mg',   'Viên sủi',    'Viên',    3000.00)
ON CONFLICT (ma_thuoc) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 4. NẠP CÁN BỘ Y TẾ (Bác sĩ, KTV, Tiếp nhận)
-- ----------------------------------------------------------------------------
-- Bác sĩ 1
INSERT INTO nguoi (ma_dinh_danh, ho_ten, ngay_sinh, gioi_tinh, dia_chi, so_dien_thoai) VALUES
('001080000001', 'BS.CKII. Trần Đình Khoa', '1975-04-12', 'NAM', '12 Nguyễn Trãi, Q.5, TP.HCM', ARRAY['0903111222', '0918333444']),
('001085000002', 'ThS.BS. Lê Thị Mai Lan',   '1982-08-20', 'NU',  '45 Hai Bà Trưng, Q.1, TP.HCM', ARRAY['0908555666']),
('001088000003', 'BS.CKI. Nguyễn Hoàng Nam', '1985-11-15', 'NAM', '88 Lê Văn Lương, Q.7, TP.HCM', ARRAY['0913777888']),
('001090000004', 'KTV. Đỗ Văn Hùng',        '1990-02-10', 'NAM', '102 Hoàng Văn Thụ, Q.Phú Nhuận', ARRAY['0932999000']),
('001092000005', 'KTV. Phạm Bích Ngọc',     '1992-06-25', 'NU',  '215 Điện Biên Phủ, Q.Bình Thạnh', ARRAY['0977112233']),
('001095000006', 'NV. Vũ Thị Thu Trang',    '1995-09-05', 'NU',  '33 CMT8, Q.10, TP.HCM', ARRAY['0988445566'])
ON CONFLICT (ma_dinh_danh) DO NOTHING;

-- Nhân viên y tế
INSERT INTO nhan_vien_y_te (ma_nhan_vien, ma_dinh_danh, ma_khoa_phong, hoc_vi, chuc_vu, trang_thai_lam_viec) VALUES
('NV-00001', '001080000001', 'P_101', 'Bác sĩ CKII', 'Trưởng khoa Khám Bệnh', 'DANG_LAM_VIEC'),
('NV-00002', '001085000002', 'P_102', 'Thạc sĩ Y học', 'Bác sĩ điều trị',     'DANG_LAM_VIEC'),
('NV-00003', '001088000003', 'P_103', 'Bác sĩ CKI',  'Bác sĩ điều trị',     'DANG_LAM_VIEC'),
('NV-00004', '001090000004', 'K_XN',  'Cử nhân XN',   'Kỹ thuật viên trưởng','DANG_LAM_VIEC'),
('NV-00005', '001092000005', 'P_XQ',  'Cử nhân CĐHA', 'Kỹ thuật viên X-Quang','DANG_LAM_VIEC'),
('NV-00006', '001095000006', 'QUAY_01','Cao đẳng ĐD', 'Nhân viên lễ tân',   'DANG_LAM_VIEC')
ON CONFLICT (ma_nhan_vien) DO NOTHING;

-- Phân loại chuyên môn
INSERT INTO bac_si (ma_nhan_vien, chung_chi_hanh_nghe, chuyen_khoa_chinh) VALUES
('NV-00001', 'CCHN-001234/BYT', 'Nội Tổng Quát'),
('NV-00002', 'CCHN-005678/BYT', 'Tim Mạch & Chuyển Hóa'),
('NV-00003', 'CCHN-009012/BYT', 'Hô Hấp')
ON CONFLICT (ma_nhan_vien) DO NOTHING;

INSERT INTO ky_thuat_vien (ma_nhan_vien, linh_vuc_chuyen_trach, chung_chi_an_toan_buc_xa) VALUES
('NV-00004', 'SINH_HOA', NULL),
('NV-00005', 'X_QUANG', 'ATBX-2023-098')
ON CONFLICT (ma_nhan_vien) DO NOTHING;

INSERT INTO nhan_vien_tiep_nhan (ma_nhan_vien, quay_tiep_nhan) VALUES
('NV-00006', 'Quầy số 01')
ON CONFLICT (ma_nhan_vien) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 5. SINH TỰ ĐỘNG 60 BỆNH NHÂN (Họ tên Việt Nam, địa chỉ, số điện thoại)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    i INT;
    v_cccd CHAR(12);
    v_ma_bn CHAR(10);
    v_ho TEXT[] := ARRAY['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng', 'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương'];
    v_dem TEXT[] := ARRAY['Văn', 'Thị', 'Đình', 'Hữu', 'Ngọc', 'Thanh', 'Đức', 'Xuân', 'Kim', 'Minh', 'Anh', 'Bảo'];
    v_ten TEXT[] := ARRAY['An', 'Bình', 'Cường', 'Dũng', 'Hải', 'Hương', 'Huy', 'Khoa', 'Linh', 'Long', 'Mai', 'Nam', 'Nghĩa', 'Phúc', 'Quân', 'Sơn', 'Tâm', 'Tuấn', 'Tùng', 'Yến'];
    v_nhom_mau nhom_mau_enum[] := ARRAY['A+', 'A-', 'B+', 'B-', 'AB+', 'O+', 'O-'];
    v_ho_ten TEXT;
    v_ngay_sinh DATE;
    v_gioi_tinh gioi_tinh_enum;
    v_sdt TEXT[];
BEGIN
    FOR i IN 1..60 LOOP
        v_cccd := '079' || LPAD(i::TEXT, 9, '0');
        v_ma_bn := 'BN-' || LPAD(i::TEXT, 6, '0');
        
        v_ho_ten := v_ho[1 + (i % array_length(v_ho, 1))] || ' ' || 
                    v_dem[1 + ((i * 3) % array_length(v_dem, 1))] || ' ' || 
                    v_ten[1 + ((i * 7) % array_length(v_ten, 1))];
                    
        v_ngay_sinh := DATE '1955-01-01' + (i * 365 % 18000);
        v_gioi_tinh := CASE WHEN i % 2 = 0 THEN 'NAM'::gioi_tinh_enum ELSE 'NU'::gioi_tinh_enum END;
        v_sdt := ARRAY['09' || LPAD((10000000 + i * 12345)::TEXT, 8, '0')];

        INSERT INTO nguoi (ma_dinh_danh, ho_ten, ngay_sinh, gioi_tinh, dia_chi, so_dien_thoai)
        VALUES (v_cccd, v_ho_ten, v_ngay_sinh, v_gioi_tinh, 'Số ' || i || ' Đường Số 8, TP.Thủ Đức', v_sdt)
        ON CONFLICT (ma_dinh_danh) DO NOTHING;

        INSERT INTO benh_nhan (ma_benh_nhan, ma_dinh_danh, nhom_mau, tien_su_di_ung, tien_su_benh)
        VALUES (
            v_ma_bn, 
            v_cccd, 
            v_nhom_mau[1 + (i % array_length(v_nhom_mau, 1))],
            CASE WHEN i % 5 = 0 THEN 'Dị ứng kháng sinh Penicillin' WHEN i % 7 = 0 THEN 'Dị ứng hải sản, tôm cua' ELSE NULL END,
            CASE WHEN i % 3 = 0 THEN 'Tiền sử Tăng huyết áp 5 năm' WHEN i % 4 = 0 THEN 'Đái tháo đường Type 2' ELSE 'Không ghi nhận bệnh mãn tính' END
        )
        ON CONFLICT (ma_benh_nhan) DO NOTHING;
    END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 6. SINH TỰ ĐỘNG 240 HỒ SƠ KHÁM BỆNH (Phân bố 12 tháng gần nhất)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    i INT;
    v_ma_bn ma_bn_domain;
    v_ma_bs ma_nv_domain[] := ARRAY['NV-00001', 'NV-00002', 'NV-00003'];
    v_phong VARCHAR(10)[] := ARRAY['P_101', 'P_102', 'P_103'];
    v_thoi_gian TIMESTAMP;
    v_ly_do TEXT[] := ARRAY[
        'Đau đầu, chóng mặt từng cơn khi thay đổi tư thế',
        'Sốt cao 38.5 độ kèm ho có đờm vàng 3 ngày nay',
        'Đau tức ngực trái khi gắng sức, hồi hộp trống ngực',
        'Mệt mỏi sút cân, khát nước uống nhiều tiểu nhiều',
        'Đau rát vùng thượng vị lúc đói, ợ hơi ợ chua',
        'Khám sức khỏe tổng quát định kỳ thường niên'
    ];
    v_so_bo TEXT[] := ARRAY[
        'Nghi ngờ Tăng huyết áp vô căn / Thiểu năng tuần hoàn não',
        'Nghi ngờ Viêm phế quản cấp / Theo dõi Viêm phổi',
        'Theo dõi Cơn đau thắt ngực ổn định / Thiếu máu cơ tim',
        'Nghi ngờ Rối loạn chuyển hóa Carbohydrate (Đái tháo đường)',
        'Viêm loét dạ dày - tá tràng',
        'Khám sức khỏe tầm soát'
    ];
    v_xac_dinh TEXT[] := ARRAY[
        'Tăng huyết áp độ 2 theo JNC VII - Rối loạn tiền đình',
        'Viêm phế quản cấp bội nhiễm vi khuẩn',
        'Cơn đau thắt ngực mạn tính do xơ vữa động mạch',
        'Đái tháo đường Typ 2 có biến chứng mạch máu nhỏ',
        'Viêm dạ dày trợt nông có vi khuẩn H. Pylori (+)',
        'Sức khỏe loại 2 - Rối loạn lipid máu nhẹ'
    ];
    v_idx INT;
BEGIN
    FOR i IN 1..240 LOOP
        v_ma_bn := 'BN-' || LPAD((1 + (i % 60))::TEXT, 6, '0');
        v_thoi_gian := CURRENT_TIMESTAMP - ((240 - i) * INTERVAL '1.2 day') - ((i % 8) * INTERVAL '1 hour');
        v_idx := 1 + (i % array_length(v_ly_do, 1));

        INSERT INTO ho_so_kham_benh (
            ma_benh_nhan, ma_bac_si_kham, ma_phong_kham, 
            thoi_gian_tiep_nhan, thoi_gian_kham,
            mach, nhiet_do, huyet_ap_tam_thu, huyet_ap_tam_truong,
            chieu_cao, can_nang,
            ly_do_kham, chan_doan_so_bo, chan_doan_xac_dinh, loi_dan_bac_si,
            ngay_hen_tai_kham, trang_thai_kham, is_deleted
        ) VALUES (
            v_ma_bn,
            v_ma_bs[1 + (i % 3)],
            v_phong[1 + (i % 3)],
            v_thoi_gian,
            v_thoi_gian + INTERVAL '20 minutes',
            70 + (i % 35),
            36.5 + ((i % 25) * 0.1),
            110 + (i % 45),
            70 + (i % 25),
            155.0 + (i % 30),
            50.0 + (i % 40),
            v_ly_do[v_idx],
            v_so_bo[v_idx],
            v_xac_dinh[v_idx],
            'Uống thuốc đúng giờ, hạn chế ăn mặn, kiêng dầu mỡ, tái khám đúng hẹn',
            DATE(v_thoi_gian + INTERVAL '14 days'),
            'HOAN_THANH',
            FALSE
        );
    END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 7. SINH TỰ ĐỘNG 200 PHIẾU CHỈ ĐỊNH XÉT NGHIỆM
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    r RECORD;
    v_phieu_id BIGINT;
BEGIN
    FOR r IN SELECT ma_ho_so, ma_bac_si_kham, thoi_gian_kham FROM ho_so_kham_benh WHERE ma_ho_so <= 200 LOOP
        INSERT INTO phieu_chi_dinh_xet_nghiem (
            ma_ho_so, ma_bac_si_chi_dinh, thoi_gian_chi_dinh, trang_thai_phieu, ghi_chu_lam_sang
        ) VALUES (
            r.ma_ho_so,
            r.ma_bac_si_kham,
            r.thoi_gian_kham + INTERVAL '5 minutes',
            'DA_CO_KET_QUA',
            'Kiểm tra định kỳ chỉ số sinh hóa và chẩn đoán hình ảnh bổ trợ'
        );
    END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 8. SINH TỰ ĐỘNG >= 550 KẾT QUẢ XÉT NGHIỆM ĐA HÌNH
-- ----------------------------------------------------------------------------

-- A. Xét nghiệm Định lượng: GLUCOSE (200 kết quả)
INSERT INTO ket_qua_dinh_luong (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ma_ktv_thuc_hien,
    thoi_gian_tiep_nhan_mau, thoi_gian_co_ket_qua, trang_thai_ket_qua,
    ket_luan_tong_quat, so_phien_ban, is_deleted,
    gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan, muc_do_canh_bao
)
SELECT 
    p.ma_phieu_chi_dinh,
    'GLUCOSE',
    'NV-00004',
    p.thoi_gian_chi_dinh + INTERVAL '10 minutes',
    p.thoi_gian_chi_dinh + INTERVAL '40 minutes',
    'CHINH_THUC',
    CASE 
        WHEN (4.0 + ((p.ma_phieu_chi_dinh % 50) * 0.15)) > 6.4 THEN 'Đường huyết tăng cao, cảnh báo đái tháo đường'
        ELSE 'Chỉ số đường huyết trong giới hạn bình thường'
    END,
    1,
    FALSE,
    ROUND((4.0 + ((p.ma_phieu_chi_dinh % 50) * 0.15))::numeric, 2),
    'mmol/L',
    3.900,
    6.400,
    CASE 
        WHEN (4.0 + ((p.ma_phieu_chi_dinh % 50) * 0.15)) > 7.0 THEN 'NGUY_HIEM'::canh_bao_enum
        WHEN (4.0 + ((p.ma_phieu_chi_dinh % 50) * 0.15)) > 6.4 THEN 'CAO'::canh_bao_enum
        ELSE 'BINH_THUONG'::canh_bao_enum
    END
FROM phieu_chi_dinh_xet_nghiem p;

-- B. Xét nghiệm Định lượng: URE MÁU (150 kết quả)
INSERT INTO ket_qua_dinh_luong (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ma_ktv_thuc_hien,
    thoi_gian_tiep_nhan_mau, thoi_gian_co_ket_qua, trang_thai_ket_qua,
    ket_luan_tong_quat, so_phien_ban, is_deleted,
    gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan, muc_do_canh_bao
)
SELECT 
    p.ma_phieu_chi_dinh,
    'URE_MAU',
    'NV-00004',
    p.thoi_gian_chi_dinh + INTERVAL '12 minutes',
    p.thoi_gian_chi_dinh + INTERVAL '45 minutes',
    'CHINH_THUC',
    'Chức năng lọc cầu thận ổn định',
    1,
    FALSE,
    ROUND((3.2 + ((p.ma_phieu_chi_dinh % 40) * 0.12))::numeric, 2),
    'mmol/L',
    2.500,
    7.500,
    'BINH_THUONG'::canh_bao_enum
FROM phieu_chi_dinh_xet_nghiem p
WHERE p.ma_phieu_chi_dinh <= 150;

-- B1. Bổ sung các xét nghiệm sinh hóa chuyên sâu (Creatinine, Cholesterol, Triglycerid)
-- Đảm bảo có bác sĩ chỉ định đủ toàn bộ danh mục Sinh Hóa phục vụ truy vấn Phép chia quan hệ (Q6)
INSERT INTO ket_qua_dinh_luong (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ma_ktv_thuc_hien,
    thoi_gian_tiep_nhan_mau, thoi_gian_co_ket_qua, trang_thai_ket_qua,
    ket_luan_tong_quat, so_phien_ban, is_deleted,
    gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan, muc_do_canh_bao
)
SELECT 
    p.ma_phieu_chi_dinh,
    'CREATININE',
    'NV-00004',
    p.thoi_gian_chi_dinh + INTERVAL '15 minutes',
    p.thoi_gian_chi_dinh + INTERVAL '45 minutes',
    'CHINH_THUC',
    'Chức năng thận trong giới hạn bình thường',
    1, FALSE, 78.500, 'umol/L', 53.000, 106.000, 'BINH_THUONG'::canh_bao_enum
FROM phieu_chi_dinh_xet_nghiem p
WHERE p.ma_bac_si_chi_dinh = 'NV-00001' LIMIT 20;

INSERT INTO ket_qua_dinh_luong (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ma_ktv_thuc_hien,
    thoi_gian_tiep_nhan_mau, thoi_gian_co_ket_qua, trang_thai_ket_qua,
    ket_luan_tong_quat, so_phien_ban, is_deleted,
    gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan, muc_do_canh_bao
)
SELECT 
    p.ma_phieu_chi_dinh,
    'CHOLESTEROL',
    'NV-00004',
    p.thoi_gian_chi_dinh + INTERVAL '15 minutes',
    p.thoi_gian_chi_dinh + INTERVAL '45 minutes',
    'CHINH_THUC',
    'Chỉ số mỡ máu toàn phần ổn định',
    1, FALSE, 4.600, 'mmol/L', 3.600, 5.200, 'BINH_THUONG'::canh_bao_enum
FROM phieu_chi_dinh_xet_nghiem p
WHERE p.ma_bac_si_chi_dinh = 'NV-00001' LIMIT 20;

INSERT INTO ket_qua_dinh_luong (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ma_ktv_thuc_hien,
    thoi_gian_tiep_nhan_mau, thoi_gian_co_ket_qua, trang_thai_ket_qua,
    ket_luan_tong_quat, so_phien_ban, is_deleted,
    gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan, muc_do_canh_bao
)
SELECT 
    p.ma_phieu_chi_dinh,
    'TRIGLYCERID',
    'NV-00004',
    p.thoi_gian_chi_dinh + INTERVAL '15 minutes',
    p.thoi_gian_chi_dinh + INTERVAL '45 minutes',
    'CHINH_THUC',
    'Triglyceride trong giới hạn cho phép',
    1, FALSE, 1.350, 'mmol/L', 0.400, 1.700, 'BINH_THUONG'::canh_bao_enum
FROM phieu_chi_dinh_xet_nghiem p
WHERE p.ma_bac_si_chi_dinh = 'NV-00001' LIMIT 20;

-- C. Chẩn đoán Hình ảnh: X-QUANG NGỰC (120 kết quả)
INSERT INTO ket_qua_hinh_anh (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ma_ktv_thuc_hien,
    thoi_gian_tiep_nhan_mau, thoi_gian_co_ket_qua, trang_thai_ket_qua,
    ket_luan_tong_quat, so_phien_ban, is_deleted,
    duong_dan_tep_anh, ky_thuat_chup, vung_khao_sat, mo_ta_ton_thuong
)
SELECT 
    p.ma_phieu_chi_dinh,
    'XQ_NGUC',
    'NV-00005',
    p.thoi_gian_chi_dinh + INTERVAL '8 minutes',
    p.thoi_gian_chi_dinh + INTERVAL '25 minutes',
    'CHINH_THUC',
    CASE WHEN p.ma_phieu_chi_dinh % 4 = 0 THEN 'Tăng đậm rốn phổi 2 bên, hình ảnh viêm phế quản' ELSE 'Tim phổi bình thường trên phim thẳng' END,
    1,
    FALSE,
    'https://storage.hospital.vn/dicom/2026/xq_chest_' || p.ma_phieu_chi_dinh || '.dcm',
    'Chụp X-quang ngực thẳng tư thế đứng (PA View)',
    'Lồng ngực, nhu mô phổi, bóng tim',
    CASE WHEN p.ma_phieu_chi_dinh % 4 = 0 THEN 'Dày màng phổi nhẹ đáy phổi phải, không tràn dịch' ELSE 'Không thấy hình ảnh tổn thương thâm nhiễm nhu mô phổi' END
FROM phieu_chi_dinh_xet_nghiem p
WHERE p.ma_phieu_chi_dinh <= 120;

-- D. Xét nghiệm Vi sinh: CẤY ĐỜM & KHÁNG SINH ĐỒ (80 kết quả)
INSERT INTO ket_qua_dinh_tinh (
    ma_phieu_chi_dinh, ma_danh_muc_xn, ma_ktv_thuc_hien,
    thoi_gian_tiep_nhan_mau, thoi_gian_co_ket_qua, trang_thai_ket_qua,
    ket_luan_tong_quat, so_phien_ban, is_deleted,
    ket_qua_danh_gia, ten_chung_vi_khuan, mo_ta_vi_sinh, khang_sinh_nhay_cam
)
SELECT 
    p.ma_phieu_chi_dinh,
    'VI_SINH_DOM',
    'NV-00004',
    p.thoi_gian_chi_dinh + INTERVAL '30 minutes',
    p.thoi_gian_chi_dinh + INTERVAL '24 hours',
    'CHINH_THUC',
    CASE WHEN p.ma_phieu_chi_dinh % 2 = 0 THEN 'Dương tính với vi khuẩn đường hô hấp' ELSE 'Âm tính sau 24h nuôi cấy' END,
    1,
    FALSE,
    CASE WHEN p.ma_phieu_chi_dinh % 2 = 0 THEN 'DUONG_TINH'::danh_gia_dinh_tinh_enum ELSE 'AM_TINH'::danh_gia_dinh_tinh_enum END,
    CASE WHEN p.ma_phieu_chi_dinh % 2 = 0 THEN 'Streptococcus pneumoniae' ELSE NULL END,
    CASE WHEN p.ma_phieu_chi_dinh % 2 = 0 THEN 'Song cầu Gram dương hình ngọn nến, mọc khuẩn lạc tan máu alpha' ELSE 'Không có vi khuẩn gây bệnh phát triển' END,
    CASE WHEN p.ma_phieu_chi_dinh % 2 = 0 THEN ARRAY['Amoxicillin/Clavulanate', 'Cefuroxime', 'Azithromycin'] ELSE ARRAY[]::TEXT[] END
FROM phieu_chi_dinh_xet_nghiem p
WHERE p.ma_phieu_chi_dinh <= 80;

-- ----------------------------------------------------------------------------
-- 9. NẠP ĐƠN THUỐC VÀ CHI TIẾT ĐƠN THUỐC (180 Đơn thuốc)
-- ----------------------------------------------------------------------------
DO $$
DECLARE
    r RECORD;
    v_don_id BIGINT;
BEGIN
    FOR r IN SELECT ma_ho_so, ma_bac_si_kham, thoi_gian_kham FROM ho_so_kham_benh WHERE ma_ho_so <= 180 LOOP
        INSERT INTO don_thuoc (ma_ho_so, ma_bac_si_ke, ngay_ke_don, loi_dan_chung)
        VALUES (
            r.ma_ho_so, 
            r.ma_bac_si_kham, 
            r.thoi_gian_kham + INTERVAL '50 minutes', 
            'Uống thuốc sau bữa ăn no, uống nhiều nước lọc'
        ) RETURNING ma_don_thuoc INTO v_don_id;

        -- Dòng thuốc 1
        INSERT INTO chi_tiet_don_thuoc (ma_don_thuoc, so_thu_tu_dong, ma_thuoc, so_luong, lieu_dung_moi_lan, so_lan_uong_ngay, thoi_diem_uong, so_ngay_dung)
        VALUES (v_don_id, 1, 'MED_PARA500', 20, '1 viên', 2, 'Sau ăn sáng - tối', 10);

        -- Dòng thuốc 2
        INSERT INTO chi_tiet_don_thuoc (ma_don_thuoc, so_thu_tu_dong, ma_thuoc, so_luong, lieu_dung_moi_lan, so_lan_uong_ngay, thoi_diem_uong, so_ngay_dung)
        VALUES (v_don_id, 2, 'MED_OMEPRA20', 14, '1 viên', 1, 'Trước ăn sáng 30 phút', 14);

        -- Dòng thuốc 3 nếu là bệnh nhân tim mạch/tiểu đường
        IF r.ma_ho_so % 2 = 0 THEN
            INSERT INTO chi_tiet_don_thuoc (ma_don_thuoc, so_thu_tu_dong, ma_thuoc, so_luong, lieu_dung_moi_lan, so_lan_uong_ngay, thoi_diem_uong, so_ngay_dung)
            VALUES (v_don_id, 3, 'MED_AMLO5', 30, '1 viên', 1, 'Sáng lúc 8h', 30);
        END IF;
    END LOOP;
END $$;

-- ----------------------------------------------------------------------------
-- 10. KÍCH HOẠT TRIGGER ĐỂ TẠO DỮ LIỆU MẪU CHO LỊCH SỬ CHỈNH SỬA (AUDIT TRAIL)
-- ----------------------------------------------------------------------------
-- Mô phỏng việc đính chính kết quả xét nghiệm Glucose của bản ghi ID 1, 2, 5
CALL sp_cap_nhat_ket_qua_dinh_luong(1, 8.250, 'NV-00004', 'Hiệu chuẩn lại máy phân tích tự động Beckman Coulter số 01', 1);
CALL sp_cap_nhat_ket_qua_dinh_luong(2, 5.100, 'NV-00004', 'Kỹ thuật viên đối chiếu lại mẫu huyết thanh chạy lần 2', 1);
CALL sp_cap_nhat_ket_qua_dinh_luong(5, 7.800, 'NV-00004', 'Đính chính kết quả sau khi pha loãng mẫu bệnh phẩm', 1);

COMMIT;

