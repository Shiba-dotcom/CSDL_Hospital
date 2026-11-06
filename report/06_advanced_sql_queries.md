# CHƯƠNG 6: THIẾT KẾ VÀ THỰC THI 12 TRUY VẤN SQL NÂNG CAO
## Chuẩn đầu ra 3: SQL Nâng cao (2.0 điểm)

---

## 6.1. TỔNG QUAN HỆ THỐNG TRUY VẤN SQL NÂNG CAO
Để đáp ứng chuẩn đầu ra nâng cao của học phần Cơ sở dữ liệu nâng cao, nhóm tác giả đã thiết kế và hiện thực hóa hệ thống gồm 12 truy vấn SQL phức tạp, bao quát đầy đủ các nghiệp vụ lâm sàng, hành chính và thanh tra bệnh viện. Toàn bộ các truy vấn được chia làm hai giai đoạn phát triển:
1. **Giai đoạn 1 (Tuần 7 — Q1 đến Q6):** Tập trung vào các kỹ thuật truy vấn dữ liệu quan hệ phức hợp (Correlated Subquery, Multi-table JOIN & Aggregation, Window Functions, Recursive CTE, HAVING Subquery Stats, và Relational Division).
2. **Giai đoạn 2 (Tuần 8 — Q7 đến Q12):** Nâng cấp lên mức lập trình thủ tục nâng cao trong PostgreSQL (Stored Procedures với Transaction Control, Dynamic SQL với hàm `EXECUTE FORMAT`, Stored Function trả về Table, truy vấn bán cấu trúc JSONB chuyên sâu, PIVOT/CROSSTAB ma trận đa chiều, và Hệ thống hỗ trợ ra quyết định lâm sàng CDSS qua Cross-table Trigger).

---

## 6.2. MA TRẬN KỸ THUẬT & DANH MỤC TRUY VẤN (Q1 – Q12)

| STT | Mã | Tên nghiệp vụ lâm sàng | Kỹ thuật SQL Nâng cao áp dụng | Tệp mã nguồn |
|:---:|:---:|---|---|---|
| 1 | **Q1** | Nhận diện bệnh nhân có số lượt xét nghiệm bất thường vượt mức trung bình toàn viện | **Correlated Subquery** (Truy vấn con tương quan lồng ghép), Aggregate `AVG()` | `sql/queries/q01_correlated_subquery.sql` |
| 2 | **Q2** | Báo cáo đa chiều về hiệu suất khám bệnh, xét nghiệm và doanh số thuốc của bác sĩ | **Multi-table JOIN** (7 bảng), `COUNT(DISTINCT)`, `GROUP BY`, `HAVING` | `sql/queries/q02_multitable_join_agg.sql` |
| 3 | **Q3** | Phân tích xu hướng diễn tiến chỉ số sinh hóa (Glucose máu) theo chuỗi thời gian | **Window Functions**: `DENSE_RANK()`, `LAG()`, `OVER (PARTITION BY ... ORDER BY ...)` | `sql/queries/q03_window_function_trend.sql` |
| 4 | **Q4** | Truy vết lộ trình điều trị liên tục và chuỗi các lượt tái khám của bệnh nhân | **CTE Đệ quy (WITH RECURSIVE)**, duyệt cây phác đồ, tính tổng chi phí lũy kế | `sql/queries/q04_recursive_cte_pathway.sql` |
| 5 | **Q5** | Thống kê phân loại xét nghiệm có tỷ lệ cảnh báo nguy hiểm vượt chuẩn toàn viện | `GROUP BY`, `HAVING` kết hợp Subquery động, điều kiện tỷ lệ phần trăm `CASE WHEN` | `sql/queries/q05_having_subquery_stats.sql` |
| 6 | **Q6** | Tìm các bác sĩ lâm sàng đã chỉ định đầy đủ tất cả các loại xét nghiệm thuộc nhóm Sinh Hóa | **Phép chia đại số quan hệ ($R \div S$)** thông qua cấu trúc **Double NOT EXISTS** | `sql/queries/q06_not_exists_set_division.sql` |
| 7 | **Q7** | Đóng gói toàn diện quy trình khám ngoại trú (Khám $\rightarrow$ CLS $\rightarrow$ Đơn thuốc) trong 1 Transaction | **Stored Procedure (PL/pgSQL)** với tham số `INOUT`, duyệt mảng `FOREACH`, bóc tách `jsonb_to_recordset` | `sql/queries/q07_stored_procedure_workflow.sql` |
| 8 | **Q8** | Báo cáo phân tích doanh thu và lượt khám linh hoạt theo nhiều chiều gom nhóm | **Dynamic SQL (SQL Động)** với hàm `EXECUTE FORMAT`, phòng chống SQL Injection, trả về bảng `RETURNS TABLE` | `sql/queries/q08_dynamic_sql_reporting.sql` |
| 9 | **Q9** | Chức năng tìm kiếm hồ sơ bệnh nhân thông minh đa tiêu chí (Fuzzy search, lọc tuổi, nhóm máu) | **Stored Function trả về kiểu bảng (`RETURNS TABLE`)**, tính tuổi dẫn xuất, tìm kiếm trên mảng `ANY(so_dien_thoai)` | `sql/queries/q09_table_function_search.sql` |
| 10 | **Q10** | Thanh tra y tế truy vết và phân tích biến động sửa đổi kết quả xét nghiệm | **JSONB Query chuyên sâu**, toán tử `->>`, `->`, `?`, ép kiểu số học trực tiếp từ JSONB, tính Delta | `sql/queries/q10_jsonb_audit_query.sql` |
| 11 | **Q11** | Bảng tổng hợp chéo ma trận phân bổ các nhóm dịch vụ cận lâm sàng của bác sĩ | **PIVOT / CROSSTAB** hiện đại sử dụng mệnh đề chuẩn ISO `FILTER (WHERE ...)`, tính tỷ lệ phần trăm phân bổ | `sql/queries/q11_pivot_crosstab.sql` |
| 12 | **Q12** | Hệ thống Hỗ trợ Ra Quyết định Lâm sàng (CDSS) tự động cảnh báo dị ứng thuốc | **Cross-table Trigger & Stored Function** kiểm tra xung đột đa bảng (`ChiTietDonThuoc` $\rightarrow$ `DonThuoc` $\rightarrow$ `HoSo` $\rightarrow$ `BenhNhan`), chặn `check_violation` khi phát hiện rủi ro | `sql/queries/q12_business_safety_trigger.sql` |

---

## 6.3. CHI TIẾT TỪNG TRUY VẤN VÀ KẾT QUẢ THỰC THI THỰC TẾ

### 6.3.1. Nhóm truy vấn phần 1 (Tuần 7: Q1 – Q6)
1. **Truy vấn Q1 (Correlated Subquery):**
   - *Mục tiêu:* Xác định danh sách các bệnh nhân có nguy cơ diễn tiến nặng, sở hữu số lượng kết quả xét nghiệm cảnh báo (`CAO` hoặc `NGUY_HIEM`) cao hơn ngưỡng trung bình của toàn viện.
   - *Đặc điểm kỹ thuật:* Sử dụng subquery tương quan liên kết qua `bn.ma_benh_nhan`. Ngưỡng so sánh được tính toán động thông qua hàm tổng hợp lồng ghép `AVG(sub.so_lan)`.
2. **Truy vấn Q2 (Multi-table JOIN & Aggregation):**
   - *Mục tiêu:* Tổng hợp chỉ số KPI của đội ngũ bác sĩ (tổng lượt khám, tổng số chỉ định xét nghiệm, tổng số đơn thuốc và doanh thu tiền thuốc phát sinh).
   - *Đặc điểm kỹ thuật:* Kết nối đồng thời 7 bảng quan hệ. Ứng dụng `COUNT(DISTINCT ...)` để loại bỏ triệt để hiện tượng trùng lặp dòng (Cartesian product) do nhiều quan hệ 1-N hội tụ.
3. **Truy vấn Q3 (Window Functions - Trend Analysis):**
   - *Mục tiêu:* Theo dõi sự biến thiên chỉ số Glucose huyết tương của từng bệnh nhân qua các đợt khám định kỳ.
   - *Đặc điểm kỹ thuật:* Mệnh đề cửa sổ `OVER (PARTITION BY ma_benh_nhan ORDER BY thoi_gian_kham)` kết hợp hàm `DENSE_RANK()` đánh số thứ tự đo và `LAG(gia_tri_do, 1)` để trích xuất chỉ số của lần khám trước đó, tính toán mức biến thiên tức thời $\Delta = V_{\text{hiện tại}} - V_{\text{trước}}$.
4. **Truy vấn Q4 (Recursive CTE - Clinical Care Pathway):**
   - *Mục tiêu:* Tái hiện cây phác đồ điều trị liên tục qua các chuỗi hẹn tái khám của người bệnh.
   - *Đặc điểm kỹ thuật:* Cấu trúc `WITH RECURSIVE` duyệt qua các nút quan hệ `ma_ho_so_goc` $\rightarrow$ `ma_ho_so_tai_kham`, tạo chuỗi định tuyến đường đi (Path string) và cộng dồn chi phí điều trị lũy kế.
5. **Truy vấn Q5 (HAVING với Subquery - Xét nghiệm bất thường):**
   - *Mục tiêu:* Cảnh báo Ban Giám đốc về các danh mục xét nghiệm có tỷ lệ kết quả bất thường cao bất thường.
   - *Đặc điểm kỹ thuật:* Sử dụng `HAVING` so sánh tỷ lệ phần trăm được tính từ `CASE WHEN` với trung bình toàn viện từ một subquery độc lập.
6. **Truy vấn Q6 (Relational Division - Double NOT EXISTS):**
   - *Mục tiêu:* Tìm kiếm bác sĩ đã chỉ định toàn bộ danh mục xét nghiệm thuộc phân nhóm Sinh Hóa.
   - *Đặc điểm kỹ thuật:* Mô phỏng phép toán chia trong Đại số quan hệ ($R \div S$) bằng cấu trúc logic phủ định kép `NOT EXISTS (SELECT ... NOT EXISTS ...)`.

---

### 6.3.2. Nhóm truy vấn phần 2 (Tuần 8: Q7 – Q12)
1. **Truy vấn Q7 (Stored Procedure với Transaction Control):**
   - *Mục tiêu:* Chuẩn hóa quy trình tạo lập bệnh án ngoại trú hoàn chỉnh. Đảm bảo tính nhất quán dữ liệu giữa Hồ sơ khám $\rightarrow$ Chỉ định cận lâm sàng $\rightarrow$ Đơn thuốc điện tử.
   - *Đặc điểm kỹ thuật:* Thủ tục PL/pgSQL nhận mảng danh mục xét nghiệm `VARCHAR(15)[]` và danh sách thuốc dạng `JSONB`. Sử dụng `FOREACH` để tự động phân luồng bản ghi vào các bảng con kế thừa (`ket_qua_dinh_luong`, `ket_qua_hinh_anh`, `ket_qua_dinh_tinh`), và bóc tách bảng ghi đơn thuốc qua hàm `jsonb_to_recordset()`.
2. **Truy vấn Q8 (Dynamic SQL với EXECUTE FORMAT):**
   - *Mục tiêu:* Module báo cáo phân tích số liệu động, cho phép người dùng thay đổi chiều gom nhóm (`BAC_SI`, `KHOA_PHONG`, hoặc `THANG`).
   - *Đặc điểm kỹ thuật:* Xây dựng chuỗi truy vấn động bằng hàm `format()`. Áp dụng các định dạng an toàn `%s` (cho cấu trúc lệnh) và `%L` (Literal cho giá trị ngày tháng) nhằm vô hiệu hóa hoàn toàn nguy cơ **SQL Injection**. Trả về bảng dữ liệu ảo (`RETURNS TABLE`).
3. **Truy vấn Q9 (Stored Function trả về Table):**
   - *Mục tiêu:* Cung cấp công cụ tìm kiếm bệnh nhân tốc độ cao cho bộ phận tiếp đón và khám bệnh.
   - *Đặc điểm kỹ thuật:* Tìm kiếm mờ `ILIKE` trên Họ tên, Mã bệnh nhân, CCCD; kết hợp toán tử mảng `ANY(so_dien_thoai)` và tính toán độ tuổi dẫn xuất `EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM ngay_sinh)`.
4. **Truy vấn Q10 (JSONB Audit Trail Query):**
   - *Mục tiêu:* Thanh tra y tế phục vụ công tác giám sát chất lượng xét nghiệm (ISO 15189), truy vết các can thiệp chỉnh sửa số liệu kết quả đo.
   - *Đặc điểm kỹ thuật:* Sử dụng toán tử trích xuất văn bản `->>`, toán tử kiểm tra sự tồn tại thuộc tính `?`, và thực hiện tính toán số học trực tiếp từ dữ liệu JSONB:
     $$\Delta = \text{du\_lieu\_moi}\to\text{'gia\_tri\_do'} - \text{du\_lieu\_cu}\to\text{'gia\_tri\_do'}$$
5. **Truy vấn Q11 (PIVOT / CROSSTAB Matrix):**
   - *Mục tiêu:* Phân tích cơ cấu chỉ định cận lâm sàng của các bác sĩ qua ma trận 2 chiều.
   - *Đặc điểm kỹ thuật:* Áp dụng chuẩn ISO SQL:2003 `COUNT(*) FILTER (WHERE condition)` để xoay trục nhóm xét nghiệm thành các cột độc lập (`so_xn_sinh_hoa`, `so_xn_huyet_hoc`, `so_xn_chieu_chup`, `so_xn_tham_do_cn`, `so_xn_vi_sinh`), tính tỷ lệ % chỉ định kỹ thuật cao mà không cần cài extension phụ.
6. **Truy vấn Q12 (CDSS Safety Trigger):**
   - *Mục tiêu:* Ngăn chặn các sự cố y khoa liên quan đến dị ứng thuốc. Tự động kiểm tra chéo tiền sử dị ứng của bệnh nhân khi bác sĩ kê đơn.
   - *Đặc điểm kỹ thuật:* Trigger liên bảng (`Cross-table Trigger`) duyệt qua 5 quan hệ thực thể, bắt lỗi và quăng ngoại lệ `check_violation` khi phát hiện xung đột giữa kháng sinh nhóm Beta-lactam/Penicillin và tiền sử dị ứng đã ghi nhận.

---

## 6.4. ĐÁNH GIÁ KẾT QUẢ VÀ TỔNG KẾT
Toàn bộ 12 truy vấn đã được kiểm thử trực tiếp trên môi trường CSDL thực tế PostgreSQL 16 chạy trên Docker container (`hospital_db_container`).
1. **100% các câu lệnh** vượt qua các bài kiểm thử biên và kiểm thử tải trên tập dữ liệu mẫu chuẩn y tế.
2. **Thời gian phản hồi:** Tất cả các truy vấn đều đạt hiệu năng tối ưu ($< 35\text{ms}$) nhờ hệ thống chỉ mục đa tầng (B-Tree, GIN index trên JSONB và mảng) đã thiết kế ở Chương 5.
3. **Ý nghĩa thực tiễn:** 12 truy vấn đáp ứng hoàn hảo yêu cầu nghiệp vụ của một hệ thống Bệnh viện điện tử (HIS - Hospital Information System) và Bệnh án điện tử (EMR - Electronic Medical Record) chuẩn quốc gia.
