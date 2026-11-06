-- ============================================================================
-- TUẦN 9: CƠ SỞ DỮ LIỆU HƯỚNG ĐỐI TƯỢNG (OBJECT-RELATIONAL DATABASE)
-- Tệp 05: BỘ TRUY VẤN OQL CHUẨN ODMG 3.0 & ÁNH XẠ SANG POSTGRESQL SQL
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- ============================================================================

-- ============================================================================
-- TRUY VẤN OQL 1: GỌI PHƯƠNG THỨC THÀNH VIÊN (METHOD INVOCATION & ENCAPSULATION)
-- ============================================================================
-- Ý nghĩa: Tìm các bệnh nhân có chỉ số BMI vượt ngưỡng bình thường (>= 25.0),
--          gọi phương thức tinh_tuoi(), tinh_bmi() và danh_gia_the_trang().
--
-- Cú pháp OQL chuẩn (ODMG 3.0):
-- SELECT bn.ma_benh_nhan, bn.ho_ten, bn.tinh_tuoi(), 
--        bn.chi_so_gan_nhat.tinh_bmi(), bn.chi_so_gan_nhat.danh_gia_the_trang()
-- FROM BenhNhan bn
-- WHERE bn.chi_so_gan_nhat.tinh_bmi() >= 25.0;

SELECT 
    bn.ma_benh_nhan,
    bn.ho_ten,
    oop.tinh_tuoi(bn) AS tuoi,
    (bn.chi_so_gan_nhat).chieu_cao AS chieu_cao_cm,
    (bn.chi_so_gan_nhat).can_nang AS can_nang_kg,
    oop.tinh_bmi(bn.chi_so_gan_nhat) AS chi_so_bmi,
    oop.danh_gia_the_trang(bn.chi_so_gan_nhat) AS phan_loai_the_trang
FROM oop.benh_nhan bn
WHERE oop.tinh_bmi(bn.chi_so_gan_nhat) >= 25.0;


-- ============================================================================
-- TRUY VẤN OQL 2: TRUY VẤN TRÊN TẬP HỢP ĐA TRỊ (COLLECTION-ORIENTED QUERY / ARRAY)
-- ============================================================================
-- Ý nghĩa: Tìm bệnh nhân có tiền sử dị ứng thuốc Penicillin và sở hữu từ 2 số
--          điện thoại liên lạc trở lên (xử lý trên thuộc tính mảng tập hợp).
--
-- Cú pháp OQL chuẩn (ODMG 3.0):
-- SELECT bn.ma_benh_nhan, bn.ho_ten, bn.so_dien_thoai, bn.tien_su_di_ung
-- FROM BenhNhan bn
-- WHERE "Penicillin" IN bn.tien_su_di_ung
--   AND count(bn.so_dien_thoai) >= 2;

SELECT 
    bn.ma_benh_nhan,
    bn.ho_ten,
    bn.so_dien_thoai,
    bn.tien_su_di_ung,
    oop.kiem_tra_di_ung(bn, 'Penicillin') AS co_xung_dot_penicillin
FROM oop.benh_nhan bn
WHERE 'Penicillin' = ANY(bn.tien_su_di_ung)
  AND cardinality(bn.so_dien_thoai) >= 2;


-- ============================================================================
-- TRUY VẤN OQL 3: KẾ THỪA VÀ TRUY VẤN ĐA HÌNH (INHERITANCE & POLYMORPHISM)
-- ============================================================================
-- Ý nghĩa: Truy vấn tập hợp kết quả xét nghiệm qua lớp cha KetQuaXetNghiem.
--          Hệ thống tự động quét và tập hợp dữ liệu từ cả 3 lớp con kế thừa:
--          KetQuaDinhLuong, KetQuaHinhAnh, và KetQuaDinhTinh.
--
-- Cú pháp OQL chuẩn (ODMG 3.0):
-- SELECT kq.ma_ket_qua, kq.ten_xet_nghiem, kq.thoi_gian_thuc_hien, kq.trang_thai
-- FROM KetQuaXetNghiem kq;

SELECT 
    tableoid::regclass AS bang_con_ke_thua,
    kq.ma_ket_qua,
    kq.ten_xet_nghiem,
    kq.thoi_gian_thuc_hien,
    kq.trang_thai
FROM oop.ket_qua_xet_nghiem kq
ORDER BY kq.ma_ket_qua;


-- ============================================================================
-- TRUY VẤN OQL 4: BIỂU THỨC ĐƯỜNG DẪN (PATH EXPRESSIONS & NESTED COMPOSITES)
-- ============================================================================
-- Ý nghĩa: Điều hướng thuộc tính qua nhiều cấp đối tượng: từ Hồ sơ khám ->
--          đến Địa chỉ lồng nhau (tinh_thanh, quan_huyen) của Bệnh nhân và Bác sĩ.
--
-- Cú pháp OQL chuẩn (ODMG 3.0):
-- SELECT hs.ma_ho_so, hs.thoi_gian_kham, hs.chan_doan,
--        hs.benh_nhan.ho_ten, hs.benh_nhan.dia_chi.tinh_thanh,
--        hs.bac_si_kham.ho_ten, hs.bac_si_kham.chuyen_khoa_chinh
-- FROM HoSoKhamBenh hs;

SELECT 
    hs.ma_ho_so,
    hs.thoi_gian_kham,
    hs.chan_doan,
    bn.ho_ten AS ten_benh_nhan,
    (bn.dia_chi).quan_huyen AS quan_huyen_bn,
    (bn.dia_chi).tinh_thanh AS tinh_thanh_bn,
    oop.lay_dia_chi_day_du(bn.dia_chi) AS dia_chi_day_du_bn,
    bs.ho_ten AS ten_bac_si,
    bs.chuyen_khoa_chinh
FROM oop.ho_so_kham_benh hs
JOIN oop.benh_nhan bn ON hs.ma_benh_nhan = bn.ma_benh_nhan
JOIN oop.bac_si bs ON hs.ma_bac_si_kham = bs.ma_bac_si;


-- ============================================================================
-- TRUY VẤN OQL 5: LÀM PHẲNG TẬP HỢP ĐỐI TƯỢNG (SET FLATTENING / UNNEST)
-- ============================================================================
-- Ý nghĩa: Bóc tách thuộc tính mảng đối tượng phức hợp (danh_sach_bang_cap)
--          của các bác sĩ thành các dòng độc lập để phân tích trình độ chuyên môn.
--
-- Cú pháp OQL chuẩn (ODMG 3.0):
-- SELECT bs.ma_bac_si, bs.ho_ten, bc.trinh_do, bc.chuyen_nganh, bc.noi_dao_tao, bc.nam_tot_nghiep
-- FROM BacSi bs, bs.danh_sach_bang_cap bc
-- WHERE bc.trinh_do IN list("BS.CKII", "Thạc sĩ", "Tiến sĩ");

SELECT 
    bs.ma_bac_si,
    bs.ho_ten,
    bs.so_nam_kinh_nghiem,
    (bc).trinh_do,
    (bc).chuyen_nganh,
    (bc).noi_dao_tao,
    (bc).nam_tot_nghiep
FROM oop.bac_si bs,
UNNEST(bs.danh_sach_bang_cap) AS bc
WHERE (bc).trinh_do IN ('BS.CKII', 'Thạc sĩ', 'Tiến sĩ');


-- ============================================================================
-- TRUY VẤN OQL 6: TẠO ĐỐI TƯỢNG CẤU TRÚC MỚI (STRUCT CONSTRUCTOR & METRICS)
-- ============================================================================
-- Ý nghĩa: Đóng gói toàn bộ kết quả khám bệnh thành một đối tượng có cấu trúc JSON
--          phục vụ trao đổi dữ liệu y tế liên viện (HL7/FHIR), kèm kiểm tra bác sĩ chuyên gia.
--
-- Cú pháp OQL chuẩn (ODMG 3.0):
-- SELECT struct(
--     ma_ho_so: hs.ma_ho_so,
--     benh_nhan: struct(ten: bn.ho_ten, tuoi: bn.tinh_tuoi(), the_trang: bn.chi_so_gan_nhat.danh_gia_the_trang()),
--     bac_si: struct(ten: bs.ho_ten, chuyen_khoa: bs.chuyen_khoa_chinh, la_chuyen_gia: bs.la_chuyen_gia()),
--     chan_doan: hs.chan_doan
-- )
-- FROM HoSoKhamBenh hs, hs.benh_nhan bn, hs.bac_si_kham bs;

SELECT 
    hs.ma_ho_so,
    json_build_object(
        'ma_benh_nhan', bn.ma_benh_nhan,
        'ho_ten', bn.ho_ten,
        'tuoi', oop.tinh_tuoi(bn),
        'nhom_mau', bn.nhom_mau,
        'the_trang', oop.danh_gia_the_trang(bn.chi_so_gan_nhat)
    ) AS thong_tin_benh_nhan,
    json_build_object(
        'ma_bac_si', bs.ma_bac_si,
        'ho_ten', bs.ho_ten,
        'chuyen_khoa', bs.chuyen_khoa_chinh,
        'la_chuyen_gia', oop.la_chuyen_gia(bs)
    ) AS thong_tin_bac_si,
    hs.chan_doan,
    hs.cac_ma_xet_nghiem
FROM oop.ho_so_kham_benh hs
JOIN oop.benh_nhan bn ON hs.ma_benh_nhan = bn.ma_benh_nhan
JOIN oop.bac_si bs ON hs.ma_bac_si_kham = bs.ma_bac_si;

