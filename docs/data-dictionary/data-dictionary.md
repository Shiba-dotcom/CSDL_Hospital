# 📖 TỪ ĐIỂN DỮ LIỆU (DATA DICTIONARY)
## Hệ thống CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
*(Nền tảng: PostgreSQL 16+ | Chuẩn hóa mức logic và vật lý)*

---

## 1. DANH MỤC THỰC THỂ & BẢNG DỮ LIỆU

| STT | Tên bảng (Table Name) | Phân loại | Ý nghĩa nghiệp vụ |
|---|---|---|---|
| 1 | `nguoi` | Siêu lớp (Superclass) | Định danh nhân thân duy nhất (Single Source of Truth) cho mọi cá nhân. |
| 2 | `benh_nhan` | Lớp con (Subclass - Overlapping) | Thông tin bệnh nhân, tiền sử bệnh án và dị ứng. |
| 3 | `nhan_vien_y_te` | Lớp con (Subclass - Overlapping) | Thông tin chung về cán bộ, nhân viên y tế tại bệnh viện. |
| 4 | `bac_si` | Lớp con chuyên biệt (Disjoint) | Bác sĩ khám lâm sàng, có chứng chỉ hành nghề và chuyên khoa. |
| 5 | `ky_thuat_vien` | Lớp con chuyên biệt (Disjoint) | Kỹ thuật viên phụ trách xét nghiệm hoặc chẩn đoán hình ảnh. |
| 6 | `nhan_vien_tiep_nhan` | Lớp con chuyên biệt (Disjoint) | Nhân viên lễ tân tiếp đón, phân luồng bệnh nhân. |
| 7 | `khoa_phong` | Thực thể độc lập | Danh mục khoa, phòng khám, phòng xét nghiệm, quầy tiếp nhận. |
| 8 | `ho_so_kham_benh` | Thực thể nghiệp vụ | Đợt khám bệnh của bệnh nhân, chứa các chỉ số sinh tồn và chẩn đoán. |
| 9 | `danh_muc_xet_nghiem` | Thực thể danh mục | Danh mục kỹ thuật xét nghiệm do bệnh viện cung cấp. |
| 10 | `phieu_chi_dinh_xet_nghiem`| Thực thể nghiệp vụ | Phiếu yêu cầu xét nghiệm do bác sĩ chỉ định trong lượt khám. |
| 11 | `ket_qua_xet_nghiem` | Siêu lớp kết quả (Disjoint) | Kết quả xét nghiệm chung (quản lý phiên bản và cờ xóa logic). |
| 12 | `ket_qua_dinh_luong` | Lớp con kết quả (Inheritance) | Kết quả số học (sinh hóa, huyết học, nước tiểu) kèm ngưỡng tham chiếu. |
| 13 | `ket_qua_hinh_anh` | Lớp con kết quả (Inheritance) | Kết quả chẩn đoán hình ảnh (X-quang, CT, MRI, Siêu âm). |
| 14 | `ket_qua_dinh_tinh` | Lớp con kết quả (Inheritance) | Kết quả vi sinh, định danh vi khuẩn và kháng sinh đồ. |
| 15 | `thuoc` | Thực thể danh mục | Danh mục thuốc, biệt dược, hoạt chất và đơn giá. |
| 16 | `don_thuoc` | Thực thể nghiệp vụ | Đơn thuốc do bác sĩ kê sau khi có chẩn đoán xác định. |
| 17 | `chi_tiet_don_thuoc` | Thực thể yếu (Weak Entity) | Từng mục thuốc trong đơn (liều lượng, cách dùng, số ngày). |
| 18 | `lich_su_chinh_sua` | Thực thể giám sát (Audit Log) | Lưu vết toàn bộ biến động dữ liệu quan trọng dạng snapshot JSONB. |

---

## 2. CHI TIẾT TỪ ĐIỂN DỮ LIỆU TỪNG BẢNG

### 2.1. Bảng `nguoi` (Siêu lớp Con người)
*Mô tả: Lưu trữ thông tin nhân thân cơ bản. Mọi công dân chỉ xuất hiện đúng 1 lần tại bảng này.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_dinh_danh` | `CHAR(12)` | **PK** | NOT NULL | | `LENGTH(ma_dinh_danh) = 12` | Số Căn cước công dân (12 chữ số) |
| `ho_ten` | `VARCHAR(100)` | | NOT NULL | | `LENGTH(TRIM(ho_ten)) >= 2` | Họ và tên đầy đủ |
| `ngay_sinh` | `DATE` | | NOT NULL | | `ngay_sinh <= CURRENT_DATE` | Ngày tháng năm sinh |
| `gioi_tinh` | `VARCHAR(10)` | | NOT NULL | | `gioi_tinh IN ('NAM', 'NU', 'KHAC')` | Giới tính sinh học |
| `dia_chi` | `VARCHAR(255)` | | NULL | | | Địa chỉ cư trú thường trú |
| `so_dien_thoai` | `TEXT[]` | | NOT NULL | `'{}'` | | Mảng các số điện thoại liên lạc (Đa trị) |
| `ngay_tao` | `TIMESTAMP` | | NOT NULL | `CURRENT_TIMESTAMP` | | Thời điểm tạo bản ghi trên hệ thống |

---

### 2.2. Bảng `benh_nhan` (Lớp con Bệnh nhân)
*Mô tả: Kế thừa chồng lặp từ `nguoi`. Bác sĩ hay nhân viên y tế đi khám sẽ có bản ghi tại đây.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_benh_nhan` | `CHAR(10)` | **PK** | NOT NULL | | `ma_benh_nhan ~ '^BN-[0-9]{6}$'` | Mã bệnh nhân y tế (Format: `BN-XXXXXX`) |
| `ma_dinh_danh` | `CHAR(12)` | **FK, UK** | NOT NULL | | Tham chiếu `nguoi(ma_dinh_danh)` | Khóa ngoại nối sang bảng `nguoi` |
| `nhom_mau` | `VARCHAR(5)` | | NULL | | `nhom_mau IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-')` | Nhóm máu hệ ABO và Rh |
| `tien_su_di_ung` | `TEXT` | | NULL | | | Tiền sử dị ứng thuốc, thức ăn, hóa chất |
| `tien_su_benh` | `TEXT` | | NULL | | | Tiền sử bệnh lý mãn tính của bản thân/gia đình |

---

### 2.3. Bảng `nhan_vien_y_te` (Lớp con Cán bộ y tế)
*Mô tả: Kế thừa chồng lặp từ `nguoi`. Chứa thông tin quản lý nhân sự.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_nhan_vien` | `CHAR(8)` | **PK** | NOT NULL | | `ma_nhan_vien ~ '^NV-[0-9]{5}$'` | Mã cán bộ y tế (Format: `NV-XXXXX`) |
| `ma_dinh_danh` | `CHAR(12)` | **FK, UK** | NOT NULL | | Tham chiếu `nguoi(ma_dinh_danh)` | Khóa ngoại trỏ sang bảng `nguoi` |
| `ma_khoa_phong` | `VARCHAR(10)` | **FK** | NOT NULL | | Tham chiếu `khoa_phong(ma_khoa_phong)` | Khoa/phòng làm việc chính |
| `hoc_vi` | `VARCHAR(50)` | | NULL | | | Bác sĩ, Thạc sĩ, Tiến sĩ, Cử nhân... |
| `chuc_vu` | `VARCHAR(50)` | | NOT NULL | `'NHAN_VIEN'` | | Trưởng khoa, Phó khoa, Bác sĩ điều trị... |
| `trang_thai_lam_viec`| `VARCHAR(20)`| | NOT NULL | `'DANG_LAM_VIEC'` | `IN ('DANG_LAM_VIEC', 'NGHI_PHEP', 'DA_NGHI_VIEC')` | Tình trạng công tác |

---

### 2.4. Bảng `bac_si` (Lớp con chuyên biệt Bác sĩ)
*Mô tả: Kế thừa rời rạc từ `nhan_vien_y_te`.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_nhan_vien` | `CHAR(8)` | **PK, FK** | NOT NULL | | Tham chiếu `nhan_vien_y_te(ma_nhan_vien)` | Khóa chính đồng thời là khóa ngoại |
| `chung_chi_hanh_nghe`| `VARCHAR(30)`| **UK** | NOT NULL | | `LENGTH(TRIM(chung_chi_hanh_nghe)) > 0` | Số chứng chỉ hành nghề do Bộ/Sở Y tế cấp |
| `chuyen_khoa_chinh`| `VARCHAR(100)`| | NOT NULL | | | Nội tổng quát, Tim mạch, Tai Mũi Họng... |

---

### 2.5. Bảng `ky_thuat_vien` (Lớp con chuyên biệt Kỹ thuật viên)
*Mô tả: Kế thừa rời rạc từ `nhan_vien_y_te`.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_nhan_vien` | `CHAR(8)` | **PK, FK** | NOT NULL | | Tham chiếu `nhan_vien_y_te(ma_nhan_vien)` | Khóa chính đồng thời là khóa ngoại |
| `linh_vuc_chuyen_trach`| `VARCHAR(50)`| | NOT NULL | | `IN ('SINH_HOA', 'HUYET_HOC', 'VI_SINH', 'X_QUANG', 'MRI', 'SIEU_AM')` | Lĩnh vực phụ trách thực hiện kỹ thuật |
| `chung_chi_an_toan_buc_xa`| `VARCHAR(30)`| | NULL | | | Bắt buộc đối với KTV X-quang/CT Scanner |

---

### 2.6. Bảng `nhan_vien_tiep_nhan` (Lớp con chuyên biệt Nhân viên tiếp nhận)
*Mô tả: Kế thừa rời rạc từ `nhan_vien_y_te`.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_nhan_vien` | `CHAR(8)` | **PK, FK** | NOT NULL | | Tham chiếu `nhan_vien_y_te(ma_nhan_vien)` | Khóa chính đồng thời là khóa ngoại |
| `quay_tiep_nhan` | `VARCHAR(20)`| | NOT NULL | | | Tên quầy tiếp đón phục vụ (Quầy 1, Quầy 2...) |

---

### 2.7. Bảng `khoa_phong` (Danh mục Khoa Phòng)
*Mô tả: Danh mục đơn vị tổ chức, phòng khám, phòng xét nghiệm.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_khoa_phong` | `VARCHAR(10)` | **PK** | NOT NULL | | `ma_khoa_phong ~ '^[A-Z0-9_]{3,10}$'` | Mã viết tắt (VD: `K_KHAM`, `P_101`, `XN_SH`) |
| `ten_khoa_phong`| `VARCHAR(100)`| | NOT NULL | | `LENGTH(TRIM(ten_khoa_phong)) >= 3` | Tên phòng ban hoặc phòng khám |
| `loai_phong` | `VARCHAR(30)` | | NOT NULL | | `IN ('KHOA_CHUYEN_MON', 'PHONG_KHAM_LAMSANG', 'PHONG_XET_NGHIEM', 'PHONG_CHUP_CHIEU', 'QUAY_TIEP_DON')` | Phân loại chức năng phòng |
| `vi_tri_tang` | `VARCHAR(20)` | | NULL | | | Vị trí: Tầng 1 Tòa A, Tầng 2 Tòa B... |

---

### 2.8. Bảng `ho_so_kham_benh` (Hồ sơ Khám bệnh)
*Mô tả: Bản ghi trung tâm lưu trữ diễn biến một đợt khám lâm sàng của bệnh nhân.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_ho_so` | `BIGSERIAL` | **PK** | NOT NULL | | | Khóa chính tự tăng |
| `ma_benh_nhan` | `CHAR(10)` | **FK** | NOT NULL | | Tham chiếu `benh_nhan(ma_benh_nhan)` | Bệnh nhân được khám |
| `ma_bac_si_kham`| `CHAR(8)` | **FK** | NOT NULL | | Tham chiếu `bac_si(ma_nhan_vien)` | Bác sĩ phụ trách lượt khám |
| `ma_phong_kham` | `VARCHAR(10)` | **FK** | NOT NULL | | Tham chiếu `khoa_phong(ma_khoa_phong)` | Phòng khám lâm sàng diễn ra đợt khám |
| `thoi_gian_tiep_nhan`| `TIMESTAMP`| | NOT NULL | `CURRENT_TIMESTAMP` | | Thời điểm đăng ký tiếp nhận |
| `thoi_gian_kham`| `TIMESTAMP`| | NULL | | `thoi_gian_kham >= thoi_gian_tiep_nhan` | Thời điểm bác sĩ bắt đầu thăm khám |
| `mach` | `INTEGER` | | NULL | | `mach BETWEEN 30 AND 220` | Nhịp mạch (lần/phút) |
| `nhiet_do` | `NUMERIC(3,1)`| | NULL | | `nhiet_do BETWEEN 34.0 AND 43.0` | Thân nhiệt (°C) |
| `huyet_ap_tam_thu` | `INTEGER` | | NULL | | `huyet_ap_tam_thu BETWEEN 60 AND 250` | Huyết áp tâm thu (mmHg) |
| `huyet_ap_tam_truong`| `INTEGER` | | NULL | | `huyet_ap_tam_truong >= 40 AND huyet_ap_tam_truong < huyet_ap_tam_thu` | Huyết áp tâm trương (mmHg) |
| `chieu_cao` | `NUMERIC(4,1)`| | NULL | | `chieu_cao BETWEEN 40.0 AND 250.0` | Chiều cao (cm) |
| `can_nang` | `NUMERIC(4,1)`| | NULL | | `can_nang BETWEEN 2.0 AND 300.0` | Cân nặng (kg) |
| `chi_so_bmi` | `NUMERIC(4,2)`| | NULL | | Dẫn xuất: `can_nang / ((chieu_cao/100)^2)` | Chỉ số khối cơ thể (BMI) |
| `ly_do_kham` | `TEXT` | | NOT NULL | | `LENGTH(TRIM(ly_do_kham)) > 0` | Triệu chứng khó chịu khiến bệnh nhân đi khám |
| `chan_doan_so_bo`| `TEXT` | | NULL | | | Nhận định ban đầu của bác sĩ |
| `chan_doan_xac_dinh`| `TEXT` | | NULL | | | Kết luận bệnh lý cuối cùng sau cận lâm sàng |
| `loi_dan_bac_si`| `TEXT` | | NULL | | | Chế độ ăn uống, tập luyện, dặn dò y lệnh |
| `ngay_hen_tai_kham`| `DATE` | | NULL | | `ngay_hen_tai_kham > DATE(thoi_gian_tiep_nhan)` | Lịch hẹn tái khám (nếu có) |
| `trang_thai_kham`| `VARCHAR(20)`| | NOT NULL | `'CHO_KHAM'` | `IN ('CHO_KHAM', 'DANG_KHAM', 'CHO_KET_QUA_XN', 'HOAN_THANH', 'DA_HUY')` | Tiến độ quy trình khám |
| `is_deleted` | `BOOLEAN` | | NOT NULL | `FALSE` | | Cờ xóa logic (Soft Delete) |

---

### 2.9. Bảng `danh_muc_xet_nghiem` (Danh mục Dịch vụ Xét nghiệm)
*Mô tả: Bảng tra cứu các kỹ thuật cận lâm sàng mà bệnh viện thực hiện.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_danh_muc_xn`| `VARCHAR(15)` | **PK** | NOT NULL | | `ma_danh_muc_xn ~ '^[A-Z0-9_]{3,15}$'` | Mã xét nghiệm (VD: `GLUCOSE`, `XQ_NGUC`) |
| `ten_xet_nghiem`| `VARCHAR(150)`| | NOT NULL | | | Tên gọi chuẩn y khoa |
| `nhom_xet_nghiem`| `VARCHAR(50)` | | NOT NULL | | `IN ('SINH_HOA', 'HUYET_HOC', 'VI_SINH', 'CHIEU_CHUP', 'THAM_DO_CN')` | Phân nhóm chuyên môn |
| `hinh_thai_ket_qua`| `VARCHAR(20)`| | NOT NULL | | `IN ('DINH_LUONG', 'HINH_ANH', 'DINH_TINH')` | Quyết định bảng con kế thừa sẽ lưu kết quả |
| `don_gia_dich_vu`| `NUMERIC(12,2)`| | NOT NULL | | `don_gia_dich_vu >= 0` | Giá dịch vụ khám thông thường (VNĐ) |
| `thoi_gian_chuan_tra_kq`| `INTEGER`| | NOT NULL | `60` | `thoi_gian_chuan_tra_kq > 0` | Thời gian trả kết quả cam kết (phút) |

---

### 2.10. Bảng `phieu_chi_dinh_xet_nghiem` (Phiếu Chỉ định Xét nghiệm)
*Mô tả: Gom nhóm các yêu cầu xét nghiệm do bác sĩ tạo ra trong đợt khám.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_phieu_chi_dinh`| `BIGSERIAL` | **PK** | NOT NULL | | | Khóa chính tự tăng |
| `ma_ho_so` | `BIGINT` | **FK** | NOT NULL | | Tham chiếu `ho_so_kham_benh(ma_ho_so)` | Thuộc về hồ sơ khám bệnh nào |
| `ma_bac_si_chi_dinh`| `CHAR(8)` | **FK** | NOT NULL | | Tham chiếu `bac_si(ma_nhan_vien)` | Bác sĩ chỉ định |
| `thoi_gian_chi_dinh`| `TIMESTAMP`| | NOT NULL | `CURRENT_TIMESTAMP` | | Thời điểm ra y lệnh xét nghiệm |
| `trang_thai_phieu`| `VARCHAR(20)`| | NOT NULL | `'CHO_THUC_HIEN'` | `IN ('CHO_THUC_HIEN', 'DANG_THUC_HIEN', 'DA_CO_KET_QUA', 'DA_HUY')` | Trạng thái xử lý của phiếu |
| `ghi_chu_lam_sang`| `TEXT` | | NULL | | | Lưu ý của bác sĩ cho KTV (VD: Bệnh nhân sốt cao, nghi u phổi) |
| `is_deleted` | `BOOLEAN` | | NOT NULL | `FALSE` | | Cờ xóa logic |

---

### 2.11. Bảng `ket_qua_xet_nghiem` (Siêu lớp Kết quả xét nghiệm)
*Mô tả: Bảng cha chứa các trường chung, hỗ trợ kế thừa hướng đối tượng, khóa lạc quan và lịch sử.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_ket_qua` | `BIGSERIAL` | **PK** | NOT NULL | | | Khóa chính tự tăng |
| `ma_phieu_chi_dinh`| `BIGINT` | **FK** | NOT NULL | | Tham chiếu `phieu_chi_dinh_xet_nghiem` | Phiếu chỉ định chứa kết quả này |
| `ma_danh_muc_xn`| `VARCHAR(15)` | **FK** | NOT NULL | | Tham chiếu `danh_muc_xet_nghiem` | Loại xét nghiệm được thực hiện |
| `ma_ktv_thuc_hien`| `CHAR(8)` | **FK** | NULL | | Tham chiếu `ky_thuat_vien(ma_nhan_vien)` | Kỹ thuật viên thao tác và ký nhận |
| `thoi_gian_tiep_nhan_mau`| `TIMESTAMP`| | NULL | | | Thời điểm nhận mẫu bệnh phẩm / nhận chụp |
| `thoi_gian_co_ket_qua`| `TIMESTAMP`| | NULL | | `thoi_gian_co_ket_qua >= thoi_gian_tiep_nhan_mau` | Thời điểm trả kết quả chính thức |
| `trang_thai_ket_qua`| `VARCHAR(20)`| | NOT NULL | `'CHO_KET_QUA'` | `IN ('CHO_KET_QUA', 'SO_BO', 'CHINH_THUC', 'DINH_CHINH')` | Trạng thái kết quả |
| `ket_luan_tong_quat`| `TEXT` | | NULL | | | Nhận định chung của KTV/Bác sĩ chuyên khoa |
| `so_phien_ban` | `INTEGER` | | NOT NULL | `1` | `so_phien_ban >= 1` | **Optimistic Locking Token** (Tăng dần khi sửa) |
| `is_deleted` | `BOOLEAN` | | NOT NULL | `FALSE` | | Cờ xóa logic (Soft Delete) |

---

### 2.12. Bảng `ket_qua_dinh_luong` (Kế thừa từ `ket_qua_xet_nghiem`)
*Mô tả: Kết quả dạng số, so sánh với khoảng tham chiếu.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| *(Các trường kế thừa)*| | | | | *(Thừa hưởng toàn bộ trường của `ket_qua_xet_nghiem`)* | |
| `gia_tri_do` | `NUMERIC(10,3)`| | NOT NULL | | | Giá trị số đo lường thực tế từ máy phân tích |
| `don_vi_tinh` | `VARCHAR(30)` | | NOT NULL | | | Đơn vị: `mmol/L`, `mg/dL`, `g/L`, `10^9/L`... |
| `chi_so_min_chuan`| `NUMERIC(10,3)`| | NOT NULL | | | Ngưỡng sinh lý dưới bình thường |
| `chi_so_max_chuan`| `NUMERIC(10,3)`| | NOT NULL | | `chi_so_max_chuan > chi_so_min_chuan` | Ngưỡng sinh lý trên bình thường |
| `muc_do_canh_bao`| `VARCHAR(20)`| | NOT NULL | `'BINH_THUONG'` | `IN ('BINH_THUONG', 'THAP', 'CAO', 'NGUY_HIEM')` | Hệ thống tự động so khớp gán nhãn |

---

### 2.13. Bảng `ket_qua_hinh_anh` (Kế thừa từ `ket_qua_xet_nghiem`)
*Mô tả: Kết quả chẩn đoán hình ảnh.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| *(Các trường kế thừa)*| | | | | *(Thừa hưởng toàn bộ trường của `ket_qua_xet_nghiem`)* | |
| `duong_dan_tep_anh`| `TEXT` | | NOT NULL | | `LENGTH(TRIM(duong_dan_tep_anh)) > 0` | URL hoặc đường dẫn file ảnh DICOM/JPG |
| `ky_thuat_chup` | `VARCHAR(100)`| | NOT NULL | | | Chụp thẳng, chụp nghiêng, cản quang... |
| `vung_khao_sat` | `VARCHAR(100)`| | NOT NULL | | | Lồng ngực, Sọ não, Ổ bụng tổng quát... |
| `mo_ta_ton_thuong`| `TEXT` | | NOT NULL | | | Mô tả hình ảnh giải phẫu học chi tiết |

---

### 2.14. Bảng `ket_qua_dinh_tinh` (Kế thừa từ `ket_qua_xet_nghiem`)
*Mô tả: Kết quả vi sinh, giải phẫu bệnh, định tính.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| *(Các trường kế thừa)*| | | | | *(Thừa hưởng toàn bộ trường của `ket_qua_xet_nghiem`)* | |
| `ket_qua_danh_gia`| `VARCHAR(20)`| | NOT NULL | | `IN ('AM_TINH', 'DUONG_TINH', 'NGHI_NGO')` | Kết luận định tính |
| `ten_chung_vi_khuan`| `VARCHAR(150)`| | NULL | | | Tên vi khuẩn/virus phân lập (nếu dương tính) |
| `mo_ta_vi_sinh` | `TEXT` | | NULL | | | Mô tả hình thái, khuẩn lạc, nhuộm Gram |
| `khang_sinh_nhay_cam`| `TEXT[]` | | NOT NULL | `'{}'` | | Mảng danh sách kháng sinh nhạy cảm (Đa trị) |

---

### 2.15. Bảng `thuoc` (Danh mục Thuốc)
*Mô tả: Danh mục thuốc được phép lưu hành và kê đơn.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_thuoc` | `VARCHAR(15)` | **PK** | NOT NULL | | `ma_thuoc ~ '^[A-Z0-9_]{3,15}$'` | Mã biệt dược / thuốc |
| `ten_thuoc` | `VARCHAR(150)`| | NOT NULL | | | Tên thương mại / biệt dược |
| `hoat_chat` | `VARCHAR(150)`| | NOT NULL | | | Hoạt chất chính (Paracetamol, Amoxicillin...) |
| `ham_luong` | `VARCHAR(50)` | | NOT NULL | | | Hàm lượng (500mg, 1g, 250mg/5ml...) |
| `dang_bao_che` | `VARCHAR(50)` | | NOT NULL | | | Viên nén, Viên nang, Siro, Hỗn dịch, Ống tiêm... |
| `don_vi_tinh` | `VARCHAR(20)` | | NOT NULL | | | Viên, Gói, Chai, Lọ, Ống... |
| `don_gia` | `NUMERIC(12,2)`| | NOT NULL | | `don_gia >= 0` | Đơn giá bán lẻ dịch vụ (VNĐ) |

---

### 2.16. Bảng `don_thuoc` (Đơn thuốc)
*Mô tả: Đơn thuốc chính do bác sĩ kê sau chẩn đoán xác định.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_don_thuoc` | `BIGSERIAL` | **PK** | NOT NULL | | | Khóa chính tự tăng |
| `ma_ho_so` | `BIGINT` | **FK, UK** | NOT NULL | | Tham chiếu `ho_so_kham_benh(ma_ho_so)` | Quan hệ 1-1 với hồ sơ khám bệnh |
| `ma_bac_si_ke` | `CHAR(8)` | **FK** | NOT NULL | | Tham chiếu `bac_si(ma_nhan_vien)` | Bác sĩ kê đơn |
| `ngay_ke_don` | `TIMESTAMP` | | NOT NULL | `CURRENT_TIMESTAMP` | | Thời điểm kê đơn |
| `loi_dan_chung` | `TEXT` | | NULL | | | Lưu ý chung (Uống nhiều nước, kiêng rượu bia) |
| `is_deleted` | `BOOLEAN` | | NOT NULL | `FALSE` | | Cờ xóa logic |

---

### 2.17. Bảng `chi_tiet_don_thuoc` (Thực thể yếu - Chi tiết dòng thuốc)
*Mô tả: Từng khoản thuốc trong đơn. Phụ thuộc định danh hoàn toàn vào `don_thuoc`.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_don_thuoc` | `BIGINT` | **PK (1/2), FK**| NOT NULL | | Tham chiếu `don_thuoc(ma_don_thuoc) ON DELETE CASCADE` | Khóa ngoại trỏ về đơn thuốc |
| `so_thu_tu_dong`| `INTEGER` | **PK (2/2)**| NOT NULL | | `so_thu_tu_dong > 0` | Khóa bộ phận (Discriminator): STT dòng thuốc |
| `ma_thuoc` | `VARCHAR(15)` | **FK** | NOT NULL | | Tham chiếu `thuoc(ma_thuoc)` | Thuốc được kê |
| `so_luong` | `INTEGER` | | NOT NULL | | `so_luong > 0` | Tổng số lượng cấp phát |
| `lieu_dung_moi_lan`| `VARCHAR(50)`| | NOT NULL | | | Liều mỗi lần (1 viên, 2 gói, 5ml...) |
| `so_lan_uong_ngay`| `INTEGER` | | NOT NULL | | `so_lan_uong_ngay BETWEEN 1 AND 6` | Số lần dùng trong ngày |
| `thoi_diem_uong`| `VARCHAR(100)`| | NOT NULL | | | Sau ăn no, Trước ăn 30 phút, Trước ngủ... |
| `so_ngay_dung` | `INTEGER` | | NOT NULL | | `so_ngay_dung > 0` | Số ngày điều trị theo đơn |

---

### 2.18. Bảng `lich_su_chinh_sua` (Audit Log - Nhật ký Kiểm toán)
*Mô tả: Bảng ghi vết tự động thông qua Trigger. Dữ liệu chỉ ghi thêm (APPEND-ONLY), cấm sửa xóa.*

| Tên cột | Kiểu dữ liệu | Khóa | Null? | Default | Ràng buộc kiểm tra (CHECK) | Diễn giải |
|---|---|:---:|:---:|---|---|---|
| `ma_lich_su` | `BIGSERIAL` | **PK** | NOT NULL | | | Khóa chính tự sinh |
| `ten_bang` | `VARCHAR(50)` | | NOT NULL | | `ten_bang IN ('ket_qua_xet_nghiem', 'ho_so_kham_benh', 'don_thuoc')` | Bảng phát sinh biến động dữ liệu |
| `ma_ban_ghi` | `VARCHAR(50)` | | NOT NULL | | | Khóa chính của bản ghi bị tác động |
| `so_phien_ban` | `INTEGER` | | NOT NULL | | `so_phien_ban >= 1` | Phiên bản tại thời điểm ghi vết |
| `loai_thao_tac` | `VARCHAR(20)` | | NOT NULL | | `loai_thao_tac IN ('INSERT', 'UPDATE', 'SOFT_DELETE')` | Hành động thực thi trên dữ liệu |
| `du_lieu_cu` | `JSONB` | | NULL | | | Snapshot toàn bộ dữ liệu trước khi thay đổi |
| `du_lieu_moi` | `JSONB` | | NOT NULL | | | Snapshot toàn bộ dữ liệu sau khi thay đổi |
| `ly_do_sua` | `TEXT` | | NOT NULL | | `LENGTH(TRIM(ly_do_sua)) >= 5` | Bắt buộc giải trình nguyên nhân chỉnh sửa |
| `nguoi_thuc_hien`| `CHAR(8)` | **FK** | NOT NULL | | Tham chiếu `nhan_vien_y_te(ma_nhan_vien)` | Cán bộ y tế thực hiện thao tác |
| `thoi_gian_sua` | `TIMESTAMP` | | NOT NULL | `CURRENT_TIMESTAMP` | | Dấu thời gian thực thi (Timestamp) |

