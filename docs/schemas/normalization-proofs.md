# 📐 TÀI LIỆU CHỨNG MINH CHUẨN HÓA (BCNF, 3NF & 4NF)
## Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
*(Giai đoạn 2: Chuẩn hóa dữ liệu — Nhiệm vụ Tuần 5)*

---

## 1. CƠ SỞ LÝ THUYẾT DẠNG CHUẨN (NORMAL FORMS)

### 1.1. Dạng chuẩn 1 (1NF - First Normal Form)
Lược đồ quan hệ $R$ đạt dạng chuẩn 1 (1NF) nếu và chỉ nếu mọi miền giá trị của các thuộc tính trong $R$ đều chỉ chứa các giá trị nguyên tử (Atomic values), không chứa tập hợp lặp hay thuộc tính phức hợp lồng nhau.

### 1.2. Dạng chuẩn 2 (2NF - Second Normal Form)
Lược đồ quan hệ $R$ đạt 2NF nếu:
1. $R$ đã đạt chuẩn 1NF.
2. Mọi thuộc tính không khóa (Non-prime attribute) đều **phụ thuộc hàm đầy đủ** vào mọi khóa ứng viên của $R$ (không có phụ thuộc bộ phận vào một phần của khóa).

### 1.3. Dạng chuẩn 3 (3NF - Third Normal Form)
Lược đồ quan hệ $R$ đạt 3NF đối với tập phụ thuộc hàm $F$ nếu với mọi phụ thuộc hàm không tầm thường $X \rightarrow A \in F^+$ ($A \notin X$), thỏa mãn ít nhất một trong hai điều kiện:
1. $X$ là một **siêu khóa (Superkey)** của $R$.
2. $A$ là một **thuộc tính khóa (Prime attribute)** (tức $A$ thuộc về ít nhất một khóa ứng viên nào đó của $R$).
*(Ý nghĩa: Loại bỏ hoàn toàn phụ thuộc bắc cầu của thuộc tính không khóa vào khóa chính).*

### 1.4. Dạng chuẩn Boyce-Codd (BCNF - Boyce-Codd Normal Form)
Lược đồ quan hệ $R$ đạt BCNF đối với tập phụ thuộc hàm $F$ nếu với mọi phụ thuộc hàm không tầm thường $X \rightarrow A \in F^+$, điều kiện duy nhất bắt buộc phải thỏa mãn là:
- $X$ phải là một **siêu khóa (Superkey)** của $R$.
*(Ý nghĩa: BCNF chặt chẽ hơn 3NF, không cho phép ngoại lệ $A$ là thuộc tính khóa. BCNF loại bỏ triệt để mọi dị thường dư thừa do phụ thuộc hàm gây ra).*

---

## 2. CHỨNG MINH PHÂN RÃ CHUẨN HÓA BCNF & 3NF (CASE STUDIES)

### 2.1. Case Study 1: Phân hệ Kết quả Xét nghiệm & Danh mục Kỹ thuật

Giả sử ban đầu người thiết kế gộp thông tin danh mục xét nghiệm vào bảng kết quả đo lường:
$$R_{\text{KQ\_Gop}}(\text{ma\_ket\_qua}, \text{ma\_phieu\_chi\_dinh}, \text{ma\_danh\_muc\_xn}, \text{ma\_ktv}, \text{gia\_tri\_do}, \text{don\_vi\_tinh}, \text{chi\_so\_min}, \text{chi\_so\_max}, \text{so\_phien\_ban})$$

- **Tập thuộc tính viết tắt:** $U = \{K, P, D, T, V, U, N, X, S\}$
- **Tập phụ thuộc hàm $F$:**
  - $f_1: K \rightarrow \{P, D, T, V, S\}$
  - $f_2: D \rightarrow \{U, N, X\}$
  - $f_3: \{P, D\} \rightarrow K$
- **Khóa ứng viên:** $\mathcal{K} = \{\{K\}, \{P, D\}\}$.
  - Tập thuộc tính khóa: $\{K, P, D\}$.
  - Tập thuộc tính không khóa: $\{T, V, U, N, X, S\}$.

#### Bước 1: Kiểm tra dạng chuẩn 3NF và BCNF
- Xét phụ thuộc hàm $f_2: D \rightarrow \{U, N, X\}$:
  1. $D$ có phải là siêu khóa không?
     - $\{D\}^+ = \{D, U, N, X\} \neq U \Rightarrow D$ **KHÔNG PHẢI LÀ SIÊU KHÓA**.
  2. Các thuộc tính $\{U, N, X\}$ có phải là thuộc tính khóa không?
     - Không, $\{U, N, X\}$ đều là thuộc tính không khóa.
- **Kết luận:**
  - $f_2$ **vi phạm điều kiện 3NF** (tồn tại phụ thuộc bắc cầu: $K \rightarrow D \rightarrow \{U, N, X\}$).
  - $f_2$ **vi phạm điều kiện BCNF** (vế trái $D$ không phải siêu khóa).
  - Hậu quả: Dư thừa dữ liệu nghiêm trọng (mỗi lần đo Glucose đều phải lặp lại đơn vị `mmol/L`, min `3.9`, max `6.4`), dễ phát sinh dị thường sửa đổi và dị thường xóa.

#### Bước 2: Thuật toán Phân rã BCNF
Do $f_2: D \rightarrow \{U, N, X\}$ vi phạm BCNF, ta phân rã $R_{\text{KQ\_Gop}}$ thành hai quan hệ con:
1. $R_1 = D^+ = \{D, U, N, X\} \equiv \text{DanhMucXetNghiem}(\underline{\text{ma\_danh\_muc\_xn}}, \text{don\_vi\_tinh}, \text{chi\_so\_min}, \text{chi\_so\_max})$.
2. $R_2 = (U \setminus \{U, N, X\}) \cup \{D\} = \{K, P, D, T, V, S\} \equiv \text{KetQuaDinhLuong}(\underline{\text{ma\_ket\_qua}}, \text{ma\_phieu\_chi\_dinh}, \text{ma\_danh\_muc\_xn}, \text{ma\_ktv}, \text{gia\_tri\_do}, \text{so\_phien\_ban})$.

#### Bước 3: Kiểm tra dạng chuẩn của các lược đồ con
- Trong $R_1$: $D \rightarrow \{U, N, X\}$. Khóa chính là $D$ (siêu khóa) $\Rightarrow R_1$ đạt **BCNF**.
- Trong $R_2$: Khóa chính là $K$ và $\{P, D\}$; các FD chỉ có $K \rightarrow \{P, D, T, V, S\}$ và $\{P, D\} \rightarrow K$. Mọi vế trái đều là siêu khóa $\Rightarrow R_2$ đạt **BCNF**.

---

## 3. CHỨNG MINH TÍNH NỐI KHÔNG MẤT MÁT & BẢO TOÀN PHỤ THUỘC

### 3.1. Chứng minh Tính Nối Không Mất Mát Thông Tin (Lossless Join Property)

**Định lý Heath (Heath's Theorem):**
Phép phân rã lược đồ $R$ thành hai lược đồ con $R_1, R_2$ ($R = R_1 \cup R_2$) là **nối không mất mát thông tin** đối với tập phụ thuộc hàm $F$ khi và chỉ khi:
$$(R_1 \cap R_2) \rightarrow (R_1 \setminus R_2) \in F^+ \quad \text{HOẶC} \quad (R_1 \cap R_2) \rightarrow (R_2 \setminus R_1) \in F^+$$

**Áp dụng vào phân rã ở Case Study 1:**
- $R_1 = \{D, U, N, X\}$
- $R_2 = \{K, P, D, T, V, S\}$
- Giao của hai quan hệ:
  $$R_1 \cap R_2 = \{D\} = \{\text{ma\_danh\_muc\_xn}\}$$
- Hiệu của quan hệ thứ nhất với quan hệ thứ hai:
  $$R_1 \setminus R_2 = \{U, N, X\} = \{\text{don\_vi\_tinh}, \text{chi\_so\_min}, \text{chi\_so\_max}\}$$
- Ta kiểm tra phụ thuộc hàm:
  $$(R_1 \cap R_2) \rightarrow (R_1 \setminus R_2) \iff D \rightarrow \{U, N, X\}$$
- Theo tập phụ thuộc hàm ban đầu $F$, $D \rightarrow \{U, N, X\}$ chính là $f_2 \in F$.
- Do đó:
  $$(R_1 \cap R_2) \rightarrow (R_1 \setminus R_2) \in F^+$$

$$\Rightarrow \mathbf{Phép\ phân\ rã\ \rho = \{R_1, R_2\}\ đảm\ bảo\ TÍNH\ NỐI\ KHÔNG\ MẤT\ MÁT\ THÔNG\ TIN\ (Lossless\ Join).}$$

---

### 3.2. Chứng minh Tính Bảo toàn Phụ thuộc Hàm (Dependency Preservation)

**Định nghĩa:**
Phép phân rã $R$ thành $\rho = \{R_1, R_2, \dots, R_k\}$ là **bảo toàn phụ thuộc hàm** đối với $F$ nếu:
$$F^+ = (\pi_{R_1}(F) \cup \pi_{R_2}(F) \cup \dots \cup \pi_{R_k}(F))^+$$
trong đó $\pi_{R_i}(F) = \{X \rightarrow Y \in F^+ \mid XY \subseteq R_i\}$.

**Áp dụng kiểm tra:**
- Chiếu của $F$ lên $R_1$:
  $$\pi_{R_1}(F) = \{D \rightarrow U, D \rightarrow N, D \rightarrow X\}$$
- Chiếu của $F$ lên $R_2$:
  $$\pi_{R_2}(F) = \{K \rightarrow P, K \rightarrow D, K \rightarrow T, K \rightarrow V, K \rightarrow S, PD \rightarrow K\}$$
- Hợp hai tập chiếu:
  $$F' = \pi_{R_1}(F) \cup \pi_{R_2}(F) = \{D \rightarrow \{U, N, X\}, K \rightarrow \{P, D, T, V, S\}, PD \rightarrow K\}$$
- So sánh $F'$ với tập phủ tối thiểu $F_{\min}$ ở Tuần 4:
  $$F' \equiv F_{\min} \equiv F$$
- Không có bất kỳ phụ thuộc hàm nào bị mất hay cần phải nối bảng (JOIN) lại mới kiểm tra được ràng buộc.

$$\Rightarrow \mathbf{Phép\ phân\ rã\ BẢO\ TOÀN\ HOÀN\ TOÀN\ HỆ\ PHỤ\ THUỘC\ HÀM\ (Dependency\ Preservation).}$$

---

### 2.2. Case Study 2: Phân hệ Đơn thuốc & Dòng thuốc (ChiTietDonThuoc)

Xét quan hệ ban đầu khi gộp đơn thuốc và danh mục thuốc:
$$R_{\text{DonThuocGop}}(\underline{\text{ma\_don\_thuoc}, \text{so\_thu\_tu\_dong}}, \text{ma\_ho\_so}, \text{ma\_bac\_si}, \text{ngay\_ke}, \text{ma\_thuoc}, \text{ten\_thuoc}, \text{don\_gia}, \text{so\_luong}, \text{lieu\_dung})$$

- Khóa chính: $\{\text{ma\_don\_thuoc}, \text{so\_thu\_tu\_dong}\}$.
- Phụ thuộc hàm phát sinh:
  - $fd_1: \{\text{ma\_don\_thuoc}, \text{so\_thu\_tu\_dong}\} \rightarrow \text{ma\_thuoc}, \text{so\_luong}, \text{lieu\_dung}$
  - $fd_2: \text{ma\_don\_thuoc} \rightarrow \text{ma\_ho\_so}, \text{ma\_bac\_si}, \text{ngay\_ke}$ *(Phụ thuộc bộ phận vào một phần khóa $\rightarrow$ Vi phạm 2NF)*
  - $fd_3: \text{ma\_thuoc} \rightarrow \text{ten\_thuoc}, \text{don\_gia}$ *(Phụ thuộc bắc cầu $\rightarrow$ Vi phạm 3NF)*

#### Phân rã chuẩn hóa 3 bảng:
1. `DonThuoc`($\underline{\text{ma\_don\_thuoc}}$, $\text{ma\_ho\_so}$, $\text{ma\_bac\_si}$, $\text{ngay\_ke}$) $\rightarrow$ Đạt **BCNF**.
2. `Thuoc`($\underline{\text{ma\_thuoc}}$, $\text{ten\_thuoc}$, $\text{don\_gia}$) $\rightarrow$ Đạt **BCNF**.
3. `ChiTietDonThuoc`($\underline{\text{ma\_don\_thuoc}, \text{so\_thu\_tu\_dong}}$, $\text{ma\_thuoc}$, $\text{so\_luong}$, $\text{lieu\_dung}$) $\rightarrow$ Đạt **BCNF**.

- Giao của các bảng con đều là siêu khóa của một trong các bảng $\rightarrow$ Nối không mất mát thông tin.
- Mọi FD đều được kiểm tra cục bộ trên từng bảng $\rightarrow$ Bảo toàn phụ thuộc hàm.

---

## 4. PHÂN TÍCH DẠNG CHUẨN 4 (4NF - MULTIVALUED DEPENDENCY)

### 4.1. Khái niệm Phụ thuộc đa trị (Multivalued Dependency - MVD)
Cho quan hệ $R(U)$, và $X, Y \subseteq U$. Ký hiệu $Z = U \setminus (XY)$.
Ta nói $X$ xác định đa trị $Y$ (ký hiệu $X \twoheadrightarrow Y$) nếu với mọi bộ giá trị của $X$, tập các giá trị của $Y$ tương ứng hoàn toàn độc lập với tập các giá trị của $Z$.

### 4.2. Định nghĩa Dạng chuẩn 4 (4NF)
Lược đồ quan hệ $R$ đạt dạng chuẩn 4 (4NF) đối với tập phụ thuộc đa trị $D$ nếu với mọi phụ thuộc đa trị không tầm thường $X \twoheadrightarrow Y \in D^+$ (nghĩa là $Y \not\subseteq X$ và $XY \neq U$), thì **$X$ bắt buộc phải là một siêu khóa của $R$**.

### 4.3. Phân tích thực tế trong Đồ án: Bài toán Bác sĩ - Chuyên khoa - Phòng khám
Xét giả thiết nếu ta thiết kế một bảng lưu trữ phân công bác sĩ:
$$R_{\text{PhanCong}}(\text{ma\_bac\_si}, \text{chung\_chi\_chuyen\_mon}, \text{phong\_kham\_phu\_trach})$$

- **Ngữ cảnh nghiệp vụ y tế:**
  - Một Bác sĩ $BS_1$ có thể có 2 chứng chỉ: `Chẩn đoán hình ảnh` ($C_1$), `Nội soi tiêu hóa` ($C_2$).
  - Bác sĩ $BS_1$ được phân công trực tại 2 phòng: `Phòng 201` ($P_1$), `Phòng 205` ($P_2$).
  - Các chứng chỉ chuyên môn và phòng khám phụ trách hoàn toàn **độc lập** với nhau.
- **Hệ quả nếu để chung 1 bảng:**
  Bảng phải lưu tích Descartes của hai tập hợp:
  $$\begin{matrix}
  \text{ma\_bac\_si} & \text{chung\_chi\_chuyen\_mon} & \text{phong\_kham\_phu\_trach} \\
  \hline
  BS_1 & C_1 & P_1 \\
  BS_1 & C_1 & P_2 \\
  BS_1 & C_2 & P_1 \\
  BS_1 & C_2 & P_2
  \end{matrix}$$
- **Phân tích MVD:**
  - $\text{ma\_bac\_si} \twoheadrightarrow \text{chung\_chi\_chuyen\_mon}$
  - $\text{ma\_bac\_si} \twoheadrightarrow \text{phong\_kham\_phu\_trach}$
  - Khóa của bảng là cả 3 thuộc tính: $\{\text{ma\_bac\_si}, \text{chung\_chi\_chuyen\_mon}, \text{phong\_kham\_phu\_trach}\}$.
  - Tuy nhiên, vế trái $\text{ma\_bac\_si}$ **không phải là siêu khóa** $\rightarrow$ **Vi phạm dạng chuẩn 4NF**!
- **Giải pháp phân rã đạt 4NF:**
  Theo Định lý Fagin, ta phân rã $R_{\text{PhanCong}}$ thành 2 quan hệ riêng biệt:
  1. $R_A(\underline{\text{ma\_bac\_si}, \text{chung\_chi\_chuyen\_mon}})$: Quản lý năng lực chuyên môn của bác sĩ.
  2. $R_B(\underline{\text{ma\_bac\_si}, \text{phong\_kham\_phu\_trach}})$: Quản lý lịch phân công phòng khám.
  - Trong $R_A$ và $R_B$, phụ thuộc đa trị trở thành tầm thường (vì $XY = U$) $\rightarrow$ Cả hai đều đạt **4NF**.

### 4.4. Đánh giá tính thỏa mãn 4NF trên Lược đồ Cơ sở Dữ liệu của Đồ án
Trong thiết kế chuẩn của hệ thống:
1. **Thuộc tính đa trị `so_dien_thoai` trong `Nguoi`**: Được lưu trữ dưới dạng kiểu mảng nguyên tử `TEXT[]` của PostgreSQL. Về mặt ngữ nghĩa quan hệ 1NF/4NF, thuộc tính này là một giá trị đơn nguyên tử gắn với từng thực thể, không gây ra sự kết hợp độc lập nhiều thuộc tính đa trị trên cùng một bộ (tức không tồn tại cùng lúc $X \twoheadrightarrow Y$ và $X \twoheadrightarrow Z$).
2. **Các thực thể nghiệp vụ khác**: Mỗi bảng chỉ biểu diễn đúng một mối quan hệ thực thể, không có bảng nào chứa 2 hoặc nhiều thuộc tính đa trị độc lập.
$\Rightarrow$ **Toàn bộ các lược đồ quan hệ trong hệ thống đều thỏa mãn Dạng chuẩn 4 (4NF).**

