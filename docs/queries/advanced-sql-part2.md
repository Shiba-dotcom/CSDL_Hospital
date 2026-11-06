# 📊 BÁO CÁO THỰC THI 6 TRUY VẤN SQL NÂNG CAO (PHẦN 2 — TUẦN 8)
## Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
*(Đáp ứng Chuẩn đầu ra 3: SQL Nâng cao — 2.0 điểm, hoàn thành trọn bộ 12 truy vấn Q1–Q12)*

---

## 1. TỔNG HỢP DANH MỤC TRUY VẤN TUẦN 8 (Q7 – Q12)

| Mã | Tên nghiệp vụ | Kỹ thuật SQL Nâng cao áp dụng | Tệp mã nguồn |
|:---:|---|---|---|
| **Q7** | Đóng gói toàn bộ quy trình khám ngoại trú (Khám $\rightarrow$ Chỉ định CLS $\rightarrow$ Đơn thuốc) trong 1 Transaction | **Stored Procedure (PL/pgSQL)** với tham số `INOUT`, duyệt mảng `FOREACH ... IN ARRAY`, bóc tách dữ liệu JSONB `jsonb_to_recordset()`, Transaction Control | [q07_stored_procedure_workflow.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q07_stored_procedure_workflow.sql) |
| **Q8** | Báo cáo phân tích doanh thu và lượt khám linh hoạt theo nhiều chiều gom nhóm | **Dynamic SQL (SQL Động)** với hàm `EXECUTE FORMAT`, tham số an toàn `%s`, `%L`, cơ chế chống SQL Injection, trả về bảng `RETURNS TABLE` | [q08_dynamic_sql_reporting.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q08_dynamic_sql_reporting.sql) |
| **Q9** | Chức năng tìm kiếm hồ sơ bệnh nhân thông minh đa tiêu chí (Fuzzy search, lọc độ tuổi, nhóm máu) | **Stored Function trả về kiểu bảng (`RETURNS TABLE`)**, tính tuổi dẫn xuất, tìm kiếm trên mảng `ANY(so_dien_thoai)`, tổng hợp lịch sử khám | [q09_table_function_search.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q09_table_function_search.sql) |
| **Q10** | Thanh tra y tế truy vết và phân tích biến động sửa đổi kết quả xét nghiệm | **JSONB Query chuyên sâu**, toán tử `->>`, `->`, `?` (key exists), ép kiểu số học trực tiếp từ JSONB, tính độ chênh lệch (Delta) | [q10_jsonb_audit_query.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q10_jsonb_audit_query.sql) |
| **Q11** | Bảng tổng hợp chéo ma trận phân bổ các nhóm dịch vụ cận lâm sàng của bác sĩ | **PIVOT / CROSSTAB** hiện đại sử dụng mệnh đề chuẩn ISO `FILTER (WHERE ...)`, tính tỷ lệ phần trăm phân bổ | [q11_pivot_crosstab.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q11_pivot_crosstab.sql) |
| **Q12** | Hệ thống Hỗ trợ Ra Quyết định Lâm sàng (CDSS) tự động cảnh báo dị ứng thuốc | **Cross-table Trigger & Stored Function** kiểm tra xung đột đa bảng (`ChiTietDonThuoc` $\rightarrow$ `DonThuoc` $\rightarrow$ `HoSo` $\rightarrow$ `BenhNhan`), chặn `check_violation` khi phát hiện rủi ro | [q12_business_safety_trigger.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q12_business_safety_trigger.sql) |

---

## 2. CHI TIẾT TỪNG TRUY VẤN & KẾT QUẢ THỰC THI THỰC TẾ

### 2.1. Truy vấn Q7: Stored Procedure quy trình khám bệnh toàn diện trong 1 Transaction
- **Mã nguồn:** [q07_stored_procedure_workflow.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q07_stored_procedure_workflow.sql)
- **Ý nghĩa nghiệp vụ:** 
  Khi bác sĩ kết thúc buổi khám bệnh, hệ thống cần thực hiện đồng bộ 3 hành động:
  1. Ghi nhận hồ sơ khám bệnh lâm sàng kèm các dấu hiệu sinh tồn (mạch, huyết áp, nhiệt độ, chiều cao, cân nặng).
  2. Tạo phiếu chỉ định cận lâm sàng và sinh các bản ghi kết quả ban đầu tương ứng với hình thái xét nghiệm (định lượng, định tính, hình ảnh).
  3. Kê đơn thuốc điện tử từ danh sách thuốc dạng JSONB truyền từ giao diện ứng dụng.
  Toàn bộ chu trình này phải được bảo đảm tính nguyên tử (Atomicity) theo chuẩn ACID — nếu có lỗi bất kỳ thì toàn bộ tác vụ phải rollback, không để lại dữ liệu rác hay hồ sơ mồ côi.
- **Điểm sáng kỹ thuật:**
  - Thủ tục PL/pgSQL sử dụng 3 tham số `INOUT` (`p_ma_ho_so_out`, `p_ma_phieu_out`, `p_ma_don_out`) để trả ID vừa sinh về cho caller.
  - Vòng lặp `FOREACH v_ma_xn IN ARRAY p_danh_sach_xn` tự động nhận diện hình thái xét nghiệm (`DINH_LUONG`, `HINH_ANH`, `DINH_TINH`) để chèn vào bảng con kế thừa tương ứng.
  - Sử dụng hàm `jsonb_to_recordset(p_danh_sach_thuoc)` để bóc tách mảng JSONB thành các dòng quan hệ và nạp vào bảng `chi_tiet_don_thuoc`.
- **Kết quả thực thi mẫu (Trích xuất từ Database Docker):**
```text
======================================================================
1. KHỞI TẠO VÀ THỰC THI Q7: STORED PROCEDURE QUY TRÌNH KHÁM BỆNH
======================================================================
CREATE PROCEDURE
psql:sql/queries/run_week8_queries.sql:33: NOTICE:  KHÁM BỆNH THÀNH CÔNG: Hồ sơ ID: 244, Phiếu XN ID: 203, Đơn thuốc ID: 185
DO
```

---

### 2.2. Truy vấn Q8: Dynamic SQL (SQL Động với cú pháp EXECUTE FORMAT)
- **Mã nguồn:** [q08_dynamic_sql_reporting.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q08_dynamic_sql_reporting.sql)
- **Ý nghĩa nghiệp vụ:** 
  Báo cáo thống kê hiệu suất khám bệnh và doanh thu tiền thuốc phục vụ Ban Quản lý bệnh viện. Người dùng báo cáo có thể chọn linh hoạt trục gom nhóm dữ liệu theo:
  - Từng Bác sĩ (`'BAC_SI'`)
  - Từng Khoa phòng (`'KHOA_PHONG'`)
  - Từng Tháng điều trị (`'THANG'`)
  kèm theo khoảng thời gian từ ngày ... đến ngày ... tùy chọn.
- **Điểm sáng kỹ thuật:**
  - Hàm `fn_thong_ke_kham_benh_dong` nhận tham số đầu vào và xây dựng câu lệnh SQL bằng chuỗi động.
  - Sử dụng hàm chuẩn an toàn `format()` của PostgreSQL với `%s` cho cấu trúc lệnh và `%L` (Literal) để escape chuỗi tham số ngày tháng, triệt tiêu nguy cơ tấn công **SQL Injection**.
  - Trả về bảng ảo có cấu trúc chặt chẽ (`RETURNS TABLE (tieu_chi_nhom TEXT, ten_doi_tuong TEXT, so_luot_kham BIGINT, so_don_thuoc BIGINT, tong_tien_thuoc_vnd NUMERIC)`).
- **Kết quả thực thi mẫu:**
```text
--> Báo cáo gom nhóm theo BÁC SĨ:
 tieu_chi_nhom |      ten_doi_tuong       | so_luot_kham | so_don_thuoc | tong_tien_thuoc_vnd 
---------------+--------------------------+--------------+--------------+---------------------
 NV-00001      | BS.CKII. Trần Đình Khoa  |           83 |           63 |         19053000.00
 NV-00002      | ThS.BS. Lê Thị Mai Lan   |           80 |           60 |         18360000.00
 NV-00003      | BS.CKI. Nguyễn Hoàng Nam |           80 |           60 |         18360000.00
(3 rows)

--> Báo cáo gom nhóm theo KHOA PHÒNG:
 tieu_chi_nhom |        ten_doi_tuong         | so_luot_kham | so_don_thuoc | tong_tien_thuoc_vnd 
---------------+------------------------------+--------------+--------------+---------------------
 P_101         | Phòng Khám Nội Tổng Quát 101 |           83 |           63 |         19053000.00
 P_102         | Phòng Khám Tim Mạch 102      |           80 |           60 |         18360000.00
 P_103         | Phòng Khám Hô Hấp 103        |           80 |           60 |         18360000.00
(3 rows)
```

---

### 2.3. Truy vấn Q9: Stored Function trả về kiểu bảng (RETURNS TABLE)
- **Mã nguồn:** [q09_table_function_search.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q09_table_function_search.sql)
- **Ý nghĩa nghiệp vụ:** 
  Cung cấp API tìm kiếm bệnh nhân tốc độ cao cho bộ phận tiếp đón và điều dưỡng. Hỗ trợ tìm kiếm mờ (Fuzzy search) theo tên, mã bệnh nhân, căn cước công dân hoặc số điện thoại (trong mảng đa trị), đồng thời kết hợp bộ lọc phân tầng theo nhóm máu và khoảng độ tuổi lâm sàng.
- **Điểm sáng kỹ thuật:**
  - `RETURNS TABLE (...)`: cho phép câu lệnh gọi hàm trực tiếp trong mệnh đề `FROM fn_tim_kiem_benh_nhan_nang_cao(...)`.
  - Tính toán độ tuổi động: `(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM n.ngay_sinh))::INT`.
  - Tìm kiếm phần tử trong mảng số điện thoại: `p_tu_khoa = ANY(n.so_dien_thoai)`.
  - Mệnh đề `WHERE` xử lý tham số `DEFAULT NULL` một cách thanh lịch: `(p_tu_khoa IS NULL OR ...)`.
- **Kết quả thực thi mẫu (Tìm kiếm họ 'Nguyễn', độ tuổi 40–70):**
```text
 ma_benh_nhan |      ho_ten       | tuoi | gioi_tinh | nhom_mau | so_dien_thoai_chinh |        tien_su_di_ung        | tong_so_lan_kham | ngay_kham_gan_nhat 
--------------+-------------------+------+-----------+----------+---------------------+------------------------------+------------------+--------------------
 BN-000015    | Nguyễn Minh Hương |   57 | NU        | A-       | 0910185175          | Dị ứng kháng sinh Penicillin |                4 | 2026-09-10
 BN-000060    | Nguyễn Văn An     |   61 | NAM       | AB+      | 0910740700          | Dị ứng kháng sinh Penicillin |                4 | 2026-11-02
 BN-000030    | Nguyễn Đức Mai    |   42 | NAM       | B+       | 0910370350          | Dị ứng kháng sinh Penicillin |                4 | 2026-09-28
(3 rows)
```

---

### 2.4. Truy vấn Q10: Phân tích JSONB trên bảng Nhật ký kiểm toán (Audit Trail)
- **Mã nguồn:** [q10_jsonb_audit_query.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q10_jsonb_audit_query.sql)
- **Ý nghĩa nghiệp vụ:** 
  Phục vụ công tác thanh tra y tế và quản lý chất lượng phòng xét nghiệm (ISO 15189): Khi kỹ thuật viên chỉnh sửa kết quả xét nghiệm định lượng (ví dụ hiệu chuẩn lại máy phân tích tự động hay pha loãng mẫu bệnh phẩm), truy vấn bóc tách dữ liệu snapshot trước và sau khi sửa, tính toán biên độ chênh lệch và hiển thị sự thay đổi nhãn cảnh báo lâm sàng.
- **Điểm sáng kỹ thuật:**
  - Toán tử JSONB:
    - `->>`: Trích xuất trường dưới dạng text thuần để hiển thị hoặc ép kiểu.
    - `?`: Kiểm tra sự tồn tại của khóa JSONB (`ls.du_lieu_cu ? 'gia_tri_do'`).
  - Ép kiểu toán học trực tiếp từ JSONB sang `NUMERIC` để tính toán delta chênh lệch:
    `((ls.du_lieu_moi->>'gia_tri_do')::NUMERIC - (ls.du_lieu_cu->>'gia_tri_do')::NUMERIC)`.
  - Kết nối bảng `lich_su_chinh_sua` với `nhan_vien_y_te` và `nguoi` để quy trách nhiệm pháp lý rõ ràng.
- **Kết quả thực thi mẫu:**
```text
 ma_lich_su |      ten_bang      | ma_ket_qua_bi_sua | phien_ban_truoc_khi_sua | loai_thao_tac | ma_xet_nghiem | gia_tri_do_cu | gia_tri_do_moi | don_vi | bien_do_chenh_lech |     bien_dong_canh_bao     |                         ly_do_sua                          | ma_ktv_sua |   ten_ktv_sua    |       thoi_gian_sua        
------------+--------------------+-------------------+-------------------------+---------------+---------------+---------------+----------------+--------+--------------------+----------------------------+------------------------------------------------------------+------------+------------------+----------------------------
          1 | ket_qua_dinh_luong | 1                 |                       1 | UPDATE        | GLUCOSE       |         4.150 |          8.250 | mmol/L |              4.100 | BINH_THUONG -> BINH_THUONG | Hiệu chuẩn lại máy phân tích tự động Beckman Coulter số 01 | NV-00004   | KTV. Đỗ Văn Hùng | 2026-11-04 09:07:26.273349
          2 | ket_qua_dinh_luong | 2                 |                       1 | UPDATE        | GLUCOSE       |         4.300 |          5.100 | mmol/L |              0.800 | BINH_THUONG -> BINH_THUONG | Kỹ thuật viên đối chiếu lại mẫu huyết thanh chạy lần 2     | NV-00004   | KTV. Đỗ Văn Hùng | 2026-11-04 09:07:26.273349
          3 | ket_qua_dinh_luong | 5                 |                       1 | UPDATE        | GLUCOSE       |         4.750 |          7.800 | mmol/L |              3.050 | BINH_THUONG -> BINH_THUONG | Đính chính kết quả sau khi pha loãng mẫu bệnh phẩm         | NV-00004   | KTV. Đỗ Văn Hùng | 2026-11-04 09:07:26.273349
(3 rows)
```

---

### 2.5. Truy vấn Q11: Bảng tổng hợp chéo Ma trận 2 chiều (PIVOT / CROSSTAB)
- **Mã nguồn:** [q11_pivot_crosstab.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q11_pivot_crosstab.sql)
- **Ý nghĩa nghiệp vụ:** 
  Ban Giám đốc phân tích thói quen và xu hướng chỉ định cận lâm sàng của các bác sĩ. Xoay trục nhóm xét nghiệm (vốn nằm dọc theo dòng) thành 5 cột ngang tương ứng với 5 nhóm nghiệp vụ (`SINH_HOA`, `HUYET_HOC`, `CHIEU_CHUP`, `THAM_DO_CN`, `VI_SINH`), đồng thời tính tỷ trọng phần trăm chỉ định chiếu chụp hình ảnh để kiểm soát việc lạm dụng dịch vụ kỹ thuật cao.
- **Điểm sáng kỹ thuật:**
  - Sử dụng mệnh đề chuẩn SQL:2003 `COUNT(*) FILTER (WHERE condition)` để xoay trục (Pivot) mà không cần cài đặt extension phụ `tablefunc` (crosstab), đạt hiệu năng tối ưu và tương thích cao.
  - Sử dụng hàm `NULLIF()` trong phép chia tỷ lệ phần trăm để chống lỗi `division by zero`.
- **Kết quả thực thi mẫu:**
```text
 ma_bac_si |      ho_ten_bac_si       |   chuyen_khoa_chinh   |        khoa_lam_viec         | so_xn_sinh_hoa | so_xn_huyet_hoc | so_xn_chieu_chup | so_xn_tham_do_cn | so_xn_vi_sinh | tong_so_chi_dinh | ty_le_chieu_chup_pct 
-----------+--------------------------+-----------------------+------------------------------+----------------+-----------------+------------------+------------------+---------------+------------------+----------------------
 NV-00001  | BS.CKII. Trần Đình Khoa  | Nội Tổng Quát         | Phòng Khám Nội Tổng Quát 101 |            125 |               0 |               43 |                0 |            26 |              194 |                22.16
 NV-00003  | BS.CKI. Nguyễn Hoàng Nam | Hô Hấp                | Phòng Khám Hô Hấp 103        |            117 |               0 |               40 |                0 |            27 |              184 |                21.74
 NV-00002  | ThS.BS. Lê Thị Mai Lan   | Tim Mạch & Chuyển Hóa | Phòng Khám Tim Mạch 102      |            117 |               0 |               40 |                0 |            27 |              184 |                21.74
(3 rows)
```

---

### 2.6. Truy vấn Q12: Function & Trigger Hỗ trợ Quyết định Lâm sàng (CDSS)
- **Mã nguồn:** [q12_business_safety_trigger.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/q12_business_safety_trigger.sql)
- **Ý nghĩa nghiệp vụ:** 
  Tính năng bảo vệ sinh mạng bệnh nhân (Clinical Decision Support System - CDSS). Ngay khi bác sĩ thao tác kê đơn thuốc trên giao diện hoặc qua API, trigger sẽ lập tức kiểm tra chéo tiền sử dị ứng của bệnh nhân nhận thuốc. Nếu phát hiện bác sĩ kê nhóm thuốc xung đột (ví dụ: bệnh nhân dị ứng Penicillin nhưng kê Augmentin/Amoxicillin), CSDL sẽ ném lỗi ngoại lệ và từ chối ghi nhận dòng thuốc đó.
- **Điểm sáng kỹ thuật:**
  - **Cross-table Trigger:** Trigger gắn trên bảng `chi_tiet_don_thuoc` (`BEFORE INSERT OR UPDATE OF ma_thuoc`) nhưng thực hiện join qua 4 quan hệ: `thuoc`, `don_thuoc`, `ho_so_kham_benh`, `benh_nhan`, `nguoi`.
  - Bắt lỗi chuẩn định dạng `USING ERRCODE = 'check_violation'`.
  - Kèm khối kiểm thử nghiệm vụ tự động (Automated Test Block) chứng minh cả 2 kịch bản:
    - Kê thuốc an toàn (Paracetamol) $\rightarrow$ Thành công.
    - Kê thuốc xung đột dị ứng (Augmentin) $\rightarrow$ Bị trigger chặn đứng thành công.
- **Kết quả thực thi mẫu:**
```text
psql:sql/queries/run_week8_queries.sql:114: NOTICE:  TEST 1: Kê Paracetamol thành công cho bệnh nhân dị ứng Penicillin (Hợp lệ).
psql:sql/queries/run_week8_queries.sql:114: NOTICE:  TEST 2: TRIGGER ĐÃ BẢO VỆ THÀNH CÔNG! Chặn đứng kê thuốc Augmentin cho bệnh nhân dị ứng Penicillin!
DO
======================================================================
HOÀN TẤT KIỂM THỬ THÀNH CÔNG 100% TOÀN BỘ 12 TRUY VẤN SQL NÂNG CAO!
======================================================================
```

---

## 3. TỔNG KẾT ĐÁNH GIÁ CHUẨN ĐẦU RA 3 (SQL NÂNG CAO)

| Chỉ tiêu môn học | Yêu cầu của đề tài | Kết quả đạt được | Trạng thái |
|---|---|---|:---:|
| **Số lượng truy vấn** | Tối thiểu 10 – 12 câu | Đã hoàn thành trọn vẹn **12 câu (Q1 – Q12)** | **VƯỢT CHỈ TIÊU (100%)** |
| **Kỹ thuật bắt buộc** | Join nhiều bảng, Subquery, Window Function, CTE, Division, Trigger, Procedure | Đầy đủ 100% các kỹ thuật: Correlated Subquery, Window Functions (`LAG`, `OVER`), Recursive CTE, Double NOT EXISTS Division, Stored Procedure with In/Out & JSONB, Dynamic SQL với `EXECUTE FORMAT`, Stored Table Function, JSONB Operators, Modern PIVOT (`FILTER WHERE`), và Cross-table CDSS Safety Trigger | **XUẤT SẮC** |
| **Kiểm thử trên CSDL** | Chạy kiểm thử thành công trên hệ CSDL thực tế | 100% các script chạy thông suốt trên PostgreSQL 16 Docker | **ĐẠT** |
| **Chất lượng báo cáo** | Có phân tích ý nghĩa nghiệp vụ, giải thích kỹ thuật và chụp ảnh/log kết quả | Báo cáo chi tiết Phần 1 ([advanced-sql-part1.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/queries/advanced-sql-part1.md)) & Phần 2 ([advanced-sql-part2.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/queries/advanced-sql-part2.md)) | **ĐẠT** |

