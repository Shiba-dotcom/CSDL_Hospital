# 📊 BÁO CÁO THỰC THI 6 TRUY VẤN SQL NÂNG CAO (PHẦN 1 — TUẦN 7)
## Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
*(Đáp ứng Chuẩn đầu ra 3: SQL Nâng cao — 2.0 điểm)*

---

## 1. TỔNG HỢP DANH MỤC TRUY VẤN TUẦN 7 (Q1 – Q6)

| Mã | Tên nghiệp vụ | Kỹ thuật SQL Nâng cao áp dụng | Tệp mã nguồn |
|:---:|---|---|---|
| **Q1** | Tìm bệnh nhân có số lượt xét nghiệm bất thường vượt mức trung bình toàn viện | **Correlated Subquery** (Truy vấn con tương quan lồng trong WHERE và SELECT), Aggregate `AVG()` | `sql/queries/q01_correlated_subquery.sql` |
| **Q2** | Báo cáo tổng hợp hiệu suất khám bệnh, xét nghiệm và doanh thu thuốc của từng bác sĩ | **Multi-table JOIN** (7 bảng), `COUNT(DISTINCT)`, `GROUP BY`, `HAVING`, `COALESCE` | `sql/queries/q02_multitable_join_agg.sql` |
| **Q3** | Phân tích xu hướng diễn tiến chỉ số đường huyết (Glucose) theo chuỗi thời gian | **Window Functions**: `DENSE_RANK()`, `LAG()`, `OVER (PARTITION BY ... ORDER BY ...)` | `sql/queries/q03_window_function_trend.sql` |
| **Q4** | Truy vết lộ trình điều trị liên tục & chuỗi các lượt tái khám của bệnh nhân | **CTE Đệ quy (WITH RECURSIVE)**, Path Traversal string aggregation, Cumulative SUM | `sql/queries/q04_recursive_cte_pathway.sql` |
| **Q5** | Thống kê các loại xét nghiệm có tỷ lệ kết quả bất thường cao vượt chuẩn toàn viện | `GROUP BY`, `HAVING` kết hợp Subquery động, tính toán phần trăm theo điều kiện (`CASE WHEN`) | `sql/queries/q05_having_subquery_stats.sql` |
| **Q6** | Tìm các Bác sĩ đã từng chỉ định ĐẦY ĐỦ TẤT CẢ các loại xét nghiệm thuộc nhóm Sinh Hóa | **Phép chia đại số quan hệ (Relational Division $R \div S$)** biểu diễn qua **Double NOT EXISTS** | `sql/queries/q06_not_exists_set_division.sql` |

---

## 2. CHI TIẾT TỪNG TRUY VẤN & KẾT QUẢ THỰC THI THỰC TẾ

### 2.1. Truy vấn Q1: Correlated Subquery (Truy vấn con tương quan)
- **Ý nghĩa nghiệp vụ:** Giúp hội đồng y khoa và bảo hiểm y tế phát hiện nhóm bệnh nhân có nguy cơ cao, sức khỏe không ổn định do số lần xét nghiệm cảnh báo (`CAO` hoặc `NGUY_HIEM`) vượt trội so với mức bình quân toàn viện.
- **Điểm sáng kỹ thuật:**
  - Với mỗi dòng ứng viên ở bảng `benh_nhan`, truy vấn con bên trong tham chiếu trực tiếp đến `bn.ma_benh_nhan` ở bảng ngoài.
  - Mệnh đề `WHERE` so khớp động với kết quả trung bình `AVG()` được tính toán từ một subquery độc lập gom nhóm theo bệnh nhân.
- **Kết quả thực thi mẫu (Trích xuất từ Database Docker):**

```
 ma_benh_nhan |      ho_ten       | nhom_mau | so_lan_xet_nghiem_bat_thuong 
--------------+-------------------+----------+------------------------------
 BN-000018    | Phạm Đức Huy      | AB+      |                            4
 BN-000019    | Hoàng Minh Phúc   | O+       |                            4
 BN-000020    | Huỳnh Văn An      | O-       |                            4
 BN-000011    | Đỗ Minh Tuấn      | AB+      |                            3
 BN-000012    | Hồ Văn Hải        | O+       |                            3
 BN-000013    | Ngô Hữu Nam       | O-       |                            3
 BN-000014    | Dương Đức Tùng    | A+       |                            3
 BN-000015    | Nguyễn Minh Hương | A-       |                            3
... (Tổng cộng 23 bệnh nhân thỏa mãn điều kiện)
```

---

### 2.2. Truy vấn Q2: Multi-table JOIN + Aggregation + HAVING
- **Ý nghĩa nghiệp vụ:** Ban Giám đốc bệnh viện đánh giá khối lượng công việc thực tế của từng Bác sĩ lâm sàng: số ca khám, số phiếu chỉ định cận lâm sàng đã ban hành, số đơn thuốc đã xuất và tổng giá trị tiền thuốc phát sinh.
- **Điểm sáng kỹ thuật:**
  - Kết nối đồng thời 7 bảng: `bac_si`, `nhan_vien_y_te`, `nguoi`, `khoa_phong`, `ho_so_kham_benh`, `phieu_chi_dinh_xet_nghiem`, `don_thuoc`, `chi_tiet_don_thuoc`, `thuoc`.
  - Sử dụng `COUNT(DISTINCT ...)` để triệt tiêu hiện tượng nhân đôi số dòng (Cartesian product) phát sinh khi một đợt khám vừa có nhiều phiếu xét nghiệm vừa có đơn thuốc nhiều dòng.
  - Sử dụng `COALESCE()` bảo đảm an toàn với giá trị NULL.
- **Kết quả thực thi mẫu:**

```
 ma_bac_si |      ho_ten_bac_si       |   chuyen_khoa_chinh   |     phong_lam_viec_chinh     | tong_so_luot_kham | tong_so_phieu_xn | tong_so_don_thuoc | tong_doanh_thu_thuoc_vnd 
-----------+--------------------------+-----------------------+------------------------------+-------------------+------------------+-------------------+--------------------------
 NV-00001  | BS.CKII. Trần Đình Khoa  | Nội Tổng Quát         | Phòng Khám Nội Tổng Quát 101 |                80 |               66 |                60 |              18360000.00
 NV-00002  | ThS.BS. Lê Thị Mai Lan   | Tim Mạch & Chuyển Hóa | Phòng Khám Tim Mạch 102      |                80 |               67 |                60 |              18360000.00
 NV-00003  | BS.CKI. Nguyễn Hoàng Nam | Hô Hấp                | Phòng Khám Hô Hấp 103        |                80 |               67 |                60 |              18360000.00
```

---

### 2.3. Truy vấn Q3: Window Functions (LAG, LEAD, DENSE_RANK)
- **Ý nghĩa nghiệp vụ:** Giám sát liên tục chỉ số đường huyết mao mạch/tĩnh mạch (Glucose) của bệnh nhân qua các đợt khám. Bác sĩ thấy ngay giá trị của lần đo liền trước mà không cần mở lại hồ sơ bệnh án cũ, tự động phát hiện xu hướng đường huyết đang TĂNG hay GIẢM.
- **Điểm sáng kỹ thuật:**
  - `PARTITION BY bn.ma_benh_nhan`: Phân vùng tính toán độc lập cho từng bệnh nhân.
  - `ORDER BY dl.thoi_gian_co_ket_qua ASC`: Sắp xếp chuỗi thời gian tăng dần.
  - `LAG(dl.gia_tri_do, 1)`: Lấy giá trị của dòng trước đó trong cùng phân vùng mà không cần thực hiện phép tự kết nối (Self-JOIN tốn kém $O(N^2)$).
- **Kết quả thực thi mẫu:**

```
 ma_benh_nhan | ho_ten_benh_nhan  | lan_do_thu |    thoi_gian_co_ket_qua    | glucose_hien_tai | don_vi_tinh | muc_do_canh_bao | glucose_lan_truoc | do_bien_thien_delta |     danh_gia_xu_huong      
--------------+-------------------+------------+----------------------------+------------------+-------------+-----------------+-------------------+---------------------+----------------------------
 BN-000001    | Trần Hữu Khoa     |          1 | 2026-04-02 06:12:26        |            5.500 | mmol/L      | BINH_THUONG     |                   |                     | LẦN ĐO ĐẦU TIÊN (BASELINE)
 BN-000001    | Trần Hữu Khoa     |          2 | 2026-06-13 10:12:26        |            7.000 | mmol/L      | CAO             |             5.500 |                1.50 | XU HƯỚNG TĂNG ↗
 BN-000001    | Trần Hữu Khoa     |          3 | 2026-08-24 06:12:26        |            8.500 | mmol/L      | NGUY_HIEM       |             7.000 |                1.50 | XU HƯỚNG TĂNG ↗
 BN-000002    | Lê Đức Quân       |          1 | 2026-04-03 10:00:26        |            5.650 | mmol/L      | BINH_THUONG     |                   |                     | LẦN ĐO ĐẦU TIÊN (BASELINE)
 BN-000002    | Lê Đức Quân       |          2 | 2026-06-14 13:48:26        |            7.150 | mmol/L      | CAO             |             5.650 |                1.50 | XU HƯỚNG TĂNG ↗
```

---

### 2.4. Truy vấn Q4: CTE Đệ quy (WITH RECURSIVE)
- **Ý nghĩa nghiệp vụ:** Bệnh nhân mắc bệnh mạn tính (Tăng huyết áp, Đái tháo đường) trải qua quá trình khám và hẹn tái khám nhiều đợt. Truy vấn đệ quy giúp hệ thống tái hiện toàn bộ cây phác đồ theo dõi (Care Pathway), xâu chuỗi các mã hồ sơ và tính tổng chi phí tiền thuốc tích lũy qua từng đợt tái khám.
- **Điểm sáng kỹ thuật:**
  - **Anchor Member:** Xác định đợt khám đầu tiên (`visit_seq = 1`).
  - **Recursive Member:** Kết nối đệ quy giữa đợt khám thứ $n$ và đợt khám thứ $n+1$ của cùng một bệnh nhân.
  - Phép toán tích lũy: Ghép nối chuỗi đường dẫn (`pcp.chuoi_lo_trinh_kham || ' -> HS-' || next_v.ma_ho_so`) và cộng dồn chi phí (`pcp.tong_chi_phi_luy_ke + next_v.chi_phi_dot_nay`).
- **Kết quả thực thi mẫu:**

```
 ma_benh_nhan |   ten_benh_nhan   | tong_so_lan_kham |                        chuoi_lo_trinh_kham                        |  thoi_diem_kham_gan_nhat   |                  chan_doan_moi_nhat                  | tong_tien_thuoc_luy_ke_vnd 
--------------+-------------------+------------------+-------------------------------------------------------------------+----------------------------+------------------------------------------------------+----------------------------
 BN-000001    | Trần Hữu Khoa     |                7 | HS-60 -> HS-120 -> HS-180 -> HS-240 -> HS-241 -> HS-242 -> HS-244 | 2026-11-06 06:40:22.988297 | Tăng huyết áp độ 1 - Kiểm soát tốt                   |                 1935000.00
 BN-000002    | Lê Đức Quân       |                4 | HS-1 -> HS-61 -> HS-121 -> HS-181                                 | 2026-08-25 09:15:26.273349 | Viêm phế quản cấp bội nhiễm vi khuẩn                 |                  594000.00
 BN-000003    | Phạm Minh Bình    |                4 | HS-2 -> HS-62 -> HS-122 -> HS-182                                 | 2026-08-26 13:03:26.273349 | Cơn đau thắt ngực mạn tính do xơ vữa động mạch       |                 1242000.00
 BN-000004    | Hoàng Văn Linh    |                4 | HS-3 -> HS-63 -> HS-123 -> HS-183                                 | 2026-08-27 16:51:26.273349 | Đái tháo đường Typ 2 có biến chứng mạch máu nhỏ      |                  594000.00
 BN-000005    | Huỳnh Hữu Sơn     |                4 | HS-4 -> HS-64 -> HS-124 -> HS-184                                 | 2026-08-29 04:39:26.273349 | Viêm dạ dày trợt nông có vi khuẩn H. Pylori (+)      |                 1242000.00
```

---

### 2.5. Truy vấn Q5: GROUP BY + HAVING Subquery
- **Ý nghĩa nghiệp vụ:** Báo cáo kiểm soát chất lượng kỹ thuật xét nghiệm (Quality Control) giúp Trưởng khoa Xét nghiệm phát hiện các dịch vụ xét nghiệm có tỷ lệ cảnh báo bất thường cao bất thường để rà soát quy trình lấy mẫu hoặc hiệu chuẩn máy.
- **Điểm sáng kỹ thuật:**
  - Kết hợp gom nhóm và hàm đếm có điều kiện: `COUNT(CASE WHEN dl.muc_do_canh_bao IN ('CAO', 'NGUY_HIEM') THEN 1 END)`.
  - Mệnh đề `HAVING` sử dụng một subquery động độc lập để so sánh với tỷ lệ bình quân của toàn bộ các xét nghiệm định lượng trong CSDL.
- **Kết quả thực thi mẫu:**

```
 ma_danh_muc_xn |               ten_xet_nghiem                | nhom_xet_nghiem | tong_so_luot_xet_nghiem | so_luot_binh_thuong | so_luot_bat_thuong | ty_le_bat_thuong_pct 
----------------+---------------------------------------------+-----------------+-------------------------+---------------------+--------------------+----------------------
 GLUCOSE        | Định lượng Glucose máu (Mao mạch/Tĩnh mạch) | SINH_HOA        |                     200 |                  68 |                132 |                66.00
```

---

### 2.6. Truy vấn Q6: Relational Division (Double NOT EXISTS)
- **Ý nghĩa nghiệp vụ:** Tìm kiếm các Bác sĩ có năng lực chuyên môn toàn diện, đã từng chỉ định **TẤT CẢ** các danh mục kỹ thuật thuộc nhóm chuyên khoa `'SINH_HOA'`.
- **Điểm sáng kỹ thuật:**
  - Hiện thực hóa phép chia đại số quan hệ kinh điển:
    $$\pi_{\text{ma\_bac\_si}}(\text{PhieuChiDinh} \bowtie \text{KetQua}) \div \pi_{\text{ma\_danh\_muc\_xn}}(\sigma_{\text{nhom} = \text{'SINH\_HOA'}}(\text{DanhMucXetNghiem}))$$
  - Cấu trúc phủ định kép: Tìm Bác sĩ $B$ sao cho **KHÔNG TỒN TẠI** xét nghiệm sinh hóa nào mà **KHÔNG ĐƯỢC CHỈ ĐỊNH** bởi Bác sĩ $B$.
- **Kết quả thực thi mẫu:**

```
 ma_bac_si |      ho_ten_bac_si      | chuyen_khoa_chinh |        khoa_lam_viec         
-----------+-------------------------+-------------------+------------------------------
 NV-00001  | BS.CKII. Trần Đình Khoa | Nội Tổng Quát     | Phòng Khám Nội Tổng Quát 101
(1 row)
```
*(Bác sĩ Trần Đình Khoa là bác sĩ duy nhất đã chỉ định trọn vẹn đủ 5 kỹ thuật Sinh Hóa: Glucose, Ure máu, Creatinine, Cholesterol và Triglycerid).*

