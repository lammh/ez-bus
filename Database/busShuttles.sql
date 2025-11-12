-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 12, 2025 at 12:04 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ezbus`
--

-- --------------------------------------------------------

--
-- Table structure for table `auth_settings`
--

CREATE TABLE `auth_settings` (
  `id` int(10) UNSIGNED NOT NULL,
  `secure_key` text DEFAULT NULL,
  `u1` text DEFAULT NULL,
  `u2` text DEFAULT NULL,
  `u3` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `auth_settings`
--

INSERT INTO `auth_settings` (`id`, `secure_key`, `u1`, `u2`, `u3`, `created_at`, `updated_at`) VALUES
(1, 'NO_LICENSE_NEEDED', 'DUMMY_U1', 'DUMMY_U2', 'DUMMY_U3', '2025-10-22 08:46:13', '2025-10-22 08:46:13');

-- --------------------------------------------------------

--
-- Table structure for table `bank_accounts`
--

CREATE TABLE `bank_accounts` (
  `id` int(10) UNSIGNED NOT NULL,
  `account_number` varchar(255) NOT NULL,
  `beneficiary_name` varchar(255) NOT NULL,
  `beneficiary_address` varchar(255) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `routing_number` varchar(255) DEFAULT NULL,
  `iban` varchar(255) DEFAULT NULL,
  `swift` varchar(255) DEFAULT NULL,
  `bic` varchar(255) DEFAULT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `buses`
--

CREATE TABLE `buses` (
  `id` int(10) UNSIGNED NOT NULL,
  `license` varchar(255) NOT NULL,
  `capacity` int(10) UNSIGNED NOT NULL,
  `driver_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `price_factor` double NOT NULL DEFAULT 1,
  `seat_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '{"rows":5,"columns":4,"seatGrid":[[true,true,true,true],[true,true,true,true],[true,true,true,true],[true,true,true,true],[true,true,true,true]]}' CHECK (json_valid(`seat_config`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `buses`
--

INSERT INTO `buses` (`id`, `license`, `capacity`, `driver_id`, `created_at`, `updated_at`, `price_factor`, `seat_config`) VALUES
(1, '002566', 20, 5, '2025-10-31 21:23:26', '2025-10-31 21:23:47', 1, '{\"totalRows\":5,\"totalColumns\":4,\"seatGrid\":[[true,true,true,true],[true,true,true,true],[true,true,true,true],[true,true,true,true],[true,true,true,true]]}'),
(2, '8765', 20, 7, '2025-11-01 09:49:06', '2025-11-01 09:49:57', 1, '{\"totalRows\":5,\"totalColumns\":4,\"seatGrid\":[[true,true,true,true],[true,true,true,true],[true,true,true,true],[true,true,true,true],[true,true,true,true]]}');

-- --------------------------------------------------------

--
-- Table structure for table `complaints`
--

CREATE TABLE `complaints` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `reservation_id` int(10) UNSIGNED NOT NULL,
  `complaint` text NOT NULL,
  `response` text DEFAULT NULL,
  `status` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `stop_id` int(10) UNSIGNED DEFAULT NULL,
  `stop_name` varchar(255) DEFAULT NULL,
  `stop_lat` double DEFAULT NULL,
  `stop_lng` double DEFAULT NULL,
  `customer_lat` double DEFAULT NULL,
  `customer_lng` double DEFAULT NULL,
  `bus_lat` double DEFAULT NULL,
  `bus_lng` double DEFAULT NULL,
  `planned_time` datetime DEFAULT NULL,
  `actual_time` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `coupons`
--

CREATE TABLE `coupons` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(255) NOT NULL,
  `discount` int(10) UNSIGNED NOT NULL,
  `limit` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `max_amount` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `status` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `expiration_date` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `coupon_customers`
--

CREATE TABLE `coupon_customers` (
  `id` int(10) UNSIGNED NOT NULL,
  `coupon_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `planned_trip_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `currencies`
--

CREATE TABLE `currencies` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `code` varchar(50) NOT NULL,
  `symbol` varchar(5) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `currencies`
--

INSERT INTO `currencies` (`id`, `name`, `code`, `symbol`, `created_at`, `updated_at`) VALUES
(1, 'Afghani', 'AFN', '؋', NULL, NULL),
(2, 'Lek', 'ALL', 'Lek', NULL, NULL),
(3, 'Netherlands Antillian Guilder', 'ANG', 'ƒ', NULL, NULL),
(4, 'Argentine Peso', 'ARS', '$', NULL, NULL),
(5, 'Australian Dollar', 'AUD', '$', NULL, NULL),
(6, 'Aruban Guilder', 'AWG', 'ƒ', NULL, NULL),
(7, 'Azerbaijanian Manat', 'AZN', 'ман', NULL, NULL),
(8, 'Convertible Marks', 'BAM', 'KM', NULL, NULL),
(9, 'Bangladeshi Taka', 'BDT', '৳', NULL, NULL),
(10, 'Barbados Dollar', 'BBD', '$', NULL, NULL),
(11, 'Bulgarian Lev', 'BGN', 'лв', NULL, NULL),
(12, 'Bermudian Dollar', 'BMD', '$', NULL, NULL),
(13, 'Brunei Dollar', 'BND', '$', NULL, NULL),
(14, 'BOV Boliviano Mvdol', 'BOB', '$b', NULL, NULL),
(15, 'Brazilian Real', 'BRL', 'R$', NULL, NULL),
(16, 'Bahamian Dollar', 'BSD', '$', NULL, NULL),
(17, 'Pula', 'BWP', 'P', NULL, NULL),
(18, 'Belarussian Ruble', 'BYR', '₽', NULL, NULL),
(19, 'Belize Dollar', 'BZD', 'BZ$', NULL, NULL),
(20, 'Canadian Dollar', 'CAD', '$', NULL, NULL),
(21, 'Swiss Franc', 'CHF', 'CHF', NULL, NULL),
(22, 'CLF Chilean Peso Unidades de fomento', 'CLP', '$', NULL, NULL),
(23, 'Yuan Renminbi', 'CNY', '¥', NULL, NULL),
(24, 'COU Colombian Peso Unidad de Valor Real', 'COP', '$', NULL, NULL),
(25, 'Costa Rican Colon', 'CRC', '₡', NULL, NULL),
(26, 'CUC Cuban Peso Peso Convertible', 'CUP', '₱', NULL, NULL),
(27, 'Czech Koruna', 'CZK', 'Kč', NULL, NULL),
(28, 'Danish Krone', 'DKK', 'kr', NULL, NULL),
(29, 'Dominican Peso', 'DOP', 'RD$', NULL, NULL),
(30, 'Egyptian Pound', 'EGP', '£', NULL, NULL),
(31, 'Euro', 'EUR', '€', NULL, NULL),
(32, 'Fiji Dollar', 'FJD', '$', NULL, NULL),
(33, 'Falkland Islands Pound', 'FKP', '£', NULL, NULL),
(34, 'Pound Sterling', 'GBP', '£', NULL, NULL),
(35, 'Gibraltar Pound', 'GIP', '£', NULL, NULL),
(36, 'Quetzal', 'GTQ', 'Q', NULL, NULL),
(37, 'Guyana Dollar', 'GYD', '$', NULL, NULL),
(38, 'Hong Kong Dollar', 'HKD', '$', NULL, NULL),
(39, 'Lempira', 'HNL', 'L', NULL, NULL),
(40, 'Croatian Kuna', 'HRK', 'kn', NULL, NULL),
(41, 'Forint', 'HUF', 'Ft', NULL, NULL),
(42, 'Rupiah', 'IDR', 'Rp', NULL, NULL),
(43, 'New Israeli Sheqel', 'ILS', '₪', NULL, NULL),
(44, 'Iranian Rial', 'IRR', '﷼', NULL, NULL),
(45, 'Iceland Krona', 'ISK', 'kr', NULL, NULL),
(46, 'Jamaican Dollar', 'JMD', 'J$', NULL, NULL),
(47, 'Yen', 'JPY', '¥', NULL, NULL),
(48, 'Som', 'KGS', 'лв', NULL, NULL),
(49, 'Riel', 'KHR', '៛', NULL, NULL),
(50, 'North Korean Won', 'KPW', '₩', NULL, NULL),
(51, 'Won', 'KRW', '₩', NULL, NULL),
(52, 'Cayman Islands Dollar', 'KYD', '$', NULL, NULL),
(53, 'Tenge', 'KZT', 'лв', NULL, NULL),
(54, 'Kip', 'LAK', '₭', NULL, NULL),
(55, 'Lebanese Pound', 'LBP', '£', NULL, NULL),
(56, 'Sri Lanka Rupee', 'LKR', '₨', NULL, NULL),
(57, 'Liberian Dollar', 'LRD', '$', NULL, NULL),
(58, 'Lithuanian Litas', 'LTL', 'Lt', NULL, NULL),
(59, 'Latvian Lats', 'LVL', 'Ls', NULL, NULL),
(60, 'Denar', 'MKD', 'ден', NULL, NULL),
(61, 'Tugrik', 'MNT', '₮', NULL, NULL),
(62, 'Mauritius Rupee', 'MUR', '₨', NULL, NULL),
(63, 'MXV Mexican Peso Mexican Unidad de Inversion (UDI]', 'MXN', '$', NULL, NULL),
(64, 'Malaysian Ringgit', 'MYR', 'RM', NULL, NULL),
(65, 'Metical', 'MZN', 'MT', NULL, NULL),
(66, 'Naira', 'NGN', '₦', NULL, NULL),
(67, 'Cordoba Oro', 'NIO', 'C$', NULL, NULL),
(68, 'Norwegian Krone', 'NOK', 'kr', NULL, NULL),
(69, 'Nepalese Rupee', 'NPR', '₨', NULL, NULL),
(70, 'New Zealand Dollar', 'NZD', '$', NULL, NULL),
(71, 'Rial Omani', 'OMR', '﷼', NULL, NULL),
(72, 'USD Balboa US Dollar', 'PAB', 'B/.', NULL, NULL),
(73, 'Nuevo Sol', 'PEN', 'S/.', NULL, NULL),
(74, 'Philippine Peso', 'PHP', 'Php', NULL, NULL),
(75, 'Pakistan Rupee', 'PKR', '₨', NULL, NULL),
(76, 'Zloty', 'PLN', 'zł', NULL, NULL),
(77, 'Guarani', 'PYG', 'Gs', NULL, NULL),
(78, 'Qatari Rial', 'QAR', '﷼', NULL, NULL),
(79, 'New Leu', 'RON', 'lei', NULL, NULL),
(80, 'Serbian Dinar', 'RSD', 'Дин.', NULL, NULL),
(81, 'Russian Ruble', 'RUB', 'руб', NULL, NULL),
(82, 'Saudi Riyal', 'SAR', '﷼', NULL, NULL),
(83, 'Solomon Islands Dollar', 'SBD', '$', NULL, NULL),
(84, 'Seychelles Rupee', 'SCR', '₨', NULL, NULL),
(85, 'Swedish Krona', 'SEK', 'kr', NULL, NULL),
(86, 'Singapore Dollar', 'SGD', '$', NULL, NULL),
(87, 'Saint Helena Pound', 'SHP', '£', NULL, NULL),
(88, 'Somali Shilling', 'SOS', 'S', NULL, NULL),
(89, 'Surinam Dollar', 'SRD', '$', NULL, NULL),
(90, 'USD El Salvador Colon US Dollar', 'SVC', '$', NULL, NULL),
(91, 'Syrian Pound', 'SYP', '£', NULL, NULL),
(92, 'Baht', 'THB', '฿', NULL, NULL),
(93, 'Turkish Lira', 'TRY', 'TL', NULL, NULL),
(94, 'Trinidad and Tobago Dollar', 'TTD', 'TT$', NULL, NULL),
(95, 'New Taiwan Dollar', 'TWD', 'NT$', NULL, NULL),
(96, 'Hryvnia', 'UAH', '₴', NULL, NULL),
(97, 'US Dollar', 'USD', '$', NULL, NULL),
(98, 'UYI Uruguay Peso en Unidades Indexadas', 'UYU', '$U', NULL, NULL),
(99, 'Uzbekistan Sum', 'UZS', 'лв', NULL, NULL),
(100, 'Bolivar Fuerte', 'VEF', 'Bs', NULL, NULL),
(101, 'Dong', 'VND', '₫', NULL, NULL),
(102, 'East Caribbean Dollar', 'XCD', '$', NULL, NULL),
(103, 'Yemeni Rial', 'YER', '﷼', NULL, NULL),
(104, 'Rand', 'ZAR', 'R', NULL, NULL),
(105, 'Zambian Kwacha', 'ZMW', 'ZK', NULL, NULL),
(106, 'Francs CFA', 'XAF', 'FCFA', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `customer_reserved_trips`
--

CREATE TABLE `customer_reserved_trips` (
  `id` int(10) UNSIGNED NOT NULL,
  `ticket_number` varchar(255) NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `planned_trip_id` int(10) UNSIGNED NOT NULL,
  `reservation_date` date NOT NULL,
  `start_stop_id` int(10) UNSIGNED NOT NULL,
  `end_stop_id` int(10) UNSIGNED NOT NULL,
  `end_point_lat` double NOT NULL,
  `end_point_lng` double NOT NULL,
  `start_address` text NOT NULL,
  `destination_address` text NOT NULL,
  `planned_start_time` time NOT NULL,
  `trip_price` double NOT NULL,
  `paid_price` double NOT NULL DEFAULT 0,
  `driver_share` double NOT NULL DEFAULT 0,
  `admin_share` double NOT NULL DEFAULT 0,
  `ride_status` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `payment_method` int(11) NOT NULL DEFAULT 0,
  `seat_number` int(11) DEFAULT NULL,
  `row` int(11) DEFAULT NULL,
  `column` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `driver_documents`
--

CREATE TABLE `driver_documents` (
  `id` int(10) UNSIGNED NOT NULL,
  `driver_information_id` int(10) UNSIGNED NOT NULL,
  `document_name` varchar(255) NOT NULL,
  `document_number` varchar(255) NOT NULL,
  `expiry_date` date NOT NULL,
  `local_file_path` text NOT NULL,
  `remote_file_path` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `driver_documents`
--

INSERT INTO `driver_documents` (`id`, `driver_information_id`, `document_name`, `document_number`, `expiry_date`, `local_file_path`, `remote_file_path`, `created_at`, `updated_at`) VALUES
(1, 1, 'ID', '09641761', '2031-10-31', '/storage/emulated/0/Android/data/com.creativeapps.ezbusdriver/files/driver_documents/scaled_1000008595.jpg', '/storage/images/11/driver_documents/1761951282.ID.jpg', '2025-10-31 21:54:42', '2025-10-31 21:54:42');

-- --------------------------------------------------------

--
-- Table structure for table `driver_information`
--

CREATE TABLE `driver_information` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `phone_number` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `license_number` varchar(255) NOT NULL,
  `response` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `driver_information`
--

INSERT INTO `driver_information` (`id`, `user_id`, `first_name`, `last_name`, `phone_number`, `address`, `email`, `license_number`, `response`, `created_at`, `updated_at`) VALUES
(1, 11, 'Hatem', 'Boukhrouf', '52662088', 'Cité Hidhab, Fouchana', 'driver12@gmail.com', '09641741', 'Approved', '2025-10-31 21:54:42', '2025-11-01 09:48:35');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fav_trips`
--

CREATE TABLE `fav_trips` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `trip_id` int(10) UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `flutterwave_transactions`
--

CREATE TABLE `flutterwave_transactions` (
  `id` int(10) UNSIGNED NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `body` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2019_08_19_000000_create_failed_jobs_table', 1),
(2, '2019_10_11_000000_create_currencies_table', 1),
(3, '2019_10_12_000000_create_statuses_table', 1),
(4, '2019_10_12_000001_create_users_table', 1),
(5, '2019_10_12_000002_create_user_statuses_table', 1),
(6, '2019_10_12_000003_create_bank_accounts_table', 1),
(7, '2019_10_12_000003_create_buses_table', 1),
(8, '2019_10_12_000003_create_mobile_money_accounts_table', 1),
(9, '2019_10_12_000003_create_paypal_accounts_table', 1),
(10, '2019_10_12_000003_create_stops_table', 1),
(11, '2019_10_12_000004_create_routes_table', 1),
(12, '2019_10_12_000005_create_redemption_types_table', 1),
(13, '2019_10_12_000005_create_route_stops_table', 1),
(14, '2019_10_12_000006_create_redemptions_table', 1),
(15, '2019_10_12_000006_create_route_stop_directions_table', 1),
(16, '2019_10_12_000007_create_trips_table', 1),
(17, '2019_10_12_000008_create_trip_details_table', 1),
(18, '2019_10_12_000009_create_planned_trips_table', 1),
(19, '2019_10_12_000010_create_settings_table', 1),
(20, '2019_10_12_000011_create_fav_trips_table', 1),
(21, '2019_10_12_000011_create_suspended_trips_table', 1),
(22, '2019_10_12_000012_create_customer_reserved_trips_table', 1),
(23, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(24, '2020_10_12_100000_create_password_resets_table', 1),
(25, '2020_10_12_200000_add_two_factor_columns_to_users_table', 1),
(26, '2021_01_22_220306_create_messages_table', 1),
(27, '2021_08_01_000026_create_places_table', 1),
(28, '2021_08_01_000030_create_trip_search_results_table', 1),
(29, '2021_08_01_000031_create_user_payments_table', 1),
(30, '2021_08_01_000032_create_user_refunds_table', 1),
(31, '2021_08_01_000033_create_planned_trip_details_table', 1),
(32, '2021_08_01_000034_create_user_charges_table', 1),
(33, '2021_08_01_000035_create_driver_information_table', 1),
(34, '2021_08_01_000036_create_driver_documents_table', 1),
(35, '2021_08_01_000037_create_complaints_table', 1),
(36, '2021_08_01_000037_create_notifications_table', 1),
(37, '2021_08_01_000038_create_auth_settings_table', 1),
(38, '2021_08_01_000040_create_flutterwave_transactions_table', 1),
(39, '2021_08_01_000040_create_paytabs_transactions_table', 1),
(40, '2021_08_01_000041_add_request_delete_to_users_table', 1),
(41, '2021_08_01_000042_create_coupons_table', 1),
(42, '2021_08_01_000043_create_coupon_customers_table', 1),
(43, '2021_08_01_000044_add_payment_method_to_customer_reserved_trips_table', 1),
(44, '2021_08_01_000045_add_price_factor_to_buses_table', 1),
(45, '2021_08_01_000046_add_seat_config_to_buses_table', 1),
(46, '2021_08_01_000047_add_seat_selection_to_settings_table', 1),
(47, '2021_08_01_000048_add_seat_number_to_customer_reserved_trips_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `mobile_money_accounts`
--

CREATE TABLE `mobile_money_accounts` (
  `id` int(10) UNSIGNED NOT NULL,
  `phone_number` varchar(255) NOT NULL,
  `network` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `seen` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `paypal_accounts`
--

CREATE TABLE `paypal_accounts` (
  `id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `paytabs_transactions`
--

CREATE TABLE `paytabs_transactions` (
  `id` int(10) UNSIGNED NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `expires_at`, `last_used_at`, `created_at`, `updated_at`) VALUES
(3, 'App\\Models\\User', 5, 'TestDevice', '4962809b4fe59b778ebcfa98efaa61cb7a6cbcfa85fd04d345cc4445d0eb8892', '[\"admin\"]', NULL, NULL, '2025-10-17 13:17:27', '2025-10-17 13:17:27'),
(6, 'App\\Models\\User', 6, '2201117TG', 'ba8d1b1e5ac390f7fd064b3e5189eb8a78105473b02fa2fd1ea0e61acf1da14d', '[\"driver\"]', NULL, NULL, '2025-10-17 15:19:50', '2025-10-17 15:19:50'),
(7, 'App\\Models\\User', 7, '2201117TG', '8fcaab01396b710d1a5a5bebb932d6b46cff2727425781569d8314918e1e0bc7', '[\"driver\"]', NULL, NULL, '2025-10-17 15:22:51', '2025-10-17 15:22:51'),
(8, 'App\\Models\\User', 5, '2201117TG', '5eb92dd32e366a889ec0af4ae265d3114a0c82ca4458468983468474c9249f9e', '[\"driver\"]', NULL, NULL, '2025-10-17 15:28:54', '2025-10-17 15:28:54'),
(9, 'App\\Models\\User', 9, '2201117TG', 'a148955d8fffca4113dd0137e43833176248a8b864cc66436739298385719743', '[\"driver\"]', NULL, NULL, '2025-10-31 13:38:09', '2025-10-31 13:38:09'),
(12, 'App\\Models\\User', 10, '2201117TG', 'faaaf631b37f428bf6d2f24885d2d64944662a7ad7031b42b919ac41fd68893d', '[\"driver\"]', NULL, '2025-10-31 13:45:16', '2025-10-31 13:45:14', '2025-10-31 13:45:16'),
(13, 'App\\Models\\User', 1, 'Chrome- v141', 'f34eada329784c10bab25671297074aa44461acb9bbdace9b31c9e2aae09e816', '[\"admin\"]', NULL, '2025-11-01 13:01:43', '2025-10-31 21:22:29', '2025-11-01 13:01:43'),
(16, 'App\\Models\\User', 11, '2201117TG', '1cd42aa614705a89205bd73a0fb286abc57ab3dadba60a626f20925c8dc30e68', '[\"driver\"]', NULL, '2025-11-01 14:52:12', '2025-11-01 13:43:23', '2025-11-01 14:52:12');

-- --------------------------------------------------------

--
-- Table structure for table `places`
--

CREATE TABLE `places` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `type` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `favorite` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `planned_trips`
--

CREATE TABLE `planned_trips` (
  `id` int(10) UNSIGNED NOT NULL,
  `channel` varchar(255) NOT NULL,
  `trip_id` int(10) UNSIGNED NOT NULL,
  `route_id` int(10) UNSIGNED NOT NULL,
  `planned_date` date NOT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `ended_at` timestamp NULL DEFAULT NULL,
  `last_position_lat` double DEFAULT NULL,
  `last_position_lng` double DEFAULT NULL,
  `driver_id` int(10) UNSIGNED DEFAULT NULL,
  `bus_id` int(10) UNSIGNED DEFAULT NULL,
  `reserved_seats` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `planned_trip_details`
--

CREATE TABLE `planned_trip_details` (
  `id` int(10) UNSIGNED NOT NULL,
  `stop_id` int(10) UNSIGNED NOT NULL,
  `planned_trip_id` int(10) UNSIGNED NOT NULL,
  `planned_timestamp` time NOT NULL,
  `actual_timestamp` time DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `redemptions`
--

CREATE TABLE `redemptions` (
  `id` int(10) UNSIGNED NOT NULL,
  `redemption_amount` double NOT NULL,
  `redemption_type_id` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `user_id` int(10) UNSIGNED NOT NULL,
  `bank_account_id` int(10) UNSIGNED DEFAULT NULL,
  `paypal_account_id` int(10) UNSIGNED DEFAULT NULL,
  `mobile_money_account_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `redemption_types`
--

CREATE TABLE `redemption_types` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `redemption_types`
--

INSERT INTO `redemption_types` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'Cash', '2025-10-16 09:50:28', '2025-10-16 09:50:28'),
(2, 'Bank transfer', '2025-10-16 09:50:28', '2025-10-16 09:50:28'),
(3, 'Paypal', '2025-10-16 09:50:28', '2025-10-16 09:50:28'),
(4, 'Mobile money', '2025-10-16 09:50:28', '2025-10-16 09:50:28');

-- --------------------------------------------------------

--
-- Table structure for table `routes`
--

CREATE TABLE `routes` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `route_stops`
--

CREATE TABLE `route_stops` (
  `id` int(10) UNSIGNED NOT NULL,
  `stop_id` int(10) UNSIGNED NOT NULL,
  `route_id` int(10) UNSIGNED NOT NULL,
  `order` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `route_stop_directions`
--

CREATE TABLE `route_stop_directions` (
  `id` int(10) UNSIGNED NOT NULL,
  `route_stop_id` int(10) UNSIGNED NOT NULL,
  `index` int(10) UNSIGNED NOT NULL,
  `summary` varchar(255) NOT NULL,
  `overview_path` text NOT NULL,
  `current` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(10) UNSIGNED NOT NULL,
  `rate_per_km` double NOT NULL DEFAULT 10,
  `commission` double NOT NULL DEFAULT 10,
  `publish_trips_future_days` int(11) NOT NULL DEFAULT 3,
  `max_distance_to_stop` double NOT NULL DEFAULT 10,
  `distance_to_stop_to_mark_arrived` double NOT NULL DEFAULT 100,
  `currency_id` int(10) UNSIGNED NOT NULL,
  `allow_ads_in_driver_app` tinyint(1) NOT NULL DEFAULT 0,
  `allow_ads_in_customer_app` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `allow_seat_selection` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `rate_per_km`, `commission`, `publish_trips_future_days`, `max_distance_to_stop`, `distance_to_stop_to_mark_arrived`, `currency_id`, `allow_ads_in_driver_app`, `allow_ads_in_customer_app`, `created_at`, `updated_at`, `allow_seat_selection`) VALUES
(1, 10, 10, 3, 10, 100, 97, 0, 0, '2025-10-16 09:50:28', '2025-10-16 09:50:28', 1);

-- --------------------------------------------------------

--
-- Table structure for table `statuses`
--

CREATE TABLE `statuses` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `statuses`
--

INSERT INTO `statuses` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'active', '2025-10-16 09:50:28', '2025-10-16 09:50:28'),
(2, 'pending', '2025-10-16 09:50:28', '2025-10-16 09:50:28'),
(3, 'suspended', '2025-10-16 09:50:28', '2025-10-16 09:50:28'),
(4, 'under_review', '2025-10-16 09:50:28', '2025-10-16 09:50:28'),
(5, 'active', '2025-10-22 08:29:10', '2025-10-22 08:29:10'),
(6, 'pending', '2025-10-22 08:29:10', '2025-10-22 08:29:10'),
(7, 'suspended', '2025-10-22 08:29:10', '2025-10-22 08:29:10'),
(8, 'under_review', '2025-10-22 08:29:10', '2025-10-22 08:29:10');

-- --------------------------------------------------------

--
-- Table structure for table `stops`
--

CREATE TABLE `stops` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `place_id` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `lat` varchar(255) NOT NULL,
  `lng` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stops`
--

INSERT INTO `stops` (`id`, `name`, `place_id`, `address`, `lat`, `lng`, `created_at`, `updated_at`) VALUES
(1, 'NGI', 'ChIJgSIbR881_RIRq-10DHgkrVQ', '26 Rue de l\'Usine, Tunis 2035, Tunisia', '36.8549252', '10.2067501', '2025-11-01 09:53:10', '2025-11-01 09:53:10'),
(2, 'Home', 'ChIJs675oLIw_RIRqwnbCX0OXcg', 'Fouchana, Tunisia', '36.6959499', '10.1647233', '2025-11-01 09:54:14', '2025-11-01 09:54:14');

-- --------------------------------------------------------

--
-- Table structure for table `suspended_trips`
--

CREATE TABLE `suspended_trips` (
  `id` int(10) UNSIGNED NOT NULL,
  `trip_id` int(10) UNSIGNED NOT NULL,
  `repetition_period` int(10) UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trips`
--

CREATE TABLE `trips` (
  `id` int(10) UNSIGNED NOT NULL,
  `channel` varchar(255) NOT NULL,
  `route_id` int(10) UNSIGNED NOT NULL,
  `effective_date` date NOT NULL,
  `repetition_period` int(10) UNSIGNED NOT NULL,
  `stop_to_stop_avg_time` int(10) UNSIGNED NOT NULL,
  `first_stop_time` time NOT NULL,
  `last_stop_time` time DEFAULT NULL,
  `status_id` int(10) UNSIGNED NOT NULL,
  `driver_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trip_details`
--

CREATE TABLE `trip_details` (
  `id` int(10) UNSIGNED NOT NULL,
  `stop_id` int(10) UNSIGNED NOT NULL,
  `trip_id` int(10) UNSIGNED NOT NULL,
  `planned_timestamp` time NOT NULL,
  `actual_timestamp` time DEFAULT NULL,
  `inter_time` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `trip_search_results`
--

CREATE TABLE `trip_search_results` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `route_id` int(10) UNSIGNED NOT NULL,
  `planned_trip_id` int(10) UNSIGNED NOT NULL,
  `start_stop_id` int(10) UNSIGNED NOT NULL,
  `end_stop_id` int(10) UNSIGNED NOT NULL,
  `end_point_lat` double NOT NULL,
  `end_point_lng` double NOT NULL,
  `distance_to_start_stop` double NOT NULL,
  `distance_to_end_stop` double NOT NULL,
  `distance_to_end_point` double NOT NULL,
  `price` double NOT NULL,
  `distance` double NOT NULL,
  `start_address` text NOT NULL,
  `destination_address` text NOT NULL,
  `planned_start_date` date NOT NULL,
  `planned_start_time` time NOT NULL,
  `path` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `two_factor_secret` text DEFAULT NULL,
  `two_factor_recovery_codes` text DEFAULT NULL,
  `uid` varchar(255) NOT NULL,
  `fcm_token` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) NOT NULL DEFAULT 'avatar.png',
  `tel_number` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `license_url` varchar(255) DEFAULT NULL,
  `wallet` double NOT NULL DEFAULT 0,
  `status_id` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `role` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `redemption_preference` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `request_delete_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `two_factor_secret`, `two_factor_recovery_codes`, `uid`, `fcm_token`, `avatar`, `tel_number`, `address`, `license_url`, `wallet`, `status_id`, `role`, `redemption_preference`, `remember_token`, `created_at`, `updated_at`, `request_delete_at`) VALUES
(1, 'SuperAdmin', 'admin@busshuttles.com', NULL, '$2y$10$dqcEoMpVz/X4ev8joFLuHOooBS8QfgMWOzMI9KO0gm3N2pbDQdaoe', NULL, NULL, 'ONa9pdXZdQZ0RnIZHPLNSTGIRam1', NULL, '/storage/avatars/1/avatar.png', NULL, NULL, NULL, 0, 1, 0, 1, NULL, '2025-10-16 09:50:28', '2025-10-16 09:50:28', NULL),
(3, 'Test User', 'testuser1@example.com', NULL, NULL, NULL, NULL, 'LjujQBHBYBOMTIUVnCzkoUKKlog1', NULL, 'avatar.png', NULL, NULL, NULL, 0, 2, 1, 1, NULL, '2025-10-17 10:22:57', '2025-10-17 10:22:57', NULL),
(5, 'Test User', 'testuser2@example.com', NULL, 'UkVEQUNURUQ=', NULL, NULL, 'D0noedFOaqbTQwP6JJkh9uE0adz2', 'fnAiO38wTrOtT0XJbI-HZm:APA91bF7794NKCgsUyBgFG7jETABdcOVRiHdUfkhH5PpohbuK-5-XCCbBCRok85TonOHTxkdYoyZMzJSOCNiY7sAbrNACM7mLiAO-1XlFj_2NBY3Dvb3kCY', '/storage/avatars/5/avatar.png', NULL, NULL, NULL, 0, 1, 2, 1, NULL, '2025-10-17 13:17:26', '2025-10-17 15:19:23', NULL),
(6, 'DriverTest', 'creativedonkey1607@gmail.com', NULL, 'UkVEQUNURUQ=', NULL, NULL, 'KdQpRpdU5YSwlyBI4V010YNdHkU2', 'fnAiO38wTrOtT0XJbI-HZm:APA91bF7794NKCgsUyBgFG7jETABdcOVRiHdUfkhH5PpohbuK-5-XCCbBCRok85TonOHTxkdYoyZMzJSOCNiY7sAbrNACM7mLiAO-1XlFj_2NBY3Dvb3kCY', '/storage/avatars/6/avatar.png', NULL, NULL, NULL, 0, 2, 2, 1, NULL, '2025-10-17 15:16:39', '2025-10-17 15:16:40', NULL),
(7, 'driver9', 'kpoper2566@gmail.com', NULL, 'UkVEQUNURUQ=', NULL, NULL, 'pWNhGWLiAGenG4PcLBZXFEt7nsu1', 'fnAiO38wTrOtT0XJbI-HZm:APA91bF7794NKCgsUyBgFG7jETABdcOVRiHdUfkhH5PpohbuK-5-XCCbBCRok85TonOHTxkdYoyZMzJSOCNiY7sAbrNACM7mLiAO-1XlFj_2NBY3Dvb3kCY', '/storage/avatars/7/avatar.png', NULL, NULL, NULL, 0, 2, 2, 1, NULL, '2025-10-17 15:22:51', '2025-10-17 15:22:51', NULL),
(9, 'driver10', 'driver10@gmail.com', NULL, 'UkVEQUNURUQ=', NULL, NULL, 'ZRCZUdsHymT7Xf0ITk1sb1ykyNR2', 'fnAiO38wTrOtT0XJbI-HZm:APA91bF7794NKCgsUyBgFG7jETABdcOVRiHdUfkhH5PpohbuK-5-XCCbBCRok85TonOHTxkdYoyZMzJSOCNiY7sAbrNACM7mLiAO-1XlFj_2NBY3Dvb3kCY', '/storage/avatars/9/avatar.png', NULL, NULL, NULL, 0, 2, 2, 1, NULL, '2025-10-31 13:38:06', '2025-10-31 13:38:09', NULL),
(10, 'driver11', 'driver11@gmail.com', NULL, 'UkVEQUNURUQ=', NULL, NULL, '7RUbtWdoBzct2RnfQCaxcYje2rS2', 'fnAiO38wTrOtT0XJbI-HZm:APA91bF7794NKCgsUyBgFG7jETABdcOVRiHdUfkhH5PpohbuK-5-XCCbBCRok85TonOHTxkdYoyZMzJSOCNiY7sAbrNACM7mLiAO-1XlFj_2NBY3Dvb3kCY', '/storage/avatars/10/avatar.png', NULL, NULL, NULL, 0, 2, 2, 1, NULL, '2025-10-31 13:43:20', '2025-10-31 13:43:20', NULL),
(11, 'driver12', 'driver12@gmail.com', NULL, 'UkVEQUNURUQ=', NULL, NULL, 'OecBGyfkWpREVTNZWyvHgbOBWpg2', 'fnAiO38wTrOtT0XJbI-HZm:APA91bF7794NKCgsUyBgFG7jETABdcOVRiHdUfkhH5PpohbuK-5-XCCbBCRok85TonOHTxkdYoyZMzJSOCNiY7sAbrNACM7mLiAO-1XlFj_2NBY3Dvb3kCY', '/storage/avatars/11/1762010997.png', NULL, NULL, NULL, 0, 1, 2, 1, NULL, '2025-10-31 21:51:49', '2025-11-01 14:29:57', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_charges`
--

CREATE TABLE `user_charges` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `amount` double NOT NULL,
  `payment_date` date NOT NULL,
  `payment_method` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_payments`
--

CREATE TABLE `user_payments` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `amount` double NOT NULL,
  `payment_date` date NOT NULL,
  `reservation_id` int(10) UNSIGNED NOT NULL,
  `redeemed` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_refunds`
--

CREATE TABLE `user_refunds` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `amount` double NOT NULL,
  `refund_date` date NOT NULL,
  `reason` text DEFAULT NULL,
  `reservation_id` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_statuses`
--

CREATE TABLE `user_statuses` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `status_id` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `auth_settings`
--
ALTER TABLE `auth_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bank_accounts_user_id_foreign` (`user_id`);

--
-- Indexes for table `buses`
--
ALTER TABLE `buses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `buses_driver_id_foreign` (`driver_id`);

--
-- Indexes for table `complaints`
--
ALTER TABLE `complaints`
  ADD PRIMARY KEY (`id`),
  ADD KEY `complaints_user_id_foreign` (`user_id`),
  ADD KEY `complaints_reservation_id_foreign` (`reservation_id`),
  ADD KEY `complaints_stop_id_foreign` (`stop_id`);

--
-- Indexes for table `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `coupons_code_unique` (`code`);

--
-- Indexes for table `coupon_customers`
--
ALTER TABLE `coupon_customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `coupon_customers_coupon_id_user_id_planned_trip_id_unique` (`coupon_id`,`user_id`,`planned_trip_id`),
  ADD KEY `coupon_customers_user_id_foreign` (`user_id`),
  ADD KEY `coupon_customers_planned_trip_id_foreign` (`planned_trip_id`);

--
-- Indexes for table `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `currencies_name_unique` (`name`),
  ADD UNIQUE KEY `currencies_code_unique` (`code`);

--
-- Indexes for table `customer_reserved_trips`
--
ALTER TABLE `customer_reserved_trips`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_seat_number_per_trip` (`planned_trip_id`,`seat_number`),
  ADD KEY `customer_reserved_trips_user_id_foreign` (`user_id`),
  ADD KEY `customer_reserved_trips_start_stop_id_foreign` (`start_stop_id`),
  ADD KEY `customer_reserved_trips_end_stop_id_foreign` (`end_stop_id`);

--
-- Indexes for table `driver_documents`
--
ALTER TABLE `driver_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `driver_documents_driver_information_id_foreign` (`driver_information_id`);

--
-- Indexes for table `driver_information`
--
ALTER TABLE `driver_information`
  ADD PRIMARY KEY (`id`),
  ADD KEY `driver_information_user_id_foreign` (`user_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `fav_trips`
--
ALTER TABLE `fav_trips`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fav_trips_user_id_foreign` (`user_id`),
  ADD KEY `fav_trips_trip_id_foreign` (`trip_id`);

--
-- Indexes for table `flutterwave_transactions`
--
ALTER TABLE `flutterwave_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mobile_money_accounts`
--
ALTER TABLE `mobile_money_accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `mobile_money_accounts_user_id_foreign` (`user_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_user_id_foreign` (`user_id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`);

--
-- Indexes for table `paypal_accounts`
--
ALTER TABLE `paypal_accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `paypal_accounts_user_id_foreign` (`user_id`);

--
-- Indexes for table `paytabs_transactions`
--
ALTER TABLE `paytabs_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `places`
--
ALTER TABLE `places`
  ADD PRIMARY KEY (`id`),
  ADD KEY `places_user_id_foreign` (`user_id`);

--
-- Indexes for table `planned_trips`
--
ALTER TABLE `planned_trips`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `planned_trips_trip_id_planned_date_unique` (`trip_id`,`planned_date`),
  ADD KEY `planned_trips_route_id_foreign` (`route_id`),
  ADD KEY `planned_trips_driver_id_foreign` (`driver_id`),
  ADD KEY `planned_trips_bus_id_foreign` (`bus_id`);

--
-- Indexes for table `planned_trip_details`
--
ALTER TABLE `planned_trip_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `planned_trip_details_stop_id_foreign` (`stop_id`),
  ADD KEY `planned_trip_details_planned_trip_id_foreign` (`planned_trip_id`);

--
-- Indexes for table `redemptions`
--
ALTER TABLE `redemptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `redemptions_redemption_type_id_foreign` (`redemption_type_id`),
  ADD KEY `redemptions_user_id_foreign` (`user_id`),
  ADD KEY `redemptions_bank_account_id_foreign` (`bank_account_id`),
  ADD KEY `redemptions_paypal_account_id_foreign` (`paypal_account_id`),
  ADD KEY `redemptions_mobile_money_account_id_foreign` (`mobile_money_account_id`);

--
-- Indexes for table `redemption_types`
--
ALTER TABLE `redemption_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `routes`
--
ALTER TABLE `routes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `route_stops`
--
ALTER TABLE `route_stops`
  ADD PRIMARY KEY (`id`),
  ADD KEY `route_stops_stop_id_foreign` (`stop_id`),
  ADD KEY `route_stops_route_id_foreign` (`route_id`);

--
-- Indexes for table `route_stop_directions`
--
ALTER TABLE `route_stop_directions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `route_stop_directions_route_stop_id_foreign` (`route_stop_id`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `settings_currency_id_foreign` (`currency_id`);

--
-- Indexes for table `statuses`
--
ALTER TABLE `statuses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stops`
--
ALTER TABLE `stops`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `suspended_trips`
--
ALTER TABLE `suspended_trips`
  ADD PRIMARY KEY (`id`),
  ADD KEY `suspended_trips_trip_id_foreign` (`trip_id`);

--
-- Indexes for table `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`id`),
  ADD KEY `trips_route_id_foreign` (`route_id`),
  ADD KEY `trips_status_id_foreign` (`status_id`),
  ADD KEY `trips_driver_id_foreign` (`driver_id`);

--
-- Indexes for table `trip_details`
--
ALTER TABLE `trip_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `trip_details_stop_id_foreign` (`stop_id`),
  ADD KEY `trip_details_trip_id_foreign` (`trip_id`);

--
-- Indexes for table `trip_search_results`
--
ALTER TABLE `trip_search_results`
  ADD PRIMARY KEY (`id`),
  ADD KEY `trip_search_results_user_id_foreign` (`user_id`),
  ADD KEY `trip_search_results_route_id_foreign` (`route_id`),
  ADD KEY `trip_search_results_planned_trip_id_foreign` (`planned_trip_id`),
  ADD KEY `trip_search_results_start_stop_id_foreign` (`start_stop_id`),
  ADD KEY `trip_search_results_end_stop_id_foreign` (`end_stop_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_status_id_foreign` (`status_id`);

--
-- Indexes for table `user_charges`
--
ALTER TABLE `user_charges`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_charges_user_id_foreign` (`user_id`);

--
-- Indexes for table `user_payments`
--
ALTER TABLE `user_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_payments_user_id_foreign` (`user_id`),
  ADD KEY `user_payments_reservation_id_foreign` (`reservation_id`);

--
-- Indexes for table `user_refunds`
--
ALTER TABLE `user_refunds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_refunds_user_id_foreign` (`user_id`),
  ADD KEY `user_refunds_reservation_id_foreign` (`reservation_id`);

--
-- Indexes for table `user_statuses`
--
ALTER TABLE `user_statuses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_statuses_user_id_foreign` (`user_id`),
  ADD KEY `user_statuses_status_id_foreign` (`status_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `auth_settings`
--
ALTER TABLE `auth_settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `buses`
--
ALTER TABLE `buses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `complaints`
--
ALTER TABLE `complaints`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `coupons`
--
ALTER TABLE `coupons`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `coupon_customers`
--
ALTER TABLE `coupon_customers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `currencies`
--
ALTER TABLE `currencies`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT for table `customer_reserved_trips`
--
ALTER TABLE `customer_reserved_trips`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `driver_documents`
--
ALTER TABLE `driver_documents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `driver_information`
--
ALTER TABLE `driver_information`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fav_trips`
--
ALTER TABLE `fav_trips`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `flutterwave_transactions`
--
ALTER TABLE `flutterwave_transactions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `mobile_money_accounts`
--
ALTER TABLE `mobile_money_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `paypal_accounts`
--
ALTER TABLE `paypal_accounts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `paytabs_transactions`
--
ALTER TABLE `paytabs_transactions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `places`
--
ALTER TABLE `places`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `planned_trips`
--
ALTER TABLE `planned_trips`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `planned_trip_details`
--
ALTER TABLE `planned_trip_details`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `redemptions`
--
ALTER TABLE `redemptions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `redemption_types`
--
ALTER TABLE `redemption_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `routes`
--
ALTER TABLE `routes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `route_stops`
--
ALTER TABLE `route_stops`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `route_stop_directions`
--
ALTER TABLE `route_stop_directions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `statuses`
--
ALTER TABLE `statuses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `stops`
--
ALTER TABLE `stops`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `suspended_trips`
--
ALTER TABLE `suspended_trips`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trips`
--
ALTER TABLE `trips`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trip_details`
--
ALTER TABLE `trip_details`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `trip_search_results`
--
ALTER TABLE `trip_search_results`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `user_charges`
--
ALTER TABLE `user_charges`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_payments`
--
ALTER TABLE `user_payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_refunds`
--
ALTER TABLE `user_refunds`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_statuses`
--
ALTER TABLE `user_statuses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD CONSTRAINT `bank_accounts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `buses`
--
ALTER TABLE `buses`
  ADD CONSTRAINT `buses_driver_id_foreign` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `complaints`
--
ALTER TABLE `complaints`
  ADD CONSTRAINT `complaints_reservation_id_foreign` FOREIGN KEY (`reservation_id`) REFERENCES `customer_reserved_trips` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `complaints_stop_id_foreign` FOREIGN KEY (`stop_id`) REFERENCES `stops` (`id`),
  ADD CONSTRAINT `complaints_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `coupon_customers`
--
ALTER TABLE `coupon_customers`
  ADD CONSTRAINT `coupon_customers_coupon_id_foreign` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `coupon_customers_planned_trip_id_foreign` FOREIGN KEY (`planned_trip_id`) REFERENCES `planned_trips` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `coupon_customers_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `customer_reserved_trips`
--
ALTER TABLE `customer_reserved_trips`
  ADD CONSTRAINT `customer_reserved_trips_end_stop_id_foreign` FOREIGN KEY (`end_stop_id`) REFERENCES `stops` (`id`),
  ADD CONSTRAINT `customer_reserved_trips_planned_trip_id_foreign` FOREIGN KEY (`planned_trip_id`) REFERENCES `planned_trips` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `customer_reserved_trips_start_stop_id_foreign` FOREIGN KEY (`start_stop_id`) REFERENCES `stops` (`id`),
  ADD CONSTRAINT `customer_reserved_trips_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `driver_documents`
--
ALTER TABLE `driver_documents`
  ADD CONSTRAINT `driver_documents_driver_information_id_foreign` FOREIGN KEY (`driver_information_id`) REFERENCES `driver_information` (`id`);

--
-- Constraints for table `driver_information`
--
ALTER TABLE `driver_information`
  ADD CONSTRAINT `driver_information_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `fav_trips`
--
ALTER TABLE `fav_trips`
  ADD CONSTRAINT `fav_trips_trip_id_foreign` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`),
  ADD CONSTRAINT `fav_trips_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `mobile_money_accounts`
--
ALTER TABLE `mobile_money_accounts`
  ADD CONSTRAINT `mobile_money_accounts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `paypal_accounts`
--
ALTER TABLE `paypal_accounts`
  ADD CONSTRAINT `paypal_accounts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `places`
--
ALTER TABLE `places`
  ADD CONSTRAINT `places_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `planned_trips`
--
ALTER TABLE `planned_trips`
  ADD CONSTRAINT `planned_trips_bus_id_foreign` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `planned_trips_driver_id_foreign` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `planned_trips_route_id_foreign` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`),
  ADD CONSTRAINT `planned_trips_trip_id_foreign` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `planned_trip_details`
--
ALTER TABLE `planned_trip_details`
  ADD CONSTRAINT `planned_trip_details_planned_trip_id_foreign` FOREIGN KEY (`planned_trip_id`) REFERENCES `planned_trips` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `planned_trip_details_stop_id_foreign` FOREIGN KEY (`stop_id`) REFERENCES `stops` (`id`);

--
-- Constraints for table `redemptions`
--
ALTER TABLE `redemptions`
  ADD CONSTRAINT `redemptions_bank_account_id_foreign` FOREIGN KEY (`bank_account_id`) REFERENCES `bank_accounts` (`id`),
  ADD CONSTRAINT `redemptions_mobile_money_account_id_foreign` FOREIGN KEY (`mobile_money_account_id`) REFERENCES `mobile_money_accounts` (`id`),
  ADD CONSTRAINT `redemptions_paypal_account_id_foreign` FOREIGN KEY (`paypal_account_id`) REFERENCES `paypal_accounts` (`id`),
  ADD CONSTRAINT `redemptions_redemption_type_id_foreign` FOREIGN KEY (`redemption_type_id`) REFERENCES `redemption_types` (`id`),
  ADD CONSTRAINT `redemptions_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `route_stops`
--
ALTER TABLE `route_stops`
  ADD CONSTRAINT `route_stops_route_id_foreign` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `route_stops_stop_id_foreign` FOREIGN KEY (`stop_id`) REFERENCES `stops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `route_stop_directions`
--
ALTER TABLE `route_stop_directions`
  ADD CONSTRAINT `route_stop_directions_route_stop_id_foreign` FOREIGN KEY (`route_stop_id`) REFERENCES `route_stops` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `settings`
--
ALTER TABLE `settings`
  ADD CONSTRAINT `settings_currency_id_foreign` FOREIGN KEY (`currency_id`) REFERENCES `currencies` (`id`);

--
-- Constraints for table `suspended_trips`
--
ALTER TABLE `suspended_trips`
  ADD CONSTRAINT `suspended_trips_trip_id_foreign` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`);

--
-- Constraints for table `trips`
--
ALTER TABLE `trips`
  ADD CONSTRAINT `trips_driver_id_foreign` FOREIGN KEY (`driver_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `trips_route_id_foreign` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`),
  ADD CONSTRAINT `trips_status_id_foreign` FOREIGN KEY (`status_id`) REFERENCES `statuses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `trip_details`
--
ALTER TABLE `trip_details`
  ADD CONSTRAINT `trip_details_stop_id_foreign` FOREIGN KEY (`stop_id`) REFERENCES `stops` (`id`),
  ADD CONSTRAINT `trip_details_trip_id_foreign` FOREIGN KEY (`trip_id`) REFERENCES `trips` (`id`);

--
-- Constraints for table `trip_search_results`
--
ALTER TABLE `trip_search_results`
  ADD CONSTRAINT `trip_search_results_end_stop_id_foreign` FOREIGN KEY (`end_stop_id`) REFERENCES `stops` (`id`),
  ADD CONSTRAINT `trip_search_results_planned_trip_id_foreign` FOREIGN KEY (`planned_trip_id`) REFERENCES `planned_trips` (`id`),
  ADD CONSTRAINT `trip_search_results_route_id_foreign` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`),
  ADD CONSTRAINT `trip_search_results_start_stop_id_foreign` FOREIGN KEY (`start_stop_id`) REFERENCES `stops` (`id`),
  ADD CONSTRAINT `trip_search_results_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_status_id_foreign` FOREIGN KEY (`status_id`) REFERENCES `statuses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_charges`
--
ALTER TABLE `user_charges`
  ADD CONSTRAINT `user_charges_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `user_payments`
--
ALTER TABLE `user_payments`
  ADD CONSTRAINT `user_payments_reservation_id_foreign` FOREIGN KEY (`reservation_id`) REFERENCES `customer_reserved_trips` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_payments_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `user_refunds`
--
ALTER TABLE `user_refunds`
  ADD CONSTRAINT `user_refunds_reservation_id_foreign` FOREIGN KEY (`reservation_id`) REFERENCES `customer_reserved_trips` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_refunds_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `user_statuses`
--
ALTER TABLE `user_statuses`
  ADD CONSTRAINT `user_statuses_status_id_foreign` FOREIGN KEY (`status_id`) REFERENCES `statuses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_statuses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
