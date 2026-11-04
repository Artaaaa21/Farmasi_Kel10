-- 02_dml_data.sql
-- ========================================================
-- Tahap 2  : DML - Pengisian Data (Modul 3 : SQL DML Lanjutan)
-- Database : db_farmasi_pplg2_kel10
-- Kelompok : 10 (Riyandi, Owen, Ghani)
-- Prasyarat: 01_ddl_init.sql sudah dijalankan.
-- ========================================================

USE db_farmasi_pplg2_kel10;

START TRANSACTION;

-- ========================================================
-- BAGIAN 1. MENGISI DATA
-- ========================================================

-- --------------------------------------------------------
-- 1. tb_golongan_obat (4 baris)
-- --------------------------------------------------------
INSERT INTO tb_golongan_obat (id_golongan, nama_golongan) VALUES
('gol1', 'Obat Resep'),
('gol2', 'Obat Vitamin'),
('gol3', 'Obat Keras'),
('gol4', 'Obat Herbal');

-- --------------------------------------------------------
-- 2. tb_pemasok_pbf (4 baris)
-- --------------------------------------------------------
INSERT INTO tb_pemasok_pbf (id_pemasok, nama_pemasok, kota_asal, kontak) VALUES
('PBF1', 'PT Kimia Farma',      'Samarinda', '081234567890'),
('PBF2', 'PT Indofarma',        'Balikpapan', '081298765432'),
('PBF3', 'PT Pharos Indonesia', 'Jakarta',   '082112345678'),
('PBF4', 'PT Kalbe Farma',      'Jakarta',   '085212345678');

-- --------------------------------------------------------
-- 3. tb_pasien_pembeli (7 baris)
-- --------------------------------------------------------
INSERT INTO tb_pasien_pembeli (id_pasien, nama_pasien, jenis_kelamin, alamat, tanggal_daftar) VALUES
('pas1', 'Aura',         'P', 'Jl. Merdeka No. 10',    '2026-10-01'),
('pas2', 'Nopia',        'P', 'Jl. Diponegoro No. 15', '2026-10-02'),
('pas3', 'Rizky Praama', 'L', 'Jl. Pahlawan No. 21',   '2026-10-03'),
('pas4', 'Riyandi',      'L', 'Jl. Ahmad Yani No. 8',  '2026-10-04'),
('pas5', 'Dhanis',       'L', 'Jl. Gajah Mada No. 12', '2026-10-05'),
('pas6', 'Vita',         'P', 'Jl. Sudirman No. 45',   '2026-10-06'),
('pas7', 'Ares',         'L', 'Jl. Pemuda No. 18',     '2026-10-07');

-- --------------------------------------------------------
-- 4. tb_pengguna (3 baris)
-- --------------------------------------------------------
INSERT INTO tb_pengguna (id_user, username, password, nama_lengkap, role) VALUES
('111', 'admin_apotek', 'admin123', 'Admin Apotik', 'ADMIN'),
('222', 'admin_obat',   'obat123',  'Admin Obat',   'ADMIN_OBAT'),
('333', 'kasir_apotek', 'kasir123', 'Kasir Apotik', 'KASIR');

-- --------------------------------------------------------
-- 5. tb_obat (10 baris) — urutan id mengikuti dump
-- --------------------------------------------------------
INSERT INTO tb_obat (id_obat, id_golongan, id_pemasok, nama_obat, harga_satuan, stok) VALUES
('ob1',  'gol1', 'PBF1', 'Paracetamol 500mg',  5000,  100),
('ob10', 'gol1', 'PBF2', 'OBH Combi Batuk',    18500, 65),
('ob2',  'gol1', 'PBF2', 'Antasida Tablet',    4000,  80),
('ob3',  'gol2', 'PBF3', 'Vitamin C',          12000, 50),
('ob4',  'gol3', 'PBF4', 'Amoxicillin 500mg',  10000, 60),
('ob5',  'gol4', 'PBF1', 'Tolak Angin',        3500,  120),
('ob6',  'gol1', 'PBF2', 'Ibuprofen 400mg',    6000,  75),
('ob7',  'gol2', 'PBF3', 'Cetirizine 10mg',    8000,  90),
('ob8',  'gol3', 'PBF1', 'Promag Tablet',      8500,  110),
('ob9',  'gol4', 'PBF4', 'Cefadroxil 500mg',   15000, 40);

-- --------------------------------------------------------
-- 6. tb_transaksi_obat (5 baris)
-- total_bayar konsisten dengan jumlah_beli x harga_satuan.
-- --------------------------------------------------------
INSERT INTO tb_transaksi_obat (id_transaksi, id_pasien, id_obat, tanggal_transaksi, jumlah_beli, total_bayar, status_transaksi) VALUES
('tran1', 'pas1', 'ob1', '2026-10-06', 2, 10000, 'SELESAI'),
('tran2', 'pas2', 'ob2', '2026-10-06', 3, 12000, 'SELESAI'),
('tran3', 'pas3', 'ob3', '2026-10-07', 1, 12000, 'SELESAI'),
('tran4', 'pas4', 'ob4', '2026-10-07', 2, 20000, 'SELESAI'),
('tran5', 'pas5', 'ob5', '2026-10-08', 4, 14000, 'SELESAI');

-- --------------------------------------------------------
-- 7. tb_log_farmasi (5 baris)
-- --------------------------------------------------------
INSERT INTO tb_log_farmasi (id_log, nama_operasi, rincian, waktu_eksekusi) VALUES
(1, 'INSERT OBAT',   'Menambahkan Paracetamol 500mg ke data obat', '2026-10-06 08:30:00'),
(2, 'INSERT PASIEN', 'Menambahkan pasien Andi Setiawan',           '2026-10-06 09:00:00'),
(3, 'TRANSAKSI',     'Transaksi tran1 berhasil dilakukan',         '2026-10-06 10:15:00'),
(4, 'TRANSAKSI',     'Transaksi tran2 berhasil dilakukan',         '2026-10-06 11:20:00'),
(5, 'UPDATE STOK',   'Stok obat diperbarui setelah transaksi',     '2026-10-07 14:30:00');

COMMIT;

-- ========================================================
-- BAGIAN 2. VERIFIKASI (output untuk screenshot)
-- Hasil yang diharapkan: 4, 4, 10, 7, 3, 5, 5
-- ========================================================
SELECT 'tb_golongan_obat'  AS tabel, COUNT(*) AS jumlah FROM tb_golongan_obat
UNION ALL SELECT 'tb_pemasok_pbf',    COUNT(*) FROM tb_pemasok_pbf
UNION ALL SELECT 'tb_obat',           COUNT(*) FROM tb_obat
UNION ALL SELECT 'tb_pasien_pembeli', COUNT(*) FROM tb_pasien_pembeli
UNION ALL SELECT 'tb_pengguna',       COUNT(*) FROM tb_pengguna
UNION ALL SELECT 'tb_transaksi_obat', COUNT(*) FROM tb_transaksi_obat
UNION ALL SELECT 'tb_log_farmasi',    COUNT(*) FROM tb_log_farmasi;

-- Total pendapatan (dipakai sp_total_pendapatan di file 07) -> 68000
SELECT SUM(total_bayar) AS total_pendapatan FROM tb_transaksi_obat;

-- ========================================================
-- BAGIAN 3. OPSIONAL 1: OBAT "FORTE" (disarankan diaktifkan)
-- Tahap 2 menuntut kueri LIKE '%FORTE%', sedangkan dump belum
-- punya obat bernama FORTE. Satu baris UPDATE ini membuat kueri
-- tersebut menghasilkan data tanpa menambah baris tabel.
-- ========================================================
-- UPDATE tb_obat SET nama_obat = 'OBH Combi Batuk FORTE' WHERE id_obat = 'ob10';

-- ========================================================
-- BAGIAN 4. OPSIONAL 2: TAMBAHAN BARIS (tidak aktif)
-- Aktifkan hanya bila dosen meminta minimal 10 baris di semua tabel.
-- Catatan: menambah baris mengubah hasil agregasi di 04 dan 06.
-- ========================================================
-- INSERT INTO tb_golongan_obat (id_golongan, nama_golongan) VALUES
-- ('gol5', 'Obat Bebas'), ('gol6', 'Obat Generik'), ('gol7', 'Alat Kesehatan'),
-- ('gol8', 'Suplemen'),   ('gol9', 'Obat Salep'),   ('gol10','Obat Tetes');
--
-- INSERT INTO tb_pemasok_pbf (id_pemasok, nama_pemasok, kota_asal, kontak) VALUES
-- ('PBF5', 'PT Sanbe Farma',        'Bandung',   '081311112222'),
-- ('PBF6', 'PT Dexa Medica',        'Palembang', '081355556666'),
-- ('PBF7', 'PT Soho Industri',      'Jakarta',   '081377778888'),
-- ('PBF8', 'PT Tempo Scan',         'Jakarta',   '081399990000'),
-- ('PBF9', 'PT Bernofarm',          'Sidoarjo',  '082111112222'),
-- ('PBF10','PT Guardian Pharmatama','Bekasi',    '082133334444');
--
-- INSERT INTO tb_pasien_pembeli (id_pasien, nama_pasien, jenis_kelamin, alamat, tanggal_daftar) VALUES
-- ('pas8',  'Nabila',    'P', 'Jl. Cendrawasih No. 3', '2026-10-08'),
-- ('pas9',  'Farhan',    'L', 'Jl. Melati No. 27',     '2026-10-09'),
-- ('pas10', 'Salsabila', 'P', 'Jl. Kenanga No. 14',    '2026-10-10');
--
-- INSERT INTO tb_pengguna (id_user, username, password, nama_lengkap, role) VALUES
-- ('444', 'admin_gudang', 'gudang123', 'Admin Gudang', 'ADMIN_OBAT'),
-- ('555', 'kasir_dua',    'kasir456',  'Kasir Dua',    'KASIR'),
-- ('666', 'kasir_tiga',   'kasir789',  'Kasir Tiga',   'KASIR'),
-- ('777', 'admin_resep',  'resep123',  'Admin Resep',  'ADMIN_OBAT'),
-- ('888', 'kasir_malam',  'malam123',  'Kasir Malam',  'KASIR'),
-- ('999', 'admin_inventori','inv123',  'Admin Inventori','ADMIN_OBAT'),
-- ('1000','kasir_pagi',   'pagi123',   'Kasir Pagi',   'KASIR');

-- ========================================================
-- BAGIAN 5. RESET DATA (opsional)
-- Urutan anak -> induk. Cara terbersih tetap: jalankan ulang 01 lalu 02.
-- ========================================================
-- DELETE FROM tb_log_farmasi;
-- DELETE FROM tb_transaksi_obat;
-- DELETE FROM tb_obat;
-- DELETE FROM tb_pengguna;
-- DELETE FROM tb_pasien_pembeli;
-- DELETE FROM tb_pemasok_pbf;
-- DELETE FROM tb_golongan_obat;
