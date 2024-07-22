-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 21, 2024 at 07:23 PM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `toko_buku_online`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CountTotalPurchasesByCategoryAndCustomer` (IN `p_kategori` VARCHAR(255), IN `p_pelanggan_id` INT)  BEGIN
    DECLARE total_pembelian DECIMAL(10,2);

    IF p_kategori = 'Fiksi Cerita' THEN
        SELECT SUM(t.total_harga) INTO total_pembelian
        FROM transaksi t
        JOIN buku b ON t.buku_id = b.buku_id
        JOIN kategori k ON b.kategori_id = k.kategori_id
        WHERE k.nama_kategori = p_kategori AND t.pelanggan_id = p_pelanggan_id;
    ELSEIF p_kategori = 'Buku Pelajaran' THEN
        SELECT SUM(t.total_harga) INTO total_pembelian
        FROM transaksi t
        JOIN buku b ON t.buku_id = b.buku_id
        JOIN kategori k ON b.kategori_id = k.kategori_id
        WHERE k.nama_kategori = p_kategori AND t.pelanggan_id = p_pelanggan_id;
    ELSE
        SET total_pembelian = 0;
    END IF;

    SELECT total_pembelian;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowBooksByCategoryAndPrice` (IN `category` VARCHAR(50), IN `max_price` DECIMAL(10,2))  BEGIN
    SELECT * FROM buku 
    WHERE kategori = category AND harga <= max_price;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowLowStockBooks` ()  BEGIN
    SELECT * FROM buku WHERE stok < 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_HitungTotalPembelianPerJenis` (`p_kode_bank` VARCHAR(20), `p_jenis_barang` VARCHAR(20))  BEGIN
    DECLARE total_pembelian DECIMAL(10,2);

    IF p_jenis_barang = 'Fiksi Cerita' THEN
        SELECT SUM(t.total_harga) INTO total_pembelian
        FROM Transaksi t
        JOIN Buku b ON t.buku_id = b.buku_id
        JOIN Kategori k ON b.kategori_id = k.kategori_id
        WHERE k.nama_kategori = p_jenis_barang AND t.kode_bank = p_kode_bank;
    ELSEIF p_jenis_barang = 'Buku Pelajaran' THEN
        SELECT SUM(t.total_harga) INTO total_pembelian
        FROM Transaksi t
        JOIN Buku b ON t.buku_id = b.buku_id
        JOIN Kategori k ON b.kategori_id = k.kategori_id
        WHERE k.nama_kategori = p_jenis_barang AND t.kode_bank = p_kode_bank;
    ELSE
        SET total_pembelian = 0;
    END IF;

    SELECT total_pembelian;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_buku` ()  BEGIN
    UPDATE buku SET harga = harga * 1.1 WHERE id = 1;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_AmbilJumlahPembeli` () RETURNS INT(11) BEGIN 
    DECLARE jumlah INT; 
    SELECT COUNT(*) INTO jumlah FROM transaksi; 
    RETURN jumlah; 
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_buku_by_kategori` (`p_kategori_id` INT, `p_tahun_terbit` INT) RETURNS TEXT CHARSET utf8mb4 BEGIN
  DECLARE result TEXT;
  SET result = (
    SELECT GROUP_CONCAT(judul_buku)
    FROM Buku
    WHERE kategori_id = p_kategori_id AND tahun_terbit = p_tahun_terbit
  );
  RETURN result;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `buku`
--

CREATE TABLE `buku` (
  `buku_id` int(11) NOT NULL,
  `judul_buku` varchar(255) DEFAULT NULL,
  `penulis_id` int(50) DEFAULT NULL,
  `penerbit_id` int(25) DEFAULT NULL,
  `kategori_id` int(5) DEFAULT NULL,
  `isbn` varchar(20) DEFAULT NULL,
  `jumlah_halaman` int(4) DEFAULT NULL,
  `tahun_terbit` int(4) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL,
  `stok` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `buku`
--

INSERT INTO `buku` (`buku_id`, `judul_buku`, `penulis_id`, `penerbit_id`, `kategori_id`, `isbn`, `jumlah_halaman`, `tahun_terbit`, `harga`, `stok`) VALUES
(1, 'Buku Baru Diupdate (Inside View)', 13, 1, 1, '9780 618 053829', 1178, 1954, '55000.00', 10),
(2, 'Kisah cinta ilham', 14, 2, 2, '9780 140 192165', 352, 1813, '75000.00', 15),
(3, 'Misteri Ilham', 15, 3, 3, '9780 446 310789', 336, 1960, '90000.00', 8),
(4, 'Ilham hilang harapan', 16, 4, 4, '9780 451 524935', 328, 1949, '85000.00', 12),
(5, 'Mafia Ilham', 17, 5, 5, '9780 307 588013', 224, 1951, '70000.00', 20),
(6, 'Ilham yang tersakiti', 18, 6, 6, '9780 743 273565', 218, 1925, '95000.00', 18),
(7, 'cita cita ilham', 19, 7, 7, '9780 545 010221', 306, 1997, '120000.00', 25);

--
-- Triggers `buku`
--
DELIMITER $$
CREATE TRIGGER `after_buku_delete` AFTER DELETE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log_buku (
        event_type,
        old_buku_id,
        old_judul_buku,
        old_kategori_id,
        old_harga,
        new_buku_id,
        new_judul_buku,
        new_kategori_id,
        new_harga
    )
    VALUES (
        'DELETE',
        OLD.buku_id,
        OLD.judul_buku,
        OLD.kategori_id,
        OLD.harga,
        NULL, -- Karena ini adalah delete, new_buku_id dan lainnya NULL
        NULL,
        NULL,
        NULL
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_buku_insert` AFTER INSERT ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log_buku (
        event_type,
        old_buku_id,
        old_judul_buku,
        old_kategori_id,
        old_harga,
        new_buku_id,
        new_judul_buku,
        new_kategori_id,
        new_harga
    )
    VALUES (
        'INSERT',
        NULL, -- Karena ini adalah insert, old_buku_id dan lainnya NULL
        NULL,
        NULL,
        NULL,
        NEW.buku_id,
        NEW.judul_buku,
        NEW.kategori_id,
        NEW.harga
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_buku_update` AFTER UPDATE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log_buku (
        event_type,
        old_buku_id,
        old_judul_buku,
        old_kategori_id,
        old_harga,
        new_buku_id,
        new_judul_buku,
        new_kategori_id,
        new_harga
    )
    VALUES (
        'UPDATE',
        OLD.buku_id,
        OLD.judul_buku,
        OLD.kategori_id,
        OLD.harga,
        NEW.buku_id,
        NEW.judul_buku,
        NEW.kategori_id,
        NEW.harga
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_delete_buku` AFTER DELETE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log (event_type, old_buku_id, old_judul_buku, old_kategori_id, old_harga)
    VALUES ('AFTER DELETE', OLD.buku_id, OLD.judul_buku, OLD.kategori_id, OLD.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_buku` AFTER INSERT ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log (event_type, new_buku_id, new_judul_buku, new_kategori_id, new_harga)
    VALUES ('AFTER INSERT', NEW.buku_id, NEW.judul_buku, NEW.kategori_id, NEW.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_buku` AFTER UPDATE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log (event_type, old_buku_id, old_judul_buku, old_kategori_id, old_harga, new_buku_id, new_judul_buku, new_kategori_id, new_harga)
    VALUES ('AFTER UPDATE', OLD.buku_id, OLD.judul_buku, OLD.kategori_id, OLD.harga, NEW.buku_id, NEW.judul_buku, NEW.kategori_id, NEW.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_buku_delete` BEFORE DELETE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log_buku (
        event_type,
        old_buku_id,
        old_judul_buku,
        old_kategori_id,
        old_harga,
        new_buku_id,
        new_judul_buku,
        new_kategori_id,
        new_harga
    )
    VALUES (
        'DELETE',
        OLD.buku_id,
        OLD.judul_buku,
        OLD.kategori_id,
        OLD.harga,
        NULL, -- Karena ini adalah delete, new_buku_id dan lainnya NULL
        NULL,
        NULL,
        NULL
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_buku_insert` BEFORE INSERT ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log_buku (
        event_type,
        old_buku_id,
        old_judul_buku,
        old_kategori_id,
        old_harga,
        new_buku_id,
        new_judul_buku,
        new_kategori_id,
        new_harga
    )
    VALUES (
        'INSERT',
        NULL, -- Karena ini adalah insert, old_buku_id dan lainnya NULL
        NULL,
        NULL,
        NULL,
        NEW.buku_id,
        NEW.judul_buku,
        NEW.kategori_id,
        NEW.harga
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_buku_update` BEFORE UPDATE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log_buku (
        event_type,
        old_buku_id,
        old_judul_buku,
        old_kategori_id,
        old_harga,
        new_buku_id,
        new_judul_buku,
        new_kategori_id,
        new_harga
    )
    VALUES (
        'UPDATE',
        OLD.buku_id,
        OLD.judul_buku,
        OLD.kategori_id,
        OLD.harga,
        NEW.buku_id,
        NEW.judul_buku,
        NEW.kategori_id,
        NEW.harga
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_buku` BEFORE DELETE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log (event_type, old_buku_id, old_judul_buku, old_kategori_id, old_harga)
    VALUES ('BEFORE DELETE', OLD.buku_id, OLD.judul_buku, OLD.kategori_id, OLD.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_buku` BEFORE INSERT ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log (event_type, new_buku_id, new_judul_buku, new_kategori_id, new_harga)
    VALUES ('BEFORE INSERT', NEW.buku_id, NEW.judul_buku, NEW.kategori_id, NEW.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_buku` BEFORE UPDATE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log (event_type, old_buku_id, old_judul_buku, old_kategori_id, old_harga, new_buku_id, new_judul_buku, new_kategori_id, new_harga)
    VALUES ('BEFORE UPDATE', OLD.buku_id, OLD.judul_buku, OLD.kategori_id, OLD.harga, NEW.buku_id, NEW.judul_buku, NEW.kategori_id, NEW.harga);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `buku baru diupdate (inside view)`
-- (See below for the actual view)
--
CREATE TABLE `buku baru diupdate (inside view)` (
`transaksi_id` int(11)
,`tanggal_transaksi` date
,`pelanggan_id` int(11)
,`total_harga` decimal(10,2)
,`buku_id` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `horizontal_view`
-- (See below for the actual view)
--
CREATE TABLE `horizontal_view` (
`buku_id` int(11)
,`judul_buku` varchar(255)
,`penerbit_id` int(25)
);

-- --------------------------------------------------------

--
-- Table structure for table `index_table_1`
--

CREATE TABLE `index_table_1` (
  `id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `index_table_2`
--

CREATE TABLE `index_table_2` (
  `id` int(11) DEFAULT NULL,
  `product_name` varchar(50) DEFAULT NULL,
  `supplier_name` varchar(50) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `index_table_3`
--

CREATE TABLE `index_table_3` (
  `id` int(11) DEFAULT NULL,
  `customer_name` varchar(50) DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Stand-in structure for view `inside_view`
-- (See below for the actual view)
--
CREATE TABLE `inside_view` (
`buku_id` int(11)
,`judul_buku` varchar(255)
,`nama_kategori` varchar(255)
);

-- --------------------------------------------------------

--
-- Table structure for table `kategori`
--

CREATE TABLE `kategori` (
  `kategori_id` int(11) NOT NULL,
  `nama_kategori` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `kategori`
--

INSERT INTO `kategori` (`kategori_id`, `nama_kategori`) VALUES
(1, 'Fiksi Cerita'),
(2, 'Buku Pelajaran'),
(3, 'Komik'),
(4, 'Sastra'),
(5, 'Sejarah'),
(6, 'Ilmu Pengetahuan Alam'),
(7, 'Teknologi Informasi');

-- --------------------------------------------------------

--
-- Table structure for table `log`
--

CREATE TABLE `log` (
  `log_id` int(11) NOT NULL,
  `event_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `event_type` varchar(20) DEFAULT NULL,
  `old_buku_id` int(11) DEFAULT NULL,
  `old_judul_buku` varchar(255) DEFAULT NULL,
  `old_kategori_id` int(11) DEFAULT NULL,
  `old_harga` decimal(10,2) DEFAULT NULL,
  `new_buku_id` int(11) DEFAULT NULL,
  `new_judul_buku` varchar(255) DEFAULT NULL,
  `new_kategori_id` int(11) DEFAULT NULL,
  `new_harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `log`
--

INSERT INTO `log` (`log_id`, `event_time`, `event_type`, `old_buku_id`, `old_judul_buku`, `old_kategori_id`, `old_harga`, `new_buku_id`, `new_judul_buku`, `new_kategori_id`, `new_harga`) VALUES
(1, '2024-07-21 07:37:38', 'BEFORE UPDATE', 1, 'Buku Baru Diupdate', 1, '55000.00', 1, 'Buku Baru Diupdate', 1, '55000.00'),
(2, '2024-07-21 07:37:38', 'AFTER UPDATE', 1, 'Buku Baru Diupdate', 1, '55000.00', 1, 'Buku Baru Diupdate', 1, '55000.00'),
(3, '2024-07-21 07:39:13', 'BEFORE UPDATE', 1, 'Buku Baru Diupdate', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(4, '2024-07-21 07:39:13', 'AFTER UPDATE', 1, 'Buku Baru Diupdate', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(5, '2024-07-21 07:39:52', 'BEFORE UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(6, '2024-07-21 07:39:52', 'AFTER UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(9, '2024-07-21 07:43:18', 'BEFORE UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(10, '2024-07-21 07:43:18', 'AFTER UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(11, '2024-07-21 07:44:02', 'BEFORE UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(12, '2024-07-21 07:44:02', 'AFTER UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(13, '2024-07-21 07:44:13', 'BEFORE UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(14, '2024-07-21 07:44:13', 'AFTER UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00');

-- --------------------------------------------------------

--
-- Table structure for table `log_buku`
--

CREATE TABLE `log_buku` (
  `log_id` int(11) NOT NULL,
  `event_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `event_type` varchar(20) DEFAULT NULL,
  `old_buku_id` int(11) DEFAULT NULL,
  `old_judul_buku` varchar(255) DEFAULT NULL,
  `old_kategori_id` int(11) DEFAULT NULL,
  `old_harga` decimal(10,2) DEFAULT NULL,
  `new_buku_id` int(11) DEFAULT NULL,
  `new_judul_buku` varchar(255) DEFAULT NULL,
  `new_kategori_id` int(11) DEFAULT NULL,
  `new_harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `log_buku`
--

INSERT INTO `log_buku` (`log_id`, `event_time`, `event_type`, `old_buku_id`, `old_judul_buku`, `old_kategori_id`, `old_harga`, `new_buku_id`, `new_judul_buku`, `new_kategori_id`, `new_harga`) VALUES
(1, '2024-07-21 07:37:38', 'UPDATE', 1, 'Buku Baru Diupdate', 1, '55000.00', 1, 'Buku Baru Diupdate', 1, '55000.00'),
(2, '2024-07-21 07:37:38', 'UPDATE', 1, 'Buku Baru Diupdate', 1, '55000.00', 1, 'Buku Baru Diupdate', 1, '55000.00'),
(3, '2024-07-21 07:39:13', 'UPDATE', 1, 'Buku Baru Diupdate', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(4, '2024-07-21 07:39:13', 'UPDATE', 1, 'Buku Baru Diupdate', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(5, '2024-07-21 07:39:52', 'UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(6, '2024-07-21 07:39:52', 'UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(9, '2024-07-21 07:43:18', 'UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(10, '2024-07-21 07:43:18', 'UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(11, '2024-07-21 07:44:02', 'UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(12, '2024-07-21 07:44:02', 'UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(13, '2024-07-21 07:44:13', 'UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00'),
(14, '2024-07-21 07:44:13', 'UPDATE', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00', 1, 'Buku Baru Diupdate (Inside View)', 1, '55000.00');

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `pelanggan_id` int(11) NOT NULL,
  `nama_pelanggan` varchar(255) DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `nomor_telpon` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`pelanggan_id`, `nama_pelanggan`, `alamat`, `nomor_telpon`, `email`) VALUES
(1, 'amin ilham', 'yogyakarta', '1234567890', 'amikan@gmail.com'),
(2, 'ilham maulana', 'semarang', '9876543210', 'maulanakan@gmail.com'),
(3, 'maulana ilham', 'jakarta', '5555555555', 'ilhamkan@gmail.com'),
(4, 'ndunigo', 'palembang', '4444444444', 'ndunigokan@gmail.com'),
(5, 'exsa', 'madura', '3333333333', 'exsakan@gmail.com'),
(6, 'ahmad', 'papua', '2222222222', 'ahmadkan@gmail.com'),
(7, 'azhar', 'aceh', '7777777777', 'azharkan@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `penerbit`
--

CREATE TABLE `penerbit` (
  `penerbit_id` int(11) NOT NULL,
  `nama_penerbit` varchar(255) DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `nomor_telpon` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `penerbit`
--

INSERT INTO `penerbit` (`penerbit_id`, `nama_penerbit`, `alamat`, `nomor_telpon`, `email`) VALUES
(1, 'Aminmedia', 'yogyakarta', '81234567890', 'Ammin@gmail.com'),
(2, 'Ilhamtech', 'surabaya', '12345678900', 'Ilham@gmail.com'),
(3, 'Maulanainfo', 'kalimantan', '0', 'Maulana@gmail.com'),
(4, 'Ndunigoorg', 'magelang', '123456789101', 'Ndunigo@gmail.com'),
(5, 'Exsainfokan', 'semarang', '812332232', 'Exsa@gmail.com'),
(6, 'Ahmadmediakan', 'kebumen', '812322222', 'Ahmad@gmail.com'),
(7, 'Azharinicom', 'cikarang', '81234533333', 'Azhar@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `penulis`
--

CREATE TABLE `penulis` (
  `penulis_id` int(11) NOT NULL,
  `nama_penulis` varchar(255) DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `nomor_telpon` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `penulis`
--

INSERT INTO `penulis` (`penulis_id`, `nama_penulis`, `alamat`, `nomor_telpon`, `email`) VALUES
(13, 'Amin', 'YOGYAKARTA', '81234567891', 'amin@gmail.com'),
(14, 'Ilham', 'SURABAYA', '81234567892', 'ilham@gmail.com'),
(15, 'Maulana', 'KALIMANTAN', '81234567893', 'maulana@gmail.com'),
(16, 'Exsa', 'MAGELANG', '81234567894', 'exsa@gmail.com'),
(17, 'Wardana', 'SEMARANG', '81234567895', 'wardana@gmail.com'),
(18, 'Ahmad', 'KEBUMEN', '81234567896', 'ahmad@gmail.com'),
(19, 'Azhar', 'CIKARANG', '81234567897', 'azhar@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `transaksi_id` int(11) NOT NULL,
  `tanggal_transaksi` date DEFAULT NULL,
  `pelanggan_id` int(11) DEFAULT NULL,
  `total_harga` decimal(10,2) DEFAULT NULL,
  `buku_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`transaksi_id`, `tanggal_transaksi`, `pelanggan_id`, `total_harga`, `buku_id`) VALUES
(1, '2023-07-20', 1, '100000.00', 1),
(2, '2023-07-21', 2, '75000.00', 2),
(3, '2023-07-22', 3, '90000.00', 3),
(4, '2023-07-23', 4, '85000.00', 4),
(5, '2023-07-24', 5, '70000.00', 5),
(6, '2023-07-25', 6, '95000.00', 6),
(7, '2023-07-26', 7, '120000.00', 7);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vertical_view`
-- (See below for the actual view)
--
CREATE TABLE `vertical_view` (
`buku_id` int(11)
,`judul_buku` varchar(255)
,`penerbit_id` int(25)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_barang`
-- (See below for the actual view)
--
CREATE TABLE `v_barang` (
`id` int(11)
,`sku` varchar(255)
,`seller` int(25)
,`harga` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_barang_limited`
-- (See below for the actual view)
--
CREATE TABLE `v_barang_limited` (
`buku_id` int(11)
,`sku` varchar(255)
,`seller` int(25)
);

-- --------------------------------------------------------

--
-- Structure for view `buku baru diupdate (inside view)`
--
DROP TABLE IF EXISTS `buku baru diupdate (inside view)`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `buku baru diupdate (inside view)`  AS  select `transaksi`.`transaksi_id` AS `transaksi_id`,`transaksi`.`tanggal_transaksi` AS `tanggal_transaksi`,`transaksi`.`pelanggan_id` AS `pelanggan_id`,`transaksi`.`total_harga` AS `total_harga`,`transaksi`.`buku_id` AS `buku_id` from `transaksi` ;

-- --------------------------------------------------------

--
-- Structure for view `horizontal_view`
--
DROP TABLE IF EXISTS `horizontal_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horizontal_view`  AS  select `buku`.`buku_id` AS `buku_id`,`buku`.`judul_buku` AS `judul_buku`,`buku`.`penerbit_id` AS `penerbit_id` from `buku` ;

-- --------------------------------------------------------

--
-- Structure for view `inside_view`
--
DROP TABLE IF EXISTS `inside_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `inside_view`  AS  select `b`.`buku_id` AS `buku_id`,`b`.`judul_buku` AS `judul_buku`,`k`.`nama_kategori` AS `nama_kategori` from (`buku` `b` join `kategori` `k` on(`b`.`kategori_id` = `k`.`kategori_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `vertical_view`
--
DROP TABLE IF EXISTS `vertical_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vertical_view`  AS  select `buku`.`buku_id` AS `buku_id`,`buku`.`judul_buku` AS `judul_buku`,`buku`.`penerbit_id` AS `penerbit_id` from `buku` ;

-- --------------------------------------------------------

--
-- Structure for view `v_barang`
--
DROP TABLE IF EXISTS `v_barang`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_barang`  AS  select `buku`.`buku_id` AS `id`,`buku`.`judul_buku` AS `sku`,`buku`.`penerbit_id` AS `seller`,`buku`.`harga` AS `harga` from `buku` ;

-- --------------------------------------------------------

--
-- Structure for view `v_barang_limited`
--
DROP TABLE IF EXISTS `v_barang_limited`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_barang_limited`  AS  select `buku`.`buku_id` AS `buku_id`,`buku`.`judul_buku` AS `sku`,`buku`.`penerbit_id` AS `seller` from `buku` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `buku`
--
ALTER TABLE `buku`
  ADD PRIMARY KEY (`buku_id`),
  ADD KEY `fk_buku_penulis` (`penulis_id`),
  ADD KEY `fk_buku_penerbit` (`penerbit_id`),
  ADD KEY `fk_buku_kategori` (`kategori_id`);

--
-- Indexes for table `index_table_1`
--
ALTER TABLE `index_table_1`
  ADD KEY `idx_index_table_1` (`name`,`category`);

--
-- Indexes for table `index_table_3`
--
ALTER TABLE `index_table_3`
  ADD KEY `idx_index_table_3` (`customer_name`,`order_date`);

--
-- Indexes for table `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`kategori_id`);

--
-- Indexes for table `log`
--
ALTER TABLE `log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `log_buku`
--
ALTER TABLE `log_buku`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`pelanggan_id`);

--
-- Indexes for table `penerbit`
--
ALTER TABLE `penerbit`
  ADD PRIMARY KEY (`penerbit_id`);

--
-- Indexes for table `penulis`
--
ALTER TABLE `penulis`
  ADD PRIMARY KEY (`penulis_id`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`transaksi_id`),
  ADD KEY `fk_transaksi_pelanggan` (`pelanggan_id`),
  ADD KEY `fk_transaksi_buku` (`buku_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `buku`
--
ALTER TABLE `buku`
  MODIFY `buku_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `log`
--
ALTER TABLE `log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `log_buku`
--
ALTER TABLE `log_buku`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `buku`
--
ALTER TABLE `buku`
  ADD CONSTRAINT `fk_buku_kategori` FOREIGN KEY (`kategori_id`) REFERENCES `kategori` (`kategori_id`),
  ADD CONSTRAINT `fk_buku_penerbit` FOREIGN KEY (`penerbit_id`) REFERENCES `penerbit` (`penerbit_id`),
  ADD CONSTRAINT `fk_buku_penulis` FOREIGN KEY (`penulis_id`) REFERENCES `penulis` (`penulis_id`);

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `fk_transaksi_buku` FOREIGN KEY (`buku_id`) REFERENCES `buku` (`buku_id`),
  ADD CONSTRAINT `fk_transaksi_pelanggan` FOREIGN KEY (`pelanggan_id`) REFERENCES `pelanggan` (`pelanggan_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
