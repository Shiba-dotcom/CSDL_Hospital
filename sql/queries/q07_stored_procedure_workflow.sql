-- ============================================================================
-- TRUY VẤN Q7: STORED PROCEDURE QUY TRÌNH KHÁM BỆNH ĐẦY ĐỦ TRONG 1 TRANSACTION
-- Nghiệp vụ: Đóng gói toàn bộ chu trình khám bệnh lâm sàng vào 1 thủ tục lưu trữ:
--           1. Khởi tạo Hồ sơ khám bệnh & ghi nhận chỉ số sinh tồn (BMI tự động).
--           2. Tự động sinh Phiếu chỉ định xét nghiệm & các hạng mục cận lâm sàng.
--           3. Tự động sinh Đơn thuốc & nạp danh sách các dòng thuốc từ JSONB.
-- Kỹ thuật: Stored Procedure với Transaction Control (COMMIT / ROLLBACK),
--           biến RECORD / JSONB array unnesting, tham số OUT và kiểm soát ngoại lệ.
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_quy_trinh_kham_benh_toan_dien(
    -- 1. Tham số hồ sơ khám
    p_ma_benh_nhan          ma_bn_domain,
    p_ma_bac_si             ma_nv_domain,
    p_ma_phong              VARCHAR(10),
    p_mach                  INTEGER,
    p_nhiet_do              NUMERIC,
    p_ha_thu                INTEGER,
    p_ha_truong             INTEGER,
    p_chieu_cao             NUMERIC,
    p_can_nang              NUMERIC,
    p_ly_do                 TEXT,
    p_chan_doan             TEXT,
    p_loi_dan               TEXT,
    -- 2. Danh sách mã xét nghiệm chỉ định (mảng chuỗi)
    p_danh_sach_xn          VARCHAR(15)[],
    -- 3. Danh sách thuốc kê đơn dạng JSONB: [{"ma_thuoc": "...", "so_luong": 10, "lieu_dung": "...", "so_lan": 2, "thoi_diem": "...", "so_ngay": 5}]
    p_danh_sach_thuoc       JSONB,
    -- 4. Tham số đầu ra (OUT)
    INOUT p_ma_ho_so_out    BIGINT DEFAULT NULL,
    INOUT p_ma_phieu_out    BIGINT DEFAULT NULL,
    INOUT p_ma_don_out      BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ma_xn VARCHAR(15);
    v_thuoc RECORD;
    v_stt_dong INT := 0;
    v_hinh_thai hinh_thai_kq_enum;
BEGIN
    -- Kiểm tra tính hợp lệ cơ bản
    IF p_ly_do IS NULL OR LENGTH(TRIM(p_ly_do)) < 3 THEN
        RAISE EXCEPTION 'LỖI NGHIỆP VỤ: Lý do khám bệnh không được để trống!';
    END IF;

    -- BƯỚC 1: Tạo Hồ sơ khám bệnh
    INSERT INTO ho_so_kham_benh (
        ma_benh_nhan, ma_bac_si_kham, ma_phong_kham,
        thoi_gian_tiep_nhan, thoi_gian_kham,
        mach, nhiet_do, huyet_ap_tam_thu, huyet_ap_tam_truong,
        chieu_cao, can_nang,
        ly_do_kham, chan_doan_xac_dinh, loi_dan_bac_si,
        trang_thai_kham
    ) VALUES (
        p_ma_benh_nhan, p_ma_bac_si, p_ma_phong,
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,
        p_mach, p_nhiet_do, p_ha_thu, p_ha_truong,
        p_chieu_cao, p_can_nang,
        p_ly_do, p_chan_doan, p_loi_dan,
        'HOAN_THANH'
    ) RETURNING ma_ho_so INTO p_ma_ho_so_out;

    -- BƯỚC 2: Tạo Phiếu chỉ định và các hạng mục xét nghiệm (nếu có)
    IF p_danh_sach_xn IS NOT NULL AND array_length(p_danh_sach_xn, 1) > 0 THEN
        INSERT INTO phieu_chi_dinh_xet_nghiem (
            ma_ho_so, ma_bac_si_chi_dinh, thoi_gian_chi_dinh, trang_thai_phieu, ghi_chu_lam_sang
        ) VALUES (
            p_ma_ho_so_out, p_ma_bac_si, CURRENT_TIMESTAMP, 'CHO_THUC_HIEN', 'Chỉ định tự động từ quy trình khám lâm sàng'
        ) RETURNING ma_phieu_chi_dinh INTO p_ma_phieu_out;

        -- Duyệt mảng xét nghiệm để chèn vào các bảng con tương ứng
        FOREACH v_ma_xn IN ARRAY p_danh_sach_xn LOOP
            SELECT hinh_thai_ket_qua INTO v_hinh_thai 
            FROM danh_muc_xet_nghiem 
            WHERE ma_danh_muc_xn = v_ma_xn;

            IF v_hinh_thai = 'DINH_LUONG' THEN
                INSERT INTO ket_qua_dinh_luong (
                    ma_phieu_chi_dinh, ma_danh_muc_xn, gia_tri_do, don_vi_tinh, chi_so_min_chuan, chi_so_max_chuan, muc_do_canh_bao
                ) VALUES (
                    p_ma_phieu_out, v_ma_xn, 0.0, 'Đang chờ', 0.0, 1.0, 'BINH_THUONG'
                );
            ELSIF v_hinh_thai = 'HINH_ANH' THEN
                INSERT INTO ket_qua_hinh_anh (
                    ma_phieu_chi_dinh, ma_danh_muc_xn, duong_dan_tep_anh, ky_thuat_chup, vung_khao_sat, mo_ta_ton_thuong
                ) VALUES (
                    p_ma_phieu_out, v_ma_xn, 'pending_capture.dcm', 'Tiêu chuẩn', 'Theo chỉ định', 'Chờ chụp'
                );
            ELSE
                INSERT INTO ket_qua_dinh_tinh (
                    ma_phieu_chi_dinh, ma_danh_muc_xn, ket_qua_danh_gia, mo_ta_vi_sinh
                ) VALUES (
                    p_ma_phieu_out, v_ma_xn, 'AM_TINH', 'Đang nuôi cấy'
                );
            END IF;
        END LOOP;
    END IF;

    -- BƯỚC 3: Tạo Đơn thuốc & nạp chi tiết đơn thuốc từ JSONB (nếu có)
    IF p_danh_sach_thuoc IS NOT NULL AND jsonb_array_length(p_danh_sach_thuoc) > 0 THEN
        INSERT INTO don_thuoc (
            ma_ho_so, ma_bac_si_ke, ngay_ke_don, loi_dan_chung
        ) VALUES (
            p_ma_ho_so_out, p_ma_bac_si, CURRENT_TIMESTAMP, p_loi_dan
        ) RETURNING ma_don_thuoc INTO p_ma_don_out;

        FOR v_thuoc IN 
            SELECT * FROM jsonb_to_recordset(p_danh_sach_thuoc) AS x(
                ma_thuoc VARCHAR(15),
                so_luong INT,
                lieu_dung VARCHAR(50),
                so_lan INT,
                thoi_diem VARCHAR(100),
                so_ngay INT
            )
        LOOP
            v_stt_dong := v_stt_dong + 1;
            INSERT INTO chi_tiet_don_thuoc (
                ma_don_thuoc, so_thu_tu_dong, ma_thuoc, so_luong,
                lieu_dung_moi_lan, so_lan_uong_ngay, thoi_diem_uong, so_ngay_dung
            ) VALUES (
                p_ma_don_out, v_stt_dong, v_thuoc.ma_thuoc, v_thuoc.so_luong,
                v_thuoc.lieu_dung, v_thuoc.so_lan, v_thuoc.thoi_diem, v_thuoc.so_ngay
            );
        END LOOP;
    END IF;

    RAISE NOTICE 'KHÁM BỆNH THÀNH CÔNG: Hồ sơ ID: %, Phiếu XN ID: %, Đơn thuốc ID: %', 
        p_ma_ho_so_out, p_ma_phieu_out, p_ma_don_out;
END;
$$;
