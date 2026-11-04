-- 03_query_select.sql
-- ========================================================
-- Tahap 2  : SELECT, Pattern Matching, Filtering & Sorting
-- Database : db_farmasi_pplg2_kel10
-- Kelompok : 10 (Riyandi, Owen, Ghani)
-- Prasyarat: 01_ddl_init.sql dan 02_dml_data.sql sudah dijalankan.
-- Catatan  : collation utf8mb4_general_ci membuat LIKE tidak membedakan huruf besar/kecil ('%M%' = '%m%').       
-- ========================================================

USE db_farmasi_pplg2_kel10;

-- --------------------------------------------------------
-- PERSIAPAN DATA: nama obat ber-FORTE
-- Satu baris UPDATE saja, supaya jumlah baris tb_obat tetap 10.
-- Harga dan stok tidak diubah, sehingga hasil agregasi di 04
-- dan 06 tidak terpengaruh.
-- --------------------------------------------------------

UPDATE tb_obat
SET nama_obat = 'OBH Combi Batuk FORTE'
WHERE id_obat = 'ob10';

-- ========================================================
-- A. PATTERN MATCHING dengan LIKE
-- ========================================================

-- A1. Wildcard di kedua sisi: nama mengandung "Tablet"
--     Hasil: Antasida Tablet, Promag Tablet (2 baris)
SELECT id_obat, nama_obat, stok
FROM tb_obat
WHERE nama_obat LIKE '%Tablet%';

-- A2. Wildcard di kanan: nama diawali "Vita"
--     Hasil: Vitamin C (1 baris)
SELECT id_obat, nama_obat
FROM tb_obat
WHERE nama_obat LIKE 'Vita%';

-- A3. Wildcard di kiri: nama diakhiri "mg"
--     Hasil: Paracetamol 500mg, Amoxicillin 500mg,
--            Ibuprofen 400mg, Cetirizine 10mg, Cefadroxil 500mg (5 baris)
SELECT id_obat, nama_obat
FROM tb_obat
WHERE nama_obat LIKE '%mg';

-- A4. Wildcard di tengah: nama mengandung "Combi"
--     Hasil: OBH Combi Batuk FORTE (1 baris)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE nama_obat LIKE '%Combi%';

-- A5. Wildcard "_" = tepat satu karakter
--     Hasil: Vitamin C (1 baris)
SELECT id_obat, nama_obat
FROM tb_obat
WHERE nama_obat LIKE 'Vitamin _';

-- A6. Dua pola sekaligus: mengandung "500mg" atau "400mg"
--     Hasil: 4 baris
SELECT id_obat, nama_obat
FROM tb_obat
WHERE nama_obat LIKE '%500mg%'
   OR nama_obat LIKE '%400mg%';

-- A7. Pola wajib modul: LIKE '%FORTE%'
--     Hasil: OBH Combi Batuk FORTE (1 baris)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE nama_obat LIKE '%FORTE%';

-- ========================================================
-- B. NEGASI POLA dengan NOT LIKE
-- ========================================================

-- B1. Semua obat yang namanya TIDAK mengandung "mg"
--     Hasil: Antasida Tablet, Vitamin C, Tolak Angin,
--            Promag Tablet, OBH Combi Batuk FORTE (5 baris)
SELECT id_obat, nama_obat
FROM tb_obat
WHERE nama_obat NOT LIKE '%mg%';

-- B2. NOT LIKE digabung LIKE: tidak berakhiran "mg"
--     tetapi mengandung "Tablet"
--     Hasil: Antasida Tablet, Promag Tablet (2 baris)
SELECT id_obat, nama_obat
FROM tb_obat
WHERE nama_obat NOT LIKE '%mg'
  AND nama_obat LIKE '%Tablet%';

-- B3. Padanan negasi dari A7: seluruh obat selain yang ber-FORTE
--     Hasil: 9 baris
SELECT id_obat, nama_obat
FROM tb_obat
WHERE nama_obat NOT LIKE '%FORTE%';

-- ========================================================
-- C. FILTER RENTANG NUMERIK dengan BETWEEN
-- ========================================================

-- C1. Stok antara 50 dan 150 (inklusif: 50 dan 150 ikut)
--     Hanya Cefadroxil (40) yang di luar rentang.
--     Hasil: 9 baris
SELECT nama_obat, stok
FROM tb_obat
WHERE stok BETWEEN 50 AND 150
ORDER BY stok ASC;

-- C2. Pembanding: padanan BETWEEN memakai >= dan <=
--     Hasil: 9 baris (sama dengan C1)
SELECT nama_obat, stok
FROM tb_obat
WHERE stok >= 50 AND stok <= 150
ORDER BY stok ASC;

-- C3. Harga satuan antara 5000 dan 12000
--     Hasil: 6 baris
SELECT nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan BETWEEN 5000 AND 12000
ORDER BY harga_satuan ASC;

-- ========================================================
-- D. FILTER RENTANG TANGGAL dengan BETWEEN
-- ========================================================

-- D1. Pasien yang mendaftar 1-5 Oktober 2026
--     Hasil: pas1 sampai pas5 (5 baris)
SELECT id_pasien, nama_pasien, tanggal_daftar
FROM tb_pasien_pembeli
WHERE tanggal_daftar BETWEEN '2026-10-01' AND '2026-10-05';

-- D2. Transaksi pada 7 Oktober 2026
--     Hasil: tran3, tran4 (2 baris)
SELECT id_transaksi, id_pasien, id_obat, tanggal_transaksi
FROM tb_transaksi_obat
WHERE tanggal_transaksi BETWEEN '2026-10-07' AND '2026-10-07';

-- D3. Pola aman bila kolom bertipe DATETIME (bukan DATE):
--     >= batas awal AND < hari setelah batas akhir
--     Hasil: id_log 1, 2, 3, 4 (4 baris)
SELECT nama_operasi, waktu_eksekusi
FROM tb_log_farmasi
WHERE waktu_eksekusi >= '2026-10-06 00:00:00'
  AND waktu_eksekusi <  '2026-10-07 00:00:00';

-- ========================================================
-- E. PENGURUTAN dengan ORDER BY
-- ========================================================

-- E1. Harga termahal ke termurah
SELECT nama_obat, harga_satuan
FROM tb_obat
ORDER BY harga_satuan DESC;

-- E2. Nama obat alfabetis A-Z
SELECT nama_obat
FROM tb_obat
ORDER BY nama_obat ASC;

-- E3. Tanggal daftar pasien, terbaru lebih dulu
SELECT nama_pasien, tanggal_daftar
FROM tb_pasien_pembeli
ORDER BY tanggal_daftar DESC;

-- E4. Dua kolom: per golongan, lalu harga tertinggi
SELECT id_golongan, nama_obat, harga_satuan
FROM tb_obat
ORDER BY id_golongan ASC, harga_satuan DESC;

-- E5. WHERE + ORDER BY + LIMIT: 5 obat termahal
--     yang stoknya masih tersedia
SELECT nama_obat, harga_satuan, stok
FROM tb_obat
WHERE stok > 0
ORDER BY harga_satuan DESC
LIMIT 5;

-- ========================================================
-- F. UPDATE & DELETE BERSYARAT (klausa WHERE)
-- Dijalankan dalam transaksi lalu di-ROLLBACK, supaya data
-- dummy 02_dml_data.sql tetap utuh untuk Tahap 3-4.
-- ========================================================
START TRANSACTION;

-- F1. UPDATE satu kolom untuk kelompok tertentu:
--     harga obat keras (gol3) naik 10%
UPDATE tb_obat
SET harga_satuan = harga_satuan * 1.10
WHERE id_golongan = 'gol3';

-- F2. Verifikasi hasil UPDATE sebelum disimpan
--     Hasil: Amoxicillin 11000, Promag 9350
SELECT id_obat, nama_obat, id_golongan, harga_satuan
FROM tb_obat
WHERE id_golongan = 'gol3'
ORDER BY nama_obat;

-- F3. UPDATE bersyarat banyak kondisi: stok rendah + golongan herbal
--     Hasil: Cefadroxil stok 40 -> 90
UPDATE tb_obat
SET stok = stok + 50
WHERE stok < 50
  AND id_golongan = 'gol4';

-- F4. DELETE bersyarat pada baris uji (bukan data asli)
INSERT INTO tb_obat (id_obat, id_golongan, id_pemasok, nama_obat, harga_satuan, stok)
VALUES ('ob99', 'gol1', 'PBF1', 'Obat Uji Hapus', 1000, 1);

DELETE FROM tb_obat
WHERE id_obat = 'ob99'
  AND stok = 1;

-- F5. Pastikan baris uji sudah hilang
--     Hasil: 0 baris
SELECT id_obat, nama_obat
FROM tb_obat
WHERE id_obat = 'ob99';

-- F6. Batalkan SELURUH perubahan agar data kembali seperti semula
ROLLBACK;

-- F7. Bukti bahwa data utuh kembali
--     Hasil: Amoxicillin 10000, Promag 8500, Cefadroxil stok 40
SELECT id_obat, nama_obat, harga_satuan, stok
FROM tb_obat
WHERE id_golongan IN ('gol3','gol4')
ORDER BY id_obat;

-- Catatan: UPDATE nama FORTE di bagian PERSIAPAN berada di luar
-- transaksi F, jadi tetap tersimpan setelah ROLLBACK (memang
-- diinginkan agar kueri A7 dan B3 punya data).
