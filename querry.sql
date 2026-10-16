-- A. Menggunakan Kueri Filter LIKE dengan Wildcard (%)

-- 1. Kueri Filter LIKE %m%
SELECT * FROM tb_obat
WHERE nama_obat LIKE '%m%';

-- 2. Kueri Filter LIKE %mol%
SELECT * FROM tb_obat
WHERE nama_obat LIKE '%mol%';

-- 3. Kueri Filter LIKE %a%
SELECT * FROM tb_obat
WHERE nama_obat LIKE '%a%';


-- B. Menggunakan Kueri Filter BETWEEN

-- 1. Kueri FILTER BETWEEN 50 AND 150 mencari obat dengan stok antara 50 dan 150 dan menampilkan nama obat dan stoknya
SELECT stok, nama_obat
FROM tb_obat
WHERE stok BETWEEN 50 AND 150;

-- 2. Kueri FILTER BETWEEN


--- Penggunaan Fungsi Agregat COUNT, SUM, AVG, MAX, MIN[cite: 12, 15]

--- Kueri Agregat SUM
-- 1. Total Pendapatan dari transaksi obat yang sudah selesai
SELECT SUM(total_bayar) AS total_pendapatan
FROM tb_transaksi_obat
WHERE status_transaksi = 'Selesai';

-- 2. Total Keseluruhan Stok Obat di Apotek
SELECT SUM(stok) AS total_stok
FROM tb_obat;

--3. Total Keseluruhan Kuantitas Obat yang Terjual dari Transaksi Obat yang Sudah Selesai
SELECT SUM(jumlah_beli) AS total_terjual
FROM tb_transaksi_obat;


--- Kueri Agregat AVG
-- 1. Rata-rata Harga Obat di Apotek
SELECT AVG(harga_satuan) AS rata_rata_harga_obat
FROM tb_obat;

-- 2. Rata - rata jumlah stok obat di apotek
SELECT AVG(stok) AS rata_rata_stok_obat
FROM tb_obat;

-- 3. Rata - rata Nominal Uang yang Dihasilkan dari Transaksi Obat yang Sudah Selesai
SELECT AVG(total_bayar) AS rata_rata_nominal_transaksi
FROM tb_transaksi_obat;


--- Kueri Agregat MIN
-- 1. Harga Obat Termurah di Inventaris
SELECT MIN(harga_satuan) AS harga_terendah
FROM tb_obat;

-- 2. Stok Obat Tersedikit di Inventaris
SELECT MIN(stok) AS stok_terendah
FROM tb_obat;

-- 3. Tanggal Transaksi Obat Pertama yang Terjadi
SELECT MIN(tanggal_transaksi) AS tanggal_transaksi_pertama
FROM tb_transaksi_obat;


--- Kueri Agregat MAX
-- 1. Harga Obat Termahal di Inventaris
SELECT MAX(harga_satuan) AS harga_tertinggi
FROM tb_obat;

-- 2. Stok Obat Terbanyak di Inventaris
SELECT MAX(stok) AS stok_tertinggi
FROM tb_obat;

-- 3. Nilai Total Bayar Transaksi Obat Terbesar
SELECT MAX(total_bayar) AS total_harga_tertinggi
FROM tb_transaksi_obat;


--- Kueri Having
-- 1. Pemasok yang menyuplai lebih dari 2 jenis obat
SELECT p.nama_pemasok, COUNT(o.id_obat) AS jumlah_obat
FROM tb_pemasok_pbf p
JOIN tb_obat o ON p.id_pemasok = o.id_pemasok
GROUP BY p.nama_pemasok
HAVING COUNT(o.id_obat) > 2;

-- 2. Golongan obat yang memiliki stok lebih dari 200
SELECT g.nama_golongan, SUM(o.stok) AS total_stok
FROM tb_golongan_obat g
JOIN tb_obat o ON g.id_golongan = o.id_golongan
GROUP BY g.id_golongan, g.nama_golongan
HAVING SUM(o.stok) > 200;

-- 3. Kota asal pasien yang memiliki lebih dari 1 pasien
SELECT p.alamat, COUNT(*) AS jumlah_pasien
FROM tb_pasien_pembeli p
GROUP BY p.alamat
HAVING COUNT(*) > 1;