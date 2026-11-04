-- 06_subquery.sql
-- =====================================================================
-- Tahap 5A & 5B : Subquery Tingkat Lanjut (Modul 6 : Nested & Correlated Query)
-- Database      : db_farmasi_pplg2_kel10
-- Kelompok      : 10 (Riyandi, Owen, Ghani)
-- Prasyarat     : 01, 02, 03 sudah dijalankan.
-- Isi           : A. Scalar | B. IN | C. NOT IN | D. ANY/SOME/ALL | E. EXISTS / NOT EXISTS | F. Data uji + pembersihan
-- =====================================================================

USE db_farmasi_pplg2_kel10;

-- =====================================================================
-- A. SCALAR SUBQUERY
-- Subquery mengembalikan SATU nilai (satu baris, satu kolom).
-- =====================================================================

-- A1. Obat dengan harga di atas harga rata-rata (9050).
--     Hasil: 4 baris -- Vitamin C (12000), Amoxicillin (10000),
--            Cefadroxil (15000), OBH Combi Batuk FORTE (18500)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan > (SELECT AVG(harga_satuan) FROM tb_obat);

-- A2. Obat dengan stok di bawah stok rata-rata (79).
--     Hasil: 5 baris -- Vitamin C (50), Amoxicillin (60),
--            Ibuprofen (75), Cefadroxil (40), OBH Combi (65)
SELECT id_obat, nama_obat, stok
FROM tb_obat
WHERE stok < (SELECT AVG(stok) FROM tb_obat);

-- A3. Selisih harga tiap obat terhadap harga rata-rata.
--     Hasil: 10 baris, teratas OBH Combi (+9450), terbawah Tolak Angin (-5550)
SELECT id_obat, nama_obat, harga_satuan,
       harga_satuan - (SELECT AVG(harga_satuan) FROM tb_obat) AS selisih_rata_rata
FROM tb_obat
ORDER BY selisih_rata_rata DESC;

-- A4. Transaksi dengan total bayar di atas rata-rata (13600).
--     Hasil: 2 baris -- tran4 (20000), tran5 (14000)
SELECT id_transaksi, id_pasien, total_bayar
FROM tb_transaksi_obat
WHERE total_bayar > (SELECT AVG(total_bayar) FROM tb_transaksi_obat);

-- =====================================================================
-- B. MULTIPLE-ROW SUBQUERY dengan operator IN
-- =====================================================================

-- B1. Obat yang pernah dibeli (ada di tabel transaksi).
--     Hasil: 5 baris (ob1 s/d ob5)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE id_obat IN (SELECT id_obat FROM tb_transaksi_obat);

-- B2. Pasien yang pernah membeli minimal 3 unit sekali beli.
--     Hasil: 2 baris -- Nopia/pas2 (3 unit), Dhanis/pas5 (4 unit)
SELECT id_pasien, nama_pasien, alamat
FROM tb_pasien_pembeli
WHERE id_pasien IN (SELECT id_pasien
                    FROM tb_transaksi_obat
                    WHERE jumlah_beli >= 3);

-- B3. Obat yang dipasok pemasok dari kota Jakarta (PBF3 & PBF4).
--     PBF3 memasok Vitamin C (ob3) dan Cetirizine (ob7),
--     PBF4 memasok Amoxicillin (ob4) dan Cefadroxil (ob9).
--     Hasil: 4 baris
SELECT id_obat, nama_obat, id_pemasok, harga_satuan
FROM tb_obat
WHERE id_pemasok IN (SELECT id_pemasok
                     FROM tb_pemasok_pbf
                     WHERE kota_asal = 'Jakarta');

-- B4. Golongan yang memiliki obat dengan harga di atas 8000.
--     Hasil: 4 baris -- Obat Resep, Obat Vitamin, Obat Keras, Obat Herbal
SELECT id_golongan, nama_golongan
FROM tb_golongan_obat
WHERE id_golongan IN (SELECT id_golongan
                      FROM tb_obat
                      WHERE harga_satuan > 8000);

-- =====================================================================
-- C. MULTIPLE-ROW SUBQUERY dengan operator NOT IN
-- CATATAN: subquery diberi IS NOT NULL. Jika ada satu saja nilai NULL,
-- NOT IN akan mengembalikan 0 baris.
-- =====================================================================

-- C1. Obat yang belum pernah terjual.
--     Hasil: 5 baris -- ob6, ob7, ob8, ob9, ob10
SELECT id_obat, nama_obat, stok
FROM tb_obat
WHERE id_obat NOT IN (SELECT id_obat
                      FROM tb_transaksi_obat
                      WHERE id_obat IS NOT NULL);

-- C2. Pasien yang belum pernah melakukan transaksi.
--     Hasil: 2 baris -- pas6 (Vita), pas7 (Ares)
SELECT id_pasien, nama_pasien
FROM tb_pasien_pembeli
WHERE id_pasien NOT IN (SELECT id_pasien
                        FROM tb_transaksi_obat
                        WHERE id_pasien IS NOT NULL);

-- C3. Pemasok yang belum memasok obat apa pun.
--     Hasil: 0 baris (keempat pemasok punya obat)
SELECT id_pemasok, nama_pemasok, kota_asal
FROM tb_pemasok_pbf
WHERE id_pemasok NOT IN (SELECT id_pemasok
                         FROM tb_obat
                         WHERE id_pemasok IS NOT NULL);

-- C4. Obat selain yang bergolongan Obat Resep (gol1).
--     Hasil: 6 baris -- ob3, ob4, ob5, ob7, ob8, ob9
SELECT id_obat, nama_obat, id_golongan
FROM tb_obat
WHERE id_obat NOT IN (SELECT id_obat
                      FROM tb_obat
                      WHERE id_golongan = 'gol1');

-- =====================================================================
-- D. SUBQUERY KOMPARASI MULTI-NILAI: ANY / SOME dan ALL
-- Harga obat gol1 = 4000, 5000, 6000, 18500.
-- ANY/SOME : benar bila cocok dengan SALAH SATU nilai.
-- ALL      : benar bila cocok dengan SEMUA nilai.
-- =====================================================================

-- D1. Harga LEBIH BESAR dari SALAH SATU harga gol1
--     (artinya > 4000, nilai terkecil gol1).
--     Hasil: 8 baris (semua kecuali Antasida 4000 dan Tolak Angin 3500)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan > ANY (SELECT harga_satuan
                          FROM tb_obat
                          WHERE id_golongan = 'gol1');

-- D2. Sama dengan D1 memakai SOME (hasil identik).
--     Hasil: 8 baris
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan > SOME (SELECT harga_satuan
                           FROM tb_obat
                           WHERE id_golongan = 'gol1');

-- D3. = ANY setara IN. Harga gol2 = 8000 dan 12000.
--     Hasil: 2 baris -- Vitamin C (ob3), Cetirizine (ob7)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan = ANY (SELECT harga_satuan
                          FROM tb_obat
                          WHERE id_golongan = 'gol2');

-- D4. Harga LEBIH BESAR dari SEMUA harga gol2 (> 12000).
--     Memakai gol2 karena gol1 mengandung 18500, yang membuat
--     perbandingan > ALL tidak menyisakan satu baris pun.
--     Hasil: 2 baris -- Cefadroxil (15000), OBH Combi FORTE (18500)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan > ALL (SELECT harga_satuan
                          FROM tb_obat
                          WHERE id_golongan = 'gol2');

-- D5. Harga LEBIH KECIL dari SEMUA harga gol1 (< 4000).
--     Hasil: 1 baris -- Tolak Angin (3500)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan < ALL (SELECT harga_satuan
                          FROM tb_obat
                          WHERE id_golongan = 'gol1');

-- D6. Stok lebih besar dari SEMUA stok gol2 & gol3 (terbesar 110).
--     Hasil: 1 baris -- Tolak Angin (120)
SELECT id_obat, nama_obat, stok
FROM tb_obat
WHERE stok > ALL (SELECT stok
                  FROM tb_obat
                  WHERE id_golongan IN ('gol2', 'gol3'));

-- D7. Transaksi dengan total bayar tertinggi (>= ALL).
--     Hasil: 1 baris -- tran4 (20000)
SELECT id_transaksi, id_pasien, total_bayar
FROM tb_transaksi_obat
WHERE total_bayar >= ALL (SELECT total_bayar
                          FROM tb_transaksi_obat
                          WHERE total_bayar IS NOT NULL);

-- =====================================================================
-- E. CORRELATED SUBQUERY dengan EXISTS dan NOT EXISTS
-- =====================================================================

-- E1. Pasien yang pernah melakukan transaksi.
--     Hasil: 5 baris (pas1 s/d pas5)
SELECT p.id_pasien, p.nama_pasien
FROM tb_pasien_pembeli p
WHERE EXISTS (SELECT 1
              FROM tb_transaksi_obat t
              WHERE t.id_pasien = p.id_pasien);

-- E2. Pasien yang belum pernah melakukan transaksi.
--     Hasil: 2 baris -- pas6 (Vita), pas7 (Ares)
SELECT p.id_pasien, p.nama_pasien
FROM tb_pasien_pembeli p
WHERE NOT EXISTS (SELECT 1
                  FROM tb_transaksi_obat t
                  WHERE t.id_pasien = p.id_pasien);

-- E3. Pemasok yang memasok obat dengan stok lebih dari 100.
--     Hasil: 1 baris -- PT Kimia Farma (Tolak Angin 120, Promag 110)
SELECT s.id_pemasok, s.nama_pemasok, s.kota_asal
FROM tb_pemasok_pbf s
WHERE EXISTS (SELECT 1
              FROM tb_obat o
              WHERE o.id_pemasok = s.id_pemasok
                AND o.stok > 100);

-- E4. Pemasok yang TIDAK memasok obat dengan stok lebih dari 100.
--     Hasil: 3 baris -- PBF2, PBF3, PBF4
SELECT s.id_pemasok, s.nama_pemasok, s.kota_asal
FROM tb_pemasok_pbf s
WHERE NOT EXISTS (SELECT 1
                  FROM tb_obat o
                  WHERE o.id_pemasok = s.id_pemasok
                    AND o.stok > 100);

-- E5. Golongan obat yang memiliki minimal satu obat.
--     Hasil: 4 baris (gol1 s/d gol4)
SELECT g.id_golongan, g.nama_golongan
FROM tb_golongan_obat g
WHERE EXISTS (SELECT 1
              FROM tb_obat o
              WHERE o.id_golongan = g.id_golongan);

-- E6. Golongan obat yang belum memiliki obat.
--     Hasil: 0 baris (dengan data awal)
SELECT g.id_golongan, g.nama_golongan
FROM tb_golongan_obat g
WHERE NOT EXISTS (SELECT 1
                  FROM tb_obat o
                  WHERE o.id_golongan = g.id_golongan);

-- E7. Obat yang belum pernah terjual (versi NOT EXISTS dari C1).
--     Hasil: 5 baris -- ob6, ob7, ob8, ob9, ob10
SELECT o.id_obat, o.nama_obat, o.stok
FROM tb_obat o
WHERE NOT EXISTS (SELECT 1
                  FROM tb_transaksi_obat t
                  WHERE t.id_obat = o.id_obat);

-- E8. Pasien yang pernah membeli obat golongan Obat Keras (gol3).
--     Hasil: 1 baris -- Riyandi (pas4), pembeli Amoxicillin
SELECT p.id_pasien, p.nama_pasien
FROM tb_pasien_pembeli p
WHERE EXISTS (SELECT 1
              FROM tb_transaksi_obat t
              JOIN tb_obat o ON t.id_obat = o.id_obat
              WHERE t.id_pasien = p.id_pasien
                AND o.id_golongan = 'gol3');

-- =====================================================================
-- F. DATA UJI TAMBAHAN
-- Pada data awal, C3 dan E6 sudah menghasilkan 0 baris. Untuk
-- membuktikan NOT IN / NOT EXISTS benar-benar bekerja, ditambahkan
-- data uji dengan ID khusus (99) agar tidak menimpa data asli.
-- Semua data uji dihapus kembali di F6.
-- =====================================================================

-- F0. Tambah data uji (urutan induk -> anak karena ada FOREIGN KEY)
INSERT INTO tb_golongan_obat (id_golongan, nama_golongan)
VALUES ('gol99', 'Golongan Uji');

INSERT INTO tb_pemasok_pbf (id_pemasok, nama_pemasok, kota_asal, kontak)
VALUES ('PBF99', 'PT Uji Coba', 'Bandung', '081200000000');

INSERT INTO tb_obat (id_obat, id_golongan, id_pemasok, nama_obat, harga_satuan, stok)
VALUES ('ob99', 'gol99', 'PBF99', 'Obat Uji Belum Terjual', 7000, 30);

INSERT INTO tb_pasien_pembeli (id_pasien, nama_pasien, jenis_kelamin, alamat, tanggal_daftar)
VALUES ('pas99', 'Pasien Uji', 'P', 'Jl. Uji Coba No. 1', '2026-11-03');

-- F1. NOT IN: obat belum terjual. Hasil: 6 baris (ob6-ob10 + ob99)
SELECT id_obat, nama_obat
FROM tb_obat
WHERE id_obat NOT IN (SELECT id_obat FROM tb_transaksi_obat WHERE id_obat IS NOT NULL);

-- F2. NOT IN: pasien belum bertransaksi. Hasil: 3 baris (pas6, pas7, pas99)
SELECT id_pasien, nama_pasien
FROM tb_pasien_pembeli
WHERE id_pasien NOT IN (SELECT id_pasien FROM tb_transaksi_obat WHERE id_pasien IS NOT NULL);

-- F3. NOT IN: pemasok belum memasok obat. Hasil: 1 baris (PBF99)
SELECT id_pemasok, nama_pemasok
FROM tb_pemasok_pbf
WHERE id_pemasok NOT IN (SELECT id_pemasok FROM tb_obat WHERE id_pemasok IS NOT NULL);

-- F4. NOT EXISTS: golongan tanpa obat. Hasil: 1 baris (gol99)
SELECT g.id_golongan, g.nama_golongan
FROM tb_golongan_obat g
WHERE NOT EXISTS (SELECT 1 FROM tb_obat o WHERE o.id_golongan = g.id_golongan);

-- F5. NOT EXISTS: pasien tanpa transaksi. Hasil: 3 baris (pas6, pas7, pas99)
SELECT p.id_pasien, p.nama_pasien
FROM tb_pasien_pembeli p
WHERE NOT EXISTS (SELECT 1 FROM tb_transaksi_obat t WHERE t.id_pasien = p.id_pasien);

-- F6. Pembersihan data uji (anak -> induk karena FOREIGN KEY)
DELETE FROM tb_obat           WHERE id_obat    = 'ob99';
DELETE FROM tb_pasien_pembeli WHERE id_pasien  = 'pas99';
DELETE FROM tb_pemasok_pbf    WHERE id_pemasok = 'PBF99';
DELETE FROM tb_golongan_obat  WHERE id_golongan = 'gol99';

-- Bukti data asli utuh: 10 obat, 7 pasien, 4 pemasok, 4 golongan
SELECT 'tb_obat' AS tabel, COUNT(*) AS jumlah FROM tb_obat
UNION ALL SELECT 'tb_pasien_pembeli', COUNT(*) FROM tb_pasien_pembeli
UNION ALL SELECT 'tb_pemasok_pbf',    COUNT(*) FROM tb_pemasok_pbf
UNION ALL SELECT 'tb_golongan_obat',  COUNT(*) FROM tb_golongan_obat;
