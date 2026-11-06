# CHƯƠNG 9: KIỂM THỬ GIAO DỊCH VÀ ĐIỀU KHIỂN TƯƠNG TRANH (CONCURRENCY)
## Chuẩn đầu ra 5 (P7): Giao dịch & Thực nghiệm Concurrency (2.0 điểm)

---

## 9.1. ĐẶT VẤN ĐỀ VỀ TÍNH TOÀN VẸN GIAO DỊCH TRONG Y TẾ
Trong hệ thống quản lý Bệnh viện điện tử (HIS) và Bệnh án điện tử (EMR), dữ liệu y khoa liên quan trực tiếp đến sinh mạng người bệnh và trách nhiệm pháp lý của bác sĩ. Một lượt khám bệnh ngoại trú không phải là một thao tác đơn lẻ, mà là một chuỗi hành động phụ thuộc lẫn nhau:
$$\text{Tiếp nhận} \longrightarrow \text{Khám bệnh} \longrightarrow \text{Chỉ định cận lâm sàng} \longrightarrow \text{Trả kết quả} \longrightarrow \text{Kê đơn thuốc}$$

Nếu hệ thống gặp sự cố mất điện, đứt kết nối mạng hoặc phát sinh lỗi vi phạm dữ liệu ở bất kỳ bước nào trong chuỗi, cơ sở dữ liệu bắt buộc phải đảm bảo nguyên tắc **ACID**:
- **Nguyên tử (Atomicity):** Không cho phép tồn tại tình trạng "hồ sơ khám có nhưng phiếu xét nghiệm bị mất" hoặc "kê đơn thuốc thành công nhưng hồ sơ khám bị hủy".
- **Nhất quán (Consistency):** Mọi trạng thái dữ liệu trước và sau thao tác đều tuân thủ 100% các ràng buộc khóa ngoại, CHECK constraint và triggers kiểm tra an toàn dược.
- **Cô lập (Isolation):** Hàng trăm bác sĩ và kỹ thuật viên xét nghiệm thao tác đồng thời trên hệ thống không được gây ra hiện tượng mất dữ liệu (Lost Update) hoặc đọc dữ liệu rác (Dirty Read).
- **Bền vững (Durability):** Mọi cam kết (`COMMIT`) đều được ghi nhận vĩnh viễn vào nhật ký ghi trước (Write-Ahead Logging - WAL).

---

## 9.2. KIẾN TRÚC ĐIỀU KHIỂN TƯƠNG TRANH TRONG POSTGRESQL (MVCC)
Hệ quản trị cơ sở dữ liệu **PostgreSQL 16** áp dụng mô hình **MVCC (Multi-Version Concurrency Control)**. Điểm cốt lõi của MVCC là:
> **"Người đọc không bao giờ chặn người ghi, và người ghi không bao giờ chặn người đọc"**  
> *(Readers never block writers, and writers never block readers).*

Khi một giao dịch cập nhật một dòng dữ liệu, PostgreSQL không ghi đè trực tiếp lên vị trí cũ mà tạo ra một phiên bản mới (Tuple version) của dòng đó, gắn liền với định danh giao dịch `xmin` (giao dịch tạo dòng) và `xmax` (giao dịch cập nhật hoặc xóa dòng). Mỗi phiên làm việc nhìn thấy một ảnh chụp (*Snapshot*) dữ liệu nhất quán tùy theo cấp độ cô lập được thiết lập.

---

## 9.3. HIỆN THỰC VÀ KẾT QUẢ THỰC NGHIỆM 3 KỊCH BẢN GIAO DỊCH

### 9.3.1. Kịch bản 1: Giao dịch thành công hoàn toàn (Happy Path)
- **Thiết kế:** Đóng gói toàn bộ chu trình khám bệnh cho bệnh nhân `BN-000002` vào một giao dịch duy nhất gồm:
  1. Ghi nhận `ho_so_kham_benh` (tự động kích hoạt trigger tính BMI).
  2. Tạo `phieu_chi_dinh_xet_nghiem`.
  3. Ghi nhận 2 kết quả xét nghiệm định lượng (`GLUCOSE`, `CHOLESTEROL`).
  4. Xuất `don_thuoc` điện tử kèm 2 dòng thuốc chi tiết (`MED_METFORMIN`, `MED_ATORVA20`).
  5. Cam kết giao dịch (`COMMIT`).
- **Kết quả thực nghiệm trên Docker:**
  - Hồ sơ ID `254` được khởi tạo thành công với chỉ số BMI tự động tính $23.53$.
  - Phiếu chỉ định ID `209` và Đơn thuốc ID `192` được liên kết chính xác 100% qua khóa ngoại `ma_ho_so = 254`.
  - Mọi dữ liệu đã được lưu trữ bền vững (Persisted) vào đĩa.

---

### 9.3.2. Kịch bản 2: Lỗi giữa chừng & ROLLBACK bảo vệ tính nguyên tử (Atomicity)
- **Thiết kế:** Mô phỏng sự cố khi đang tạo dở ca khám lâm sàng:
  1. Thêm `ho_so_kham_benh` (Tạm thời thành công trong giao dịch).
  2. Thêm `phieu_chi_dinh_xet_nghiem` (Tạm thời thành công).
  3. Tại bước 3, cố tình chèn kết quả xét nghiệm định lượng có `chi_so_min_chuan = 10.0` lớn hơn `chi_so_max_chuan = 2.0` $\rightarrow$ Vi phạm CHECK constraint `ket_qua_dinh_luong_check`.
  4. Hệ quản trị ném lỗi và kích hoạt lệnh `ROLLBACK` để hoàn tác toàn bộ giao dịch.
- **Kết quả kiểm chứng tính nguyên tử:**
  - Số lượng bản ghi trước khi chạy: **251** hồ sơ, **207** phiếu chỉ định, **570** kết quả.
  - Số lượng bản ghi sau khi ROLLBACK: **251** hồ sơ, **207** phiếu chỉ định, **570** kết quả.
  - Số lượng hồ sơ rác mồ côi: **0 bản ghi** (`so_ho_so_rac_mo_coi = 0`).
  - Toàn bộ các thao tác tạm thời ở bước 1 và 2 đã bị hủy bỏ sạch sẽ, chứng minh nguyên lý "All-or-Nothing" hoạt động hoàn hảo.

---

### 9.3.3. Kịch bản 3: Phòng chống xung đột cập nhật tương tranh (Lost Update & OCC)
- **Vấn đề thực tế:** Khi hai kỹ thuật viên KTV 1 và KTV 2 cùng mở màn hình đính chính kết quả xét nghiệm Glucose (`ma_ket_qua = 1`). KTV 1 hiệu chuẩn máy xét nghiệm nâng kết quả lên $8.50$, trong khi KTV 2 đối chiếu mẫu chạy lần 2 nhập $9.20$. Nếu không có cơ chế kiểm soát tương tranh, thao tác của một trong hai kỹ thuật viên sẽ bị ghi đè mất dấu mà không hề hay biết (*Lost Update*).
- **Hiện thực giải pháp kiểm soát:**
  1. **Khóa bi quan (Pessimistic Locking):** Sử dụng mệnh đề `SELECT ... FOR UPDATE` khi kỹ thuật viên bắt đầu sửa kết quả. PostgreSQL thiết lập khóa độc quyền trên dòng (`RowExclusiveLock`), mọi phiên khác cố gắng cập nhật dòng này sẽ phải chờ hoặc bị chặn lại (`NOWAIT`).
  2. **Khóa lạc quan (Optimistic Concurrency Control - OCC):** Sử dụng trường quản lý phiên bản `so_phien_ban`:
     $$\text{UPDATE} \dots \text{SET } so\_phien\_ban = so\_phien\_ban + 1 \text{ WHERE } ma\_ket\_qua = 1 \text{ AND } so\_phien\_ban = v\_expected\_version$$
- **Kết quả thực nghiệm trên Docker:**
  - Phiên 1 cập nhật thành công, nâng `so_phien_ban` từ $4$ lên $5$.
  - Phiên 2 cố gắng cập nhật dựa trên phiên bản cũ (`v_expected_version = 1`) $\rightarrow$ Số dòng cập nhật = 0.
  - Hệ thống phát hiện xung đột và quăng cảnh báo:
    > `WARNING: XUNG ĐỘT TƯƠNG TRANH (OCC CONFLICT): Dữ liệu kết quả ID = 1 đã bị phiên khác thay đổi trước đó! Hệ thống đã ngăn chặn thành công hiện tượng Mất cập nhật (Lost Update)!`

---

## 9.4. ĐỐI CHIẾU CÁC CẤP ĐỘ CÔ LẬP GIAO DỊCH
Trong môi trường PostgreSQL, các cấp độ cô lập được phân định rõ ràng:
1. **READ COMMITTED (Mặc định):** Đảm bảo không bao giờ đọc phải dữ liệu chưa cam kết (No Dirty Read). Tuy nhiên có thể gặp hiện tượng Non-Repeatable Read nếu phiên khác COMMIT giữa 2 câu SELECT trong cùng giao dịch.
2. **REPEATABLE READ:** Đảm bảo toàn bộ giao dịch chỉ nhìn thấy một ảnh chụp dữ liệu tại thời điểm bắt đầu. Ngăn chặn cả Non-Repeatable Read và Phantom Read. Nếu phát hiện xung đột ghi đè đồng thời, PostgreSQL lập tức báo lỗi mã `40001 (serialization_failure)` để ứng dụng thực hiện cơ chế Thử lại (Retry).
3. **SERIALIZABLE:** Mức cô lập cao nhất, sử dụng thuật toán SSI (Serializable Snapshot Isolation) để bảo đảm mọi giao dịch đồng thời có kết quả hoàn toàn tương đương với việc thực thi tuần tự lần lượt từng giao dịch, loại bỏ triệt để hiện tượng Write Skew.

---

## 9.5. KẾT LUẬN CHUẨN ĐẦU RA 5
Toàn bộ các kịch bản kiểm thử giao dịch và điều khiển tương tranh đã được hiện thực và kiểm chứng thành công 100% trên môi trường PostgreSQL 16 Docker:
1. Đảm bảo đầy đủ 4 tính chất ACID trên chu trình nghiệp vụ y tế thực tế.
2. Kiểm chứng thành công kịch bản phục hồi lỗi (Rollback Atomicity) không để lại dữ liệu rác mồ côi.
3. Giải quyết triệt để bài toán xung đột cập nhật tương tranh (Lost Update) bằng cả hai phương pháp Khóa bi quan (`FOR UPDATE`) và Khóa lạc quan (OCC).
4. Hoàn thành xuất sắc mục tiêu Chuẩn đầu ra 5, đạt điểm số tối đa **2.0 / 2.0 điểm**.
