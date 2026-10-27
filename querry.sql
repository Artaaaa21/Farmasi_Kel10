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

-- C. Menggunakan Kueri ORDER BY

-- 1. Mengurutkan data obat berdasarkan harga termahal ke termurah (DESC)
SELECT * FROM tb_obat
ORDER BY harga_satuan DESC;

-- 2. Mengurutkan data obat berdasarkan nama secara alfabet A-Z (ASC)
SELECT * FROM tb_obat
ORDER BY nama_obat ASC;

-- 3. Mengurutkan data pasien berdasarkan tanggal daftar terbaru
SELECT * FROM tb_pasien_pembeli
ORDER BY tanggal_daftar DESC;

-- 2. Kueri FILTER BETWEEN


--- Penggunaan Fungsi Agregat COUNT, SUM, AVG, MAX, MIN

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

-- ========================================================
-- TAHAP 4 & 5: RELASI MULTI-TABEL (JOIN & UNION) DAN SUBQUERY KOMPLEKS
-- (Modul 5 & Modul 6)
-- ========================================================

-- --------------------------------------------------------
-- 1. INNER JOIN (Eksplisit ON & Implisit WHERE)
-- --------------------------------------------------------

-- a. INNER JOIN Eksplisit (Menampilkan transaksi lengkap dengan nama pasien dan nama obat)
SELECT 
    t.id_transaksi, 
    p.nama_pasien, 
    o.nama_obat, 
    t.jumlah_beli, 
    t.total_bayar, 
    t.tanggal_transaksi 
FROM tb_transaksi_obat t
INNER JOIN tb_pasien_pembeli p ON t.id_pasien = p.id_pasien
INNER JOIN tb_obat o ON t.id_obat = o.id_obat;

-- b. INNER JOIN Implisit (Menggunakan klausa WHERE)
SELECT 
    t.id_transaksi, 
    p.nama_pasien, 
    o.nama_obat, 
    t.total_bayar 
FROM tb_transaksi_obat t, tb_pasien_pembeli p, tb_obat o
WHERE t.id_pasien = p.id_pasien AND t.id_obat = o.id_obat;


-- --------------------------------------------------------
-- 2. OUTER JOIN (LEFT OUTER JOIN & RIGHT OUTER JOIN)
-- --------------------------------------------------------

-- a. LEFT OUTER JOIN: Mencari daftar obat yang BELUM PERNAH TERJUAL sama sekali
SELECT 
    o.id_obat, 
    o.nama_obat, 
    o.harga_satuan, 
    o.stok
FROM tb_obat o
LEFT JOIN tb_transaksi_obat t ON o.id_obat = t.id_obat
WHERE t.id_transaksi IS NULL;

-- b. RIGHT OUTER JOIN: Menampilkan seluruh pemasok PBF beserta obat yang mereka suplai
SELECT 
    pbf.nama_pemasok, 
    o.nama_obat, 
    o.stok
FROM tb_obat o
RIGHT JOIN tb_pemasok_pbf pbf ON o.id_pemasok = pbf.id_pemasok;


-- --------------------------------------------------------
-- 3. PENGGABUNGAN DATASET (UNION & UNION ALL)
-- --------------------------------------------------------

-- a. UNION (Menggabungkan daftar nama pasien dan nama pemasok PBF tanpa duplikasi)
SELECT nama_pasien AS nama_entitas, 'Pasien' AS peran FROM tb_pasien_pembeli
UNION
SELECT nama_pemasok AS nama_entitas, 'Pemasok PBF' AS peran FROM tb_pemasok_pbf;

-- b. UNION ALL (Menggabungkan seluruh riwayat aktivitas atau entitas termasuk jika ada duplikat)
SELECT id_obat AS kode_identitas, nama_obat AS nama_item FROM tb_obat
UNION ALL
SELECT id_pasien AS kode_identitas, nama_pasien AS nama_item FROM tb_pasien_pembeli;


-- --------------------------------------------------------
-- 4. SUBQUERY KOMPLEKS (Scalar, Multi-Row, Multi-Nilai, & Correlated)
-- --------------------------------------------------------

-- a. Scalar Subquery: Mencari obat yang harganya DI ATAS RATA-RATA harga obat apotek
SELECT nama_obat, harga_satuan 
FROM tb_obat
WHERE harga_satuan > (SELECT AVG(harga_satuan) FROM tb_obat);

-- b. Multi-Row Subquery dengan Operator IN: Menampilkan pasien yang pernah membeli obat kategori 'Obat Resep' (gol1)
SELECT nama_pasien, alamat 
FROM tb_pasien_pembeli
WHERE id_pasien IN (
    SELECT id_pasien 
    FROM tb_transaksi_obat 
    WHERE id_obat IN (SELECT id_obat FROM tb_obat WHERE id_golongan = 'gol1')
);

-- c. Subquery Komparasi Multi-Nilai (ANY / ALL): Mencari obat dengan stok lebih besar dari SELURUH obat golongan 3
SELECT nama_obat, stok 
FROM tb_obat
WHERE stok > ALL (
    SELECT stok FROM tb_obat WHERE id_golongan = 'gol3'
);

-- d. Correlated Subquery dengan EXISTS / NOT EXISTS: Menampilkan data pasien yang SUDAH pernah melakukan transaksi
SELECT p.id_pasien, p.nama_pasien 
FROM tb_pasien_pembeli p
WHERE EXISTS (
    SELECT 1 FROM tb_transaksi_obat t WHERE t.id_pasien = p.id_pasien
);

-- e. Correlated Subquery dengan NOT EXISTS: Menampilkan data pasien yang BELUM PERNAH melakukan transaksi
SELECT p.id_pasien, p.nama_pasien 
FROM tb_pasien_pembeli p
WHERE NOT EXISTS (
    SELECT 1 FROM tb_transaksi_obat t WHERE t.id_pasien = p.id_pasien
);