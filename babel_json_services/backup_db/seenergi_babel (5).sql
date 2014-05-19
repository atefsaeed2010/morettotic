-- phpMyAdmin SQL Dump
-- version 4.1.8
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 19-Maio-2014 às 16:28
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

CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_login`(`p_ip` VARCHAR(50), `p_email` VARCHAR(200), `p_language` VARCHAR(2)) RETURNS int(11)
    NO SQL
BEGIN
DECLARE my_id INT;
DECLARE my_nature INT;

SELECT id_lang into my_nature FROM `language` WHERE token =  p_language;

SELECT id_user into my_id FROM `profile` 
WHERE email = p_email;

UPDATE `profile` SET 
`avaliable` = true,`online`=true,`nature`=my_nature 
WHERE id_user = my_id;

INSERT INTO `log`(idlog,ip,date,id_user)  VALUES(null,p_ip,now(),my_id);


RETURN my_nature;
END$$

CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_rate_translator`(`id_user` INT(11), `id_trans` INT(11), `rate` FLOAT) RETURNS int(11)
    NO SQL
BEGIN
DECLARE id_eval INT;

INSERT INTO `evaluation`( `date`, `rate`, `profile_id_translator`, `profile_id_user`) VALUES (now(),rate,id_user,id_trans);

SELECT idevaluation into id_eval FROM `evaluation` WHERE profile_id_translator = id_trans AND profile_id_user = id_user;

RETURN id_eval;
END$$

CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_set_avatar`(`p_image` VARCHAR(300), `p_id_user` INT(11)) RETURNS int(11)
    NO SQL
BEGIN

DECLARE img_id INT(11);

INSERT INTO avatar (image_path) VALUES (p_image);

SELECT idavatar INTO img_id FROM avatar WHERE image_path = p_image;

UPDATE profile SET avatar_idavatar = img_id  WHERE id_user = p_id_user;

RETURN img_id;

END$$

CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_set_unavaliable`(`p_id_user` INT(11), `p_id_translator` INT(11)) RETURNS int(11)
    NO SQL
begin
update profile 
set online = true and avaliable = false where id_user= p_id_user;
update profile 
set online = true and avaliable = false where id_user= p_id_trans;
return -1;

end$$

CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_sipacc`(`p_email` VARCHAR(200), `p_pass` VARCHAR(300)) RETURNS int(11)
    NO SQL
BEGIN
DECLARE my_id INT;
DECLARE my_sip INT;

SELECT idsip_user into my_sip FROM sip_user WHERE profile_id_user IS NULL  LIMIT 1;

SELECT id_user into my_id FROM `profile` 
WHERE email = p_email AND passwd = p_pass;

update sip_user set profile_id_user = my_id 
where idsip_user = my_sip;

return my_sip;

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=143 ;

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
(44, 'resized_IMG-20140428-WA0001.jpg'),
(45, 'resized_FB_IMG_13976845447457075.jpg'),
(46, 'resized_IMG-1398784640338-V.jpg'),
(47, 'resized_IMG_20140504_142059.jpg'),
(48, 'resized_last_background.jpg'),
(49, 'resized_IMG-20140428-WA0001.jpg'),
(50, 'resized_IMG_20140422_174522.jpg'),
(51, 'resized_IMG_20140504_143702.jpg'),
(52, 'resized_IMG_58158435362689.jpeg'),
(53, 'resized_IMG_20140422_174522.jpg'),
(54, 'resized_IMG_20140504_143702.jpg'),
(55, 'resized_FB_IMG_13976845447457075.jpg'),
(56, 'resized_1399081831195.jpg'),
(57, 'resized_IMG_20140421_175530.jpg'),
(58, 'resized_IMG_20140504_142132.jpg'),
(59, 'resized_IMG-20140421-WA0001.jpg'),
(60, ''),
(61, ''),
(62, ''),
(63, ''),
(64, ''),
(65, ''),
(66, ''),
(67, 'IMG00075.jpg'),
(68, 'IMG00075.jpg'),
(69, 'IMG00075.jpg'),
(70, 'IMG00075.jpg'),
(71, 'IMG00075.jpg'),
(72, 'resized_IMG_20140426_152141.jpg'),
(73, 'resized_IMG_20140426_152141.jpg'),
(74, 'resized_FB_IMG_13976845447457075.jpg'),
(75, 'IMG00075.jpg'),
(76, 'LOVOO_2014_03_26_14_04_40.jpg'),
(77, 'LOVOO_2014_03_26_14_04_40.jpg'),
(78, 'LOVOO_2014_03_26_14_04_40.jpg'),
(79, 'LOVOO_2014_03_26_14_04_40.jpg'),
(80, 'LOVOO_2014_03_26_14_04_40.jpg'),
(81, 'resized_Screenshot_2014-04-16-14-31-28.png'),
(82, 'IMG-20140401-WA0004.jpg'),
(83, 'resized_IMG-20140424-WA0002.jpg'),
(84, 'IMG-20140424-WA0002.jpg'),
(85, 'resized_IMG-20140424-WA0002.jpg'),
(86, 'resized_IMG_20140421_175530.jpg'),
(87, 'IMG_20140504_142134.jpg'),
(88, 'IMG_20140504_142134.jpg'),
(89, 'resized_20140504_220408.jpg'),
(90, 'resized_'),
(91, 'IMG-20140502-WA0001.jpg'),
(92, 'IMG_20140421_175530.jpg'),
(93, 'IMG-20140421-WA0001.jpg'),
(94, 'IMG_20140504_143702.jpg'),
(95, '1399081831195.jpg'),
(96, 'IMG_20140426_152141.jpg'),
(97, 'Image-2.jpg'),
(98, 'IMG_20140504_143702.jpg'),
(99, 'IMG-1398784640338-V.jpg'),
(100, 'IMG_20140422_174522.jpg'),
(101, 'IMG-20140421-WA0000.jpg'),
(102, 'IMG_58158435362689.jpeg'),
(103, 'IMG-20140511-WA0000.jpg'),
(104, 'last_background.jpg'),
(105, 'IMG_58158435362689.jpeg'),
(106, 'IMG_58158435362689.jpeg'),
(107, 'IMG-20140511-WA0000.jpg'),
(108, 'Screenshot_2014-05-10-11-40-03.png'),
(109, 'Screenshot_2014-04-16-14-31-35.png'),
(110, '1399081831195.jpg'),
(111, 'IMG-1398784640338-V.jpg'),
(112, 'IMG_58158435362689.jpeg'),
(115, '12313'),
(116, '123123123'),
(117, '1231'),
(118, '12312'),
(119, 'IMG-20140424-WA0000.jpg'),
(120, '12299-MLB20057718045_032014-O.jpg'),
(121, 'IMG_20140508_175622.jpg'),
(133, 'FB_IMG_13976845447457075.jpg'),
(139, '17520e7be66bc1fa00d7a72d69737ef1.jpg'),
(141, 'IMG_20140420_181722.jpg'),
(142, 'IMG_20140504_141743.jpg');

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=963 ;

--
-- Extraindo dados da tabela `call`
--

INSERT INTO `call` (`id_call`, `start_t`, `end_t`, `from_c`, `to_c`, `service_type_idservice_type`, `token`) VALUES
(777, '2014-05-12 03:38:12', '2014-05-12 03:38:12', 1, 148, 3, 'b7097e0cb68a4f11106f770136cae8e4'),
(778, '2014-05-12 03:38:19', '2014-05-12 03:38:19', 1, 148, 3, '43327b1e5dc6fee6574ee1cedcaebea6'),
(779, '2014-05-12 03:38:24', '2014-05-12 03:38:24', 1, 148, 3, 'd84f50dc44eaef16ff297eee789d88db'),
(780, '2014-05-12 03:38:31', '2014-05-12 03:38:31', 1, 148, 3, '211157bb2fd1f40c33367f15e8d45804'),
(789, '2014-05-12 03:38:49', '2014-05-12 03:38:49', 1, 148, 3, 'c21c0da315cc6a350f4132bd538f8b1e'),
(790, '2014-05-12 03:52:36', '2014-05-12 03:52:36', 1, 148, 3, 'e3dde5b4a175aecdaed373486e9cfdb4'),
(798, '2014-05-12 03:52:56', '2014-05-12 03:52:56', 1, 148, 3, '67755f14f8091afb2681dc1e770039ca'),
(799, '2014-05-12 09:23:33', '2014-05-12 09:23:33', 193, 147, 3, 'cdb19be1776d80520a247a69a601e340'),
(800, '2014-05-13 00:03:18', '2014-05-13 00:03:27', 1, 147, 3, '8655af0cce1d8c55ebe868622896d444'),
(803, '2014-05-13 00:03:34', '2014-05-13 00:03:39', 1, 147, 3, 'e8d7a0f62c947aefcfd3979610eeb437'),
(804, '2014-05-13 00:04:34', '2014-05-13 00:04:34', 1, 147, 3, 'd530a7842e6f906bfb570fdf574cfde3'),
(805, '2014-05-13 00:40:19', '2014-05-13 00:41:20', 1, 147, 3, 'd08b2f2b5f0d1f5867885827debbe96f'),
(806, '2014-05-13 02:55:56', '2014-05-13 02:55:56', 1, 147, 3, '58b7dd2a4d37d372b1f3b552a2a983eb'),
(812, '2014-05-13 07:00:15', '2014-05-13 07:00:15', 1, 147, 3, 'e249a8df9cf0c3e872f5c01e03f3ab7e'),
(817, '2014-05-13 07:00:29', '2014-05-13 07:20:48', 1, 139, 3, 'c40e4f382113ba61b7511bc4b967b87c'),
(819, '2014-05-13 07:25:24', '2014-05-13 07:25:58', 1, 147, 3, 'ba739267c3042d7d59e2327bbe3bba56'),
(821, '2014-05-13 07:30:11', '2014-05-13 07:30:44', 1, 147, 3, '5d8299441dc8c8b8b55328c2c9570a80'),
(826, '2014-05-13 09:09:19', '2014-05-13 09:09:19', 1, 187, 3, '58d5460d80c0461875cad02b03aa0a13'),
(828, '2014-05-13 09:09:26', '2014-05-13 09:09:26', 1, 148, 3, '6c15d5ab8aae657ca02d0be1968ba940'),
(832, '2014-05-13 09:09:39', '2014-05-13 09:09:39', 1, 187, 3, 'd1477a050ddf1eb5c407a21d64488014'),
(833, '2014-05-13 09:09:42', '2014-05-13 09:09:42', 1, 148, 3, '6d456e554b704032cad88f346051d266'),
(834, '2014-05-13 09:09:45', '2014-05-13 09:09:45', 1, 148, 3, 'd4aa641d0e61a0308b028dbd00678aad'),
(853, '2014-05-13 09:45:53', '2014-05-13 09:45:53', 1, 187, 3, '53fd85b9b88ea9023d0ac043c51f75df'),
(855, '2014-05-13 09:45:55', '2014-05-13 09:45:55', 1, 148, 3, '407ef183f7710abb630105a22caaada7'),
(856, '2014-05-13 09:46:07', '2014-05-13 09:46:07', 1, 148, 3, 'b2e225ea413acaf216fcf30178282c70'),
(857, '2014-05-13 09:51:45', '2014-05-13 09:51:45', 1, 148, 3, 'd96890ed6daf7b5c512b5fb1329e9fc0'),
(858, '2014-05-13 09:53:16', '2014-05-13 09:53:16', 1, 148, 3, 'd17b109d29ed6044f48da94a6537149d'),
(860, '2014-05-13 09:54:57', '2014-05-13 09:54:57', 1, 187, 3, '7e768f9db9d1149f1e5c05c01081aac7'),
(864, '2014-05-13 09:55:03', '2014-05-13 09:55:03', 1, 148, 3, '3bbac30411e27da85ee3ef7f953d40c8'),
(865, '2014-05-13 09:56:57', '2014-05-13 09:56:57', 1, 148, 3, '99b37c2b261407c097c6ca303fe17e66'),
(866, '2014-05-13 09:59:22', '2014-05-13 09:59:22', 1, 148, 3, 'd9a4dabf0a8b902bb68a1e0ee02de71c'),
(867, '2014-05-13 09:59:44', '2014-05-13 09:59:44', 1, 148, 3, 'ca076670145c1cac9ff5976396f32328'),
(868, '2014-05-13 10:09:18', '2014-05-13 10:09:18', 1, 148, 3, '2d3621309850ef46be4069b558ceb746'),
(869, '2014-05-13 10:10:02', '2014-05-13 10:10:37', 1, 148, 3, 'bb5e6ce5c83e6681758a661af36f1787'),
(870, '2014-05-13 10:10:41', '2014-05-13 10:10:41', 1, 148, 3, '15e6aea897d58ea493f1e821e6b03dfb'),
(871, '2014-05-13 10:14:23', '2014-05-13 10:14:23', 1, 148, 3, 'c55837b3a74fd52bc93eda3a9a304153'),
(872, '2014-05-13 11:15:53', '2014-05-13 11:15:53', 1, 148, 3, '1a86d201cefd26f03026ef8b7f001189'),
(873, '2014-05-13 11:15:57', '2014-05-13 11:15:57', 1, 148, 3, '6c7bd5556e9e17f7c7e534995605e158'),
(875, '2014-05-13 11:17:41', '2014-05-13 11:17:41', 1, 148, 3, 'ec1d4d3d09c117c0ecaf458339675144'),
(876, '2014-05-13 11:34:27', '2014-05-13 11:34:27', 1, 148, 3, '64fcaadce24aea7634ff5aebf9000ba5'),
(877, '2014-05-13 11:34:46', '2014-05-13 11:34:46', 1, 148, 3, '56a1a2e83deaae818656b75a52cb7eea'),
(878, '2014-05-13 11:35:04', '2014-05-13 11:35:11', 1, 148, 3, 'f7c81cac7563ea9f4adedfb1b696ab7a'),
(882, '2014-05-13 11:35:19', '2014-05-13 11:35:19', 1, 187, 3, 'da14c368ae5448404d07c848e3479f51'),
(886, '2014-05-13 11:35:25', '2014-05-13 11:35:25', 1, 187, 3, '790a46294313882b705d5c65164ac3f1'),
(891, '2014-05-13 11:35:32', '2014-05-13 11:35:32', 1, 148, 3, '4d598e1927418a7fc4de409f46988942'),
(892, '2014-05-13 12:20:49', '2014-05-13 12:20:54', 1, 148, 3, '654c7d25a9388232a1f6c50a5676eb39'),
(893, '2014-05-13 12:20:59', '2014-05-13 12:21:02', 1, 148, 3, '2a132031a8f694b1dcf4c33814736e6d'),
(895, '2014-05-13 12:22:20', '2014-05-13 12:22:25', 1, 148, 2, '02f37f3ba99d57aa6fc8e4f261ee4cd8'),
(896, '2014-05-13 12:22:28', '2014-05-13 12:22:34', 1, 148, 3, '6f9a692c861546748856ed5a543eaf16'),
(906, '2014-05-13 12:23:22', '2014-05-13 12:23:48', 1, 148, 3, 'f02d4e9bab5a74a022a39a89e18f12cf'),
(915, '2014-05-13 13:14:11', '2014-05-13 13:14:32', 1, 148, 3, '5450e7915abb31706a7ee45cb65e2811'),
(933, '2014-05-13 13:14:51', '2014-05-13 13:14:58', 1, 148, 3, '809dd79b78f99933aa0bb1b8d57c11ef'),
(934, '2014-05-13 13:15:07', '2014-05-13 13:15:25', 1, 148, 3, '2fc29be7ae65ddd8f7a7fca19c32a9e8'),
(941, '2014-05-13 13:18:39', '2014-05-13 13:21:47', 1, 148, 3, 'df94c1a38a0373b1bb1298fe108bfb03'),
(942, '2014-05-13 13:22:09', '2014-05-13 13:22:09', 1, 148, 3, '892277eabf8069410614e8fb5ba54533'),
(943, '2014-05-13 13:22:21', '2014-05-13 13:22:21', 1, 148, 3, '73a2849054ec3b4bee36d8c4487dc5d5'),
(944, '2014-05-13 13:22:25', '2014-05-13 13:22:25', 1, 148, 3, 'c3c79b008e01210db6cb140b757e1ee1'),
(946, '2014-05-13 13:24:03', '2014-05-13 13:24:03', 1, 188, 3, '8813bcbfec8ba900cb763415de37bcdd'),
(951, '2014-05-13 13:24:08', '2014-05-13 13:24:08', 1, 148, 3, 'd3b258a92a6883ecb1f5efdff5f7933c'),
(952, '2014-05-13 23:10:46', '2014-05-13 23:10:50', 1, 148, 3, '47ddcad71371518972d0fd7aeb6c11c9'),
(953, '2014-05-14 00:34:23', '2014-05-14 00:34:23', 1, 148, 3, '5399777131345f42fe6bf71d4421de47'),
(954, '2014-05-14 02:54:15', '2014-05-14 02:54:21', 1, 148, 3, '5239c157eba7eb0073d0420c8e939a7b'),
(955, '2014-05-15 05:47:29', '2014-05-15 05:47:29', 1, 147, 3, '6c0e55982a5d9d0b4fb974211fca8029'),
(956, '2014-05-16 03:24:19', '2014-05-16 03:25:10', 1, 147, 3, '74f45e3dd3a10cc9ce0456dc1b8aa840'),
(957, '2014-05-16 03:30:25', '2014-05-16 03:30:39', 1, 147, 3, '883c6a79879d15fa96e3b660dd265653'),
(958, '2014-05-16 03:30:41', '2014-05-16 03:30:43', 1, 139, 3, '7188e19eeccb78f1059765c64448a757'),
(959, '2014-05-16 03:30:49', '2014-05-16 03:30:58', 1, 147, 3, '2e3ec488bde19fa9cc9fb9a47f9eec1d'),
(960, '2014-05-16 07:47:53', '2014-05-16 07:47:53', 1, 147, 3, '034b158d065cbfbd4adf7c9778d03909'),
(961, '2014-05-19 10:34:42', '2014-05-19 10:34:49', 1, 147, 3, 'bf610403b83a0fb6bf0f8d9dd9ea3f8f'),
(962, '2014-05-19 10:36:45', '2014-05-19 10:36:45', 1, 148, 3, 'ed2f30cff951d63cd5e5e58bdc0d206b');

-- --------------------------------------------------------

--
-- Estrutura da tabela `evaluation`
--

CREATE TABLE IF NOT EXISTS `evaluation` (
  `idevaluation` int(11) NOT NULL AUTO_INCREMENT,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `rate` float NOT NULL,
  `profile_id_translator` int(11) NOT NULL,
  `profile_id_user` int(11) NOT NULL,
  PRIMARY KEY (`idevaluation`),
  KEY `fk_evaluation_profile_idx` (`profile_id_translator`),
  KEY `fk_evaluation_profile1_idx` (`profile_id_user`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=40 ;

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
(1, 'PORTUGUESE', 'BR'),
(2, 'ENGLISH', 'EN'),
(3, 'GERMANY', 'GR'),
(4, 'FRENCH', 'FR'),
(5, 'JAPANESE', 'JP'),
(6, 'CHINESE', 'CH'),
(7, 'ARABIC', 'MR'),
(8, 'SPANISH', 'ES');

-- --------------------------------------------------------

--
-- Estrutura da tabela `log`
--

CREATE TABLE IF NOT EXISTS `log` (
  `idlog` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(45) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `id_user` int(11) NOT NULL,
  PRIMARY KEY (`idlog`),
  KEY `fk_log_profile_idx` (`id_user`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=179 ;

--
-- Extraindo dados da tabela `log`
--

INSERT INTO `log` (`idlog`, `ip`, `date`, `id_user`) VALUES
(20, '186.222.60.227', '2014-05-12 04:44:36', 1),
(21, '186.222.60.227', '2014-05-12 04:44:40', 1),
(22, '186.222.60.227', '2014-05-12 04:44:43', 1),
(23, '186.222.60.227', '2014-05-12 04:44:46', 1),
(24, '186.222.60.227', '2014-05-12 04:45:16', 1),
(25, '186.222.60.227', '2014-05-12 04:45:30', 1),
(26, '186.222.60.227', '2014-05-12 04:45:56', 1),
(27, '186.222.60.227', '2014-05-12 04:46:11', 1),
(28, '186.222.60.227', '2014-05-12 04:46:50', 1),
(29, '186.222.60.227', '2014-05-12 06:18:01', 190),
(30, '186.222.60.227', '2014-05-12 06:18:58', 191),
(31, '186.222.60.227', '2014-05-12 06:20:29', 192),
(32, '186.222.60.227', '2014-05-12 06:21:58', 193),
(33, '186.222.60.227', '2014-05-12 06:22:35', 193),
(34, '186.222.60.227', '2014-05-12 06:22:52', 193),
(35, '186.222.60.227', '2014-05-12 06:46:00', 1),
(36, '186.222.60.227', '2014-05-12 06:46:10', 1),
(37, '186.222.60.227', '2014-05-12 06:46:25', 1),
(38, '186.222.60.227', '2014-05-12 06:47:09', 1),
(39, '186.222.60.227', '2014-05-12 21:02:41', 1),
(40, '186.222.60.227', '2014-05-12 21:04:06', 1),
(41, '186.222.60.227', '2014-05-12 21:04:15', 1),
(42, '186.222.60.227', '2014-05-12 21:40:02', 1),
(43, '186.222.60.227', '2014-05-12 23:55:46', 1),
(44, '186.222.60.227', '2014-05-13 00:51:07', 1),
(45, '186.222.60.227', '2014-05-13 02:34:33', 1),
(46, '186.222.60.227', '2014-05-13 02:36:29', 1),
(47, '179.255.191.44', '2014-05-13 02:38:57', 1),
(48, '186.222.60.227', '2014-05-13 02:44:48', 1),
(49, '186.222.60.227', '2014-05-13 03:01:12', 1),
(50, '186.222.60.227', '2014-05-13 03:03:47', 1),
(51, '186.222.60.227', '2014-05-13 03:04:14', 1),
(52, '186.222.60.227', '2014-05-13 03:13:11', 1),
(53, '186.222.60.227', '2014-05-13 03:13:28', 1),
(54, '186.222.60.227', '2014-05-13 03:15:12', 1),
(55, '191.219.49.207', '2014-05-13 03:20:36', 1),
(56, '191.219.49.207', '2014-05-13 03:23:04', 1),
(57, '191.219.49.207', '2014-05-13 03:24:41', 1),
(58, '186.222.60.227', '2014-05-13 03:26:03', 1),
(59, '186.222.60.227', '2014-05-13 03:26:04', 1),
(60, '186.222.60.227', '2014-05-13 03:26:05', 1),
(61, '186.222.60.227', '2014-05-13 03:26:42', 1),
(62, '186.222.60.227', '2014-05-13 03:27:22', 1),
(63, '191.219.49.207', '2014-05-13 03:29:16', 1),
(64, '186.222.60.227', '2014-05-13 03:32:09', 1),
(65, '186.222.60.227', '2014-05-13 03:32:18', 1),
(66, '186.222.60.227', '2014-05-13 03:32:19', 1),
(67, '186.222.60.227', '2014-05-13 03:32:24', 1),
(68, '186.222.60.227', '2014-05-13 03:32:25', 1),
(69, '186.222.60.227', '2014-05-13 03:32:27', 1),
(70, '186.222.60.227', '2014-05-13 03:32:29', 1),
(71, '191.219.49.207', '2014-05-13 03:35:40', 1),
(72, '186.222.60.227', '2014-05-13 03:35:45', 1),
(73, '191.219.49.207', '2014-05-13 03:41:43', 1),
(74, '186.222.60.227', '2014-05-13 03:42:19', 1),
(75, '191.219.49.207', '2014-05-13 03:44:49', 1),
(76, '186.222.60.227', '2014-05-13 03:45:31', 1),
(77, '191.219.49.207', '2014-05-13 03:48:33', 1),
(78, '179.255.183.165', '2014-05-13 03:50:52', 1),
(79, '179.255.183.165', '2014-05-13 03:52:12', 1),
(80, '179.255.183.165', '2014-05-13 03:54:15', 1),
(81, '179.255.183.165', '2014-05-13 03:56:23', 1),
(82, '186.222.60.227', '2014-05-13 03:58:40', 1),
(83, '186.222.60.227', '2014-05-13 04:20:39', 1),
(84, '179.255.171.191', '2014-05-13 04:21:54', 1),
(85, '179.255.171.191', '2014-05-13 04:24:24', 1),
(86, '179.255.192.110', '2014-05-13 04:29:31', 1),
(87, '186.222.60.227', '2014-05-13 05:01:01', 1),
(88, '186.222.60.227', '2014-05-13 05:05:11', 1),
(89, '186.222.60.227', '2014-05-13 05:52:01', 1),
(90, '186.222.60.227', '2014-05-13 06:05:15', 1),
(91, '186.222.60.227', '2014-05-13 06:09:06', 1),
(92, '186.222.60.227', '2014-05-13 06:11:06', 1),
(93, '186.222.60.227', '2014-05-13 06:14:59', 1),
(94, '186.222.60.227', '2014-05-13 06:15:04', 1),
(95, '186.222.60.227', '2014-05-13 06:15:07', 1),
(96, '186.222.60.227', '2014-05-13 06:15:11', 1),
(97, '186.222.60.227', '2014-05-13 06:15:14', 1),
(98, '186.222.60.227', '2014-05-13 06:15:49', 1),
(99, '186.222.60.227', '2014-05-13 06:15:53', 1),
(100, '186.222.60.227', '2014-05-13 06:15:58', 1),
(101, '186.222.60.227', '2014-05-13 06:17:57', 1),
(102, '186.222.60.227', '2014-05-13 06:23:06', 1),
(103, '186.222.60.227', '2014-05-13 06:23:20', 1),
(104, '186.222.60.227', '2014-05-13 06:25:06', 1),
(105, '186.222.60.227', '2014-05-13 06:28:21', 1),
(106, '186.222.60.227', '2014-05-13 06:41:42', 1),
(107, '186.222.60.227', '2014-05-13 06:51:41', 1),
(108, '186.222.60.227', '2014-05-13 06:53:10', 1),
(109, '186.222.60.227', '2014-05-13 07:09:15', 1),
(110, '186.222.60.227', '2014-05-13 07:24:15', 1),
(111, '186.222.60.227', '2014-05-13 07:24:45', 1),
(112, '186.222.60.227', '2014-05-13 07:30:20', 1),
(113, '186.222.60.227', '2014-05-13 07:31:15', 1),
(114, '186.222.60.227', '2014-05-13 08:08:04', 1),
(115, '186.222.60.227', '2014-05-13 08:12:10', 1),
(116, '186.222.60.227', '2014-05-13 08:15:37', 1),
(117, '186.222.60.227', '2014-05-13 08:20:04', 1),
(118, '186.222.60.227', '2014-05-13 08:21:55', 1),
(119, '186.222.60.227', '2014-05-13 08:23:22', 1),
(120, '186.222.60.227', '2014-05-13 08:24:03', 1),
(121, '186.222.60.227', '2014-05-13 08:24:30', 1),
(122, '186.222.60.227', '2014-05-13 08:32:19', 1),
(123, '186.222.60.227', '2014-05-13 08:34:21', 1),
(124, '186.222.60.227', '2014-05-13 08:34:42', 1),
(125, '186.222.60.227', '2014-05-13 08:34:56', 1),
(126, '186.222.60.227', '2014-05-13 09:20:42', 1),
(127, '186.222.60.227', '2014-05-13 09:24:01', 1),
(128, '186.222.60.227', '2014-05-13 09:24:05', 1),
(129, '186.222.60.227', '2014-05-13 09:24:23', 1),
(130, '186.222.60.227', '2014-05-13 09:24:33', 1),
(131, '186.222.60.227', '2014-05-13 09:27:02', 1),
(132, '186.222.60.227', '2014-05-13 09:37:49', 1),
(133, '186.222.60.227', '2014-05-13 10:14:07', 1),
(134, '186.222.60.227', '2014-05-13 10:15:56', 1),
(135, '186.222.60.227', '2014-05-13 10:15:59', 1),
(136, '186.222.60.227', '2014-05-13 10:16:02', 1),
(137, '186.222.60.227', '2014-05-13 10:16:06', 1),
(138, '186.222.60.227', '2014-05-13 10:16:12', 1),
(139, '186.222.60.227', '2014-05-13 10:16:18', 1),
(140, '186.222.60.227', '2014-05-13 10:18:37', 1),
(141, '186.222.60.227', '2014-05-13 10:26:17', 1),
(142, '186.222.60.227', '2014-05-13 20:10:28', 1),
(143, '186.254.116.201', '2014-05-13 21:33:11', 1),
(144, '179.206.240.255', '2014-05-13 23:52:14', 1),
(145, '179.206.240.255', '2014-05-13 23:52:21', 1),
(146, '179.206.240.255', '2014-05-13 23:52:48', 1),
(147, '186.198.251.233', '2014-05-14 00:41:56', 1),
(148, '177.96.146.171', '2014-05-14 01:06:08', 1),
(149, '177.96.146.171', '2014-05-14 01:11:55', 1),
(150, '189.66.230.246', '2014-05-15 00:15:06', 1),
(151, '189.66.230.246', '2014-05-15 00:15:57', 194),
(152, '189.66.230.246', '2014-05-15 00:16:03', 194),
(153, '191.224.229.166', '2014-05-15 02:20:06', 194),
(154, '191.224.229.166', '2014-05-15 02:20:22', 1),
(155, '186.222.60.227', '2014-05-15 02:59:51', 1),
(156, '186.222.60.227', '2014-05-15 03:02:49', 1),
(157, '186.222.60.227', '2014-05-15 07:51:59', 1),
(158, '186.222.60.227', '2014-05-16 00:21:14', 1),
(159, '186.222.60.227', '2014-05-16 00:24:17', 1),
(160, '186.222.60.227', '2014-05-16 00:26:11', 1),
(161, '186.222.60.227', '2014-05-16 00:30:02', 1),
(162, '186.222.60.227', '2014-05-16 04:42:36', 1),
(163, '186.222.60.227', '2014-05-16 04:46:21', 1),
(164, '186.222.60.227', '2014-05-16 05:03:51', 1),
(165, '186.222.60.227', '2014-05-16 05:07:15', 1),
(166, '186.222.60.227', '2014-05-16 05:11:33', 1),
(167, '186.222.60.227', '2014-05-16 05:13:23', 1),
(168, '191.219.85.186', '2014-05-17 14:44:23', 1),
(169, '179.216.171.104', '2014-05-17 22:56:00', 1),
(170, '179.216.171.104', '2014-05-18 01:08:05', 1),
(171, '179.216.171.104', '2014-05-19 07:33:41', 1),
(172, '179.216.171.104', '2014-05-19 07:34:03', 1),
(173, '179.216.171.104', '2014-05-19 07:34:17', 1),
(174, '179.216.171.104', '2014-05-19 07:35:14', 1),
(175, '179.216.171.104', '2014-05-19 07:35:24', 1),
(176, '179.216.171.104', '2014-05-19 07:35:35', 1),
(177, '179.216.171.104', '2014-05-19 07:35:54', 1),
(178, '179.216.171.104', '2014-05-19 07:36:13', 1);

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=12 ;

--
-- Extraindo dados da tabela `network`
--

INSERT INTO `network` (`idnetwork`, `facebook`, `country`, `whatsapp`, `viber`, `skype`, `linkedin`, `microsoft`, `serial`, `google`) VALUES
(5, 'malacma@hotmail.com', 'BR', 'WhatsApp', ' 554896004929', 'luisaugustomachadomoretto', 'malacma@gmail.com', 'malacma@hotmail.com', '89550440000343042053', 'malacma@gmail.com'),
(10, 'deboracrysty', 'BR', 'WhatsApp', '', 'deboracrysty@hotmail.com', 'Finance', '', '89550440000337113860', 'debora.crysty87@gmail.com'),
(11, '', 'US', '', '', '', '', '', '89111427014731456112', 'henry.gingerrich@gmail.com');

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=195 ;

--
-- Extraindo dados da tabela `profile`
--

INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(1, 'MORETTO LAMM', 'malacma@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2010-01-01', '10e13a1c-2c5a-46d2-9e37-d4199011581e', 973.666, 2, 7, 5, 142, 0),
(138, 'MARCINHO VP', 'marcio@gmail.com', '76d80224611fc919a5d54f0ff9fba446', 1, 1, '2020-10-11', 'f0eae5e7-3ad4-4370-8c68-89200600a234', 0, 1, 1, 1, 1, 0),
(139, 'MARCINHO', 'jj@mail.com', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2013-10-11', 'a83dbbe1-c5b3-411f-9919-c2097af9c111', 1127, 2, 1, 3, 82, 0),
(142, 'ARTHUR', 'arthur123@gmail.com', '4eae18cf9e54a0f62b44176d074cbe2f', 0, 0, '2016-02-15', '242a4389-a2c3-47e2-a83f-981d604e41de', 0, 2, 1, 3, 1, 0),
(143, 'AVAI', 'avai@avai.com.br', '43ffce0e8192a15d42bebe855683ac19', 1, 1, '2014-10-18', 'acf9c5f7-22af-47fb-89ef-a3843da1e41b', 0, 1, 1, 1, 1, 0),
(144, 'MEME', 'malacma@gmail.com.net', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-12-22', 'c55e9eb4-1606-44a2-ae21-fdf4679e72ce', 0, 1, 1, 1, 33, 0),
(145, 'SENIOR', 'malacma@gmail.com.cc', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '1999-02-06', '08cbf1a6-c069-4234-b1ec-0f3fc12b00e2', 0, 1, 1, 1, 1, 0),
(146, 'NN SENIOE', 'malacma@gmail.com.nn', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '1978-04-29', 'dba97a9c-fba8-4b9a-badb-206d0e64db21', 0, 1, 4, 1, 46, 0),
(147, 'FR VAI SE FUDER', 'malacma@gmail.com.jp', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-06', '4ea64023-635b-4c20-abe5-1c3cd6cc9e88', 1, 2, 1, 4, 102, 0),
(148, 'CHINA IN BOX', 'malacma@gmail.com.ch', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2006-06-08', '84a1549a-2b36-4e34-8494-8bbef06a9b47', 6, 2, 4, 4, 58, 0),
(149, 'ARTHUR', 'arthur@labirinto.com.br', '22d2eab6a3b79cfced78a8028f59f6b3', 1, 1, '0000-00-00', 'd5a1172c-c0d4-4ccb-aac0-456db3187a12', 0, 1, 1, 1, 1, 0),
(150, 'ARTHIR', 'arthur@inteligenis.com.br', '76d80224611fc919a5d54f0ff9fba446', 1, 1, '0000-00-00', 'b06d8785-8d7f-4e20-9cc6-4320dbe23806', 0, 1, 1, 1, 1, 0),
(187, 'CH', 'n@m.com.ch', '7694f4a66316e53c8cdd9d9954bd611d', 1, 1, '2015-01-11', '98c8ecec-66a4-4e5d-9ab4-63bfe30f5848', 0, 2, 6, 7, 110, 0),
(188, 'JK', 'malacma@gmail.com.jk', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2015-01-12', '4fd27d9f-8cac-467c-9133-1041f41bb796', 0, 2, 5, 8, 1, 0),
(189, 'RURU', 'malacma@gmail.com.rur', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2013-11-12', '97c0edc6-7549-469d-b4a8-2bfc63dfb7a7', 0, 1, 1, 1, 1, 0),
(190, 'RARA', 'malacma@gmail.com.rara', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2015-02-12', 'ac93fdb5-3ab4-48bb-9123-7cf220791f5d', 0, 1, 5, 1, 1, 0),
(191, 'RERR', 'malacma@gmail.com.rere', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-12', '84cd99b0-12bc-4258-bc94-8e257bd60e96', 0, 1, 6, 1, 1, 0),
(192, 'ROP', 'malacma@gmail.com.rop', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-12', '904c098c-585e-415f-9703-c2c255812e56', 0, 1, 3, 1, 1, 0),
(193, 'FRF', 'malacma@gmail.com.frf', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2015-02-12', '95319917-4929-4c92-a317-0787d1648003', 0, 1, 1, 1, 1, 0),
(194, 'MAMMAM', 'malacma@gmail.com.mbr', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2015-02-14', 'f59e60e9-6774-4047-b792-136dfd9fe06a', 0, 1, 1, 1, 1, 0);

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Extraindo dados da tabela `purchase`
--

INSERT INTO `purchase` (`id`, `invoice`, `trasaction_id`, `log_id`, `user_id`, `product_id`, `product_name`, `product_quantity`, `product_amount`, `payer_fname`, `payer_lname`, `payer_address`, `payer_city`, `payer_state`, `payer_zip`, `payer_country`, `payer_email`, `payment_status`, `posted_date`) VALUES
(3, '2056278172', '', NULL, 1, '1', 'Babel2u Coins', '1', '5', 'MORETTO LAMM', 'MORETTO LAMM', '', '', '', '', '', 'malacma@gmail.com', 'pending', '2014-05-12 20:56:34');

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=6 ;

--
-- Extraindo dados da tabela `service_type`
--

INSERT INTO `service_type` (`idservice_type`, `description`) VALUES
(1, 'SECURITY'),
(2, 'HEALTHCARE'),
(3, 'DEFAULT'),
(4, 'TOURISM'),
(5, 'SHOP');

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=8 ;

--
-- Extraindo dados da tabela `sip_user`
--

INSERT INTO `sip_user` (`idsip_user`, `user`, `pass`, `profile_id_user`, `sip_server_idsip_server`) VALUES
(1, 'tradutoringles', '36w74nsE', 139, 1),
(2, 'CS00016926', '25h34bgQ', 148, 2),
(3, 'CS00016927', '19d61reT', 194, 2),
(4, 'CS00016928', '74c46toG', 149, 2),
(5, 'user_pt_bt', 'user_pt_bt', 147, 1),
(6, 'translator_pt_en', 'translator_pt_en', 150, 1),
(7, 'ekooossss', 'ekooossss', 1, 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_call_info`
--
CREATE TABLE IF NOT EXISTS `view_call_info` (
`end_t` timestamp
,`start_t` timestamp
,`id_from` bigint(11)
,`id_to` bigint(11)
,`credits_user` double
,`credits_translator` double
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_profile`
--
CREATE TABLE IF NOT EXISTS `view_profile` (
`id_user` int(11)
,`name` varchar(200)
,`email` varchar(200)
,`passwd` varchar(240)
,`online` tinyint(1)
,`avaliable` tinyint(1)
,`birthday` date
,`paypall_acc` varchar(200)
,`credits` float
,`fk_id_role` int(11)
,`nature` int(11)
,`proficiency` int(11)
,`avatar_idavatar` int(11)
,`qualified` tinyint(1)
,`user` varchar(100)
,`pass` varchar(45)
,`servername` varchar(200)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_profile_by_last_ip`
--
CREATE TABLE IF NOT EXISTS `view_profile_by_last_ip` (
`email` varchar(200)
,`online` tinyint(1)
,`ip` varchar(45)
,`image_path` varchar(500)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_profile_count`
--
CREATE TABLE IF NOT EXISTS `view_profile_count` (
`passwd` varchar(240)
,`total` bigint(21)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_profile_sip_acc`
--
CREATE TABLE IF NOT EXISTS `view_profile_sip_acc` (
`id_user` int(11)
,`name` varchar(200)
,`user` varchar(100)
,`pass` varchar(45)
,`servername` varchar(200)
,`email` varchar(200)
,`passwd` varchar(240)
,`nature` int(11)
,`proficiency` int(11)
,`fk_id_role` int(11)
,`online` tinyint(1)
,`avaliable` tinyint(1)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_profile_tomaps`
--
CREATE TABLE IF NOT EXISTS `view_profile_tomaps` (
`calls` bigint(21)
,`image` varchar(500)
,`ip` varchar(45)
,`logins` bigint(21)
,`role_name` varchar(20)
,`my_nature` varchar(45)
,`my_proficiency` varchar(45)
,`name` varchar(200)
,`email` varchar(200)
,`online` tinyint(1)
,`birthday` date
,`credits` float
,`user` varchar(100)
,`pass` varchar(45)
);
-- --------------------------------------------------------

--
-- Structure for view `view_call_info`
--
DROP TABLE IF EXISTS `view_call_info`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_call_info` AS select `a`.`end_t` AS `end_t`,`a`.`start_t` AS `start_t`,(select `c`.`id_user` from `profile` `c` where (`c`.`id_user` = `a`.`from_c`)) AS `id_from`,(select `c`.`id_user` from `profile` `c` where (`c`.`id_user` = `a`.`to_c`)) AS `id_to`,(select `c`.`credits` from `profile` `c` where (`c`.`id_user` = `a`.`from_c`)) AS `credits_user`,(select `c`.`credits` from `profile` `c` where (`c`.`id_user` = `a`.`to_c`)) AS `credits_translator` from `call` `a`;

-- --------------------------------------------------------

--
-- Structure for view `view_profile`
--
DROP TABLE IF EXISTS `view_profile`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_profile` AS select `A`.`id_user` AS `id_user`,`A`.`name` AS `name`,`A`.`email` AS `email`,`A`.`passwd` AS `passwd`,`A`.`online` AS `online`,`A`.`avaliable` AS `avaliable`,`A`.`birthday` AS `birthday`,`A`.`paypall_acc` AS `paypall_acc`,`A`.`credits` AS `credits`,`A`.`fk_id_role` AS `fk_id_role`,`A`.`nature` AS `nature`,`A`.`proficiency` AS `proficiency`,`A`.`avatar_idavatar` AS `avatar_idavatar`,`A`.`qualified` AS `qualified`,`B`.`user` AS `user`,`B`.`pass` AS `pass`,`C`.`servername` AS `servername` from ((`profile` `A` left join `sip_user` `B` on((`A`.`id_user` = `B`.`profile_id_user`))) left join `sip_server` `C` on((`B`.`sip_server_idsip_server` = `C`.`idsip_server`)));

-- --------------------------------------------------------

--
-- Structure for view `view_profile_by_last_ip`
--
DROP TABLE IF EXISTS `view_profile_by_last_ip`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_profile_by_last_ip` AS select ucase(`a1`.`email`) AS `email`,`a1`.`online` AS `online`,`a2`.`ip` AS `ip`,`a3`.`image_path` AS `image_path` from ((`profile` `a1` join `log` `a2` on((`a1`.`id_user` = `a2`.`id_user`))) left join `avatar` `a3` on((`a3`.`idavatar` = `a1`.`avatar_idavatar`))) group by `a1`.`email` order by `a2`.`idlog` desc;

-- --------------------------------------------------------

--
-- Structure for view `view_profile_count`
--
DROP TABLE IF EXISTS `view_profile_count`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_profile_count` AS select `profile`.`passwd` AS `passwd`,count(0) AS `total` from `profile`;

-- --------------------------------------------------------

--
-- Structure for view `view_profile_sip_acc`
--
DROP TABLE IF EXISTS `view_profile_sip_acc`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_profile_sip_acc` AS select `a`.`id_user` AS `id_user`,`a`.`name` AS `name`,`b`.`user` AS `user`,`b`.`pass` AS `pass`,`c`.`servername` AS `servername`,`a`.`email` AS `email`,`a`.`passwd` AS `passwd`,`a`.`nature` AS `nature`,`a`.`proficiency` AS `proficiency`,`a`.`fk_id_role` AS `fk_id_role`,`a`.`online` AS `online`,`a`.`avaliable` AS `avaliable` from ((`profile` `a` left join `sip_user` `b` on((`a`.`id_user` = `b`.`profile_id_user`))) left join `sip_server` `c` on((`b`.`sip_server_idsip_server` = `c`.`idsip_server`)));

-- --------------------------------------------------------

--
-- Structure for view `view_profile_tomaps`
--
DROP TABLE IF EXISTS `view_profile_tomaps`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_profile_tomaps` AS select (select count(0) from `call` `cc` where ((`cc`.`from_c` = `a`.`id_user`) or (`cc`.`to_c` = `a`.`id_user`))) AS `calls`,(select `avatar`.`image_path` from `avatar` where (`avatar`.`idavatar` = `a`.`avatar_idavatar`)) AS `image`,(select `ll`.`ip` from `log` `ll` where (`ll`.`id_user` = `a`.`id_user`) order by `ll`.`date` desc limit 1) AS `ip`,(select count(`ll`.`ip`) from `log` `ll` where (`ll`.`id_user` = `a`.`id_user`) order by `ll`.`date` desc limit 1) AS `logins`,`d`.`role_name` AS `role_name`,`b`.`description` AS `my_nature`,`c`.`description` AS `my_proficiency`,`a`.`name` AS `name`,`a`.`email` AS `email`,`a`.`online` AS `online`,`a`.`birthday` AS `birthday`,`a`.`credits` AS `credits`,`a`.`user` AS `user`,`a`.`pass` AS `pass` from (((`view_profile` `a` left join `language` `b` on((`a`.`nature` = `b`.`id_lang`))) left join `language` `c` on((`a`.`proficiency` = `c`.`id_lang`))) left join `role` `d` on((`d`.`id_role` = `a`.`fk_id_role`)));

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
-- Limitadores para a tabela `evaluation`
--
ALTER TABLE `evaluation`
  ADD CONSTRAINT `fk_evaluation_profile` FOREIGN KEY (`profile_id_translator`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_evaluation_profile1` FOREIGN KEY (`profile_id_user`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limitadores para a tabela `log`
--
ALTER TABLE `log`
  ADD CONSTRAINT `fk_log_profile` FOREIGN KEY (`id_user`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

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
