-- DCL_user.sql
-- =====================================================================
-- Tahap 0   : Manajemen Pengguna & Hak Akses Database (Modul 1 & DCL)
-- Database  : db_farmasi_pplg2_kel10
-- Kelompok  : 10 (Riyandi, Owen, Ghani)
-- Prasyarat : 01_ddl_init.sql sudah dijalankan (tabel harus ada, karena sebagian GRANT diberikan per tabel) dan jalankan sebagai root (phpMyAdmin: login root, tab SQL).
-- Urutan    : boleh dijalankan kapan saja setelah 01. Cukup sekali, karena CREATE USER dan GRANT disimpan di level server dan tidak hilang walau database dibangun ulang.    
--
-- Role-Based Access Control sesuai penugasan :
--   1. admin_apotek : ALL PRIVILEGES pada seluruh database
--   2. admin_obat   : SELECT/INSERT/UPDATE/DELETE pada tb_obat, tb_golongan_obat, tb_pemasok_pbf             
--   3. kasir_apotek : SELECT/INSERT pada tb_transaksi_obat, SELECT pada tb_obat & tb_pasien_pembeli         
-- =====================================================================

-- =====================================================================
-- 1. PEMBUATAN AKUN (CREATE USER)
-- IF NOT EXISTS agar aman dijalankan berulang.
-- =====================================================================
CREATE USER IF NOT EXISTS 'admin_apotek'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER IF NOT EXISTS 'admin_obat'@'localhost'   IDENTIFIED BY 'obat123';
CREATE USER IF NOT EXISTS 'kasir_apotek'@'localhost' IDENTIFIED BY 'kasir123';

-- =====================================================================
-- 2. PEMBERIAN HAK AKSES (GRANT)
-- =====================================================================

-- 2a. Administrator Apotek: hak penuh (DDL, DML, procedure, trigger)
GRANT ALL PRIVILEGES ON db_farmasi_pplg2_kel10.*
  TO 'admin_apotek'@'localhost';

-- 2b. Admin Obat / Gudang Farmasi: hanya 3 tabel master obat.
--     Tidak diberi akses ke transaksi, pasien, pengguna, dan log.
GRANT SELECT, INSERT, UPDATE, DELETE ON db_farmasi_pplg2_kel10.tb_obat
  TO 'admin_obat'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON db_farmasi_pplg2_kel10.tb_golongan_obat
  TO 'admin_obat'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON db_farmasi_pplg2_kel10.tb_pemasok_pbf
  TO 'admin_obat'@'localhost';

-- 2c. Kasir Apotek / Pelayanan Resep.
--     Boleh menulis transaksi, hanya membaca obat & pasien.
--     Tidak diberi UPDATE/DELETE: koreksi transaksi = wewenang admin.
GRANT SELECT, INSERT ON db_farmasi_pplg2_kel10.tb_transaksi_obat
  TO 'kasir_apotek'@'localhost';
GRANT SELECT ON db_farmasi_pplg2_kel10.tb_obat
  TO 'kasir_apotek'@'localhost';
GRANT SELECT ON db_farmasi_pplg2_kel10.tb_pasien_pembeli
  TO 'kasir_apotek'@'localhost';

FLUSH PRIVILEGES;

-- =====================================================================
-- 3. VERIFIKASI HAK AKSES (screenshot hasilnya)
-- =====================================================================
SHOW GRANTS FOR 'admin_apotek'@'localhost';
SHOW GRANTS FOR 'admin_obat'@'localhost';
SHOW GRANTS FOR 'kasir_apotek'@'localhost';

-- Daftar akun pada server (screenshot tambahan)
SELECT User, Host FROM mysql.user
WHERE User IN ('admin_apotek','admin_obat','kasir_apotek');

-- =====================================================================
-- 4. UJI COBA LOGIN & PEMBATASAN HAK AKSES
-- Dijalankan di Command Prompt / Terminal, bukan di phpMyAdmin.
--
-- A. LOGIN ADMIN APOTEK  (password : admin123)
--    mysql -u admin_apotek -p
--    USE db_farmasi_pplg2_kel10;
--    CREATE TABLE uji_admin (id INT);                          -- BERHASIL
--    DROP TABLE uji_admin;
--    SHOW PROCEDURE STATUS WHERE Db='db_farmasi_pplg2_kel10';  -- BERHASIL
--    SELECT COUNT(*) FROM tb_log_farmasi;                      -- BERHASIL
--
-- B. LOGIN ADMIN OBAT  (password : obat123)
--    mysql -u admin_obat -p
--    USE db_farmasi_pplg2_kel10;
--    SELECT COUNT(*) FROM tb_obat;                       -- BERHASIL
--    UPDATE tb_obat SET stok = stok WHERE id_obat='ob1'; -- BERHASIL
--    SELECT * FROM tb_transaksi_obat;                    -- DITOLAK
--    SELECT * FROM tb_pasien_pembeli;                    -- DITOLAK
--    SELECT * FROM tb_pengguna;                          -- DITOLAK
--    CREATE TABLE uji_obat (id INT);                     -- DITOLAK (tanpa DDL)
--
-- C. LOGIN KASIR APOTEK  (password : kasir123)
--    mysql -u kasir_apotek -p
--    USE db_farmasi_pplg2_kel10;
--    SELECT id_obat, nama_obat, stok FROM tb_obat;                     -- BERHASIL
--    SELECT * FROM tb_pasien_pembeli;                                  -- BERHASIL
--    INSERT INTO tb_transaksi_obat
--      (id_transaksi, id_pasien, id_obat, tanggal_transaksi,
--       jumlah_beli, total_bayar, status_transaksi)
--      VALUES ('tran90','pas1','ob1','2026-11-05',1,5000,'SELESAI');   -- BERHASIL
--    SELECT * FROM tb_transaksi_obat WHERE id_transaksi='tran90';      -- BERHASIL
--    UPDATE tb_obat SET stok = 999 WHERE id_obat='ob1';                -- DITOLAK
--    DELETE FROM tb_transaksi_obat WHERE id_transaksi='tran90';        -- DITOLAK
--    SELECT * FROM tb_log_farmasi;                                     -- DITOLAK
--    SELECT * FROM tb_pengguna;                                        -- DITOLAK
--
-- Setelah uji C, hapus data uji tran90 sebagai admin_apotek:
--    mysql -u admin_apotek -p
--    USE db_farmasi_pplg2_kel10;
--    DELETE FROM tb_transaksi_obat WHERE id_transaksi='tran90';
--    UPDATE tb_obat SET stok = 100 WHERE id_obat='ob1';
--
-- CATATAN : perilaku stok setelah INSERT tran90 bergantung pada ada atau tidaknya 08_trigger.sql.
--   - Tanpa trigger (kondisi sekarang): kasir tidak punya hak UPDATE,
--     jadi stok ob1 TIDAK berubah (tetap 100). Baris UPDATE di bawah
--     hanya pengaman agar nilainya dipastikan 100.
--   - Dengan trigger terpasang: trigger memotong stok 1 menjadi 99,
--     sehingga baris UPDATE tersebut wajib dijalankan.
-- =====================================================================

-- =====================================================================
-- 5. RESET (opsional) – hapus akun bila ingin mengulang dari nol
-- =====================================================================
-- DROP USER IF EXISTS 'admin_apotek'@'localhost';
-- DROP USER IF EXISTS 'admin_obat'@'localhost';
-- DROP USER IF EXISTS 'kasir_apotek'@'localhost';
