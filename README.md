# 🏥 Hệ thống CSDL Hồ sơ Khám bệnh & Kết quả Xét nghiệm

> Đồ án môn CSDL Nâng cao — Thiết kế CSDL hồ sơ khám bệnh và kết quả xét nghiệm **có lịch sử chỉnh sửa**

## 📋 Mô tả

Hệ thống quản lý toàn bộ quy trình khám bệnh tại bệnh viện, bao gồm:
- Quản lý hồ sơ bệnh nhân và lịch sử khám bệnh
- Quản lý phiếu xét nghiệm và kết quả xét nghiệm đa hình (số liệu, hình ảnh, văn bản)
- Quản lý đơn thuốc
- **Lịch sử chỉnh sửa (Audit Trail)** — ghi nhận mọi thay đổi trên dữ liệu quan trọng

## 🛠️ Công nghệ

- **DBMS:** PostgreSQL 16+
- **Tính năng nâng cao:** Object-Relational (Table Inheritance, Composite Types), JSONB, Array, Transaction Isolation Levels

## 📁 Cấu trúc dự án

```
CSDL_BenhVien/
├── docs/                      # Tài liệu & sơ đồ
│   ├── eer/                   # Sơ đồ EER
│   ├── schemas/               # Lược đồ quan hệ
│   └── data-dictionary/       # Từ điển dữ liệu
├── sql/
│   ├── ddl/                   # CREATE TABLE, TYPE, INDEX, TRIGGER, VIEW
│   ├── dml/                   # INSERT dữ liệu mẫu
│   ├── queries/               # 10–12 truy vấn SQL nâng cao
│   ├── oop/                   # Object-Relational & OQL
│   └── transactions/          # 3 kịch bản transaction
├── tests/                     # Script kiểm thử
├── report/                    # Báo cáo đồ án
└── README.md
```

## 🚀 Hướng dẫn cài đặt & chạy

### Yêu cầu
- PostgreSQL 16+ đã cài đặt
- psql CLI hoặc pgAdmin

### Chạy từ đầu
```bash
# 1. Tạo database
createdb hospital_db

# 2. Chạy DDL
psql -d hospital_db -f sql/ddl/01_create_types.sql
psql -d hospital_db -f sql/ddl/02_create_tables.sql
psql -d hospital_db -f sql/ddl/03_create_indexes.sql
psql -d hospital_db -f sql/ddl/04_create_triggers.sql
psql -d hospital_db -f sql/ddl/05_create_views.sql

# 3. Nạp dữ liệu mẫu
psql -d hospital_db -f sql/dml/seed_data.sql

# 4. Chạy truy vấn nâng cao
psql -d hospital_db -f sql/queries/run_all_queries.sql

# Hoặc chạy tất cả bằng 1 lệnh:
psql -d hospital_db -f run_all.sql
```

## 📊 Các tính năng nổi bật

| Tính năng | Mô tả |
|---|---|
| **Lịch sử chỉnh sửa** | Audit trail tự động qua trigger, lưu JSONB old/new values |
| **Kết quả XN đa hình** | Table Inheritance + JSONB cho kết quả số, hình ảnh, văn bản |
| **12 truy vấn nâng cao** | Subquery, CTE Recursive, Window Function, Dynamic SQL, JSONB Query |
| **Object-Relational** | Composite Types, Table Inheritance, Array, Methods |
| **Transaction Testing** | 3 kịch bản: success, rollback, concurrency (2 phiên) |

## 👥 Tác giả: Huỳnh Tuấn Kiệt

## 📚 Tài liệu tham khảo

1. Elmasri, R. & Navathe, S. — *Fundamentals of Database Systems* (7th ed.)
2. PostgreSQL Documentation — https://www.postgresql.org/docs/current/
3. Silberschatz, A. et al. — *Database System Concepts* (7th ed.)

