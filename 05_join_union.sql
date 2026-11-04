-- 05_join_union.sql
-- ========================================================
-- Tahap 4  : Relasi Multi-Tabel (JOIN & UNION) (Modul 5 : Relasi & Penggabungan)
-- Database : db_farmasi_pplg2_kel10
-- Kelompok : 10 (Riyandi, Owen, Ghani)
-- Prasyarat: 01, 02, dan 03 sudah dijalankan
-- ========================================================

USE db_farmasi_pplg2_kel10;

-- ========================================================
-- 1. INNER JOIN
-- ========================================================

-- 1a. INNER JOIN eksplisit ON (dua tabel): transaksi lengkap dengan
--     nama pasien dan nama obat
--     Hasil: 5 baris
SELECT t.id_transaksi,
       p.nama_pasien,
       o.nama_obat,
       t.jumlah_beli,
       t.total_bayar,
       t.tanggal_transaksi
FROM tb_transaksi_obat t
INNER JOIN tb_pasien_pembeli p ON t.id_pasien = p.id_pasien
INNER JOIN tb_obat o           ON t.id_obat   = o.id_obat
ORDER BY t.id_transaksi;

-- 1b. INNER JOIN implisit WHERE: hasil sama dengan 1a
--     Hasil: 5 baris
SELECT t.id_transaksi,
       p.nama_pasien,
       o.nama_obat,
       t.total_bayar
FROM tb_transaksi_obat t, tb_pasien_pembeli p, tb_obat o
WHERE t.id_pasien = p.id_pasien
  AND t.id_obat   = o.id_obat
ORDER BY t.id_transaksi;

-- 1c. INNER JOIN dua tabel + agregasi: omzet per pasien
--     Hasil: pas1 10000, pas2 12000, pas3 12000, pas4 20000, pas5 14000
SELECT p.nama_pasien,
       COUNT(t.id_transaksi) AS jumlah_transaksi,
       SUM(t.total_bayar)    AS total_belanja
FROM tb_pasien_pembeli p
JOIN tb_transaksi_obat t ON p.id_pasien = t.id_pasien
GROUP BY p.id_pasien, p.nama_pasien
ORDER BY total_belanja DESC;

-- 1d. INNER JOIN tiga tabel: transaksi -> obat -> golongan
--     Omzet penjualan per golongan obat
--     Hasil: gol1 22000, gol3 20000, gol4 14000, gol2 12000
SELECT g.nama_golongan,
       COUNT(t.id_transaksi) AS jumlah_transaksi,
       SUM(t.total_bayar)    AS omzet
FROM tb_transaksi_obat t
JOIN tb_obat o          ON t.id_obat      = o.id_obat
JOIN tb_golongan_obat g ON o.id_golongan  = g.id_golongan
GROUP BY g.id_golongan, g.nama_golongan
ORDER BY omzet DESC;

-- ========================================================
-- 2. OUTER JOIN
-- ========================================================

-- 2a. LEFT OUTER JOIN: obat yang BELUM PERNAH terjual
--     Hasil: 5 baris (ob6, ob7, ob8, ob9, ob10)
SELECT o.id_obat, o.nama_obat, o.harga_satuan, o.stok
FROM tb_obat o
LEFT JOIN tb_transaksi_obat t ON o.id_obat = t.id_obat
WHERE t.id_transaksi IS NULL
ORDER BY o.id_obat;

-- 2b. RIGHT OUTER JOIN: seluruh pemasok beserta obat yang disuplai
--     Semua 4 pemasok pada data ini menyuplai obat, sehingga hasilnya
--     10 baris dan tidak ada kolom NULL. Perilaku "pemasok tanpa obat"
--     dibuktikan oleh 2e di bawah.
--     Hasil: 10 baris
SELECT pbf.nama_pemasok, o.nama_obat, o.stok
FROM tb_obat o
RIGHT JOIN tb_pemasok_pbf pbf ON o.id_pemasok = pbf.id_pemasok
ORDER BY pbf.nama_pemasok, o.nama_obat;

-- 2c. Pembanding: LEFT JOIN versi setara dari 2b
--     (RIGHT JOIN dapat ditulis sebagai LEFT JOIN hanya dengan
--      menukar posisi tabel). Hasil identik dengan 2b: 10 baris.
SELECT pbf.nama_pemasok, o.nama_obat, o.stok
FROM tb_pemasok_pbf pbf
LEFT JOIN tb_obat o ON pbf.id_pemasok = o.id_pemasok
ORDER BY pbf.nama_pemasok, o.nama_obat;

-- 2d. Pemasok yang belum pernah menyuplai obat apa pun
--     Hasil: 0 baris (semua pemasok punya obat)
SELECT pbf.id_pemasok, pbf.nama_pemasok
FROM tb_pemasok_pbf pbf
LEFT JOIN tb_obat o ON pbf.id_pemasok = o.id_pemasok
WHERE o.id_obat IS NULL;

-- 2e. BUKTI baris NULL pada LEFT JOIN
--     Sementara menambah satu pemasok tanpa obat, tampilkan, lalu
--     batalkan agar data 02 tetap utuh (tidak ada DDL di dalam
--     transaksi, sehingga ROLLBACK bekerja penuh).
--     Hasil: PBF9 dengan nama_obat NULL, lalu 0 baris setelah rollback.
START TRANSACTION;

INSERT INTO tb_pemasok_pbf (id_pemasok, nama_pemasok, kota_asal, kontak)
VALUES ('PBF9', 'PT Bernofarm', 'Sidoarjo', '082111112222');

SELECT pbf.id_pemasok, pbf.nama_pemasok, o.nama_obat
FROM tb_pemasok_pbf pbf
LEFT JOIN tb_obat o ON pbf.id_pemasok = o.id_pemasok
WHERE o.id_obat IS NULL;

ROLLBACK;

-- Bukti pemasok uji sudah hilang: hasil 0 baris
SELECT COUNT(*) AS sisa_pbf9 FROM tb_pemasok_pbf WHERE id_pemasok = 'PBF9';

-- ========================================================
-- 3. UNION & UNION ALL
-- ========================================================

-- 3a. UNION: gabungan nama pasien dan nama pemasok tanpa duplikasi
--     Hasil: 11 baris (7 pasien + 4 pemasok)
SELECT nama_pasien AS nama_entitas, 'Pasien' AS peran
FROM tb_pasien_pembeli
UNION
SELECT nama_pemasok AS nama_entitas, 'Pemasok PBF' AS peran
FROM tb_pemasok_pbf;

-- 3b. UNION ALL: gabungan id obat dan id pasien, duplikat dipertahankan
--     Hasil: 17 baris (10 obat + 7 pasien)
SELECT id_obat AS kode_identitas, nama_obat AS nama_item, 'Obat' AS jenis
FROM tb_obat
UNION ALL
SELECT id_pasien, nama_pasien, 'Pasien'
FROM tb_pasien_pembeli;

-- 3c. Bukti perbedaan UNION vs UNION ALL pada data yang sama
--     Hasil: 4 baris (gol1-gol4), karena UNION membuang duplikat
SELECT id_golongan FROM tb_obat
UNION
SELECT id_golongan FROM tb_obat;

-- 3d. Kontras: UNION ALL mempertahankan seluruh 20 baris
--     (10 dari SELECT pertama + 10 dari SELECT kedua)
SELECT id_golongan FROM tb_obat
UNION ALL
SELECT id_golongan FROM tb_obat;
