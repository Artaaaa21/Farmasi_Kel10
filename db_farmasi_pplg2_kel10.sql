-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 14 Okt 2026 pada 16.11
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_farmasi_pplg2_kel10`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_golongan_obat`
--

CREATE TABLE `tb_golongan_obat` (
  `id_golongan` varchar(8) NOT NULL,
  `nama_golongan` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_golongan_obat`
--

INSERT INTO `tb_golongan_obat` (`id_golongan`, `nama_golongan`) VALUES
('gol1', 'Obat Resep'),
('gol2', 'Obat Vitamin'),
('gol3', 'Obat Keras'),
('gol4', 'Obat Herbal');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_log_farmasi`
--

CREATE TABLE `tb_log_farmasi` (
  `id_log` int(11) NOT NULL,
  `nama_operasi` varchar(30) DEFAULT NULL,
  `rincian` varchar(255) DEFAULT NULL,
  `waktu_eksekusi` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_log_farmasi`
--

INSERT INTO `tb_log_farmasi` (`id_log`, `nama_operasi`, `rincian`, `waktu_eksekusi`) VALUES
(1, 'INSERT OBAT', 'Menambahkan Paracetamol 500mg ke data obat', '2026-10-06 08:30:00'),
(2, 'INSERT PASIEN', 'Menambahkan pasien Andi Setiawan', '2026-10-06 09:00:00'),
(3, 'TRANSAKSI', 'Transaksi tran1 berhasil dilakukan', '2026-10-06 10:15:00'),
(4, 'TRANSAKSI', 'Transaksi tran2 berhasil dilakukan', '2026-10-06 11:20:00'),
(5, 'UPDATE STOK', 'Stok obat diperbarui setelah transaksi', '2026-10-07 14:30:00');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_obat`
--

CREATE TABLE `tb_obat` (
  `id_obat` varchar(8) NOT NULL,
  `id_golongan` varchar(8) DEFAULT NULL,
  `id_pemasok` varchar(8) DEFAULT NULL,
  `nama_obat` varchar(50) DEFAULT NULL,
  `harga_satuan` int(11) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_obat`
--

INSERT INTO `tb_obat` (`id_obat`, `id_golongan`, `id_pemasok`, `nama_obat`, `harga_satuan`, `stok`) VALUES
('ob1', 'gol1', 'PBF1', 'Paracetamol 500mg', 5000, 100),
('ob2', 'gol1', 'PBF2', 'Antasida Tablet', 4000, 80),
('ob3', 'gol2', 'PBF3', 'Vitamin C', 12000, 50),
('ob4', 'gol3', 'PBF4', 'Amoxicillin 500mg', 10000, 60),
('ob5', 'gol4', 'PBF1', 'Tolak Angin', 3500, 120);

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_pasien_pembeli`
--

CREATE TABLE `tb_pasien_pembeli` (
  `id_pasien` varchar(8) NOT NULL,
  `nama_pasien` varchar(50) DEFAULT NULL,
  `jenis_kelamin` char(1) DEFAULT NULL,
  `alamat` varchar(100) DEFAULT NULL,
  `tanggal_daftar` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_pasien_pembeli`
--

INSERT INTO `tb_pasien_pembeli` (`id_pasien`, `nama_pasien`, `jenis_kelamin`, `alamat`, `tanggal_daftar`) VALUES
('pas1', 'Messi Datvansa', 'L', 'Jl. Merdeka No. 10', '2026-10-01'),
('pas2', 'Rakhmat Dika', 'L', 'Jl. Diponegoro No. 15', '2026-10-02'),
('pas3', 'Rizky Praama', 'L', 'Jl. Pahlawan No. 21', '2026-10-03'),
('pas4', 'Riyandi', 'L', 'Jl. Ahmad Yani No. 8', '2026-10-04'),
('pas5', 'Dhanis', 'L', 'Jl. Gajah Mada No. 12', '2026-10-05');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_pemasok_pbf`
--

CREATE TABLE `tb_pemasok_pbf` (
  `id_pemasok` varchar(8) NOT NULL,
  `nama_pemasok` varchar(50) DEFAULT NULL,
  `kota_asal` varchar(30) DEFAULT NULL,
  `kontak` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_pemasok_pbf`
--

INSERT INTO `tb_pemasok_pbf` (`id_pemasok`, `nama_pemasok`, `kota_asal`, `kontak`) VALUES
('PBF1', 'PT Kimia Farma', 'Samarinda', '081234567890'),
('PBF2', 'PT Indofarma', 'Balikpapan', '081298765432'),
('PBF3', 'PT Pharos Indonesia', 'Jakarta', '082112345678'),
('PBF4', 'PT Kalbe Farma', 'Jakarta', '085212345678');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_pengguna`
--

CREATE TABLE `tb_pengguna` (
  `id_user` varchar(8) NOT NULL,
  `username` varchar(30) DEFAULT NULL,
  `password` varchar(60) DEFAULT NULL,
  `nama_lengkap` varchar(50) DEFAULT NULL,
  `role` enum('ADMIN','ADMIN_OBAT','KASIR') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_pengguna`
--

INSERT INTO `tb_pengguna` (`id_user`, `username`, `password`, `nama_lengkap`, `role`) VALUES
('111', 'admin_apotek', 'admin123', 'Admin Apotik', 'ADMIN'),
('222', 'admin_obat', 'obat123', 'Admin Obat', 'ADMIN_OBAT'),
('333', 'kasir_apotek', 'kasir123', 'Kasir Apotik', 'KASIR');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_transaksi_obat`
--

CREATE TABLE `tb_transaksi_obat` (
  `id_transaksi` varchar(8) NOT NULL,
  `id_pasien` varchar(8) DEFAULT NULL,
  `id_obat` varchar(8) DEFAULT NULL,
  `tanggal_transaksi` date DEFAULT NULL,
  `jumlah_beli` int(11) DEFAULT NULL,
  `total_bayar` int(11) DEFAULT NULL,
  `status_transaksi` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_transaksi_obat`
--

INSERT INTO `tb_transaksi_obat` (`id_transaksi`, `id_pasien`, `id_obat`, `tanggal_transaksi`, `jumlah_beli`, `total_bayar`, `status_transaksi`) VALUES
('tran1', 'pas1', 'ob1', '2026-10-06', 2, 10000, 'SELESAI'),
('tran2', 'pas2', 'ob2', '2026-10-06', 3, 12000, 'SELESAI'),
('tran3', 'pas3', 'ob3', '2026-10-07', 1, 12000, 'SELESAI'),
('tran4', 'pas4', 'ob4', '2026-10-07', 2, 20000, 'SELESAI'),
('tran5', 'pas5', 'ob5', '2026-10-08', 4, 14000, 'SELESAI');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `tb_golongan_obat`
--
ALTER TABLE `tb_golongan_obat`
  ADD PRIMARY KEY (`id_golongan`);

--
-- Indeks untuk tabel `tb_log_farmasi`
--
ALTER TABLE `tb_log_farmasi`
  ADD PRIMARY KEY (`id_log`);

--
-- Indeks untuk tabel `tb_obat`
--
ALTER TABLE `tb_obat`
  ADD PRIMARY KEY (`id_obat`),
  ADD KEY `id_golongan` (`id_golongan`),
  ADD KEY `id_pemasok` (`id_pemasok`);

--
-- Indeks untuk tabel `tb_pasien_pembeli`
--
ALTER TABLE `tb_pasien_pembeli`
  ADD PRIMARY KEY (`id_pasien`);

--
-- Indeks untuk tabel `tb_pemasok_pbf`
--
ALTER TABLE `tb_pemasok_pbf`
  ADD PRIMARY KEY (`id_pemasok`);

--
-- Indeks untuk tabel `tb_pengguna`
--
ALTER TABLE `tb_pengguna`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indeks untuk tabel `tb_transaksi_obat`
--
ALTER TABLE `tb_transaksi_obat`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD KEY `id_pasien` (`id_pasien`),
  ADD KEY `id_obat` (`id_obat`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `tb_log_farmasi`
--
ALTER TABLE `tb_log_farmasi`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `tb_obat`
--
ALTER TABLE `tb_obat`
  ADD CONSTRAINT `tb_obat_ibfk_1` FOREIGN KEY (`id_golongan`) REFERENCES `tb_golongan_obat` (`id_golongan`),
  ADD CONSTRAINT `tb_obat_ibfk_2` FOREIGN KEY (`id_pemasok`) REFERENCES `tb_pemasok_pbf` (`id_pemasok`);

--
-- Ketidakleluasaan untuk tabel `tb_transaksi_obat`
--
ALTER TABLE `tb_transaksi_obat`
  ADD CONSTRAINT `tb_transaksi_obat_ibfk_1` FOREIGN KEY (`id_pasien`) REFERENCES `tb_pasien_pembeli` (`id_pasien`),
  ADD CONSTRAINT `tb_transaksi_obat_ibfk_2` FOREIGN KEY (`id_obat`) REFERENCES `tb_obat` (`id_obat`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
