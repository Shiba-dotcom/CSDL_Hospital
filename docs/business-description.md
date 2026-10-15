# 🏥 TÀI LIỆU ĐẶC TẢ NGHIỆP VỤ HỆ THỐNG CƠ SỞ DỮ LIỆU
## Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
*(Áp dụng cho quy trình khám bệnh dịch vụ / thông thường - Không áp dụng BHYT)*

---

## 1. TỔNG QUAN HỆ THỐNG VÀ CÁC TÁC NHÂN (ACTORS)

### 1.1. Bối cảnh & Mục tiêu
Hệ thống được thiết kế nhằm quản lý hồ sơ y tế bệnh nhân từ khâu tiếp nhận, khám lâm sàng, thực hiện các kỹ thuật cận lâm sàng (xét nghiệm, chẩn đoán hình ảnh) cho đến chẩn đoán xác định và kê đơn thuốc. 

Điểm cốt lõi kỹ thuật của hệ thống là:
1. **Tính đa hình của dữ liệu xét nghiệm**: Hỗ trợ nhiều dạng dữ liệu kết quả khác nhau (chỉ số sinh hóa định lượng, mô tả vi sinh định tính, hình ảnh nội soi / X-quang).
2. **Tính toàn vẹn và minh bạch qua Lịch sử chỉnh sửa (Audit Trail & Versioning)**: Mọi thao tác chỉnh sửa hồ sơ bệnh án hoặc đính chính kết quả xét nghiệm đều phải được lưu vết tự động, lưu giữ dữ liệu gốc, người thực hiện, thời gian và bắt buộc phải có lý do điều chỉnh.

### 1.2. Các tác nhân tham gia hệ thống
- **Bệnh nhân (Patient)**: Người đến khám chữa bệnh, được cấp một mã bệnh nhân duy nhất (`ma_benh_nhan`) theo dõi suốt đời.
- **Nhân viên tiếp nhận (Receptionist)**: Tiếp đón bệnh nhân, kiểm tra hoặc đăng ký thông tin cá nhân, tạo lượt tiếp nhận và chỉ định phòng khám lâm sàng ban đầu.
- **Bác sĩ khám bệnh (Doctor)**: Khám lâm sàng, ghi nhận triệu chứng, chẩn đoán sơ bộ, ra chỉ định cận lâm sàng (xét nghiệm), đọc kết quả, đưa ra chẩn đoán xác định và kê đơn thuốc.
- **Kỹ thuật viên xét nghiệm / Chẩn đoán hình ảnh (Lab Technician)**: Tiếp nhận mẫu xét nghiệm hoặc thực hiện chụp chiếu hình ảnh, nhập kết quả xét nghiệm vào hệ thống, đính kèm kết luận hoặc hình ảnh liên quan.

---

## 2. QUY TRÌNH NGHIỆP VỤ CHI TIẾT (WORKFLOW)

Quy trình khám bệnh ngoại trú trải qua 6 giai đoạn tuần tự:

```
[1. Tiếp nhận & Đăng ký] 
          ↓
[2. Khám lâm sàng & Chẩn đoán sơ bộ]
          ↓
[3. Chỉ định cận lâm sàng / Xét nghiệm]
          ↓
[4. Thực hiện & Trả kết quả xét nghiệm (Đa hình)]
          ↓
[5. Chẩn đoán xác định & Kê đơn thuốc]
          ↓
[6. Kết thúc lượt khám / Lịch sử chỉnh sửa phát sinh]
```

### Bước 1: Tiếp nhận và phân luồng khám
1. Bệnh nhân đến bệnh viện xuất trình thông tin định danh (CCCD/Số điện thoại).
2. Nhân viên tiếp nhận tra cứu trên hệ thống:
   - Nếu là bệnh nhân mới: Thu thập thông tin cá nhân (Họ tên, ngày sinh, giới tính, số điện thoại liên lạc, địa chỉ, tiền sử bệnh án/dị ứng) và khởi tạo hồ sơ bệnh nhân.
   - Nếu là bệnh nhân cũ: Xác nhận thông tin và kiểm tra lịch sử thăm khám trước đó.
3. Nhân viên tạo một **Hồ sơ khám bệnh** mới cho ngày khám hiện tại, ghi nhận lý do khám và phân luồng bệnh nhân vào phòng khám chuyên khoa cụ thể.

### Bước 2: Khám lâm sàng và chẩn đoán sơ bộ
1. Bác sĩ chuyên khoa tại phòng khám gọi bệnh nhân vào khám.
2. Bác sĩ thực hiện đo các chỉ số sinh tồn cơ bản: Mạch, nhiệt độ, huyết áp, cân nặng, chiều cao (BMI).
3. Bác sĩ thăm khám, ghi nhận:
   - Triệu chứng lâm sàng / Lý do vào viện.
   - Bệnh sử và tiền sử gia đình.
   - Chẩn đoán sơ bộ ban đầu (ví dụ: Nghi ngờ viêm phổi cấp, Nghi ngờ rối loạn chuyển hóa lipid...).

### Bước 3: Chỉ định cận lâm sàng / xét nghiệm
1. Căn cứ vào chẩn đoán sơ bộ, bác sĩ tạo một hoặc nhiều **Phiếu chỉ định xét nghiệm**.
2. Trên mỗi phiếu có thể yêu cầu nhiều hạng mục xét nghiệm khác nhau thuộc các nhóm:
   - Huyết học, sinh hóa máu (Glucose, Acid Uric, Ure, Creatinine...).
   - Nước tiểu, dịch sinh học.
   - Chẩn đoán hình ảnh (X-quang ngực thẳng, Siêu âm ổ bụng, MRI...).
   - Vi sinh / Kháng sinh đồ (nếu nghi ngờ nhiễm khuẩn).
3. Trạng thái phiếu chỉ định ban đầu là `CHO_THUC_HIEN` (Chờ thực hiện).

### Bước 4: Tiếp nhận, thực hiện và nhập kết quả xét nghiệm (Tính Đa hình)
1. Bệnh nhân mang phiếu chỉ định đến khoa xét nghiệm / thăm dò chức năng tương ứng.
2. Kỹ thuật viên tiếp nhận mẫu hoặc tiến hành kỹ thuật chụp chiếu.
3. Kỹ thuật viên nhập kết quả vào hệ thống theo cấu trúc đa hình tương ứng:
   - **Xét nghiệm định lượng (Số học)**:
     - Giá trị đo được (`gia_tri_so` - Numeric).
     - Đơn vị đo (`don_vi` - mg/dL, mmol/L, g/L...).
     - Khoảng tham chiếu chuẩn (`chi_so_min`, `chi_so_max`).
     - Đánh giá cờ cảnh báo (`canh_bao`: Thấp, Bình thường, Cao, Nguy hiểm).
   - **Xét nghiệm định tính / Mô tả vi sinh (Văn bản)**:
     - Kết quả định tính (`ket_qua_dinh_tinh`: Âm tính, Dương tính, Nghi ngờ).
     - Mô tả chi tiết (`mo_ta_vi_sinh`: Tên chủng vi khuẩn phân lập, định danh mẫu).
     - Kết quả kháng sinh đồ (danh sách kháng sinh nhạy cảm/kháng).
   - **Chẩn đoán hình ảnh (Đa phương tiện)**:
     - Đường dẫn tệp ảnh / DICOM (`duong_dan_anh`).
     - Kỹ thuật chụp (`vung_chup`, `ky_thuat`).
     - Mô tả hình ảnh tổn thương (`mo_ta_ton_thuong`).
     - Kết luận hình ảnh (`ket_luan_hinh_anh`).
4. Kỹ thuật viên ký xác nhận và cập nhật trạng thái phiếu thành `DA_CO_KET_QUA`.

### Bước 5: Chẩn đoán xác định và Kê đơn thuốc
1. Bệnh nhân quay lại phòng khám ban đầu.
2. Bác sĩ xem xét kết quả cận lâm sàng kết hợp với triệu chứng lâm sàng:
   - Đưa ra **Chẩn đoán xác định** (kèm mã ICD-10 nếu có).
   - Lời dặn dò, chế độ ăn uống, ngày hẹn tái khám.
3. Nếu cần dùng thuốc, bác sĩ lập **Đơn thuốc**:
   - Chọn các loại thuốc từ danh mục thuốc sẵn có.
   - Ghi rõ liều dùng, đường dùng (uống, tiêm, bôi...), số lượng, thời điểm dùng (trước/sau ăn, sáng/tối), số ngày điều trị.
4. Bác sĩ xác nhận đóng phiên khám (`HOAN_THANH`).

---

## 3. CƠ CHẾ LƯU VẾT LỊCH SỬ CHỈNH SỬA (AUDIT TRAIL & REVISION CONTROL)

Trong lĩnh vực y tế, tính pháp lý của hồ sơ bệnh án là tối thượng. Quy chế quản lý chỉnh sửa được thiết kế nghiêm ngặt như sau:

### 3.1. Quy tắc bất biến (Immutability Rules)
1. **Tuyệt đối không sử dụng `HARD DELETE`** đối với hồ sơ khám bệnh, phiếu xét nghiệm, kết quả xét nghiệm và đơn thuốc.
2. Mọi thực thể chính đều có cờ `is_deleted BOOLEAN DEFAULT FALSE`. Khi có nhu cầu hủy hoặc xóa, hệ thống chỉ cập nhật cờ logic `is_deleted = TRUE` kèm ghi chú lý do hủy.
3. Dữ liệu kết quả xét nghiệm sau khi đã ký phát hành (`DA_CO_KET_QUA`) nếu cần sửa đổi thì không được ghi đè trực tiếp mà phải sinh ra một bản ghi lịch sử tương ứng trong bảng `LichSuChinhSua`.

### 3.2. Cơ chế theo dõi chỉnh sửa (Audit Trail Specification)
Mọi thao tác `UPDATE` trên bảng `KetQuaXetNghiem` và `HoSoKhamBenh` sẽ tự động kích hoạt trigger ghi nhận vào bảng `LichSuChinhSua` với các thông tin bắt buộc:
- `ma_lich_su`: Khóa chính tự sinh (BIGSERIAL).
- `ten_bang`: Tên bảng bị chỉnh sửa (`KetQuaXetNghiem`, `HoSoKhamBenh`...).
- `ma_ban_ghi`: Khóa chính của bản ghi bị chỉnh sửa.
- `so_phien_ban`: Phiên bản dữ liệu tại thời điểm sửa đổi.
- `loai_thao_tac`: `UPDATE` hoặc `SOFT_DELETE`.
- `du_lieu_cu`: Snapshot toàn bộ dữ liệu trước khi thay đổi (lưu dạng `JSONB`).
- `du_lieu_moi`: Snapshot toàn bộ dữ liệu sau khi thay đổi (lưu dạng `JSONB`).
- `nguoi_thuc_hien`: Mã nhân viên / Bác sĩ thực hiện hành vi sửa đổi.
- `thoi_gian_sua`: Thời điểm phát sinh thay đổi (mặc định `CURRENT_TIMESTAMP`).
- `ly_do_sua`: Chuỗi văn bản bắt buộc giải trình lý do (ví dụ: *"Hiệu chuẩn lại máy xét nghiệm sinh hóa số 02"*, *"Đính chính chẩn đoán sau khi hội chẩn"*).

### 3.3. Quản lý phiên bản & Khóa lạc quan (Revision Control & Optimistic Locking)
- Mỗi bản ghi `KetQuaXetNghiem` có trường `so_phien_ban` (Revision Number, bắt đầu từ 1).
- Khi có đính chính, `so_phien_ban` được tăng dần ($1 \rightarrow 2 \rightarrow 3$), và hệ thống ghi lại vết thay đổi.
- **Ứng dụng kiểm soát đồng thời (Optimistic Locking)**: Cột `so_phien_ban` được dùng làm phiên bản khóa. Khi hai người dùng cùng mở một kết quả xét nghiệm và bấm lưu cập nhật đồng thời, câu lệnh kiểm tra điều kiện `WHERE ma_ket_qua = ... AND so_phien_ban = ...` sẽ giúp ngăn chặn lỗi mất dữ liệu ghi đè (Lost Update) ở Tuần 11.

---

## 4. DANH SÁCH CÁC THỰC THỂ CỐT LÕI (CORE ENTITIES)

Hệ thống được mô hình hóa với 12 thực thể chính, sẵn sàng cho việc ánh xạ sang mô hình EER (có chuyên biệt hóa/tổng quát hóa):

| STT | Thực thể | Loại thực thể | Mô tả nghiệp vụ |
|---|---|---|---|
| 1 | **Nguoi (Person)** | Siêu lớp (Superclass) | Lưu trữ thuộc tính định danh duy nhất (CCCD, Họ tên, ngày sinh, giới tính, điện thoại[], địa chỉ). Là nguồn dữ liệu chuẩn duy nhất (Single Source of Truth). |
| 2 | **BenhNhan (Patient)** | Lớp con (Subclass) | Kế thừa **chồng lặp (Overlapping)** từ `Nguoi`. Bổ sung: Mã bệnh nhân, nhóm máu, tiền sử dị ứng, tiền sử bệnh án. |
| 3 | **NhanVienYTe (Staff)** | Lớp con (Subclass) | Kế thừa **chồng lặp (Overlapping)** từ `Nguoi` (Cho phép Bác sĩ/Nhân viên y tế khi đi khám bệnh vẫn dùng chung định danh `Nguoi` với vai trò `BenhNhan`, không bị nhân bản dữ liệu CCCD). Đại diện cán bộ y tế: Mã nhân viên, bằng cấp, chức vụ. |
| 4 | **KhoaPhong (Department/Room)** | Thực thể độc lập | Danh mục khoa (Khoa Khám Bệnh, Khoa Xét Nghiệm, Chẩn Đoán Hình Ảnh...) và các phòng khám/phòng xét nghiệm cụ thể. |
| 5 | **BacSi (Doctor)** | Lớp con chuyên biệt | Kế thừa từ `NhanVienYTe`. Thuộc một `KhoaPhong`, có chứng chỉ hành nghề, chuyên khoa khám. |
| 6 | **KyThuatVien (Technician)** | Lớp con chuyên biệt | Kế thừa từ `NhanVienYTe`. Phụ trách phòng xét nghiệm hoặc phòng chụp chiếu. |
| 7 | **HoSoKhamBenh (MedicalRecord)** | Thực thể liên kết | Lưu trữ thông tin một đợt khám: Bệnh nhân, bác sĩ khám, ngày giờ khám, chỉ số sinh tồn (mạch, nhiệt độ, huyết áp, BMI), lý do khám, chẩn đoán sơ bộ, chẩn đoán xác định, lời dặn. |
| 8 | **DanhMucXetNghiem (TestCatalog)**| Thực thể danh mục | Danh mục các loại xét nghiệm do bệnh viện cung cấp (Tên xét nghiệm, nhóm xét nghiệm, chi phí dịch vụ, thời gian trả kết quả dự kiến). |
| 9 | **PhieuChiDinhXetNghiem (TestOrder)**| Thực thể nghiệp vụ | Phiếu yêu cầu làm xét nghiệm do bác sĩ tạo ra trong đợt khám, bao gồm bác sĩ chỉ định, phòng thực hiện, trạng thái thực hiện. |
| 10 | **KetQuaXetNghiem (TestResult)**| Siêu lớp đa hình | Kết quả của một hạng mục xét nghiệm trên phiếu chỉ định. Có các lớp con: `KetQuaDinhLuong`, `KetQuaHinhAnh`, `KetQuaDinhTinh`. |
| 11 | **DonThuoc (Prescription)** | Thực thể nghiệp vụ | Đơn thuốc do bác sĩ kê sau khi có chẩn đoán xác định (gồm ngày kê, bác sĩ kê, lời dặn chung). |
| 12 | **ChiTietDonThuoc (PrescriptionItem)**| Thực thể yếu (Weak) | Từng loại thuốc trong đơn thuốc (Tên thuốc, liều lượng, số lượng, cách dùng, thời điểm uống). Phụ thuộc vào `DonThuoc`. |
| 13 | **Thuoc (Medication)** | Thực thể danh mục | Danh mục thuốc: Tên biệt dược, hoạt chất, dạng bào chế (viên, siro, ống tiêm), hàm lượng, đơn vị tính. |
| 14 | **LichSuChinhSua (AuditLog)** | Thực thể vết (Audit) | Lưu lại toàn bộ lịch sử biến động dữ liệu quan trọng phục vụ giám sát pháp lý và kỹ thuật kiểm thử transaction. |

---

## 5. CÁC RÀNG BUỘC NGHIỆP VỤ BẮT BUỘC (BUSINESS RULES)

1. **Ràng buộc thời gian**:
   - `ngay_sinh` của bệnh nhân / nhân viên phải nhỏ hơn hoặc bằng ngày hiện tại (`<= CURRENT_DATE`).
   - `thoi_gian_co_ket_qua` của xét nghiệm phải lớn hơn hoặc bằng `thoi_gian_chi_dinh`.
   - `ngay_hen_tai_kham` (nếu có) phải sau `ngay_kham`.
2. **Ràng buộc chỉ số sinh tồn**:
   - Huyết áp tâm thu > Huyết áp tâm trương ($60 \le HA_{tam\_truong} < HA_{tam\_thu} \le 250$).
   - Nhịp tim / mạch nằm trong khoảng hợp lý y khoa ($30 \le mach \le 220$ lần/phút).
   - Thân nhiệt nằm trong khoảng sinh lý sống ($34.0 \le nhiet\_do \le 43.0^\circ C$).
3. **Ràng buộc kê đơn**:
   - Một đợt khám chỉ được kê đơn thuốc sau khi đã có chẩn đoán (sơ bộ hoặc xác định).
   - Số lượng thuốc kê trong `ChiTietDonThuoc` phải là số nguyên dương $> 0$.
4. **Ràng buộc lịch sử chỉnh sửa**:
   - Khi cập nhật `KetQuaXetNghiem`, trường `ly_do_sua` không được rỗng hoặc NULL.
   - Bắt buộc phải xác định được `nguoi_thuc_hien` là ai thông qua khóa ngoại liên kết bảng nhân viên.

