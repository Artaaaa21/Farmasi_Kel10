-- =====================================================================
-- 06_subquery.sql
-- Logbook Pengujian Nested Query
-- Pekan 6 (09 - 13 Nov 2026) - Tahap 5B: Subquery Tingkat Lanjut
-- Modul 6: Nested & Correlated Query
-- Database : db_farmasi_pplg2_kel10
-- Isi      : A. IN | B. NOT IN | C. ANY / SOME / ALL | D. EXISTS / NOT EXISTS
--            E. Data uji tambahan (opsional) + pembersihan
-- =====================================================================

USE db_farmasi_pplg2_kel10;


-- =====================================================================
-- A. MULTIPLE-ROW SUBQUERY dengan operator IN
-- Subquery mengembalikan BANYAK baris (satu kolom), lalu dicocokkan
-- dengan IN.
-- =====================================================================

-- A1. Tampilkan obat yang pernah dibeli (ada di tabel transaksi).
-- Hasil diharapkan: 5 baris (ob1 s/d ob5)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE id_obat IN (SELECT id_obat FROM tb_transaksi_obat);

-- A2. Tampilkan pasien yang pernah membeli obat minimal 3 buah sekali beli.
-- Hasil diharapkan: Rakhmat Dika (pas2), Dhanis (pas5)
SELECT id_pasien, nama_pasien, alamat
FROM tb_pasien_pembeli
WHERE id_pasien IN (SELECT id_pasien
                    FROM tb_transaksi_obat
                    WHERE jumlah_beli >= 3);

-- A3. Tampilkan obat yang dipasok oleh pemasok dari kota Jakarta.
-- Hasil diharapkan: Vitamin C (ob3), Amoxicillin 500mg (ob4)
SELECT id_obat, nama_obat, id_pemasok, harga_satuan
FROM tb_obat
WHERE id_pemasok IN (SELECT id_pemasok
                     FROM tb_pemasok_pbf
                     WHERE kota_asal = 'Jakarta');

-- A4. Tampilkan golongan obat yang memiliki obat dengan harga di atas 8000.
-- Hasil diharapkan: Obat Vitamin (gol2), Obat Keras (gol3)
SELECT id_golongan, nama_golongan
FROM tb_golongan_obat
WHERE id_golongan IN (SELECT id_golongan
                      FROM tb_obat
                      WHERE harga_satuan > 8000);


-- =====================================================================
-- B. MULTIPLE-ROW SUBQUERY dengan operator NOT IN
-- CATATAN: kolom di subquery HARUS dipastikan tidak NULL
-- (tambahkan IS NOT NULL). Jika subquery menghasilkan satu saja NULL,
-- NOT IN akan mengembalikan 0 baris.
-- Dengan data awal, hasil B1-B3 = 0 baris karena semua data sudah
-- terpakai. Lihat Bagian E untuk pengujian dengan data tambahan.
-- =====================================================================

-- B1. Obat yang belum pernah terjual.
-- Hasil diharapkan: 0 baris (semua obat sudah pernah dibeli)
SELECT id_obat, nama_obat, stok
FROM tb_obat
WHERE id_obat NOT IN (SELECT id_obat
                      FROM tb_transaksi_obat
                      WHERE id_obat IS NOT NULL);

-- B2. Pasien yang belum pernah melakukan transaksi.
-- Hasil diharapkan: 0 baris
SELECT id_pasien, nama_pasien
FROM tb_pasien_pembeli
WHERE id_pasien NOT IN (SELECT id_pasien
                        FROM tb_transaksi_obat
                        WHERE id_pasien IS NOT NULL);

-- B3. Pemasok yang belum memasok obat apa pun.
-- Hasil diharapkan: 0 baris
SELECT id_pemasok, nama_pemasok, kota_asal
FROM tb_pemasok_pbf
WHERE id_pemasok NOT IN (SELECT id_pemasok
                         FROM tb_obat
                         WHERE id_pemasok IS NOT NULL);

-- B4. Obat selain yang bergolongan Obat Resep (gol1).
-- Hasil diharapkan: Vitamin C, Amoxicillin 500mg, Tolak Angin
SELECT id_obat, nama_obat, id_golongan
FROM tb_obat
WHERE id_obat NOT IN (SELECT id_obat
                      FROM tb_obat
                      WHERE id_golongan = 'gol1');


-- =====================================================================
-- C. SUBQUERY KOMPARASI MULTI-NILAI: ANY / SOME dan ALL
-- Harga obat golongan gol1 = 5000 dan 4000.
-- ANY / SOME : kondisi benar jika cocok dengan SALAH SATU nilai.
-- ALL        : kondisi benar jika cocok dengan SEMUA nilai.
-- (SOME adalah sinonim ANY.)
-- =====================================================================

-- C1. Obat yang harganya LEBIH BESAR dari SALAH SATU harga obat gol1.
-- (artinya > nilai terkecil = 4000)
-- Hasil diharapkan: Paracetamol (5000), Vitamin C (12000), Amoxicillin (10000)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan > ANY (SELECT harga_satuan
                          FROM tb_obat
                          WHERE id_golongan = 'gol1');

-- C2. Sama dengan C1, memakai SOME (hasil harus identik dengan C1).
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan > SOME (SELECT harga_satuan
                           FROM tb_obat
                           WHERE id_golongan = 'gol1');

-- C3. = ANY setara dengan IN.
-- Hasil diharapkan: Vitamin C (ob3) saja
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan = ANY (SELECT harga_satuan
                          FROM tb_obat
                          WHERE id_golongan = 'gol2');

-- C4. Obat yang harganya LEBIH BESAR dari SEMUA harga obat gol1.
-- (artinya > nilai terbesar = 5000)
-- Hasil diharapkan: Vitamin C (12000), Amoxicillin (10000)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan > ALL (SELECT harga_satuan
                          FROM tb_obat
                          WHERE id_golongan = 'gol1');

-- C5. Obat yang harganya LEBIH KECIL dari SEMUA harga obat gol1.
-- (artinya < nilai terkecil = 4000)
-- Hasil diharapkan: Tolak Angin (3500)
SELECT id_obat, nama_obat, harga_satuan
FROM tb_obat
WHERE harga_satuan < ALL (SELECT harga_satuan
                          FROM tb_obat
                          WHERE id_golongan = 'gol1');

-- C6. Obat dengan stok lebih besar dari SEMUA stok obat gol2 dan gol3.
-- (stok gol2 = 50, gol3 = 60, jadi harus > 60)
-- Hasil diharapkan: Paracetamol (100), Antasida (80), Tolak Angin (120)
SELECT id_obat, nama_obat, stok
FROM tb_obat
WHERE stok > ALL (SELECT stok
                  FROM tb_obat
                  WHERE id_golongan IN ('gol2', 'gol3'));

-- C7. Transaksi dengan total bayar tertinggi (>= ALL total bayar).
-- Hasil diharapkan: tran4 (20000)
SELECT id_transaksi, id_pasien, total_bayar
FROM tb_transaksi_obat
WHERE total_bayar >= ALL (SELECT total_bayar
                          FROM tb_transaksi_obat
                          WHERE total_bayar IS NOT NULL);


-- =====================================================================
-- D. CORRELATED SUBQUERY dengan EXISTS dan NOT EXISTS
-- Subquery di dalam mengacu ke kolom tabel luar (alias p, o, g),
-- sehingga dijalankan ulang untuk setiap baris tabel luar.
-- EXISTS hanya memeriksa ADA / TIDAK ADA baris (SELECT 1 sudah cukup).
-- =====================================================================

-- D1. Pasien yang pernah melakukan transaksi.
-- Hasil diharapkan: 5 baris (pas1 s/d pas5)
SELECT p.id_pasien, p.nama_pasien
FROM tb_pasien_pembeli p
WHERE EXISTS (SELECT 1
              FROM tb_transaksi_obat t
              WHERE t.id_pasien = p.id_pasien);

-- D2. Pasien yang belum pernah melakukan transaksi.
-- Hasil diharapkan: 0 baris (dengan data awal)
SELECT p.id_pasien, p.nama_pasien
FROM tb_pasien_pembeli p
WHERE NOT EXISTS (SELECT 1
                  FROM tb_transaksi_obat t
                  WHERE t.id_pasien = p.id_pasien);

-- D3. Pemasok yang memasok obat dengan stok lebih dari 100.
-- Hasil diharapkan: PT Kimia Farma (PBF1) karena Tolak Angin stok 120
SELECT s.id_pemasok, s.nama_pemasok, s.kota_asal
FROM tb_pemasok_pbf s
WHERE EXISTS (SELECT 1
              FROM tb_obat o
              WHERE o.id_pemasok = s.id_pemasok
                AND o.stok > 100);

-- D4. Pemasok yang TIDAK memasok obat dengan stok lebih dari 100.
-- Hasil diharapkan: PBF2, PBF3, PBF4
SELECT s.id_pemasok, s.nama_pemasok, s.kota_asal
FROM tb_pemasok_pbf s
WHERE NOT EXISTS (SELECT 1
                  FROM tb_obat o
                  WHERE o.id_pemasok = s.id_pemasok
                    AND o.stok > 100);

-- D5. Golongan obat yang memiliki minimal satu obat.
-- Hasil diharapkan: 4 baris (gol1 s/d gol4)
SELECT g.id_golongan, g.nama_golongan
FROM tb_golongan_obat g
WHERE EXISTS (SELECT 1
              FROM tb_obat o
              WHERE o.id_golongan = g.id_golongan);

-- D6. Golongan obat yang belum memiliki obat.
-- Hasil diharapkan: 0 baris (dengan data awal)
SELECT g.id_golongan, g.nama_golongan
FROM tb_golongan_obat g
WHERE NOT EXISTS (SELECT 1
                  FROM tb_obat o
                  WHERE o.id_golongan = g.id_golongan);

-- D7. Obat yang belum pernah terjual (versi NOT EXISTS dari B1).
-- Hasil diharapkan: 0 baris (dengan data awal)
SELECT o.id_obat, o.nama_obat, o.stok
FROM tb_obat o
WHERE NOT EXISTS (SELECT 1
                  FROM tb_transaksi_obat t
                  WHERE t.id_obat = o.id_obat);

-- D8. Pasien yang pernah membeli obat golongan Obat Keras (gol3).
-- Hasil diharapkan: Riyandi (pas4)
SELECT p.id_pasien, p.nama_pasien
FROM tb_pasien_pembeli p
WHERE EXISTS (SELECT 1
              FROM tb_transaksi_obat t
              JOIN tb_obat o ON t.id_obat = o.id_obat
              WHERE t.id_pasien = p.id_pasien
                AND o.id_golongan = 'gol3');


-- =====================================================================
-- E. DATA UJI TAMBAHAN (OPSIONAL)
-- Karena data awal sudah saling terhubung semua, query NOT IN dan
-- NOT EXISTS menghasilkan 0 baris. Tambahkan data uji berikut agar
-- hasilnya terlihat, lalu hapus lagi di akhir.
-- =====================================================================

-- E0. Tambah data uji
INSERT INTO tb_golongan_obat (id_golongan, nama_golongan) VALUES ('gol5', 'Obat Bebas');
INSERT INTO tb_pemasok_pbf (id_pemasok, nama_pemasok, kota_asal, nomor_kontak)
VALUES ('PBF5', 'PT Uji Coba', 'Bandung', '081200000000');
INSERT INTO tb_obat (id_obat, id_golongan, id_pemasok, nama_obat, harga_satuan, stok, keterangan)
VALUES ('ob6', 'gol1', 'PBF1', 'Obat Uji Belum Terjual', 7000, 30, NULL);
INSERT INTO tb_pasien_pembeli (nama_pasien, id_pasien, jenis_kelamin, alamat, tanggal_daftar)
VALUES ('Pasien Uji', 'pas6', 'P', 'Jl. Uji Coba No. 1', '2026-11-03');

-- E1. NOT IN: obat belum terjual. Hasil diharapkan: ob6
SELECT id_obat, nama_obat
FROM tb_obat
WHERE id_obat NOT IN (SELECT id_obat FROM tb_transaksi_obat WHERE id_obat IS NOT NULL);

-- E2. NOT IN: pasien belum bertransaksi. Hasil diharapkan: pas6
SELECT id_pasien, nama_pasien
FROM tb_pasien_pembeli
WHERE id_pasien NOT IN (SELECT id_pasien FROM tb_transaksi_obat WHERE id_pasien IS NOT NULL);

-- E3. NOT IN: pemasok belum memasok obat. Hasil diharapkan: PBF5
SELECT id_pemasok, nama_pemasok
FROM tb_pemasok_pbf
WHERE id_pemasok NOT IN (SELECT id_pemasok FROM tb_obat WHERE id_pemasok IS NOT NULL);

-- E4. NOT EXISTS: golongan tanpa obat. Hasil diharapkan: gol5
SELECT g.id_golongan, g.nama_golongan
FROM tb_golongan_obat g
WHERE NOT EXISTS (SELECT 1 FROM tb_obat o WHERE o.id_golongan = g.id_golongan);

-- E5. NOT EXISTS: pasien tanpa transaksi. Hasil diharapkan: pas6
SELECT p.id_pasien, p.nama_pasien
FROM tb_pasien_pembeli p
WHERE NOT EXISTS (SELECT 1 FROM tb_transaksi_obat t WHERE t.id_pasien = p.id_pasien);

-- E6. Pembersihan data uji (urutan penting karena ada foreign key)
DELETE FROM tb_obat           WHERE id_obat = 'ob6';
DELETE FROM tb_pasien_pembeli WHERE id_pasien = 'pas6';
DELETE FROM tb_pemasok_pbf    WHERE id_pemasok = 'PBF5';
DELETE FROM tb_golongan_obat  WHERE id_golongan = 'gol5';
