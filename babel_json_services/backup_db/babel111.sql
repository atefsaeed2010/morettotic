-- phpMyAdmin SQL Dump
-- version 4.1.8
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 12-Maio-2014 às 03:11
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
CREATE DATABASE IF NOT EXISTS `seenergi_babel` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `seenergi_babel`;

DELIMITER $$
--
-- Functions
--
DROP FUNCTION IF EXISTS `fn_add_credits`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_add_credits`(`p_invoice` VARCHAR(255), `p_credits` FLOAT) RETURNS float
BEGIN
DECLARE my_credits FLOAT;
update profile as a1 set a1.credits=(a1.credits+p_credits) where id_user = (select user_id from purchase where invoice = p_invoice);

SELECT credits into my_credits FROM `profile` WHERE id_user = (select user_id from purchase where invoice = p_invoice);

RETURN my_credits;
END$$

DROP FUNCTION IF EXISTS `fn_get_avatar`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_get_avatar`(`p_id_user` INT) RETURNS varchar(300) CHARSET latin1
BEGIN
DECLARE my_avatar VARCHAR(300);

SELECT image_path into my_avatar from avatar where idavatar = (select avatar_idavatar from profile where id_user = p_id_user);

RETURN my_avatar;
END$$

DROP FUNCTION IF EXISTS `fn_login`$$
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

DROP FUNCTION IF EXISTS `fn_sipacc`$$
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

DROP TABLE IF EXISTS `avatar`;
CREATE TABLE IF NOT EXISTS `avatar` (
  `idavatar` int(11) NOT NULL AUTO_INCREMENT,
  `image_path` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idavatar`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=111 ;

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
(110, '1399081831195.jpg');

-- --------------------------------------------------------

--
-- Estrutura da tabela `call`
--

DROP TABLE IF EXISTS `call`;
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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=799 ;

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
(798, '2014-05-12 03:52:56', '2014-05-12 03:52:56', 1, 148, 3, '67755f14f8091afb2681dc1e770039ca');

-- --------------------------------------------------------

--
-- Estrutura da tabela `language`
--

DROP TABLE IF EXISTS `language`;
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

DROP TABLE IF EXISTS `log`;
CREATE TABLE IF NOT EXISTS `log` (
  `idlog` int(11) NOT NULL AUTO_INCREMENT,
  `ip` varchar(45) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `id_user` int(11) NOT NULL,
  PRIMARY KEY (`idlog`),
  KEY `fk_log_profile_idx` (`id_user`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=29 ;

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
(28, '186.222.60.227', '2014-05-12 04:46:50', 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `network`
--

DROP TABLE IF EXISTS `network`;
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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=16 ;

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
(13, 'malacma@hotmail.com', 'BR', 'WhatsApp', ' 554896004929', 'luisaugustomachadomoretto', 'malacma@gmail.com', 'malacma@hotmail.com', '89550440000343042053', 'malacma@gmail.com'),
(14, 'malacma@hotmail.com', 'BR', 'WhatsApp', ' 554896004929', 'luisaugustomachadomoretto', 'malacma@gmail.com', 'malacma@hotmail.com', '89550440000343042053', 'malacma@gmail.com'),
(15, 'malacma@hotmail.com', 'BR', 'WhatsApp', ' 554896004929', 'luisaugustomachadomoretto', 'malacma@gmail.com', 'malacma@hotmail.com', '89550440000343042053', 'malacma@gmail.com');

-- --------------------------------------------------------

--
-- Estrutura da tabela `paypal_log`
--

DROP TABLE IF EXISTS `paypal_log`;
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

DROP TABLE IF EXISTS `profile`;
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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=190 ;

--
-- Extraindo dados da tabela `profile`
--

INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(1, 'MORETTO LAMM', 'malacma@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2010-01-01', '71618013-4043-4f0e-b601-e8d269050b20', -1092, 2, 8, 3, 104, 0),
(138, 'MARCINHO VP', 'marcio@gmail.com', '76d80224611fc919a5d54f0ff9fba446', 1, 1, '2020-10-11', 'f0eae5e7-3ad4-4370-8c68-89200600a234', 0, 1, 1, 1, 1, 0),
(139, 'MARCINHO', 'jj@mail.com', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2013-10-11', 'a83dbbe1-c5b3-411f-9919-c2097af9c111', 1107, 2, 1, 3, 82, 0),
(142, 'ARTHUR', 'arthur123@gmail.com', '4eae18cf9e54a0f62b44176d074cbe2f', 0, 0, '2016-02-15', '242a4389-a2c3-47e2-a83f-981d604e41de', 0, 2, 1, 3, 1, 0),
(143, 'AVAI', 'avai@avai.com.br', '43ffce0e8192a15d42bebe855683ac19', 1, 1, '2014-10-18', 'acf9c5f7-22af-47fb-89ef-a3843da1e41b', 0, 1, 1, 1, 1, 0),
(144, 'MEME', 'malacma@gmail.com.net', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-12-22', 'c55e9eb4-1606-44a2-ae21-fdf4679e72ce', 0, 1, 1, 1, 33, 0),
(145, 'SENIOR', 'malacma@gmail.com.cc', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '1999-02-06', '08cbf1a6-c069-4234-b1ec-0f3fc12b00e2', 0, 1, 1, 1, 1, 0),
(146, 'NN SENIOE', 'malacma@gmail.com.nn', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '1978-04-29', 'dba97a9c-fba8-4b9a-badb-206d0e64db21', 0, 1, 4, 1, 46, 0),
(147, 'FR VAI SE FUDER', 'malacma@gmail.com.jp', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-06', '4ea64023-635b-4c20-abe5-1c3cd6cc9e88', 0, 2, 1, 4, 102, 0),
(148, 'CHINA IN BOX', 'malacma@gmail.com.ch', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2006-06-08', '84a1549a-2b36-4e34-8494-8bbef06a9b47', 0, 2, 4, 4, 58, 0),
(149, 'ARTHUR', 'arthur@labirinto.com.br', '22d2eab6a3b79cfced78a8028f59f6b3', 1, 1, '0000-00-00', 'd5a1172c-c0d4-4ccb-aac0-456db3187a12', 0, 1, 1, 1, 1, 0),
(150, 'ARTHIR', 'arthur@inteligenis.com.br', '76d80224611fc919a5d54f0ff9fba446', 1, 1, '0000-00-00', 'b06d8785-8d7f-4e20-9cc6-4320dbe23806', 0, 1, 1, 1, 1, 0),
(187, 'CH', 'n@m.com.ch', '7694f4a66316e53c8cdd9d9954bd611d', 1, 1, '2015-01-11', '98c8ecec-66a4-4e5d-9ab4-63bfe30f5848', 0, 2, 6, 7, 110, 0),
(188, 'JK', 'malacma@gmail.com.jk', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2015-01-12', '4fd27d9f-8cac-467c-9133-1041f41bb796', 0, 2, 5, 8, 1, 0),
(189, 'RURU', 'malacma@gmail.com.rur', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2013-11-12', '97c0edc6-7549-469d-b4a8-2bfc63dfb7a7', 0, 1, 1, 1, 1, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `purchase`
--

DROP TABLE IF EXISTS `purchase`;
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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `role`
--

DROP TABLE IF EXISTS `role`;
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

DROP TABLE IF EXISTS `service_type`;
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

DROP TABLE IF EXISTS `sip_server`;
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

DROP TABLE IF EXISTS `sip_user`;
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
(1, 'tradutoringles', '36w74nsE', 145, 1),
(2, 'CS00016926', '25h34bgQ', 148, 2),
(3, 'CS00016927', '19d61reT', 1, 2),
(4, 'CS00016928', '74c46toG', 149, 2),
(5, 'user_pt_bt', 'user_pt_bt', 147, 1),
(6, 'translator_pt_en', 'translator_pt_en', 150, 1),
(7, 'ekooossss', 'ekooossss', 189, 1);

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
