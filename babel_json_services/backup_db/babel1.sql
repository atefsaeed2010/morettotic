-- phpMyAdmin SQL Dump
-- version 3.3.3
-- http://www.phpmyadmin.net
--
-- Servidor: mysql03-farm13.kinghost.net
-- Tempo de Geração: Abr 07, 2014 as 01:20 AM
-- Versão do Servidor: 5.5.29
-- Versão do PHP: 5.2.17

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Banco de Dados: `nosnaldeia01`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `avatar`
--

CREATE TABLE IF NOT EXISTS `avatar` (
  `idavatar` int(11) NOT NULL AUTO_INCREMENT,
  `image_path` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`idavatar`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=29 ;

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
(28, 'resized_IMG_20140404_210310.jpg');

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=344 ;

--
-- Extraindo dados da tabela `call`
--

INSERT INTO `call` (`id_call`, `start_t`, `end_t`, `from_c`, `to_c`, `service_type_idservice_type`, `token`) VALUES
(212, '2014-03-19 23:19:47', '2014-03-19 23:19:47', 1, 106, 3, '0f141c25df3e45cb268b7a21205e2bd1'),
(213, '2014-03-19 23:21:47', '2014-03-19 23:21:47', 1, 106, 3, '9aefded3962eb707b5a2fb77d26cbd1e'),
(217, '2014-04-03 05:41:57', '2014-04-03 05:41:57', 1, 106, 3, 'a672c39f2434aa43ca27a6c3b638791a'),
(218, '2014-04-03 05:57:04', '2014-04-03 05:57:04', 1, 106, 3, '51df482992fb377cfc0d4de1f2276a23'),
(220, '2014-04-03 05:59:59', '2014-04-03 05:59:59', 1, 107, 3, '114736504df2e11309af634e36d5203c'),
(227, '2014-04-03 06:00:44', '2014-04-03 06:00:44', 1, 112, 3, '33137bd89397919f169c7ee31019c67a'),
(228, '2014-04-03 06:02:14', '2014-04-03 06:02:14', 1, 116, 3, '6aa2bf07990f1bc0ebabb269e990c7fb'),
(235, '2014-04-03 06:03:19', '2014-04-03 06:03:19', 1, 1, 3, 'aa283a5b60b768c602f0de04a9ba044b'),
(236, '2014-04-03 06:03:33', '2014-04-03 06:03:33', 1, 113, 3, '25a55900a134d17ff43a3145f9dfcf51'),
(237, '2014-04-03 06:04:14', '2014-04-03 06:04:14', 1, 113, 3, '694478bceab39d31db234a168e096487'),
(238, '2014-04-03 06:04:23', '2014-04-03 06:04:23', 1, 112, 3, '48b29818f5509bf7d1d93f694abe1d32'),
(239, '2014-04-03 06:04:30', '2014-04-03 06:04:30', 1, 116, 3, '0adf306dfeeb915bde561bea10866e36'),
(247, '2014-04-03 06:05:32', '2014-04-03 06:05:32', 1, 113, 3, '374a1355e3bfd06c9ef9ef5cf7a09075'),
(250, '2014-04-03 06:05:41', '2014-04-03 06:05:41', 1, 112, 3, '7ac768c67245e9276254dff2e997ae64'),
(251, '2014-04-03 06:05:44', '2014-04-03 06:05:44', 1, 116, 3, 'dd50048ce60d96e1b40b4213fb4edcd0'),
(257, '2014-04-03 06:07:02', '2014-04-03 06:07:02', 1, 1, 3, 'c0d634f8c16b4a66772cc129415ccb95'),
(258, '2014-04-03 06:07:11', '2014-04-03 06:07:11', 1, 112, 3, '0af2809027a03018a8daa3ef2a0d804d'),
(259, '2014-04-03 06:08:30', '2014-04-03 06:08:30', 1, 112, 3, '9a0158c0249f9899581d528a77efe86c'),
(261, '2014-04-03 06:08:39', '2014-04-03 06:08:39', 1, 116, 3, '7040bb7f3a462b9e38862b33b09aee9b'),
(262, '2014-04-03 06:08:43', '2014-04-03 06:08:43', 1, 113, 3, '681be10361c51e0c953a5d9a11c6229d'),
(281, '2014-04-03 07:13:29', '2014-04-03 07:13:29', 1, 112, 3, '720292544a3864b8f3b5792f56ea2885'),
(282, '2014-04-03 07:14:53', '2014-04-03 07:14:53', 1, 116, 3, 'a08a321413f667d2e9b57dfd6698adce'),
(290, '2014-04-03 07:20:07', '2014-04-03 07:20:07', 1, 112, 3, '25cb401637a3740c5ac160dc130f7121'),
(291, '2014-04-03 07:20:31', '2014-04-03 07:20:31', 1, 116, 3, '9d0808787edcfa4d2e2a8630daba2178'),
(293, '2014-04-03 07:20:40', '2014-04-03 07:20:40', 1, 112, 3, '59fbd2b94817035ad3f56c40920d7390'),
(299, '2014-04-03 07:28:20', '2014-04-03 07:28:20', 1, 113, 3, '0252d96199486757148e84135d7bc00e'),
(302, '2014-04-03 07:29:21', '2014-04-03 07:29:21', 1, 113, 3, '1b6c6f894b8241419aba22af8a096dc7'),
(304, '2014-04-03 07:31:29', '2014-04-03 07:31:29', 1, 112, 3, '505027131d71625ee8bf2f54d71799f8'),
(305, '2014-04-03 07:31:32', '2014-04-03 07:31:32', 1, 116, 3, '064275ecd6e4ffc52b9bff806cd9e5de'),
(307, '2014-04-03 07:31:47', '2014-04-03 07:31:47', 1, 112, 3, '177884035091ef5863011811f0714bfc'),
(308, '2014-04-03 07:37:45', '2014-04-03 07:37:45', 1, 112, 3, 'c265f14dd32b657a0c7699f97dd6bdef'),
(309, '2014-04-03 07:47:48', '2014-04-03 07:47:48', 1, 112, 3, '203b1dfa3492b1a2e5b8cd5c2d8b3812'),
(310, '2014-04-03 07:50:04', '2014-04-03 07:50:04', 1, 112, 3, '0bfc5c67549790cb7db492fc76f7ded1'),
(311, '2014-04-03 08:36:05', '2014-04-03 08:36:05', 1, 112, 3, '8d2371845a292b3d4558c720aca594be'),
(312, '2014-04-03 08:37:55', '2014-04-03 08:37:55', 1, 116, 3, 'c1fdb69a44261641aad233f18734e357'),
(331, '2014-04-05 19:45:14', '2014-04-05 19:45:14', 1, 112, 3, 'a46be626638c97eb72d9740a1bde02ee'),
(332, '2014-04-05 19:45:51', '2014-04-05 19:45:51', 1, 116, 3, '35ed1251e74395c569c352f7e362e2ab'),
(333, '2014-04-05 20:07:02', '2014-04-05 20:07:02', 1, 134, 3, 'a9e7269f5d8bb6f60e3cbe9a954879dd'),
(335, '2014-04-05 20:07:43', '2014-04-05 20:07:43', 1, 112, 3, '61d8c874680b7e9c981289b90a72e269'),
(341, '2014-04-05 20:31:15', '2014-04-05 20:31:15', 1, 112, 3, '124c3adfd5758c3274ec0fb20123a0cb'),
(342, '2014-04-05 20:33:32', '2014-04-05 20:33:32', 1, 116, 3, 'ed9dc83b3e82eab300f90ed3f7c51ec2'),
(343, '2014-04-05 20:36:45', '2014-04-05 20:36:45', 1, 134, 3, 'cce78fffc9972f77611208af858e465b');

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
-- Estrutura da tabela `paypal_log`
--

CREATE TABLE IF NOT EXISTS `paypal_log` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `txn_id` varchar(600) NOT NULL,
  `log` text NOT NULL,
  `posted_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `paypal_log`
--


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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=135 ;

--
-- Extraindo dados da tabela `profile`
--

INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(1, 'MORETTO LAMM', 'malacma@gmail.com', 'e10adc3949ba59abbe56e057f20f883e', 0, 1, '2015-02-01', 'JSJZJZJZJSJSJ', 296, 2, 2, 2, 28, 0),
(106, 'PTBR ENUS', 'malacma@mw.com', 'dc647eb65e6711e155375218212b3964', 1, 1, '2014-04-14', 'PAYBUNDA', 0, 2, 1, 4, 26, 0),
(107, 'VISITORJZJZJ', 'Email@mail.cccom', 'dc647eb65e6711e155375218212b3964', 1, 1, '2015-01-19', 'N-INSJSJSJ', 0, 2, 1, 4, 26, 0),
(108, 'VISITORJSJSJSJ', 'Email@nonono.com', 'dc647eb65e6711e155375218212b3964', 1, 1, '2014-12-19', 'N-INSNSJSJ', 0, 1, 4, 1, 26, 0),
(109, 'GUIME PIGUW', 'guime@gmail.com', 'dc647eb65e6711e155375218212b3964', 1, 1, '2006-12-24', 'NSJSJSJXNDNDNDNFKFJFJFK', 0, 1, 1, 1, 26, 0),
(110, 'EKIGAGADO', 'Email@ekikgado.com', 'dc647eb65e6711e155375218212b3964', 1, 1, '2014-11-21', 'JSHZNZJZJJS', 0, 1, 1, 1, 26, 0),
(111, 'TESTE', 'malacma@gnnn.com', 'dc647eb65e6711e155375218212b3964', 1, 1, '0000-00-00', 'JSJSKSKS', 0, 1, 1, 1, 26, 0),
(112, 'VISITOR', 'Email@m.com', 'dc647eb65e6711e155375218212b3964', 0, 1, '0000-00-00', 'N-I', 0, 2, 3, 2, 26, 0),
(113, 'MENPHIS', 'malacma@menphis.com', '74b87337454200d4d33f80c4663dc5e5', 1, 1, '2015-01-01', 'AAAAAA', 0, 2, 1, 3, 26, 0),
(115, 'NECO PADARATZ', 'malacma@gmail.com.br', '0cc175b9c0f1b6a831c399e269772661', 1, 1, '2015-01-01', 'N-INRCO', 0, 1, 3, 1, 26, 0),
(116, 'VISITOR', 'mMM@mamam.com', '2be0d0e84c354f20e279c6b83848f42b', 0, 1, '2014-12-03', 'N-INXNXJXJ', 0, 2, 3, 2, 26, 0),
(128, 'VISITOR', 'nene@mail.com', '8b30dfd4a3168f7954b95b6ff878fc3a', 1, 1, '0000-00-00', 'N-IJXJXJX', 0, 1, 3, 1, 26, 0),
(130, 'VISITOR', 'jzj@ma.xom', '41df5463c3367d1778147b28d4e4072f', 1, 1, '2015-01-03', 'JZJZJZJXJ', 0, 1, 3, 1, 26, 0),
(131, 'VISITOR', 'hshd@jsjd.com', '869d276513fec6444ceee4ca4f34bfbf', 1, 1, '2014-12-03', 'N-IHHHH', 0, 1, 3, 1, 26, 0),
(132, 'VARELA HOUSE MUSIC', 'varela@mamam.com', '9d1fa6b2aef720f78a0fb897af260d96', 1, 1, '2015-01-03', 'N-IJDJXJXJXJX', 0, 1, 3, 1, 26, 0),
(133, 'VDEVOL', 'meme@meme.com', 'dc647eb65e6711e155375218212b3964', 1, 1, '2015-01-03', 'NJSKDK', 0, 1, 3, 1, 1, 0),
(134, 'MEME', 'meme@email.com', 'e10adc3949ba59abbe56e057f20f883e', 0, 1, '1985-03-04', 'N-IJSJSJS', 0, 2, 2, 2, 27, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `purchase`
--

CREATE TABLE IF NOT EXISTS `purchase` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `invoice` varchar(300) NOT NULL,
  `trasaction_id` varchar(600) NOT NULL,
  `log_id` int(10) NOT NULL,
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
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `purchase`
--


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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Extraindo dados da tabela `sip_server`
--

INSERT INTO `sip_server` (`idsip_server`, `servername`) VALUES
(1, 'ekiga.net');

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Extraindo dados da tabela `sip_user`
--

INSERT INTO `sip_user` (`idsip_user`, `user`, `pass`, `profile_id_user`, `sip_server_idsip_server`) VALUES
(1, 'user_pt_bt', 'user_pt_bt', 1, 1);

--
-- Restrições para as tabelas dumpadas
--

--
-- Restrições para a tabela `call`
--
ALTER TABLE `call`
  ADD CONSTRAINT `fk_call_service_type1` FOREIGN KEY (`service_type_idservice_type`) REFERENCES `service_type` (`idservice_type`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_call_user_profile1` FOREIGN KEY (`from_c`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_call_user_profile2` FOREIGN KEY (`to_c`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Restrições para a tabela `profile`
--
ALTER TABLE `profile`
  ADD CONSTRAINT `fk_profile_avatar1` FOREIGN KEY (`avatar_idavatar`) REFERENCES `avatar` (`idavatar`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_language1` FOREIGN KEY (`nature`) REFERENCES `language` (`id_lang`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_language2` FOREIGN KEY (`proficiency`) REFERENCES `language` (`id_lang`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_Role` FOREIGN KEY (`fk_id_role`) REFERENCES `role` (`id_role`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Restrições para a tabela `sip_user`
--
ALTER TABLE `sip_user`
  ADD CONSTRAINT `fk_sip_user_profile1` FOREIGN KEY (`profile_id_user`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_sip_user_sip_server1` FOREIGN KEY (`sip_server_idsip_server`) REFERENCES `sip_server` (`idsip_server`) ON DELETE NO ACTION ON UPDATE NO ACTION;


ALTER TABLE `purchase`
  ADD CONSTRAINT `fk_paypall_user_profile1` FOREIGN KEY (`user_id`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_paypall_log_id` FOREIGN KEY (`log_id`) REFERENCES `paypal_log` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION