# PHẦN 1: GIỚI THIỆU VÀ MỤC TIÊU ĐỒ ÁN

---

## 1.1. Đặt vấn đề và Tính cấp thiết của đề tài

Trong thời đại chuyển đổi số y tế, hệ thống Thông tin Bệnh viện (Hospital Information System - HIS) và hệ thống Quản lý Xét nghiệm (Laboratory Information System - LIS) đóng vai trò xương sống trong việc bảo đảm chất lượng chẩn đoán và điều trị. Tại các cơ sở y tế hiện đại, khối lượng dữ liệu phát sinh hàng ngày từ các lượt khám bệnh, xét nghiệm cận lâm sàng và đơn thuốc là vô cùng lớn, đa dạng về mặt cấu trúc và đòi hỏi độ chính xác tuyệt đối.

Một trong những thách thức kỹ thuật lớn nhất đối với hệ thống cơ sở dữ liệu y tế là **tính pháp lý và khả năng lưu vết dữ liệu (Audit Trail / Revision Control)**:
- Kết quả xét nghiệm y khoa hay chẩn đoán bệnh án liên quan trực tiếp đến tính mạng con người và chịu sự chi phối chặt chẽ của luật khám chữa bệnh. Dữ liệu khi đã công bố thì **không được phép xóa bỏ (hard delete)** hoặc **ghi đè âm thầm (silent update)**. 
- Trong thực tế vận hành, việc đính chính kết quả xét nghiệm vẫn xảy ra (do máy phân tích tự động hiệu chuẩn lại, do lấy nhầm mẫu bệnh phẩm, hoặc do bác sĩ chuyên khoa hội chẩn lại). Do đó, CSDL bắt buộc phải có cơ chế ghi nhận lịch sử chỉnh sửa một cách tự động, minh bạch, bảo toàn dữ liệu trước và sau biến động, đồng thời lưu giữ thông tin người thực hiện và lý do giải trình.

Bên cạnh đó, **tính đa hình của dữ liệu cận lâm sàng (Polymorphic Test Results)** cũng đặt ra bài toán kiến trúc phức tạp:
- Các xét nghiệm sinh hóa, huyết học trả về chỉ số định lượng (số thực, đơn vị đo, khoảng tham chiếu).
- Các xét nghiệm vi sinh, sinh học phân tử trả về kết quả định tính kèm mô tả văn bản phức tạp.
- Các kỹ thuật chẩn đoán hình ảnh (X-quang, MRI, Siêu âm) lại lưu trữ tệp tin đa phương tiện và kết luận tổn thương.

Để giải quyết đồng thời hai thách thức trên, đề tài **"Thiết kế CSDL hồ sơ khám bệnh và kết quả xét nghiệm có lịch sử chỉnh sửa"** được triển khai dựa trên hệ quản trị cơ sở dữ liệu quan hệ - hướng đối tượng **PostgreSQL**. Đồ án không chỉ dừng lại ở mô hình quan hệ truyền thống mà còn khai thác triệt để các tính năng nâng cao như Object-Relational (Table Inheritance, Composite Types), JSONB, Trigger-based Auditing và cơ chế kiểm soát giao dịch (Transaction Isolation Levels).

---

## 1.2. Mục tiêu nghiên cứu và sản phẩm của đồ án

### 1.2.1. Mục tiêu học thuật & kỹ thuật
1. **Phân tích và Mô hình hóa dữ liệu (Conceptual Design)**:
   - Xây dựng mô hình thực thể kết hợp mở rộng (EER) hoàn chỉnh, thể hiện chính xác mối quan hệ phân cấp kế thừa (Generalization/Specialization) trong hệ thống y tế (phân loại nhân sự y tế và phân loại đa hình kết quả xét nghiệm).
   - Xây dựng từ điển dữ liệu chuẩn mực, bao phủ toàn bộ các ràng buộc toàn vẹn miền giá trị, khóa, tham chiếu và quy tắc nghiệp vụ.
2. **Lý thuyết Chuẩn hóa CSDL (Normalization)**:
   - Xác định hệ phụ thuộc hàm đầy đủ, tính bao đóng và tìm phủ tối thiểu.
   - Chứng minh các quan hệ đạt chuẩn 3NF và BCNF; phân tích tính nối không mất mát thông tin (Lossless Join) và bảo toàn phụ thuộc hàm (Dependency Preservation). Phân tích dạng chuẩn 4NF đối với các phụ thuộc đa trị (MVD).
3. **Khai thác SQL Nâng cao (Advanced SQL)**:
   - Hiện thực hóa hệ thống bằng PostgreSQL.
   - Thiết kế và tối ưu 10–12 truy vấn nghiệp vụ phức tạp: Correlated Subquery, Window Functions (RANK, LAG/LEAD), Recursive CTE, Dynamic SQL, Stored Procedures và Trigger tự động hóa.
4. **Ứng dụng Mô hình Cơ sở Dữ liệu Hướng Đối Tượng (Object-Relational DBMS)**:
   - Thiết kế phân hệ 4–6 lớp đối tượng, tận dụng thế mạnh kế thừa bảng (`INHERITS`), kiểu dữ liệu phức hợp (`Composite Types`), mảng (`Array`) và phương thức tính toán.
   - Xây dựng tối thiểu 5 câu truy vấn OQL (Object Query Language) khai thác các đặc tính hướng đối tượng trên PostgreSQL.
5. **Kiểm thử Giao dịch và Tính toàn vẹn (Transactions & Concurrency Control)**:
   - Xây dựng 3 kịch bản transaction thực tế: Kịch bản thành công hoàn toàn (Commit), Kịch bản lỗi giữa chừng (Rollback đảm bảo tính nguyên tử - Atomicity), và Kịch bản xung đột đồng thời (Concurrency giữa 2 phiên làm việc độc lập ở các mức cô lập khác nhau như Read Committed, Repeatable Read, Serializable).

---

## 1.3. Phạm vi áp dụng của đề tài

- **Phạm vi nghiệp vụ**:
  - Hệ thống tập trung vào quy trình khám chữa bệnh ngoại trú dịch vụ / thông thường tại các phòng khám đa khoa hoặc bệnh viện tuyến quận/huyện.
  - Bao quát các mắt xích: Tiếp nhận bệnh nhân $\rightarrow$ Khám lâm sàng $\rightarrow$ Chỉ định cận lâm sàng $\rightarrow$ Nhập & trả kết quả xét nghiệm đa hình $\rightarrow$ Chẩn đoán xác định & Kê đơn thuốc $\rightarrow$ Lưu vết lịch sử chỉnh sửa.
  - **Giới hạn phạm vi**: Hệ thống không đi sâu vào phân hệ thanh toán Bảo hiểm Y tế (BHYT) phức tạp hoặc quản lý viện phí nội trú dài ngày, nhằm dồn trọng tâm kỹ thuật vào mô hình hóa dữ liệu xét nghiệm và cơ chế lịch sử chỉnh sửa dữ liệu.

- **Nền tảng công nghệ**:
  - Hệ quản trị CSDL: **PostgreSQL 16+**.
  - Công cụ quản trị & thực thi: `psql` CLI, pgAdmin 4.
  - Quản lý mã nguồn & tài liệu: GitHub Repository.

