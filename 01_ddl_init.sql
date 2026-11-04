-- 01_ddl_init.sql
-- ========================================================
-- Tahap 1  : Inisialisasi Database & DDL (Modul 1 & 2: DDL & Relasi)
-- Database : db_farmasi_pplg2_kel10
-- Kelompok : 10 (Riyandi, Owen, Ghani)
-- Server   : MariaDB 10.4.x -> collation utf8mb4_general_ci
-- ========================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";
SET NAMES utf8mb4;

DROP DATABASE IF EXISTS db_farmasi_pplg2_kel10;
CREATE DATABASE db_farmasi_pplg2_kel10
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE db_farmasi_pplg2_kel10;

-- ========================================================
-- BAGIAN 1. CREATE TABLE (mengikuti template dump)
-- ========================================================

CREATE TABLE tb_golongan_obat (
  id_golongan   varchar(8)  NOT NULL,
  nama_golongan varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE tb_log_farmasi (
  id_log         int(11)      NOT NULL,
  nama_operasi   varchar(30)  DEFAULT NULL,
  rincian        varchar(255) DEFAULT NULL,
  waktu_eksekusi datetime     DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE tb_obat (
  id_obat      varchar(8)  NOT NULL,
  id_golongan  varchar(8)  DEFAULT NULL,
  id_pemasok   varchar(8)  DEFAULT NULL,
  nama_obat    varchar(50) DEFAULT NULL,
  harga_satuan int(11)     DEFAULT NULL,
  stok         int(11)     DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE tb_pasien_pembeli (
  id_pasien      varchar(8)   NOT NULL,
  nama_pasien    varchar(50)  DEFAULT NULL,
  jenis_kelamin  char(1)      DEFAULT NULL,
  alamat         varchar(100) DEFAULT NULL,
  tanggal_daftar date         DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE tb_pemasok_pbf (
  id_pemasok   varchar(8)  NOT NULL,
  nama_pemasok varchar(50) DEFAULT NULL,
  kota_asal    varchar(30) DEFAULT NULL,
  kontak       varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE tb_pengguna (
  id_user      varchar(8)  NOT NULL,
  username     varchar(30) DEFAULT NULL,
  password     varchar(60) DEFAULT NULL,
  nama_lengkap varchar(50) DEFAULT NULL,
  role         enum('ADMIN','ADMIN_OBAT','KASIR') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE tb_transaksi_obat (
  id_transaksi      varchar(8)  NOT NULL,
  id_pasien         varchar(8)  DEFAULT NULL,
  id_obat           varchar(8)  DEFAULT NULL,
  tanggal_transaksi date        DEFAULT NULL,
  jumlah_beli       int(11)     DEFAULT NULL,
  total_bayar       int(11)     DEFAULT NULL,
  status_transaksi  varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ========================================================
-- BAGIAN 2. PRIMARY KEY, KEY, dan AUTO_INCREMENT
-- ========================================================

ALTER TABLE tb_golongan_obat
  ADD PRIMARY KEY (id_golongan);

ALTER TABLE tb_log_farmasi
  ADD PRIMARY KEY (id_log);

ALTER TABLE tb_obat
  ADD PRIMARY KEY (id_obat),
  ADD KEY id_golongan (id_golongan),
  ADD KEY id_pemasok (id_pemasok);

ALTER TABLE tb_pasien_pembeli
  ADD PRIMARY KEY (id_pasien);

ALTER TABLE tb_pemasok_pbf
  ADD PRIMARY KEY (id_pemasok);

ALTER TABLE tb_pengguna
  ADD PRIMARY KEY (id_user),
  ADD UNIQUE KEY username (username);

ALTER TABLE tb_transaksi_obat
  ADD PRIMARY KEY (id_transaksi),
  ADD KEY id_pasien (id_pasien),
  ADD KEY id_obat (id_obat);

ALTER TABLE tb_log_farmasi
  MODIFY id_log int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

-- ========================================================
-- BAGIAN 3. FOREIGN KEY (integritas referensial)
-- Nama constraint sama dengan dump agar identik saat diekspor ulang.
-- ========================================================

ALTER TABLE tb_obat
  ADD CONSTRAINT tb_obat_ibfk_1 FOREIGN KEY (id_golongan)
      REFERENCES tb_golongan_obat (id_golongan),
  ADD CONSTRAINT tb_obat_ibfk_2 FOREIGN KEY (id_pemasok)
      REFERENCES tb_pemasok_pbf (id_pemasok);

ALTER TABLE tb_transaksi_obat
  ADD CONSTRAINT tb_transaksi_obat_ibfk_1 FOREIGN KEY (id_pasien)
      REFERENCES tb_pasien_pembeli (id_pasien),
  ADD CONSTRAINT tb_transaksi_obat_ibfk_2 FOREIGN KEY (id_obat)
      REFERENCES tb_obat (id_obat);

-- ========================================================
-- BAGIAN 4. DEMONSTRASI MODUL 2: ALTER TABLE
-- Dijalankan pada tabel LATIHAN agar skema asli tidak berubah.
-- ========================================================
DROP TABLE IF EXISTS tb_obat_alter_demo;
CREATE TABLE tb_obat_alter_demo LIKE tb_obat;

-- D1. ADD: menambah kolom di posisi terakhir
ALTER TABLE tb_obat_alter_demo
  ADD COLUMN catatan_rak VARCHAR(50);

-- D2. ADD ... AFTER: menyisipkan kolom setelah kolom tertentu
ALTER TABLE tb_obat_alter_demo
  ADD COLUMN kadaluarsa DATE AFTER stok;

-- D3. ADD ... FIRST: menjadikan kolom paling depan
ALTER TABLE tb_obat_alter_demo
  ADD COLUMN kode_lama VARCHAR(8) FIRST;

-- D4. CHANGE: ganti nama kolom sekaligus definisinya
ALTER TABLE tb_obat_alter_demo
  CHANGE catatan_rak lokasi_rak VARCHAR(60);

-- D5. MODIFY ... AFTER: ubah definisi + pindahkan posisi tanpa ganti nama
ALTER TABLE tb_obat_alter_demo
  MODIFY lokasi_rak VARCHAR(60) AFTER nama_obat;

-- D6. MODIFY ... FIRST: pindahkan kolom ke posisi pertama
ALTER TABLE tb_obat_alter_demo
  MODIFY kode_lama VARCHAR(8) FIRST;

-- D7. Bukti hasil: urutan kolom setelah diubah
-- >>> SCREENSHOT baris ini SEBELUM tabel latihan dihapus <<<
DESCRIBE tb_obat_alter_demo;

DROP TABLE tb_obat_alter_demo;

-- ========================================================
-- BAGIAN 5. VERIFIKASI
-- ========================================================
-- SHOW TABLES;   -- harus 7 tabel
-- SHOW CREATE TABLE tb_transaksi_obat;   -- bandingkan dengan dump
-- SELECT * FROM information_schema.TABLE_CONSTRAINTS
--   WHERE CONSTRAINT_SCHEMA = 'db_farmasi_pplg2_kel10';

-- ========================================================
-- BAGIAN 6. OPSIONAL: PERKETAT INTEGRITAS (tidak aktif)
-- Hanya jika diminta menambah NOT NULL / CHECK di atas template dump.
-- Jalankan setelah 02_dml_data.sql, karena data harus memenuhi aturan.
-- ========================================================
-- ALTER TABLE tb_pemasok_pbf
--   MODIFY nama_pemasok varchar(50) NOT NULL,
--   MODIFY kota_asal    varchar(30) NOT NULL,
--   MODIFY kontak       varchar(15) NOT NULL;
--
-- ALTER TABLE tb_pasien_pembeli
--   MODIFY nama_pasien   varchar(50) NOT NULL,
--   MODIFY jenis_kelamin char(1)     NOT NULL,
--   MODIFY tanggal_daftar date       NOT NULL,
--   ADD CONSTRAINT ck_jenis_kelamin  CHECK (jenis_kelamin IN ('L','P')),
--   ADD CONSTRAINT ck_tanggal_daftar CHECK (tanggal_daftar >= '2020-01-01');
--
-- ALTER TABLE tb_pengguna
--   MODIFY username     varchar(30) NOT NULL,
--   MODIFY password     varchar(60) NOT NULL,
--   MODIFY nama_lengkap varchar(50) NOT NULL,
--   MODIFY role         enum('ADMIN','ADMIN_OBAT','KASIR') NOT NULL;
--
-- ALTER TABLE tb_obat
--   MODIFY id_golongan  varchar(8)  NOT NULL,
--   MODIFY id_pemasok   varchar(8)  NOT NULL,
--   MODIFY nama_obat    varchar(50) NOT NULL,
--   MODIFY harga_satuan int(11)     NOT NULL DEFAULT 0,
--   MODIFY stok         int(11)     NOT NULL DEFAULT 0,
--   ADD CONSTRAINT ck_harga_satuan CHECK (harga_satuan > 0),
--   ADD CONSTRAINT ck_stok         CHECK (stok >= 0);
--
-- ALTER TABLE tb_transaksi_obat
--   MODIFY id_pasien         varchar(8)  NOT NULL,
--   MODIFY id_obat           varchar(8)  NOT NULL,
--   MODIFY tanggal_transaksi date        NOT NULL,
--   MODIFY jumlah_beli       int(11)     NOT NULL,
--   MODIFY total_bayar       int(11)     NOT NULL,
--   MODIFY status_transaksi  varchar(15) NOT NULL DEFAULT 'SELESAI',
--   ADD CONSTRAINT ck_jumlah_beli CHECK (jumlah_beli > 0),
--   ADD CONSTRAINT ck_total_bayar CHECK (total_bayar > 0);
--
-- ALTER TABLE tb_golongan_obat
--   ADD CONSTRAINT uq_nama_golongan UNIQUE (nama_golongan);
