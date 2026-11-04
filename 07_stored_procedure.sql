-- 07_stored_procedure.sql
-- =====================================================================
-- Tahap 6    : Stored Procedure (Modul 7 : Stored Procedure)
-- Database   : db_farmasi_pplg2_kel10
-- Kelompok   : 10 (Riyandi, Owen, Ghani)
-- Prasyarat  : 01, 02, 03 sudah dijalankan.
-- Isi        : A. CREATE PROCEDURE & DELIMITER
--              B. Parameter IN  | C. Parameter OUT | D. Parameter INOUT
--              E. Percabangan IF-THEN-ELSE (termasuk sp_cek_ketersediaan_stok)
--              F. Melihat / menghapus procedure
--              G. Pembersihan data uji
--
-- CATATAN :
-- 1. Parameter diawali "p_", variabel lokal diawali "v_", agar tidak
--    bentrok dengan nama kolom (stok, id_obat).
-- 2. Di phpMyAdmin : jika baris DELIMITER menimbulkan error, hapus baris
--    DELIMITER dan ubah kotak "Delimiter" di bawah editor menjadi //.
-- 3. Setelah CREATE PROCEDURE, jalankan CALL lalu screenshot hasilnya.
-- =====================================================================

USE db_farmasi_pplg2_kel10;

-- =====================================================================
-- A. DEKLARASI STORED PROCEDURE DASAR (CREATE PROCEDURE, DELIMITER)
-- =====================================================================

-- A1. Menampilkan seluruh data obat
DROP PROCEDURE IF EXISTS sp_tampil_obat;
DELIMITER //
CREATE PROCEDURE sp_tampil_obat()
BEGIN
    SELECT id_obat, nama_obat, harga_satuan, stok
    FROM tb_obat;
END //
DELIMITER ;

-- Eksekusi. Hasil diharapkan: 10 baris obat
CALL sp_tampil_obat();


-- A2. Data obat beserta nama golongan dan nama pemasok
DROP PROCEDURE IF EXISTS sp_tampil_obat_lengkap;
DELIMITER //
CREATE PROCEDURE sp_tampil_obat_lengkap()
BEGIN
    SELECT o.id_obat, o.nama_obat, g.nama_golongan, p.nama_pemasok,
           o.harga_satuan, o.stok
    FROM tb_obat o
    JOIN tb_golongan_obat g ON o.id_golongan = g.id_golongan
    JOIN tb_pemasok_pbf   p ON o.id_pemasok  = p.id_pemasok;
END //
DELIMITER ;

-- Eksekusi. Hasil diharapkan: 10 baris dengan nama golongan & pemasok
CALL sp_tampil_obat_lengkap();


-- =====================================================================
-- B. PARAMETER MODE IN
-- =====================================================================

-- B1. Menampilkan obat berdasarkan golongan
DROP PROCEDURE IF EXISTS sp_obat_by_golongan;
DELIMITER //
CREATE PROCEDURE sp_obat_by_golongan(IN p_id_golongan VARCHAR(8))
BEGIN
    SELECT id_obat, nama_obat, harga_satuan, stok
    FROM tb_obat
    WHERE id_golongan = p_id_golongan;
END //
DELIMITER ;

-- Eksekusi. Hasil: 4 baris -- Paracetamol, Antasida, Ibuprofen,
--           OBH Combi Batuk FORTE
CALL sp_obat_by_golongan('gol1');
-- Hasil: 2 baris -- Amoxicillin 500mg, Promag Tablet
CALL sp_obat_by_golongan('gol3');


-- B2. Menambah pasien baru (tanggal daftar otomatis hari ini)
--     Memakai id 'pas8' karena pas1-pas7 sudah terpakai di 02.
DROP PROCEDURE IF EXISTS sp_tambah_pasien;
DELIMITER //
CREATE PROCEDURE sp_tambah_pasien(
    IN p_id_pasien     VARCHAR(8),
    IN p_nama_pasien   VARCHAR(50),
    IN p_jenis_kelamin CHAR(1),
    IN p_alamat        VARCHAR(100)
)
BEGIN
    INSERT INTO tb_pasien_pembeli (nama_pasien, id_pasien, jenis_kelamin, alamat, tanggal_daftar)
    VALUES (p_nama_pasien, p_id_pasien, p_jenis_kelamin, p_alamat, CURDATE());
END //
DELIMITER ;

-- Eksekusi. Hasil: pas8 (Pasien Uji) muncul, total pasien menjadi 8
CALL sp_tambah_pasien('pas8', 'Pasien Uji', 'P', 'Jl. Uji Coba No. 1');
SELECT id_pasien, nama_pasien, tanggal_daftar
FROM tb_pasien_pembeli
ORDER BY id_pasien DESC
LIMIT 3;


-- B3. Menambah stok obat (jumlah negatif = mengurangi)
DROP PROCEDURE IF EXISTS sp_tambah_stok;
DELIMITER //
CREATE PROCEDURE sp_tambah_stok(IN p_id_obat VARCHAR(8), IN p_jumlah INT)
BEGIN
    UPDATE tb_obat
    SET stok = stok + p_jumlah
    WHERE id_obat = p_id_obat;

    SELECT id_obat, nama_obat, stok
    FROM tb_obat
    WHERE id_obat = p_id_obat;
END //
DELIMITER ;

-- Eksekusi. Hasil: stok ob1 100 -> 110, lalu kembali 100
CALL sp_tambah_stok('ob1', 10);
CALL sp_tambah_stok('ob1', -10);


-- =====================================================================
-- C. PARAMETER MODE OUT
-- =====================================================================

-- C1. Menghitung jumlah jenis obat
DROP PROCEDURE IF EXISTS sp_hitung_obat;
DELIMITER //
CREATE PROCEDURE sp_hitung_obat(OUT p_total INT)
BEGIN
    SELECT COUNT(*) INTO p_total
    FROM tb_obat;
END //
DELIMITER ;

-- Eksekusi. Hasil: total_obat = 10
CALL sp_hitung_obat(@total_obat);
SELECT @total_obat AS total_obat;


-- C2. Menghitung total pendapatan dari semua transaksi
DROP PROCEDURE IF EXISTS sp_total_pendapatan;
DELIMITER //
CREATE PROCEDURE sp_total_pendapatan(OUT p_total INT)
BEGIN
    SELECT IFNULL(SUM(total_bayar), 0) INTO p_total
    FROM tb_transaksi_obat;
END //
DELIMITER ;

-- Eksekusi. Hasil: 68000 (selama tran1-tran5 saja yang ada)
CALL sp_total_pendapatan(@total_pendapatan);
SELECT @total_pendapatan AS total_pendapatan;


-- C3. Mengambil detail satu obat lewat beberapa parameter OUT
DROP PROCEDURE IF EXISTS sp_detail_obat;
DELIMITER //
CREATE PROCEDURE sp_detail_obat(
    IN  p_id_obat VARCHAR(8),
    OUT p_nama    VARCHAR(50),
    OUT p_harga   INT,
    OUT p_stok    INT
)
BEGIN
    SELECT nama_obat, harga_satuan, stok
    INTO p_nama, p_harga, p_stok
    FROM tb_obat
    WHERE id_obat = p_id_obat;
END //
DELIMITER ;

-- Eksekusi. Hasil: Amoxicillin 500mg | 10000 | 60
CALL sp_detail_obat('ob4', @nama, @harga, @stok);
SELECT @nama AS nama_obat, @harga AS harga_satuan, @stok AS stok;


-- =====================================================================
-- D. PARAMETER MODE INOUT
-- =====================================================================

-- D1. Menaikkan harga sebesar persentase tertentu
DROP PROCEDURE IF EXISTS sp_naikkan_harga;
DELIMITER //
CREATE PROCEDURE sp_naikkan_harga(INOUT p_harga INT, IN p_persen INT)
BEGIN
    SET p_harga = p_harga + (p_harga * p_persen / 100);
END //
DELIMITER ;

-- Eksekusi. Hasil: harga_baru = 11000
SET @harga_baru = 10000;
CALL sp_naikkan_harga(@harga_baru, 10);
SELECT @harga_baru AS harga_baru;


-- D2. Mengakumulasi stok beberapa obat ke dalam satu variabel
DROP PROCEDURE IF EXISTS sp_akumulasi_stok;
DELIMITER //
CREATE PROCEDURE sp_akumulasi_stok(IN p_id_obat VARCHAR(8), INOUT p_total_stok INT)
BEGIN
    DECLARE v_stok INT DEFAULT 0;

    SELECT IFNULL(stok, 0) INTO v_stok
    FROM tb_obat
    WHERE id_obat = p_id_obat;

    SET p_total_stok = p_total_stok + v_stok;
END //
DELIMITER ;

-- Eksekusi. Hasil: 100 -> 180 -> 230 (stok ob1 100, ob2 80, ob3 50)
SET @total_stok = 0;
CALL sp_akumulasi_stok('ob1', @total_stok);
SELECT @total_stok AS total_stok;   -- 100
CALL sp_akumulasi_stok('ob2', @total_stok);
SELECT @total_stok AS total_stok;   -- 180
CALL sp_akumulasi_stok('ob3', @total_stok);
SELECT @total_stok AS total_stok;   -- 230


-- =====================================================================
-- E. PERCABANGAN KONDISIONAL (IF-THEN-ELSEIF-ELSE)
-- =====================================================================

-- E1. Mengecek status stok obat
-- stok = 0 -> Habis | stok <= 50 -> Menipis | lainnya -> Aman
DROP PROCEDURE IF EXISTS sp_cek_stok;
DELIMITER //
CREATE PROCEDURE sp_cek_stok(IN p_id_obat VARCHAR(8), OUT p_status VARCHAR(30))
BEGIN
    DECLARE v_stok INT DEFAULT NULL;

    SELECT stok INTO v_stok
    FROM tb_obat
    WHERE id_obat = p_id_obat;

    IF v_stok IS NULL THEN
        SET p_status = 'Obat tidak ditemukan';
    ELSEIF v_stok = 0 THEN
        SET p_status = 'Habis';
    ELSEIF v_stok <= 50 THEN
        SET p_status = 'Menipis';
    ELSE
        SET p_status = 'Aman';
    END IF;
END //
DELIMITER ;

-- Eksekusi. Hasil: ob1 = Aman (100), ob3 = Menipis (50),
--           xx = Obat tidak ditemukan
CALL sp_cek_stok('ob1', @status);  SELECT @status AS status_stok;
CALL sp_cek_stok('ob3', @status);  SELECT @status AS status_stok;
CALL sp_cek_stok('xx',  @status);  SELECT @status AS status_stok;


-- E2. Menentukan kategori harga obat
-- harga < 5000 -> Murah | 5000-9999 -> Sedang | >= 10000 -> Mahal
DROP PROCEDURE IF EXISTS sp_kategori_harga;
DELIMITER //
CREATE PROCEDURE sp_kategori_harga(IN p_id_obat VARCHAR(8), OUT p_kategori VARCHAR(30))
BEGIN
    DECLARE v_harga INT DEFAULT NULL;

    SELECT harga_satuan INTO v_harga
    FROM tb_obat
    WHERE id_obat = p_id_obat;

    IF v_harga IS NULL THEN
        SET p_kategori = 'Obat tidak ditemukan';
    ELSEIF v_harga < 5000 THEN
        SET p_kategori = 'Murah';
    ELSEIF v_harga < 10000 THEN
        SET p_kategori = 'Sedang';
    ELSE
        SET p_kategori = 'Mahal';
    END IF;
END //
DELIMITER ;

-- Eksekusi. Hasil: ob2 = Murah (4000), ob1 = Sedang (5000),
--           ob3 = Mahal (12000)
CALL sp_kategori_harga('ob2', @kategori);  SELECT @kategori AS kategori_harga;
CALL sp_kategori_harga('ob1', @kategori);  SELECT @kategori AS kategori_harga;
CALL sp_kategori_harga('ob3', @kategori);  SELECT @kategori AS kategori_harga;


-- E3. Transaksi pembelian obat dengan validasi bertahap
DROP PROCEDURE IF EXISTS sp_beli_obat;
DELIMITER //
CREATE PROCEDURE sp_beli_obat(
    IN  p_id_transaksi VARCHAR(8),
    IN  p_id_pasien    VARCHAR(8),
    IN  p_id_obat      VARCHAR(8),
    IN  p_jumlah       INT,
    OUT p_pesan        VARCHAR(100)
)
BEGIN
    DECLARE v_pasien INT DEFAULT 0;
    DECLARE v_stok   INT DEFAULT NULL;
    DECLARE v_harga  INT DEFAULT NULL;

    SELECT COUNT(*) INTO v_pasien
    FROM tb_pasien_pembeli
    WHERE id_pasien = p_id_pasien;

    SELECT stok, harga_satuan INTO v_stok, v_harga
    FROM tb_obat
    WHERE id_obat = p_id_obat;

    IF v_pasien = 0 THEN
        SET p_pesan = 'Gagal: pasien tidak ditemukan';
    ELSEIF v_stok IS NULL THEN
        SET p_pesan = 'Gagal: obat tidak ditemukan';
    ELSEIF p_jumlah <= 0 THEN
        SET p_pesan = 'Gagal: jumlah beli harus lebih dari 0';
    ELSEIF p_jumlah > v_stok THEN
        SET p_pesan = CONCAT('Gagal: stok tidak cukup (sisa ', v_stok, ')');
    ELSE
        INSERT INTO tb_transaksi_obat
            (id_transaksi, id_pasien, id_obat, tanggal_transaksi, jumlah_beli, total_bayar, status_transaksi)
        VALUES
            (p_id_transaksi, p_id_pasien, p_id_obat, CURDATE(), p_jumlah, v_harga * p_jumlah, 'SELESAI');

        UPDATE tb_obat
        SET stok = stok - p_jumlah
        WHERE id_obat = p_id_obat;

        SET p_pesan = 'Berhasil: transaksi disimpan';
    END IF;
END //
DELIMITER ;

-- Eksekusi. Hasil yang diharapkan:
-- 1) Berhasil (25000 = 5 x 5000), stok ob1 100 -> 95
CALL sp_beli_obat('tran6', 'pas1', 'ob1', 5, @pesan);   SELECT @pesan AS pesan;
-- 2) Gagal: stok tidak cukup (sisa 50)
CALL sp_beli_obat('tran7', 'pas1', 'ob3', 999, @pesan); SELECT @pesan AS pesan;
-- 3) Gagal: obat tidak ditemukan
CALL sp_beli_obat('tran8', 'pas1', 'xx', 1, @pesan);    SELECT @pesan AS pesan;
-- 4) Gagal: pasien tidak ditemukan
CALL sp_beli_obat('tran9', 'xx', 'ob1', 1, @pesan);     SELECT @pesan AS pesan;

-- Bukti perubahan data (screenshot)
SELECT id_transaksi, id_pasien, id_obat, jumlah_beli, total_bayar
FROM tb_transaksi_obat
ORDER BY id_transaksi DESC;
SELECT id_obat, nama_obat, stok FROM tb_obat WHERE id_obat = 'ob1';


-- E4. PROCEDURE WAJIB PENUGASAN: sp_cek_ketersediaan_stok()
-- Parameter IN (id obat + jumlah yang ingin dibeli) dan logika
-- IF-THEN-ELSE untuk memutuskan ketersediaan stok.
DROP PROCEDURE IF EXISTS sp_cek_ketersediaan_stok;
DELIMITER //
CREATE PROCEDURE sp_cek_ketersediaan_stok(
    IN p_id_obat VARCHAR(8),
    IN p_jumlah  INT
)
BEGIN
    DECLARE v_stok INT DEFAULT NULL;

    SELECT stok INTO v_stok
    FROM tb_obat
    WHERE id_obat = p_id_obat;

    IF v_stok IS NULL THEN
        SELECT p_id_obat AS id_obat, 'Obat tidak ditemukan' AS keterangan;
    ELSEIF p_jumlah <= 0 THEN
        SELECT p_id_obat AS id_obat, 'Jumlah permintaan tidak valid' AS keterangan;
    ELSEIF p_jumlah <= v_stok THEN
        SELECT p_id_obat AS id_obat, v_stok AS stok_tersedia,
               'Stok TERSEDIA' AS keterangan;
    ELSE
        SELECT p_id_obat AS id_obat, v_stok AS stok_tersedia,
               CONCAT('Stok TIDAK CUKUP, kurang ', p_jumlah - v_stok, ' unit') AS keterangan;
    END IF;
END //
DELIMITER ;

-- Eksekusi. Hasil yang diharapkan:
-- 1) ob1, minta 20 -> Stok TERSEDIA (stok 95 setelah E3)
CALL sp_cek_ketersediaan_stok('ob1', 20);
-- 2) ob3, minta 100 -> Stok TIDAK CUKUP, kurang 50 unit
CALL sp_cek_ketersediaan_stok('ob3', 100);
-- 3) xx -> Obat tidak ditemukan
CALL sp_cek_ketersediaan_stok('xx', 5);


-- =====================================================================
-- F. MELIHAT DAN MENGHAPUS PROCEDURE
-- =====================================================================

-- Daftar procedure pada database ini (screenshot)
SHOW PROCEDURE STATUS WHERE Db = 'db_farmasi_pplg2_kel10';

-- Melihat isi/definisi satu procedure
SHOW CREATE PROCEDURE sp_cek_ketersediaan_stok;

-- Contoh menghapus procedure:
-- DROP PROCEDURE IF EXISTS sp_tampil_obat;


-- =====================================================================
-- G. PEMBERSIHAN DATA UJI (jalankan setelah semua screenshot selesai)
-- Mengembalikan data ke kondisi 02: 10 obat, 7 pasien, 5 transaksi.
-- =====================================================================
DELETE FROM tb_transaksi_obat WHERE id_transaksi = 'tran6';
DELETE FROM tb_pasien_pembeli WHERE id_pasien   = 'pas8';
UPDATE tb_obat SET stok = 100 WHERE id_obat = 'ob1';

-- Bukti data kembali seperti semula (10 / 7 / 5)
SELECT 'tb_obat' AS tabel, COUNT(*) AS jumlah FROM tb_obat
UNION ALL SELECT 'tb_pasien_pembeli', COUNT(*) FROM tb_pasien_pembeli
UNION ALL SELECT 'tb_transaksi_obat', COUNT(*) FROM tb_transaksi_obat;
