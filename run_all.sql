-- ============================================================================
-- MASTER SCRIPT: CHẠY TOÀN BỘ DDL VÀ SEED DATA THEO ĐÚNG THỨ TỰ
-- Đề tài: CSDL Hồ sơ Khám bệnh và Kết quả Xét nghiệm có Lịch sử Chỉnh sửa
-- Hướng dẫn chạy: psql -h localhost -p 5433 -U postgres -d hospital_db -f run_all.sql
-- ============================================================================

\echo '----------------------------------------------------------------------'
\echo '1. Dang tao Types, Enums va Domains...'
\i sql/ddl/01_create_types.sql

\echo '----------------------------------------------------------------------'
\echo '2. Dang tao cac Bang quan he va Bang huong doi tuong (Table Inheritance)...'
\i sql/ddl/02_create_tables.sql

\echo '----------------------------------------------------------------------'
\echo '3. Dang tao cac Chi muc B-tree, GIN va Partial Indexes...'
\i sql/ddl/03_create_indexes.sql

\echo '----------------------------------------------------------------------'
\echo '4. Dang tao cac Trigger tu dong hoa Audit Trail va Rang buoc phap ly...'
\i sql/ddl/04_create_triggers.sql

\echo '----------------------------------------------------------------------'
\echo '5. Dang tao cac Khung nhin (Views)...'
\i sql/ddl/05_create_views.sql

\echo '----------------------------------------------------------------------'
\echo '6. Dang nap Du lieu mau quy mo lon (Seed Data)...'
\i sql/dml/seed_data.sql

\echo '======================================================================'
\echo 'HOAN TAT KHOI TAO CSDL HO SO BENH VIEN THANH CONG!'
\echo '======================================================================'
