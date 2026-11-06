# 🏥 Hệ thống CSDL Hồ sơ Khám bệnh & Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
## Đồ án môn học: Cơ sở Dữ liệu Nâng cao (Advanced Database Systems)

> **Sinh viên thực hiện:** Huỳnh Tuấn Kiệt  
> **Hệ quản trị CSDL:** PostgreSQL 16 (Object-Relational DBMS)  
> **Môi trường ảo hóa:** Docker Container (`hospital_db_container` — Cổng kết nối Host: `5433:5432`)

---

## 📋 1. TỔNG QUAN ĐỀ TÀI & PHẠM VI NGHIỆP VỤ

Đề tài tập trung thiết kế và hiện thực hóa cơ sở dữ liệu hoàn chỉnh cho quy trình khám bệnh ngoại trú tiêu chuẩn tại bệnh viện, giải quyết hai bài toán kỹ thuật chuyên sâu:
1. **Lịch sử chỉnh sửa kết quả xét nghiệm (Audit Trail):** Ghi vết toàn bộ thao tác đính chính, hiệu chuẩn thông số cận lâm sàng dưới dạng snapshot bán cấu trúc `JSONB`, lưu trữ ai sửa, sửa gì, khi nào, lý do sửa và biên độ biến động chỉ số ($\Delta$).
2. **Đa hình thái kết quả xét nghiệm (Polymorphism):** Mô hình hóa kết quả xét nghiệm đa hình (Định lượng số học, Chẩn đoán hình ảnh DICOM, Nuôi cấy vi sinh/kháng sinh đồ) thông qua cơ chế kế thừa bảng (**Table Inheritance**) và kiểu dữ liệu phức hợp (**Composite Types**).
3. **Hỗ trợ ra quyết định lâm sàng (CDSS Trigger):** Tự động phát hiện và ngăn chặn bác sĩ kê đơn thuốc xung đột với tiền sử dị ứng của người bệnh ngay tại tầng CSDL.

---

## 🗺️ 2. BẢNG TỔNG HỢP TIẾN ĐỘ 12 TUẦN

| Giai đoạn | Tuần | Nội dung thực hiện | Tệp minh chứng chính |
|:---:|:---:|---|---|
| **Giai đoạn 1:<br>Phân tích & EER** | **Tuần 1–3** | • Đặc tả nghiệp vụ khám ngoại trú y khoa.<br>• Sơ đồ EER chuẩn: Chuyên biệt hóa Chồng lặp Overlapping `(o,t)` cho `Nguoi` $\rightarrow$ `BenhNhan`, `NhanVienYTe`; Rời rạc Disjoint `(d,t)` cho `KetQuaXetNghiem`.<br>• Từ điển dữ liệu chi tiết cho 18 bảng quan hệ. | • [business-description.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/business-description.md)<br>• [eer-specification.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/eer/eer-specification.md)<br>• [data-dictionary.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/data-dictionary/data-dictionary.md) |
| **Giai đoạn 2:<br>Chuẩn hóa Toán học** | **Tuần 4–5** | • Xác định hệ 42 phụ thuộc hàm ($F$), tìm phủ tối thiểu $F_{\min}$, bao đóng tập thuộc tính.<br>• Chứng minh 100% đạt chuẩn **BCNF** (hoặc 3NF có kiểm soát Trigger cho thuộc tính dẫn xuất BMI).<br>• Chứng minh bảo toàn thông tin (Lossless Join qua định lý Heath), bảo toàn phụ thuộc hàm.<br>• Phân tích phụ thuộc đa trị (MVD) và chứng minh đạt dạng chuẩn **4NF** cho mảng số điện thoại. | • [functional-dependencies.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/schemas/functional-dependencies.md)<br>• [normalization-proofs.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/schemas/normalization-proofs.md)<br>• [relational-schema.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/schemas/relational-schema.md) |
| **Giai đoạn 3:<br>CSDL Vật lý &<br>12 SQL Nâng cao** | **Tuần 6–8** | • Dựng PostgreSQL 16 Docker, DDL chia tầng, Trigger Audit Trail, Views báo cáo.<br>• Dữ liệu mẫu chuẩn: 66 người, 60 bệnh nhân, 249 hồ sơ, 568 kết quả xét nghiệm, 185 đơn thuốc.<br>• **Q1–Q6:** Correlated Subquery, Multi-table JOIN (7 bảng), Window Functions (`LAG`, `OVER`), Recursive CTE (`WITH RECURSIVE`), HAVING Subquery Stats, Relational Division ($R \div S$ qua Double NOT EXISTS).<br>• **Q7–Q12:** Stored Procedure (ACID quy trình khám với JSONB), Dynamic SQL (`EXECUTE FORMAT`), Stored Table Function, JSONB Audit Query, PIVOT Crosstab (`FILTER WHERE`), CDSS Allergy Trigger. | • [run_all.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/run_all.sql)<br>• [advanced-sql-part1.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/queries/advanced-sql-part1.md)<br>• [advanced-sql-part2.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/queries/advanced-sql-part2.md)<br>• [run_week7_queries.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/run_week7_queries.sql)<br>• [run_week8_queries.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/queries/run_week8_queries.sql) |
| **Giai đoạn 4:<br>ORDBMS &<br>Đo Hiệu năng** | **Tuần 9–10** | • 3 Composite Types (`dia_chi_type`, `chi_so_sinh_ton_type`, `bang_cap_type`).<br>• Phân cấp 8 lớp/bảng kế thừa (`INHERITS`), 7 phương thức thành viên (Methods).<br>• 6 câu truy vấn **OQL chuẩn ODMG 3.0** ánh xạ sang PostgreSQL SQL.<br>• Đo hiệu năng **EXPLAIN ANALYZE**: B-Tree Composite & GIN Index tăng tốc từ **12.8 đến 294.1 lần**.<br>• Health Check toàn vẹn: 0 bản ghi mồ côi, 11/11 triggers hoạt động hoàn hảo. | • [object-relational-and-oql.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/oop/object-relational-and-oql.md)<br>• [query-optimization-and-benchmarks.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/performance/query-optimization-and-benchmarks.md)<br>• [run_week9_oop_tests.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/oop/run_week9_oop_tests.sql)<br>• [explain_analyze_benchmark.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/tests/performance/explain_analyze_benchmark.sql) |
| **Giai đoạn 5:<br>Transaction &<br>Báo cáo tổng thể** | **Tuần 11–12** | • Kịch bản 1: Giao dịch trọn vẹn thành công (Happy Path).<br>• Kịch bản 2: Lỗi vi phạm CHECK constraint & ROLLBACK bảo vệ tính nguyên tử (All-or-Nothing).<br>• Kịch bản 3: Phòng chống Lost Update qua Khóa bi quan (`SELECT FOR UPDATE`) & Khóa lạc quan (OCC).<br>• Kịch bản 4: Ma trận cấp độ cô lập (Read Committed, Repeatable Read, Serializable).<br>• **Báo cáo đồ án Word (`.docx`)** hoàn chỉnh 11 chương (~30 trang).<br>• **Cẩm nang 10 câu hỏi - đáp bảo vệ đồ án** (Defense Cheatsheet). | • [transaction-and-concurrency.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/transactions/transaction-and-concurrency.md)<br>• [run_transaction_tests.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/transactions/run_transaction_tests.sql)<br>• [BaoCao_DoAn_CSDL_BenhVien.docx](file:///a:/VisualStudioCode/CSDL_BenhVien/BaoCao_DoAn_CSDL_BenhVien.docx)<br>• [defense-qa-cheatsheet.md](file:///a:/VisualStudioCode/CSDL_BenhVien/docs/defense/defense-qa-cheatsheet.md) |

---

## 📁 3. CẤU TRÚC THƯ MỤC DỰ ÁN

```
CSDL_BenhVien/
├── docs/                               # Toàn bộ tài liệu kỹ thuật & đặc tả
│   ├── eer/                            # Đặc tả EER & chuyên biệt hóa
│   ├── schemas/                        # Phụ thuộc hàm & chứng minh chuẩn hóa
│   ├── data-dictionary/                # Từ điển dữ liệu 18 bảng
│   ├── queries/                        # Báo cáo kỹ thuật 12 truy vấn nâng cao (Phần 1 & 2)
│   ├── oop/                            # Thiết kế ORDBMS & 6 truy vấn OQL
│   ├── performance/                    # Thực nghiệm EXPLAIN ANALYZE & tối ưu Index
│   ├── transactions/                   # Thực nghiệm 4 kịch bản Transaction & Concurrency
│   └── defense/                        # Cẩm nang 10 câu hỏi bảo vệ đồ án
├── sql/
│   ├── ddl/                            # 01_types, 02_tables, 03_indexes, 04_triggers, 05_views
│   ├── dml/                            # seed_data.sql (dữ liệu mẫu chuẩn y tế)
│   ├── queries/                        # q01 đến q12.sql + runner tuần 7, tuần 8
│   ├── oop/                            # Script composite types, inheritance, methods, OQL
│   └── transactions/                   # 01_happy_path, 02_rollback, 03_concurrency, 04_isolation
├── tests/
│   ├── performance/                    # explain_analyze_benchmark.sql
│   └── verify_end_to_end.sql           # Health check toàn diện hệ thống
├── report/                             # 11 chương báo cáo đồ án (.md)
├── scripts/                            # export_to_docx.py (tự động xuất báo cáo sang Word)
├── docker-compose.yml                  # Cấu hình container PostgreSQL 16
├── run_all.sql                         # Khởi tạo toàn bộ CSDL chỉ với 1 lệnh
├── BaoCao_DoAn_CSDL_BenhVien.docx      # Báo cáo Word hoàn chỉnh chuẩn học thuật (~30 trang)
└── README.md                           # Tài liệu tổng quan dự án
```

---

## 🚀 4. HƯỚNG DẪN KHỞI CHẠY & KIỂM THỬ TRÊN DOCKER

### 4.1. Khởi động môi trường Database
Hệ thống sử dụng Docker Compose với cổng ánh xạ máy chủ `5433:5432` (tránh xung đột với các phiên bản PostgreSQL có sẵn trên máy):
```powershell
# Khởi động container nền
docker compose up -d

# Kiểm tra trạng thái container đang chạy (Status: Up)
docker ps --filter "name=hospital_db_container"
```

### 4.2. Khởi tạo toàn bộ CSDL và nạp dữ liệu mẫu (1 lệnh duy nhất)
```powershell
docker exec -w /workspace hospital_db_container psql -U postgres -d hospital_db -f run_all.sql
```

### 4.3. Kiểm thử từng giai đoạn chuyên đề

```powershell
# 1. Chạy 6 truy vấn nâng cao Tuần 7 (Q1 - Q6):
docker exec -w /workspace hospital_db_container psql -U postgres -d hospital_db -f sql/queries/run_week7_queries.sql

# 2. Chạy 6 truy vấn nâng cao Tuần 8 (Q7 - Q12, Stored Procedure, Dynamic SQL, Trigger CDSS):
docker exec -w /workspace hospital_db_container psql -U postgres -d hospital_db -f sql/queries/run_week8_queries.sql

# 3. Chạy thực nghiệm CSDL Hướng đối tượng & OQL Tuần 9:
docker exec -w /workspace hospital_db_container psql -U postgres -d hospital_db -f sql/oop/run_week9_oop_tests.sql

# 4. Đo hiệu năng truy vấn EXPLAIN ANALYZE Tuần 10:
docker exec -w /workspace hospital_db_container psql -U postgres -d hospital_db -f tests/performance/explain_analyze_benchmark.sql

# 5. Kiểm tra sức khỏe toàn vẹn hệ thống (Health Check):
docker exec -w /workspace hospital_db_container psql -U postgres -d hospital_db -f tests/verify_end_to_end.sql

# 6. Chạy 4 kịch bản Giao dịch & Kiểm thử Concurrency Tuần 11:
docker exec -w /workspace hospital_db_container psql -U postgres -d hospital_db -f sql/transactions/run_transaction_tests.sql
```

---

## 📊 5. DANH MỤC 12 TRUY VẤN SQL NÂNG CAO (Q1 – Q12)

| Mã | Nghiệp vụ y tế | Kỹ thuật nâng cao áp dụng |
|:---:|---|---|
| **Q1** | Tìm bệnh nhân có lượt xét nghiệm bất thường vượt mức trung bình viện | **Correlated Subquery** lồng ghép trong WHERE & SELECT, Aggregate `AVG()` |
| **Q2** | Báo cáo KPI khám bệnh, xét nghiệm và doanh thu thuốc của từng bác sĩ | **Multi-table JOIN** (7 bảng), `COUNT(DISTINCT)`, `GROUP BY`, `HAVING` |
| **Q3** | Phân tích xu hướng diễn tiến chỉ số Glucose máu theo chuỗi thời gian | **Window Functions**: `DENSE_RANK()`, `LAG()`, `OVER (PARTITION BY ...)` |
| **Q4** | Truy vết cây phác đồ điều trị và các đợt tái khám liên tục của bệnh nhân | **CTE Đệ quy (`WITH RECURSIVE`)**, String Aggregation, Tính chi phí lũy kế |
| **Q5** | Thống kê danh mục xét nghiệm có tỷ lệ cảnh báo bất thường cao vượt chuẩn | `GROUP BY`, `HAVING` kết hợp Subquery động, tỷ lệ phần trăm theo điều kiện |
| **Q6** | Tìm bác sĩ đã chỉ định ĐẦY ĐỦ TẤT CẢ các xét nghiệm nhóm Sinh Hóa | **Phép chia đại số quan hệ ($R \div S$)** qua cấu trúc **Double NOT EXISTS** |
| **Q7** | Đóng gói toàn bộ quy trình khám lâm sàng ngoại trú trong 1 Transaction | **Stored Procedure (PL/pgSQL)** với tham số `INOUT`, duyệt mảng, nạp đơn thuốc JSONB |
| **Q8** | Báo cáo phân tích doanh số và lượt khám động theo nhiều chiều | **Dynamic SQL** với hàm `EXECUTE FORMAT`, tham số `%s`, `%L` chống SQL Injection |
| **Q9** | Chức năng tìm kiếm bệnh nhân thông minh đa tiêu chí (Fuzzy Search) | **Stored Function trả về Table (`RETURNS TABLE`)**, tính tuổi động, tìm mảng `ANY()` |
| **Q10** | Thanh tra y tế phân tích biến động sửa đổi kết quả xét nghiệm | **JSONB Query chuyên sâu**, toán tử `->>`, `->`, `?`, tính Delta ($\Delta$) |
| **Q11** | Ma trận tổng hợp phân bổ 5 nhóm dịch vụ cận lâm sàng của bác sĩ | **PIVOT / CROSSTAB** hiện đại sử dụng mệnh đề chuẩn ISO `FILTER (WHERE ...)` |
| **Q12** | Hệ thống Hỗ trợ Ra Quyết định Lâm sàng (CDSS) cảnh báo dị ứng thuốc | **Cross-table Trigger** liên kết 5 bảng, chặn `check_violation` khi xung đột dị ứng |

---

## 🧬 6. MÔ HÌNH HƯỚNG ĐỐI TƯỢNG (ORDBMS & OQL)

- **3 Kiểu phức hợp (Composite Types):** `oop.dia_chi_type`, `oop.chi_so_sinh_ton_type`, `oop.bang_cap_type`.
- **8 Lớp đối tượng (Table Inheritance):** 
  - Nhánh Con người: `oop.nguoi` $\rightarrow$ `oop.benh_nhan`, `oop.bac_si`, `oop.ky_thuat_vien`.
  - Nhánh Cận lâm sàng đa hình: `oop.ket_qua_xet_nghiem` $\rightarrow$ `oop.ket_qua_dinh_luong`, `oop.ket_qua_hinh_anh`, `oop.ket_qua_dinh_tinh`.
- **7 Phương thức thành viên:** `tinh_tuoi()`, `lay_dia_chi_day_du()`, `tinh_bmi()`, `danh_gia_the_trang()`, `danh_gia_muc_canh_bao()`, `kiem_tra_di_ung()`, `la_chuyen_gia()`.
- **6 Truy vấn OQL chuẩn ODMG 3.0:** Gọi phương thức đối tượng, truy vấn mảng tập hợp, duyệt kế thừa đa hình (Polymorphic Append Scan), biểu thức đường dẫn đa cấp (Path Expression), làm phẳng tập hợp (`UNNEST`), và khởi tạo đối tượng cấu trúc mới (`json_build_object`).

---

## ⚡ 7. KẾT QUẢ ĐO HIỆU NĂNG EXPLAIN ANALYZE

| Kịch bản Benchmark | Cơ chế tối ưu | Quét tuần tự (Seq Scan) | Quét có chỉ mục (Index Scan) | Tỷ lệ tăng tốc |
|---|---|:---:|:---:|:---:|
| **B1. Định lượng Glucose** | Composite B-Tree Index `(ma_danh_muc_xn, gia_tri_do)` | 27.059 ms | **0.092 ms** | **Nhanh gấp ~294 lần** |
| **B2. JSONB Audit Trail** | GIN Index `USING GIN (du_lieu_moi)` | 1.511 ms | **0.039 ms** | **Nhanh gấp ~38 lần** |
| **B3. Khoảng thời gian khám** | Partial B-Tree Index `WHERE is_deleted = FALSE` | 1.002 ms | **0.078 ms** | **Nhanh gấp ~12.8 lần** |
| **B4. Window Function (Q3)** | Sắp xếp bộ nhớ `quicksort Memory: 36kB` | — | **2.840 ms** | 100% trong RAM |
| **B5. Kế thừa đa hình** | Polymorphic Append Scan (568 bản ghi) | — | **0.938 ms** | Không cần `UNION` |

---

## 🔒 8. KIỂM THỬ GIAO DỊCH & CONCURRENCY

- **Kịch bản 1 (Happy Path):** Tạo lập trọn vẹn chu trình khám trong 1 Transaction, cam kết `COMMIT` toàn vẹn.
- **Kịch bản 2 (Rollback Atomicity):** Vi phạm CHECK constraint ở bước cuối kích hoạt `ROLLBACK` ngay lập tức, số lượng bản ghi trước và sau hoàn toàn bằng nhau, **0 bản ghi mồ côi**.
- **Kịch bản 3 (Lost Update & OCC):** Kết hợp Khóa bi quan (`SELECT ... FOR UPDATE`) và Khóa lạc quan (OCC qua cột `so_phien_ban`), loại bỏ triệt để hiện tượng ghi đè mất mát dữ liệu khi nhiều kỹ thuật viên đồng thời đính chính kết quả.
- **Kịch bản 4 (Isolation Levels):** Phân tích so sánh 3 mức cô lập của PostgreSQL (`READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`), xử lý lỗi tương tranh `40001 (serialization_failure)`.

---

## 📚 9. TÀI LIỆU THAM KHẢO

1. **Elmasri, R., & Navathe, S. B. (2016).** *Fundamentals of Database Systems* (7th ed.). Pearson Education.
2. **Silberschatz, A., Korth, H. F., & Sudarshan, S. (2019).** *Database System Concepts* (7th ed.). McGraw-Hill.
3. **PostgreSQL Global Development Group. (2024).** *PostgreSQL 16.4 Documentation*. https://www.postgresql.org/docs/16/
4. **Cattell, R. G. G., et al. (2000).** *The Object Data Standard: ODMG 3.0*. Morgan Kaufmann Publishers.
5. **Bộ Y tế Việt Nam.** *Thông tư 46/2018/TT-BYT quy định về hồ sơ bệnh án điện tử*.

---
*(Bản quyền đề tài thuộc về Huỳnh Tuấn Kiệt — Đồ án môn học Cơ sở Dữ liệu Nâng cao)*
