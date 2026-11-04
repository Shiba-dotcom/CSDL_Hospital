# PHẦN 5: THIẾT KẾ MỨC VẬT LÝ VÀ HIỆN THỰC HÓA CSDL (PHYSICAL DATABASE DESIGN)

---

## 5.1. Lựa chọn Hệ Quản trị Cơ sở Dữ liệu & Môi trường Triển khai

### 5.1.1. Lý do lựa chọn PostgreSQL 16+
Hệ thống quản lý hồ sơ khám bệnh và xét nghiệm y khoa đòi hỏi những năng lực kỹ thuật đặc thù mà các hệ RDBMS thuần túy khó đáp ứng trọn vẹn:
1. **Mô hình Quan hệ - Hướng đối tượng (Object-Relational DBMS)**: Hỗ trợ kế thừa bảng (`INHERITS`), kiểu dữ liệu phức hợp (`Composite Types`), mảng (`Array`), và kiểu dữ liệu JSON bán cấu trúc (`JSONB`).
2. **Khả năng lưu trữ và đánh chỉ mục phi quan hệ (GIN Indexing)**: Cho phép lập chỉ mục trên mảng đa trị và tài liệu `JSONB` với tốc độ tìm kiếm $O(\log N)$.
3. **Tuân thủ chuẩn ACID toàn diện và kiểm soát đa phiên bản (MVCC)**: Cung cấp đầy đủ các mức cô lập giao dịch từ *Read Committed*, *Repeatable Read* đến *Serializable* phục vụ quản lý tương tranh lâm sàng.

### 5.1.2. Môi trường đóng gói Container (Docker Containerization)
Hệ thống được cấu hình triển khai hoàn toàn thông qua Docker Compose:
- **Image:** `postgres:16-alpine` (nhẹ, bảo mật, tối ưu tài nguyên).
- **Cổng dịch vụ (Port Mapping):** `5433:5432` (ánh xạ cổng 5433 trên máy trạm để tránh xung đột với các phiên bản PostgreSQL khác).
- **Lưu trữ dữ liệu bền vững (Volume Persistence):** Sử dụng Named Volume `hospital_pgdata` đảm bảo dữ liệu không bị mất khi container khởi động lại.
- **Tự động hóa toàn diện:** Toàn bộ quá trình tạo cấu trúc bảng, chỉ mục, trigger, view và nạp dữ liệu mẫu được tích hợp thành kịch bản chạy duy nhất qua tệp `run_all.sql`.

---

## 5.2. Hiện thực hóa Kiểu Dữ liệu Nâng cao (Custom ENUMs, Domains & Arrays)

Để bảo đảm tính toàn vẹn dữ liệu ngay từ tầng vật lý, CSDL không dùng kiểu chuỗi tự do (`VARCHAR`) cho các trường có miền giá trị cố định:

### 5.2.1. Hệ thống Kiểu Liệt kê (ENUM Types)
- `gioi_tinh_enum`: `'NAM'`, `'NU'`, `'KHAC'`.
- `nhom_mau_enum`: `'A+'`, `'A-'`, `'B+'`, `'B-'`, `'AB+'`, `'AB-'`, `'O+'`, `'O-'`.
- `trang_thai_kham_enum`: `'CHO_KHAM'`, `'DANG_KHAM'`, `'CHO_KET_QUA_XN'`, `'HOAN_THANH'`, `'DA_HUY'`.
- `canh_bao_enum`: `'BINH_THUONG'`, `'THAP'`, `'CAO'`, `'NGUY_HIEM'`.
- `thao_tac_audit_enum`: `'INSERT'`, `'UPDATE'`, `'SOFT_DELETE'`.

### 5.2.2. Các Miền Giá trị Ràng buộc (User-Defined Domains)
- `cccd_domain`: Định nghĩa trên `CHAR(12)` với biểu thức chính quy `CHECK (VALUE ~ '^[0-9]{12}$')`.
- `ma_bn_domain`: Định nghĩa trên `VARCHAR(10)` với ràng buộc `CHECK (VALUE ~ '^BN-[0-9]{6,7}$')`.
- `ma_nv_domain`: Định nghĩa trên `CHAR(8)` với ràng buộc `CHECK (VALUE ~ '^NV-[0-9]{5}$')`.

### 5.2.3. Kiểu Mảng Nguyên tử (Array Data Types)
- Cột `so_dien_thoai TEXT[]` trong bảng `nguoi`: Cho phép một người lưu nhiều số điện thoại liên lạc trong 1 cột duy nhất mà vẫn đảm bảo tính nguyên tử 1NF.
- Cột `khang_sinh_nhay_cam TEXT[]` trong `ket_qua_dinh_tinh`: Lưu trữ danh sách các loại kháng sinh có tác dụng điều trị đối với chủng vi khuẩn phân lập được.

---

## 5.3. Thiết kế Bảng Hướng Đối tượng: Kế thừa Bảng (Table Inheritance)

Một trong những chuẩn đầu ra nâng cao của đồ án là ứng dụng mô hình Object-Relational của PostgreSQL. Phân hệ kết quả xét nghiệm được triển khai theo cấu trúc **Kế thừa bảng (`INHERITS`)**:

```
                       ket_qua_xet_nghiem (Bảng cha)
                      /            |             \
                     /             |              \
                    v              v               v
  ket_qua_dinh_luong      ket_qua_hinh_anh     ket_qua_dinh_tinh
  - gia_tri_do            - duong_dan_tep_anh  - ket_qua_danh_gia
  - don_vi_tinh           - ky_thuat_chup      - ten_chung_vi_khuan
  - chi_so_min_chuan      - vung_khao_sat      - khang_sinh_nhay_cam[]
  - chi_so_max_chuan      - mo_ta_ton_thuong
  - muc_do_canh_bao
```

- **Tính kế thừa thuộc tính:** Các bảng con tự động thừa hưởng toàn bộ các trường của bảng cha (`ma_ket_qua`, `ma_phieu_chi_dinh`, `ma_danh_muc_xn`, `ma_ktv_thuc_hien`, `thoi_gian_co_ket_qua`, `so_phien_ban`, `is_deleted`).
- **Khóa chính duy nhất toàn cục:** Sử dụng một Sequence chia sẻ chung `seq_ket_qua_xet_nghiem_id` cho toàn bộ các lớp con.
- **Tính đa hình trong truy vấn:** 
  - Truy vấn trên bảng cha `SELECT * FROM ket_qua_xet_nghiem` sẽ tự động quét và trả về kết quả của tất cả các bảng con.
  - Sử dụng từ khóa `ONLY` (`SELECT * FROM ONLY ket_qua_xet_nghiem`) nếu chỉ muốn lấy dữ liệu riêng của bảng cha.

---

## 5.4. Chiến lược Thiết kế Chỉ mục Vật lý (Physical Indexing Strategy)

Hệ thống kết hợp ba loại hình Index tối ưu theo từng mục đích truy xuất:

### 5.4.1. B-tree Index trên Khóa Ngoại & Cột Thời gian
Tất cả các cột khóa ngoại tham gia vào điều kiện kết nối (`JOIN`) đều được đánh chỉ mục B-tree nhằm triệt tiêu hiện tượng quét toàn bảng (Sequential Scan), chuyển đổi kế hoạch thực thi sang `Index Scan` hoặc `Bitmap Index Scan`:
- `idx_ho_so_benh_nhan`, `idx_ho_so_bac_si`, `idx_ho_so_phong`.
- `idx_kq_phieu`, `idx_kq_danhmuc`, `idx_kq_ktv`.
- `idx_ho_so_thoi_gian` (sắp xếp giảm dần `DESC` cho trang chủ danh sách bệnh nhân chờ khám).

### 5.4.2. Chỉ mục Bộ phận (Partial Indexes)
Trong môi trường khám bệnh thực tế, 99% các truy vấn nghiệp vụ hàng ngày chỉ thao tác trên các bản ghi đang hoạt động (`is_deleted = FALSE`). Do đó, các chỉ mục sau được thiết lập:
```sql
CREATE INDEX idx_ho_so_active 
ON ho_so_kham_benh (ma_benh_nhan, thoi_gian_tiep_nhan DESC) 
WHERE is_deleted = FALSE;
```
- **Lợi ích:** Kích thước của chỉ mục giảm đi đáng kể, nằm trọn trong RAM (Buffer Cache), tăng tốc độ tìm kiếm gấp nhiều lần và giảm chi phí bảo trì chỉ mục khi ghi chép.

### 5.4.3. Generalized Inverted Index (GIN Index) cho Mảng và JSONB
- **Chỉ mục GIN trên mảng điện thoại:** `CREATE INDEX idx_gin_nguoi_sdt ON nguoi USING GIN (so_dien_thoai);` $\rightarrow$ Cho phép tìm kiếm bệnh nhân theo số điện thoại với toán tử chứa mảng `@>` trong thời gian tức thì.
- **Chỉ mục GIN trên JSONB Audit Trail:** `CREATE INDEX idx_gin_audit_moi ON lich_su_chinh_sua USING GIN (du_lieu_moi);` $\rightarrow$ Hỗ trợ cơ quan điều tra/thanh tra y tế tìm kiếm bất kỳ thuộc tính nào bên trong snapshot JSONB mà không cần biết trước cấu trúc cố định.

---

## 5.5. Thiết kế Kiểm soát Toàn vẹn & Tự động hóa Audit Trail (Triggers)

### 5.5.1. Trigger Chống xóa cứng (Hard Delete Prevention)
- Hàm trigger `fn_prevent_hard_delete()` chặn đứng mọi lệnh `DELETE` phát ra từ ứng dụng đối với các bảng lâm sàng nhạy cảm (`ho_so_kham_benh`, `phieu_chi_dinh_xet_nghiem`, `ket_qua_xet_nghiem`).
- Bắt buộc nhà phát triển và người dùng phải thao tác qua cập nhật logic `is_deleted = TRUE`.

### 5.5.2. Trigger Tự động Lưu vết Lịch sử & Khóa Lạc quan
- Hàm trigger `fn_audit_ket_qua_xet_nghiem()` được gắn vào sự kiện `BEFORE UPDATE` trên bảng kết quả xét nghiệm.
- **Cơ chế hoạt động:**
  1. Tự động tăng `so_phien_ban = OLD.so_phien_ban + 1` và cập nhật trạng thái kết quả thành `'DINH_CHINH'`.
  2. Đọc ngữ cảnh phiên làm việc (`app.current_user_id` và `app.current_reason`).
  3. Đóng gói toàn bộ dòng dữ liệu trước và sau biến động thành chuỗi `to_jsonb(OLD)` và `to_jsonb(NEW)`.
  4. Chèn một dòng kiểm toán bất biến vào bảng `lich_su_chinh_sua`.
- Thủ tục lưu trữ `sp_cap_nhat_ket_qua_dinh_luong` cung cấp giao diện chuẩn để đính chính kết quả, bắt buộc cung cấp lý do y khoa $\ge 5$ ký tự và kiểm tra xung đột phiên bản Optimistic Lock.

---

## 5.6. Kết quả Thực nghiệm Triển khai và Nạp Dữ liệu Mẫu (Seed Data)

Hệ thống đã triển khai thành công bộ dữ liệu mẫu quy mô lớn mô phỏng hoạt động thực tế của một bệnh viện:

| Thực thể / Bảng | Số lượng bản ghi thực tế | Chuẩn đầu ra yêu cầu | Đánh giá |
|---|:---:|:---:|:---:|
| `khoa_phong` | 8 | Danh mục | Đạt |
| `danh_muc_xet_nghiem` | 10 | Danh mục | Đạt |
| `thuoc` | 15 | Danh mục | Đạt |
| `nguoi` | 66 | Nhân sự & Bệnh nhân | Đạt |
| `benh_nhan` | 60 | $\ge 50$ bệnh nhân | **Vượt chỉ tiêu** |
| `ho_so_kham_benh` | 240 | $\ge 200$ hồ sơ khám | **Vượt chỉ tiêu** |
| `phieu_chi_dinh_xet_nghiem` | 200 | Phiếu chỉ định | Đạt |
| **`ket_qua_xet_nghiem` (Tổng đa hình)** | **550** | $\ge 500$ kết quả XN | **Vượt chỉ tiêu** |
| - *Trong đó: `ket_qua_dinh_luong`* | 350 | Đo lường số học | Đạt |
| - *Trong đó: `ket_qua_hinh_anh`* | 120 | X-quang, CT | Đạt |
| - *Trong đó: `ket_qua_dinh_tinh`* | 80 | Vi sinh, kháng sinh đồ | Đạt |
| `don_thuoc` | 180 | Đơn thuốc | Đạt |
| `chi_tiet_don_thuoc` | 450 | Chi tiết thuốc kê | Đạt |
| `lich_su_chinh_sua` | 3 | Vết kích hoạt tự động | Đạt |

> Toàn bộ cơ sở dữ liệu đã sẵn sàng trên container Docker `hospital_db_container` (cổng `5433`), hoạt động ổn định và sẵn sàng cho việc xây dựng **10–12 Truy vấn SQL Nâng cao ở Tuần 7–8**.
