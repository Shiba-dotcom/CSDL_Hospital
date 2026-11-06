# 🔒 TÀI LIỆU KIỂM THỬ GIAO DỊCH & TƯƠNG TRANH (TRANSACTIONS & CONCURRENCY)
## Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
*(Đáp ứng Chuẩn đầu ra 5: Transaction & Thực nghiệm Concurrency — 2.0 điểm)*

---

## 1. TỔNG QUAN LÝ THUYẾT GIAO DỊCH (ACID & MVCC TRONG POSTGRESQL)

Mỗi chu trình nghiệp vụ y tế (như quy trình khám bệnh ngoại trú, chỉ định cận lâm sàng, đính chính kết quả xét nghiệm hoặc kê đơn thuốc) đòi hỏi hệ quản trị cơ sở dữ liệu phải bảo đảm tuyệt đối 4 đặc tính **ACID**:

1. **Atomicity (Tính nguyên tử):** "Tất cả hoặc không có gì" (*All-or-Nothing*). Toàn bộ các thao tác tạo hồ sơ $\rightarrow$ chỉ định $\rightarrow$ kết quả $\rightarrow$ đơn thuốc phải cùng thành công hoặc cùng bị hủy bỏ (Rollback), không để lại bất kỳ bản ghi mồ côi nào.
2. **Consistency (Tính nhất quán):** Dữ liệu trước và sau giao dịch luôn thỏa mãn 100% các ràng buộc toàn vẹn (Khóa ngoại, CHECK constraints, Trigger nghiệp vụ y tế).
3. **Isolation (Tính cô lập):** Các phiên làm việc đồng thời của nhiều bác sĩ, kỹ thuật viên không được can thiệp hay đọc dữ liệu rác chưa cam kết của nhau. PostgreSQL hiện thực tính cô lập thông qua cơ chế **MVCC** (*Multi-Version Concurrency Control*).
4. **Durability (Tính bền vững):** Một khi giao dịch đã `COMMIT`, dữ liệu được ghi nhận vào nhật ký Write-Ahead Log (WAL) và đảm bảo an toàn tuyệt đối ngay cả khi gặp sự cố mất điện máy chủ.

---

## 2. MA TRẬN 4 CẤP ĐỘ CÔ LẬP GIAO DỊCH TRÊN POSTGRESQL

| Cấp độ cô lập (Isolation Level) | Đọc rác (Dirty Read) | Đọc không lặp lại (Non-Repeatable Read) | Đọc bóng ma (Phantom Read) | Dị thường tuần tự hóa (Serialization Anomaly) | Cơ chế kiểm soát trong PostgreSQL |
|---|:---:|:---:|:---:|:---:|---|
| **READ COMMITTED** *(Mặc định)* | **KHÔNG** | Có thể xảy ra | Có thể xảy ra | Có thể xảy ra | Mỗi câu lệnh SQL nhận một snapshot dữ liệu mới tại thời điểm câu lệnh bắt đầu |
| **REPEATABLE READ** | **KHÔNG** | **KHÔNG** | **KHÔNG** *(Ưu việt hơn chuẩn SQL:92)* | Có thể xảy ra *(Write Skew)* | Toàn bộ giao dịch sử dụng chung một snapshot tại thời điểm giao dịch bắt đầu. Báo lỗi `40001` nếu gặp xung đột cập nhật |
| **SERIALIZABLE** | **KHÔNG** | **KHÔNG** | **KHÔNG** | **KHÔNG (An toàn tuyệt đối)** | Cơ chế **SSI** (*Serializable Snapshot Isolation*), theo dõi đồ thị phụ thuộc SIREAD locks |

---

## 3. THỰC NGHIỆM CHI TIẾT 4 KỊCH BẢN GIAO DỊCH

### 3.1. Kịch bản 1: Giao dịch thành công hoàn toàn (Happy Path)
- **Tệp mã nguồn:** [01_scenario_happy_path.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/transactions/01_scenario_happy_path.sql)
- **Kịch bản nghiệp vụ:** Bác sĩ hoàn tất khám lâm sàng cho bệnh nhân `BN-000002`:
  1. Ghi nhận `ho_so_kham_benh` kèm chỉ số sinh tồn (Trigger tự động tính $BMI = 23.53$).
  2. Tạo `phieu_chi_dinh_xet_nghiem` ở trạng thái `DA_CO_KET_QUA`.
  3. Ghi nhận 2 kết quả xét nghiệm định lượng (`GLUCOSE`, `CHOLESTEROL`).
  4. Xuất `don_thuoc` kèm 2 khoản mục thuốc (`MED_METFORMIN`, `MED_ATORVA20`).
  5. Cam kết giao dịch (`COMMIT`).
- **Kết quả thực thi mẫu từ CSDL Docker:**
```text
psql:sql/transactions/01_scenario_happy_path.sql:81: NOTICE:  [1/4] Đã tạo Hồ sơ khám bệnh ID = 254 (BMI tự động tính qua Trigger: 23.53)
psql:sql/transactions/01_scenario_happy_path.sql:81: NOTICE:  [2/4] Đã tạo Phiếu chỉ định xét nghiệm ID = 209
psql:sql/transactions/01_scenario_happy_path.sql:81: NOTICE:  [3/4] Đã ghi nhận 2 kết quả xét nghiệm định lượng cho phiếu ID = 209
psql:sql/transactions/01_scenario_happy_path.sql:81: NOTICE:  [4/4] Đã tạo Đơn thuốc ID = 192 với 2 khoản mục thuốc
psql:sql/transactions/01_scenario_happy_path.sql:81: NOTICE:  ===> KỊCH BẢN 1 HOÀN TẤT THÀNH CÔNG: Mọi dữ liệu đã cam kết (COMMIT) toàn vẹn!
DO
 ma_ho_so | ma_benh_nhan | chi_so_bmi | ma_phieu_chi_dinh | so_luong_ket_qua_xn | ma_don_thuoc | so_khoan_muc_thuoc 
----------+--------------+------------+-------------------+---------------------+--------------+--------------------
      254 | BN-000002    |      23.53 |               209 |                   2 |          192 |                  2
(1 row)
```

---

### 3.2. Kịch bản 2: Lỗi giữa chừng & ROLLBACK bảo vệ tính nguyên tử (Atomicity)
- **Tệp mã nguồn:** [02_scenario_rollback_atomicity.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/transactions/02_scenario_rollback_atomicity.sql)
- **Kịch bản sự cố:**
  1. Giao dịch khởi tạo `ho_so_kham_benh` và `phieu_chi_dinh_xet_nghiem` tạm thời thành công.
  2. Tại bước 3, cố tình chèn bản ghi kết quả xét nghiệm định lượng có `chi_so_min_chuan = 10.0` lớn hơn `chi_so_max_chuan = 2.0` $\rightarrow$ Vi phạm ràng buộc `CHECK (chi_so_max_chuan > chi_so_min_chuan)`.
  3. PostgreSQL lập tức quăng lỗi `check_violation`, chuyển giao dịch sang trạng thái `ABORTED`.
  4. Lệnh `ROLLBACK` được kích hoạt để hủy bỏ toàn bộ các bước trước đó.
- **Kết quả thực thi mẫu chứng minh tính nguyên tử:**
```text
tong_hs_truoc_khi_chay: 251 | tong_phieu_truoc_khi_chay: 207 | tong_kq_truoc_khi_chay: 570

BEGIN
>>> [Bước 1] Thêm Hồ sơ khám bệnh vào giao dịch (Tạm thời thành công)...
INSERT 0 1
>>> [Bước 2] Thêm Phiếu chỉ định xét nghiệm vào giao dịch (Tạm thời thành công)...
INSERT 0 1
>>> [Bước 3] CỐ Ý GÂY LỖI: Chèn kết quả xét nghiệm vi phạm CHECK constraint (min=10.0 > max=2.0)...
ERROR: new row for relation "ket_qua_dinh_luong" violates check constraint "ket_qua_dinh_luong_check"
DETAIL: Failing row contains (575, 210, GLUCOSE, null, null, null, CHO_KET_QUA, null, 1, f, 5.500, mmol/L, 10.000, 2.000, BINH_THUONG).
>>> [Bước 4] PHÁT LỆNH ROLLBACK ĐỂ HỦY BỎ VÀ HOÀN TÁC TOÀN BỘ GIAO DỊCH...
ROLLBACK

KẾT QUẢ ĐỐI CHỨNG:
tong_hs_sau_khi_loi: 251 | tong_phieu_sau_khi_loi: 207 | tong_kq_sau_khi_loi: 570
so_ho_so_rac_mo_coi: 0
```
*(Số lượng bản ghi trước và sau hoàn toàn bằng nhau, số hồ sơ mồ côi bằng 0 $\rightarrow$ Nguyên tử tính tuyệt đối).*

---

### 3.3. Kịch bản 3: Phòng chống xung đột cập nhật (Lost Update & Concurrency Control)
- **Tệp mã nguồn:** [03_scenario_concurrency_lost_update.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/transactions/03_scenario_concurrency_lost_update.sql)
- **Vấn đề tranh chấp:** Hai kỹ thuật viên cùng mở màn hình đính chính kết quả xét nghiệm Glucose (`ma_ket_qua = 1`). Nếu cùng ghi đè, thao tác của một kỹ thuật viên sẽ bị mất (*Lost Update*).
- **Hai cơ chế giải quyết triệt để:**
  1. **Khóa bi quan (Pessimistic Locking):** Sử dụng `SELECT ... FOR UPDATE` để chiếm giữ khóa độc quyền trên dòng (`Exclusive Row Lock`). Phiên đồng thời sẽ bị chặn lại hoặc từ chối ngay lập tức (`NOWAIT`) cho đến khi phiên đầu tiên giải phóng khóa.
  2. **Khóa lạc quan (Optimistic Concurrency Control - OCC):** Sử dụng cột `so_phien_ban` (*Version column*):
     ```sql
     UPDATE ket_qua_dinh_luong
     SET gia_tri_do = 9.20, so_phien_ban = so_phien_ban + 1
     WHERE ma_ket_qua = 1 AND so_phien_ban = 1;
     ```
     Nếu số dòng ảnh hưởng (`ROW_COUNT`) bằng 0, hệ thống phát hiện xung đột tương tranh và từ chối cập nhật, cảnh báo người dùng tải lại dữ liệu mới nhất.
- **Kết quả thực thi mẫu:**
```text
psql:sql/transactions/03_scenario_concurrency_lost_update.sql:47: NOTICE:  >>> [PHIÊN 1] Đang bắt đầu giao dịch và giữ khóa dòng (ROW-LEVEL EXCLUSIVE LOCK)...
psql:sql/transactions/03_scenario_concurrency_lost_update.sql:47: NOTICE:  [PHIÊN 1] Đã khóa thành công dòng kết quả ID = 1 (Giá trị đo hiện thời: 8.500)
psql:sql/transactions/03_scenario_concurrency_lost_update.sql:47: NOTICE:  [PHIÊN 1] Đã cập nhật giá trị mới: 8.50. Chuẩn bị COMMIT...
DO
psql:sql/transactions/03_scenario_concurrency_lost_update.sql:72: NOTICE:  >>> [PHIÊN 2] Cố gắng cập nhật với phiên bản cũ (v_expected_version = 1)...
DO
psql:sql/transactions/03_scenario_concurrency_lost_update.sql:72: WARNING:  XUNG ĐỘT TƯƠNG TRANH (OCC CONFLICT): Dữ liệu kết quả ID = 1 đã bị phiên khác thay đổi trước đó!
psql:sql/transactions/03_scenario_concurrency_lost_update.sql:72: WARNING:  Hệ thống đã ngăn chặn thành công hiện tượng Mất cập nhật (Lost Update)!
```

---

### 3.4. Kịch bản 4: Đối chiếu cấp độ cô lập (Isolation Levels Simulation)
- **Tệp mã nguồn:** [04_scenario_isolation_levels.sql](file:///a:/VisualStudioCode/CSDL_BenhVien/sql/transactions/04_scenario_isolation_levels.sql)
- **Thử nghiệm:**
  - Mô phỏng ứng xử của cấp độ `REPEATABLE READ` khi có cập nhật tương tranh đồng thời: PostgreSQL phát hiện xung đột và ném ngoại lệ chuẩn `serialization_failure (SQLSTATE 40001)`.
  - Ứng dụng y tế được cấu hình tự động bắt mã lỗi này và thực hiện cơ chế Retry giao dịch (Thử lại) một cách trong suốt với người dùng.
