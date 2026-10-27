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