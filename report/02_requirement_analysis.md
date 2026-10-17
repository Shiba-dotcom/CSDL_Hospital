# PHẦN 2: PHÂN TÍCH YÊU CẦU HỆ THỐNG

---

## 2.1. Phân tích Yêu cầu Chức năng (Functional Requirements)

Dựa trên quy trình nghiệp vụ khám chữa bệnh ngoại trú thông thường và tính chất đặc thù của dữ liệu y tế, hệ thống cơ sở dữ liệu được phân chia thành 5 phân hệ chức năng chính:

```
+-----------------------------------------------------------------------------------+
|                        HỆ THỐNG CSDL KHÁM BỆNH & XÉT NGHIỆM                       |
+-------------------+--------------------+--------------------+---------------------+
| 1. Quản lý Hồ sơ  | 2. Khám lâm sàng   | 3. Quản lý Xét     | 4. Quản lý Kê đơn   |
|    Bệnh nhân      |    & Hồ sơ bệnh án |    nghiệm đa hình  |    & Danh mục thuốc |
+-------------------+--------------------+--------------------+---------------------+
|                  5. Phân hệ Giám sát & Lịch sử Chỉnh sửa (Audit Trail)            |
+-----------------------------------------------------------------------------------+
```

### 2.1.1. Phân hệ Tiếp nhận & Quản lý Hồ sơ Bệnh nhân (FR-01)
- **FR-01.1 Đăng ký & Định danh**: Cho phép tiếp nhận thông tin bệnh nhân mới, cấp mã định danh duy nhất (`ma_benh_nhan`), ghi nhận nhân khẩu học, nhóm máu, tiền sử dị ứng, tiền sử bệnh mãn tính và danh sách số điện thoại liên hệ (hỗ trợ thuộc tính đa trị).
- **FR-01.2 Tra cứu tiền sử**: Cung cấp khả năng tìm kiếm nhanh bệnh nhân theo CCCD, họ tên, số điện thoại; trích xuất toàn bộ lịch sử các đợt khám bệnh và xét nghiệm trong quá khứ.
- **FR-01.3 Phân luồng tiếp nhận**: Tạo lượt khám mới, gán vào phòng khám chuyên khoa cụ thể và cấp số thứ tự khám trong ngày.

### 2.1.2. Phân hệ Khám lâm sàng & Hồ sơ Bệnh án (FR-02)
- **FR-02.1 Ghi nhận chỉ số sinh tồn**: Lưu trữ các thông số sinh lý ban đầu (huyết áp tâm thu/tâm trương, mạch, nhiệt độ, chiều cao, cân nặng); tự động tính toán chỉ số khối cơ thể (BMI).
- **FR-02.2 Chẩn đoán sơ bộ & Bệnh sử**: Ghi nhận lý do vào viện, bệnh sử hiện tại, kết quả khám từng cơ quan và chẩn đoán sơ bộ của bác sĩ điều trị.
- **FR-02.3 Chẩn đoán xác định**: Sau khi có kết quả cận lâm sàng, bác sĩ cập nhật chẩn đoán xác định, tiên lượng và lời dặn chế độ sinh hoạt/tái khám.

### 2.1.3. Phân hệ Cận lâm sàng & Kết quả Xét nghiệm Đa hình (FR-03)
- **FR-03.1 Chỉ định cận lâm sàng**: Bác sĩ lập phiếu chỉ định gồm một hoặc nhiều dịch vụ xét nghiệm, chẩn đoán hình ảnh từ danh mục kỹ thuật y tế.
- **FR-03.2 Nhập kết quả định lượng (Sinh hóa / Huyết học)**: Lưu trữ giá trị số đo được, đơn vị tính, khoảng tham chiếu sinh lý (min–max); tự động so sánh và gắn nhãn cảnh báo (Bình thường / Thấp / Cao / Nguy hiểm).
- **FR-03.3 Nhập kết quả chẩn đoán hình ảnh**: Lưu trữ đường dẫn tệp hình ảnh/chụp chiếu (X-quang, CT, MRI, Siêu âm), kỹ thuật chụp, mô tả tổn thương chi tiết và kết luận hình ảnh của bác sĩ chuyên khoa chẩn đoán hình ảnh.
- **FR-03.4 Nhập kết quả định tính / Vi sinh**: Lưu trữ kết quả định tính (Âm tính / Dương tính), định danh chủng vi khuẩn phân lập và danh sách các kháng sinh nhạy cảm/kháng thuốc.

### 2.1.4. Phân hệ Kê đơn & Quản lý Dược (FR-04)
- **FR-04.1 Kê đơn thuốc**: Bác sĩ chọn thuốc từ danh mục hoạt chất/biệt dược sẵn có, quy định liều dùng, đường dùng, thời điểm dùng, số ngày dùng và tổng số lượng thuốc cấp phát.
- **FR-04.2 Ràng buộc an toàn**: Đảm bảo thuốc kê đơn phải tồn tại trong danh mục thuốc được phép lưu hành; số lượng thuốc phải là số nguyên dương $> 0$.

### 2.1.5. Phân hệ Giám sát & Lịch sử Chỉnh sửa (Audit Trail) (FR-05)
- **FR-05.1 Tự động lưu vết (Automatic Auditing)**: Mọi thao tác sửa đổi (`UPDATE`) trên kết quả xét nghiệm và hồ sơ khám bệnh phải được trigger tự động ghi lại toàn bộ trạng thái dữ liệu cũ (`OLD`) và mới (`NEW`) dưới dạng `JSONB`.
- **FR-05.2 Bắt buộc giải trình**: Mọi hành vi cập nhật kết quả đã phát hành bắt buộc phải nhập lý do đính chính và xác định danh tính nhân viên/bác sĩ thao tác.
- **FR-05.3 Quản lý phiên bản & Khóa lạc quan (Versioning & Optimistic Locking)**: Duy trì số phiên bản (`so_phien_ban`) tăng dần; dùng làm token kiểm soát tương tranh nhằm ngăn chặn lỗi mất cập nhật (Lost Update) khi có nhiều phiên đồng thời chỉnh sửa kết quả. Hỗ trợ truy vấn so sánh lịch sử biến động giữa các phiên bản (Diff View).
- **FR-05.4 Chống xóa cứng (Soft Delete)**: Tuyệt đối không hỗ trợ xóa vật lý (`HARD DELETE`); các trạng thái hủy được đánh dấu qua cờ logic `is_deleted = TRUE` kèm lý do.

---

## 2.2. Phân tích Yêu cầu Phi chức năng (Non-Functional Requirements)

### 2.2.1. Tính Toàn vẹn & Nhất quán Dữ liệu (Data Integrity & ACID)
- Đảm bảo 4 thuộc tính cốt lõi của giao dịch (Atomicity, Consistency, Isolation, Durability).
- Toàn bộ quy trình từ khám $\rightarrow$ chỉ định $\rightarrow$ kết quả $\rightarrow$ kê đơn phải được ràng buộc chặt chẽ thông qua các khóa ngoại (`FOREIGN KEY`) và các quy tắc toàn vẹn miền giá trị (`CHECK CONSTRAINT`).
- Xử lý xung đột truy cập đồng thời (Concurrency Control) thông qua cơ chế **Khóa lạc quan (Optimistic Locking)** trên cột `so_phien_ban` kết hợp với các mức cô lập giao dịch phù hợp (Read Committed, Repeatable Read, Serializable).

### 2.2.2. Khả năng Mở rộng & Tái cấu trúc (Extensibility & Object-Relational)
- Thiết kế mô hình dữ liệu có khả năng dễ dàng bổ sung các loại hình xét nghiệm mới (ví dụ: giải trình tự gen, xét nghiệm miễn dịch huỳnh quang) mà không làm phá vỡ lược đồ bảng hiện hữu.
- Tận dụng sức mạnh của PostgreSQL Object-Relational: Table Inheritance, Composite Types, Array data types và Function methods.

### 2.2.3. Hiệu năng & Tối ưu hóa Truy vấn (Performance)
- Hệ số phản hồi của các truy vấn tra cứu lịch sử bệnh án và kết quả xét nghiệm $< 200\text{ms}$ trên tập dữ liệu mẫu.
- Thiết lập chỉ mục (Index) thông minh: B-tree Index trên các khóa ngoại và cột tìm kiếm thường xuyên; GIN Index trên các trường lưu trữ mảng (`TEXT[]`) và `JSONB` của lịch sử chỉnh sửa.

### 2.2.4. Tính Pháp lý & Bảo mật Y tế (Security & Auditability)
- Không thể chối bỏ (Non-repudiation): Mọi dữ liệu sửa đổi đều được gán nhãn thời gian thực (`CURRENT_TIMESTAMP`) và định danh người thực hiện.
- Nhật ký kiểm toán (Audit Log) chỉ cho phép thao tác ghi (`APPEND-ONLY`), ngăn chặn tuyệt đối mọi hành vi sửa đổi hoặc xóa nhật ký kiểm toán.

---

## 2.3. Ma trận Phân quyền Tác nhân (Role-Based Access Control - RBAC)

| Thực thể / Chức năng | Nhân viên Tiếp nhận | Bác sĩ Khám bệnh | Kỹ thuật viên XN | Quản trị viên (Admin) |
|---|:---:|:---:|:---:|:---:|
| **Hồ sơ Bệnh nhân (`BenhNhan`)** | Tạo / Đọc / Sửa | Đọc | Đọc | Toàn quyền |
| **Hồ sơ Khám (`HoSoKhamBenh`)** | Đọc | Tạo / Sửa (chẩn đoán) | Đọc | Toàn quyền |
| **Phiếu Chỉ định XN (`PhieuChiDinhXN`)**| Không có quyền | Tạo / Hủy | Đọc / Cập nhật trạng thái | Toàn quyền |
| **Kết quả Xét nghiệm (`KetQuaXetNghiem`)**| Không có quyền | Đọc | Tạo / Sửa (kèm lý do) | Toàn quyền |
| **Đơn thuốc (`DonThuoc`, `ChiTietDonThuoc`)**| Không có quyền | Tạo / Sửa | Không có quyền | Toàn quyền |
| **Lịch sử Chỉnh sửa (`LichSuChinhSua`)**| Không có quyền | Chỉ Đọc vết | Chỉ Đọc vết | Chỉ Đọc (Không được xóa) |

