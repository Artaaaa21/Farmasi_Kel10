-- ========================================================
-- 04_aggregate.sql
-- Tahap 3: Fungsi Agregasi & Grouping (Modul 4)
-- Database : db_farmasi_pplg2_kel10
-- Kelompok : 10 (Riyandi, Owen, Ghani)
-- Sumber isi: querry.sql (commit Riyandi) -- dipisah per tahap,
--             kueri asli dipertahankan, ditambah yang belum ada.
-- ========================================================

USE db_farmasi_pplg2_kel10;

-- ========================================================
-- A. SUM
-- ========================================================

-- A1. Total pendapatan dari transaksi yang sudah selesai
--     Hasil: 68000
SELECT SUM(total_bayar) AS total_pendapatan
FROM tb_transaksi_obat
WHERE status_transaksi = 'SELESAI';

-- A2. Total keseluruhan stok obat
--     Hasil: 790
SELECT SUM(stok) AS total_stok
FROM tb_obat;

-- A3. Total kuantitas obat terjual
--     Hasil: 12
SELECT SUM(jumlah_beli) AS total_terjual
FROM tb_transaksi_obat;

-- A4. NILAI ASET persediaan: SUM(harga_satuan * stok)  <-- indikator modul
--     Hasil: 6347500
SELECT SUM(harga_satuan * stok) AS total_nilai_aset
FROM tb_obat;

-- A5. Nilai aset per golongan
SELECT id_golongan,
       SUM(harga_satuan * stok) AS nilai_aset
FROM tb_obat
GROUP BY id_golongan
ORDER BY nilai_aset DESC;

-- ========================================================
-- B. COUNT
-- ========================================================

-- B1. Jumlah baris obat
--     Hasil: 10
SELECT COUNT(*) AS jumlah_obat
FROM tb_obat;

-- B2. Jumlah transaksi tercatat
--     Hasil: 5
SELECT COUNT(*) AS jumlah_transaksi
FROM tb_transaksi_obat;

-- B3. Jumlah pasien unik yang pernah bertransaksi
--     Hasil: 5
SELECT COUNT(DISTINCT id_pasien) AS pasien_aktif
FROM tb_transaksi_obat;

-- ========================================================
-- C. AVG
-- ========================================================

-- C1. Rata-rata harga obat
--     Hasil: 9050
SELECT AVG(harga_satuan) AS rata_rata_harga_obat
FROM tb_obat;

-- C2. Rata-rata stok obat
--     Hasil: 79
SELECT AVG(stok) AS rata_rata_stok_obat
FROM tb_obat;

-- C3. Rata-rata nominal transaksi
--     Hasil: 13600
SELECT AVG(total_bayar) AS rata_rata_nominal_transaksi
FROM tb_transaksi_obat;

-- ========================================================
-- D. MIN
-- ========================================================

-- D1. Harga obat termurah      Hasil: 3500
SELECT MIN(harga_satuan) AS harga_terendah FROM tb_obat;

-- D2. Stok paling sedikit      Hasil: 40
SELECT MIN(stok) AS stok_terendah FROM tb_obat;

-- D3. Tanggal transaksi pertama  Hasil: 2026-10-06
SELECT MIN(tanggal_transaksi) AS tanggal_transaksi_pertama
FROM tb_transaksi_obat;

-- ========================================================
-- E. MAX
-- ========================================================

-- E1. Harga obat termahal       Hasil: 18500
SELECT MAX(harga_satuan) AS harga_tertinggi FROM tb_obat;

-- E2. Stok paling banyak        Hasil: 120
SELECT MAX(stok) AS stok_tertinggi FROM tb_obat;

-- E3. Nilai total bayar terbesar Hasil: 20000
SELECT MAX(total_bayar) AS total_harga_tertinggi
FROM tb_transaksi_obat;

-- ========================================================
-- F. GROUP BY
-- ========================================================

-- F1. Jumlah obat dan total stok per golongan
--     Hasil: gol1 4 obat/320, gol2 2/140, gol3 2/170, gol4 2/160
SELECT g.nama_golongan,
       COUNT(o.id_obat) AS jumlah_obat,
       SUM(o.stok)      AS total_stok
FROM tb_golongan_obat g
JOIN tb_obat o ON g.id_golongan = o.id_golongan
GROUP BY g.id_golongan, g.nama_golongan
ORDER BY total_stok DESC;

-- F2. Rata-rata harga per golongan
SELECT id_golongan,
       COUNT(*)             AS jumlah_obat,
       AVG(harga_satuan)    AS rata_rata_harga,
       MAX(harga_satuan)    AS harga_termahal
FROM tb_obat
GROUP BY id_golongan;

-- F3. Jumlah obat per pemasok
SELECT p.nama_pemasok, COUNT(o.id_obat) AS jumlah_obat
FROM tb_pemasok_pbf p
LEFT JOIN tb_obat o ON p.id_pemasok = o.id_pemasok
GROUP BY p.id_pemasok, p.nama_pemasok;

-- ========================================================
-- G. DISTINCT (eliminasi duplikasi)
-- ========================================================

-- G1. Daftar golongan yang benar-benar dipakai obat
--     Hasil: gol1, gol2, gol3, gol4
SELECT DISTINCT id_golongan FROM tb_obat;

-- G2. Status transaksi yang ada di data
--     Hasil: SELESAI
SELECT DISTINCT status_transaksi FROM tb_transaksi_obat;

-- G3. Beda COUNT(*) dan COUNT(DISTINCT): semua baris vs nilai unik
--     Hasil: 10 dan 4
SELECT COUNT(*) AS semua_baris,
       COUNT(DISTINCT id_golongan) AS golongan_unik
FROM tb_obat;

-- G4. Kombinasi dua kolom unik: pasangan golongan + pemasok
SELECT DISTINCT id_golongan, id_pemasok
FROM tb_obat
ORDER BY id_golongan, id_pemasok;

-- ========================================================
-- H. HAVING (filter pada hasil agregasi)
-- ========================================================

-- H1. Pemasok yang menyuplai lebih dari 2 jenis obat
--     Hasil: PT Kimia Farma (3), PT Indofarma (3)
SELECT p.nama_pemasok, COUNT(o.id_obat) AS jumlah_obat
FROM tb_pemasok_pbf p
JOIN tb_obat o ON p.id_pemasok = o.id_pemasok
GROUP BY p.id_pemasok, p.nama_pemasok
HAVING COUNT(o.id_obat) > 2;

-- H2. Golongan dengan total stok di atas 200
--     Hasil: Obat Resep (320)
SELECT g.nama_golongan, SUM(o.stok) AS total_stok
FROM tb_golongan_obat g
JOIN tb_obat o ON g.id_golongan = o.id_golongan
GROUP BY g.id_golongan, g.nama_golongan
HAVING SUM(o.stok) > 200;

-- H3. Golongan dengan rata-rata harga di atas 8000
--     Hasil: gol3 (9250), gol4 (9250)
--     (menggantikan contoh "kota asal pasien" yang selalu kosong,
--      karena kolom alamat tiap pasien unik)
SELECT id_golongan,
       AVG(harga_satuan) AS rata_rata_harga
FROM tb_obat
GROUP BY id_golongan
HAVING AVG(harga_satuan) > 8000;

-- H4. WHERE + GROUP BY + HAVING + ORDER BY dalam satu kueri
--     Hanya transaksi SELESAI, nominal > 12000
SELECT id_obat,
       SUM(jumlah_beli) AS total_terjual,
       SUM(total_bayar) AS total_omzet
FROM tb_transaksi_obat
WHERE status_transaksi = 'SELESAI'
GROUP BY id_obat
HAVING SUM(total_bayar) > 12000
ORDER BY total_omzet DESC;
