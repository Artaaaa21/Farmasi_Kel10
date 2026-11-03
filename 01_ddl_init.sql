-- ========================================================
-- 01_ddl_init.sql
-- Tahap 1: Inisialisasi Database & DDL (Modul 1 & 2: DDL & Relasi)
-- Database : db_farmasi_pplg2_kel10
-- Kelompok : 10 (Riyandi, Owen, Ghani)
-- Server   : MariaDB 10.4.x  -> collation utf8mb4_general_ci
-- Fungsi   : membangun ulang SELURUH struktur database dari nol.
--            File ini TIDAK berisi data. Data ada di 02_dml_data.sql
-- Aman dijalankan berulang (DROP DATABASE IF EXISTS di awal).
-- ========================================================

DROP DATABASE IF EXISTS db_farmasi_pplg2_kel10;
CREATE DATABASE db_farmasi_pplg2_kel10
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;
USE db_farmasi_pplg2_kel10;

-- ========================================================
-- BAGIAN A. TABEL INDUK (dibuat lebih dulu, karena dirujuk FK)
-- ========================================================

-- A1. tb_golongan_obat
CREATE TABLE tb_golongan_obat (
  id_golongan   VARCHAR(8)  NOT NULL,
  nama_golongan VARCHAR(30) NOT NULL,
  CONSTRAINT pk_golongan       PRIMARY KEY (id_golongan),
  CONSTRAINT uq_nama_golongan  UNIQUE (nama_golongan)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- A2. tb_pemasok_pbf
CREATE TABLE tb_pemasok_pbf (
  id_pemasok   VARCHAR(8)  NOT NULL,
  nama_pemasok VARCHAR(50) NOT NULL,
  kota_asal    VARCHAR(30) NOT NULL,
  kontak       VARCHAR(15) NOT NULL,
  CONSTRAINT pk_pemasok PRIMARY KEY (id_pemasok)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- A3. tb_pasien_pembeli
CREATE TABLE tb_pasien_pembeli (
  id_pasien      VARCHAR(8)   NOT NULL,
  nama_pasien    VARCHAR(50)  NOT NULL,
  jenis_kelamin  CHAR(1)      NOT NULL,
  alamat         VARCHAR(100) DEFAULT NULL,
  tanggal_daftar DATE         NOT NULL,
  CONSTRAINT pk_pasien            PRIMARY KEY (id_pasien),
  CONSTRAINT ck_jenis_kelamin     CHECK (jenis_kelamin IN ('L','P')),
  CONSTRAINT ck_tanggal_daftar    CHECK (tanggal_daftar >= '2020-01-01')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- A4. tb_pengguna
CREATE TABLE tb_pengguna (
  id_user      VARCHAR(8)  NOT NULL,
  username     VARCHAR(30) NOT NULL,
  password     VARCHAR(60) NOT NULL,
  nama_lengkap VARCHAR(50) NOT NULL,
  role         ENUM('ADMIN','ADMIN_OBAT','KASIR') NOT NULL,
  CONSTRAINT pk_pengguna  PRIMARY KEY (id_user),
  CONSTRAINT uq_username  UNIQUE (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ========================================================
-- BAGIAN B. TABEL ANAK (memiliki FOREIGN KEY)
-- ========================================================

-- B1. tb_obat (anak dari tb_golongan_obat & tb_pemasok_pbf)
CREATE TABLE tb_obat (
  id_obat      VARCHAR(8)  NOT NULL,
  id_golongan  VARCHAR(8)  NOT NULL,
  id_pemasok   VARCHAR(8)  NOT NULL,
  nama_obat    VARCHAR(50) NOT NULL,
  harga_satuan INT         NOT NULL DEFAULT 0,
  stok         INT         NOT NULL DEFAULT 0,
  CONSTRAINT pk_obat PRIMARY KEY (id_obat),
  KEY idx_obat_golongan (id_golongan),
  KEY idx_obat_pemasok  (id_pemasok),
  CONSTRAINT fk_obat_golongan FOREIGN KEY (id_golongan)
    REFERENCES tb_golongan_obat (id_golongan)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_obat_pemasok FOREIGN KEY (id_pemasok)
    REFERENCES tb_pemasok_pbf (id_pemasok)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  -- Integritas domain
  CONSTRAINT ck_harga_satuan CHECK (harga_satuan > 0),
  CONSTRAINT ck_stok         CHECK (stok >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- B2. tb_transaksi_obat (anak dari tb_pasien_pembeli & tb_obat)
CREATE TABLE tb_transaksi_obat (
  id_transaksi      VARCHAR(8)  NOT NULL,
  id_pasien         VARCHAR(8)  NOT NULL,
  id_obat           VARCHAR(8)  NOT NULL,
  tanggal_transaksi DATE        NOT NULL,
  jumlah_beli       INT         NOT NULL,
  total_bayar       INT         NOT NULL,
  status_transaksi  VARCHAR(15) NOT NULL DEFAULT 'SELESAI',
  CONSTRAINT pk_transaksi PRIMARY KEY (id_transaksi),
  KEY idx_transaksi_pasien (id_pasien),
  KEY idx_transaksi_obat   (id_obat),
  CONSTRAINT fk_transaksi_pasien FOREIGN KEY (id_pasien)
    REFERENCES tb_pasien_pembeli (id_pasien)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_transaksi_obat FOREIGN KEY (id_obat)
    REFERENCES tb_obat (id_obat)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_jumlah_beli CHECK (jumlah_beli > 0),
  CONSTRAINT ck_total_bayar CHECK (total_bayar > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ========================================================
-- BAGIAN C. TABEL PENDUKUNG: audit log untuk Trigger (Tahap 8)
-- 6 tabel inti relasional ada di Bagian A dan B; tabel ini pendukung.
-- ========================================================
CREATE TABLE tb_log_farmasi (
  id_log          INT          NOT NULL AUTO_INCREMENT,
  nama_operasi    VARCHAR(30)  DEFAULT NULL,
  rincian         VARCHAR(255) DEFAULT NULL,
  waktu_eksekusi  DATETIME     DEFAULT NULL,
  CONSTRAINT pk_log PRIMARY KEY (id_log)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ========================================================
-- BAGIAN D. DEMONSTRASI MODUL 2: ALTER TABLE
-- Dijalankan pada tabel LATIHAN, supaya skema asli tidak berubah.
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
DESCRIBE tb_obat_alter_demo;

-- Bersihkan tabel latihan agar database hanya berisi 7 tabel sesungguhnya
DROP TABLE tb_obat_alter_demo;

-- ========================================================
-- BAGIAN E. VERIFIKASI (jalankan manual setelah import)
-- ========================================================
-- SHOW TABLES;                              -- harus 7 tabel
-- SELECT * FROM information_schema.TABLE_CONSTRAINTS
--   WHERE CONSTRAINT_SCHEMA = 'db_farmasi_pplg2_kel10';
