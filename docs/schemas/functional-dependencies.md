# 📐 TÀI LIỆU PHÂN TÍCH PHỤ THUỘC HÀM, BAO ĐÓNG & PHỦ TỐI THIỂU
## Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
*(Giai đoạn 2: Chuẩn hóa dữ liệu — Nhiệm vụ Tuần 4)*

---

## 1. CƠ SỞ LÝ THUYẾT NỀN TẢNG

### 1.1. Định nghĩa Phụ thuộc hàm (Functional Dependency - FD)
Cho lược đồ quan hệ $R(U)$ với $U$ là tập thuộc tính, và hai tập con $X, Y \subseteq U$. Ta nói **$X$ xác định hàm $Y$** (hay **$Y$ phụ thuộc hàm vào $X$**), ký hiệu:
$$X \rightarrow Y$$
nếu và chỉ nếu với mọi quan hệ $r$ trên $R$, với hai bộ bất kỳ $t_1, t_2 \in r$, nếu $t_1[X] = t_2[X]$ thì $t_1[Y] = t_2[Y]$.

### 1.2. Hệ tiên đề Armstrong
Tập các quy tắc suy diễn nền tảng:
1. **Phản xạ (Reflexivity)**: Nếu $Y \subseteq X$, thì $X \rightarrow Y$.
2. **Tăng trưởng (Augmentation)**: Nếu $X \rightarrow Y$, thì $XZ \rightarrow YZ$ với mọi tập thuộc tính $Z$.
3. **Bắc cầu (Transitivity)**: Nếu $X \rightarrow Y$ và $Y \rightarrow Z$, thì $X \rightarrow Z$.

Các quy tắc dẫn xuất:
- **Quy tắc hợp (Union)**: Nếu $X \rightarrow Y$ và $X \rightarrow Z$, thì $X \rightarrow YZ$.
- **Quy tắc phân rã (Decomposition)**: Nếu $X \rightarrow YZ$, thì $X \rightarrow Y$ và $X \rightarrow Z$.
- **Quy tắc tựa bắc cầu (Pseudo-transitivity)**: Nếu $X \rightarrow Y$ và $WY \rightarrow Z$, thì $WX \rightarrow Z$.

### 1.3. Bao đóng của tập thuộc tính (Attribute Closure - $X^+$)
Bao đóng của tập thuộc tính $X$ đối với tập phụ thuộc hàm $F$, ký hiệu $X^+_F$, là tập hợp tất cả các thuộc tính $A \in U$ sao cho $X \rightarrow A$ có thể được suy diễn logic từ $F$ bằng hệ tiên đề Armstrong.

**Thuật toán tìm $X^+$:**
- **Đầu vào:** Tập thuộc tính $U$, tập phụ thuộc hàm $F$, tập thuộc tính $X \subseteq U$.
- **Đầu ra:** Bao đóng $X^+$.
- **Các bước:**
  1. Khởi tạo: $\text{Closure} = X$.
  2. Lặp lại bước sau cho đến khi $\text{Closure}$ không thay đổi:
     - Với mỗi $Y \rightarrow Z \in F$:
       - Nếu $Y \subseteq \text{Closure}$ thì $\text{Closure} = \text{Closure} \cup Z$.
  3. Trả về $X^+ = \text{Closure}$.

### 1.4. Định nghĩa Siêu khóa và Khóa ứng viên (Superkey & Candidate Key)
- **Siêu khóa (Superkey)**: Tập thuộc tính $K \subseteq U$ là một siêu khóa của $R$ nếu $K^+ = U$.
- **Khóa ứng viên (Candidate Key - Khóa tối thiểu)**: $K$ là khóa ứng viên của $R$ nếu:
  1. $K$ là một siêu khóa ($K^+ = U$).
  2. Không tồn tại tập con thực sự $K' \subset K$ sao cho $(K')^+ = U$ (tính tối thiểu).

### 1.5. Phủ tối thiểu (Minimal Cover / Canonical Cover - $F_{\min}$)
Một tập phụ thuộc hàm $F_{\min}$ được gọi là phủ tối thiểu của tập $F$ nếu $F_{\min} \equiv F$ (tương đương logic) và thỏa mãn 3 điều kiện:
1. **Đơn thuộc tính vế phải (Standard Form)**: Mọi FD trong $F_{\min}$ đều có dạng $X \rightarrow A$, với $A$ là thuộc tính đơn lẻ.
2. **Không có thuộc tính dư thừa vế trái (Left-reduced)**: Không tồn tại $X \rightarrow A \in F_{\min}$ và $B \in X$ sao cho $(F_{\min} \setminus \{X \rightarrow A\}) \cup \{(X \setminus \{B\}) \rightarrow A\} \equiv F_{\min}$.
3. **Không có phụ thuộc hàm dư thừa (Non-redundant)**: Không tồn tại bất kỳ FD nào trong $F_{\min}$ có thể suy diễn từ các FD còn lại: $\forall f \in F_{\min}, (F_{\min} \setminus \{f\}) \not\models f$.

---

## 2. XÁC ĐỊNH HỆ PHỤ THUỘC HÀM CHO CÁC QUAN HỆ TRỌNG TÂM

Dựa trên nghiệp vụ y tế đã xác lập ở Tuần 1–3, ta phân tích tập phụ thuộc hàm cho 7 lược đồ quan hệ cốt lõi:

### 2.1. Quan hệ `Nguoi`
- **Tập thuộc tính:**
  $$U_{\text{Nguoi}} = \{\text{ma\_dinh\_danh}, \text{ho\_ten}, \text{ngay\_sinh}, \text{gioi\_tinh}, \text{dia\_chi}, \text{so\_dien\_thoai}\}$$
- **Tập phụ thuộc hàm $F_{\text{Nguoi}}$:**
  - $fd_1: \text{ma\_dinh\_danh} \rightarrow \text{ho\_ten}$
  - $fd_2: \text{ma\_dinh\_danh} \rightarrow \text{ngay\_sinh}$
  - $fd_3: \text{ma\_dinh\_danh} \rightarrow \text{gioi\_tinh}$
  - $fd_4: \text{ma\_dinh\_danh} \rightarrow \text{dia\_chi}$
  - $fd_5: \text{ma\_dinh\_danh} \rightarrow \text{so\_dien\_thoai}$ *(Lưu ý: `so_dien_thoai` dạng kiểu mảng `TEXT[]` được coi là một giá trị phức hợp đơn nguyên tử trong quan hệ)*

### 2.2. Quan hệ `BenhNhan`
- **Tập thuộc tính:**
  $$U_{\text{BN}} = \{\text{ma\_benh\_nhan}, \text{ma\_dinh\_danh}, \text{nhom\_mau}, \text{tien\_su\_di\_ung}, \text{tien\_su\_benh}\}$$
- **Tập phụ thuộc hàm $F_{\text{BN}}$:**
  - $fd_1: \text{ma\_benh\_nhan} \rightarrow \text{ma\_dinh\_danh}, \text{nhom\_mau}, \text{tien\_su\_di\_ung}, \text{tien\_su\_benh}$
  - $fd_2: \text{ma\_dinh\_danh} \rightarrow \text{ma\_benh\_nhan}$ *(Mỗi công dân đăng ký khám chỉ được cấp duy nhất 1 mã hồ sơ bệnh nhân y tế suốt đời)*

### 2.3. Quan hệ `BacSi`
- **Tập thuộc tính:**
  $$U_{\text{BS}} = \{\text{ma\_nhan\_vien}, \text{chung\_chi\_hanh\_nghe}, \text{chuyen\_khoa\_chinh}, \text{ma\_khoa\_phong}\}$$
- **Tập phụ thuộc hàm $F_{\text{BS}}$:**
  - $fd_1: \text{ma\_nhan\_vien} \rightarrow \text{chung\_chi\_hanh\_nghe}, \text{chuyen\_khoa\_chinh}, \text{ma\_khoa\_phong}$
  - $fd_2: \text{chung\_chi\_hanh\_nghe} \rightarrow \text{ma\_nhan\_vien}, \text{chuyen\_khoa\_chinh}$ *(Chứng chỉ hành nghề do Bộ Y tế cấp là định danh độc nhất của bác sĩ)*

### 2.4. Quan hệ `HoSoKhamBenh` (Hồ sơ khám lâm sàng)
- **Tập thuộc tính:**
  $$U_{\text{HS}} = \{\text{ma\_ho\_so}, \text{ma\_benh\_nhan}, \text{ma\_bac\_si\_kham}, \text{ma\_phong\_kham}, \text{thoi\_gian\_tiep\_nhan}, \text{mach}, \text{nhiet\_do}, \text{huyet\_ap\_tam\_thu}, \text{huyet\_ap\_tam\_truong}, \text{chieu\_cao}, \text{can\_nang}, \text{ly\_do\_kham}, \text{chan\_doan\_xac\_dinh}, \text{trang\_thai\_kham}, \text{is\_deleted}\}$$
- **Tập phụ thuộc hàm $F_{\text{HS}}$:**
  - $fd_1: \text{ma\_ho\_so} \rightarrow \text{ma\_benh\_nhan}, \text{ma\_bac\_si\_kham}, \text{ma\_phong\_kham}, \text{thoi\_gian\_tiep\_nhan}, \text{mach}, \text{nhiet\_do}, \text{huyet\_ap\_tam\_thu}, \text{huyet\_ap\_tam\_truong}, \text{chieu\_cao}, \text{can\_nang}, \text{ly\_do\_kham}, \text{chan\_doan\_xac\_dinh}, \text{trang\_thai\_kham}, \text{is\_deleted}$
  - $fd_2: \{\text{ma\_benh\_nhan}, \text{thoi\_gian\_tiep\_nhan}\} \rightarrow \text{ma\_ho\_so}$ *(Tại một thời điểm cụ thể, một bệnh nhân chỉ có thể mở đúng một hồ sơ lượt khám)*

### 2.5. Quan hệ `KetQuaDinhLuong` (Đa hình Kết quả xét nghiệm số học)
- **Tập thuộc tính:**
  $$U_{\text{KQ\_DL}} = \{\text{ma\_ket\_qua}, \text{ma\_phieu\_chi\_dinh}, \text{ma\_danh\_muc\_xn}, \text{ma\_ktv\_thuc\_hien}, \text{gia\_tri\_do}, \text{don\_vi\_tinh}, \text{chi\_so\_min\_chuan}, \text{chi\_so\_max\_chuan}, \text{muc\_do\_canh\_bao}, \text{so\_phien\_ban}, \text{is\_deleted}\}$$
- **Tập phụ thuộc hàm $F_{\text{KQ\_DL}}$:**
  - $fd_1: \text{ma\_ket\_qua} \rightarrow \text{ma\_phieu\_chi\_dinh}, \text{ma\_danh\_muc\_xn}, \text{ma\_ktv\_thuc\_hien}, \text{gia\_tri\_do}, \text{muc\_do\_canh\_bao}, \text{so\_phien\_ban}, \text{is\_deleted}$
  - $fd_2: \text{ma\_danh\_muc\_xn} \rightarrow \text{don\_vi\_tinh}, \text{chi\_so\_min\_chuan}, \text{chi\_so\_max\_chuan}$ *(Mỗi xét nghiệm chuẩn có đơn vị và khoảng tham chiếu sinh lý cố định)*
  - $fd_3: \{\text{ma\_phieu\_chi\_dinh}, \text{ma\_danh\_muc\_xn}\} \rightarrow \text{ma\_ket\_qua}$ *(Trong cùng 1 phiếu chỉ định, mỗi xét nghiệm chỉ làm 1 lần)*

### 2.6. Quan hệ `DonThuoc` & `ChiTietDonThuoc` (Phân hệ Dược)
- **Tập thuộc tính bảng Thuốc:**
  $$U_{\text{Thuoc}} = \{\text{ma\_thuoc}, \text{ten\_thuoc}, \text{hoat\_chat}, \text{ham\_luong}, \text{dang\_bao\_che}, \text{don\_vi\_tinh}, \text{don\_gia}\}$$
  $$F_{\text{Thuoc}} = \{\text{ma\_thuoc} \rightarrow \text{ten\_thuoc}, \text{hoat\_chat}, \text{ham\_luong}, \text{dang\_bao\_che}, \text{don\_vi\_tinh}, \text{don\_gia}\}$$
- **Tập thuộc tính bảng ChiTietDonThuoc:**
  $$U_{\text{CTDT}} = \{\text{ma\_don\_thuoc}, \text{so\_thu\_tu\_dong}, \text{ma\_thuoc}, \text{so\_luong}, \text{lieu\_dung\_moi\_lan}, \text{so\_lan\_uong\_ngay}, \text{thoi\_diem\_uong}, \text{so\_ngay\_dung}\}$$
  $$F_{\text{CTDT}} = \{\{\text{ma\_don\_thuoc}, \text{so\_thu\_tu\_dong}\} \rightarrow \text{ma\_thuoc}, \text{so\_luong}, \text{lieu\_dung\_moi\_lan}, \text{so\_lan\_uong\_ngay}, \text{thoi\_diem\_uong}, \text{so\_ngay\_dung}\}$$

---

## 3. TÍNH TOÁN BAO ĐÓNG VÀ XÁC ĐỊNH KHÓA (STEP-BY-STEP)

### 3.1. Tính bao đóng và xác định khóa của quan hệ `BenhNhan`
Cho $U = \{\text{ma\_benh\_nhan}, \text{ma\_dinh\_danh}, \text{nhom\_mau}, \text{tien\_su\_di\_ung}, \text{tien\_su\_benh}\}$ và:
$$F = \{\text{ma\_benh\_nhan} \rightarrow \text{ma\_dinh\_danh}, \text{nhom\_mau}, \text{tien\_su\_di\_ung}, \text{tien\_su\_benh}; \quad \text{ma\_dinh\_danh} \rightarrow \text{ma\_benh\_nhan}\}$$

- **Bước 1: Tính bao đóng của $\{\text{ma\_benh\_nhan}\}$**:
  - Khởi tạo: $\text{Closure} = \{\text{ma\_benh\_nhan}\}$.
  - Áp dụng $fd_1$: Thấy $\{\text{ma\_benh\_nhan}\} \subseteq \text{Closure}$, bổ sung các thuộc tính vế phải:
    $$\text{Closure} = \{\text{ma\_benh\_nhan}, \text{ma\_dinh\_danh}, \text{nhom\_mau}, \text{tien\_su\_di\_ung}, \text{tien\_su\_benh}\} = U$$
  - $\Rightarrow \{\text{ma\_benh\_nhan}\}^+ = U \Rightarrow \{\text{ma\_benh\_nhan}\}$ là một siêu khóa. Vì là thuộc tính đơn nên nó là một **Khóa ứng viên (Candidate Key 1)**.

- **Bước 2: Tính bao đóng của $\{\text{ma\_dinh\_danh}\}$**:
  - Khởi tạo: $\text{Closure} = \{\text{ma\_dinh\_danh}\}$.
  - Áp dụng $fd_2$: Thấy $\{\text{ma\_dinh\_danh}\} \subseteq \text{Closure} \Rightarrow \text{Closure} = \{\text{ma\_dinh\_danh}, \text{ma\_benh\_nhan}\}$.
  - Áp dụng $fd_1$: Thấy $\{\text{ma\_benh\_nhan}\} \subseteq \text{Closure} \Rightarrow \text{Closure} = U$.
  - $\Rightarrow \{\text{ma\_dinh\_danh}\}^+ = U \Rightarrow \{\text{ma\_dinh\_danh}\}$ là một **Khóa ứng viên (Candidate Key 2)**.

- **Kết luận:** Quan hệ `BenhNhan` có 2 khóa ứng viên:
  $$\mathcal{K}(\text{BenhNhan}) = \{\{\text{ma\_benh\_nhan}\}, \{\text{ma\_dinh\_danh}\}\}$$
  Ta chọn $\text{ma\_benh\_nhan}$ làm **Khóa chính (Primary Key)**, $\text{ma\_dinh\_danh}$ làm **Khóa duy nhất (Alternate / Unique Key)**.

---

### 3.2. Tính bao đóng và xác định khóa của quan hệ `KetQuaDinhLuong`
Xét tập thuộc tính rút gọn đại diện:
$$U = \{K, P, D, T, V, U, N, X, W, S\}$$
Trong đó: $K$ (ma_ket_qua), $P$ (ma_phieu_chi_dinh), $D$ (ma_danh_muc_xn), $T$ (ma_ktv), $V$ (gia_tri_do), $U$ (don_vi_tinh), $N$ (chi_so_min), $X$ (chi_so_max), $W$ (canh_bao), $S$ (so_phien_ban).

Tập FD:
- $fd_1: K \rightarrow P, D, T, V, W, S$
- $fd_2: D \rightarrow U, N, X$
- $fd_3: \{P, D\} \rightarrow K$

- **Tính bao đóng $\{K\}^+$:**
  1. $\text{Closure} = \{K\}$
  2. Áp dụng $fd_1: \text{Closure} = \{K, P, D, T, V, W, S\}$
  3. Áp dụng $fd_2$: Do $D \in \text{Closure} \Rightarrow \text{Closure} = \{K, P, D, T, V, W, S, U, N, X\} = U$.
  $\Rightarrow \{K\}^+ = U \Rightarrow \{K\}$ là **Khóa ứng viên 1**.

- **Tính bao đóng $\{P, D\}^+$:**
  1. $\text{Closure} = \{P, D\}$
  2. Áp dụng $fd_3: \text{Closure} = \{P, D, K\}$
  3. Áp dụng $fd_1: \text{Closure} = \{P, D, K, T, V, W, S\}$
  4. Áp dụng $fd_2: \text{Closure} = \{P, D, K, T, V, W, S, U, N, X\} = U$.
  $\Rightarrow \{P, D\}^+ = U$.
  Kiểm tra tính tối thiểu: $\{P\}^+ = \{P\} \neq U$, $\{D\}^+ = \{D, U, N, X\} \neq U$.
  $\Rightarrow \{P, D\}$ là **Khóa ứng viên 2**.

- **Kết luận:** $\mathcal{K} = \{\{K\}, \{P, D\}\}$. Chọn $\{K\}$ làm Khóa chính (PK).

---

## 4. THUẬT TOÁN VÀ TÍNH TOÁN PHỦ TỐI THIỂU (CANONICAL COVER)

Ta xét tập phụ thuộc hàm tổng hợp của phân hệ **Chỉ định & Kết quả xét nghiệm định lượng**:

Tập thuộc tính: $U = \{K, P, D, T, V, U, N, X, W, S\}$
Tập phụ thuộc ban đầu $F$:
1. $f_1: K \rightarrow P$
2. $f_2: K \rightarrow D, T, V$
3. $f_3: K \rightarrow W, S$
4. $f_4: D \rightarrow U, N$
5. $f_5: D \rightarrow X$
6. $f_6: \{P, D\} \rightarrow K$
7. $f_7: \{K, D\} \rightarrow P$ *(FD phát sinh do liên kết thừa)*

---

### Bước 1: Phân rã vế phải thành đơn thuộc tính (RHS Decomposition)
Tách toàn bộ các FD có vế phải nhiều thuộc tính thành dạng $X \rightarrow A$:
- Từ $f_2: K \rightarrow D, T, V \Rightarrow K \rightarrow D$, $K \rightarrow T$, $K \rightarrow V$.
- Từ $f_3: K \rightarrow W, S \Rightarrow K \rightarrow W$, $K \rightarrow S$.
- Từ $f_4: D \rightarrow U, N \Rightarrow D \rightarrow U$, $D \rightarrow N$.

Ta thu được tập $F_1$:
1. $K \rightarrow P$
2. $K \rightarrow D$
3. $K \rightarrow T$
4. $K \rightarrow V$
5. $K \rightarrow W$
6. $K \rightarrow S$
7. $D \rightarrow U$
8. $D \rightarrow N$
9. $D \rightarrow X$
10. $PD \rightarrow K$
11. $KD \rightarrow P$

---

### Bước 2: Loại bỏ thuộc tính dư thừa ở vế trái (Extraneous Left Attributes)
Xét các FD có từ 2 thuộc tính trở lên ở vế trái:
- **Xét $f_{11}: KD \rightarrow P$**:
  - Xét xem $D$ có dư thừa không? Tính bao đóng của $(KD \setminus \{D\})^+ = \{K\}^+$ đối với $F_1$:
    - $\{K\}^+_{F_1}$:
      - Bắt đầu với $\{K\}$.
      - Có $K \rightarrow P$ (từ $f_1$) $\Rightarrow P \in \{K\}^+$.
    - Vì $P \in \{K\}^+$, thuộc tính $D$ ở vế trái của $KD \rightarrow P$ là **dư thừa**!
    - Thay thế $KD \rightarrow P$ bằng $K \rightarrow P$.
    - Tuy nhiên, ta đã có sẵn $f_1: K \rightarrow P$, do đó $f_{11}$ bị rút gọn thành trùng lắp.

- **Xét $f_{10}: PD \rightarrow K$**:
  - Xét $P$ có dư thừa không? Tính $\{D\}^+_{F_1}$:
    - $\{D\}^+ = \{D, U, N, X\}$. Không chứa $K \Rightarrow P$ **không dư thừa**.
  - Xét $D$ có dư thừa không? Tính $\{P\}^+_{F_1}$:
    - $\{P\}^+ = \{P\}$. Không chứa $K \Rightarrow D$ **không dư thừa**.
  - $\Rightarrow PD \rightarrow K$ giữ nguyên vẹn.

Tập sau Bước 2:
$$F_2 = \{K \rightarrow P, K \rightarrow D, K \rightarrow T, K \rightarrow V, K \rightarrow W, K \rightarrow S, D \rightarrow U, D \rightarrow N, D \rightarrow X, PD \rightarrow K\}$$

---

### Bước 3: Loại bỏ phụ thuộc hàm dư thừa (Redundant FDs)
Thử loại bỏ từng FD $f: X \rightarrow Y \in F_2$ và kiểm tra xem $Y$ có còn thuộc $X^+_{(F_2 \setminus \{f\})}$ hay không:

1. **Thử bỏ $K \rightarrow P$**:
   - Tính $\{K\}^+_{(F_2 \setminus \{K \rightarrow P\})}$:
   - Khởi tạo: $\text{Closure} = \{K\}$.
   - Có $K \rightarrow D, K \rightarrow T, K \rightarrow V, K \rightarrow W, K \rightarrow S \Rightarrow \text{Closure} = \{K, D, T, V, W, S\}$.
   - Có $D \rightarrow U, D \rightarrow N, D \rightarrow X \Rightarrow \text{Closure} = \{K, D, T, V, W, S, U, N, X\}$.
   - Không có luật nào suy ra được $P$ vì chưa có $P$ để kích hoạt $PD \rightarrow K$.
   - $\Rightarrow P \notin \{K\}^+ \Rightarrow K \rightarrow P$ **không dư thừa (bắt buộc giữ lại)**.

2. **Thử bỏ $K \rightarrow D$**:
   - Tương tự, nếu bỏ $K \rightarrow D$, $\{K\}^+ = \{K, P, T, V, W, S\}$. Không có cách nào suy ra $D$.
   - $\Rightarrow K \rightarrow D$ **không dư thừa (bắt buộc giữ lại)**.

3. **Kiểm tra tương tự cho toàn bộ các FD còn lại:**
   - Không có FD nào suy diễn bắc cầu được qua các thuộc tính khác để tạo thành chu trình dư thừa.

---

### KẾT QUẢ PHỦ TỐI THIỂU ($F_{\min}$)
Gộp các thuộc tính có cùng vế trái (đưa về dạng thu gọn chuẩn):
$$F_{\min} = \begin{cases}
K \rightarrow \{P, D, T, V, W, S\} \\
D \rightarrow \{U, N, X\} \\
PD \rightarrow K
\end{cases}$$

Hay theo ngữ nghĩa y khoa:
$$\begin{cases}
\text{ma\_ket\_qua} \rightarrow \{\text{ma\_phieu\_chi\_dinh}, \text{ma\_danh\_muc\_xn}, \text{ma\_ktv\_thuc\_hien}, \text{gia\_tri\_do}, \text{muc\_do\_canh\_bao}, \text{so\_phien\_ban}\} \\
\text{ma\_danh\_muc\_xn} \rightarrow \{\text{don\_vi\_tinh}, \text{chi\_so\_min\_chuan}, \text{chi\_so\_max\_chuan}\} \\
\{\text{ma\_phieu\_chi\_dinh}, \text{ma\_danh\_muc\_xn}\} \rightarrow \text{ma\_ket\_qua}
\end{cases}$$

> [!IMPORTANT]
> **Ý nghĩa của kết quả phủ tối thiểu đối với chuẩn hóa ở Tuần 5:**
> Nhìn vào $F_{\min}$, ta phát hiện ngay:
> - Trong lược đồ quan hệ kết quả xét nghiệm, thuộc tính $\text{ma\_danh\_muc\_xn}$ xác định $\{\text{don\_vi\_tinh}, \text{chi\_so\_min\_chuan}, \text{chi\_so\_max\_chuan}\}$.
> - Tuy nhiên, $\text{ma\_danh\_muc\_xn}$ **KHÔNG PHẢI LÀ SIÊU KHÓA** của bảng kết quả!
> - Đây chính là bằng chứng toán học chứng minh quan hệ ban đầu **vi phạm dạng chuẩn BCNF và 3NF** (phụ thuộc bắc cầu: $\text{ma\_ket\_qua} \rightarrow \text{ma\_danh\_muc\_xn} \rightarrow \{\text{don\_vi\_tinh}, \dots\}$).
> - Điều này chứng minh việc tách bảng `DanhMucXetNghiem` và `KetQuaDinhLuong` là bắt buộc về mặt lý thuyết để đạt chuẩn BCNF ở Tuần 5!

