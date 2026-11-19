# CHƯƠNG 10: KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN ĐỀ TÀI
## Phần 8 (P8): Đánh giá tổng kết & Triển vọng tương lai

---

## 10.1. TỔNG KẾT KẾT QUẢ ĐẠT ĐƯỢC
Sau quá trình 12 tuần nghiên cứu, thiết kế và hiện thực hóa đề tài **"Thiết kế CSDL hồ sơ khám bệnh và kết quả xét nghiệm có lịch sử chỉnh sửa"**, đồ án đã hoàn thành xuất sắc toàn bộ các mục tiêu đặt ra với các kết quả cụ thể:

### 1. Về mặt phân tích và thiết kế quan niệm (Giai đoạn 1 — Tuần 1 đến 3)
- Đã đặc tả trọn vẹn quy trình khám ngoại trú tiêu chuẩn, xác định rõ ranh giới nghiệp vụ (phục vụ đối tượng khám thông thường, tách biệt sự phức tạp của chế độ bảo hiểm y tế).
- Xây dựng mô hình thực thể kết hợp mở rộng (**Enhanced Entity-Relationship - EER**) chuẩn hóa với 18 thực thể, thể hiện tường minh:
  - Chuyên biệt hóa chồng lặp (**Overlapping `(o,t)`**) đối với thực thể `Nguoi` thành `BenhNhan` và `NhanVienYTe` (cho phép bác sĩ/nhân viên y tế vừa là người khám bệnh vừa có thể là bệnh nhân).
  - Chuyên biệt hóa rời rạc (**Disjoint `(d,t)`**) đối với thực thể `KetQuaXetNghiem` thành 3 nhóm hình thái độc lập: Định lượng, Hình ảnh và Vi sinh/Định tính.
- Hoàn thiện từ điển dữ liệu (Data Dictionary) chi tiết cho 18 bảng với đầy đủ kiểu dữ liệu, miền giá trị, Domain và Enum.

### 2. Về mặt cơ sở toán học và chuẩn hóa dữ liệu (Giai đoạn 2 — Tuần 4 đến 5)
- Xác định hệ 42 phụ thuộc hàm ($F$), tính toán bao đóng tập thuộc tính và tìm kiếm khóa ứng viên tối tiểu.
- Chứng minh toán học đưa 100% các bảng quan hệ đạt dạng chuẩn **BCNF** (hoặc chuẩn 3NF có kiểm soát đối với bảng chứa thuộc tính dẫn xuất $BMI$ để tối ưu hiệu năng đọc).
- Chứng minh tính bảo toàn thông tin (**Lossless Join Decomposition**) dựa trên định lý Heath và bảo toàn tập phụ thuộc hàm.
- Phân tích phụ thuộc đa trị (**MVD**) và chứng minh đạt dạng chuẩn **4NF** cho các thuộc tính đa trị (mảng số điện thoại `so_dien_thoai TEXT[]`).

### 3. Về mặt hiện thực hóa CSDL và 12 truy vấn SQL Nâng cao (Giai đoạn 3 — Tuần 6 đến 8)
- Triển khai toàn bộ CSDL trên hệ quản trị **PostgreSQL 16** chạy môi trường Docker, phân tách DDL theo từng tầng (Types, Tables, Indexes, Triggers, Views).
- Nạp tập dữ liệu mẫu thực tế y khoa (`seed_data.sql`): 66 con người, 60 bệnh nhân, 240 hồ sơ khám, 200 phiếu chỉ định, 610 kết quả xét nghiệm (410 định lượng, 120 hình ảnh, 80 vi sinh), 180 đơn thuốc, 450 dòng thuốc *(tăng lên 243 hồ sơ, 202 phiếu chỉ định, 615 kết quả xét nghiệm, 183 đơn thuốc, 454 dòng thuốc sau khi chạy trọn bộ kịch bản kiểm thử)*.
- Thiết kế và kiểm thử thành công trọn bộ **12 truy vấn SQL nâng cao (Q1 đến Q12)**, bao phủ đầy đủ các kỹ thuật cao cấp:
  - Correlated Subquery & Window Functions (`DENSE_RANK`, `LAG`, `OVER PARTITION`).
  - CTE Đệ quy (`WITH RECURSIVE`) phân tích lộ trình điều trị liên tục.
  - Phép chia đại số quan hệ ($R \div S$) qua cấu trúc `Double NOT EXISTS`.
  - Stored Procedure đóng gói chu trình khám trong 1 Transaction với dữ liệu `JSONB`.
  - Dynamic SQL (`EXECUTE FORMAT`) phân tích báo cáo đa chiều.
  - Stored Table Function tìm kiếm bệnh nhân thông minh đa tiêu chí.
  - Truy vấn JSONB bóc tách dữ liệu lịch sử kiểm toán Audit Trail.
  - PIVOT / Crosstab xoay trục dữ liệu bằng mệnh đề ISO `COUNT(*) FILTER (WHERE ...)`.
  - Hệ thống Hỗ trợ Ra Quyết định Lâm sàng (**CDSS Trigger**) tự động chặn kê thuốc xung đột dị ứng.

### 4. Về mặt Cơ sở dữ liệu Hướng đối tượng và Thực nghiệm (Giai đoạn 4 & 5 — Tuần 9 đến 11)
- Xây dựng mô hình hướng đối tượng - quan hệ (**ORDBMS**) gồm 3 kiểu phức hợp (`dia_chi_type`, `chi_so_sinh_ton_type`, `bang_cap_type`), hệ phân cấp 8 lớp/bảng kế thừa (`INHERITS`), và 7 phương thức thành viên đóng gói nghiệp vụ.
- Hiện thực hóa 6 câu truy vấn **OQL chuẩn ODMG 3.0** ánh xạ trực tiếp sang PostgreSQL SQL.
- Thực nghiệm đo kiểm hiệu năng bằng **`EXPLAIN ANALYZE`** chứng minh Partial B-Tree Index lọc thời gian giảm **76.9%** trang bộ đệm đọc và nhanh hơn **1.34 lần**, `Bitmap Index Scan` loại bỏ hoàn toàn 290 dòng dư thừa ở bảng định lượng và kiểm chứng thành công GIN Index trên `JSONB`, còn Window Function (Q3) chạy hoàn toàn trong RAM (`35kB`) chỉ mất **0.840 ms**.
- Kiểm thử toàn diện 4 kịch bản giao dịch (**Transaction & Concurrency**): kiểm chứng tính nguyên tử All-or-Nothing khi có lỗi, cơ chế phòng chống Lost Update bằng Khóa bi quan (`SELECT FOR UPDATE`) và Khóa lạc quan (OCC qua `so_phien_ban`).

---

## 10.2. CÁC HẠN CHẾ HIỆN TẠI CỦA HỆ THỐNG
Mặc dù đã hoàn thành trọn vẹn các yêu cầu học phần, hệ thống vẫn tồn tại một số hạn chế mang tính phạm vi:
1. **Phạm vi bảo hiểm y tế:** Do giới hạn nghiên cứu của đề tài tập trung chuyên sâu vào hồ sơ bệnh án và lịch sử xét nghiệm, hệ thống chưa mô hình hóa danh mục đồng chi trả và cổng giám định Bảo hiểm Xã hội Việt Nam (BHYT).
2. **Lưu trữ dữ liệu nhị phân dung lượng lớn:** Hiện tại các kết quả chẩn đoán hình ảnh mới chỉ lưu trữ đường dẫn tệp (`duong_dan_tep_anh`), chưa tích hợp trực tiếp máy chủ lưu trữ hình ảnh chuyên dụng chuẩn PACS/DICOM (như Orthanc hoặc dcm4chee).
3. **Giao diện người dùng:** Hệ thống mới hoàn thiện tầng cơ sở dữ liệu và API Stored Procedures/Functions trên PostgreSQL, chưa phát triển ứng dụng Web/Mobile frontend hoàn chỉnh.

---

## 10.3. HƯỚNG PHÁT TRIỂN TRONG TƯƠNG LAI
Để phát triển đề tài thành một sản phẩm Bệnh viện điện tử (HIS) thương mại hoàn chỉnh, các hướng mở rộng tiếp theo bao gồm:
1. **Tích hợp tiêu chuẩn y tế quốc tế HL7 / FHIR (Fast Healthcare Interoperability Resources):**
   - Xây dựng RESTful API chuẩn FHIR Release 4 trên nền tảng các hàm JSONB sẵn có của PostgreSQL để liên thông hồ sơ bệnh án giữa các bệnh viện tuyến tỉnh và tuyến trung ương.
2. **Nâng cấp máy chủ PACS/DICOM và AI hỗ trợ chẩn đoán hình ảnh:**
   - Kết nối hệ thống với máy chủ PACS mã nguồn mở để truyền nhận trực tiếp hình ảnh X-quang, CT, MRI từ các thiết bị chụp chiếu y tế.
   - Ứng dụng mô hình Deep Learning (CNN) phân tích tự động tổn thương phổi trên ảnh X-quang lồng ngực và gợi ý chẩn đoán sơ bộ cho bác sĩ.
3. **Mở rộng kiến trúc phân tán (Database Sharding & Read-Replicas):**
   - Khi quy mô bệnh viện lên đến hàng triệu lượt khám mỗi năm, áp dụng phân vùng dữ liệu theo thời gian (**Declarative Table Partitioning**) trên các bảng `ho_so_kham_benh` và `ket_qua_xet_nghiem`.
   - Thiết lập cụm máy chủ PostgreSQL Streaming Replication (1 Primary - nhiều Standby) tách biệt hoàn toàn giữa lưu lượng ghi (Write) tại phòng khám và lưu lượng đọc (Read) cho các báo cáo phân tích quản lý.

