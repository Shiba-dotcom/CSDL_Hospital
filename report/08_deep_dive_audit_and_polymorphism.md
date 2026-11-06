# CHƯƠNG 8: CHUYÊN SÂU — LỊCH SỬ CHỈNH SỬA, ĐA HÌNH KẾT QUẢ VÀ TỐI ƯU HIỆU NĂNG
## Chuẩn đầu ra 6 (P6): Phần chuyên sâu & Thực nghiệm (1.5 điểm)

---

## 8.1. CƠ CHẾ LỊCH SỬ CHỈNH SỬA (AUDIT TRAIL & TEMPORAL INTEGRITY)

### 8.1.1. Yêu cầu pháp lý và nghiệp vụ trong Y tế
Theo quy định của Bộ Y tế và tiêu chuẩn quốc tế ISO 15189 đối với phòng xét nghiệm y khoa:
1. Mọi kết quả cận lâm sàng một khi đã được kỹ thuật viên phê duyệt ban hành thì **tuyệt đối không được phép xóa vật lý (Hard Delete)** khỏi hệ thống.
2. Mọi thao tác đính chính, hiệu chuẩn lại máy phân tích hoặc cập nhật thông số sinh hóa bắt buộc phải lưu trữ:
   - Ai đã chỉnh sửa (Mã định danh kỹ thuật viên / Bác sĩ).
   - Thời gian chính xác đến mili-giây.
   - Lý do đính chính lâm sàng.
   - Trọn vẹn dữ liệu ảnh chụp (Snapshot) trước và sau khi chỉnh sửa.

### 8.1.2. Phân tích so sánh 3 phương án kiến trúc lưu vết lịch sử

| Tiêu chí | Phương án 1: Audit Table tập trung (JSONB) | Phương án 2: Shadow Tables (Bảng bóng song song) | Phương án 3: Temporal Tables (`valid_from` / `valid_to`) |
|---|---|---|---|
| **Cấu trúc lưu trữ** | Một bảng duy nhất `lich_su_chinh_sua` lưu snapshot `du_lieu_cu`, `du_lieu_moi` dạng `JSONB` | Mỗi bảng chính có một bảng phụ tương ứng (vd: `ket_qua_dinh_luong_history`) | Thêm 2 cột mốc thời gian vào chính bảng dữ liệu nghiệp vụ |
| **Độ phức tạp lược đồ** | **Rất thấp (Đơn giản, dễ bảo trì):** 1 bảng duy nhất đáp ứng cho toàn bộ CSDL | Cao: Gấp đôi số lượng bảng trong hệ thống | Trung bình: Thay đổi toàn bộ các câu lệnh `SELECT` (phải thêm điều kiện thời gian) |
| **Tính linh hoạt** | **Cực cao:** Bảng chính thay đổi thuộc tính, thêm bớt cột thì cơ chế Audit vẫn tự thích ứng không cần sửa DDL | Kém: Mỗi lần `ALTER TABLE` bảng chính đều phải sửa đổi bảng shadow song hành | Trung bình |
| **Hiệu năng truy vấn hiện tại** | **Tối ưu:** Bảng chính chỉ chứa dữ liệu phiên bản mới nhất, dung lượng nhỏ gọn | Tương tự phương án 1 | Kém: Bảng chính phình to nhanh chóng chứa cả dữ liệu cũ |
| **Quyết định lựa chọn** | **ĐƯỢC CHỌN (Phù hợp nhất với CSDL Bệnh viện)** | Dùng hỗ trợ nếu cần truy vấn shadow | Không chọn do phức tạp hóa truy vấn |

---

## 8.2. THIẾT KẾ ĐA HÌNH KẾT QUẢ XÉT NGHIỆM (POLYMORPHIC LAB RESULTS)

### 8.2.1. Thách thức mô hình hóa thực thể cận lâm sàng
Kết quả xét nghiệm y tế có sự phân hóa hình thái sâu sắc:
1. **Xét nghiệm Định lượng (Quantitative):** Sinh hóa, huyết học, nước tiểu $\rightarrow$ Dữ liệu là các con số thực (`NUMERIC`), đơn vị tính (`mmol/L`, `mg/dL`), và dải tham chiếu chuẩn $[Min, Max]$.
2. **Xét nghiệm Hình ảnh (Imaging):** X-quang, Siêu âm, CT-Scanner, MRI $\rightarrow$ Dữ liệu là đường dẫn tệp ảnh định dạng y khoa DICOM, kỹ thuật chụp và văn bản mô tả tổn thương.
3. **Xét nghiệm Định tính / Vi sinh (Qualitative):** Nuôi cấy vi khuẩn, kháng sinh đồ $\rightarrow$ Dữ liệu là kết luận định danh (`DUONG_TINH`, `AM_TINH`) và chủng loại vi khuẩn.

### 8.2.2. Giải pháp kiến trúc: Kế thừa bảng (Table Inheritance) trên PostgreSQL
Thay vì áp dụng mẫu thiết kế Single Table Inheritance (tất cả dồn vào một bảng lớn với hàng chục cột bị NULL) gây lãng phí bộ nhớ và vi phạm chuẩn 3NF, đề tài triển khai mô hình **Table Inheritance**:
- Lớp cha trừu tượng: `ket_qua_xet_nghiem`.
- 3 bảng con chuyên biệt hóa kế thừa: `ket_qua_dinh_luong`, `ket_qua_hinh_anh`, `ket_qua_dinh_tinh`.

**Ưu điểm vượt trội:**
- Mỗi bảng con chỉ lưu trữ các thuộc tính đặc thù của riêng mình, các ràng buộc toàn vẹn (`NOT NULL`, `CHECK`) được áp dụng độc lập và nghiêm ngặt.
- Khi cần truy vấn tổng thể toàn viện, câu lệnh quét trên bảng cha `ket_qua_xet_nghiem` sẽ tự động kích hoạt nút `Append` trong kế hoạch thực thi để quét cả 3 bảng con một cách liền mạch mà không cần viết câu lệnh `UNION`.

---

## 8.3. KẾT QUẢ THỰC NGHIỆM ĐO HIỆU NĂNG TRUY VẤN (EXPLAIN ANALYZE)

Nhóm tác giả đã tiến hành thực nghiệm đo kiểm hiệu năng trên CSDL thực tế PostgreSQL 16 chạy trên Docker container (`hospital_db_container`), so sánh giữa việc quét tuần tự (Sequential Scan) và quét qua chỉ mục (Indexed Scan).

### 8.3.1. Bảng tổng hợp số liệu đo kiểm

| Kịch bản Benchmark | Kỹ thuật tối ưu áp dụng | Thời gian quét tuần tự (ms) | Thời gian quét có chỉ mục (ms) | Tỷ lệ tăng tốc hiệu năng |
|---|---|:---:|:---:|:---:|
| **1. Định lượng Glucose máu** | Composite B-Tree Index `(ma_danh_muc_xn, gia_tri_do)` | 27.059 ms | **0.092 ms** | **Nhanh hơn 294.1 lần** |
| **2. Truy vết Audit JSONB** | GIN Index `USING GIN (du_lieu_moi)` | 1.511 ms | **0.039 ms** | **Nhanh hơn 38.7 lần** |
| **3. Lọc hồ sơ theo thời gian** | Partial B-Tree Index `WHERE is_deleted = FALSE` | 1.002 ms | **0.078 ms** | **Nhanh hơn 12.8 lần** |
| **4. Window Function (Q3)** | Quicksort in-memory (`work_mem = 36kB`) | — | **2.840 ms** | Không bị trào đĩa I/O |
| **5. Quét đa hình kế thừa** | Polymorphic Append Scan (568 bản ghi) | — | **0.938 ms** | Chi phí tối thiểu |

### 8.3.2. Đánh giá kiểm thử toàn vẹn hệ thống (Health Check)
Kết quả chạy script kiểm thử độc lập [verify_end_to_end.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/tests/verify_end_to_end.sql) xác nhận:
1. **Dữ liệu phân bổ đúng chuẩn:**
   - 66 Người dùng $\rightarrow$ 60 Bệnh nhân, 6 Nhân viên y tế (3 Bác sĩ, 2 Kỹ thuật viên, 1 Tiếp đón).
   - 249 Hồ sơ khám bệnh ngoại trú.
   - 205 Phiếu chỉ định cận lâm sàng $\rightarrow$ 568 Kết quả xét nghiệm (363 định lượng, 125 hình ảnh, 80 vi sinh).
   - 185 Đơn thuốc $\rightarrow$ 460 Chi tiết dòng thuốc.
2. **Tính toàn vẹn tham chiếu:**
   - Số hồ sơ mồ côi bệnh nhân: **0**.
   - Số phiếu xét nghiệm mồ côi hồ sơ: **0**.
   - Số kết quả xét nghiệm mồ côi phiếu: **0**.
   - Số dòng thuốc mồ côi đơn thuốc: **0**.
3. **An toàn dữ liệu:**
   - 11/11 Triggers hoạt động chính xác (tự động tính BMI, ghi nhận Audit Trail, ngăn chặn hard delete, và hệ thống CDSS cảnh báo dị ứng thuốc).

