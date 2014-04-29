-- phpMyAdmin SQL Dump
-- version 3.3.3
-- http://www.phpmyadmin.net
--
-- Servidor: mysql03-farm13.kinghost.net
-- Tempo de GeraÃ§Ã£o: Mar 09, 2014 as 01:39 AM
-- VersÃ£o do Servidor: 5.5.29
-- VersÃ£o do PHP: 5.2.17

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
  `image_path` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`idavatar`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- Extraindo dados da tabela `avatar`
--

INSERT INTO `avatar` (`idavatar`, `image_path`) VALUES
(1, 'null.png');

-- --------------------------------------------------------

--
-- Estrutura da tabela `call`
--

CREATE TABLE IF NOT EXISTS `call` (
  `id_call` int(11) NOT NULL AUTO_INCREMENT,
  `start_t` bigint(40) DEFAULT NULL,
  `end_t` bigint(40) DEFAULT NULL,
  `from_c` int(11) NOT NULL,
  `to_c` int(11) NOT NULL,
  `service_type_idservice_type` int(11) NOT NULL,
  `token` varchar(220) CHARACTER SET latin5 COLLATE latin5_bin NOT NULL COMMENT 'token da chamada',
  PRIMARY KEY (`id_call`,`from_c`,`to_c`),
  UNIQUE KEY `token` (`token`),
  KEY `fk_call_user_profile1_idx` (`from_c`),
  KEY `fk_call_user_profile2_idx` (`to_c`),
  KEY `fk_call_service_type1_idx` (`service_type_idservice_type`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=171 ;

--
-- Extraindo dados da tabela `call`
--

INSERT INTO `call` (`id_call`, `start_t`, `end_t`, `from_c`, `to_c`, `service_type_idservice_type`, `token`) VALUES


-- --------------------------------------------------------

--
-- Estrutura da tabela `language`
--

CREATE TABLE IF NOT EXISTS `language` (
  `id_lang` int(11) NOT NULL,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`id_lang`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `language`
--

INSERT INTO `language` (`id_lang`, `description`) VALUES
(1, 'Portuguese'),
(2, 'ENGLISH'),
(3, 'GERMANY');

-- --------------------------------------------------------

--
-- Estrutura da tabela `profile`
--

CREATE TABLE IF NOT EXISTS `profile` (
  `id_user` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `email` varchar(200) NOT NULL,
  `passwd` varchar(10) DEFAULT NULL,
  `online` tinyint(1) DEFAULT NULL,
  `avaliable` tinyint(1) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `paypall_acc` varchar(200) DEFAULT NULL,
  `credits` float NOT NULL,
  `fk_id_role` int(11) NOT NULL,
  `nature` int(11) NOT NULL,
  `proficiency` int(11) DEFAULT NULL,
  `avatar_idavatar` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  UNIQUE KEY `paypall_acc_UNIQUE` (`paypall_acc`),
  KEY `fk_user_profile_Role_idx` (`fk_id_role`),
  KEY `fk_user_profile_language1_idx` (`nature`),
  KEY `fk_user_profile_language2_idx` (`proficiency`),
  KEY `fk_profile_avatar1_idx` (`avatar_idavatar`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=47 ;

--
-- Extraindo dados da tabela `profile`
--

INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`) VALUES
(1, 'Alejandro Martines', 'malacma@gmail.com', '123123', 0, 0, '2010-01-01', '12223kkjj12', 0, 1, 1, 2, 1),
(2, 'George Martins', 'george.martins@gmail.com', '123456', 0, 0, '2014-08-05', 'xxaa123123', 1, 2, 2, 1, 1),
(3, 'Rogerio Bastos', 'rgermail@mail.com', '123456', 0, 0, '2014-03-10', 'X1ss123', 123, 1, 1, NULL, 1),
(25, 'Alejandro Martines', 'daone@gmail.com', '123123', 0, 0, '2010-01-01', '123kkjj12', 0, 1, 1, 2, 1),
(27, 'Alejandro Martines', 'dao2ne@gmail.com', '123123', 0, 0, '2082-01-01', '12s223kkjj12', 0, 1, 1, 2, 1),
(29, 'Alejandro Martines', 'da2o2ne@gmail.com', '123123', 0, 0, '2010-01-01', '1232223kkjj12', 0, 1, 1, 2, 1),
(30, 'Alejandro Martines', 'da22o2ne@gmail.com', '123123', 0, 0, '2010-01-01', '123211223kkjj12', 0, 1, 1, 2, 1),
(31, 'Karla Simas', 'kakacine@gmail.com', '123123', 0, 0, '2010-01-01', 'KRAK122ACINE', 0, 2, 2, 1, 1),
(38, 'Tradutor Germany English', 'translator@gmaisl.com', '123123', 1, 1, '1982-01-01', 'KRAaaaaaa122aACINE', 0, 2, 2, 3, 1),
(42, 'Tradutor Portugues Ingles', 'translator@gmaiaa.com', '123123', 1, 1, '1982-11-01', 'KRAasaaaaaa122aACINE', 0, 2, 1, 2, 1);

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
  `profile_id_user` int(11) NOT NULL,
  `sip_server_idsip_server` int(11) NOT NULL,
  PRIMARY KEY (`idsip_user`),
  KEY `fk_sip_user_profile1_idx` (`profile_id_user`),
  KEY `fk_sip_user_sip_server1_idx` (`sip_server_idsip_server`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=13 ;

--
-- Extraindo dados da tabela `sip_user`
--

INSERT INTO `sip_user` (`idsip_user`, `user`, `pass`, `profile_id_user`, `sip_server_idsip_server`) VALUES
(1, 'turistacopa1', 'turismcup1', 1, 1),
(2, 'tradutoringles', 'translate1', 2, 1),
(12, 'tradutoralemao', '123456', 38, 1);

--
-- RestriÃ§Ãµes para as tabelas dumpadas
--

--
-- RestriÃ§Ãµes para a tabela `call`
--
ALTER TABLE `call`
  ADD CONSTRAINT `fk_call_service_type1` FOREIGN KEY (`service_type_idservice_type`) REFERENCES `service_type` (`idservice_type`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_call_user_profile1` FOREIGN KEY (`from_c`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_call_user_profile2` FOREIGN KEY (`to_c`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- RestriÃ§Ãµes para a tabela `profile`
--
ALTER TABLE `profile`
  ADD CONSTRAINT `fk_profile_avatar1` FOREIGN KEY (`avatar_idavatar`) REFERENCES `avatar` (`idavatar`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_language1` FOREIGN KEY (`nature`) REFERENCES `language` (`id_lang`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_language2` FOREIGN KEY (`proficiency`) REFERENCES `language` (`id_lang`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_user_profile_Role` FOREIGN KEY (`fk_id_role`) REFERENCES `role` (`id_role`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- RestriÃ§Ãµes para a tabela `sip_user`
--
ALTER TABLE `sip_user`
  ADD CONSTRAINT `fk_sip_user_profile1` FOREIGN KEY (`profile_id_user`) REFERENCES `profile` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_sip_user_sip_server1` FOREIGN KEY (`sip_server_idsip_server`) REFERENCES `sip_server` (`idsip_server`) ON DELETE NO ACTION ON UPDATE NO ACTION;
