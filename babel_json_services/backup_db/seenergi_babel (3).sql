-- phpMyAdmin SQL Dump
-- version 4.1.8
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 06-Maio-2014 às 05:49
-- Versão do servidor: 5.1.73-cll
-- PHP Version: 5.4.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `seenergi_babel`
--

DELIMITER $$
--
-- Functions
--
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_add_credits`(`p_invoice` VARCHAR(255), `p_credits` FLOAT) RETURNS float
BEGIN
DECLARE my_credits FLOAT;
update profile as a1 set a1.credits=(a1.credits+p_credits) where id_user = (select user_id from purchase where invoice = p_invoice);

SELECT credits into my_credits FROM `profile` WHERE id_user = (select user_id from purchase where invoice = p_invoice);

RETURN my_credits;
END$$

CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_get_avatar`(`p_id_user` INT) RETURNS varchar(300) CHARSET latin1
BEGIN
DECLARE my_avatar VARCHAR(300);

SELECT image_path into my_avatar from avatar where idavatar = (select avatar_idavatar from profile where id_user = p_id_user);

RETURN my_avatar;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `avatar`
--

CREATE TABLE IF NOT EXISTS `avatar` (
  `idavatar` int(11) NOT NULL AUTO_INCREMENT,
  `image_path` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idavatar`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=45 ;

--
-- Extraindo dados da tabela `avatar`
--

INSERT INTO `avatar` (`idavatar`, `image_path`) VALUES
(1, 'null.png'),
(21, 'resized_888143d04bed1c0fd961a370ec7f85fa.jpg'),
(22, 'resized_IMG-1385091192-V.jpg'),
(23, 'resized_Messenger_5819930491920885236_13875795583995115.jpg'),
(24, 'resized_a01 (1).png'),
(25, 'resized_Image-2.jpg'),
(26, 'resized_LOVOO_2014_02_26_06_04_39.jpg'),
(27, 'resized_IMG-20140404-WA0011.jpg'),
(28, 'resized_IMG_20140404_210310.jpg'),
(29, 'resized_IMG-20140406-WA0008.jpg'),
(30, 'resized_IMG_20140406_131542.jpg'),
(31, 'resized_IMG_20140410_152548.jpg'),
(32, 'resized_IMG_20140410_152522.jpg'),
(33, 'resized_IMG_20140421_175530.jpg'),
(34, 'resized_1399081831195.jpg'),
(35, 'resized_IMG_20140504_143702.jpg'),
(36, 'resized_'),
(37, 'resized_Screenshot_2014-04-23-05-12-48.png'),
(38, 'resized_Screenshot_2014-04-23-05-12-48.png'),
(39, 'resized_IMG-20140502-WA0004.jpg'),
(40, 'resized_IMG_20140504_143313.jpg'),
(41, 'resized_IMG_20140504_143702.jpg'),
(42, 'resized_IMG_58158435362689.jpeg'),
(43, 'resized_IMG_20140421_175530.jpg'),
(44, 'resized_IMG-20140428-WA0001.jpg');

-- --------------------------------------------------------

--
-- Estrutura da tabela `call`
--

CREATE TABLE IF NOT EXISTS `call` (
  `id_call` int(11) NOT NULL AUTO_INCREMENT,
  `start_t` timestamp NULL DEFAULT NULL,
  `end_t` timestamp NULL DEFAULT NULL,
  `from_c` int(11) NOT NULL,
  `to_c` int(11) NOT NULL,
  `service_type_idservice_type` int(11) NOT NULL,
  `token` varchar(220) CHARACTER SET latin5 COLLATE latin5_bin NOT NULL COMMENT 'token da chamada',
  PRIMARY KEY (`id_call`,`from_c`,`to_c`),
  UNIQUE KEY `token` (`token`),
  KEY `fk_call_user_profile1_idx` (`from_c`),
  KEY `fk_call_user_profile2_idx` (`to_c`),
  KEY `fk_call_service_type1_idx` (`service_type_idservice_type`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=570 ;

--
-- Extraindo dados da tabela `call`
--

INSERT INTO `call` (`id_call`, `start_t`, `end_t`, `from_c`, `to_c`, `service_type_idservice_type`, `token`) VALUES
(443, '2014-04-15 23:27:03', '2014-04-15 23:27:37', 1, 139, 3, '9b0e9bbdd703263cfe7b39070cca34d9'),
(444, '2014-04-15 23:27:51', '2014-04-15 23:28:18', 1, 139, 3, '51687a98af1717fcf97b96d0f59e8b76'),
(445, '2014-04-15 23:28:29', '2014-04-15 23:29:05', 1, 139, 3, 'f8de50354d4e453c752dd5ad2332ebcb'),
(446, '2014-04-16 01:32:49', '2014-04-16 01:33:04', 1, 139, 3, 'f0fa40f298cebba782bbcbba5474e514'),
(447, '2014-04-16 02:50:09', '2014-04-16 02:50:23', 1, 139, 3, 'f4bccb98b9686b348c96ac0dd61550cf'),
(448, '2014-04-16 02:50:25', '2014-04-16 02:50:32', 1, 139, 3, '3404a411ac6e4041b5eec6dba8097b32'),
(449, '2014-04-16 04:39:53', '2014-04-16 04:39:53', 1, 139, 3, '662c620fa2b4c6a8bdc85d220c38cc35'),
(450, '2014-04-16 07:10:35', '2014-04-16 07:10:44', 1, 139, 3, '5a691e5388fd7b212e9710da8543bd0c'),
(451, '2014-04-16 07:10:50', '2014-04-16 07:11:12', 1, 139, 3, 'e26ebb0b3aba64d6dcc5c25c8ecf18fb'),
(452, '2014-04-16 07:11:16', '2014-04-16 07:11:39', 1, 139, 3, '19355b692d806b1b59ac0bfab23934ed'),
(453, '2014-04-16 07:11:49', '2014-04-16 07:12:10', 1, 139, 3, 'd3a5a835a76d8edd7f4648c4d2c5060f'),
(454, '2014-04-16 07:12:21', '2014-04-16 07:12:24', 1, 139, 3, 'b1d24a2711f14545085c3e650efbd434'),
(455, '2014-04-16 07:12:29', '2014-04-16 07:12:31', 1, 139, 3, 'c3cc833e833202166198b9293e4ae100'),
(456, '2014-04-16 07:12:44', '2014-04-16 07:12:53', 1, 139, 3, '4b796f8012f4ca3e079ab94e928779c3'),
(457, '2014-04-16 07:13:17', '2014-04-16 07:13:20', 1, 139, 3, 'a5f046e7c1cf0c50a63dfc6e11b484fc'),
(458, '2014-04-16 07:43:26', '2014-04-16 07:43:26', 1, 139, 3, 'ee562d2dc81cc551c41ddc78f0347f98'),
(459, '2014-04-16 07:49:23', '2014-04-16 07:49:49', 1, 139, 3, '9cb40296d66da79944aac9f56c79ac5f'),
(460, '2014-04-16 08:11:48', '2014-04-16 08:11:59', 1, 139, 3, '2b76d7c934016ec58e3c7168bba275d4'),
(461, '2014-04-16 08:27:40', '2014-04-16 08:27:51', 1, 139, 3, 'b9582ad8fc9f00624dc6c13276a8994f'),
(462, '2014-04-16 08:29:33', '2014-04-16 08:29:40', 1, 139, 3, '2cadda91dafc1b870fe677de6869eebb'),
(463, '2014-04-16 08:30:10', '2014-04-16 08:30:23', 1, 139, 3, '074aca957ab390a899e224d4a6f87969'),
(464, '2014-04-16 08:31:01', '2014-04-16 08:31:06', 1, 139, 3, '4face593f7cf6c521d659dd857117a21'),
(465, '2014-04-16 09:57:02', '2014-04-16 09:57:21', 1, 139, 3, '6ec4402eb64c3c5aefe396333df1b907'),
(466, '2014-04-16 10:38:01', '2014-04-16 10:38:17', 1, 139, 3, '7a6628ab2d683f69f6b3fe0e4dee0f92'),
(467, '2014-04-16 10:40:23', '2014-04-16 10:40:59', 1, 139, 3, '2aad9994b57cbf7c7f5a89e785c2107a'),
(468, '2014-04-16 10:52:12', '2014-04-16 10:52:24', 1, 139, 3, 'd0ce3beea99f1f85de97fc05f66b7d93'),
(469, '2014-04-16 11:10:08', '2014-04-16 11:10:19', 1, 139, 3, '7898cae675756312f720e7274aef5294'),
(470, '2014-04-16 11:10:34', '2014-04-16 11:11:31', 1, 139, 3, 'f031196ce3c7cc411358ed29bcab363b'),
(471, '2014-04-16 11:19:06', '2014-04-16 11:19:06', 1, 139, 3, '59e520dbdb88274d71d58d2864d65a1c'),
(472, '2014-04-16 11:51:24', '2014-04-16 11:51:31', 1, 139, 3, '93fe26f1eeb650f03e61ab52bacddee4'),
(473, '2014-04-16 11:52:34', '2014-04-16 11:52:41', 1, 139, 3, '643f62b9a19087f115d375395e59b39a'),
(474, '2014-04-16 20:29:41', '2014-04-16 20:29:47', 1, 139, 3, '198c96693d0979621d638d467ba438f3'),
(475, '2014-04-16 20:31:30', '2014-04-16 20:31:40', 1, 139, 3, '67acf6c459023a43414677359f718276'),
(476, '2014-04-18 15:06:08', '2014-04-18 15:06:31', 1, 139, 3, '4c3e724667c998ca14e3bdc03e5d37bf'),
(477, '2014-04-18 15:12:47', '2014-04-18 15:15:51', 1, 139, 3, 'd0eec3de14cb292dffa4583715906f71'),
(478, '2014-04-18 15:26:50', '2014-04-18 15:26:50', 143, 139, 3, '208ec32bbe14f45aa251472687dfbd0a'),
(479, '2014-04-18 15:32:24', '2014-04-18 15:33:34', 1, 139, 3, '1b5a5905b53da76ffae8e66276c67528'),
(480, '2014-04-18 15:41:40', '2014-04-18 15:41:40', 1, 139, 3, '3cb14bdb4e37792ea574e034a7ff099b'),
(481, '2014-04-18 15:42:48', '2014-04-18 15:43:16', 1, 139, 3, '3ab370564d62709a873fcf35857c4e32'),
(482, '2014-04-18 15:44:30', '2014-04-18 15:45:23', 1, 139, 3, '870f4bb3e2a3cd158f3029c698617e24'),
(483, '2014-04-18 16:35:09', '2014-04-18 16:36:10', 1, 139, 3, '9c136a69e50087539cc39ac641720b2a'),
(484, '2014-04-18 17:17:12', '2014-04-18 17:17:27', 1, 139, 3, '1d81fc87c301c9beaa9dac393d03940c'),
(485, '2014-04-18 17:18:44', '2014-04-18 17:18:44', 1, 139, 3, '015d633355a0dcdf4bbd693b3e34de38'),
(486, '2014-04-18 17:23:19', '2014-04-18 17:23:19', 1, 139, 3, '9d94258e0ae95e43b79dbbdfb85384f6'),
(487, '2014-04-19 16:06:08', '2014-04-19 16:06:08', 1, 139, 3, 'ad3f7c727fe32d013ec4088394ee8d08'),
(488, '2014-04-19 16:08:09', '2014-04-19 16:08:09', 1, 139, 3, '179f4df3083e737f9248d5d87e907d17'),
(489, '2014-04-19 16:11:03', '2014-04-19 16:11:03', 1, 139, 3, '7c08ce6f3435ac86c00685de929fa448'),
(490, '2014-04-19 16:20:30', '2014-04-19 16:20:30', 1, 139, 3, '53deaeff74ef459f4720bdc4a224f92c'),
(491, '2014-04-19 16:25:43', '2014-04-19 16:25:43', 1, 139, 3, 'ee03e8ca7bdd0fa5fb515bb8d218833a'),
(492, '2014-04-20 00:00:07', '2014-04-20 00:00:07', 1, 139, 3, 'cc4e8b8048fac0775e8e258d228f8108'),
(493, '2014-04-20 00:13:43', '2014-04-20 00:13:43', 1, 139, 3, '31c6641cf8e563b4f9b93403a82623c1'),
(494, '2014-04-20 01:26:57', '2014-04-20 01:26:57', 1, 139, 3, 'edf054a7d0c40f89ce82f3ee747cd96c'),
(495, '2014-04-21 00:33:21', '2014-04-21 00:33:21', 1, 139, 3, 'ed1c8e930f2770ce252140d20bcecade'),
(496, '2014-04-21 01:18:00', '2014-04-21 01:18:36', 1, 139, 3, 'd327d30bf75bf3f9784ea4014651b3b7'),
(497, '2014-04-22 09:34:22', '2014-04-22 09:37:57', 1, 139, 3, '8f2853610712573913f17aecf2bd2f31'),
(498, '2014-04-22 09:38:03', '2014-04-22 09:38:41', 1, 139, 3, '08e946b3b243906bf3bff50cb583826b'),
(499, '2014-04-22 09:38:48', '2014-04-22 09:38:48', 1, 139, 3, '4a15431e67285645f0f309cb0c046660'),
(500, '2014-04-22 09:43:42', '2014-04-22 09:44:35', 1, 139, 3, 'ae88b4c4cfcc4fed31bc7ac2ca155643'),
(501, '2014-04-22 10:16:44', '2014-04-22 10:16:56', 1, 139, 3, 'cc2046bc2f27e5d3097957d96717971b'),
(503, '2014-04-22 10:36:23', '2014-04-22 10:37:10', 1, 139, 3, 'f12be60d7b380296ddc3ad616ae05908'),
(504, '2014-04-22 11:34:21', '2014-04-22 11:34:21', 1, 139, 3, '44b3dc4d11f02feb231a74210ddf426f'),
(505, '2014-04-22 11:38:12', '2014-04-22 11:38:33', 1, 139, 3, 'b302a775dfbb70993de2c031c13db6f6'),
(506, '2014-04-22 11:38:35', '2014-04-22 11:39:08', 1, 139, 3, 'dd4c9ddff918fbe92064f60a34e92864'),
(507, '2014-04-22 11:39:11', '2014-04-22 11:39:36', 1, 139, 3, '23c6130b072c5edb3930af2eb519f94c'),
(508, '2014-04-23 02:23:53', '2014-04-23 02:23:53', 1, 139, 3, 'ba7aaec3b5c6ba8cfdc16cc08d5bbc6a'),
(509, '2014-04-23 02:25:54', '2014-04-23 02:26:01', 1, 139, 3, 'fa1aa3a6604aea07a98f0ea80aaa9139'),
(510, '2014-04-23 02:26:03', '2014-04-23 02:26:09', 1, 139, 3, 'd98788611a7a1a7cd0c4abd9142c5688'),
(511, '2014-04-23 04:20:17', '2014-04-23 04:21:23', 1, 139, 3, '6384c9a374e1a44dd70214d0b2bb7724'),
(512, '2014-04-23 04:21:27', '2014-04-23 04:21:27', 1, 139, 3, '2fcce5204528904b6671d0e8da8b924b'),
(513, '2014-04-23 04:29:00', '2014-04-23 04:29:30', 1, 139, 3, '848e704ef3109cd1892c0fbe033335a8'),
(514, '2014-04-24 06:11:06', '2014-04-24 06:11:06', 1, 139, 3, 'ac5f884c1aa38aecd8ff1551a045d6f2'),
(515, '2014-04-24 21:01:06', '2014-04-24 21:01:39', 1, 139, 3, '5781852efe45ed8b5fc8a409a8ed31f2'),
(516, '2014-04-24 21:03:32', '2014-04-24 21:03:43', 1, 139, 3, 'e0981ac9e3e8a30520461eb2929da84b'),
(517, '2014-04-24 21:05:46', '2014-04-24 21:07:13', 1, 139, 3, 'ca0c52a9f7c0efaf47352ad02e8b3ea7'),
(518, '2014-04-25 02:55:58', '2014-04-25 02:56:09', 1, 139, 3, '578a560f938f9aa2ad0211ebef13c3ef'),
(519, '2014-04-25 02:56:51', '2014-04-25 02:57:33', 1, 139, 3, 'c858a1884b6fd88c37cd66393b4f3cd6'),
(520, '2014-04-25 02:58:12', '2014-04-25 02:59:35', 1, 139, 3, 'b6fb30accefb2b20a9b735438b7de932'),
(521, '2014-04-27 01:18:11', '2014-04-27 01:18:11', 1, 139, 3, '98289046bc19b54e9312470022f7cb44'),
(522, '2014-04-27 01:20:18', '2014-04-27 01:20:18', 1, 139, 3, 'b5ea4f2b4973b5fb88b45bdd476c4bd7'),
(523, '2014-04-27 01:24:43', '2014-04-27 01:26:48', 1, 139, 3, '30582f18adeed8a879354b69e3c5fa17'),
(524, '2014-04-29 01:01:59', '2014-04-29 01:02:14', 1, 139, 3, 'dc2f5f1a240d47f251f2d977e3404c0c'),
(525, '2014-04-29 01:03:55', '2014-04-29 01:03:55', 1, 139, 3, '75843da8ac5bf8928360c4cf67c03d7f'),
(526, '2014-04-29 01:13:00', '2014-04-29 01:13:00', 1, 139, 3, '828dec09ec472a8780128cef53cf2c3e'),
(527, '2014-04-29 02:19:42', '2014-04-29 02:19:42', 1, 139, 3, '8cbf5171b910c625771e2f72bfe80634'),
(528, '2014-04-29 02:39:56', '2014-04-29 02:42:10', 1, 139, 3, 'd2e35cd531b0e4501232fba4627c9d9f'),
(529, '2014-04-29 02:53:36', '2014-04-29 02:53:36', 1, 139, 3, 'f9007a79bab833d2a6e01d2dd9dc1ec6'),
(530, '2014-04-29 03:13:35', '2014-04-29 03:14:00', 1, 139, 3, '067ccc4245003e9d835e1e1613921035'),
(531, '2014-04-29 03:14:02', '2014-04-29 03:14:02', 1, 139, 3, 'a4434d5498d3d128dc74fbdddf0ed86c'),
(532, '2014-04-29 03:14:09', '2014-04-29 03:14:09', 1, 139, 3, '45cdf91c17dff3e2e90fbf3a835120bf'),
(533, '2014-04-29 03:14:24', '2014-04-29 03:14:26', 1, 139, 3, '064b24b683dc4011b19b339a611148e0'),
(534, '2014-04-29 03:14:37', '2014-04-29 03:14:39', 1, 139, 3, 'feaf6b04b54139bf36ed79250af3230d'),
(535, '2014-04-29 03:15:22', '2014-04-29 03:15:24', 1, 139, 3, 'bdd9f1da2b7e4386afd5767b85ea3284'),
(536, '2014-04-29 15:36:11', '2014-04-29 15:36:11', 1, 139, 3, '6c9fc2b968589bcaf36ab893c67ba845'),
(537, '2014-05-06 07:17:07', '2014-05-06 07:17:07', 1, 139, 3, '37cefd48d81a182c854253ee2a8057f6'),
(538, '2014-05-06 08:03:02', '2014-05-06 08:03:02', 1, 139, 3, 'd764b615fb194207e29b04427a6748cf'),
(539, '2014-05-06 08:03:07', '2014-05-06 08:03:07', 1, 139, 3, 'd3014d134a467fc79f68ff4ca4373a8e'),
(540, '2014-05-06 08:03:10', '2014-05-06 08:03:10', 1, 139, 3, '7dc5f3e5573df6b1f5ec6052f478d938'),
(541, '2014-05-06 08:03:13', '2014-05-06 08:03:13', 1, 139, 3, '6c4e21173dc227b0509a6d1a178e196c'),
(542, '2014-05-06 08:55:48', '2014-05-06 08:55:48', 1, 139, 3, 'decf321fa5f63f48cf61b368d08f9cb2'),
(543, '2014-05-06 08:56:47', '2014-05-06 08:56:47', 1, 139, 3, '27cc8c81bccab016abd9e1957783e101'),
(544, '2014-05-06 08:59:44', '2014-05-06 08:59:44', 1, 139, 3, '3e706c94a1d1cca5f883abfc667e2760'),
(545, '2014-05-06 09:00:17', '2014-05-06 09:00:17', 1, 139, 3, 'db1d7de668bc4c0cc3712878ddda4e76'),
(546, '2014-05-06 09:01:04', '2014-05-06 09:01:04', 1, 139, 3, 'ed738d7af950a58e763825ada28edf43'),
(547, '2014-05-06 09:01:18', '2014-05-06 09:01:31', 1, 139, 3, '7ee63b144f0cc5f8a5076b88957f7712'),
(548, '2014-05-06 09:01:34', '2014-05-06 09:01:47', 1, 139, 3, 'f2b7e46d58e0fb8c5e3290c7115d81a0'),
(549, '2014-05-06 09:01:54', '2014-05-06 09:01:54', 1, 139, 3, 'dbced92eb8056ceaf4569adcf583c1c7'),
(550, '2014-05-06 09:07:33', '2014-05-06 09:08:34', 1, 139, 3, '0cfda3b2799da919ef86e4f16fa930ea'),
(551, '2014-05-06 09:13:35', '2014-05-06 09:13:35', 1, 139, 3, '031eefcf5dc8248ea8d0cbce3b0f9e7c'),
(552, '2014-05-06 09:14:37', '2014-05-06 09:14:37', 1, 139, 3, '6d5ff5da24eaccd8e19cd686fe5dfc62'),
(553, '2014-05-06 09:16:18', '2014-05-06 09:16:18', 1, 139, 3, 'a42cdfcd0caaf591b9eb870bf60f1b1d'),
(554, '2014-05-06 09:18:39', '2014-05-06 09:18:39', 1, 139, 3, 'fc6efd838c5d9b0e56b0071aa8c15e57'),
(555, '2014-05-06 09:20:31', '2014-05-06 09:20:31', 1, 139, 3, '1d3043716090b64dcbf87c638bc6aa18'),
(556, '2014-05-06 09:22:45', '2014-05-06 09:22:55', 1, 139, 3, 'e976ae0f547a5e4d74b743592f7e4dc5'),
(557, '2014-05-06 09:23:25', '2014-05-06 09:23:37', 1, 139, 3, '3e5f6e9b7b6db875050c989f694c49ad'),
(558, '2014-05-06 09:30:50', '2014-05-06 09:31:05', 1, 139, 3, '29c20b15ccaf0653fea9d28641844f4b'),
(559, '2014-05-06 09:31:09', '2014-05-06 09:31:29', 1, 139, 3, 'd59aca40d6925e5de044dc3ab9d4761d'),
(560, '2014-05-06 09:31:36', '2014-05-06 09:32:16', 1, 139, 3, 'e95edb83ce5d12c6fa7e794a24e17e72'),
(561, '2014-05-06 09:37:20', '2014-05-06 09:37:20', 1, 139, 3, 'c0424a326efdde52be9695b6ad2711d0'),
(562, '2014-05-06 09:39:17', '2014-05-06 09:39:17', 1, 139, 3, 'a6411f0e32e8249c4d7bc9562c70faed'),
(563, '2014-05-06 09:48:02', '2014-05-06 09:48:02', 1, 139, 3, 'dc48afe44ef96926609425884570f3c7'),
(564, '2014-05-06 10:03:08', '2014-05-06 10:03:08', 1, 139, 3, 'aba2205f8998440f087ca5c7c0b6c712'),
(565, '2014-05-06 10:04:30', '2014-05-06 10:04:33', 1, 139, 3, '5012ce257bf043bd5574ec2e8c2935b6'),
(566, '2014-05-06 10:17:36', '2014-05-06 10:17:49', 1, 139, 3, '32a0f6bccb018839d2cb84a877e4545e'),
(567, '2014-05-06 10:28:26', '2014-05-06 10:28:37', 1, 139, 3, 'dcc7249d40cdd46e082a7b887f4e95f6'),
(568, '2014-05-06 10:39:49', '2014-05-06 10:39:49', 1, 139, 3, '7be07536a66d8e5fa9322450f30b6552'),
(569, '2014-05-06 10:41:54', '2014-05-06 10:41:54', 1, 139, 3, '16dc48a22f79c4af3398c3a1431a79d4');

-- --------------------------------------------------------

--
-- Estrutura da tabela `language`
--

CREATE TABLE IF NOT EXISTS `language` (
  `id_lang` int(11) NOT NULL,
  `description` varchar(45) NOT NULL,
  `token` varchar(2) NOT NULL,
  PRIMARY KEY (`id_lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `language`
--

INSERT INTO `language` (`id_lang`, `description`, `token`) VALUES
(1, 'PORTUGUESE', 'PT'),
(2, 'ENGLISH', 'EN'),
(3, 'GERMANY', 'GR'),
(4, 'FRENCH', 'FR'),
(5, 'JAPANESE', 'JP');

-- --------------------------------------------------------

--
-- Estrutura da tabela `network`
--

CREATE TABLE IF NOT EXISTS `network` (
  `idnetwork` int(11) NOT NULL AUTO_INCREMENT,
  `facebook` varchar(300) DEFAULT NULL,
  `country` varchar(2) DEFAULT NULL,
  `whatsapp` varchar(300) DEFAULT NULL,
  `viber` varchar(300) DEFAULT NULL,
  `skype` varchar(300) DEFAULT NULL,
  `linkedin` varchar(300) DEFAULT NULL,
  `microsoft` varchar(300) DEFAULT NULL,
  `serial` varchar(300) DEFAULT NULL,
  `google` varchar(300) NOT NULL,
  PRIMARY KEY (`idnetwork`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=14 ;

--
-- Extraindo dados da tabela `network`
--

INSERT INTO `network` (`idnetwork`, `facebook`, `country`, `whatsapp`, `viber`, `skype`, `linkedin`, `microsoft`, `serial`, `google`) VALUES
(5, 'malacma@hotmail.com', 'BR', 'WhatsApp', ' 554896004929', 'luisaugustomachadomoretto', 'malacma@gmail.com', 'malacma@hotmail.com', '89550440000343042053', 'malacma@gmail.com'),
(6, 'deboracrysty', 'BR', 'WhatsApp', '', 'deboracrysty@hotmail.com', 'Finance', '', '89550440000337113860', 'debora.crysty87@gmail.com'),
(7, 'deboracrysty', 'BR', 'WhatsApp', '', 'deboracrysty@hotmail.com', 'Finance', '', '89550440000337113860', 'debora.crysty87@gmail.com'),
(8, 'deboracrysty', 'BR', 'WhatsApp', '', 'deboracrysty@hotmail.com', 'Finance', '', '89550440000337113860', 'debora.crysty87@gmail.com'),
(9, 'deboracrysty', 'BR', 'WhatsApp', '', 'deboracrysty@hotmail.com', 'Finance', '', '89550440000337113860', 'debora.crysty87@gmail.com'),
(10, 'deboracrysty', 'BR', 'WhatsApp', '', 'deboracrysty@hotmail.com', 'Finance', '', '89550440000337113860', 'debora.crysty87@gmail.com'),
(11, '', 'US', '', '', '', '', '', '89111427014731456112', 'henry.gingerrich@gmail.com'),
(12, 'malacma@hotmail.com', 'BR', 'WhatsApp', ' 554896004929', 'luisaugustomachadomoretto', 'malacma@gmail.com', 'malacma@hotmail.com', '89550440000343042053', 'malacma@gmail.com'),
(13, 'malacma@hotmail.com', 'BR', 'WhatsApp', ' 554896004929', 'luisaugustomachadomoretto', 'malacma@gmail.com', 'malacma@hotmail.com', '89550440000343042053', 'malacma@gmail.com');

-- --------------------------------------------------------

--
-- Estrutura da tabela `paypal_log`
--

CREATE TABLE IF NOT EXISTS `paypal_log` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `txn_id` varchar(600) NOT NULL,
  `log` text NOT NULL,
  `posted_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `profile`
--

CREATE TABLE IF NOT EXISTS `profile` (
  `id_user` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `email` varchar(200) NOT NULL,
  `passwd` varchar(240) DEFAULT NULL,
  `online` tinyint(1) DEFAULT NULL,
  `avaliable` tinyint(1) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `paypall_acc` varchar(200) DEFAULT NULL,
  `credits` float NOT NULL,
  `fk_id_role` int(11) NOT NULL,
  `nature` int(11) NOT NULL,
  `proficiency` int(11) DEFAULT NULL,
  `avatar_idavatar` int(11) DEFAULT NULL,
  `qualified` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  UNIQUE KEY `paypall_acc_UNIQUE` (`paypall_acc`),
  KEY `fk_user_profile_Role_idx` (`fk_id_role`),
  KEY `fk_user_profile_language1_idx` (`nature`),
  KEY `fk_user_profile_language2_idx` (`proficiency`),
  KEY `fk_profile_avatar1_idx` (`avatar_idavatar`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=145 ;

--
-- Extraindo dados da tabela `profile`
--

INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(1, 'MORETTO LAMM', 'malacma@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2015-02-01', 'JSJZJZJZJSJSJ', -1087, 2, 3, 4, 44, 0),
(116, 'VISITOR', 'mMM@mamam.com', '2be0d0e84c354f20e279c6b83848f42b', 0, 0, '2014-12-03', 'N-INXNXJXJ', 0, 2, 3, 2, 30, 0),
(128, 'VISITOR', 'nene@mail.com', '8b30dfd4a3168f7954b95b6ff878fc3a', 0, 0, '0000-00-00', 'N-IJXJXJX', 0, 1, 3, 1, 30, 0),
(138, 'MARCINHO VP', 'marcio@gmail.com', '76d80224611fc919a5d54f0ff9fba446', 0, 0, '2020-10-11', 'f0eae5e7-3ad4-4370-8c68-89200600a234', 0, 1, 1, 1, 1, 0),
(139, 'MARCINHO', 'jj@mail.com', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2013-10-11', 'a83dbbe1-c5b3-411f-9919-c2097af9c111', 1102, 2, 3, 3, 1, 0),
(140, 'AVAI', 'avai@avai.com', '43ffce0e8192a15d42bebe855683ac19', 1, 1, '0000-00-00', 'dba72c09-e00b-4f43-8b8a-925138072ef3', 0, 1, 1, 1, 1, 0),
(142, 'ARTHUR', 'arthur123@gmail.com', '4eae18cf9e54a0f62b44176d074cbe2f', 0, 0, '2016-02-15', '242a4389-a2c3-47e2-a83f-981d604e41de', 0, 2, 1, 3, 1, 0),
(143, 'AVAI', 'avai@avai.com.br', '43ffce0e8192a15d42bebe855683ac19', 1, 1, '2014-10-18', 'acf9c5f7-22af-47fb-89ef-a3843da1e41b', 0, 1, 1, 1, 1, 0),
(144, 'MEME', 'malacma@gmail.com.net', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-12-22', 'c55e9eb4-1606-44a2-ae21-fdf4679e72ce', 0, 1, 1, 1, 33, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `purchase`
--

CREATE TABLE IF NOT EXISTS `purchase` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `invoice` varchar(300) NOT NULL,
  `trasaction_id` varchar(600) NOT NULL,
  `log_id` int(10) DEFAULT NULL,
  `user_id` int(10) NOT NULL,
  `product_id` varchar(300) NOT NULL,
  `product_name` varchar(300) NOT NULL,
  `product_quantity` varchar(300) NOT NULL,
  `product_amount` varchar(300) NOT NULL,
  `payer_fname` varchar(300) NOT NULL,
  `payer_lname` varchar(300) NOT NULL,
  `payer_address` varchar(300) NOT NULL,
  `payer_city` varchar(300) NOT NULL,
  `payer_state` varchar(300) NOT NULL,
  `payer_zip` varchar(300) NOT NULL,
  `payer_country` varchar(300) NOT NULL,
  `payer_email` text NOT NULL,
  `payment_status` varchar(300) NOT NULL,
  `posted_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_profile_id` (`user_id`),
  KEY `fk_log_id` (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `role`
--

CREATE TABLE IF NOT EXISTS `role` (
  `id_role` int(11) NOT NULL,
  `role_name` varchar(20) NOT NULL,
  PRIMARY KEY (`id_role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `role`
--

INSERT INTO `role` (`id_role`, `role_name`) VALUES
(1, 'USER'),
(2, 'TRANSLATOR');

-- --------------------------------------------------------

--
-- Estrutura da tabela `service_type`
--

CREATE TABLE IF NOT EXISTS `service_type` (
  `idservice_type` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`idservice_type`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Extraindo dados da tabela `service_type`
--

INSERT INTO `service_type` (`idservice_type`, `description`) VALUES
(1, 'SECURITY'),
(2, 'HEALTHCARE'),
(3, 'DEFAULT');

-- --------------------------------------------------------

--
-- Estrutura da tabela `sip_server`
--

CREATE TABLE IF NOT EXISTS `sip_server` (
  `idsip_server` int(11) NOT NULL AUTO_INCREMENT,
  `servername` varchar(200) NOT NULL,
  PRIMARY KEY (`idsip_server`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

--
-- Extraindo dados da tabela `sip_server`
--

INSERT INTO `sip_server` (`idsip_server`, `servername`) VALUES
(1, 'ekiga.net'),
(2, 'sps6.commcorp.com.br');

-- --------------------------------------------------------

--
-- Estrutura da tabela `sip_user`
--

CREATE TABLE IF NOT EXISTS `sip_user` (
  `idsip_user` int(11) NOT NULL AUTO_INCREMENT,
  `user` varchar(100) DEFAULT NULL,
  `pass` varchar(45) DEFAULT NULL,
  `profile_id_user` int(11) DEFAULT NULL,
  `sip_server_idsip_server` int(11) NOT NULL,
  PRIMARY KEY (`idsip_user`),
  KEY `fk_sip_user_profile1_idx` (`profile_id_user`),
  KEY `fk_sip_user_sip_server1_idx` (`sip_server_idsip_server`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;

--
-- Extraindo dados da tabela `sip_user`
--

INSERT INTO `sip_user` (`idsip_user`, `user`, `pass`, `profile_id_user`, `sip_server_idsip_server`) VALUES
(1, 'tradutoringles', '36w74nsE', 138, 1),
(2, 'CS00016926', '25h34bgQ', 140, 2),
(3, 'CS00016927', '19d61reT', 143, 2),
(4, 'CS00016928', '74c46toG', 143, 2),
(5, 'user_pt_bt', 'user_pt_bt', 1, 1),
(6, 'translator_pt_en', 'translator_pt_en', 139, 1);

--
-- Constraints for dumped tables
--

--
-- Limitadores para a tabela `call`
--
ALTER TABLE `call`
  ADD CONSTRAINT `fk_call_service_type1` FOREIGN KEY (`service_type_idservice_type`) REFERENCES `service_type` (`idservice_type`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_call_user_profile1` FOREIGN KEY (`from_c`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_call_user_profile2` FOREIGN KEY (`to_c`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `profile`
--
ALTER TABLE `profile`
  ADD CONSTRAINT `fk_profile_avatar1` FOREIGN KEY (`avatar_idavatar`) REFERENCES `avatar` (`idavatar`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_language1` FOREIGN KEY (`nature`) REFERENCES `language` (`id_lang`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_language2` FOREIGN KEY (`proficiency`) REFERENCES `language` (`id_lang`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_Role` FOREIGN KEY (`fk_id_role`) REFERENCES `role` (`id_role`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `purchase`
--
ALTER TABLE `purchase`
  ADD CONSTRAINT `fk_paypall_log_id` FOREIGN KEY (`log_id`) REFERENCES `paypal_log` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_paypall_user_profile1` FOREIGN KEY (`user_id`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `sip_user`
--
ALTER TABLE `sip_user`
  ADD CONSTRAINT `fk_sip_user_profile1` FOREIGN KEY (`profile_id_user`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_sip_user_sip_server1` FOREIGN KEY (`sip_server_idsip_server`) REFERENCES `sip_server` (`idsip_server`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
