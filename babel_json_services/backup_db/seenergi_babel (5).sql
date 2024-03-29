-- phpMyAdmin SQL Dump
-- version 4.1.8
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 24-Jun-2014 às 04:57
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

DROP FUNCTION IF EXISTS `fn_change_pass`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_change_pass`(`pemail` VARCHAR(200), `psenha` VARCHAR(300)) RETURNS int(11)
    NO SQL
begin
update profile set passwd = psenha where email like pemail;
return 1;
end$$

DROP FUNCTION IF EXISTS `fn_get_avatar`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_get_avatar`(`p_id_user` INT) RETURNS varchar(300) CHARSET latin1
BEGIN
DECLARE my_avatar VARCHAR(300);

SELECT image_path into my_avatar from avatar where idavatar = (select avatar_idavatar from profile where id_user = p_id_user);

RETURN my_avatar;
END$$

DROP FUNCTION IF EXISTS `fn_log`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_log`(`my_id` INT(11), `p_ip` VARCHAR(255)) RETURNS int(11)
    NO SQL
BEGIN


DECLARE my_logid INT;


INSERT INTO `log`(idlog,ip,date,id_user)  VALUES(null,p_ip,now(),my_id);


RETURN -1;
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

DROP FUNCTION IF EXISTS `fn_offline`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_offline`(`p_id` INT(11)) RETURNS int(11)
    NO SQL
begin
UPDATE `profile` SET `online`= '0',`avaliable`='0' where id_user= p_id;
return 0;
end$$

DROP FUNCTION IF EXISTS `fn_online`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_online`(`p_id` INT(11)) RETURNS int(11)
    NO SQL
begin
update profile set online = true where id_user= p_id;

update profile set avaliable = true where id_user= p_id;
return 1;
end$$

DROP FUNCTION IF EXISTS `fn_rate_translator`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_rate_translator`(`id_user` INT(11), `id_trans` INT(11), `rate` FLOAT) RETURNS double
    NO SQL
BEGIN
DECLARE id_eval REAL;

INSERT INTO `evaluation`( `date`, `rate`, `profile_id_translator`, `profile_id_user`) VALUES (now(),rate,id_user,id_trans);

SELECT (sum(rate)/count(rate)) into id_eval FROM `evaluation` WHERE profile_id_translator = id_trans;

RETURN id_eval;
END$$

DROP FUNCTION IF EXISTS `fn_release_sip`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_release_sip`(`t1` INT) RETURNS int(11)
    NO SQL
begin

update sip_user set profile_id_user = null where profile_id_user not in (SELECT id_user FROM `view_find_away` where awayTime <t1 and  awayTime >0 group by id_user ORDER BY id_user desc);

return -1;

end$$

DROP FUNCTION IF EXISTS `fn_set_avatar`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_set_avatar`(`p_image` VARCHAR(300), `p_id_user` INT(11)) RETURNS int(11)
    NO SQL
BEGIN

DECLARE img_id INT(11);

INSERT INTO avatar (image_path) VALUES (p_image);

SELECT idavatar INTO img_id FROM avatar WHERE image_path = p_image;

UPDATE profile SET avatar_idavatar = img_id  WHERE id_user = p_id_user;

RETURN img_id;

END$$

DROP FUNCTION IF EXISTS `fn_set_busy`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_set_busy`(`p_user` INT(11), `p_trans` INT(11)) RETURNS int(11)
    NO SQL
begin

update profile set online = 1, avaliable = 0 where id_user in (p_trans,p_user);

return 1;
end$$

DROP FUNCTION IF EXISTS `fn_set_unavaliable`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_set_unavaliable`(`p_id_user` INT(11), `p_id_translator` INT(11)) RETURNS int(11)
    NO SQL
begin
update profile 
set online = true and avaliable = false where id_user= p_id_user;
update profile 
set online = true and avaliable = false where id_user= p_id_trans;
return -1;

end$$

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

DROP FUNCTION IF EXISTS `fn_update_sip`$$
CREATE DEFINER=`seenergi`@`localhost` FUNCTION `fn_update_sip`(`id_user` INT(11)) RETURNS int(11)
    NO SQL
BEGIN

DECLARE my_id INT;

UPDATE `sip_user` SET `profile_id_user`=null WHERE `profile_id_user`  = id_user;


select `idsip_user` into my_id from sip_user where `profile_id_user` is null limit 1;


UPDATE `sip_user` SET `profile_id_user`=id_user WHERE `idsip_user`  = my_id;

RETURN my_id;

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=556 ;

--
-- Extraindo dados da tabela `avatar`
--

INSERT INTO `avatar` (`idavatar`, `image_path`) VALUES
(1, 'resized_Screenshot_2014-04-15-01-22-30-1.png'),
(201, 'Patryck.jpg'),
(202, 'Richard.jpg'),
(203, 'Luís.jpg'),
(204, 'Rodrigo.jpg'),
(205, 'José.jpg'),
(206, 'Alexandre.jpg'),
(207, 'Alexandre.jpg'),
(208, 'Robson.jpg'),
(209, 'Willian.jpg'),
(210, 'Márcio.jpg'),
(211, 'Daniel.jpg'),
(212, 'sergions.jpg'),
(213, 'rodrigo..jpg'),
(214, 'Anderson.jpg'),
(215, 'Marcello.jpg'),
(216, 'Marcello.jpg'),
(217, 'Oswaldo.jpg'),
(218, 'Luiz.jpg'),
(219, 'cvarda.jpg'),
(220, 'cvarda.jpg'),
(221, 'fernandoschutz.jpg'),
(222, 'Vinícius.jpg'),
(223, 'Vinícius.jpg'),
(225, 'Giancarlo.jpg'),
(226, 'Patrick.jpg'),
(227, 'Negão.jpg'),
(228, 'fernandagorges.jpg'),
(229, 'Familia.jpg'),
(230, 'Joao.jpg'),
(231, 'Luiz.jpg'),
(232, 'Eduardo.jpg'),
(233, 'WSFurquim.jpg'),
(234, 'Sergio.jpg'),
(235, 'Daniel.jpg'),
(236, 'CaroLina.jpg'),
(237, 'musik.jpg'),
(238, 'Nivio.jpg'),
(239, 'Helyson.jpg'),
(240, 'Drê.jpg'),
(241, 'Alexandre.jpg'),
(242, 'Edson.jpg'),
(243, 'Bruno.jpg'),
(244, 'Mauro.jpg'),
(245, 'Leonardo.jpg'),
(246, 'Suhas.jpg'),
(247, 'MAÍRA.jpg'),
(248, 'Luidi.jpg'),
(249, 'Miguel.jpg'),
(250, 'carine.jpg'),
(251, 'Ronnie.jpg'),
(252, 'Jean.jpg'),
(253, 'coser@egc.ufsc.br.jpg'),
(254, 'Mauricio.jpg'),
(255, 'Gustavo.jpg'),
(256, 'Marta.jpg'),
(257, 'Marilene.jpg'),
(258, 'Diogo.jpg'),
(259, 'Simone.jpg'),
(260, 'taylor.jpg'),
(261, 'panisson.cesar@gmail.com.jpg'),
(262, 'Luiz.jpg'),
(263, 'Luiz.jpg'),
(264, 'Edelberto.jpg'),
(265, 'Daniela.jpg'),
(266, 'Vanessa.jpg'),
(267, 'NGS.jpg'),
(268, 'Rodrigo.jpg'),
(269, 'Sérgio.jpg'),
(270, 'André.jpg'),
(271, 'Jane.jpg'),
(272, 'Juliana.jpg'),
(273, 'Camilla.jpg'),
(274, 'João.jpg'),
(275, 'João.jpg'),
(276, 'augusto@lepten.ufsc.br.jpg'),
(277, 'Julio.jpg'),
(278, 'raulbusarello.jpg'),
(279, 'Simone.jpg'),
(280, 'Geovane.jpg'),
(281, 'Pratts.jpg'),
(282, 'Elton.jpg'),
(283, 'Zizii.jpg'),
(284, 'Francyne.jpg'),
(285, 'Lucas.jpg'),
(286, 'Solange.jpg'),
(287, 'Thiago.jpg'),
(288, 'alessandrobovo@gmail.com.jpg'),
(289, 'alessandrobovo@gmail.com.jpg'),
(290, 'Jades.jpg'),
(291, 'eliane.jpg'),
(292, 'Juliana.jpg'),
(293, 'Francisco.jpg'),
(294, 'Lídia.jpg'),
(295, 'inara.antunes@gmail.com.jpg'),
(296, 'Betita.jpg'),
(297, 'Idien.jpg'),
(298, 'Mariana.jpg'),
(299, 'Fabiano.jpg'),
(300, 'Saul.jpg'),
(301, 'Dan.jpg'),
(302, 'Janine.jpg'),
(303, 'Adriano.jpg'),
(304, 'Panela.jpg'),
(305, 'ailton.jpg'),
(306, 'Charles.jpg'),
(307, 'Gerente.jpg'),
(308, 'Gerente.jpg'),
(309, 'Douglas.jpg'),
(310, 'Pedro.jpg'),
(311, 'Nélida.jpg'),
(312, 'Luiz.jpg'),
(313, 'Luiz.jpg'),
(314, 'renato.jpg'),
(315, 'Maria.jpg'),
(316, 'Maria.jpg'),
(317, 'Flavio.jpg'),
(318, 'Lucas.jpg'),
(319, 'Alessandra.jpg'),
(320, 'Fernando.jpg'),
(321, 'André.jpg'),
(322, 'André.jpg'),
(323, 'André.jpg'),
(324, 'Thais.jpg'),
(325, 'Thais.jpg'),
(326, 'Paulo.jpg'),
(327, 'mav.jpg'),
(328, 'Claudia.jpg'),
(329, 'Marina.jpg'),
(330, 'Patricia.jpg'),
(331, 'Larissa.jpg'),
(332, 'Lívia.jpg'),
(333, 'Fernando.jpg'),
(335, 'Juliana.jpg'),
(336, 'Alessandro.jpg'),
(337, 'Simone.jpg'),
(338, 'Bianka.jpg'),
(339, 'Igor.jpg'),
(340, 'devison.jpg'),
(341, 'Roberta.jpg'),
(342, 'Diego.jpg'),
(343, 'Mario.jpg'),
(344, 'Roberto.jpg'),
(345, 'Gertrudes.jpg'),
(346, 'Paloma.jpg'),
(347, 'paulo.jpg'),
(348, 'Turma.jpg'),
(349, 'Rafael.jpg'),
(350, 'Cesar.jpg'),
(351, 'William.jpg'),
(352, 'Rafael.jpg'),
(353, 'Filipe.jpg'),
(354, 'Diego.jpg'),
(355, 'Mirian.jpg'),
(356, 'Silvana.jpg'),
(357, 'Kamila.jpg'),
(358, 'Daniela.jpg'),
(359, 'Eliziana♥Patrick.jpg'),
(360, 'Eliziana♥Patrick.jpg'),
(361, 'Rafael.jpg'),
(362, 'José.jpg'),
(363, 'José.jpg'),
(364, 'Cris.jpg'),
(365, 'Carla.jpg'),
(366, 'Andrea.jpg'),
(367, 'Thiago.jpg'),
(368, 'Dalva.jpg'),
(369, 'Alessandre.jpg'),
(370, 'Alessandre.jpg'),
(371, 'Airton.jpg'),
(372, 'Airton.jpg'),
(373, 'jefferson.jpg'),
(374, 'Renata.jpg'),
(375, 'Guilherme.jpg'),
(376, 'Leandro.jpg'),
(377, 'André.jpg'),
(378, 'thiago.jpg'),
(379, 'Elisa.jpg'),
(380, 'Juliano.jpg'),
(381, 'Waldoir.jpg'),
(382, 'Rogério.jpg'),
(383, 'Jorge.jpg'),
(384, 'Roberto.jpg'),
(385, 'José.jpg'),
(386, 'Everton.jpg'),
(387, 'Everton.jpg'),
(388, 'Lobinho.jpg'),
(389, 'Rodrigo.jpg'),
(390, 'Rodrigo.jpg'),
(391, 'Antonio.jpg'),
(392, 'Eduardo.jpg'),
(393, 'Marília.jpg'),
(394, 'Lucia.jpg'),
(395, 'Leonardo.jpg'),
(396, 'Claudia.jpg'),
(397, 'Vinicius.jpg'),
(398, 'Tatiana.jpg'),
(399, 'Tatiana.jpg'),
(400, 'Tatiana.jpg'),
(401, 'Hallan.jpg'),
(402, 'Mariana.jpg'),
(403, 'Sidnei.jpg'),
(404, 'Eduardo.jpg'),
(405, 'Eduardo.jpg'),
(406, 'Cassio.jpg'),
(407, 'Armando.jpg'),
(408, 'marilia.jpg'),
(409, 'Daniela.jpg'),
(410, 'Daniela.jpg'),
(411, '*.jpg'),
(412, '*.jpg'),
(413, 'Gustavo.jpg'),
(414, 'Viviane.jpg'),
(415, 'jean.jpg'),
(416, 'André.jpg'),
(417, 'André.jpg'),
(418, 'Rodolfo.jpg'),
(419, 'Janaina.jpg'),
(420, 'Ana.jpg'),
(421, 'Paulo.jpg'),
(422, 'José.jpg'),
(423, 'Ana.jpg'),
(424, 'Fernando.jpg'),
(425, 'rodmar..jpg'),
(426, 'charlesgla@outlook.com.jpg'),
(427, 'Mariana.jpg'),
(428, 'Marcio.jpg'),
(429, 'mltemp@gmail.com.jpg'),
(430, 'Adriano.jpg'),
(431, 'Adriano.jpg'),
(432, 'Adriano.jpg'),
(433, 'Tiago.jpg'),
(434, 'Alemão.jpg'),
(435, 'Eduardo.jpg'),
(436, 'isabel.jpg'),
(437, 'Claudia.jpg'),
(438, 'Marciéli.jpg'),
(439, 'Pedro.jpg'),
(440, 'Karla.jpg'),
(441, 'jean.jpg'),
(442, 'Saulo.jpg'),
(443, 'CARLOS.jpg'),
(444, 'Ricardo.jpg'),
(445, 'jackson.jpg'),
(446, 'ALFA.jpg'),
(447, 'Michele.jpg'),
(448, 'Arthur.jpg'),
(449, 'Jonathas.jpg'),
(450, 'Jonathas.jpg'),
(451, 'Bruna.jpg'),
(452, 'edismafra@gmail.com.jpg'),
(453, 'diogo.jpg'),
(454, 'Thiago.jpg'),
(455, 'Mário.jpg'),
(456, 'Mário.jpg'),
(457, 'Mário.jpg'),
(458, 'Rafael.jpg'),
(459, 'Rafael.jpg'),
(460, 'Janaina.jpg'),
(461, 'laudelinomoretto.jpg'),
(462, 'Lu.jpg'),
(463, 'Eberson.jpg'),
(464, 'wieneke.jpg'),
(465, 'Fernando.jpg'),
(466, 'Murilo.jpg'),
(467, 'henrique.otte@gmail.com.jpg'),
(469, 'Destinos.jpg'),
(470, 'chipmaster.leandro@gmail.com.jpg'),
(471, 'Andreza.jpg'),
(473, 'marcusdmb@gmail.com.jpg'),
(474, 'Sabrina.jpg'),
(475, 'Thayssa.jpg'),
(476, 'Thayssa.jpg'),
(477, 'lidia.jpg'),
(478, 'Morgana.jpg'),
(479, 'Fabio.jpg'),
(480, 'Klaibson.jpg'),
(481, 'Douglas.jpg'),
(482, 'elianacc@gmail.com.jpg'),
(483, 'fernandovalter@gmail.com.jpg'),
(484, 'Jeferson.jpg'),
(485, 'grego.jpg'),
(486, 'leandro.jpg'),
(487, 'marcos.jpg'),
(488, 'Fabricio.jpg'),
(489, 'Leticia.jpg'),
(490, 'Ana.jpg'),
(491, 'Ismael.jpg'),
(492, 'Daniel.jpg'),
(493, 'João.jpg'),
(494, 'Angela.jpg'),
(495, 'Fabiane.jpg'),
(496, 'Lilian.jpg'),
(497, 'Lilian.jpg'),
(498, 'Mai.jpg'),
(499, 'Gerusa.jpg'),
(500, 'Ivan.jpg'),
(501, 'Marco.jpg'),
(502, 'Karin.jpg'),
(503, 'Andreia.jpg'),
(504, 'Rosane.jpg'),
(505, 'CASSIANO.jpg'),
(506, 'janine_alves@hotmail.com.jpg'),
(507, 'Eduardo.jpg'),
(508, 'Eduardo.jpg'),
(509, 'David.jpg'),
(510, 'Carolina.jpg'),
(511, 'cesar.jpg'),
(512, 'Jéssica.jpg'),
(513, 'danyzinhax@gmail.com.jpg'),
(514, 'Cristiano.jpg'),
(515, 'Cristiano.jpg'),
(516, 'Djefferson.jpg'),
(517, 'Megaron.jpg'),
(518, 'marcelo.leandro@univille.br.jpg'),
(519, 'Andreza.jpg'),
(520, '288cff4571f47957b5a0c35bfa269683.jpg'),
(521, '1202253909.png'),
(525, '1202253909.jpg'),
(526, 'IMG-20140601-WA0001.jpg'),
(527, 'IMG_20140615_155351.jpg'),
(529, 'jun 16, 2014 07:18:45 PM.jpeg'),
(530, 'IMG-20140614-WA0006.jpg'),
(531, 'IMG_20140531_184322.jpg'),
(532, 'sound_on_demo.png'),
(534, 'IMG_20131124_002357.jpg'),
(535, '18469'),
(536, '17990'),
(537, '17492'),
(540, '18342'),
(541, 'IMG-20140619-WA0006.jpg'),
(543, 'VID-20140531-WA0000.mp4'),
(544, '73615'),
(545, '204889'),
(547, '2566071'),
(548, '78858'),
(551, '11197'),
(552, 'image-ced1ce5a63c2d00cb28e5cbc29c92a17b415e17a8ef7924a784aa8ba9867cf32-V.jpg'),
(553, 'Screenshot_2014-06-21-00-51-47~2.jpg'),
(554, 'IMG-20140619-WA0002.jpg'),
(555, 'IMG_20140623_194652.jpg');

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=43 ;

--
-- Extraindo dados da tabela `call`
--

INSERT INTO `call` (`id_call`, `start_t`, `end_t`, `from_c`, `to_c`, `service_type_idservice_type`, `token`) VALUES
(38, '2014-06-17 07:16:30', '2014-06-17 07:17:44', 1907, 201, 3, '889b0dedae6f72d72b38f1b691bb95a5'),
(39, '2014-06-17 07:17:49', '2014-06-17 07:17:58', 1907, 201, 3, 'c51ca800728c9a104ba6cdf566130f7d'),
(40, '2014-06-17 07:18:17', '2014-06-17 07:18:23', 1907, 201, 3, '5e4a3031324faf5e0974e95251e4b429'),
(41, '2014-06-17 07:18:37', '2014-06-17 07:18:45', 1907, 201, 3, 'ea6d5fd34fbb84ea471339311e401637'),
(42, '2014-06-17 07:20:03', '2014-06-17 07:21:19', 1907, 201, 3, 'd5f450883a26f8fc5faca711332544b2');

-- --------------------------------------------------------

--
-- Estrutura da tabela `evaluation`
--

DROP TABLE IF EXISTS `evaluation`;
CREATE TABLE IF NOT EXISTS `evaluation` (
  `idevaluation` int(11) NOT NULL AUTO_INCREMENT,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `rate` float NOT NULL,
  `profile_id_translator` int(11) NOT NULL,
  `profile_id_user` int(11) NOT NULL,
  PRIMARY KEY (`idevaluation`),
  KEY `fk_evaluation_profile_idx` (`profile_id_translator`),
  KEY `fk_evaluation_profile1_idx` (`profile_id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

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
  `optype` enum('save','call','paypall','finish','register','login','password') DEFAULT NULL,
  PRIMARY KEY (`idlog`),
  KEY `fk_log_profile_idx` (`id_user`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=729 ;

--
-- Extraindo dados da tabela `log`
--

INSERT INTO `log` (`idlog`, `ip`, `date`, `id_user`, `optype`) VALUES
(481, '179.216.171.104', '2014-06-07 17:16:21', 1907, NULL),
(482, '179.216.171.104', '2014-06-07 17:16:23', 1907, NULL),
(483, '179.216.171.104', '2014-06-07 17:16:38', 1907, NULL),
(484, '179.216.171.104', '2014-06-07 17:16:40', 1907, NULL),
(485, '179.216.171.104', '2014-06-07 17:17:59', 1907, NULL),
(486, '179.216.171.104', '2014-06-07 17:18:04', 1907, NULL),
(487, '179.216.171.104', '2014-06-07 17:18:14', 1907, NULL),
(488, '179.216.171.104', '2014-06-07 17:18:15', 1907, NULL),
(489, '179.216.171.104', '2014-06-07 17:30:51', 1907, NULL),
(490, '179.216.171.104', '2014-06-07 17:34:05', 2105, NULL),
(491, '179.216.171.104', '2014-06-07 17:40:24', 1907, NULL),
(492, '179.216.171.104', '2014-06-07 17:42:34', 1907, NULL),
(493, '179.216.171.104', '2014-06-07 17:49:37', 1907, NULL),
(494, '179.216.171.104', '2014-06-07 20:13:18', 1907, NULL),
(495, '179.216.171.104', '2014-06-07 23:04:23', 1907, NULL),
(496, '179.216.171.104', '2014-06-07 23:04:54', 1907, NULL),
(497, '179.216.171.104', '2014-06-07 23:05:00', 1907, NULL),
(498, '179.216.171.104', '2014-06-07 23:05:21', 1907, NULL),
(499, '179.216.171.104', '2014-06-07 23:05:34', 1907, NULL),
(501, '179.216.171.104', '2014-06-07 23:17:31', 1907, NULL),
(502, '179.216.171.104', '2014-06-07 23:17:37', 1907, NULL),
(503, '179.216.171.104', '2014-06-07 23:19:46', 1907, NULL),
(504, '179.216.171.104', '2014-06-09 15:50:46', 1907, NULL),
(505, '179.216.171.104', '2014-06-09 15:57:14', 1907, NULL),
(507, '179.216.171.104', '2014-06-09 19:54:43', 251, NULL),
(508, '179.216.171.104', '2014-06-09 22:35:39', 2129, NULL),
(509, '179.216.171.104', '2014-06-09 22:35:40', 2129, NULL),
(510, '192.168.6.235', '2014-06-10 22:31:49', 1907, NULL),
(511, '179.255.234.242', '2014-06-11 03:33:14', 2105, NULL),
(512, '179.255.234.242', '2014-06-11 03:33:33', 2105, NULL),
(513, '179.255.234.242', '2014-06-11 03:35:29', 2142, NULL),
(514, '179.255.234.242', '2014-06-11 03:35:34', 2142, NULL),
(515, '179.216.171.104', '2014-06-12 00:49:47', 2129, NULL),
(516, '179.216.171.104', '2014-06-12 00:49:50', 2129, NULL),
(517, '179.216.171.104', '2014-06-12 00:50:02', 2129, NULL),
(518, '179.216.171.104', '2014-06-12 00:50:09', 2129, NULL),
(519, '179.216.171.104', '2014-06-12 01:21:21', 2129, NULL),
(520, '179.216.171.104', '2014-06-12 01:21:23', 2129, NULL),
(521, '179.216.171.104', '2014-06-12 01:21:44', 2129, NULL),
(522, '179.216.171.104', '2014-06-12 01:21:46', 2129, NULL),
(523, '179.216.171.104', '2014-06-12 01:55:40', 1907, NULL),
(524, '179.216.171.104', '2014-06-12 01:55:58', 1907, NULL),
(525, '179.216.171.104', '2014-06-12 06:54:25', 1907, NULL),
(526, '179.216.171.104', '2014-06-12 06:55:20', 1907, NULL),
(527, '179.216.171.104', '2014-06-12 07:05:07', 1907, NULL),
(528, '179.216.171.104', '2014-06-12 07:05:47', 1907, NULL),
(529, '179.216.171.104', '2014-06-12 07:09:35', 1907, NULL),
(530, '179.216.171.104', '2014-06-12 07:15:59', 1907, NULL),
(531, '179.216.171.104', '2014-06-12 21:05:51', 1907, NULL),
(532, '177.16.202.167', '2014-06-14 23:47:12', 914, NULL),
(533, '177.16.202.167', '2014-06-14 23:47:22', 914, NULL),
(534, '177.16.202.167', '2014-06-14 23:48:52', 2143, NULL),
(535, '177.16.202.167', '2014-06-14 23:48:54', 2143, NULL),
(536, '177.16.202.167', '2014-06-15 00:00:50', 2144, NULL),
(537, '177.16.202.167', '2014-06-15 00:00:52', 2144, NULL),
(538, '177.16.202.167', '2014-06-15 00:09:13', 2145, NULL),
(539, '177.16.202.167', '2014-06-15 00:09:15', 2145, NULL),
(540, '177.16.202.167', '2014-06-15 00:16:11', 2145, NULL),
(541, '177.16.202.167', '2014-06-15 00:16:12', 2145, NULL),
(542, '177.16.202.167', '2014-06-15 00:23:08', 2145, NULL),
(543, '177.16.202.167', '2014-06-15 00:23:12', 2145, NULL),
(544, '189.101.239.133', '2014-06-15 00:30:33', 1907, NULL),
(545, '189.101.239.133', '2014-06-15 00:30:50', 1907, NULL),
(546, '177.16.202.167', '2014-06-15 00:41:21', 2145, NULL),
(547, '177.16.202.167', '2014-06-15 00:41:23', 2145, NULL),
(548, '177.16.202.167', '2014-06-15 00:42:31', 2145, NULL),
(549, '177.16.202.167', '2014-06-15 00:42:52', 2145, NULL),
(550, '177.16.202.167', '2014-06-15 00:43:02', 2145, NULL),
(551, '177.16.202.167', '2014-06-15 00:43:06', 2145, NULL),
(552, '177.16.202.167', '2014-06-15 00:45:28', 2145, NULL),
(553, '177.16.202.167', '2014-06-15 00:47:13', 2145, NULL),
(554, '177.16.202.167', '2014-06-15 00:59:23', 2146, NULL),
(555, '177.16.202.167', '2014-06-15 00:59:23', 2146, NULL),
(556, '177.16.202.167', '2014-06-15 00:59:31', 2146, NULL),
(557, '177.16.202.167', '2014-06-15 00:59:46', 2146, NULL),
(558, '177.16.202.167', '2014-06-15 00:59:48', 2146, NULL),
(559, '177.16.202.167', '2014-06-15 00:59:52', 2146, NULL),
(560, '177.16.202.167', '2014-06-15 01:01:38', 2146, NULL),
(561, '177.16.202.167', '2014-06-15 01:01:43', 2146, NULL),
(562, '177.16.202.167', '2014-06-15 01:02:11', 2146, NULL),
(563, '177.16.202.167', '2014-06-15 01:02:15', 2146, NULL),
(564, '177.16.202.167', '2014-06-15 01:02:38', 2146, NULL),
(565, '177.16.202.167', '2014-06-15 01:02:40', 2146, NULL),
(566, '177.16.202.167', '2014-06-15 01:02:43', 2146, NULL),
(567, '177.16.202.167', '2014-06-15 01:03:33', 2146, NULL),
(568, '177.16.202.167', '2014-06-15 01:03:34', 2146, NULL),
(569, '177.16.202.167', '2014-06-15 01:03:38', 2146, NULL),
(570, '177.16.202.167', '2014-06-15 01:09:02', 2145, NULL),
(571, '177.16.202.167', '2014-06-15 01:09:05', 2145, NULL),
(572, '177.16.202.167', '2014-06-15 01:09:21', 2145, NULL),
(573, '177.16.202.167', '2014-06-15 01:09:28', 2145, NULL),
(574, '177.16.202.167', '2014-06-15 01:29:52', 2146, NULL),
(575, '186.222.53.23', '2014-06-15 15:04:16', 1084, NULL),
(576, '186.222.53.23', '2014-06-15 15:04:22', 1084, NULL),
(577, '186.222.53.23', '2014-06-15 15:06:26', 2147, NULL),
(578, '186.222.53.23', '2014-06-15 15:06:37', 2147, NULL),
(579, '186.222.53.23', '2014-06-15 16:37:27', 2147, NULL),
(580, '186.222.53.23', '2014-06-15 16:37:29', 2147, NULL),
(581, '186.222.53.23', '2014-06-15 16:37:33', 2147, NULL),
(582, '186.222.53.23', '2014-06-15 16:37:36', 2147, NULL),
(583, '186.222.53.23', '2014-06-15 16:38:07', 2147, NULL),
(584, '186.222.53.23', '2014-06-15 16:38:09', 2147, NULL),
(585, '186.222.53.23', '2014-06-15 16:38:16', 2147, NULL),
(586, '186.222.53.23', '2014-06-15 16:38:18', 2147, NULL),
(587, '186.222.53.23', '2014-06-15 17:41:55', 2147, NULL),
(588, '186.222.53.23', '2014-06-15 17:41:57', 2147, NULL),
(589, '186.222.53.23', '2014-06-15 18:02:57', 2147, NULL),
(590, '186.222.53.23', '2014-06-15 18:02:59', 2147, NULL),
(591, '186.222.53.23', '2014-06-15 18:03:09', 2147, NULL),
(592, '189.101.239.133', '2014-06-15 18:44:30', 1907, NULL),
(593, '179.216.171.104', '2014-06-16 18:26:39', 1907, NULL),
(594, '179.216.171.104', '2014-06-16 19:01:39', 1907, NULL),
(595, '179.216.171.104', '2014-06-16 19:03:53', 1907, NULL),
(596, '179.216.171.104', '2014-06-16 19:04:25', 1907, NULL),
(597, '179.216.171.104', '2014-06-16 19:18:52', 1907, NULL),
(598, '179.216.171.104', '2014-06-16 19:19:25', 1907, NULL),
(599, '179.216.171.104', '2014-06-16 19:24:00', 1907, NULL),
(600, '179.216.171.104', '2014-06-16 19:24:21', 1907, NULL),
(601, '179.216.171.104', '2014-06-16 19:26:40', 1907, NULL),
(602, '179.216.171.104', '2014-06-16 19:29:32', 1907, NULL),
(603, '179.216.171.104', '2014-06-16 19:29:39', 1907, NULL),
(604, '179.216.171.104', '2014-06-16 19:31:56', 1907, NULL),
(605, '179.216.171.104', '2014-06-16 19:48:01', 1907, NULL),
(606, '179.216.171.104', '2014-06-16 19:56:30', 1907, NULL),
(607, '179.216.171.104', '2014-06-16 19:58:21', 1907, NULL),
(608, '179.216.171.104', '2014-06-16 20:01:05', 1907, NULL),
(609, '179.216.171.104', '2014-06-16 20:08:31', 1907, NULL),
(610, '179.216.171.104', '2014-06-16 20:10:09', 1907, NULL),
(611, '179.216.171.104', '2014-06-16 20:10:50', 1907, NULL),
(612, '179.216.171.104', '2014-06-16 20:16:55', 1907, NULL),
(613, '179.216.171.104', '2014-06-16 20:28:51', 1907, NULL),
(614, '179.216.171.104', '2014-06-16 20:43:17', 1907, NULL),
(615, '179.216.171.104', '2014-06-16 20:48:22', 1907, NULL),
(616, '179.216.171.104', '2014-06-16 23:06:55', 1907, NULL),
(617, '179.216.171.104', '2014-06-16 23:27:06', 1907, NULL),
(618, '179.216.171.104', '2014-06-16 23:28:25', 1907, NULL),
(619, '179.216.171.104', '2014-06-16 23:29:27', 1907, NULL),
(620, '179.216.171.104', '2014-06-16 23:31:04', 1907, NULL),
(621, '179.216.171.104', '2014-06-16 23:32:33', 1907, NULL),
(622, '179.216.171.104', '2014-06-16 23:38:20', 1907, NULL),
(623, '179.216.171.104', '2014-06-16 23:38:29', 1907, NULL),
(624, '179.216.171.104', '2014-06-16 23:40:26', 1907, NULL),
(625, '179.216.171.104', '2014-06-16 23:40:41', 1907, NULL),
(626, '179.216.171.104', '2014-06-16 23:41:32', 1907, NULL),
(627, '179.216.171.104', '2014-06-16 23:41:40', 1907, NULL),
(628, '179.216.171.104', '2014-06-16 23:42:31', 1907, NULL),
(629, '179.216.171.104', '2014-06-16 23:43:11', 1907, NULL),
(630, '179.216.171.104', '2014-06-16 23:44:31', 1907, NULL),
(631, '179.216.171.104', '2014-06-16 23:46:18', 1907, NULL),
(632, '179.216.171.104', '2014-06-16 23:54:46', 1907, NULL),
(633, '191.219.49.192', '2014-06-17 03:59:13', 2142, NULL),
(634, '191.219.49.192', '2014-06-17 03:59:24', 2142, NULL),
(635, '191.219.49.192', '2014-06-17 03:59:38', 2142, NULL),
(636, '191.219.49.192', '2014-06-17 04:00:27', 1907, NULL),
(637, '191.219.122.48', '2014-06-17 04:08:10', 1907, NULL),
(638, '179.216.171.104', '2014-06-17 17:46:15', 1907, NULL),
(639, '179.216.171.104', '2014-06-17 17:49:01', 1907, NULL),
(640, '179.216.171.104', '2014-06-17 17:49:51', 1907, NULL),
(641, '179.216.171.104', '2014-06-17 18:48:42', 2105, 'password'),
(642, '179.216.171.104', '2014-06-17 21:15:17', 1907, NULL),
(643, '179.216.171.104', '2014-06-17 21:15:42', 1907, NULL),
(644, '179.216.171.104', '2014-06-17 21:16:42', 205, NULL),
(645, '179.216.171.104', '2014-06-17 21:16:44', 205, NULL),
(646, '179.216.171.104', '2014-06-17 21:17:06', 205, NULL),
(647, '179.216.171.104', '2014-06-17 21:17:08', 205, NULL),
(648, '179.216.171.104', '2014-06-17 21:17:41', 205, NULL),
(649, '179.216.171.104', '2014-06-17 21:17:43', 205, NULL),
(650, '179.216.171.104', '2014-06-17 21:18:18', 205, NULL),
(651, '179.216.171.104', '2014-06-17 21:18:20', 205, NULL),
(652, '179.216.171.104', '2014-06-17 21:20:50', 205, NULL),
(653, '179.216.171.104', '2014-06-17 21:21:13', 205, NULL),
(654, '179.216.171.104', '2014-06-17 21:21:15', 205, NULL),
(655, '179.216.171.104', '2014-06-17 21:24:08', 205, NULL),
(656, '179.216.171.104', '2014-06-17 21:24:10', 205, NULL),
(657, '179.216.171.104', '2014-06-17 21:24:44', 205, NULL),
(658, '179.216.171.104', '2014-06-17 21:24:46', 205, NULL),
(659, '179.216.171.104', '2014-06-17 21:25:09', 205, NULL),
(660, '179.216.171.104', '2014-06-17 21:25:57', 205, NULL),
(661, '179.216.171.104', '2014-06-17 21:25:59', 205, NULL),
(662, '179.216.171.104', '2014-06-17 21:27:40', 205, NULL),
(663, '179.216.171.104', '2014-06-17 21:27:42', 205, NULL),
(664, '179.216.171.104', '2014-06-17 21:27:59', 205, NULL),
(665, '179.216.171.104', '2014-06-17 21:49:45', 205, NULL),
(666, '179.216.171.104', '2014-06-17 21:49:52', 205, NULL),
(667, '179.216.171.104', '2014-06-17 21:55:15', 205, NULL),
(668, '179.216.171.104', '2014-06-17 21:56:25', 205, NULL),
(669, '179.216.171.104', '2014-06-17 21:56:51', 205, NULL),
(670, '186.222.53.23', '2014-06-18 22:17:28', 2147, NULL),
(671, '186.222.53.23', '2014-06-18 22:17:31', 2147, NULL),
(672, '186.222.53.23', '2014-06-18 22:17:54', 2147, NULL),
(673, '186.222.53.23', '2014-06-18 22:17:56', 2147, NULL),
(674, '186.222.53.23', '2014-06-18 22:18:01', 2147, NULL),
(675, '186.222.53.23', '2014-06-18 22:18:33', 2147, NULL),
(676, '186.222.53.23', '2014-06-18 22:18:36', 2147, NULL),
(677, '186.222.53.23', '2014-06-18 22:20:33', 2147, NULL),
(678, '186.222.53.23', '2014-06-18 22:20:35', 2147, NULL),
(679, '186.222.53.23', '2014-06-18 22:20:41', 2147, NULL),
(680, '186.222.53.23', '2014-06-18 22:20:45', 2147, NULL),
(681, '186.222.53.23', '2014-06-18 22:20:48', 2147, NULL),
(682, '186.222.53.23', '2014-06-18 23:55:06', 2147, NULL),
(683, '186.222.53.23', '2014-06-18 23:55:08', 2147, NULL),
(684, '186.222.53.23', '2014-06-18 23:55:12', 2147, NULL),
(685, '186.222.53.23', '2014-06-18 23:55:16', 2147, NULL),
(686, '186.222.53.23', '2014-06-18 23:58:29', 2147, NULL),
(687, '186.222.53.23', '2014-06-18 23:58:31', 2147, NULL),
(688, '186.222.53.23', '2014-06-18 23:58:40', 2147, NULL),
(689, '186.222.53.23', '2014-06-19 00:06:33', 2147, NULL),
(690, '186.222.53.23', '2014-06-19 00:06:35', 2147, NULL),
(691, '186.222.53.23', '2014-06-19 00:06:41', 2147, NULL),
(692, '186.222.53.23', '2014-06-19 00:06:45', 2147, NULL),
(693, '186.222.53.23', '2014-06-19 00:07:14', 2147, NULL),
(694, '186.222.53.23', '2014-06-19 00:07:16', 2147, NULL),
(695, '186.222.53.23', '2014-06-19 00:07:30', 2147, NULL),
(696, '186.222.53.23', '2014-06-19 00:07:37', 2147, NULL),
(697, '186.222.53.23', '2014-06-19 00:35:54', 2147, NULL),
(698, '186.222.53.23', '2014-06-19 00:37:11', 2147, NULL),
(699, '186.222.53.23', '2014-06-19 00:37:36', 2147, NULL),
(700, '186.222.53.23', '2014-06-19 00:37:44', 2147, NULL),
(701, '186.222.53.23', '2014-06-19 00:38:13', 2147, NULL),
(702, '179.216.171.104', '2014-06-23 06:02:27', 1907, NULL),
(703, '193.28.178.61', '2014-06-23 07:43:45', 1907, NULL),
(704, '179.216.171.104', '2014-06-24 01:39:00', 1907, NULL),
(705, '186.222.53.23', '2014-06-24 02:19:10', 2147, NULL),
(706, '186.222.53.23', '2014-06-24 02:19:12', 2147, NULL),
(707, '186.222.53.23', '2014-06-24 02:19:26', 2147, NULL),
(708, '186.222.53.23', '2014-06-24 02:19:27', 2147, NULL),
(709, '186.222.53.23', '2014-06-24 02:22:19', 2147, NULL),
(710, '186.222.53.23', '2014-06-24 02:22:22', 2147, NULL),
(711, '186.222.53.23', '2014-06-24 02:22:34', 2147, NULL),
(712, '186.222.53.23', '2014-06-24 02:22:38', 2147, NULL),
(713, '186.222.53.23', '2014-06-24 02:26:41', 205, NULL),
(714, '179.216.171.104', '2014-06-24 03:06:33', 1907, NULL),
(715, '179.216.171.104', '2014-06-24 04:09:16', 205, NULL),
(716, '179.216.171.104', '2014-06-24 04:24:05', 205, NULL),
(717, '179.216.171.104', '2014-06-24 04:35:36', 205, NULL),
(718, '179.216.171.104', '2014-06-24 04:39:12', 205, NULL),
(719, '179.216.171.104', '2014-06-24 04:42:03', 205, NULL),
(720, '179.216.171.104', '2014-06-24 04:44:27', 205, NULL),
(721, '179.216.171.104', '2014-06-24 04:55:15', 205, NULL),
(722, '179.216.171.104', '2014-06-24 05:09:18', 205, NULL),
(723, '179.216.171.104', '2014-06-24 05:15:01', 205, NULL),
(724, '179.216.171.104', '2014-06-24 05:37:58', 205, NULL),
(725, '179.216.171.104', '2014-06-24 06:09:30', 205, NULL),
(726, '179.216.171.104', '2014-06-24 06:12:53', 205, NULL),
(727, '179.216.171.104', '2014-06-24 06:17:06', 205, NULL),
(728, '179.216.171.104', '2014-06-24 07:13:44', 1907, NULL);

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

DROP TABLE IF EXISTS `paypal_log`;
CREATE TABLE IF NOT EXISTS `paypal_log` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `txn_id` varchar(600) NOT NULL,
  `log` text NOT NULL,
  `posted_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Extraindo dados da tabela `paypal_log`
--

INSERT INTO `paypal_log` (`id`, `txn_id`, `log`, `posted_date`) VALUES
(1, '4P887111CN718644V', '{mc_gross:100.00,invoice:1441238994,protection_eligibility:Eligible,address_status:unconfirmed,item_number1:1,payer_id:DGV5Q2363653Y,tax:0.00,address_street:Rua General Bittencourt  397  casa\r\nCentro,payment_date:10:44:32 May 26, 2014 PDT,payment_status:Completed,charset:windows-1252,address_zip:88020-100,mc_shipping:0.00,mc_handling:0.00,first_name:MORETTO TIC,mc_fee:4.20,address_country_code:BR,address_name:MORETTO TIC MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO''s Test Store,notify_version:3.8,custom:,payer_status:verified,business:malacma-facilitator@gmail.com,address_country:Brazil,num_cart_items:1,mc_handling1:0.00,address_city:Florianópolis,verify_sign:AFcWxV21C7fd0v3bYYYRCpSSRl31A1c1kIeRbR7SsywCqc97mGKu3M7N,payer_email:malacma@gmail.com,mc_shipping1:0.00,tax1:0.00,txn_id:4P887111CN718644V,payment_type:instant,payer_business_name:MORETTO TIC MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO''s Test Store,last_name:MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO,address_state:SC,item_name1:Babel2u Coins,receiver_email:malacma-facilitator@gmail.com,payment_fee:4.20,quantity1:1,receiver_id:REQ8GEKT48VW6,txn_type:cart,mc_gross_1:100.00,mc_currency:USD,residence_country:BR,test_ipn:1,transaction_subject:,payment_gross:100.00,ipn_track_id:3d5885678e832,a1:null}', '2014-05-26 14:44:38'),
(2, '5NR89944FX207544Y', '{mc_gross:5.00,invoice:1528351756,protection_eligibility:Eligible,address_status:unconfirmed,item_number1:1,payer_id:DGV5Q2363653Y,tax:0.00,address_street:Rua General Bittencourt  397  casa\r\nCentro,payment_date:11:31:14 May 26, 2014 PDT,payment_status:Completed,charset:windows-1252,address_zip:88020-100,mc_shipping:0.00,mc_handling:0.00,first_name:MORETTO TIC,mc_fee:0.50,address_country_code:BR,address_name:MORETTO TIC MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO''s Test Store,notify_version:3.8,custom:,payer_status:verified,business:malacma-facilitator@gmail.com,address_country:Brazil,num_cart_items:1,mc_handling1:0.00,address_city:Florianópolis,verify_sign:Ac.eGBZJO8gkI4pLznA4cUG0IVpGAa05yFrc5JPYmrdK7RfuGpUAOPPO,payer_email:malacma@gmail.com,mc_shipping1:0.00,tax1:0.00,txn_id:5NR89944FX207544Y,payment_type:instant,payer_business_name:MORETTO TIC MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO''s Test Store,last_name:MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO,address_state:SC,item_name1:Babel2u Coins,receiver_email:malacma-facilitator@gmail.com,payment_fee:0.50,quantity1:1,receiver_id:REQ8GEKT48VW6,txn_type:cart,mc_gross_1:5.00,mc_currency:USD,residence_country:BR,test_ipn:1,transaction_subject:,payment_gross:5.00,ipn_track_id:ac148c4f7013c,a1:null}', '2014-05-26 15:31:17'),
(3, '26647260W9631751H', '{mc_gross:20.00,invoice:2123121570,protection_eligibility:Ineligible,address_status:unconfirmed,item_number1:1,payer_id:SSB9N9BKRP968,tax:0.00,address_street:Rua francisco goulart 96,405,payment_date:17:30:55 Jun 14, 2014 PDT,payment_status:Pending,charset:windows-1252,address_zip:88036600,mc_shipping:0.00,mc_handling:0.00,first_name:Arthur,address_country_code:BR,address_name:USER1 USER1,notify_version:3.8,custom:,payer_status:unverified,address_country:Brazil,num_cart_items:1,mc_handling1:0.00,address_city:florianopolis,verify_sign:AFP9pU0kCAvVAVimKAU0y2nVnOYQAsJyzTgn.sKmWT06VcHQSvU.UHKE,payer_email:artur@labirinto.com.br,mc_shipping1:0.00,txn_id:26647260W9631751H,payment_type:instant,last_name:Sanders Júnior,address_state:Santa Catarina,item_name1:Babel2u Coins,receiver_email:malacma-facilitator@gmail.com,quantity1:1,pending_reason:unilateral,txn_type:cart,mc_gross_1:20.00,mc_currency:USD,residence_country:BR,transaction_subject:Shopping CartBabel2u Coins,payment_gross:20.00,ipn_track_id:54008d49b60c2,a1:null}', '2014-06-14 21:30:59'),
(4, '4M9085866J991054B', '{mc_gross:5.00,invoice:2055152327,protection_eligibility:Ineligible,address_status:unconfirmed,item_number1:1,payer_id:HRCMN9449A4QQ,tax:0.00,address_street:antonio da silveira, 225,payment_date:16:58:08 Jun 18, 2014 PDT,payment_status:Pending,charset:windows-1252,address_zip:88062155,mc_shipping:0.00,mc_handling:0.00,first_name:João Guilherme,address_country_code:BR,address_name:GUIME GUIME,notify_version:3.8,custom:,payer_status:unverified,address_country:Brazil,num_cart_items:1,mc_handling1:0.00,address_city:FlorianÃ³polis,verify_sign:AaX4hzCdcB1ANiXCuXM2rOXwWrA7Aa7tg-Z.3b730e.px8O-nh1iGQZK,payer_email:jgoliveira78@gmail.com,mc_shipping1:0.00,txn_id:4M9085866J991054B,payment_type:instant,last_name:de Oliveira,address_state:Santa Catarina,item_name1:Babel2u Coins,receiver_email:malacma-facilitator@gmail.com,quantity1:1,pending_reason:unilateral,txn_type:cart,mc_gross_1:5.00,mc_currency:USD,residence_country:BR,transaction_subject:Shopping CartBabel2u Coins,payment_gross:5.00,ipn_track_id:3438fbe3e2b1a,a1:null}', '2014-06-18 20:58:14');

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
  `online` tinyint(1) DEFAULT '0',
  `avaliable` tinyint(1) DEFAULT '0',
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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2151 ;

--
-- Extraindo dados da tabela `profile`
--

INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(201, 'PATRYCK RAMOS MARTINS', 'PATRYCKRM@GMAIL.COM', 'c4ca4238a0b923820dcc509a6f75849b', 1, 1, '2014-06-01', '30c83688-d98a-4eb1-b027-eb4afa111397', 1.66667, 2, 1, 4, 201, 0),
(202, 'LUÍS AUGUSTO MACHADO MORETTO', 'LUIS@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8e98bdc6-5c03-4666-b847-178a595c3c34', 0, 1, 1, 1, NULL, 0),
(203, 'MURILO 6COMNETO', 'MURILO@CONNECTNET.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f00309bf-7a77-4886-ad38-fe19e5bdd5fa', 0, 1, 1, 1, NULL, 0),
(204, 'SIMONE MORETTO', 'SIMORETTO@BRTURBO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '19f1336b-a956-41bf-8681-d0be0301a9f8', 0, 1, 1, 1, NULL, 0),
(205, 'MISLENE RICHARTZ MORETTO', 'MIMI_RICHARTZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-01', 'a5739b65-6e5e-4e2e-b3b7-0ac5cea255fe', 0, 2, 3, 1, 555, 0),
(206, 'MURILO 6COMNETO', 'MURILO737@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9cf9fcc7-e9a1-44d6-a47b-bdbdf0e7ac53', 0, 1, 1, 1, NULL, 0),
(207, 'MARCELLO THIRY', 'THIRY@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1b136d89-c08b-4894-a583-c9d473aed0c2', 0, 1, 1, 1, NULL, 0),
(208, 'ADEMIR-ENG@UNIVALI.BR', 'ADEMIR-ENG@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '38f04169-d4f6-4347-996f-3ec8fb50c1cd', 0, 1, 1, 1, NULL, 0),
(209, 'RICHARD HENRIQUE DE SOUZA', 'RIHS@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '182045aa-ec06-4b11-a895-f73ec30c27c8', 0, 1, 1, 1, NULL, 0),
(210, 'RICHARD HENRIQUE DE SOUZA', 'RICHARDHENRIQUE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a2a52a77-70bf-4183-ba74-6d82f25b275c', 0, 1, 1, 1, 202, 0),
(211, 'LUÍS MORETTO NETO', 'MORETTO@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dabee87f-aeda-432c-bb0f-f37b4985707d', 0, 1, 1, 1, NULL, 0),
(212, 'ALE_FLORIPA@YAHOO.COM', 'ALE_FLORIPA@YAHOO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '31ad516c-94b5-412b-9f0f-32662a144cfe', 0, 1, 1, 1, NULL, 0),
(213, 'AZOUCAS@GMAIL.COM', 'AZOUCAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '148d5b4c-c71e-4cbf-9526-4f93a37e06b1', 0, 1, 1, 1, NULL, 0),
(214, 'ALESSANDRA ZOUCAS', 'ALESSANDRAZOUCAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd5c1874b-741c-4d26-a5ab-5808317f2878', 0, 1, 1, 1, NULL, 0),
(215, 'SOLANGE MORETTO', 'SOLANGE@FUCAP.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '63ab01da-5f22-46c7-b602-07a3b544cd77', 0, 1, 1, 1, NULL, 0),
(216, 'LUÍS AUGUSTO MACHADO MORETTO', 'MALACMA@GMAItL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a14dead-7a00-46d7-896d-b1078eff2b5e', 0, 1, 7, 1, 520, 0),
(217, 'LUCASMR@EPAGRI.RCT-SC.BR', 'LUCASMR@EPAGRI.RCT-SC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '042b3616-093e-41eb-874c-968262a6f5b5', 0, 1, 1, 1, NULL, 0),
(218, 'SIMONE MACHADO MORETTO', 'SIMORETTO@BRTURBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c54bea48-5052-4e66-bbe6-7265a1640724', 0, 1, 1, 1, NULL, 0),
(219, 'SIMONE MACHADO MORETTO', 'MORETTO.SIMONEMACHADO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3735be81-2f6e-4514-a95d-7cf54f516608', 0, 1, 1, 1, NULL, 0),
(220, 'JANARA PEIXOTO', 'JANARAP@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c05ed9af-6037-4859-aa44-341c50092141', 0, 1, 1, 1, NULL, 0),
(221, 'JANAINA.COSTA@NEXXERA.COM', 'JANAINA.COSTA@NEXXERA.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3cae2668-1a4e-4e2b-9b19-a6cc0f806b50', 0, 1, 1, 1, NULL, 0),
(222, 'FERNANDOSBOTELHO@YAHOO.COM.BR', 'FERNANDOSBOTELHO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a636ba83-4748-4659-90bd-59aba07aa42a', 0, 1, 1, 1, NULL, 0),
(223, 'JPLM@UNIVALI.BR', 'JPLM@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '82dda7f0-a78a-45d6-bf37-3c12a138d39e', 0, 1, 1, 1, NULL, 0),
(224, 'LUIS AUGUSTO MACHADO MORETTO', 'LUISMORETTO@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5fd8adcc-ae38-461f-a97f-05559b1df9b6', 0, 1, 1, 1, NULL, 0),
(225, 'JR-RIBEIRO@UNIVALI.BR', 'JR-RIBEIRO@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd3d21319-f484-4eeb-81ce-ff90dffc0d7f', 0, 1, 1, 1, NULL, 0),
(226, 'CIRIO VIEIRA', 'CIRIOVIEIRA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'acdf03a3-29cc-4ac0-af43-e3c01c911560', 0, 1, 1, 1, NULL, 0),
(227, 'SAIONARA@FEPESE.UFSC.BR', 'SAIONARA@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e34ea73c-256f-4ea0-b6d3-e20fbf85b13b', 0, 1, 1, 1, NULL, 0),
(228, 'EDUARDO FOGAÇA', 'EDUARDO@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4725e4f2-bb4a-48f7-bc27-50548bbc87d7', 0, 1, 1, 1, NULL, 0),
(229, 'PATRYCK@FEPESE.UFSC.BR', 'PATRYCK@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'da87986a-5eb0-4ae0-8062-ad74c797a321', 0, 1, 1, 1, NULL, 0),
(230, 'SOBRAL@UNIVALI.BR', 'SOBRAL@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fa86ca7c-7613-484c-bc76-0d4fc8396a9c', 0, 1, 1, 1, NULL, 0),
(231, 'LUÍS AUGUSTO MACHADO MORETTO', 'MALACMA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2aff275c-16a1-4d30-932a-571585d82b82', 0, 1, 1, 1, NULL, 0),
(232, 'PASQUA@UNIVALI.BR', 'PASQUA@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bd385107-b9e4-424d-ab17-190ec1c36b2b', 0, 1, 1, 1, NULL, 0),
(233, 'RODRIGO DELLA PASQUA - VIRTUAL BRAZIL', 'RODRIGO@VIRTUALBRAZIL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7a6dafa4-6cf8-4df0-8455-d8caec6ebada', 0, 1, 1, 1, 204, 0),
(234, 'JANARA PEIXOTO', 'JANARAP@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'afa2d415-86ca-4242-af1b-f6063da1d19e', 0, 1, 1, 1, NULL, 0),
(235, 'JOAO GUILHERME DE OLIVEIRA', 'JOAO78@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0ddc4acf-15c0-492b-9e70-518f284c3c98', 0, 1, 1, 1, NULL, 0),
(236, 'JEAN', 'JEAN@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f646bb38-ff65-4379-a507-2d28603b2ff0', 0, 1, 1, 1, NULL, 0),
(237, 'PERFEITO@UNIVALI.BR', 'PERFEITO@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '45261826-680a-4a2e-b273-44eda8651913', 0, 1, 1, 1, NULL, 0),
(238, 'RODRIGO CORRÊA MARTINS', 'MCR_MARTINS@BRTURBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0e336b0c-7de6-4fcf-88d8-a0317cad56e9', 0, 1, 1, 1, NULL, 0),
(239, 'JOSÉ PAULO', 'JOSEPAULOLM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '28ea47a4-a7fe-423b-8094-276529037aed', 0, 1, 1, 1, 205, 0),
(240, 'JCOSTA@MATRIX.COM.BR COSTA', 'JCOSTA@MATRIX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a57edd72-b05f-4566-a49e-fe2596ea56da', 0, 1, 1, 1, NULL, 0),
(241, 'FBOTELHO@YAHOO.COM.BR', 'FBOTELHO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '57728dde-5bb9-49b3-b30b-24b0116cc72e', 0, 1, 1, 1, NULL, 0),
(242, 'RHIS@UNIVALI.BR', 'RHIS@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ecf7c4b4-625d-4a1e-9b5a-7f79bd2bb51d', 0, 1, 1, 1, NULL, 0),
(243, 'FABIO MACIEL FERNANDES', 'FMF@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5d4cb88a-f814-4a30-b10e-8320a5f343db', 0, 1, 1, 1, NULL, 0),
(244, 'SAUL SOUZA MULLER', 'SAULL@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd1c29807-5b4d-4d06-b357-3757d762a9be', 0, 1, 1, 1, NULL, 0),
(245, 'DRIOS@TERRA.COM.BR', 'DRIOS@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cab70be9-ca26-40ba-a38c-a40439b0cbf2', 0, 1, 1, 1, NULL, 0),
(246, 'BRUNO', 'BRUNOMUND@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c2666b6e-13f8-490d-b3a5-ea2fec376832', 0, 1, 1, 1, NULL, 0),
(247, 'PIJAMA.SHOW@ATLANTIDA.COM.BR', 'PIJAMA.SHOW@ATLANTIDA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8f1b0c2f-4493-4df3-9fa3-4338e5488342', 0, 1, 1, 1, NULL, 0),
(248, 'MISLENERICHARTZ@BOL.COM.BR', 'MISLENERICHARTZ@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b5379d1c-e262-467c-b119-29d200acd39f', 0, 1, 1, 1, NULL, 0),
(249, 'DR. EVANDRO', 'PETRI@NETMASTER.INF.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a66139ea-7909-4a3a-bcd2-009161fce61b', 0, 1, 1, 1, NULL, 0),
(250, 'JOÃO DE DEUS MACHADO NETO', 'JMACHADO@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5dd18bbe-9663-408e-b94c-57fa2e2e74af', 0, 1, 1, 1, NULL, 0),
(251, 'ALEXANDRE PY', 'ALEXANDREPY@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e181ce9b-c569-453c-b475-5399a6944ccb', 0, 1, 1, 1, 206, 0),
(252, 'ALEXANDRE PY', 'ALEXANDREPY@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '54309035-0e80-4920-8cca-2d9bd336f932', 0, 1, 1, 1, 207, 0),
(253, 'ANDRIKDIMITRII@GMAIL.COM', 'ANDRIKDIMITRII@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3ad700a7-fc58-4fff-a318-176302111773', 0, 1, 1, 1, NULL, 0),
(254, 'RAFAEL', 'RAFAEL@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0fd2dad2-4812-4534-acbc-7eccac42d0dd', 0, 1, 1, 1, NULL, 0),
(255, 'BRAMBILLA', 'BRAMBILLA@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd479cc3b-82ef-4e5d-aad3-1d899645cfa4', 0, 1, 1, 1, NULL, 0),
(256, 'FABIO.BARROS', 'FABIO.BARROS@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f064b231-cc00-40d2-9e96-e541ee71364f', 0, 1, 1, 1, NULL, 0),
(257, 'NELSON. SILVEIRA', 'NELSON.SILVEIRA@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6c68b9b8-02f8-4045-aa2d-f47b7469d0f7', 0, 1, 1, 1, NULL, 0),
(258, 'SNS_SC', 'SNS_SC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c2f72f22-8a65-4e69-9619-c98cdc3395af', 0, 1, 1, 1, NULL, 0),
(259, 'RODRIGO_LUIZ_DUARTE', 'RODRIGO_LUIZ_DUARTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1e66951a-2aee-4a99-b428-5e8a8aa2b77e', 0, 1, 1, 1, NULL, 0),
(260, 'FERCAR1@IG.COM.BR', 'FERCAR1@IG.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ffc5c4b3-ef6a-4149-8683-99b2d1ca5ce0', 0, 1, 1, 1, NULL, 0),
(261, 'RODRIGOMARTINS', 'RODRIGOMARTINS@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd7d320bd-2f77-463a-bb0b-83d9f7ca2782', 0, 1, 1, 1, NULL, 0),
(262, 'ACIDDEVIL', 'ACIDDEVIL@BRT14.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2c61665f-f08c-4cf1-8e65-01adf3fbd344', 0, 1, 1, 1, NULL, 0),
(263, 'ANAPAULADUTRA', 'ANAPAULADUTRA@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '32085715-7775-45e1-a2ca-ca131844c201', 0, 1, 1, 1, NULL, 0),
(264, 'ANDRIKDIMITRII', 'ANDRIKDIMITRII@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bae305a3-c896-428e-8b55-2cc4f0477a3e', 0, 1, 1, 1, NULL, 0),
(265, 'MALACMA@GMAI.COM', 'MALACMA@GMAI.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4ee8caf0-9d60-4551-a3f3-df4b2c1b0ba4', 0, 1, 1, 1, NULL, 0),
(266, 'NELSON SILVEIRA NETO - FLN', 'NELSON.SILVEIRA@FLN.POLITEC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'da8485c7-0ff3-4451-bed6-0d6e6c1d3b07', 0, 1, 1, 1, NULL, 0),
(267, 'TREINAMENTO@VOFFICE.COM.BR', 'TREINAMENTO@VOFFICE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b4ba113b-4c87-4f56-9ceb-351a4beeec1f', 0, 1, 1, 1, NULL, 0),
(268, 'PVALIM@UNIVALI.BR', 'PVALIM@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7628cdd4-82a4-468f-9eb0-1953a0905ab9', 0, 1, 1, 1, NULL, 0),
(269, 'JPEIXOTO@HOTMAIL.COM', 'JPEIXOTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '806445a3-b387-4f82-bf41-b5dcb6020e61', 0, 1, 1, 1, NULL, 0),
(270, 'RIHS', 'RIHS@IG.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cb23158d-cb47-4ab5-a610-83717fbb3ec8', 0, 1, 1, 1, NULL, 0),
(271, 'ROBSON', 'FORMOSO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4f38e444-7c4c-4c5b-a081-a64f9333c8ed', 0, 1, 1, 1, 208, 0),
(272, 'WILSON ALMEIDA', 'WNA6@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3368ff7c-9042-4d57-b806-20c3153051e6', 0, 1, 1, 1, NULL, 0),
(273, 'WILLIAN SAVI', 'WWSAVI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '761b084e-dc04-4d68-92a4-12622b0746f4', 0, 1, 1, 1, 209, 0),
(274, 'SCHERRY LEMOS', 'SCHERRY@CONTRONICS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b9fb9192-9c76-4ac8-b8cb-261190732840', 0, 1, 1, 1, NULL, 0),
(275, 'SAUL', 'SOULSSS@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ce380d53-8865-4bfd-b425-121b2150ddda', 0, 1, 1, 1, NULL, 0),
(276, 'ROGÉRIO JOSÉ HOFFMANN', 'ROGERIO@BRASAOSISTEMAS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '060e1f8a-8398-4249-a7f1-54b87cee7ca7', 0, 1, 1, 1, NULL, 0),
(277, 'RODRIGO@TELEWORLD.COM.BR', 'RODRIGO@TELEWORLD.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '06c9b916-c921-4027-8f47-ec45180be042', 0, 1, 1, 1, NULL, 0),
(278, 'RAFADAMAIA@GMAIL.COM', 'RAFADAMAIA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f4c6a270-6e91-495e-a54f-9a565c73961f', 0, 1, 1, 1, NULL, 0),
(279, 'MÁRCIO BITTENCOURT', 'BITT@FLORIPA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5ba5d9ee-fa67-48ed-a599-f8d943179aee', 0, 1, 1, 1, NULL, 0),
(280, 'MÁRCIO BEPPLER', 'M.BEPPLER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a0de80e2-ce65-4ba2-83b4-ecc70057bcf9', 0, 1, 1, 1, 210, 0),
(281, 'MURILO', 'MURILO@FEESC.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e1fa69f5-b48a-49da-9c20-ab560646f705', 0, 1, 1, 1, NULL, 0),
(282, 'MARCOS@FEPESE.UFSC.BR', 'MARCOS@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '656b156a-5fde-4b04-a7c7-4612d20d5e35', 0, 1, 1, 1, NULL, 0),
(283, 'MARCIO@FEPESE.UFSC.BR', 'MARCIO@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cb2da594-2942-4558-a87f-85d2d93753da', 0, 1, 1, 1, NULL, 0),
(284, 'MARCELINO@FEPESE.UFSC.BR', 'MARCELINO@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '18dceda0-dc04-42b2-9bc8-8ec042e35493', 0, 1, 1, 1, NULL, 0),
(285, 'MAIA', 'MAIANETO@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1b0ffbdd-4709-428d-a08a-05bda9f48c36', 0, 1, 1, 1, NULL, 0),
(286, 'LUIZ AUGUSTO LOUREIRO JUNIOR', 'LOUREIROJR@GLOBO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4614932c-fd05-4435-a450-b7b40440ae95', 0, 1, 1, 1, NULL, 0),
(287, 'LEO.SCHUCH@GMAIL.COM', 'LEO.SCHUCH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5b491908-21c4-48a0-934b-81fbcc5f8274', 0, 1, 1, 1, NULL, 0),
(288, 'JORGE PETRY', 'JORGEPNETO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a0f5afd9-4c68-409b-a572-3c9be92b49de', 0, 1, 1, 1, NULL, 0),
(289, 'IVAN GRAVE', 'IGRAVE@SEFAZ.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '310d6463-3e19-4906-ae80-46d0883d0f41', 0, 1, 1, 1, NULL, 0),
(290, 'GIOVANI.POLETTO@GMAIL.COM', 'GIOVANI.POLETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bba686f9-0dd4-43d1-a641-998d8fa33155', 0, 1, 1, 1, NULL, 0),
(291, 'GERSON@NPD.UFSC.BR', 'GERSON@NPD.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b05ceac6-4ba9-4eaa-9fd6-cc443e2cf1eb', 0, 1, 1, 1, NULL, 0),
(292, 'GERACIMO@FEPESE.UFSC.BR', 'GERACIMO@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8ba070a0-b327-4223-9109-bbafe40753f1', 0, 1, 1, 1, NULL, 0),
(293, 'FERNANDO SCHUTZ', 'FERNANDOSCHUTZ@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6824ac80-c217-48d1-8be3-0f4ec03d4f43', 0, 1, 1, 1, NULL, 0),
(294, 'FERNANDO@FEPESE.UFSC.BR', 'FERNANDO@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a771a321-b14d-40e0-894e-d5805af401fa', 0, 1, 1, 1, NULL, 0),
(295, 'FELIPE MELCHER DOS SANTOS', 'FELIPE@TVBV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6f94a82b-870a-4fe3-ad02-f6b8bbe580a1', 0, 1, 1, 1, NULL, 0),
(296, 'FELIPE FERRARI', 'FELIPEDOMINIUM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '36939441-f4b5-47a7-b7ab-59f161278054', 0, 1, 1, 1, NULL, 0),
(297, 'EMERSON@FEPESE.UFSC.BR', 'EMERSON@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '911f81f0-9a37-419d-8f56-8ffce4f37ccc', 0, 1, 1, 1, NULL, 0),
(298, 'DFTHIAGO@UOL.COM.BR', 'DFTHIAGO@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4da594dd-5242-4a86-85e8-af83c45e2fa3', 0, 1, 1, 1, NULL, 0),
(299, 'DANIEL', 'BLASS.DANIEL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3cffbde6-a044-4677-8566-8a58c7b2d011', 0, 1, 1, 1, 211, 0),
(300, 'CIRIO VIEIRA', 'CV11491@TJ.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fbbfbd9b-78bc-4169-9a25-1fb92440c260', 30, 1, 1, 1, NULL, 0),
(301, 'CAU', 'CANCELLIER@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd5a7417a-eafe-4820-b5b5-358a68016aa2', 0, 1, 1, 1, NULL, 0),
(302, 'ALMEIDA@FEPESE.UFSC.BR', 'ALMEIDA@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0eab82e9-6863-405f-9b23-cdf961e2f2ba', 0, 1, 1, 1, NULL, 0),
(303, 'ADRIANO', 'ADRIANO@FEPESE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd0760b49-c7ef-4f62-a281-e7c287a35fa2', 0, 1, 1, 1, NULL, 0),
(304, 'VICTORSENS', 'VICTORSENS@IG.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '996e50ee-3a96-4ea4-b4c8-d3570ae03f1b', 0, 1, 1, 1, NULL, 0),
(305, 'FELIPE@CIASOFT.NET', 'FELIPE@CIASOFT.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2a522fbf-2816-4a3f-ac47-242bda49fb9f', 0, 1, 1, 1, NULL, 0),
(306, 'JEFFERSON@CIASOFT.NET', 'JEFFERSON@CIASOFT.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ffc12edf-fad5-4df4-9bf1-f86a997610ae', 0, 1, 1, 1, NULL, 0),
(307, 'JOÃO GOULART', 'GOULART@CIASOFT.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '127111f1-75b1-491f-9e91-309a4d1801e1', 0, 1, 1, 1, NULL, 0),
(308, 'FABIO MATTOS DE BARROS - FLN', 'FABIO.BARROS@FLN.POLITEC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '51425953-7fc8-4dc4-ae6d-1ac286574910', 0, 1, 1, 1, NULL, 0),
(309, 'SERGIONS', 'SERGIONS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8d6539b6-548f-4a25-89fa-26e922f84e2b', 0, 1, 1, 1, 212, 0),
(310, 'RODRIGO.LUIZDUARTE', 'RODRIGO.LUIZDUARTE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4462929c-6238-4df8-be01-0daa14dcf89e', 0, 1, 1, 1, 213, 0),
(311, 'GUSTHAVO TORRES DA VEIGA PEREIRA', 'ACIDDEVIL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7256230a-c2a2-4d5b-ae92-30d6fc90e922', 0, 1, 1, 1, NULL, 0),
(312, 'PAULO.ISOTEC@BERUTBO.COM.BR', 'PAULO.ISOTEC@BERUTBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2144ddba-b66f-45ef-9d0d-3c3a6d0916e2', 0, 1, 1, 1, NULL, 0),
(313, 'PAULO.ISOTEC@BRUTBO.COM.BR', 'PAULO.ISOTEC@BRUTBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9580c05e-e69c-406a-beaa-18ae2716ad17', 0, 1, 1, 1, NULL, 0),
(314, 'PAULO.ISOTEC@BRTURBO.COM.BR', 'PAULO.ISOTEC@BRTURBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bf31ce94-435d-4e78-95d4-700446bf6230', 0, 1, 1, 1, NULL, 0),
(315, 'RENATOPO@INF.UFSC.BR', 'RENATOPO@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '198cc044-aa8a-4d59-a5d2-80e5d5680df8', 0, 1, 1, 1, NULL, 0),
(316, 'JANAINA', 'JANAINA.COSTA@NEXXERA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '97b7420f-265e-4d68-b971-ab9135fd1dff', 0, 1, 1, 1, NULL, 0),
(317, 'MALACMA@MALACMA.CJB.NET', 'MALACMA@MALACMA.CJB.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5f50e380-a2fc-45ff-b239-4395d967c4f9', 0, 1, 1, 1, NULL, 0),
(318, 'ADRIANA GOULART', 'ADRIANA@CIASOFT.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '720c4022-cda5-4e27-9833-e8c07b1d22ea', 0, 1, 1, 1, NULL, 0),
(319, 'ADRIANAGOULART@FLORIPA.COM.BR', 'ADRIANAGOULART@FLORIPA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '65a9c99e-2a97-4a77-8617-4a8567f225fa', 0, 1, 1, 1, NULL, 0),
(320, 'CURRICULOS2005@GMAIL.COM', 'CURRICULOS2005@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8f3ea197-e2f5-4972-8eef-ad6748884174', 0, 1, 1, 1, NULL, 0),
(321, 'ATENDIMENTO@ADEPTSYSTEMS.COM.BR', 'ATENDIMENTO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '07bbcad2-cc3c-4d7e-9b04-2cbec40fa1e3', 0, 1, 1, 1, NULL, 0),
(322, 'NÍVIO DOS SANTOS', 'NIVIO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '87fbd717-74e8-4d29-88e0-045de4052c18', 0, 1, 1, 1, NULL, 0),
(323, 'ANDERSON MEDEIROS GASPAR', 'ANDERSONMGASPAR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ed7f5092-16ce-467d-b102-157a6db3d4ae', 0, 1, 1, 1, 214, 0),
(324, 'KCAMPOS@UNIVALI.BR', 'KCAMPOS@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4b8be98d-230c-49bb-b275-1698035f9348', 0, 1, 1, 1, NULL, 0),
(325, 'MARCELLO THIRY', 'MARCELLO.THIRY@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fcccd204-27a6-4d49-8a6c-00945af3e9d6', 0, 1, 1, 1, 215, 0),
(326, 'MARCELLO THIRY', 'MARCELLOTHIRY@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e82427f0-bfdd-4346-968b-d2f7100d1100', 0, 1, 1, 1, 216, 0),
(327, 'OSWALDO DANTAS', 'OSWALDODANTAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '96ab38d6-5ca1-40d9-8328-8d3eea33199e', 0, 1, 1, 1, 217, 0),
(328, 'OSWALDO CAVALCANTI DANTAS JUNIOR', 'OSWALDO@SENSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1ab29890-bd84-449d-8af9-5aefc2e33334', 0, 1, 1, 1, NULL, 0),
(329, 'OLIVEIRA@BADESC.GOV.BR', 'OLIVEIRA@BADESC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b1daebd8-48f8-493b-9637-699e345bcfdf', 0, 1, 1, 1, NULL, 0),
(330, 'KLEBER@BADESC.GOV.BR', 'KLEBER@BADESC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd554c34e-4459-4463-883e-abcc8f453865', 0, 1, 1, 1, NULL, 0),
(331, 'JEAN CARLO', 'JCSANTOOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '68473570-525a-45fb-9571-0f5c08b932d5', 0, 1, 1, 1, NULL, 0),
(332, 'EISTEIN@MAIL.COM', 'EISTEIN@MAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cd3384fc-7abe-41fb-aac8-63d7a3e7fe0e', 0, 1, 1, 1, NULL, 0),
(333, 'LUIZ FERNANDO GAMBA', 'LFGAMBABR@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5917158b-9f02-4765-8c7e-ace66ff70b9b', 0, 1, 1, 1, 218, 0),
(334, 'CVARDA', 'CVARDA@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '770b4b87-57c1-4fcb-9714-9e655adf0863', 0, 1, 1, 1, 219, 0),
(335, 'CVARDA', 'CVARDA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9937344f-d081-485e-800b-fa320eaa1d9e', 0, 1, 1, 1, 220, 0),
(336, 'FERNANDOSCHUTZ', 'FERNANDOSCHUTZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '457fb5c6-502d-4de8-bb67-0bf082cf3d32', 0, 1, 1, 1, 221, 0),
(337, 'SIMONE MORETTO', 'SIMONAO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '20876367-060e-48ae-ba64-28904a5d4467', 0, 1, 1, 1, NULL, 0),
(338, 'MEURER@BADESC.GOV.BR', 'MEURER@BADESC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7839a5f5-ed89-4eb7-9b96-f1ca0005daeb', 0, 1, 1, 1, NULL, 0),
(339, 'SIMONE MORETTO', 'SIMONE.MORETTO@REASON.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1d4f62d4-3221-42ae-a421-68bf351a4ae7', 0, 1, 1, 1, NULL, 0),
(340, 'PAULO ROBERTO RICCIONI GONCALVES', 'RICCIONI@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fcdf3d97-69cd-42c6-ae6d-cbcc1bd467d7', 0, 1, 1, 1, NULL, 0),
(341, 'PAULO ROBERTO RICCIONI GONCALVES', 'RICCIONI@TCE.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '58d20f61-3502-48e7-aa51-de2cd3fc3758', 0, 1, 1, 1, NULL, 0),
(342, 'SELEÇÃO INSIDE SYSTEM', 'SELECAO@INSIDESYSTEM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '97bec6ad-0682-415f-bf92-029ad747f265', 0, 1, 1, 1, NULL, 0),
(343, 'THIAGOBORN@HOTMAIL.COM', 'THIAGOBORN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b472b4bd-c1a5-44d7-840f-2c873b679938', 0, 1, 1, 1, NULL, 0),
(344, 'FINANCEIRO@ASPESCOLA.COM.BR', 'FINANCEIRO@ASPESCOLA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '274f4bdb-706c-4287-ae1b-d19b1a2493f0', 0, 1, 1, 1, NULL, 0),
(345, 'VINÍCIUS MEDINA KERN', 'KERN@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a0fd811c-9a23-4390-a2d4-2b30ae2bc5cb', 0, 1, 1, 1, 222, 0),
(346, 'VINÍCIUS MEDINA KERN', 'VMKERN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd4ac9e63-9da5-4944-8ccf-b34bc164eddc', 0, 1, 1, 1, 223, 0),
(347, 'RENATO', 'CISLAGHI@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ca616945-8852-4298-9f9e-27c58c04bff1', 0, 1, 1, 1, NULL, 0),
(348, 'JEFFERSON R. RAMOS DE SOUSA', 'EFFERSON@CIASOFT.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b592aef3-5278-45e8-b28b-0575c0212c69', 0, 1, 1, 1, NULL, 0),
(349, 'JANAINA COSTA', 'HEYJANAC@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2b93c407-46f3-482d-ac02-102b932e0284', 0, 1, 1, 1, NULL, 0),
(350, 'RAPOSO@CANADAS.COM.BR', 'RAPOSO@CANADAS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b294f99c-d3a0-4c67-9d2b-d83809fc3da5', 0, 1, 1, 1, NULL, 0),
(351, 'MICHELLE@LUMISCONSTRUTORA.COM.BR', 'MICHELLE@LUMISCONSTRUTORA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '990559a1-86d1-4843-a724-f1447a46d9b8', 0, 1, 1, 1, NULL, 0),
(352, 'PAULINE VERONEZ', 'PAULINE@MERCADO.PPG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f1cc00a3-df07-4ff5-af1e-f712c4314f0d', 0, 1, 1, 1, NULL, 0),
(353, 'FELIPE.GEVAERD@HOTMAIL.COM', 'FELIPE.GEVAERD@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8a6b1213-216e-4bb7-956c-69107e2e5ad5', 0, 1, 1, 1, NULL, 0),
(354, 'CELYSA', 'CELYSA@MERCADO.PPG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'be2e3635-6a00-48bb-b19b-ebcd787c9fa9', 0, 1, 1, 1, NULL, 0),
(355, 'FABIANO@ADEPTSYSTEMS.COM.BR', 'FABIANO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e19ecc0c-8128-4529-abe1-ce321dd6ab55', 0, 1, 1, 1, NULL, 0),
(356, 'NERI@EPS.UFSC.BR', 'NERI@EPS.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3ad81959-5a05-4aa5-84a0-33e0043bcde4', 0, 1, 1, 1, NULL, 0),
(357, 'LUIS@BADESC.GOV.BR', 'LUIS@BADESC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '668eec38-9042-4f67-966f-00a59fdbe4bd', 0, 1, 1, 1, NULL, 0),
(358, 'LORIVAL NUNES DE OLIVEIRA', 'LORIVAL@IMOVEISFLORIPA.CIM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0adf7408-4fe0-4d86-b7a1-193de27369bb', 0, 1, 1, 1, NULL, 0),
(359, 'COMPUTACAO - UNISUX', 'COMPUTACAO_UNISUX@GRUPOS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '79879b65-259b-45d6-9491-f7e08b6f9d4e', 0, 1, 1, 1, NULL, 0),
(360, 'SOUMARCIO22@YAHOO.COM.BR', 'SOUMARCIO22@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bae90f7c-21e0-43fc-8e81-89b6ef37170c', 0, 1, 1, 1, NULL, 0),
(361, 'ALEXANDRE MULLER', 'ALEXD.MULLER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8d5f1a53-9cc7-43d2-8436-51a1ede88d6a', 0, 1, 1, 1, NULL, 0),
(362, 'BARBARA@IPTRUST.COM.BR', 'BARBARA@IPTRUST.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5d930735-17cc-4326-99bd-27d192522579', 0, 1, 1, 1, NULL, 0),
(363, 'FGEVAERD@BRTURBO.COM', 'FGEVAERD@BRTURBO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6e4f1cd4-fb51-498e-bdea-7e5572c3f215', 0, 1, 1, 1, NULL, 0),
(364, 'SAC YADATA', 'SAC@YADATA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c8127419-f134-46d5-b2ef-c277fdf867f4', 0, 1, 1, 1, NULL, 0),
(365, '"LORIVAL@IMOVEISFLORIPA.CIM.BR"', '"LORIVAL@IMOVEISFLORIPA.CIM.BR"', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7d9cdf52-2122-4f44-89d0-3a48dc1d3a87', 0, 1, 1, 1, NULL, 0),
(366, 'LATOSENSU@CSE.UFSC.BR', 'LATOSENSU@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '64b3afdb-8338-4c6e-9a5b-f2aeee05d0dc', 0, 1, 1, 1, NULL, 0),
(367, 'GILSONKIND@GMAIL.COM.BR', 'GILSONKIND@GMAIL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '12812808-5e2a-475a-8aa9-f55364c5b9e8', 0, 1, 1, 1, NULL, 0),
(368, 'GILSONKIND@GMAIL.COM', 'GILSONKIND@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a083bd3a-82bc-4479-a5af-30f4c78217c6', 0, 1, 1, 1, NULL, 0),
(369, 'RICARDO DOS REIS RODRIGUES', 'RICARDO@YADATA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd2e071ed-6560-49bb-a932-57c9b7f3e62f', 0, 1, 1, 1, NULL, 0),
(370, 'TIRADUVIDAS@JAVAMAGAZINE.COM.BR', 'TIRADUVIDAS@JAVAMAGAZINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '49758504-3b27-473e-bde3-af59da01625f', 0, 1, 1, 1, NULL, 0),
(371, 'VENDAS@IMOVEISFLORIPA.CIM.BR', 'VENDAS@IMOVEISFLORIPA.CIM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8d79c300-53e5-48be-b8f1-8f4006c2c841', 0, 1, 1, 1, NULL, 0),
(372, 'FABIANA@ADEPTSYSTEMS.COM.BR', 'FABIANA@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bc0c49af-2aad-4a87-9d1f-f1532389a7fb', 0, 1, 1, 1, NULL, 0),
(373, 'SELECAO@STELA.ORG.BR', 'SELECAO@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '84357ffb-589f-439a-811b-64444e6d905a', 0, 1, 1, 1, NULL, 0),
(374, 'RODRIGO MARTINS SANTANA', 'RODRIGO.SANTANA@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '30bbf782-3af3-4ed6-87dd-d405e0cbc323', 0, 1, 1, 1, NULL, 0),
(375, 'LUCIANOPY@HOTMAIL.COM', 'LUCIANOPY@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f32d30aa-f5ff-4654-b785-de1e757a5000', 0, 1, 1, 1, NULL, 0),
(376, 'MAURICIO FERNANDES PEREIRA', 'MPEREIRA@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6edf82e9-b1b9-4b7a-9ee7-33358e3b7561', 0, 1, 1, 1, NULL, 0),
(377, 'MALLMANN@INF.UFSC.BR', 'MALLMANN@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '151278d0-8f8d-439b-a217-31457a91a1dc', 0, 1, 1, 1, NULL, 0),
(379, 'MARLON CANDIDO GUERIOS', 'MARLON@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ea5ee3ae-35dc-4afb-8d20-1540ad4367e9', 0, 1, 1, 1, NULL, 0),
(380, 'MARCELO DOMINGOS', 'DOMINGOS@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2d8a0a1e-a7aa-4cf8-9e49-33bd8f53cf03', 0, 1, 1, 1, NULL, 0),
(381, 'ALESSANDRA CASSES ZOUCAS', 'AZOUCAS@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '37b47108-b90f-408a-8719-b560d682ca29', 0, 1, 1, 1, NULL, 0),
(382, 'MADJA', 'MADJARIZZO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0dbe308c-0efd-44e5-9bb1-368b4754da58', 0, 1, 1, 1, NULL, 0),
(383, 'LUIS AUGUSTO MACHADO MORETTO', 'MORETTO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cd10b962-aa94-4ab4-8197-49f3650e548f', 0, 1, 1, 1, NULL, 0),
(384, 'ADILSON', 'ADILSON@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f0cea344-3f89-43d5-820e-59161c2eccf4', 0, 1, 1, 1, NULL, 0),
(385, 'JADER@BADESC.GOV.BR', 'JADER@BADESC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '02643f48-7f64-4549-bfe3-0f22fa96b147', 0, 1, 1, 1, NULL, 0),
(386, 'ELUARD OLIVEIRA DE SOUZA', 'ELUARD@BADESC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6584957c-ab59-40fd-aa61-3c01c9e22624', 0, 1, 1, 1, NULL, 0),
(387, 'MARIO@BADESC.GOV.BR', 'MARIO@BADESC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a5c6143d-7814-444e-95cb-2e1ccae31d5a', 0, 1, 1, 1, NULL, 0),
(388, 'PEDRO_BADESC', 'PEDRO_ZU@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ad6fc612-a3de-492e-ad67-66854b2a5d6e', 0, 1, 1, 1, NULL, 0),
(389, 'ÉRICO LIMA', 'ERICO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '18b38c36-9f88-4c19-9998-fbebbab29065', 0, 1, 1, 1, NULL, 0),
(390, 'RONI@ADEPTSYSTEMS.COM.BR', 'RONI@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '43095d88-8d12-4e97-8a03-a1beed08ea20', 0, 1, 1, 1, NULL, 0),
(391, 'MARIO GILBERTO DE SOUZA', 'MARIOGS@BADESC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bf490614-42e7-48d4-8413-4d4aed82b95f', 0, 1, 1, 1, NULL, 0),
(392, 'OKDEVELOPER@HOTMAIL.COM', 'OKDEVELOPER@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '90d3f518-2d6e-4147-ba7a-64384fda59e5', 0, 1, 1, 1, NULL, 0),
(393, 'GIANCARLO JULIANO DOS SANTOS', 'GIANCARLO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '512bcdac-2b8c-4754-8764-6b42d4a54c63', 0, 1, 1, 1, 225, 0),
(394, 'ALEXANDRE@ADEPTSYSTEMS.COM.BR', 'ALEXANDRE@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6c19f61a-4214-4c07-a566-55bad7895078', 0, 1, 1, 1, NULL, 0),
(395, 'MARCIO@INSIDESYSTEM.COM.BR', 'MARCIO@INSIDESYSTEM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a19aee65-f622-45e0-958a-0176571f1082', 0, 1, 1, 1, NULL, 0),
(396, 'DESENVOLVIMENTO GERENCIAL', 'DG2006@GRUPOS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '27c25051-6062-46e7-a087-ad58adbb8043', 0, 1, 1, 1, NULL, 0),
(397, 'PATRICK BORGES CASSETTARI', 'PCASSETTARI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b11facf0-6f89-41b9-b4aa-da1c96a3dbf4', 0, 1, 1, 1, 226, 0),
(398, 'VARDANEG@YAHOO.COM.BR', 'VARDANEG@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e48f806e-ffe1-4422-ba08-7de17290c33e', 0, 1, 1, 1, NULL, 0),
(399, 'LEANDRO CALLEGARI', 'LEANDROAH@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1f6db66b-b09b-4693-9c87-590501a350bd', 0, 1, 1, 1, NULL, 0),
(400, 'KLAUS', 'KLAUS@PMF.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2f43a9e9-3d8f-425c-8088-bf10129affe5', 0, 1, 1, 1, NULL, 0),
(401, 'FERNANDA CUNHA', 'FECUNHA34@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2d11e6f5-d22e-4717-8034-00a78ea3cb03', 0, 1, 1, 1, NULL, 0),
(402, 'RODRIGOM@INSIDESYSTEM.COM.BR', 'RODRIGOM@INSIDESYSTEM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '080f23a4-8012-4a04-beff-d9d631387c4e', 0, 1, 1, 1, NULL, 0),
(403, 'JOAHNET@IELSC.ORG.BR', 'JOAHNET@IELSC.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '52f31df0-f1a6-496d-9529-e3fbbf875e1c', 0, 1, 1, 1, NULL, 0),
(404, 'VÍCTOR CESAR SOARES DESCARDECI', 'VICTOR.CSD@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'df0d3bb2-29d0-4c4b-b811-912b338e99b6', 0, 1, 1, 1, NULL, 0),
(405, 'NEGÃO DA FEPESE - FALCA (EMERSON) TUIUIU', 'LINDONEGO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a1d0883-a983-4939-8756-f091ed199137', 0, 1, 1, 1, 227, 0),
(406, 'CENTRAL@STARPOINT.COM.BR', 'CENTRAL@STARPOINT.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '44c93d04-9b94-42da-9e62-dde794135834', 0, 1, 1, 1, NULL, 0),
(407, 'EDUARDO@DVE-SES.SC.GOV.BR', 'EDUARDO@DVE-SES.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fbf9212f-2497-4f7a-acf9-bd5e28bea6ac', 0, 1, 1, 1, NULL, 0),
(408, 'ANDRÉ RICARDO VILELA', 'ARVILELA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a534411e-fe83-4e43-b8ff-672368858239', 0, 1, 1, 1, NULL, 0),
(409, 'NIVIO', 'NIVIO@PIENGENHARIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '42a9d164-5e40-4d2c-9911-cc2b1cfa1d33', 0, 1, 1, 1, NULL, 0),
(410, 'NIVIO.SANTOS@MOVECRM.COM.BR', 'NIVIO.SANTOS@MOVECRM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7f2c9d08-388a-40d0-a4e4-1e9ed2de59c8', 0, 1, 1, 1, NULL, 0),
(411, 'JPANDOLFO', 'JPANDOLFO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '58719629-0dd3-431d-8094-7a77301ce02e', 0, 1, 1, 1, NULL, 0),
(412, 'ISMAEL BREJINSKI DE ALMEIDA - FORT GROUP SEGUROS', 'ISMAEL@FORTGROUPSEGUROS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'feaa9d1e-71c7-490b-8913-675deccf78d5', 0, 1, 1, 1, NULL, 0),
(413, 'SERGIO@CSMTELECOM.COM', 'SERGIO@CSMTELECOM.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '27b9358d-29aa-442b-a195-244b68fbe1cb', 0, 1, 1, 1, NULL, 0),
(414, 'FABIANOTRISTAO', 'FABIANOTRISTAO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6b71564e-7300-4cfc-9fdb-c0478c69d587', 0, 1, 1, 1, NULL, 0),
(415, 'ANTENORJUNIOR', 'ANTENORJUNIOR@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6ec7f0d0-209d-4259-bc06-2f24e888203a', 0, 1, 1, 1, NULL, 0),
(416, 'FERNANDAGORGES', 'FERNANDAGORGES@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '519c4d5c-79ce-4dca-9a5a-60c34e2d6441', 0, 1, 1, 1, 228, 0),
(417, 'JEFERSON PANDOLFO', 'JEFERSON@FPOLIS.SC.SENAC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a2d4cc05-0d00-4e03-b69b-b43cebab356e', 0, 1, 1, 1, NULL, 0),
(418, 'LEONARDO@ADEPSYSTEMS.COM.BR', 'LEONARDO@ADEPSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c1467e0-cf31-4ea9-a89a-e551739a6633', 0, 1, 1, 1, NULL, 0),
(419, 'XBOARD@XBOARD.COM.BR', 'XBOARD@XBOARD.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e9f7df29-9609-42a4-bb3d-46a3a30bb382', 0, 1, 1, 1, NULL, 0),
(420, 'RONI CIRINO JUNIOR', 'RONI@ADEPTMEC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1499d9c4-4fe2-45d6-bf51-be961f240ac3', 0, 1, 1, 1, NULL, 0),
(421, 'CURRICULO@JTECH-SC.COM.BR', 'CURRICULO@JTECH-SC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7809ec04-88a9-4aca-919e-4d1f8ead4f73', 0, 1, 1, 1, NULL, 0),
(422, 'RH@SUNTECH.COM.BR', 'RH@SUNTECH.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'be06d5f4-bcdb-472f-9b2c-27f98a22e865', 0, 1, 1, 1, NULL, 0),
(423, 'RIALTO-DEV', 'RIALTO-DEV@YAHOOGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd0c73fac-0617-4842-b220-b6e809ef4b1b', 0, 1, 1, 1, NULL, 0),
(424, 'RIALTO-DEV-SUBSCRIBE@YAHOOGROUPS.COM', 'RIALTO-DEV-SUBSCRIBE@YAHOOGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '93730acd-6eda-427f-a6d4-4288595bc589', 0, 1, 1, 1, NULL, 0),
(425, 'LEONARDO@ADEPTSYSTEMS.COM.BR', 'LEONARDO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'de92176c-b875-4e9a-ad6c-3ef955227f0b', 0, 1, 1, 1, NULL, 0),
(426, 'PROBST, A.F.', 'PROBST@SUNTECH.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a1805cec-8089-4d33-b45a-fd30cb525711', 0, 1, 1, 1, NULL, 0),
(427, 'FAMILIA MÄRTINS', 'MAERTINS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '87ce7cf0-cb97-46b3-8a30-77c9e0daa5f1', 0, 1, 1, 1, 229, 0),
(428, 'JOAO BOSCO DA MOTA ALVES', 'JBOSCO@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e5c784b5-fc2b-44b7-a633-9700ab3abff2', 0, 1, 1, 1, 230, 0),
(429, 'RLINHARES & ADVOGADOS ASSOCIADOS - THIAGO TEIXEIRA', 'RLINHARES@BRTURBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9f5630ef-5583-44cd-bd53-3a672e96282a', 0, 1, 1, 1, NULL, 0),
(430, 'LUIZ CARLOS PERRONE MACHADO PERRONE', 'ARTSVOCARLOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5d2f2a13-3b57-4131-b47c-1184bbe37f31', 0, 1, 1, 1, 231, 0),
(431, 'DESENVOLVIMENTO GERENCIAL', 'DESENVOLVIMENTO.GERENCIAL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '580b59bd-5cc6-4563-9f5d-9e9d0e5c5a18', 0, 1, 1, 1, NULL, 0),
(432, 'RONI', 'ADEPT@ADEPTMEC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b9eed280-22e4-4e45-b437-9941faba9c64', 0, 1, 1, 1, NULL, 0),
(433, 'RAQUEL_AGENDA@HOTMAIL.COM', 'RAQUEL_AGENDA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2e989b90-5647-4311-b2ca-c9c45c28cfe5', 0, 1, 1, 1, NULL, 0),
(434, 'FABIO@PAUTA.COM.BR', 'FABIO@PAUTA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '79c91daa-a1cd-4747-8be9-0d14e654e772', 0, 1, 1, 1, NULL, 0),
(435, 'DERLISSC@HOTMAIL.COM', 'DERLISSC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '474fac0f-1ce3-402e-9212-11690d6dc2e7', 0, 1, 1, 1, NULL, 0),
(436, 'DERLISRC@HOTMAIL.COM', 'DERLISRC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '90f918a2-40e1-488c-a23e-fd5c40ad62e9', 0, 1, 1, 1, NULL, 0),
(437, 'DERLISCR@HOTMAIL.COM', 'DERLISCR@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '16c35cd4-e39c-44b8-802d-5ac505c7337f', 0, 1, 1, 1, NULL, 0),
(438, 'NO_REPLY@YAHOOGROUPS.COM', 'NO_REPLY@YAHOOGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '17e16bc5-8fd4-4b12-966a-2e68662c4904', 0, 1, 1, 1, NULL, 0),
(439, 'SERGIO@ADEPTSYSTEMS.COM.BR', 'SERGIO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b2fa4a8e-9946-4af4-aea1-0c8f85114bf8', 0, 1, 1, 1, NULL, 0),
(440, 'WESLEY@ADEPTSYS.COM.BR', 'WESLEY@ADEPTSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '71fa4302-3c8d-4375-a4d9-e91c93f7d1f9', 0, 1, 1, 1, NULL, 0),
(441, 'MÁRIO DE SOUZA ALMEIDA', 'ALMEIDA@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0a7f47a7-05e4-4a9e-bebe-858c4860db4b', 0, 1, 1, 1, NULL, 0),
(442, 'EDUARDO TEALDI FOGAÇA', 'ETFOGACA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ce69f9f3-9ff9-4c48-817f-090166115961', 0, 1, 1, 1, 232, 0),
(443, 'EDUARDOFOGACA@SAUDE.SC.GOV.BR', 'EDUARDOFOGACA@SAUDE.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6c9eff53-9efe-4f57-9b42-dba796bafb2e', 0, 1, 1, 1, NULL, 0),
(444, 'MAMACAVALO@GMAIL.COM', 'MAMACAVALO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'feb70d7a-57e6-421d-a1a5-618860209f89', 0, 1, 1, 1, NULL, 0),
(445, 'TÂNIA KARISE VOIGT', 'TVOIGT@QUICKSOFT.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '82f3383b-001f-478d-9372-104ba97b93a0', 0, 1, 1, 1, NULL, 0),
(446, 'WSFURQUIM FURKA', 'WSFURQUIM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9d48ab99-ba3b-40b3-9c37-f25075bb3b80', 0, 1, 1, 1, 233, 0),
(447, 'GERDAU', 'GERDAU@CLAVECONSULTORIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b67ee77-a0e5-48be-ab24-3c654011aeed', 0, 1, 1, 1, NULL, 0),
(448, 'HELPDESK@PROFIT-TI.COM.BR', 'HELPDESK@PROFIT-TI.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '38ed88fc-24b5-4d5b-a740-287282abfa19', 0, 1, 1, 1, NULL, 0),
(449, 'RODRIGO SCHULZ', 'JACASCHULZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd00b1af0-b64e-4f15-9b3f-7ad3776515ff', 0, 1, 1, 1, NULL, 0),
(450, 'FLORZINHADECRISTO@HOTMAIL.COM', 'FLORZINHADECRISTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7e6df559-ec85-42d7-962e-43e3c92f8ebf', 0, 1, 1, 1, NULL, 0),
(451, 'LEOMULER@GMAIL.COM', 'LEOMULER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fdd30504-5031-46d3-840e-ca9aa99217ee', 0, 1, 1, 1, NULL, 0),
(452, 'VIOLINO@GMAIL.COM', 'VIOLINO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '82a174f7-70cf-482f-9edb-e8172e9e3a56', 0, 1, 1, 1, NULL, 0),
(453, 'ANDERSON@ADEPTSYS.COM.BR', 'ANDERSON@ADEPTSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b51b47d5-bcf8-404b-9a8b-8aee9cb6c8be', 0, 1, 1, 1, NULL, 0),
(454, 'SILVIA@ADEPTSYS.COM.BR', 'SILVIA@ADEPTSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'acc4c9fc-a347-4c66-af4e-bbabd0bb2a55', 0, 1, 1, 1, NULL, 0),
(455, 'SERGIO COSTA', 'SERGIOCOSTA.FLN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c874f582-1fe6-44f9-89f5-3006b541bfb6', 0, 1, 1, 1, 234, 0),
(456, 'HAMER ESTEVES', 'HAMER_ARAUJO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6e416bf8-37c0-4c72-9d40-1079d1099212', 0, 1, 1, 1, NULL, 0),
(457, 'WILLIAN VERAS', 'WILLIANVERAS@IG.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0b04ae8a-ccf9-487c-976f-c8a52d3fb8f6', 0, 1, 1, 1, NULL, 0),
(458, 'RAFAEL LUIZ OLINGER', 'OLINGER@POP.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '09843783-5cd3-4b3a-966e-5dd4cc72f04b', 0, 1, 1, 1, NULL, 0),
(459, 'SIMPLE CREATIVE', 'SIMPLECR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '81df78c0-65c1-4689-be77-383ba12340ac', 0, 1, 1, 1, NULL, 0),
(460, 'MORETT@ADEPTSYS.COM.BR', 'MORETT@ADEPTSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '335bc246-c943-4cb7-ade5-42d2ec6ab463', 0, 1, 1, 1, NULL, 0),
(461, 'RIZZATTI@CSE.UFSC.BR', 'RIZZATTI@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fcac914f-d782-450a-a83b-33c228ad728b', 0, 1, 1, 1, NULL, 0),
(462, 'DANIEL MARINHO', 'DARISIL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2bb11200-7d14-44b8-b411-3fe3ed56ed8a', 0, 1, 1, 1, 235, 0),
(463, 'ADAIL.NOGUEIRA@AUDARE.COM.BR', 'ADAIL.NOGUEIRA@AUDARE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9fb175f9-6d8f-41ef-b2dd-28bb8e0c5de2', 0, 1, 1, 1, NULL, 0),
(464, 'NOGUEIRA@AUDARE.COM.BR', 'NOGUEIRA@AUDARE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5dbc7967-b597-420d-8012-982de3e82241', 0, 1, 1, 1, NULL, 0),
(465, 'CAROLINA LEGAL ♪', 'CAROL.GRANADA.LEAL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cd432db9-5a97-43de-aa60-59beae2d2230', 0, 1, 1, 1, 236, 0),
(466, 'MUSIK ER GODT FOR DIG!', 'THIAGOBORN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5f5472f1-f688-44a6-9096-5a212f3c9206', 0, 1, 1, 1, 237, 0),
(467, 'SOLANGE MACHADO MORETTO', 'SOLANGE@SESC-SC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '740f271c-f542-44c3-8f7b-40057d1c3ccb', 0, 1, 1, 1, NULL, 0),
(468, 'FRANCISCO MIGUEL MORAIS', 'FRANCISCO@CTAI.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3813363c-43ff-4fcc-a90a-fd240aa09ab1', 0, 1, 1, 1, NULL, 0),
(469, 'RIALTO-DEV FRIEDMEN', 'DFRIED2007@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7d6ff136-1c6f-4547-8a96-1707e3371aba', 0, 1, 1, 1, NULL, 0),
(470, 'RICHARD@SENAI-SC.IND.BR', 'RICHARD@SENAI-SC.IND.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c841226d-f4df-4b9c-95fc-1f854de364c4', 0, 1, 1, 1, NULL, 0),
(471, 'SANDROEUFRASIO@GMAIL.COM', 'SANDROEUFRASIO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '99960ec3-c80c-43b0-a50b-b7902b66c3ca', 0, 1, 1, 1, NULL, 0),
(472, 'TALENTOS.COOL@COOL.COM.BR', 'TALENTOS.COOL@COOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b2fd5c57-713e-4e16-a24d-94c70324b4aa', 0, 1, 1, 1, NULL, 0),
(473, 'JAVASCRIPT_OFFICIAL@YAHOOGROUPS.COM', 'JAVASCRIPT_OFFICIAL@YAHOOGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b0e5840-d675-4ed8-9b1a-bc697afe7fcc', 0, 1, 1, 1, NULL, 0),
(474, 'EMERSON PALMEIRA', 'EMEJCMICROS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f078089f-48a9-4a95-b1c2-080cc5651450', 0, 1, 1, 1, NULL, 0),
(475, 'MARLI@VOFFICE.COM.BR', 'MARLI@VOFFICE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '988a208c-37e8-4047-a8a8-f7636f9a40be', 0, 1, 1, 1, NULL, 0),
(476, 'NIVIO DOS SANTOS', 'NIVIO.SANTOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b706bf90-604e-4013-9a9a-7f390da68bab', 0, 1, 1, 1, 238, 0),
(477, 'RODRIGO BRITO', 'RODRIG.BRITO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0f9e6848-587d-47e1-a5ac-21208bb49f6b', 0, 1, 1, 1, NULL, 0),
(478, 'HARIDEVA@GRAD.UFSC.BR', 'HARIDEVA@GRAD.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1cf1c87a-d2d8-4256-b7b3-c3060684f313', 0, 1, 1, 1, NULL, 0),
(479, 'DANIEL QUADROS SILVEIRA', 'SLAXDEM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eef3e122-32da-437c-ba73-e4d2a9f82398', 0, 1, 1, 1, NULL, 0),
(480, 'CBALIT@IMPROVE.FR', 'CBALIT@IMPROVE.FR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c675df88-5fe1-4cd9-95e5-fc318fc46c62', 0, 1, 1, 1, NULL, 0),
(481, 'DG2006-UFSC', 'DG2006-UFSC@GRUPOS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c000b100-9322-4fbe-a2d4-fa7b0df40211', 0, 1, 1, 1, NULL, 0),
(482, 'ARTIGOS@MUNDOJAVA.COM.BR', 'ARTIGOS@MUNDOJAVA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b9c5f176-0665-4a13-a858-227acb6cccc5', 0, 1, 1, 1, NULL, 0),
(483, 'ANDEGIL@GMAIL.COM', 'ANDEGIL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3da15729-3fea-4d08-9fa4-0e54c3205bee', 0, 1, 1, 1, NULL, 0),
(484, 'ARRUDAJEAN@HOTMAIL.COM', 'ARRUDAJEAN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2eaf709b-1462-4887-9dd3-2da415d04004', 0, 1, 1, 1, NULL, 0),
(485, 'ARTIGOS@JAVAMAGAZINE.COM.BR', 'ARTIGOS@JAVAMAGAZINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '64081fd4-cf9c-47db-a848-42f0864fda10', 0, 1, 1, 1, NULL, 0),
(486, 'GUERRA@MUNDOJAVA.COM.BR', 'GUERRA@MUNDOJAVA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '59f72b27-49d8-4ae1-b044-d21b9c3f3aa4', 0, 1, 1, 1, NULL, 0),
(487, 'CONTATO@GLOBALCODE.COM.BR', 'CONTATO@GLOBALCODE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bc40635f-0d21-44eb-80a6-f78e74a3cab7', 0, 1, 1, 1, NULL, 0),
(488, 'JAVA@GLOBALCODE.COM.BR', 'JAVA@GLOBALCODE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '05ab466f-29bb-4323-be32-452da2b657f8', 0, 1, 1, 1, NULL, 0),
(489, 'LUÍS MORETTO NETO', 'MORETTO.NETO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6d47659e-ea16-4731-8c4a-0d8ebf082a6e', 0, 1, 1, 1, NULL, 0),
(490, 'CARLOS RIVERA', 'CARLOS.RIVERA@GURUONLINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd1b88ad8-b513-4574-b51d-fb89380e6736', 0, 1, 1, 1, NULL, 0);
INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(491, 'ENOMOTO@GURUONLINE.COM.BR', 'ENOMOTO@GURUONLINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b6cc8965-4f45-417f-9df9-0a430f567579', 0, 1, 1, 1, NULL, 0),
(492, 'ARTIGOS MUNDOPM', 'ARTIGOS@MUNDOPM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5920380e-7d35-4d94-ab84-2ca99cf05767', 0, 1, 1, 1, NULL, 0),
(493, 'CARREIRA@V2TELECOM.COM.BR', 'CARREIRA@V2TELECOM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '66a9ab5a-4e7e-4a1e-91d5-7af2f2c867d7', 0, 1, 1, 1, NULL, 0),
(494, 'MISLENE.LEGAL@HOTMAIL.COM', 'MISLENE.LEGAL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7cf37559-e3e2-4ad5-8128-7415b9d56244', 0, 1, 1, 1, NULL, 0),
(495, 'ODAIR JOSÉ CUSTODIO', 'ODAIR@SPECTO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '57ea1aa2-eee6-47d2-b6ef-85b606935f3f', 0, 1, 1, 1, NULL, 0),
(496, 'HELYSON LEWIS VELASCO', 'HELYSON@SENSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4f1a9e7f-bf59-43e9-8e11-f75414552698', 0, 1, 1, 1, 239, 0),
(497, 'ANDRIK.ALBUQUERQUE@INNOVIT.COM.BR', 'ANDRIK.ALBUQUERQUE@INNOVIT.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '29f95b2a-ee9f-40d1-b8a0-49bf22ade420', 0, 1, 1, 1, NULL, 0),
(498, 'MALACMA-DFHRWTCJ-AF3QHSVK@PROD.WRITELY.COM', 'MALACMA-DFHRWTCJ-AF3QHSVK@PROD.WRITELY.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd5191126-2636-4f27-8085-562c22e9ae9a', 0, 1, 1, 1, NULL, 0),
(499, 'FABRÍCIO NEES', 'FNEES@V2TELECOM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '30c3dc24-2012-4800-93e6-cf1a3a8184b3', 0, 1, 1, 1, NULL, 0),
(500, 'RH@FLN.POLITEC.COM.BR', 'RH@FLN.POLITEC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8ab1a8af-8c65-4ca1-82c1-9fbac662b09e', 0, 1, 1, 1, NULL, 0),
(501, 'RH@NUMERA.COM.BR', 'RH@NUMERA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b7ca35fa-3444-4747-bf11-865bb485bd46', 0, 1, 1, 1, NULL, 0),
(502, 'FLEXDEV@GOOGLEGROUPS.COM', 'FLEXDEV@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee1ce988-ef81-4faf-be2a-a0a65693a60a', 0, 1, 1, 1, NULL, 0),
(503, 'ELANO MACHADO', 'ELANO@GMX.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e0640c08-1bb6-4ad6-9849-fce568187e23', 0, 1, 1, 1, NULL, 0),
(504, 'LUIZ', 'LUIZ@ATIMOSC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aba982b0-f11e-4a0f-86a3-4636c87960d3', 0, 1, 1, 1, NULL, 0),
(505, 'SÉRGIO GUILHERME DE QUEIROZ', 'SERGIO.QUEIROZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '04f6d828-9df1-429d-ade6-b258793648e9', 0, 1, 1, 1, NULL, 0),
(506, 'ANDREZA.LUPI@AUDACES.COM.BR', 'ANDREZA.LUPI@AUDACES.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '61e5966c-e9d9-494b-9189-381a31248ae3', 0, 1, 1, 1, NULL, 0),
(507, 'TALENTOS@SENIORFLORIANOPOLIS.COM.BR', 'TALENTOS@SENIORFLORIANOPOLIS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3c99de2a-8356-437a-8d00-f542352a85b5', 0, 1, 1, 1, NULL, 0),
(508, 'OPORTUNIDADES@VIRTUEM.COM.BR', 'OPORTUNIDADES@VIRTUEM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1ad16bb6-0b66-46b9-be4c-e0b8bda25751', 0, 1, 1, 1, NULL, 0),
(509, 'CURRICULO@GENNERA.COM.BR', 'CURRICULO@GENNERA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd959317f-3e98-4c40-9fba-7c374452b5b9', 0, 1, 1, 1, NULL, 0),
(510, 'OVIEDO@VHINFOSERV.COM.BR', 'OVIEDO@VHINFOSERV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '89d9c165-3cd5-45e5-b9bb-a5381748268d', 0, 1, 1, 1, NULL, 0),
(511, 'SELECAOHCM@DATASUL.COM.BR', 'SELECAOHCM@DATASUL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3d5b3ffe-1ad2-471a-9989-4ffa3a617f81', 0, 1, 1, 1, NULL, 0),
(512, 'RH@POWERLOGIC.COM.BR', 'RH@POWERLOGIC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7e43a9db-33a2-4413-a209-458302f35dc4', 0, 1, 1, 1, NULL, 0),
(513, 'EJERRICA2@SUPERVISIONCARE.INFO', 'EJERRICA2@SUPERVISIONCARE.INFO', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aca984a5-77ae-408a-8bec-e2affa4e73a0', 0, 1, 1, 1, NULL, 0),
(514, 'DRÊ', 'DREZIUS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4542c9cd-4756-4dce-97f8-9fb865ef083f', 0, 1, 1, 1, 240, 0),
(515, 'LUIZ FERNANDO GAMBA', 'LUIZFERNANDOGAMBA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '62ab1672-2fa4-48fe-b5e7-33b027340a71', 0, 1, 1, 1, NULL, 0),
(516, 'BRUNO@ADEPTSYS.COM.BR', 'BRUNO@ADEPTSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '289f0a25-fd4c-48df-a147-3a8b68edbefc', 0, 1, 1, 1, NULL, 0),
(517, 'EDILSON@ATIMOSOFTWARE.COM.BR', 'EDILSON@ATIMOSOFTWARE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '85564a59-ce75-4686-ad52-8763fb47f4a9', 0, 1, 1, 1, NULL, 0),
(518, 'BRUNO@ADEPTSYSTEMS.COM.BR', 'BRUNO@ADEPTSYSTEMS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eef4106f-c732-4396-9073-479c95be28da', 0, 1, 1, 1, NULL, 0),
(519, 'RH@AUDACES.COM.BR', 'RH@AUDACES.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd72dcadc-8b7b-4732-b053-e6bfd4aeb705', 0, 1, 1, 1, NULL, 0),
(520, 'AMARTIM@VIRTUEM.COM.BR', 'AMARTIM@VIRTUEM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '905b3943-926c-470e-aec7-c31ff0c9d172', 0, 1, 1, 1, NULL, 0),
(521, 'ALESSANDRA MARTINS DE OLIVEIRA', 'AMARTINS@VIRTUEM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b028016-efd8-4a53-8737-880fcd1652ae', 0, 1, 1, 1, NULL, 0),
(522, 'MIMORETTO', 'MIMORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '63e65ea7-cb55-4a86-ab54-a2d9d842b60a', 0, 1, 1, 1, NULL, 0),
(523, 'MIMORETTO', 'MISLENE.LEGAL_@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '03b81f0e-cc84-45ac-b0f9-f97b659dd439', 0, 1, 1, 1, NULL, 0),
(524, 'DANIEL@TIBOX.COM.BR', 'DANIEL@TIBOX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1014a23c-912d-4158-8d06-32090b753b46', 0, 1, 1, 1, NULL, 0),
(525, 'AVA-EE-J2EE-PROGRAMMING-WITH-PASSION-SUBSCRIBE@GOOGLEGROUPS.COM', 'AVA-EE-J2EE-PROGRAMMING-WITH-PASSION-SUBSCRIBE@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '900ad13e-fd76-4851-b0f9-10067a645be8', 0, 1, 1, 1, NULL, 0),
(526, 'ALEXANDRE SANTANA CAMPELO', 'ALEQI200@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f52dea7e-cb80-4feb-9b96-7ced5de41953', 0, 1, 1, 1, 241, 0),
(527, 'NORBERTO. ENOMOTO', 'NORBERTO.ENOMOTO@GURUONLINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ba4ea88a-5b25-47ca-a8fe-ca2f8354f609', 0, 1, 1, 1, NULL, 0),
(528, 'ENOMOTO, NORBERTO', 'NORBERTO.ENOMOTO@EDS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6401d743-c4dd-4b69-ad17-95c7e2605f44', 0, 1, 1, 1, NULL, 0),
(529, 'FERNANDOSOARESJR@GMAIL.COM', 'FERNANDOSOARESJR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fe604725-959d-4156-a4a6-d7707c8c0f85', 0, 1, 1, 1, NULL, 0),
(530, 'EDSON ANDRADE', 'EDRENAN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '63dfbc75-fd3b-4288-bef1-574f04668d18', 0, 1, 1, 1, 242, 0),
(531, 'THUNDERBALLVERIFICATIONDEPT@YAHOO.CO.UK', 'THUNDERBALLVERIFICATIONDEPT@YAHOO.CO.UK', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '96dc6207-0622-4471-b564-c87b1c0a71ef', 0, 1, 1, 1, NULL, 0),
(532, 'RDIAS@MAKING.COM.BR', 'RDIAS@MAKING.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e02c335e-9a08-4fda-b0e6-b4744715a6d9', 0, 1, 1, 1, NULL, 0),
(533, 'LORIVAL@PORTOSEGUROIMOVEIS.COM.BR', 'LORIVAL@PORTOSEGUROIMOVEIS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee9bda5d-6b74-4d49-9fcc-fb1f095b2b0c', 0, 1, 1, 1, NULL, 0),
(534, 'NEMESIS 2WEB', 'NEMESIS2WEB@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9681533e-23f5-4c9a-893f-44bbd960b9ce', 0, 1, 1, 1, NULL, 0),
(535, 'ELIANE.VEIGAIS@DIGITRO.COM.BRCO', 'ELIANE.VEIGAIS@DIGITRO.COM.BRCO', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '25421eac-ba8a-4e19-9446-7cc1326b0f58', 0, 1, 1, 1, NULL, 0),
(536, 'ELIANE.VEIGAIS@DIGITRO.COM.BR', 'ELIANE.VEIGAIS@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dfd2cbd9-0195-4dd7-a481-df91aab24370', 0, 1, 1, 1, NULL, 0),
(537, 'ELIANE.VEIGAS@DIGITRO.COM.BR', 'ELIANE.VEIGAS@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '415f2e76-b5fb-4e32-a879-ce8d64459a11', 0, 1, 1, 1, NULL, 0),
(538, 'ELIANE.VIEGAS@DIGITRO.COM.BR', 'ELIANE.VIEGAS@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a574fec2-b030-4913-8225-caf6711e895c', 0, 1, 1, 1, NULL, 0),
(539, 'PAULO HENRIQUE PEREIRA', 'PAULOHENRIQUEPEREIRA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd0e2a3e9-55bf-4422-a030-70fc8ef29a05', 0, 1, 1, 1, NULL, 0),
(540, 'BRUNO LEAL FREITAS', 'BRLEAL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4d7208c2-576e-405a-805e-c6ca7d4f483c', 0, 1, 1, 1, 243, 0),
(541, 'ANNA MARIA TEIXEIRA', 'ANNA@CTAI.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2da06681-dbf9-4471-885c-ff25fec37a73', 0, 1, 1, 1, NULL, 0),
(542, 'MAURO SÉRGIO SILVA', 'MAUROSERGIOSILVA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '84622be0-57b7-4f0e-aa4a-453ffd5c4c18', 0, 1, 1, 1, 244, 0),
(543, 'JUSCIELYMC@IELSC.ORG.BR', 'JUSCIELYMC@IELSC.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '10f9dec8-bc59-405a-80c0-b5ffb6201b7a', 0, 1, 1, 1, NULL, 0),
(544, 'DJONI SILVA', 'DJONISILVA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b2a59902-3a14-4274-bede-caf0c3db1e33', 0, 1, 1, 1, NULL, 0),
(545, 'ANGELO.SMELO@YAHOO.COM', 'ANGELO.SMELO@YAHOO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '34ed2640-5b08-4434-979c-62e2241b4386', 0, 1, 1, 1, NULL, 0),
(546, 'RENATO BACK', 'RENATO.BACK@SPECTO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e208f58b-ea8e-4806-a91c-afa39904f3ae', 0, 1, 1, 1, NULL, 0),
(547, 'OSWALDO CAVALCANTI DANTAS JÚNIOR', 'OSWALDO.CAVALCANTI@MOVECRM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8f056a62-6ca5-46a6-b22d-e5325ab85b63', 0, 1, 1, 1, NULL, 0),
(548, 'GABRIEL BARRETO', 'GABRIEL.MAIL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5d4ac927-c90d-4979-8b87-ce92f8c8f62d', 0, 1, 1, 1, NULL, 0),
(549, 'LUIDI VILLELA DE ABREU ANDRADE', 'LUIDIVA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '83b2d9ef-7f82-4a3f-b45a-b94773290ecf', 0, 1, 1, 1, NULL, 0),
(550, 'MAURICIO VALENTE', 'MAU.VALENTE@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '09480df0-e6e1-4261-816d-e6f3eb5238e7', 0, 1, 1, 1, NULL, 0),
(551, 'ATENDIMENTO NETCARREIRAS', 'ATENDIMENTO@NETCARREIRAS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '481f9f5f-37e4-4b9e-805a-fd9e58183e12', 0, 1, 1, 1, NULL, 0),
(552, 'MOACIR.MARQUES@DIGITRO.COM.BR', 'MOACIR.MARQUES@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ec350ed9-0177-4ecc-9c7c-e9c6108cd2d3', 0, 1, 1, 1, NULL, 0),
(553, 'ANELIM@YAHOO.COM.BR', 'ANELIM@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9255c637-b125-448c-b8f2-f193832d9eea', 0, 1, 1, 1, NULL, 0),
(554, 'ANELIM@GMAIL.COM', 'ANELIM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c879c637-d9ab-4a84-9987-1640080a50e7', 0, 1, 1, 1, NULL, 0),
(555, 'USER@XSTREAM.CODEHAUS.ORG', 'USER@XSTREAM.CODEHAUS.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '281a69a2-a2eb-4f6c-aaea-604b15d6db8d', 0, 1, 1, 1, NULL, 0),
(556, 'FABIO ARAUJO', 'FABIO.ARAUJO@SUN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5a1e5990-13f5-4042-b193-323d59524268', 0, 1, 1, 1, NULL, 0),
(557, 'VANESSA DE OLIVEIRA', 'JOSIANE.BRITO@SUN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '367ef2ee-a73b-4981-a361-57f92e1c8729', 0, 1, 1, 1, NULL, 0),
(558, 'LEONARDO DE OLIVEIRA', 'LEONARDOFLN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2430cb34-5a7f-4fbb-95df-c6457cd0bca6', 0, 1, 1, 1, 245, 0),
(559, 'RSOUZA@INF.UFSC.BR', 'RSOUZA@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f90369f3-cc7d-4260-8d41-74bf3b21fa08', 0, 1, 1, 1, NULL, 0),
(560, 'ASSINATURA MUNDOJAVA', 'ASSINATURAS@MUNDOJAVA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '91b939c7-8292-4c71-a39c-5f679c24ad7d', 0, 1, 1, 1, NULL, 0),
(561, 'ROBERTO.JUNIOR@SUN.COM', 'ROBERTO.JUNIOR@SUN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2b8803b3-ab04-4097-a3ce-3305df288459', 0, 1, 1, 1, NULL, 0),
(562, 'SUHAS WALANJOO', 'SUHAS.WALANJOO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e4c4a267-9e7d-4f5e-acdd-9ac475240e86', 0, 1, 1, 1, 246, 0),
(563, 'SIMONE.NABARRO@SUN.COM', 'SIMONE.NABARRO@SUN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '988e2f32-c39d-4b1f-8253-0561a1be2760', 0, 1, 1, 1, NULL, 0),
(564, 'SUN.EDUCATION@SUN.COM', 'SUN.EDUCATION@SUN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '72289a42-d76a-47b7-af75-fe47a915de3e', 0, 1, 1, 1, NULL, 0),
(565, 'LOGIN@SUN.COM', 'LOGIN@SUN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9afbb1ff-a0e5-4c0e-904d-d27c2b5a28f1', 0, 1, 1, 1, NULL, 0),
(566, 'IGOR@SUNCAMISETAS.COM.BR', 'IGOR@SUNCAMISETAS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee929144-2944-4ced-92b4-c789fe6dc1a1', 0, 1, 1, 1, NULL, 0),
(567, 'MABILIS2805@HOTMAIL.COM', 'MABILIS2805@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '23dd3982-2077-48c7-9b82-42a8f3afaf47', 0, 1, 1, 1, NULL, 0),
(568, 'OSANAROSA@HOTMAIL.COM', 'OSANAROSA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '22b60b09-57a3-4d53-988a-8c9e0fcf666e', 0, 1, 1, 1, NULL, 0),
(569, 'MARI VIEIRA', 'MARIETIZINHA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2d80cce8-1af9-4a51-8347-fdabd61695b9', 0, 1, 1, 1, NULL, 0),
(570, 'GEOCESCONETTO@BOL.COM.BR', 'GEOCESCONETTO@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cc086036-c3ab-45dd-b448-a89c387b5718', 0, 1, 1, 1, NULL, 0),
(571, 'GABY FAC', 'GABY301171@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '30c5280b-1646-4e7e-8699-5a54c96f877c', 0, 1, 1, 1, NULL, 0),
(572, 'GÉSSICA', 'GESSICAFLOR@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f053fac4-644e-4431-8ddc-68f8fe02ac29', 0, 1, 1, 1, NULL, 0),
(573, 'GU_RAPOSO@HOTMAIL.COM', 'GU_RAPOSO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b1b75c5-653f-4e91-8377-9b716d832ffc', 0, 1, 1, 1, NULL, 0),
(574, 'GKBORDIGNON@HOTMAIL.COM', 'GKBORDIGNON@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd232c5ee-f41b-4ee0-b491-a52e37b94a76', 0, 1, 1, 1, NULL, 0),
(575, 'MONIQUELOCH@HOTMAIL.COM', 'MONIQUELOCH@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5ab3cf4f-68cf-4ae2-b08c-c56686c541d3', 0, 1, 1, 1, NULL, 0),
(576, 'GABI_SRF@HOTMAIL.COM', 'GABI_SRF@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7eec1647-c140-424d-8a4d-32587260cc43', 0, 1, 1, 1, NULL, 0),
(577, 'NAOINTERESSA@HOTMAIL.COM', 'NAOINTERESSA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f192e37c-a9e0-4868-991c-4ab25e78d22d', 0, 1, 1, 1, NULL, 0),
(578, 'FNEGROMONTE@HOTMAIL.COM', 'FNEGROMONTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ff527714-cea0-4993-9fa4-4c45be19fc47', 0, 1, 1, 1, NULL, 0),
(579, 'RPTARROBA@HOTMAIL.COM', 'RPTARROBA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0fe01035-28cd-4e6d-93d8-27881cb2dcf3', 0, 1, 1, 1, NULL, 0),
(580, 'RAFALIMA8@HOTMAIL.COM', 'RAFALIMA8@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b797f593-1a07-4d89-83d6-fb722e37f25b', 0, 1, 1, 1, NULL, 0),
(581, 'MORETTOELIANE@HOTMAIL.COM', 'MORETTOELIANE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd586af09-9c17-4ddf-b176-dddf6c82bfe7', 0, 1, 1, 1, NULL, 0),
(582, 'FELIPE_CESCO@HOTMAIL.COM', 'FELIPE_CESCO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '97e7eb50-890f-4c6a-8611-5e86e5f7f8ab', 0, 1, 1, 1, NULL, 0),
(583, 'VALENTINASCHMITT@HOTMAIL.COM', 'VALENTINASCHMITT@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '205c2758-20dd-4845-a1f9-07ad28375aee', 0, 1, 1, 1, NULL, 0),
(584, 'SÉRGIO', 'SCBNAPPI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9f02bb44-4370-4270-8aa9-fe6f4dd702e7', 0, 1, 1, 1, NULL, 0),
(585, 'ROBERTO.VAZ@GMAIL.COM', 'ROBERTO.VAZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '064d4e54-5454-4ebe-8697-5f0b96fc1068', 0, 1, 1, 1, NULL, 0),
(586, 'JANAÍNA SEMPRE BOM', 'JANASSB@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '03505d25-e2b7-47cc-8653-9ab7805d1ad0', 0, 1, 1, 1, NULL, 0),
(587, 'MABILIS@BRTURBO.COM.BR', 'MABILIS@BRTURBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6e482f95-6a48-4e64-ad5a-bac267b63b57', 0, 1, 1, 1, NULL, 0),
(588, 'DUVIDOQUEEXISTA@HOTMAIL.COM', 'DUVIDOQUEEXISTA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8212b652-0c06-41c8-bacc-12a94d1e4ab7', 0, 1, 1, 1, NULL, 0),
(589, 'MAIRA.ST@HOTMAIL.COM', 'MAIRA.ST@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1824418f-e998-4164-8731-c20c5a3e58ad', 0, 1, 1, 1, NULL, 0),
(590, 'MARCELO ROMEIRO DA ROSA', 'MARCELORR@STI.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '744a2c3b-d632-4882-9ae3-1dac557607f8', 0, 1, 1, 1, NULL, 0),
(591, 'NISANDRA@POLOCONSULTORIA.COM.BR', 'NISANDRA@POLOCONSULTORIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '26f5c409-4c6e-4c33-bc86-6476a113b937', 0, 1, 1, 1, NULL, 0),
(592, 'RAFAELLA.TAVARES@HOTMAIL.COM', 'RAFAELLA.TAVARES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '60096f7a-719a-40be-9ca1-74be92f82034', 0, 1, 1, 1, NULL, 0),
(593, 'NIBUENO', 'NI.BUENO@IBEST.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0f6f03ba-c774-4495-82e1-7972a61c534d', 0, 1, 1, 1, NULL, 0),
(594, 'ROBERTO.ROSETO@TERRA.COM.BR', 'ROBERTO.ROSETO@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6da82bc2-2e38-4c97-b6dc-dcf315ad4f05', 0, 1, 1, 1, NULL, 0),
(595, 'GUILHERME@GDACONSTRUCOES.COM.BR', 'GUILHERME@GDACONSTRUCOES.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '738dd720-354e-4acc-a2ff-cb0ccc0a6cc3', 0, 1, 1, 1, NULL, 0),
(596, 'JEFERSONSILVA.BR@HOTMAIL.COM', 'JEFERSONSILVA.BR@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd8243821-3dd2-482e-a9e4-b6da777ecd88', 0, 1, 1, 1, NULL, 0),
(597, 'RAFASILVA75@HOTMAIL.COM', 'RAFASILVA75@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b12d7c68-7308-4df0-9dc5-3f5e15a0345f', 0, 1, 1, 1, NULL, 0),
(598, 'GEOBALBINO@HOTMAIL.COM', 'GEOBALBINO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a8eedb4e-49c8-421c-8d59-404c5f9802f6', 0, 1, 1, 1, NULL, 0),
(599, 'JAQUE_RH', 'JAQUELINE@FECOAGRO.COOP.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aa11c607-4fe8-4567-9e1c-c9b080ec0753', 0, 1, 1, 1, NULL, 0),
(600, 'MANOELACGOULART@HOTMAIL.COM', 'MANOELACGOULART@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '992df781-48bf-46c1-88c4-ad186e12d0db', 0, 1, 1, 1, NULL, 0),
(601, 'MAÍRA SEVERO TEIXEIRA', 'MAIRAST@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '08afb582-c9ca-47ae-a873-5886c850e28b', 0, 1, 1, 1, 247, 0),
(602, 'MICHEL NUNES', 'MICHEL_NUNES@HOTMAIL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7008aef3-108f-4e2e-81e8-e51c3c07ff44', 0, 1, 1, 1, NULL, 0),
(603, 'SO_ALFACINHA@HOTMAIL.COM', 'SO_ALFACINHA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '98fdd79c-761d-4612-84f6-e7567a2fa910', 0, 1, 1, 1, NULL, 0),
(604, 'ODIVALFILHO@YAHOO.COM', 'ODIVALFILHO@YAHOO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e2eb1fb6-d9d1-48c0-8afb-4a2c4e6c81f9', 0, 1, 1, 1, NULL, 0),
(605, 'GÉSSICA', 'GESSICA@GEEESUL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eb9b7d73-fba9-4a20-b8c9-6df4f71b0f0e', 0, 1, 1, 1, NULL, 0),
(606, 'GUI', 'GUI@GDACONSTRUCOES.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a2bf068-8df5-4b1d-9dfd-16671b447f59', 0, 1, 1, 1, NULL, 0),
(607, 'GESSIKAFLORES@HOTMAIL.COM', 'GESSIKAFLORES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f141607c-1040-4db0-85a3-9086515045e9', 0, 1, 1, 1, NULL, 0),
(608, 'MANUELA LOSSO', 'MCLOSSO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e3a383d8-f264-4621-a735-6ac1d477a8f9', 0, 1, 1, 1, NULL, 0),
(609, 'LUIS.MORETTO@DIGITRO.COM.BR', 'LUIS.MORETTO@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '398efed2-dcc9-4dd2-845f-ee5154b7aea8', 0, 1, 1, 1, NULL, 0),
(610, 'VENDAS@MEMORYHOUSE.COM.BR', 'VENDAS@MEMORYHOUSE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5a7cf67b-ab41-44f2-88b2-89db94c66d0c', 0, 1, 1, 1, NULL, 0),
(611, 'MEMORYHOUSE1@HOTMAIL.COM', 'MEMORYHOUSE1@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f46ac7f3-7531-4152-8f71-e98794ebbc02', 0, 1, 1, 1, NULL, 0),
(612, 'EXP', 'EXP@MEMORYHOUSE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c2e7d09f-a860-4333-9df0-bce44b2c8007', 0, 1, 1, 1, NULL, 0),
(613, 'VENDASMEMORYHOUSE@HOTMAIL.COM', 'VENDASMEMORYHOUSE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0cdb33c7-a992-4f3e-8f32-fe88445fa5b2', 0, 1, 1, 1, NULL, 0),
(614, 'TCD@RHPERFIL.COM.BR', 'TCD@RHPERFIL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '459c8576-bb7b-4479-a827-797afd269a96', 0, 1, 1, 1, NULL, 0),
(615, 'FABIO.NUNES@NAVITA.COM.BR', 'FABIO.NUNES@NAVITA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '261561ed-4274-4bb4-8a66-9872a7af23fe', 0, 1, 1, 1, NULL, 0),
(616, 'RAQUEL PETRUK EACHIMENCO JUSTINO', 'RAQUEL.JUSTINO@DATASUL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f5e4d93b-13d3-4b57-8dcc-09a3f7f83715', 0, 1, 1, 1, NULL, 0),
(617, 'CALL4PAPERS@RSJUG.ORG', 'CALL4PAPERS@RSJUG.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c90df473-2d2b-4197-8005-1b10a72b28ad', 0, 1, 1, 1, NULL, 0),
(618, 'LUIDI ANDRADE', 'LUIDIVA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a01a3fea-6f1a-457d-9a5a-c54c19073103', 0, 1, 1, 1, 248, 0),
(619, 'MIGUEL.RIVEIRO@DIGITRO.COM.BR', 'MIGUEL.RIVEIRO@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd67b45b9-64a3-4793-a27b-2529563afc31', 0, 1, 1, 1, NULL, 0),
(620, 'MIGUEL RIVERO NETO', 'MIGUEL.RIVERO@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6561500e-8032-44ee-93e5-474b0552929a', 0, 1, 1, 1, 249, 0),
(621, 'RAQUEL.SANTOS@DIGITRO.COM.BR', 'RAQUEL.SANTOS@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '09399cbc-2ebc-4d70-97e4-e44021eca8b9', 0, 1, 1, 1, NULL, 0),
(622, 'SIMONE MORETTO', 'SIMONE.MORETTO@EADADM.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c591e3f4-8579-4e58-8645-9e5b8ed37732', 0, 1, 1, 1, NULL, 0),
(623, 'WEBMASTER@DRJAVA.DE', 'WEBMASTER@DRJAVA.DE', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '78aaad5e-0f87-4095-995f-e75bf8c75913', 0, 1, 1, 1, NULL, 0),
(624, 'RECRUIT@IMOLINFO.IT', 'RECRUIT@IMOLINFO.IT', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '277d661f-40e9-4fc7-8b5f-e4bc065c6ebd', 0, 1, 1, 1, NULL, 0),
(625, 'RAQUEL N', 'RAQUELNTS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '86764c0c-7964-437a-8fb3-cdd77b19290a', 0, 1, 1, 1, NULL, 0),
(626, 'LUCAS.MARIN@PIXEON.COM.BR', 'LUCAS.MARIN@PIXEON.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dad14ec4-463d-4403-8f73-6e8b0bfa9ec8', 0, 1, 1, 1, NULL, 0),
(627, 'GABRIELA.SANTOS@ATOSORIGIN.COM', 'GABRIELA.SANTOS@ATOSORIGIN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e1a70238-07da-4c2a-abfe-3d21cbcb1845', 0, 1, 1, 1, NULL, 0),
(628, 'GABRIEL BARRETO', 'GABRIELFLORIPA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3d2b5244-c97b-4074-8a6f-313aeac4c14e', 0, 1, 1, 1, NULL, 0),
(629, 'JOAOWERLANG@HOTMAIL.COM', 'JOAOWERLANG@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ccff7640-cd4b-45d4-97f7-08dfa8ee6042', 0, 1, 1, 1, NULL, 0),
(630, 'OLIVEIRA, CARLOS JOSE R', 'CARLOSRIVERA.OLIVEIRA@EDS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8bad01a5-800c-4b8a-afe5-508f945d5c33', 0, 1, 1, 1, NULL, 0),
(631, 'LUIS.MORETTO@GURUONLINE.COM.BR', 'LUIS.MORETTO@GURUONLINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '68e0afbc-278e-49b7-958a-610703f8f1f6', 0, 1, 1, 1, NULL, 0),
(632, 'BOARD', 'BOARD@PORTALBPM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bed440dc-6198-42a3-ab23-22e86494b30f', 0, 1, 1, 1, NULL, 0),
(633, 'MAURICIO VALENTE', 'MAU_VALENTE@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fd35db71-d35a-4519-88b3-cd11c8e0843a', 0, 1, 1, 1, NULL, 0),
(634, 'ZARBATO@EPAGRI.RCT-SC.BR', 'ZARBATO@EPAGRI.RCT-SC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ce024cc5-dd98-4408-9b51-31d4704102d3', 0, 1, 1, 1, NULL, 0),
(635, 'TALENTOS@BOLSADETALENTOS.COM.BR', 'TALENTOS@BOLSADETALENTOS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f17898c4-dd2e-4bb0-9396-0888ee65cc4a', 0, 1, 1, 1, NULL, 0),
(636, 'APS@DIGITRO.COM.BR', 'APS@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1dd0be66-e95d-415d-b721-a97b539fc942', 0, 1, 1, 1, NULL, 0),
(637, 'MOACIR MARQUES', 'ENGENHEIROMARQUES@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c5195cc7-abc4-4fe0-a818-4704a9ccce66', 0, 1, 1, 1, NULL, 0),
(638, 'LEANDRO', 'LEANDROMARQUES80@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e081bd69-82b6-42f8-877a-b642cd4427c7', 0, 1, 1, 1, NULL, 0),
(639, 'ARMANDO QUADROS NETO', 'ARMANDOQUADROS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '731049d5-a654-41ba-a88c-a1b29813789c', 0, 1, 1, 1, NULL, 0),
(640, 'MARCOS.KERECKI@DIGITRO.COM.BR', 'MARCOS.KERECKI@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '428bc35d-9e40-4618-bf0c-7269ca0df679', 0, 1, 1, 1, NULL, 0),
(641, 'SONALI@TERRA.COM.BR', 'SONALI@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '576ea335-4456-4e6c-aa51-c2573a4f3dba', 0, 1, 1, 1, NULL, 0),
(642, 'FABIOLA_BAGATINI@YAHOO.COM.BR', 'FABIOLA_BAGATINI@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a17e7299-dd29-4e83-a1a8-9cf326e4972f', 0, 1, 1, 1, NULL, 0),
(643, 'CARINE BLATT', 'CARINE.BLATT@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f85de042-01be-4e80-9857-8fe86f4562c0', 0, 1, 1, 1, 250, 0),
(644, 'STUMM@EGC.UFSC.BR', 'STUMM@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '99f58170-c0ad-403f-a3f1-49a5a5c3dd44', 0, 1, 1, 1, NULL, 0),
(645, 'KERN', 'KERN@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9a0f586f-2f63-4550-86e8-03da46722c2b', 0, 1, 1, 1, NULL, 0),
(646, 'BEAW@INF.UFSC.BR', 'BEAW@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4256f7b3-ec21-4fcd-b3ff-ba0d4a4b12ec', 0, 1, 1, 1, NULL, 0),
(647, 'RONNIE FAGUNDES DE BRITO', 'RONNIEFBRITO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '84040b46-08e1-4b3d-a26b-67f5209e136b', 0, 1, 1, 1, 251, 0),
(648, 'SALM@STELA.ORG.BR', 'SALM@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '18a0d8e2-0744-4696-84a0-63137c0e4a47', 0, 1, 1, 1, NULL, 0),
(649, 'JEAN HAUCK', 'JEANHAUCK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7abd3c15-da28-41e2-a8a4-ac9b1d740c9e', 0, 1, 1, 1, 252, 0),
(650, 'CABRAL@TELEMEDICINA.UFSC.BR', 'CABRAL@TELEMEDICINA.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fb48ba0e-e457-4dc7-bed1-d7ed67996389', 0, 1, 1, 1, NULL, 0),
(651, 'COSER@EGC.UFSC.BR', 'COSER@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3231db1b-3393-408a-b9cc-de4b2ef2efec', 0, 1, 1, 1, 253, 0),
(652, 'EDSON@EGC.UFSC.BR', 'EDSON@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5aa5e5ae-8d47-45d8-ba08-3d34555aa492', 0, 1, 1, 1, NULL, 0),
(653, 'JORGE@PULSOBRASIL.COM.BR', 'JORGE@PULSOBRASIL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c59ad48e-3e8c-462b-b265-ad0108e8945e', 0, 1, 1, 1, NULL, 0),
(654, 'MAURICIO URIONA', 'MAURICIO.URIONA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1a3e04f1-1b2e-472f-b3ff-425661c63271', 0, 1, 1, 1, 254, 0),
(655, 'E_PARENTES@YAHOOGRUPOS.COM.BR', 'E_PARENTES@YAHOOGRUPOS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '93e2e16c-d8a6-48cb-bb1c-99f6a384727b', 0, 1, 1, 1, NULL, 0),
(656, 'THIAGO.PAULO@IJURIS.ORG', 'THIAGO.PAULO@IJURIS.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1a0cb286-937e-4b7c-905b-a703675d44bf', 0, 1, 1, 1, NULL, 0),
(657, 'BOLZAN.JUVENAL@GMAIL.COM', 'BOLZAN.JUVENAL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd308f23b-f8a0-4cbe-9a11-d9f480640446', 0, 1, 1, 1, NULL, 0),
(658, 'FABIPROF@HOTMAIL.COM', 'FABIPROF@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee0d93f6-bc56-4b02-bbc5-8f207a7446db', 0, 1, 1, 1, NULL, 0),
(659, 'WHO2CONTACT@SUN.COM', 'WHO2CONTACT@SUN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9de99441-f71f-4792-810a-897592f5a737', 0, 1, 1, 1, NULL, 0),
(660, 'LAVINIA.JUNQUEIRA@SUN.COM', 'LAVINIA.JUNQUEIRA@SUN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ac6dfe4b-beab-4dc9-a1ff-36f0c4b5d887', 0, 1, 1, 1, NULL, 0),
(661, 'SUNCERT@THOMSON.COM', 'SUNCERT@THOMSON.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a42ef49e-ab69-4492-a9d8-12d9d4017d93', 0, 1, 1, 1, NULL, 0),
(662, 'GUSTAVO TOMAZI LUDWIG', 'GUSTAVO.LUDWIG@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b3ce66d7-42b7-4a9c-9b58-3755ec94dd96', 0, 1, 1, 1, 255, 0),
(663, 'REGIANI GUARNIERI', 'RGUARNIERI@ATTPS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e77a52a7-0f36-4d11-8aa9-86708939ecae', 0, 1, 1, 1, NULL, 0),
(664, 'PRISCILA MARANGONI', 'PRIPMSC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e64b6d6a-7279-4697-8f2e-ac975b95f2c5', 0, 1, 1, 1, NULL, 0),
(665, 'MARTA BRAGA', 'MCGBRAGA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7b8ef40e-a0a1-42a3-b960-87eccffba60a', 0, 1, 1, 1, 256, 0),
(666, 'PENTAHOBRASIL@GOOGLEGROUPS.COM', 'PENTAHOBRASIL@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd3081583-9be0-4164-a510-6173078978d8', 0, 1, 1, 1, NULL, 0),
(667, 'KLAUSWUESTEFELD@GMAIL.COM', 'KLAUSWUESTEFELD@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f67c37a7-af12-4dc4-9041-6ecf56be0658', 0, 1, 1, 1, NULL, 0),
(668, 'FABIPROF@GMAIL.COM', 'FABIPROF@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd83eaf61-b20d-49ff-94b4-5b2022f3cf96', 0, 1, 1, 1, NULL, 0),
(669, 'FELIPE DONHA', 'FDONHA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '988a0601-b150-49e5-8c4b-8779564593b2', 0, 1, 1, 1, NULL, 0),
(670, 'TISENAIVESPERTINO@GMAIL.COM', 'TISENAIVESPERTINO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b9cfa3d8-f29b-4516-9971-a5c8eab306c4', 0, 1, 1, 1, NULL, 0),
(671, 'MARILENE SPECK', 'MARILENE.SPECK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b7153779-d086-4d23-b833-8cc3d5b250d3', 0, 1, 1, 1, 257, 0),
(672, 'DIOGO MACHADO', 'DIOGOA7X@HOTMAIL.CO.JP', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f11f29d0-6385-4d3f-84b2-dccceb157dfd', 0, 1, 1, 1, 258, 0),
(673, 'SIMONE DIAS', 'SIMONE@CONTEXTODIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '63b9f0a8-e9be-48d9-a9b1-e8936bd35d58', 0, 1, 1, 1, 259, 0),
(674, 'LPG@UNESC.NET', 'LPG@UNESC.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '955c808c-6629-4963-9f73-f6e46b133c28', 0, 1, 1, 1, NULL, 0),
(675, 'ELIEZER NEOTI', 'ELIEZER@NEOTIONLINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5bbfd962-e73e-4d4f-8d53-93162e502549', 0, 1, 1, 1, NULL, 0),
(676, 'SAIMON P. COUTO', 'SAIMON.COUTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ffda6299-3333-48fb-a74f-9c19da846237', 0, 1, 1, 1, NULL, 0),
(677, 'LUCIANO R. RATH ALVES', 'LUCIANORATH@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '486fdbe2-a947-4e37-b534-6d66bab0cf6e', 0, 1, 1, 1, NULL, 0),
(678, 'DIOGOBACH@SAUDE.SC.GOV.BR', 'DIOGOBACH@SAUDE.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c45fb81d-d6bf-43f4-810a-3973c44e6cf0', 0, 1, 1, 1, NULL, 0),
(679, 'TESTEMANDA@HOTMAIL.COM', 'TESTEMANDA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bf9eb121-1593-4f29-91ec-a53ced09c60f', 0, 1, 1, 1, NULL, 0),
(680, 'TAYLOR DAVID', 'TDFLORIPA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '784f93dd-489a-4af0-8425-8d444d58f3b5', 0, 1, 1, 1, 260, 0),
(681, 'ROBERTO AMARAL', 'ROBERTOAMARAL@ISCC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ab96b1ae-97d7-4d90-b661-2a321ba9e842', 0, 1, 1, 1, NULL, 0),
(682, 'LERAUPP@YAHOO.COM.BR', 'LERAUPP@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4685f96e-1f26-4da5-9573-b7830e1c8d05', 0, 1, 1, 1, NULL, 0),
(683, 'PAULOFERNANDO@FURB.BR', 'PAULOFERNANDO@FURB.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '83da73df-bf4f-4d3a-ab93-f92ec8c28a98', 0, 1, 1, 1, NULL, 0),
(684, 'SUPORTE SIPO', 'SUPORTE.SIPO@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'efd8c7d9-5fb9-489c-b3f6-358e2f3550ff', 0, 1, 1, 1, NULL, 0),
(685, 'PANISSON.CESAR@GMAIL.COM', 'PANISSON.CESAR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd80478e9-65b9-4e16-a2c4-170f257a331c', 0, 1, 1, 1, 261, 0),
(686, 'ALESSANDRAD.GALDO@GMAIL.COM', 'ALESSANDRAD.GALDO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ed23b21f-94ef-484f-b126-214565d232fa', 0, 1, 1, 1, NULL, 0),
(687, 'EDUARDOTEALDI@HOTMAIL.COM', 'EDUARDOTEALDI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '50db170c-77b3-494b-84d3-d45da72d8305', 0, 1, 1, 1, NULL, 0),
(688, 'RAMIRES SCHLEMPER', 'RJSCHLEMPER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4c3a7b60-f624-4b23-b8e4-25c67d5ec00f', 0, 1, 1, 1, NULL, 0),
(689, 'MEIODIA@RICRECORD.COM.BR', 'MEIODIA@RICRECORD.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '82db633c-d161-4b28-9a2d-d08a94fe7370', 0, 1, 1, 1, NULL, 0),
(690, 'RAFAEL .', 'RAFAELNAZARONANDI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f906ad3a-75ae-424b-a244-fb4e419ad2be', 0, 1, 1, 1, NULL, 0),
(691, 'ANDREA@STELA.ORG.BR', 'ANDREA@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '003e1f0a-0069-4ff5-b43e-fb117eefe0b7', 0, 1, 1, 1, NULL, 0),
(692, 'TIOGERA@HOTMAIL.COM', 'TIOGERA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '04fd06af-4afc-46d7-9b1d-130985abbaa6', 0, 1, 1, 1, NULL, 0),
(693, 'CARLOS DIAS', 'CARLOS_AUGUSTO_DIAS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '01726523-473e-44a1-aaaa-98935d1ce7b2', 0, 1, 1, 1, NULL, 0),
(694, 'R4ULTRA@FOXMAIL.COM', 'R4ULTRA@FOXMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6bff8c08-2fb8-4628-b0a4-1d9e72645029', 0, 1, 1, 1, NULL, 0),
(695, 'LUIZ PALAZZO', 'LUIZ.PALAZZO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '97505bd3-da19-4624-a62a-32512dc75d75', 0, 1, 1, 1, 262, 0),
(696, 'LUIZ PALAZZO', 'LUIZPALAZZO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'daa51abc-85be-4b4f-b6ed-566b27563f45', 0, 1, 1, 1, 263, 0),
(697, 'EDUARDO MARTINS. POLMANN', 'EDUARDO@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd1794ed6-b6e7-491b-9aae-6242bffc6fb8', 0, 1, 1, 1, NULL, 0),
(698, 'DANIEL SONAGLIO', 'DANIELSONAGLIO@OUTLOOK.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '13b6e319-cb0d-4eac-aa30-3dfa0767cad5', 0, 1, 1, 1, NULL, 0),
(699, 'FR.SILVA1971@UOL.COM.BR', 'FR.SILVA1971@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd16c0ffb-47ef-44b5-999d-6e0bb9c1576f', 0, 1, 1, 1, NULL, 0),
(700, 'DÉBORA CRISTIANE DOS SANTOS', 'DEBORA.CRYSTY87@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e40f606d-e876-4f89-93d4-e86338259cb8', 0, 1, 1, 1, NULL, 0),
(701, 'TESTERROB3@HOTMAIL.COM', 'TESTERROB3@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ab70a91a-97bb-4647-8454-637c9ce73186', 0, 1, 1, 1, NULL, 0),
(702, 'LAUMOSQUERA_DG@YAHOO.COM.AR', 'LAUMOSQUERA_DG@YAHOO.COM.AR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fb3f6f73-8b6b-4336-8c46-6152c7f23943', 0, 1, 1, 1, NULL, 0),
(703, 'ADRY_EDFISICA@YAHOO.COM.BR', 'ADRY_EDFISICA@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd5c0839d-9bb4-462a-9750-2044849f2004', 0, 1, 1, 1, NULL, 0),
(704, 'HENRIQUE', 'HENRIQUE.BERG@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7b0e7c71-0ede-408c-ad7b-6053fa76db0d', 0, 1, 1, 1, NULL, 0),
(705, 'CINTIA-PEIXOTO@HOTMAIL.COM', 'CINTIA-PEIXOTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7757e47c-5d83-4cff-b411-6582802feb6e', 0, 1, 1, 1, NULL, 0),
(706, 'EDELBERTO SANTOS', 'EDELBERTOCSJ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '802fb239-1e9a-4199-9783-eea97471f893', 0, 1, 1, 1, 264, 0),
(707, 'RENATO SCHMITZ', 'RENATO.SCHMITZ@LIVE.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '72ab3852-d74c-405c-b9e3-420bed779400', 0, 1, 1, 1, NULL, 0),
(708, 'DANIELA MELO', 'DMEL@SOFSHORE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1360338d-cd87-455f-8e01-789824de9845', 0, 1, 1, 1, 265, 0),
(709, 'EDITOR@JAVAMAGAZINE.COM.BR', 'EDITOR@JAVAMAGAZINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '630a1e75-daaa-4ca7-9bf1-be53001ba1e4', 0, 1, 1, 1, NULL, 0),
(710, 'PROGRAMADORES@LED.UFSC.BR', 'PROGRAMADORES@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7e54b80c-8061-4e66-b4d8-295d71ef99ed', 0, 1, 1, 1, NULL, 0),
(711, 'TESTEFABIOMIL@HOTMAIL.COM', 'TESTEFABIOMIL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '275d6abb-e4e0-4f6b-a814-5cc818db0c5a', 0, 1, 1, 1, NULL, 0),
(712, 'JAGOSTINI@PR.SEBRAE.COM.BR', 'JAGOSTINI@PR.SEBRAE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd7ca90d4-a488-44c5-82ca-c36fba4ba00c', 0, 1, 1, 1, NULL, 0),
(713, 'MARÍLIA POS GRAD', 'MARILIA@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8c59b3ce-6f31-41c2-a53f-20bfdc6b72a8', 0, 1, 1, 1, NULL, 0),
(714, 'VANESSA AMARAL', 'VA.AMARAL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8f5f18f4-93f6-4db1-babc-3bd0350479be', 0, 1, 1, 1, 266, 0),
(715, 'NGS (UFSC)', 'NGS.UFSC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd8428efd-c346-44c8-9fdd-2f94552d63df', 0, 1, 1, 1, 267, 0),
(716, 'RAFAELMAIA@UNIVALI.BR', 'RAFAELMAIA@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '32cd1713-545e-4d0f-a46d-9df66a531301', 0, 1, 1, 1, NULL, 0),
(717, 'TWILIOBOT@APPSPOT.COM', 'TWILIOBOT@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b44c3143-0e1a-47a6-891d-fa5bbcc6d8bb', 0, 1, 1, 1, NULL, 0),
(718, 'PAMELA.FOX@GMAIL.COM', 'PAMELA.FOX@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6e0f3bba-140b-4039-93c9-3bf71b964b01', 0, 1, 1, 1, NULL, 0),
(719, 'RODRIGO GRUMICHE', 'GRUMICHE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '05ebccec-792d-44cd-8beb-29e345d92c9a', 0, 1, 1, 1, 268, 0),
(720, 'GIANIDUARTE@HOTMAIL.COM', 'GIANIDUARTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '296a6fd9-d8e2-4a8c-8a19-b26454b12151', 0, 1, 1, 1, NULL, 0),
(721, 'LEO.DANIELLI@YAHOO.COM.BR', 'LEO.DANIELLI@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '98cd54d4-4789-4487-a661-4077955e3de7', 0, 1, 1, 1, NULL, 0),
(722, 'ELIO GONÇALVES DA LUZ', 'ELIOGL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ab740bc3-5343-4302-8a21-aa48c9f6a99d', 0, 1, 1, 1, NULL, 0),
(723, 'MIDIA-EDUCACAO-EGC-2011-3@GOOGLEGROUPS.COM', 'MIDIA-EDUCACAO-EGC-2011-3@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '309fc0d3-8142-4717-bac1-cf0e986db6e8', 0, 1, 1, 1, NULL, 0),
(724, 'GREGO@DEPS.UFSC.BR', 'GREGO@DEPS.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '014105f9-005d-463d-b4c1-3bc767491492', 0, 1, 1, 1, NULL, 0),
(725, 'TITA.CINTIASC', 'TITA.CINTIASC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0188a73e-b4a7-4018-88f9-915ea923517d', 0, 1, 1, 1, NULL, 0),
(726, 'LUISA MORETTO', 'LUISARICHARTZMORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fce911ab-cc97-4f83-b546-245bc5f7df2b', 0, 1, 1, 1, NULL, 0),
(727, 'BAHIA@CIN.UFSC.BR', 'BAHIA@CIN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9f763d86-89cb-49f5-9899-21dd1dfc9b6a', 0, 1, 1, 1, NULL, 0),
(728, 'PRISCILA.PASQUALINI@SC.SENAI.BR', 'PRISCILA.PASQUALINI@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1ff54fa9-f19f-4388-b0f4-48718f7f3a47', 0, 1, 1, 1, NULL, 0),
(729, 'ANAXAVIER.CASSOL@GMAIL.COM', 'ANAXAVIER.CASSOL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6761ce84-79d9-48ae-8bc7-74542534f3be', 0, 1, 1, 1, NULL, 0),
(730, 'ANAXAVIER.CASSOL@GMAIL.COM', 'ANAXAVIERCASSOL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c3711f94-d66d-41f8-86cc-6aa90cf96d0a', 0, 1, 1, 1, NULL, 0),
(731, 'WAVE.STORIES@GMAIL.COM', 'WAVE.STORIES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bd9a928a-abc6-4069-a095-0014ab1973c9', 0, 1, 1, 1, NULL, 0),
(732, 'BRUNOBLAZIUS@HOTMAIL.COM', 'BRUNOBLAZIUS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '876a129d-1ae4-4a9d-9f0b-8dc83cacf82f', 0, 1, 1, 1, NULL, 0),
(733, 'ELIANA QUEIROZ', 'ELIANAQUEIROZPANDION@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f8f31a8b-124d-4c80-b3b2-3ceb7ed9cd13', 0, 1, 1, 1, NULL, 0),
(734, 'JAIRBAXADA@GMAIL.COM', 'JAIRBAXADA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f7e78d6d-9dbc-41a4-830c-e6821e5b8b17', 0, 1, 1, 1, NULL, 0),
(735, 'LEIASREAVES92@HOTMAIL.COM', 'LEIASREAVES92@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'feebd1f0-cc21-466b-9450-761579e7abec', 0, 1, 1, 1, NULL, 0),
(736, 'ALISSONWI@HOTMAIL.COM', 'ALISSONWI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c5334c9f-f603-4191-8b79-f80db8ea5af5', 0, 1, 1, 1, NULL, 0),
(737, 'AUER@INFORMATIK.UNI-LEIPZIG.DE', 'AUER@INFORMATIK.UNI-LEIPZIG.DE', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '63a550c6-b2ea-40eb-abf0-24db7a1cc591', 0, 1, 1, 1, NULL, 0),
(738, 'SÉRGIO RAULINO', 'RHUBASIC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2631e332-f32d-45ef-99aa-9c8536923dc1', 0, 1, 1, 1, 269, 0),
(739, 'PROVAS@CEPUTEC.COM.BR', 'PROVAS@CEPUTEC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a2ff1931-b647-4f56-bd80-931d9f338228', 0, 1, 1, 1, NULL, 0),
(740, 'SILVIO ROMERO CAMARA FAGUNDES', 'SRCFAGUNDES@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '548aebb9-d515-47e6-a69e-4c899596567c', 0, 1, 1, 1, NULL, 0),
(741, 'RODRIGO GUIMARAES RODRIGUES', 'RODRIGOGUIMARAESRODRIGUES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '20e3d6f8-47c9-4b2e-9e9e-574b15aaa4e6', 0, 1, 1, 1, NULL, 0),
(742, 'QWERTYDF@HOTMAIL.COM', 'QWERTYDF@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8061fb7b-58b6-48f3-a24f-cb1bf28b46a0', 0, 1, 1, 1, NULL, 0),
(743, 'EURAFFAELL@GMAIL.COM', 'EURAFFAELL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'baef0658-798b-4c97-b94f-b46813e3690a', 0, 1, 1, 1, NULL, 0),
(744, 'ANDRÉ VOGES TURNES', 'ANDREVOGESTURNES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '139acb46-670f-4cc1-8430-ef523601dec1', 0, 1, 1, 1, 270, 0),
(745, 'NIVIO SANTOS', 'NIVIO.SANTOS@ADEPTSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7af4daeb-885a-43b7-aaf2-043b7167291b', 0, 1, 1, 1, NULL, 0),
(746, 'JAIRDACUNHA@HOTMAIL.COM', 'JAIRDACUNHA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3a23bfef-20f3-4b8e-9296-068c5d0f552c', 0, 1, 1, 1, NULL, 0),
(747, 'NERY .', 'NEERY.PAOLO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ae37ee16-1c12-458b-85ac-81931d6a7f6f', 0, 1, 1, 1, NULL, 0),
(748, 'LIA@ECV.UFSC.BR', 'LIA@ECV.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '29966baf-4404-410a-847a-645a82dac3dc', 0, 1, 1, 1, NULL, 0),
(749, 'TECNICA@LED.UFSC.BR', 'TECNICA@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c54d917f-cf2e-47f2-ba35-a020c9f7c1a6', 0, 1, 1, 1, NULL, 0),
(750, 'CHAINER_@HOTMAIL.COM', 'CHAINER_@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aaa3be2c-5aca-4c1d-a5f0-f919725a8787', 0, 1, 1, 1, NULL, 0),
(751, 'DIONEI_GONCALVES@HOTMAIL.COM', 'DIONEI_GONCALVES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a0ddfbdc-a124-43ac-aa8b-d66f44db3ba5', 0, 1, 1, 1, NULL, 0),
(752, 'COLUNISTACLAUDIAGOMES@GMAIL.COM', 'COLUNISTACLAUDIAGOMES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1da03889-2421-4870-85c7-0fec320caa0a', 0, 1, 1, 1, NULL, 0),
(753, 'EDSON LUIZ BATISTA', 'ED.LUIZ.BATISTA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5dee8979-be40-45a7-99bf-8571169da0d3', 0, 1, 1, 1, NULL, 0),
(754, 'PAULA DODSON FLORIANÓPOLIS BJSS!', 'PITTYBELZARA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a1faf8b3-09b0-4a7e-bffc-3194382aa5ba', 0, 1, 1, 1, NULL, 0),
(755, 'JANE LUCIA SANTOS', 'JANEJLSS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5be85974-8e46-40cf-88cc-d01bc62d08ba', 0, 1, 1, 1, 271, 0),
(756, 'PROVAS@CEPUNET.COM.BR', 'PROVAS@CEPUNET.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '570a3e55-68cc-4dc8-b462-a94d73ac19c2', 0, 1, 1, 1, NULL, 0),
(757, 'JULIANA LAPOLLI', 'JULAPOLLI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1914fd15-e7b1-40e4-a462-4109abedd00b', 0, 1, 1, 1, 272, 0),
(758, 'MARILINHA', 'C2MMG@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b4648aa3-21f4-4694-90fc-e857026ebe9b', 0, 1, 1, 1, NULL, 0),
(759, 'SABRINABLEICHER@GMAIL.COM', 'SABRINABLEICHER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '92f95bb2-c537-4c67-8a7d-b297af8c29dc', 0, 1, 1, 1, NULL, 0),
(760, 'ALYNE_MULLER@HOTMAIL.COM', 'ALYNE_MULLER@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '93e9108f-bd97-4ef0-8864-8e97ee80c8cc', 0, 1, 1, 1, NULL, 0),
(761, 'RAFAEL@ECTHUS.COM.BR', 'RAFAEL@ECTHUS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '83102636-04cb-45ad-9536-f6a5b2f739c4', 0, 1, 1, 1, NULL, 0),
(762, 'TERESABAGGOTT1@GMAIL.COM', 'TERESABAGGOTT1@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '08e780b9-0d70-47ac-add6-9079037a5b3e', 0, 1, 1, 1, NULL, 0),
(763, 'CAMILLA FETTER', 'CAMILLAFETTER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '15ce5ba7-0acb-47c7-ae07-a1368a650de1', 0, 1, 1, 1, 273, 0),
(764, 'WEBGD@GOOGLEGROUPS.COM', 'WEBGD@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f2cbe11b-c3b2-42ff-b688-d29cf1bd24ee', 0, 1, 1, 1, NULL, 0),
(765, 'JOÃO HENRIQUE GUIZZO SAUCEDA', 'JOAO.SAUCEDA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f3c656ed-0165-4de7-b83d-00e0cf152da6', 0, 1, 1, 1, 274, 0),
(766, 'JOÃO HENRIQUE GUIZZO SAUCEDA', 'JOAOSAUCEDA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '50aa24f4-3233-48eb-85e1-82f9f5d378e3', 0, 1, 1, 1, 275, 0),
(767, 'AUGUSTO@LEPTEN.UFSC.BR', 'AUGUSTO@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '09740e0c-00f5-4573-a0f6-7c1a8708af3a', 0, 1, 1, 1, 276, 0),
(768, 'GEAN_.12@HOTMAIL.COM', 'GEAN_.12@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'be0bfc0d-a7fa-4f59-8ea4-9b29aeec9cf5', 0, 1, 1, 1, NULL, 0),
(769, 'PROFCESINHAP@HOTMAIL.COM', 'PROFCESINHAP@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4683c4be-6c7c-47d6-abb8-0ecf1a5699a3', 0, 1, 1, 1, NULL, 0),
(770, 'SPANHOL', 'SPANHOL@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '81e771f3-08a3-4ade-9882-bb5f98801467', 0, 1, 1, 1, NULL, 0),
(771, 'KERN@SJ.UNIVALI.BR', 'KERN@SJ.UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '182593cf-6cde-44f5-b8c6-4a32ae567556', 0, 1, 1, 1, NULL, 0),
(772, 'DIEGO_C_ARAUJO@HOTMAIL.COM', 'DIEGO_C_ARAUJO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '60489aed-fcd6-4768-b1e3-5c73afa05852', 0, 1, 1, 1, NULL, 0),
(773, 'JULIO NELSON SCUSSEL', 'JULIO.LINEAR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b28545b5-7eb8-4fec-8e00-2a3381d8d741', 0, 1, 1, 1, 277, 0),
(774, 'MALACMA.@GMAIL.COM', 'MALACMA.@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '61304fa6-9e2c-42c6-83dd-5da74b82501d', 0, 1, 1, 1, NULL, 0),
(775, 'CAIRO@SAUDE.GOV.BR', 'CAIRO@SAUDE.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0488cf44-a795-4740-a90d-b84b37bf8901', 0, 1, 1, 1, NULL, 0),
(776, 'GUILERMEHECK@GMAIL.COM', 'GUILERMEHECK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4faef1de-a530-4598-b56c-6f865ba6e60b', 0, 1, 1, 1, NULL, 0);
INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(777, 'MAYARA TEODORO', 'TEODOROMAY@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6ae4bc28-f4fc-4319-88be-f83ddb6644a5', 0, 1, 1, 1, NULL, 0),
(778, 'JHONI INACIO', 'JHONI-INACIO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8bd2b2f7-837a-4075-84de-bc4434613dd3', 0, 1, 1, 1, NULL, 0),
(779, 'VINICIUSXJC@HOTMAIL.COM', 'VINICIUSXJC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7a6c3c31-8089-47a7-8ace-6d5901e6c903', 0, 1, 1, 1, NULL, 0),
(780, 'RAULBUSARELLO', 'RAULBUSARELLO@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fd837acb-7872-4824-adc8-edc515f5a0fe', 0, 1, 1, 1, 278, 0),
(781, 'VITORIA AUGUSTA BRAGA DE SOUZA', 'VITBRAGA_2@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '55716f21-7d4c-41b9-b704-c17573f6e780', 0, 1, 1, 1, NULL, 0),
(782, 'VITORIA AUGUSTA BRAGA DE SOUZA', 'VITBRAGA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9382b768-90a5-45c6-8007-722c8290b168', 0, 1, 1, 1, NULL, 0),
(783, 'YORAH.BOSSE@GMAIL.COM', 'YORAH.BOSSE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '123e1d9f-18b5-49a4-a07c-6a40954e588b', 0, 1, 1, 1, NULL, 0),
(784, 'RODRIGO MELO LOPES', 'RODRIGOMIRO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2ae04c65-4dc1-4cb7-aa6d-1be27d0ab7d3', 0, 1, 1, 1, NULL, 0),
(785, 'THIAGO STURDZE', 'THIAGOSTU@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9ba0e584-f224-4afe-b181-73eb8f9e3411', 0, 1, 1, 1, NULL, 0),
(786, 'KÍRIA MEURER', 'KIRIA_9@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '966a2152-8586-4436-8ca0-8da61ea473f5', 0, 1, 1, 1, NULL, 0),
(787, 'GILMARCR@GMAIL.COM', 'GILMARCR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b41459d-2520-4536-9178-b446e3733953', 0, 1, 1, 1, NULL, 0),
(788, 'ઇ‍ઉ ROBERTA WILLVERT ઇ‍ઉ', 'RO_BETA.WILL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '63a6d9b6-af8b-4783-b6fa-113a916f2e9e', 0, 1, 1, 1, NULL, 0),
(789, 'SAMIR MACHADO VERAN', 'SAMIRMVERAN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '85b86b20-8f3f-4e00-af0c-498e198e3362', 0, 1, 1, 1, NULL, 0),
(790, 'JULIANO DANIEL MARCELINO', 'JULIANO@JMARCELINO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '680b9d72-0efb-4497-a16d-eebfa21914d3', 0, 1, 1, 1, NULL, 0),
(791, 'SRCFAGUNDES@GMAIL.COM', 'SRCFAGUNDES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b5fef7f1-55dc-41da-8491-1bbf3878a201', 0, 1, 1, 1, NULL, 0),
(792, 'HEITOR M. P.', 'HEITORRMP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0701f92a-0a32-4d3d-a7e1-f872442f6277', 0, 1, 1, 1, NULL, 0),
(793, 'FELIPE J. L. DANIEL', 'FELIPE@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ced7b5cd-ca9f-4e5f-b316-f7a238bb42c1', 0, 1, 1, 1, NULL, 0),
(794, 'CRISTINEFABBRIS@GMAIL.COM', 'CRISTINEFABBRIS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9c0a1808-a6c9-4580-ae33-f2497c37a68d', 0, 1, 1, 1, NULL, 0),
(795, 'SIMONE MORETTO', 'S.M.MORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4b6ca2af-8577-418c-bab2-2551d4299854', 0, 1, 1, 1, 279, 0),
(796, 'ANDERSON.SOUZA@HOTMAIL.COM', 'ANDERSON.SOUZA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0b7eee3a-9306-43c5-bc47-ad41ccf9781f', 0, 1, 1, 1, NULL, 0),
(797, 'ALAN_DONAVAN@HOTMAIL.COM', 'ALAN_DONAVAN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7e41f26c-be95-4bd7-b891-239ed5c4c946', 0, 1, 1, 1, NULL, 0),
(798, 'RONY', 'RONNYNELSON@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cc0d2b0b-4442-4a6e-8dbf-f7f65a82496f', 0, 1, 1, 1, NULL, 0),
(799, 'MARCONEH@HOTMAIL.COM', 'MARCONEH@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '501f11ae-ec86-4b96-8370-fb601247b7e1', 0, 1, 1, 1, NULL, 0),
(800, 'VITAMUSCLE@BOL.COM.BR', 'VITAMUSCLE@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '63b9bc8a-f7fb-424e-b554-c50a93066eb5', 0, 1, 1, 1, NULL, 0),
(801, 'KERN@EPS.UFSC.BR', 'KERN@EPS.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5a25583f-d9a1-4b5a-8845-8641545a07c1', 0, 1, 1, 1, NULL, 0),
(802, 'CAIOVINISS12@GMAIL.COM', 'CAIOVINISS12@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b15f37bd-f0d7-42d3-ba14-3a2291869985', 0, 1, 1, 1, NULL, 0),
(803, 'LUIS.MORETTO.NETO@UFSC.BR', 'LUIS.MORETTO.NETO@UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9e43503c-a681-4c26-9aaa-3f9e81e6746f', 0, 1, 1, 1, NULL, 0),
(804, 'EGC-8005-SISTEMAS-MULTIMIDIA-2012-1@GOOGLEGROUPS.COM', 'EGC-8005-SISTEMAS-MULTIMIDIA-2012-1@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7eafef26-a6d5-4f2e-8397-234b9a61ea8d', 0, 1, 1, 1, NULL, 0),
(805, 'VINÍCIUS CARDOSO COELHO', 'VINICIUSCC@BRTURBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'daa1fb41-fb4f-4e17-ba82-a7ebcc830f20', 0, 1, 1, 1, NULL, 0),
(806, 'SERGIO MACHADO WOLF', 'SERGIO@EAD.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c405a965-5ecb-4a7b-aa3a-a6a2414d8c6d', 0, 1, 1, 1, NULL, 0),
(807, 'AUNT-ROSIE@APPSPOT.COM', 'AUNT-ROSIE@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2a2699ec-fd6d-4748-8332-0c18b48616df', 0, 1, 1, 1, NULL, 0),
(808, 'GEOVANE SOUZA', 'GEO_VANE_GPS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e9113f37-6d3d-4531-bd16-6364a68a2347', 0, 1, 1, 1, 280, 0),
(809, 'PRATTS', 'DFP0009@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '806ab178-1ecf-49cd-ab07-bc43b4e29091', 0, 1, 1, 1, 281, 0),
(810, 'ELTON VERGARANUNES', 'VERGARANUNES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee408b56-5bca-4af3-87dd-9bb83d666a15', 0, 1, 1, 1, 282, 0),
(811, 'THAYSSINHA AMO MUITO TUDO ISSO', 'THAYSSA_TJ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '581f7248-9866-400d-99bb-ff77cc3f1ffb', 0, 1, 1, 1, NULL, 0),
(812, 'FERNANDO MOSKORZ', 'FERNANDO.MOSKORZ@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '79d264c4-af94-475e-9038-d4d981c1fa4f', 0, 1, 1, 1, NULL, 0),
(813, 'PEDFLORIANOPOLIS@MICROCAMPCORP.COM.BR', 'PEDFLORIANOPOLIS@MICROCAMPCORP.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1b5c9892-a6e8-4b11-8fb1-0aa1e1458bd8', 0, 1, 1, 1, NULL, 0),
(814, 'GILNEI AMORIM', 'GILNEI-KBESSA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2c43218e-8af8-42ee-a075-bdc60ac32a6d', 0, 1, 1, 1, NULL, 0),
(815, 'JENNIPHERDINIZ@GMAIL.COM', 'JENNIPHERDINIZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee09c47c-f46b-4648-a4c8-96a93c465541', 0, 1, 1, 1, NULL, 0),
(816, 'ALESSANDRA HELENA ZUNINO SILVEIRA', 'ALESSANDRAZS@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '77f14621-7a19-4008-92d8-7104ae847ac6', 0, 1, 1, 1, NULL, 0),
(817, 'ZIZII', 'THAYSYZIMERMANN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fbc2f2d9-dbdc-4582-ae32-4f90473b3958', 0, 1, 1, 1, 283, 0),
(818, 'MARCO ANTONIO', 'TONHO498@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b577a94-74a3-488e-938b-b794fd40bbdf', 0, 1, 1, 1, NULL, 0),
(819, 'FRANCYNE SANTOS BRIÃO', 'FRAAN.PC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '87f12f70-1064-42ad-b8cf-703de03a35ab', 0, 1, 1, 1, 284, 0),
(820, 'MATHUESRO@HOTMAIL.COM', 'MATHUESRO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5ac1ef54-6411-4620-b62e-13bd8a486ad1', 0, 1, 1, 1, NULL, 0),
(821, 'GABRIEL.BARRETO@MSN.COM', 'GABRIEL.BARRETO@MSN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '351e30fe-a437-40c0-903a-a4a4c39ad35e', 0, 1, 1, 1, NULL, 0),
(822, 'FRANKLIN OWUSU', 'FRANKLINOWUSU20@HOTMAIL.FR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '82c15a12-8e13-4962-ba84-6e2594524bee', 0, 1, 1, 1, NULL, 0),
(823, 'BIICHO.DE.PRAIA@HOTMAIL.COM', 'BIICHO.DE.PRAIA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '88026822-5b9c-4023-b579-367a98ad54ea', 0, 1, 1, 1, NULL, 0),
(824, 'LUCAS WEBER', 'WEBERXW@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3d067e9b-88c0-443e-86d7-473b92a6401a', 0, 1, 1, 1, 285, 0),
(825, 'CLINICAVETCAMPOVERDE@BOL.COM.BR', 'CLINICAVETCAMPOVERDE@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4dd0ed6a-9633-4ecf-a4ff-e13e9a033e2a', 0, 1, 1, 1, NULL, 0),
(826, 'CLODOMIR.CORADINI@ESTACIO.BR', 'CLODOMIR.CORADINI@ESTACIO.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9f8c0649-87a6-4058-b6dc-6d69d6f3b4d7', 0, 1, 1, 1, NULL, 0),
(827, 'LUIZ MAURO SOARES', 'LUIZMAUROSOARES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9a6d456a-5ed4-45e5-8e2e-b22db9a52217', 0, 1, 1, 1, NULL, 0),
(828, 'MAGDA CAMARGO LANGE RAMOS', 'MAGDARAMOS@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '36c2ca9b-0825-4d6b-baf9-eefac5969a8c', 0, 1, 1, 1, NULL, 0),
(829, 'SOLANGE MACHADO MORETTO', 'SOLANGE.MMORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '68322eea-f427-4471-9096-bc54d00b33b8', 0, 1, 1, 1, 286, 0),
(830, 'MARCIA_MRM@HOTMAIL.COM', 'MARCIA_MRM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '41423007-ab24-47a5-8754-d5f9a99a646c', 0, 1, 1, 1, NULL, 0),
(831, 'ROSA@PGIE.UFRGS.BR', 'ROSA@PGIE.UFRGS.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0bdc3e6a-c3ee-4695-a025-27ed8f6cf8ff', 0, 1, 1, 1, NULL, 0),
(832, 'RODRIHAND@HOTMAIL.COM', 'RODRIHAND@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '454cbb82-679e-4dac-bda3-98acb36a6a69', 0, 1, 1, 1, NULL, 0),
(833, 'THIAGO FURLANE', 'FURLANIDN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0d865ade-a8aa-486f-b0d1-674db6948293', 0, 1, 1, 1, 287, 0),
(834, 'ALESSANDROBOVO@GMAIL.COM', 'ALESSANDRO@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '936f49e8-c506-4a38-91fc-a57fbbc013a7', 0, 1, 1, 1, 288, 0),
(835, 'ALESSANDROBOVO@GMAIL.COM', 'ALESSANDROBOVO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5b3d1d5e-32ad-496e-b85c-9d9f9bb6af4f', 0, 1, 1, 1, 289, 0),
(836, 'PATRICIA LOPES', 'PATRICIAANDRADELOPES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8b211254-1c55-4557-829a-16a44bf877d9', 0, 1, 1, 1, NULL, 0),
(837, 'RENATO.DADO', 'RENATO.DADO@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bcc6e1c8-938e-4d37-ae5d-b4f4a5474f39', 0, 1, 1, 1, NULL, 0),
(838, 'JADES FERNANDO', 'JADESF@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bca0f107-9713-4d91-b75d-5d8e7a824015', 0, 1, 1, 1, 290, 0),
(839, 'BURIGOGOL@HOTMAIL.COM', 'BURIGOGOL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '70f4b976-1f38-436a-8fee-eeabf0ee075d', 0, 1, 1, 1, NULL, 0),
(840, 'ANDREZA .', 'ANDREZA_CECILIA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '89afd0e6-7163-4c21-b09e-9bec64e95348', 0, 1, 1, 1, NULL, 0),
(841, 'ANDREZA .', 'DEZA.CECILIA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '19eb2ba7-4977-4940-b850-16fd12519c4a', 0, 1, 1, 1, NULL, 0),
(842, 'ANDERMG@HOTMAIL.COM', 'ANDERMG@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e0be88f5-d3d1-4aa3-baf2-41d327ee0a5d', 0, 1, 1, 1, NULL, 0),
(843, 'PACHECO@STELA.ORG', 'PACHECO@STELA.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'de186e78-5299-4eab-8d40-db7d0bf2b681', 0, 1, 1, 1, NULL, 0),
(844, 'ELIANE', 'ELIANESILVA@CEPUNET.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '007c6779-3375-463e-b8ca-ce48d7eefd5b', 0, 1, 1, 1, NULL, 0),
(845, 'ELIANE RIVIERA', 'ELIANE.COMP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a6563c21-85a0-457d-93fd-095616ef58ae', 0, 1, 1, 1, 291, 0),
(846, 'SEMPRESAFADA67@HOTMAIL.COM', 'SEMPRESAFADA67@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e325a37b-4c59-452a-867c-88789b1a1077', 0, 1, 1, 1, NULL, 0),
(847, 'JULIANA', 'JULYPOPV@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3bdcd2b4-92a9-4661-8c25-4810955282cc', 0, 1, 1, 1, 292, 0),
(848, 'RAUL BUSARELLO', 'RAULBUSARELLO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ed6ed689-a426-4322-b4b7-a6770acdd56d', 0, 1, 1, 1, NULL, 0),
(849, 'RAFAEL@ACAFE.ORG.BR', 'RAFAEL@ACAFE.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '14115261-0060-4ea1-a84d-7bdcf14c3f69', 0, 1, 1, 1, NULL, 0),
(850, 'JAQUELINE ROSSATO', 'INEROSSATO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '676277aa-c135-4277-8c9d-e91ec419ce09', 0, 1, 1, 1, NULL, 0),
(851, 'LUIZ A M PALAZZO', 'LPALAZZO@UCPEL.TCHE.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '25566792-1532-45d4-8716-a69474492d29', 0, 1, 1, 1, NULL, 0),
(852, 'GRETIN', 'GRETIN@UNIMEDFLORIANOPOLIS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd57dd32a-a11e-416b-9c75-3f65793a3782', 0, 1, 1, 1, NULL, 0),
(853, 'MATHEUS MEIRA', 'MATHEUS.MEIRA@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '36835261-ef57-46da-911c-4c38a2d49828', 0, 1, 1, 1, NULL, 0),
(854, 'RAFAELDESOUZA86@GMAIL.COM', 'RAFAELDESOUZA86@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bc109bff-2350-4466-a9cf-fdab7d045c1c', 0, 1, 1, 1, NULL, 0),
(855, 'ROSA@INF.UFRGS.BR', 'ROSA@INF.UFRGS.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8dbcb1cd-3de7-41bf-a753-22eaed9d4e15', 0, 1, 1, 1, NULL, 0),
(856, 'JENNY90ANNIE@GMAIL.COM', 'JENNY90ANNIE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '62792e06-e385-4c9a-8553-eb87ad52a65e', 0, 1, 1, 1, NULL, 0),
(857, 'GABRIEL SCOTTI', 'GABRIEL_SCOTTI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1f928c45-f523-4b31-bd35-5dcdc5cdde69', 0, 1, 1, 1, NULL, 0),
(858, 'KYOSHI TAKEMURA', 'JUNIORTAKEMURA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '22e285a9-54db-4b78-901c-3433f9a4e787', 0, 1, 1, 1, NULL, 0),
(859, 'ROBERTLUIZVILVERT@GMAIL.COM', 'ROBERTLUIZVILVERT@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '905c4341-c966-4e18-abe2-c54410fd4782', 0, 1, 1, 1, NULL, 0),
(860, 'JUANCOTO@GMAIL.COM', 'JUANCOTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c9db9925-e18e-45df-96e8-beee2400a295', 0, 1, 1, 1, NULL, 0),
(861, 'FRANCISCO FIALHO', 'FAPFIALHO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f916bfff-c9cf-4ff8-9f9e-3782f9bd51a1', 0, 1, 1, 1, 293, 0),
(862, 'AUGUS TITO', 'ELANO08@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '775fef37-68b3-4fa7-b263-d70e7ce7b617', 0, 1, 1, 1, NULL, 0),
(863, 'ALESSANDRO HOFFMANN', 'MBS-6610@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '11b97774-d397-4bc1-aabe-d574c33e663b', 0, 1, 1, 1, NULL, 0),
(864, 'ALESSANDRO HOFFMANN', 'ALESSANDRO_HOFFMANN@ALUNO.SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e39ec8e6-a74e-49ef-a4ab-6e41095b667c', 0, 1, 1, 1, NULL, 0),
(865, 'LÍDIA PORTO', 'LIDIAPORTO06@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8012a574-7b53-4da8-8851-2699a1232bfc', 0, 1, 1, 1, 294, 0),
(866, 'LUIZE CRISTINE', 'LUUHFEIA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a7adb657-1967-4a06-a1e4-65e35c235475', 0, 1, 1, 1, NULL, 0),
(867, 'CACAU.MENEZES@RBSTV.COM.BR', 'CACAU.MENEZES@RBSTV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6c3ce963-ccfa-4987-90ac-886c20d7bf5f', 0, 1, 1, 1, NULL, 0),
(868, 'INARA.ANTUNES@GMAIL.COM', 'INARA.ANTUNES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '943a16a9-4459-4194-ad72-c3472c856126', 0, 1, 1, 1, 295, 0),
(869, 'MIAROBERTACACA@HOTMAIL.COM', 'MIAROBERTACACA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6e3ad5a3-c2fb-4de8-9d61-912277772a2d', 0, 1, 1, 1, NULL, 0),
(870, 'TECNOLOGOIMOBILIARIO@HOTMAIL.COM', 'TECNOLOGOIMOBILIARIO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '81855c08-b208-4612-ae62-ecdba3558b97', 0, 1, 1, 1, NULL, 0),
(871, 'NEREU O_O', 'VESGOLINO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2859733d-2911-439a-8cea-a96038686930', 0, 1, 1, 1, NULL, 0),
(872, 'ERICKOSTON@HOTMAIL.COM', 'ERICKOSTON@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '073de550-6565-4cd3-8cd0-3f6de6b6c196', 0, 1, 1, 1, NULL, 0),
(873, 'PAMMELAH@HOTMAIL.COM', 'PAMMELAH@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '861d0ccf-4a02-49af-a8c6-077ebdc6ad09', 0, 1, 1, 1, NULL, 0),
(874, 'ENGENHARIADEPRODUCAO@UNIFEBE.EDU.BR', 'ENGENHARIADEPRODUCAO@UNIFEBE.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cf2f45d6-119a-4ee2-ad1c-eb5439fc3921', 0, 1, 1, 1, NULL, 0),
(875, 'FERNANDOTHOEL@GMAIL.COM', 'FERNANDOTHOEL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7bccefb3-a517-496c-a826-f3c2a3f110e7', 0, 1, 1, 1, NULL, 0),
(876, 'IRON MAN HACKER', 'ANDREZA.FLORIPA00@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '25073d08-2a40-4419-94f8-dec4a6fb05fc', 0, 1, 1, 1, NULL, 0),
(877, 'ANALUCIAGIL@HOTMAIL.COM', 'ANALUCIAGIL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3f81a5e7-62de-47ee-8794-12d473439aef', 0, 1, 1, 1, NULL, 0),
(878, 'ANA STANK', 'ANINHAH_POA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5e17b558-c2f4-41ab-9a3a-ac1b79132e99', 0, 1, 1, 1, NULL, 0),
(879, 'VANIA ULBRICHT', 'ULBRICHT@FLORIPA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '57af31dd-fb3d-4b65-b033-54b74ca48753', 0, 1, 1, 1, NULL, 0),
(880, 'BETITA HORN', 'BETITAHORN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '65207723-d3ab-4bac-b647-736dc18734d4', 0, 1, 1, 1, 296, 0),
(881, 'IDIEN ARIEL HILLESHEIM', 'NEIDIPETERSEN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aa31aca8-18df-4155-97eb-a42c4d309af1', 0, 1, 1, 1, 297, 0),
(882, 'MAIKONVERCOZA@GMAIL.COM', 'MAIKONVERCOZA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2d822ace-7e1e-4cd4-a194-b97381f53f15', 0, 1, 1, 1, NULL, 0),
(883, 'ROSE@CERTTO.COM.BR', 'ROSE@CERTTO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e44c6649-ada6-4db0-8214-ea6316c302e1', 0, 1, 1, 1, NULL, 0),
(884, 'SASHEMEL@SASHEMEL.COM.BR', 'SASHEMEL@SASHEMEL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '101665a0-2004-4eed-928c-cf41be31b47c', 0, 1, 1, 1, NULL, 0),
(885, 'NUNES.CAROLINA@GMAIL.COM', 'NUNES.CAROLINA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '01ba96b2-e390-4d64-9237-820300a64330', 0, 1, 1, 1, NULL, 0),
(886, 'RICARDO_ANDRE@DELL.COM', 'RICARDO_ANDRE@DELL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7c224f29-2afb-4381-b9df-1edb769446d1', 0, 1, 1, 1, NULL, 0),
(887, 'ALEXANDRESENA1978@GMAIL.COM', 'ALEXANDRESENA1978@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eed4f24b-1a99-4eef-84e4-da0ee18ea282', 0, 1, 1, 1, NULL, 0),
(888, 'IVORYCHENIERDWAUK@HOTMAIL.COM', 'IVORYCHENIERDWAUK@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7fc1e40a-31e7-4b3c-9560-9680c33389a0', 0, 1, 1, 1, NULL, 0),
(889, 'THAYSECOELHO@GMAIL.COM', 'THAYSECOELHO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8403f274-e8f3-47c3-8550-26a5cdf9c5e3', 0, 1, 1, 1, NULL, 0),
(890, 'KLEBER.P.VENDRUSCOLO@HOTMAIL.COM', 'KLEBER.P.VENDRUSCOLO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c299ed5-6443-47f4-83ba-cafec34cadf4', 0, 1, 1, 1, NULL, 0),
(891, 'KINGHOST - HOSPEDAGEM DE SITES', 'SUPORTE@KINGHOST.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '969bf70d-79d7-4118-995b-7cc266337030', 0, 1, 1, 1, NULL, 0),
(892, 'ANDERSON.OKI@HOTMAIL.COM', 'ANDERSON.OKI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8edc4ceb-4569-4fba-867d-0302b6dc6979', 0, 1, 1, 1, NULL, 0),
(893, 'HENRIQUEMEDEIROS64@GMAIL.COM', 'HENRIQUEMEDEIROS64@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2b2f772d-3405-474c-979b-518f23c33196', 0, 1, 1, 1, NULL, 0),
(894, 'EMANOEL GUTIHA', 'EMANOELGUTIHA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0a73b415-eac1-4d9d-a7ce-f7ed78d6c2d1', 0, 1, 1, 1, NULL, 0),
(895, 'AMAURI VIEIRA', 'CBALA@IG.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b66cec21-1b99-4346-8779-d4f3b75b64f1', 0, 1, 1, 1, NULL, 0),
(896, 'ACCOUNT@ACM.ORG', 'ACCOUNT@ACM.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'df7019ec-c3ab-4719-9873-7e6c7c6acfd9', 0, 1, 1, 1, NULL, 0),
(897, 'MARIANA LAPOLLI', 'MARILAPOLLI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6afcf813-d876-4a53-8dca-79990b026879', 0, 1, 1, 1, 298, 0),
(898, 'JEANJV@GMAIL.COM', 'JEANJV@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '56382322-6df0-4a91-817e-9e69a8076676', 0, 1, 1, 1, NULL, 0),
(899, 'FABIANO FELIPE', 'CAPIVARA_LOKA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e9eed42d-17d9-44b0-8e15-bed390e6484b', 0, 1, 1, 1, 299, 0),
(900, 'MEIODIA@RICSC.COMBR', 'MEIODIA@RICSC.COMBR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1812da7b-d11c-4757-ac3b-71baf780ca72', 0, 1, 1, 1, NULL, 0),
(901, 'VLEAL@CASAN.COM.BR', 'VLEAL@CASAN.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '03fbc7c2-e4a5-407c-8ccc-a2cab66c72e4', 0, 1, 1, 1, NULL, 0),
(902, 'THAYSSINHA AMO MUITO TUDO ISSO', 'THAYSSINHAA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '80c8d751-a0f6-4e01-89d8-2f483b0de301', 0, 1, 1, 1, NULL, 0),
(904, 'SAUL SOUZA MÜLLER', 'YYEECC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c2ba97c2-9d15-4868-bd8d-f8cb5e7488db', 0, 1, 1, 1, 300, 0),
(905, 'DAN HINCKEL', 'D.H.REACAO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '09206b2b-a054-4761-98b4-e3525ed7ba93', 0, 1, 1, 1, 301, 0),
(906, 'MARCELO MACIEL PEREIRA(GORDINHO)', 'MMACIEL@MATRIX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd77ed3d0-3d75-4e4d-aa29-3d99ea4789ca', 0, 1, 1, 1, NULL, 0),
(907, 'HUD.FORTE@HOTMAIL.COM', 'HUD.FORTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '90bf7363-0274-4622-bc96-a4d3635f9226', 0, 1, 1, 1, NULL, 0),
(908, 'JUXT.TESTE1@PASSPORT.COM', 'JUXT.TESTE1@PASSPORT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4dea683c-0f8a-4f3e-b9e8-5fc28b302cad', 0, 1, 1, 1, NULL, 0),
(909, 'FLORZINHA1980@HOTMAIL.COM', 'FLORZINHA1980@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a64cf61d-43a5-4450-8bd9-2bf90bcff127', 0, 1, 1, 1, NULL, 0),
(910, 'CAD@CSE.UFSC.BR', 'CAD@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4bcebcb0-cbc1-43ae-b16e-ae290a704e7c', 0, 1, 1, 1, NULL, 0),
(911, 'PLAYBLOGWS@GMAIL.COM', 'PLAYBLOGWS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5a2460de-b969-4017-956f-793a169175a4', 0, 1, 1, 1, NULL, 0),
(912, 'LORIVAL', 'VENDASI@IMOVEISFLORIPA.CIM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f9134d4d-a533-4afe-8db2-9e54dd5f4947', 0, 1, 1, 1, NULL, 0),
(913, 'UNSUBSCRIBE-CONTENT@PHPCLASSES.ORG', 'UNSUBSCRIBE-CONTENT@PHPCLASSES.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd3d7f491-556b-4d84-b741-412fbb435213', 0, 1, 1, 1, NULL, 0),
(914, 'ARTHUR SANDERS', 'ARTHUR@LABIRINTO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-01', '74b773fd-6bdd-4fdd-b22e-a80f15fb6a23', 0, 1, 1, 1, NULL, 0),
(915, 'GUIME78@HOTMAIL.COM', 'GUIME78@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '10937ff5-9010-4d04-911b-05f4f0c8affd', 0, 1, 1, 1, NULL, 0),
(916, 'C.E. RICKEN', 'C.E.RICKEN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4e275f37-837a-49ed-9ed0-1f94c497a054', 0, 1, 1, 1, NULL, 0),
(917, 'C.E. RICKEN', 'C.RICKEN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3fd79ede-52a5-4f67-b378-05337b3cb95f', 0, 1, 1, 1, NULL, 0),
(918, 'ANDRÉ LUIS', 'COLASANTE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ea298073-fbdc-4428-903a-9017a2dba512', 0, 1, 1, 1, NULL, 0),
(919, 'JANINE DA SILVA ALVES BELLO', 'JANINEALVESBELLO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6c89620c-226d-4b4b-82ea-7cd4a2b5d4fe', 0, 1, 1, 1, 302, 0),
(920, 'KYLIX75@HOTMAIL.COM', 'KYLIX75@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b89cfdaf-8e81-438c-a8fc-85a999469d48', 0, 1, 1, 1, NULL, 0),
(921, 'ADRIANO GASPAR DA SILVA', 'ADRIANOGASPAR@GOLDENGARDEN.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '74a6922f-de19-4960-b44f-7fa532898ab5', 0, 1, 1, 1, 303, 0),
(922, 'PANELA ROCK | O MELHOR DO ROCKN ROLL!', 'PANELAROCK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd0927139-4d52-4cd4-b6b7-c4e988f2972e', 0, 1, 1, 1, 304, 0),
(923, 'MALACMA@APPSPOT.COM', 'MALACMA@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '73cf4513-ac77-4e79-82ea-d7eeba1574a7', 0, 1, 1, 1, NULL, 0),
(924, 'VANIA RIBAS ULBRICHT', 'VRULBRICHT@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '916f828d-6e38-4056-82a3-c505d337b26f', 0, 1, 1, 1, NULL, 0),
(925, 'AILTON HEUSSER', 'JUNIOR.AHJ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd864904d-2730-4501-baf4-2d9b204440ef', 0, 1, 1, 1, 305, 0),
(926, 'CHEILA CILIANA', 'CHEILACILI2008@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '261d3590-64cc-4611-b232-6b188767c740', 0, 1, 1, 1, NULL, 0),
(927, 'CONTATO@LUIZAGUTIERREZ.COM.BR', 'CONTATO@LUIZAGUTIERREZ.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e862ac38-dc4f-49ec-8d18-15f9d6c021ad', 0, 1, 1, 1, NULL, 0),
(928, 'CHARLES FISCHER', 'FISCHER.CHARLES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fea41a28-a2db-4d03-97ae-956dee2b40fc', 0, 1, 1, 1, 306, 0),
(929, 'ALEXANDRE_FIN1@HOTMAIL.COM', 'ALEXANDRE_FIN1@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c4dfa8b2-c5ae-474b-85da-0cd6f3e2a761', 0, 1, 1, 1, NULL, 0),
(930, 'GERENTE DE SUPORTE E ATENDIMENTO - FÁBIO', 'FABIO.COSTA@ADEPTSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f5805ce8-ba90-4fe3-ade1-e54f1be2e1b4', 0, 1, 1, 1, 307, 0),
(931, 'GERENTE DE SUPORTE E ATENDIMENTO - FÁBIO', 'SUPORTE@ADEPTSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b3a0e048-e826-4ec2-86ad-43f9de14b2d7', 0, 1, 1, 1, 308, 0),
(932, 'MAYCON', 'MAYCON@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dd31eba2-8133-4ed0-9a5b-5ccf967134c9', 0, 1, 1, 1, NULL, 0),
(933, 'DOUGLAS KAMINSKI', 'KAMINSKIDK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2daa2f22-8ebc-479b-a894-faf008c828bd', 0, 1, 1, 1, 309, 0),
(934, 'RODRIGOAZLIMA@HOTMAIL.COM', 'RODRIGOAZLIMA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b31082eb-cce0-4f85-af48-f049312af81c', 0, 1, 1, 1, NULL, 0),
(935, 'JEHAN CARLA ZUNINO LUCKMANN MEDEIROS', 'JEHANCARLA@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4ffa2ce1-8d7d-4604-a31e-c7bf5ad3d70a', 0, 1, 1, 1, NULL, 0),
(936, 'LEONARDO OLIVEIRA', 'LEONARDOFLN@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f4e27724-eee3-4f94-b0f2-7540c5f74326', 0, 1, 1, 1, NULL, 0),
(937, 'RENATA COX', 'RENATACOX@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '019baa46-8390-4f2c-8ef5-1fac92c85e5b', 0, 1, 1, 1, NULL, 0),
(938, 'RENATABLOND@HOTMAIL.COM', 'RENATABLOND@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '406fd162-8e4a-4dd3-a98e-7fbcf1ecef98', 0, 1, 1, 1, NULL, 0),
(939, 'CAPACITACAO@CPS.SOFTEX.BR', 'CAPACITACAO@CPS.SOFTEX.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3d6cca6d-ca64-4ee2-8d1a-068d5ddd60ed', 0, 1, 1, 1, NULL, 0),
(940, 'LUCAS MARIN ROSÁRIO', 'LUCASROSARIO@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '872fd052-6461-4e27-8bce-640572229488', 0, 1, 1, 1, NULL, 0),
(941, 'MICHELES RICHARTZ', 'MICHELES48@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '597b828c-ddeb-4287-a5ed-923c9915d349', 0, 1, 1, 1, NULL, 0),
(942, 'PEDRO ♥  LETICIA .', 'GAGSTARACKER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'faaff9df-9983-4a47-a4a2-bb1846359fc3', 0, 1, 1, 1, 310, 0),
(943, 'NÉLIDA MENEZES', 'NELIDAMENEZES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4706ccf7-dd9e-40db-bdf5-f4cbb5a41f2c', 0, 1, 1, 1, 311, 0),
(944, 'EDITOR@SQLMAGAZINE.COM.BR', 'EDITOR@SQLMAGAZINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9b8a082d-8002-47c6-92b7-744c59366ccc', 0, 1, 1, 1, NULL, 0),
(945, 'LUIZ CARLSON', 'INOVACAO@IFSC.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b5aa19a1-011b-43cb-a283-3b5154566d8c', 0, 1, 1, 1, 312, 0),
(946, 'LUIZ CARLSON', 'LUIZHCARLSON@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '56071c69-a19e-4e9f-82eb-1a0b797d4208', 0, 1, 1, 1, 313, 0),
(947, 'BERSACHIN@HOTMAIL.COM', 'BERSACHIN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8aa2c988-ed28-4f1d-8349-d7faa561c76f', 0, 1, 1, 1, NULL, 0),
(948, 'RONYNELSON@HOTMAIL.COM', 'RONYNELSON@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fd58c85a-8d01-4d91-a866-c1e2e8990a82', 0, 1, 1, 1, NULL, 0),
(949, 'TC.SENAI@GMAIL.COM', 'TC.SENAI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '12e160f6-f038-4c55-a16d-fa5c57cbd086', 0, 1, 1, 1, NULL, 0),
(950, 'RENATO RAMOS E RAMOS', 'IRONETWORK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5137cea6-ed95-434d-be00-8e34b8d482ef', 0, 1, 1, 1, 314, 0),
(951, 'MARIA AUGUSTA OROFINO', 'FALECOM@MARIAAUGUSTA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cc4304f5-9788-4131-b261-afbb49d351d9', 0, 1, 1, 1, 315, 0),
(952, 'MARIA AUGUSTA OROFINO', 'PESQUISAMARCONDES187@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f0ae183d-0737-4864-877e-0b52867067ca', 0, 1, 1, 1, 316, 0),
(953, 'FLAVIO CECI', 'FLAVIOCECI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '661fd376-7a50-4e3f-8f5a-96fc5940700a', 0, 1, 1, 1, 317, 0),
(954, 'VANESSA MARTINHO FASC', 'VANESSA.M.FASC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '06455a48-a211-4489-9135-f41a3a7b7406', 0, 1, 1, 1, NULL, 0),
(955, 'FILIPE BERNARDO', 'FILIPEBERNARDO17@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f10748e2-721c-4b13-9913-132826402322', 0, 1, 1, 1, NULL, 0),
(956, 'LUCAS ROSÁRIO', 'LUCASROSARIO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4d8de8c3-f8cb-42e9-b6dd-5227b70f3953', 0, 1, 1, 1, 318, 0),
(957, 'ALESSANDRA GALDO', 'ALESSANDRA.GALDO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0cd1436c-2c2c-4a37-b70c-298c1a0cc313', 0, 1, 1, 1, 319, 0),
(958, 'WEB20@EGC.UFSC.BR', 'WEB20@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '72a3e2d7-78c6-41ab-8949-e3d7c2cffbff', 0, 1, 1, 1, NULL, 0),
(959, 'FTRMIL@HOTMAIL.COM', 'FTRMIL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '62b5e22b-705e-4412-957a-45bec0b7b878', 0, 1, 1, 1, NULL, 0),
(960, 'PATRICIAHERN@LED.UFSC.BR', 'PATRICIAHERN@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '44e11ba3-ad9f-4502-8fae-db512f6570a0', 0, 1, 1, 1, NULL, 0),
(961, 'IGOR RENATO ALMEIDA PEREIRA', 'IGOR.PEREIRA@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b445b7ea-a2ed-4bb6-a0c8-5eb20d5f9b3f', 0, 1, 1, 1, NULL, 0),
(962, 'MÉRCIA PEREIRA', 'MERCIA@REITORIA.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7d1a8a49-1de2-4c88-859b-4df4c1022cb0', 0, 1, 1, 1, NULL, 0),
(963, 'JANAINA_C@HOTMAIL.COM', 'JANAINA_C@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '71528fa2-0af1-4642-beba-6e74b29ea3d5', 0, 1, 1, 1, NULL, 0),
(964, 'FERNANDO OSTUNI-GAUTHIER', 'FERNANDO.GAUTHIER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6266a925-cc38-4c01-923e-da44b7df9617', 0, 1, 1, 1, 320, 0),
(965, 'CASPINTO@YAHOO.COM.BR', 'CASPINTO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c476e1c2-2226-4b1d-a968-eb906eb84851', 0, 1, 1, 1, NULL, 0),
(966, 'ANDRÉ RUAS DE AGUIAR', 'ANDRE@SUPORTTE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8540b288-2760-44cf-bf7e-8016584cc905', 0, 1, 1, 1, 321, 0),
(967, 'ANDRÉ RUAS DE AGUIAR', 'ARARUAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c998328f-6b58-4ce4-9cb4-40974a28e546', 0, 1, 1, 1, 322, 0),
(968, 'ANDRÉ RUAS DE AGUIAR', 'ECONORUAS@IBEST.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '303aa295-629f-4e62-b452-ad65e39e1ab5', 0, 1, 1, 1, 323, 0),
(969, 'JONAS CONSTANTE - INOPLAN', 'JONAS@INOPLAN.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0bdb0315-f1d0-4c53-9d98-cdcfc79cd472', 0, 1, 1, 1, NULL, 0),
(970, 'MARCUSMC5@HOTMAIL.COM', 'MARCUSMC5@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6bcd2cfd-2b88-4e7a-9c5f-c19c0ae69384', 0, 1, 1, 1, NULL, 0),
(971, 'LUCAS NAZÁRIO DOS SANTOS', 'LUCAS@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8977a2df-c0d4-475c-a320-11c42ab540aa', 0, 1, 1, 1, NULL, 0),
(972, 'LEO.LOL@HOTMAIL.COM', 'LEO.LOL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9d023895-aa8f-4f92-8f5e-d455de5af04d', 0, 1, 1, 1, NULL, 0),
(973, 'THAIS GARCIA', 'THAISUFSC.BIBLIO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f270f99a-d8a7-46d6-ba15-95f7c109f997', 0, 1, 1, 1, 324, 0),
(974, 'THAIS GARCIA', 'BEEBEBS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a5bb0184-c59b-4913-b968-40e2faac3fc7', 0, 1, 1, 1, 325, 0),
(975, 'PAULO IASBECH', 'PAULOIASBECH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8f939767-3f7e-439d-b08c-a19cf443db36', 0, 1, 1, 1, 326, 0),
(976, 'FABIULAFLORIPA@GMAIL.COM', 'FABIULAFLORIPA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '19441f14-8870-4f72-b672-3a7a172b720d', 0, 1, 1, 1, NULL, 0),
(977, 'YYEECC@HOTMAIL.COM', 'YYEECC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '03855e16-d7e9-4e90-b804-c300bd370885', 0, 1, 1, 1, NULL, 0),
(978, 'HERMESLUC@HOTMAIL.COM', 'HERMESLUC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2229195a-6b4f-4aac-8554-78bf678b5eb2', 0, 1, 1, 1, NULL, 0),
(979, 'SAIMON PEREIRA', 'SOUDACAF@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'db2c5047-009b-44de-b892-ce461e0f99df', 0, 1, 1, 1, NULL, 0),
(980, 'WILLIANS_PEREIRA@DELL.COM', 'WILLIANS_PEREIRA@DELL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3f50d7c1-a4df-4ca1-b639-382ec17c0f57', 0, 1, 1, 1, NULL, 0),
(981, 'TARADA.CACHORRA22@HOTMAIL.COM', 'TARADA.CACHORRA22@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '627aa8b3-8681-4176-8f6e-ab9cb373201f', 0, 1, 1, 1, NULL, 0),
(982, 'M.A.M.BONILLA@GMAIL.COM', 'M.A.M.BONILLA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3268246b-845c-456a-86cb-3ec9e0d2053b', 0, 1, 1, 1, NULL, 0),
(983, '7TH CONTECSI 2010', 'CONTECSI@USP.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '218e4eca-fcbb-4dc3-8516-8885680ab7de', 0, 1, 1, 1, NULL, 0),
(984, 'MAV .', 'MAU.VALENTE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2ddb871f-74f7-4edf-9bbc-f91189bb8dae', 0, 1, 1, 1, 327, 0),
(985, 'JONATHAS MELLO', 'JONATHAS@CARTEIRO.STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bfec5eee-7d41-4e2d-acbc-a299b9eda754', 0, 1, 1, 1, NULL, 0),
(986, 'TARCISIO VANZIN', 'TVANZIN@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c7ae094-668a-4d90-990b-9eb927547004', 0, 1, 1, 1, NULL, 0),
(987, 'VIVIANEFRAINER@HOTMAIL.COM', 'VIVIANEFRAINER@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dff24e84-c6d9-433d-8f96-8a456ad6f5c8', 0, 1, 1, 1, NULL, 0),
(988, 'ANA PAULA DA C.C. DA SILVA', 'ANAP_SIL@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '56935ebd-55a9-4554-bb80-cab0f57ab6ab', 0, 1, 1, 1, NULL, 0),
(989, 'LIVERWOOD GROUP', 'WEBE889@BTINTERNET.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bd74f660-3f97-4eb0-b14d-b4abd58de5b5', 0, 1, 1, 1, NULL, 0),
(990, 'CLAUDIA BATISTA', 'CLAUDIABATISTA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a5334c96-5311-43bb-91c4-b01e59412a00', 0, 1, 1, 1, 328, 0),
(991, 'RICARDO.WALTER@GMAIL.COM', 'RICARDO.WALTER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '620ee532-fe2e-4619-9dba-fa5e1de91764', 0, 1, 1, 1, NULL, 0),
(992, 'THIAGOSL@INF.UFSC.BR', 'THIAGOSL@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a6e5cdf7-d1f0-4e97-9df2-86c3e8605ef7', 0, 1, 1, 1, NULL, 0),
(993, 'ANA PAIM', 'ANAPAIM33@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '19c89b3d-ac06-483c-af9d-2cc91d82285e', 0, 1, 1, 1, NULL, 0),
(994, 'MARINA NAKAYAMA', 'MARINA.KEIKO.NAKAYAMA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9d8d4c2a-cf3b-44ae-8348-8d02f62e044e', 0, 1, 1, 1, 329, 0),
(995, 'JAQUE BERNARDES (GOOGLE DRIVE)', 'JAQUE.BERNARDES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2da47694-bc1f-415c-be80-aba9295dc33f', 0, 1, 1, 1, NULL, 0),
(996, 'LUCAS FROTA', 'LUCAS_FROTA2@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f6fdb6e1-990d-4ee8-9ef0-03235606ace4', 0, 1, 1, 1, NULL, 0),
(997, 'ANDRÉ HENRIQUE DOTTA', 'ANDREDOTTA@OUTLOOK.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '102677da-1e1b-400c-9a44-d27e19f1b826', 0, 1, 1, 1, NULL, 0),
(998, 'PAULONEDA@HOTMAIL.COM', 'PAULONEDA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '50da17ff-3970-4153-b29b-2ec8dfb2e23c', 0, 1, 1, 1, NULL, 0),
(999, 'OTTE@STGLO.ORG.BR', 'OTTE@STGLO.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'df320ec9-c62c-4597-8fec-1692d2c210d8', 0, 1, 1, 1, NULL, 0),
(1000, 'SCUSSEL.LINEAR@GMAIL.COM', 'SCUSSEL.LINEAR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0c499454-8a06-48a7-b4bb-b665ab4bc43e', 0, 1, 1, 1, NULL, 0),
(1001, 'CAIO SILVA', 'CAIO.CMSILVA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bd8a9e2f-ef7b-4da7-aacc-8d086832ae25', 0, 1, 1, 1, NULL, 0),
(1002, 'ADRIANA NOVELLI', 'ADRIANA@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3ff1dd45-33ca-42aa-8213-7ec10a044217', 0, 1, 1, 1, NULL, 0),
(1003, 'PUCCINIDA@HOTMAIL.COM', 'PUCCINIDA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fbcd3037-b644-409e-9dea-63a2c97d5cd5', 0, 1, 1, 1, NULL, 0),
(1004, 'ANADONNERABREU@HOTMAIL.COM', 'ANADONNERABREU@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ef73603f-c1d3-407b-84aa-0993d30ea20a', 0, 1, 1, 1, NULL, 0),
(1005, 'TDFLORIPA@HOTMAIL.COM', 'TDFLORIPA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5a6bdc35-e0f5-4d2d-b7d1-1227a35b1f6b', 0, 1, 1, 1, NULL, 0),
(1006, 'PATRICIA COSTA', 'PATRICIACOSTA@CURSOSCAD.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6211084f-acaa-4d6b-95b9-170e015a7347', 0, 1, 1, 1, 330, 0),
(1007, 'LARISSA KLEIS', 'LARISSA@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '960be8c9-6916-4fb2-b184-a9f825f84b41', 0, 1, 1, 1, 331, 0),
(1008, 'TONI', 'TONI@DIPROSUL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dace7023-04cb-4c9b-9a2c-c238e837bebe', 0, 1, 1, 1, NULL, 0),
(1009, 'MARCELO CARVALHO', 'MKCMARCELO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f185f7ff-4ffd-432e-a1f3-447449378a6d', 0, 1, 1, 1, NULL, 0),
(1010, 'MALACMA MALACMA', 'MALACMA@YATECH.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b33bcede-d6ec-4a7b-bdfa-eeb5e089e8da', 0, 1, 1, 1, NULL, 0),
(1011, 'KELLY CRISTINA BENETTI TOSTA', 'KELLYCBENETTI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bb6f482a-8dc3-4e4e-b395-b9fc7a2f0e1b', 0, 1, 1, 1, NULL, 0),
(1012, 'LÍVIA DA CRUZ', 'LIVCRUZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e1317a8c-0eed-4d94-8d25-56226360bdaf', 0, 1, 1, 1, 332, 0),
(1013, 'ANDRE', 'ANDRE.COLASANTE@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd678aee6-14f6-4b1a-adc4-02f23d04a050', 0, 1, 1, 1, NULL, 0),
(1014, 'THIAGO_JONES89@HOTMAIL.COM', 'THIAGO_JONES89@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ea0028aa-e7d6-4aa8-95b6-fd5993c76b31', 0, 1, 1, 1, NULL, 0),
(1015, 'BITLY-BOT@APPSPOT.COM', 'BITLY-BOT@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '265b99bc-60e1-45e9-83a7-9ababd3bf008', 0, 1, 1, 1, NULL, 0),
(1016, 'ISMAELCAMPECHE@HOTMAIL.COM', 'ISMAELCAMPECHE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fb018982-7b36-4d12-8d70-d5c0ff2a8d31', 0, 1, 1, 1, NULL, 0),
(1017, 'FERNANDO OSTUNI-GAUTHIER', 'GAUTHIER@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ac06ba85-7075-4eb7-a801-2b6224a8b279', 0, 1, 1, 1, 333, 0),
(1020, 'ALESSANDRO HOFFMANN', 'HOFFMANN.ALESSANDRO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'de8c5989-1bf7-45f1-8b4e-09c835e5d4c6', 0, 1, 1, 1, 336, 0),
(1021, 'SIMONE DIAS', 'SIMONE@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '33c51cd6-0aa2-4bfc-8d19-88a69d59ad37', 0, 1, 1, 1, 337, 0),
(1022, 'IVAN.EMPI@GMAIL.COM', 'IVAN.EMPI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1d83c1d7-425f-471e-ab74-e7c86760cb10', 0, 1, 1, 1, NULL, 0),
(1023, 'ALECIR@SJ.UNIVALI.BR', 'ALECIR@SJ.UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '737f08b3-3209-432d-a03f-fa12a9874086', 0, 1, 1, 1, NULL, 0),
(1024, 'ANARODRIGUES@SC.SENAI.BR', 'ANARODRIGUES@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '75b8a2f1-9b34-4da7-b0f0-a040ced1ae68', 0, 1, 1, 1, NULL, 0),
(1025, 'ELOIJY@GMAIL.COM', 'ELOIJY@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b18efd8b-6922-4156-8c36-6c3788f0b8de', 0, 1, 1, 1, NULL, 0),
(1026, 'MAURICIO GOMES', 'MAUR.GOMES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'be4c65b6-f383-4f73-bb95-89f5e4544186', 0, 1, 1, 1, NULL, 0),
(1027, 'WWW.PATRICK_JP@HOTMAIL.COM', 'WWW.PATRICK_JP@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '356206a3-7ed6-465f-ade3-adc99c52ff21', 0, 1, 1, 1, NULL, 0),
(1028, 'OLHOSNEGROS1@HOTMAIL.COM', 'OLHOSNEGROS1@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6be80c07-920d-459d-b832-de155912bda8', 0, 1, 1, 1, NULL, 0),
(1029, 'IGOR', 'IGOR@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2c6e7443-2775-41ca-a05d-ea4dfe5c6834', 0, 1, 1, 1, NULL, 0),
(1030, 'BIANKA PASSOS', 'BIANKATPAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cfa79a15-d39f-475a-823c-d0702d3b0366', 0, 1, 1, 1, 338, 0),
(1031, 'ENGENHARIA_2014_IESGF@GOOGLEGROUPS.COM', 'ENGENHARIA_2014_IESGF@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b29281a9-5c37-47f9-a039-12bfa865cf66', 0, 1, 1, 1, NULL, 0),
(1032, 'ALEX ESPIRITO SANTO', 'ALEXESTO@BRTURBO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '59b152e0-e556-463e-b5f4-ba77c4883ff4', 0, 1, 1, 1, NULL, 0),
(1033, 'SURFDOMINGO ,AQUI O SURF NÃO TIRA FÉRIAS', 'PONTAWAI@SURFDOMINGO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fa9c74fd-13ed-426f-934c-10029e9c52e3', 0, 1, 1, 1, NULL, 0),
(1034, 'TIA_AGOX@HOTMAIL.COM', 'TIA_AGOX@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6bd6df72-622b-42e4-99f7-dae0b9e23f09', 0, 1, 1, 1, NULL, 0),
(1035, 'FLORIANI_72@YAHOO.COM.BR', 'FLORIANI_72@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b0b02701-0f08-4727-9430-18e921852926', 0, 1, 1, 1, NULL, 0),
(1036, 'CLINICAO@CLINICAOFLORIPA.COM.BR', 'CLINICAO@CLINICAOFLORIPA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '10d83aa3-c85c-4b1a-870d-37474b1eedcb', 0, 1, 1, 1, NULL, 0),
(1037, 'LUIZ080384@GMAIL.COM', 'LUIZ080384@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '560d3505-7646-4af1-b902-091cbb4e5795', 0, 1, 1, 1, NULL, 0),
(1038, 'TRAMAK_PECAS@HOTMAIL.COM', 'TRAMAK_PECAS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a0e6e32a-99a1-436e-8624-adebc3858430', 0, 1, 1, 1, NULL, 0),
(1039, 'MICHELI CAMPANARO GARCIA GHISLENI', 'MICHELI.GARCIA@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cd99d276-8c49-4e76-ae39-13209273e3a5', 0, 1, 1, 1, NULL, 0),
(1040, 'PATRICIAD@IFSC.EDU.BR', 'PATRICIAD@IFSC.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '26deb372-ae4c-466d-b9f5-dcc31fb2353f', 0, 1, 1, 1, NULL, 0),
(1041, 'WOWPROJECT', 'SUPORTE@WOWPROJECT.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a01b4c4c-0b9f-48d9-99c0-c8e81d2b1aab', 0, 1, 1, 1, NULL, 0),
(1042, 'TONINHO-BV@HOTMAIL.COM', 'TONINHO-BV@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '54b7970e-2121-4adf-9ad0-1f7bc11652f5', 0, 1, 1, 1, NULL, 0),
(1043, 'DUSILUCIANE@GMAIL.COM.BR', 'DUSILUCIANE@GMAIL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '617a9861-2a38-4a15-aecb-f29640f328bf', 0, 1, 1, 1, NULL, 0),
(1044, 'LOBER206@GMAIL.COM', 'LOBER206@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '27178d7b-cf3d-40b2-8efe-604f133a2b3b', 0, 1, 1, 1, NULL, 0),
(1045, 'IGOR ALMEIDA', 'RENATO.IGOR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '39aa7384-ef27-4aef-bd8c-ea550e7d1b8a', 0, 1, 1, 1, 339, 0),
(1046, 'MOTTAL@MSN.COM', 'MOTTAL@MSN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9c40c7a3-b693-44bf-9322-d763899cadd3', 0, 1, 1, 1, NULL, 0),
(1047, 'MARCIAMILANI@YAHOO.COM.BR', 'MARCIAMILANI@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e00a6f9a-0319-4619-a411-ea5ceaf42e66', 0, 1, 1, 1, NULL, 0),
(1048, 'RD.SCHMITZ@BOL.COM.BR', 'RD.SCHMITZ@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '18e86836-74e7-45bd-829c-21f224ee6bb7', 0, 1, 1, 1, NULL, 0),
(1049, 'ATIVIDADES ACADEMICAS DO EGC', 'ATIVIDADES.ACADEMICAS@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1eb19251-34c5-45a0-b7b7-23be8d3305e5', 0, 1, 1, 1, NULL, 0),
(1050, 'ANABEL548496@HOTMAIL.COM', 'ANABEL548496@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f9a43a11-704c-4706-a349-25f6af0db804', 0, 1, 1, 1, NULL, 0),
(1051, 'DEVISON SILVA', 'DEYVISONPROX@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7bd580c8-035b-478f-969c-d172e493dce7', 0, 1, 1, 1, 340, 0),
(1052, 'ROBERTA WILLVERT', 'BETA.WILL5518@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '471ca798-7ae6-485e-9056-3fc012913f1b', 0, 1, 1, 1, 341, 0),
(1053, 'LED-UFSC-MIDIA-CONHECIMENTO@GOOGLEGROUPS.COM', 'LED-UFSC-MIDIA-CONHECIMENTO@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '195d0d8a-8fd4-4751-b13f-b0f622b16293', 0, 1, 1, 1, NULL, 0),
(1054, 'DIEGO WAGNER', 'DIEGOWAGNER4@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '15e94d8a-a5e8-48a2-976b-deef85ff7677', 0, 1, 1, 1, 342, 0),
(1055, 'REITZ1984@HOTMAIL.COM', 'REITZ1984@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c8e140a1-5673-4e66-b210-6f78c85db486', 0, 1, 1, 1, NULL, 0),
(1056, 'ALEXANDRE LEOPOLDO GONÇALVES', 'ALEXANDRE.GONCALVES@ARARANGUA.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4f4a6177-805c-4eb6-b7ad-17b0ae04995d', 0, 1, 1, 1, NULL, 0),
(1057, 'ANA PAULA BERTOLDI OBERZINER', 'ANAPAULA_BERTOLDI@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '974644a8-05e4-4c31-87ff-71181b563834', 0, 1, 1, 1, NULL, 0),
(1058, 'MARIO MAYERLE FILHO', 'MARIOMAYERLEFILHO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'da485e33-7866-42f6-a440-5c2fba3316c0', 0, 1, 1, 1, 343, 0),
(1059, 'ANGELA.AMIN@UOL.COM.BR', 'ANGELA.AMIN@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee1cb1a6-6a17-43a6-a1d7-2a4a7da97c66', 0, 1, 1, 1, NULL, 0),
(1060, 'ROBERTO PACHECO', 'PACHECO@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '996d1af6-d430-4f07-8b41-750d75862313', 0, 1, 1, 1, 344, 0),
(1061, 'GERTRUDES DANDOLINI', 'GGTUDE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6712ce50-49c7-4039-a097-d5091983ea42', 0, 1, 1, 1, 345, 0),
(1062, 'EMOTICONBOT@APPSPOT.COM', 'EMOTICONBOT@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '978133ea-25e3-4480-818e-322e58f37d12', 0, 1, 1, 1, NULL, 0),
(1063, 'VILMA VILLAROUCO', 'VILLAROUCO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '159a6ec3-01dd-46c3-b251-fb6f3a39996d', 0, 1, 1, 1, NULL, 0),
(1064, 'LÍDIA PORTO', 'LIDIA.PORTO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '36184149-8232-403d-9fd6-30ac8f81fe0f', 0, 1, 1, 1, NULL, 0),
(1065, 'PALOMA', 'PALOMAFAGUNDES@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '717c5add-87fc-4d29-b117-26912fff6ec5', 0, 1, 1, 1, 346, 0),
(1066, 'MATEUS MARTINS', 'MATEUSHGMARTINS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e0557b34-6618-413c-8418-822ccc7b0a29', 0, 1, 1, 1, NULL, 0),
(1067, 'JOARGENTON@HOTMAIL.COM', 'JOARGENTON@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'adf0811b-d0c7-45ce-a375-9c3c857c9810', 0, 1, 1, 1, NULL, 0);
INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(1068, 'PAULO GOTTFRIED', 'GOTTFRIEDPAULO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd4480496-055b-4795-98df-c9449d13dd50', 0, 1, 1, 1, 347, 0),
(1069, 'GARCIA.RAMMIREZ@GMAIL.COM', 'GARCIA.RAMMIREZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'afec5e7f-f997-46eb-b91a-87b67c8d5f14', 0, 1, 1, 1, NULL, 0),
(1070, 'GIOVANI DE PAULA', 'GIOVANI.PAULA@UNISUL.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9eb3fc32-f403-4ba6-99d8-e985695685fe', 0, 1, 1, 1, NULL, 0),
(1071, 'HENRIQUE OTTE', 'OTTE@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '925c8d01-b161-42d6-bf9c-1eed0b983b8d', 0, 1, 1, 1, NULL, 0),
(1072, 'LUCINHASILVA83@HOTMAIL.COM', 'LUCINHASILVA83@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e4b724e1-daa5-4873-b2cd-b762c1a26bb2', 0, 1, 1, 1, NULL, 0),
(1073, 'MARCELO_BELOTTI@HOTMAIL.COM', 'MARCELO_BELOTTI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '95a5316c-40eb-433a-9e03-585d8a02f6bf', 0, 1, 1, 1, NULL, 0),
(1074, 'ALBERTINA DA SILVA', 'ALBERTINAGE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2f5c7403-98e8-450f-bcc3-3af81f562ebe', 0, 1, 1, 1, NULL, 0),
(1075, 'ANDREZA.FLORIPA@HOTMAIL.COM', 'ANDREZA.FLORIPA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '87bf9ff7-a5b0-41b2-ae07-0aa2fbaf841a', 0, 1, 1, 1, NULL, 0),
(1076, 'DMN.NASCIMENTO@GMAIL.COM', 'DMN.NASCIMENTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fda1b161-10be-47f2-bf47-8a26d5ece5f1', 0, 1, 1, 1, NULL, 0),
(1077, 'TURMA DE INFORMÁTICA TÉCNICO', 'TEC.INFORMATICA.OSMELHORES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '04ba4e4a-0c36-4a2c-8c17-758199d2d02f', 0, 1, 1, 1, 348, 0),
(1078, 'FABIOHM1972@HOTMAIL.COM', 'FABIOHM1972@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd8fc2176-20e2-48a2-b8b2-714fabf66ccf', 0, 1, 1, 1, NULL, 0),
(1079, 'RAFAEL BIANCO', 'RAFA.BIANCO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9df0229d-c236-4e6e-befe-e2fb548a7340', 0, 1, 1, 1, 349, 0),
(1080, 'TCC-SENAI-SJ@GOOGLEGROUPS.COM', 'TCC-SENAI-SJ@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ceb83177-919f-4cf0-add8-2cb9f6e9a8f7', 0, 1, 1, 1, NULL, 0),
(1081, 'CCOMPUTACAO_2012_1_2_IE@GOOGLEGROUPS.COM', 'CCOMPUTACAO_2012_1_2_IE@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c62b9505-d281-43c8-8e2c-848eacc523ea', 0, 1, 1, 1, NULL, 0),
(1082, 'DEBORA CABRAL NAZARIO', 'DEBORA.NAZARIO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'caeb5f21-b86d-45d3-8f88-f8efba332c15', 0, 1, 1, 1, NULL, 0),
(1083, 'AKILA MATOS', 'AKILA.MATOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '12a831e2-9c52-4e74-8ce7-7c95fba01818', 0, 1, 1, 1, NULL, 0),
(1084, 'JOÃO GUILHERME DE OLIVEIRA', 'JGOLIVEIRA78@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-01', '094ad5e7-8854-4c6a-9408-902a7d989317', 0, 1, 1, 1, NULL, 0),
(1085, 'LIDIA_PORTO@ALUNO.SC.SENAI.BR', 'LIDIA_PORTO@ALUNO.SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fd3961eb-cade-4686-8287-a47180a6e420', 0, 1, 1, 1, NULL, 0),
(1086, 'VMOLL@IFSC.BR', 'VMOLL@IFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b4ccc600-38c3-4843-8ff6-5315fc198b43', 0, 1, 1, 1, NULL, 0),
(1087, 'MORGANALEITE@INF.UFSC.BR', 'MORGANALEITE@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0c35f4f0-5594-4c81-9767-bc5b344f1e9c', 0, 1, 1, 1, NULL, 0),
(1088, 'MIDIA-CONHECIMENTO-EGC-ACESSIBILIDADE-DIGITAL@GOOGLEGROUPS.COM', 'MIDIA-CONHECIMENTO-EGC-ACESSIBILIDADE-DIGITAL@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b0032604-338f-4e60-bf7c-e0055cfbee3f', 0, 1, 1, 1, NULL, 0),
(1089, 'CLEBER@HOTMAIL.COM', 'CLEBER@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '52f62c40-a058-49da-82f4-69b63f152429', 0, 1, 1, 1, NULL, 0),
(1090, 'CLIC@CLICNEGOCIS.COM', 'CLIC@CLICNEGOCIS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '894051d6-66f9-4432-93b6-c80becbc74bd', 0, 1, 1, 1, NULL, 0),
(1091, 'TRUNKS_TESTE@HOTMAIL.COM', 'TRUNKS_TESTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '215c2a2d-14f1-497a-b856-70125770d06f', 0, 1, 1, 1, NULL, 0),
(1092, 'CESAR SOUTO-MAIOR', 'CESARCDM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ba691eed-e13a-44a4-ba8e-e781f1d79469', 0, 1, 1, 1, 350, 0),
(1093, 'WILLIAM VIEIRA', 'WILLVCL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f5240864-961d-4d79-a114-a0632a31e320', 0, 1, 1, 1, 351, 0),
(1094, 'SELECAOUNIASSELVI@FUCAP.EDU.BR', 'SELECAOUNIASSELVI@FUCAP.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '23156cdc-bd92-4a36-ad2f-c709e304f1c6', 0, 1, 1, 1, NULL, 0),
(1095, 'RAFAELARQUFSC@GMAIL.COM', 'RAFAELARQUFSC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a2fbf2ea-a69b-4456-bebc-6f1c3dfe4370', 0, 1, 1, 1, NULL, 0),
(1096, 'JHONN_BORGES@HOTMAIL.COM', 'JHONN_BORGES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '454ffa81-2137-4b59-b263-db719221a8de', 0, 1, 1, 1, NULL, 0),
(1097, 'VALDIR NOLL', 'VNOLL@IFSC.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b9c5d19e-0cea-4399-a866-904d40f38594', 0, 1, 1, 1, NULL, 0),
(1098, 'JOSANE FERNANDA LISBOA', 'LISBOA.JOSANEFERNANDA@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b390da24-d5ef-4548-ade8-2c0c42d64e02', 0, 1, 1, 1, NULL, 0),
(1099, 'SELFESTEEMBOOSTER.AS-A-ROBOT@APPSPOT.COM', 'SELFESTEEMBOOSTER.AS-A-ROBOT@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aa2414b4-44e4-483a-b96e-df9b86889323', 0, 1, 1, 1, NULL, 0),
(1100, 'RAFAEL CONRADO', 'CONRADO.SOLISC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fbcde07c-2495-406c-bdab-9b9fe9b43f35', 0, 1, 1, 1, 352, 0),
(1101, 'BUG.NORRIS@HOTMAIL.COM', 'BUG.NORRIS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1ffa4498-fdba-4d40-b566-923e680d9635', 0, 1, 1, 1, NULL, 0),
(1102, 'DILVA FAZZIONI', 'DILVAFAZZIONI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ff0429cd-4836-4d49-8c25-ddcfb46c7b3e', 0, 1, 1, 1, NULL, 0),
(1103, 'LOURDES ALVES', 'LOUAL@LOURDESALVES.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4ae7e56a-2765-484c-b2a5-d9d3710d47d6', 0, 1, 1, 1, NULL, 0),
(1104, 'PANORAMA@NOTICIASDODIA.COM.BR', 'PANORAMA@NOTICIASDODIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd83d26cd-b8d8-43a3-83a2-708b3b795d0a', 0, 1, 1, 1, NULL, 0),
(1105, 'MAU_VALENTE@HOTMAIL.COM', 'MAU_VALENTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '32c611e6-2844-4926-8f73-272c904d039f', 0, 1, 1, 1, NULL, 0),
(1106, 'OSVALDO@JAVAMAGAZINE.COM.BR', 'OSVALDO@JAVAMAGAZINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1b97dfe9-9c02-44c3-94b8-dbabe3a0052d', 0, 1, 1, 1, NULL, 0),
(1107, 'ANDREZA DUARTE', 'ANDREZA.FLORIPA94@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd9f06034-e19c-453b-a031-57610cae9694', 0, 1, 1, 1, NULL, 0),
(1108, 'CRISTIANA PINHO TAVARES DE ABREU', 'CRISTIANA@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '55057cd0-bd3e-446b-8183-5049c93722be', 0, 1, 1, 1, NULL, 0),
(1109, 'FILIPE GHISI', 'FILIPE.GHISI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f192edc7-0e15-4e49-bbe3-2cf5b958d652', 0, 1, 1, 1, 353, 0),
(1110, 'ROSALIA_CRISTINA@HOTMAIL.COM', 'ROSALIA_CRISTINA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7ffba10c-faba-4c75-808d-6b244c4943c3', 0, 1, 1, 1, NULL, 0),
(1111, 'VANUSA VALDA FEIJO', 'NUSA@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bfb1ca00-6c82-4392-afe6-6947eeb01d78', 0, 1, 1, 1, NULL, 0),
(1112, 'DIEGO VIEIRA', 'MONITORDIEGO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bb5ade92-9dee-47f6-8eef-a61b9168b54d', 0, 1, 1, 1, 354, 0),
(1113, 'MAICO_SUBLIMESOM@HOTMAIL.COM', 'MAICO_SUBLIMESOM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2c88f06e-6a64-4b02-9646-d92383a7b3d1', 0, 1, 1, 1, NULL, 0),
(1114, 'ATENDIMENTO@LED.UFSC.BR', 'ATENDIMENTO@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ba2eb4ef-7531-4b5c-9517-f56b10702d05', 0, 1, 1, 1, NULL, 0),
(1115, 'MIRIAN TORQUATO SILVA', 'MIRIANTORQUATO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '715020ec-75d5-4362-981e-1456e2323d25', 0, 1, 1, 1, 355, 0),
(1116, 'CAESC - SOCIETÁRIO', 'SOCIETARIO@CAESC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7c8c9560-1ab2-419c-9c4c-656f19970318', 0, 1, 1, 1, NULL, 0),
(1117, 'EDIÇÃO DE LIVROS', 'LIVRO@PIMENTACULTURAL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c956ed70-4aad-4f25-bdfd-070c6cf94e13', 0, 1, 1, 1, NULL, 0),
(1118, 'NADIAC@UOL.COM.BR', 'NADIAC@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '31759866-c757-4c7d-8c33-e6dbf0255fbe', 0, 1, 1, 1, NULL, 0),
(1119, 'ALTAMIRO DAMIAN PREVE', 'DAMIANPREVE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '01a39021-cc4f-4368-88dd-ee112914a6fa', 0, 1, 1, 1, NULL, 0),
(1120, 'JARTUR', 'JARTUR@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ffefddd6-c461-4770-b439-27a001b22cd7', 0, 1, 1, 1, NULL, 0),
(1121, 'SILVANA ROSA', 'SILVANABERNARDESROSA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '27e8d56d-1c33-4ec2-bb1a-b6ba2252ec95', 0, 1, 1, 1, 356, 0),
(1122, 'ANDRÉ RICARDO RIGHETTO', 'RIGHETTO@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd28b2f36-df3c-4e6d-888e-38be4ec0232b', 0, 1, 1, 1, NULL, 0),
(1123, 'KAMILA RENATA BRITO', 'KAASINHAH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '71b78603-8c5d-4444-8ddf-1cd975c28400', 0, 1, 1, 1, 357, 0),
(1124, 'GISLAINE DE SOUZA', 'DPESSOALIES@UNIP.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '178940b4-7e49-4e58-a8a2-a91aa4de1377', 0, 1, 1, 1, NULL, 0),
(1125, 'CESCOTELECOM ANA', 'ANA@CESCOTELECOM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '45d7ee33-f139-4338-84c6-b62ab7e38a5f', 0, 1, 1, 1, NULL, 0),
(1126, 'SMORETTO@HOTMAIL.COM', 'SMORETTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f556db3a-8fca-46a9-b582-4373ea60e6df', 0, 1, 1, 1, NULL, 0),
(1127, 'DANIELA SOUZA MOREIRA', 'DANI.SMOREIRA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f9add958-ce28-4e12-b4a8-4507d42fc234', 0, 1, 1, 1, 358, 0),
(1128, 'NANA@FUNIBER.ORG', 'NANA@FUNIBER.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '04892ba1-254d-429f-b0b4-ca8c88b78359', 0, 1, 1, 1, NULL, 0),
(1129, 'GIORGIOGILWAN@HOTMAIL.COM', 'GIORGIOGILWAN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '87334a7c-5b8d-4935-9fa3-fae22da21682', 0, 1, 1, 1, NULL, 0),
(1130, 'JEFMARTINI@HOTMAIL.COM', 'JEFMARTINI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7d2be93f-cee5-4964-87f1-e904e627296f', 0, 1, 1, 1, NULL, 0),
(1131, 'AGE5215@BB.COM.BR', 'AGE5215@BB.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'acd30d47-9e45-4887-a749-38986aa83450', 0, 1, 1, 1, NULL, 0),
(1132, 'ELIZIANA♥PATRICK ♥', 'ELIZIANABEATRIZ@GLOBO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6a8aeb5e-de75-4e02-aabb-9201cf77a582', 0, 1, 1, 1, 359, 0),
(1133, 'ELIZIANA♥PATRICK ♥', 'ELIZIANABEATRIZ.EB@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a0b68db8-5b56-453b-96d1-014cf3d1af06', 0, 1, 1, 1, 360, 0),
(1134, 'ANTONIO MARCOS FELICIANO', 'FELICIANO@AGRICULTURA.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3ea917fc-282c-492c-8a98-fc4523c7b901', 0, 1, 1, 1, NULL, 0),
(1135, 'RAFAEL SAVI', 'RAFAELSAVI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5f659d87-df1e-47a0-9b33-3ea1f7e8e8fb', 0, 1, 1, 1, 361, 0),
(1136, 'JOSÉ LEOMARTODESCO', 'TITE@LEC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b3f8a90-0b17-4c7c-b264-e92d1d656859', 0, 1, 1, 1, 362, 0),
(1137, 'JOSÉ LEOMARTODESCO', 'TITETODESCO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ecc9ab00-9a5d-41b0-8111-526e41b7d82b', 0, 1, 1, 1, 363, 0),
(1138, 'EVA MARIA GIL CRUZ', 'EVAMARIA.GIL@AJZ.UCM.ES', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '613938f1-590a-4f78-b1b3-1b0d3c62ca23', 0, 1, 1, 1, NULL, 0),
(1139, 'GMSGUSTAVO@HOTMAIL.COM', 'GMSGUSTAVO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8e60c6ae-0985-47b6-8347-9dc061f66cb5', 0, 1, 1, 1, NULL, 0),
(1140, 'DREZIUS@HOTMAIL.COM', 'DREZIUS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '717469b6-cd6f-49ac-b6ba-f386967db276', 0, 1, 1, 1, NULL, 0),
(1141, 'ADRIANA', 'ADRIBRZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c207854e-457e-4190-a8f7-3d78043532eb', 0, 1, 1, 1, NULL, 0),
(1142, 'VIVIANE_NARDI@HOTMAIL.COM', 'VIVIANE_NARDI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '68cfdd4d-352d-4c4e-a7f9-349c2b97277e', 0, 1, 1, 1, NULL, 0),
(1143, 'CRIS MARTINS', 'CRISMARTINS2611@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ea907173-049d-455a-ae21-4bead5047266', 0, 1, 1, 1, 364, 0),
(1144, 'MEIODIA@RIC.COM.BR', 'MEIODIA@RIC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c57dadc8-5e47-4c77-a421-fbf8fdf5a83d', 0, 1, 1, 1, NULL, 0),
(1145, 'MALAQUIAS@YESTICKET.COM.BR', 'MALAQUIAS@YESTICKET.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e279ec6a-1198-4c0c-bda2-1d7ce2e2112d', 0, 1, 1, 1, NULL, 0),
(1146, 'ADOLFOSK8_114@HOTMAIL.COM', 'ADOLFOSK8_114@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9c793e73-4032-4b6b-b6e8-26e17ffe0e63', 0, 1, 1, 1, NULL, 0),
(1147, 'BOMNEGÓCIO.COM - PAULO', 'PAULUMY5CJ4P1QIG@SMAIL.BOMNEGOCIO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '137e9191-d018-487d-a4a5-c40dda16917f', 0, 1, 1, 1, NULL, 0),
(1148, 'CARLA FLOR', 'CARLA.FLOR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd9045c85-d6d2-4269-8033-e1d9c990fb8c', 0, 1, 1, 1, 365, 0),
(1149, 'NIAS TOUR 2 - SURF TRAVEL EXPERIENCE', 'VENDAS2@NIASTOUR.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1662744e-af77-4f7d-b6f1-499a4c4b6365', 0, 1, 1, 1, NULL, 0),
(1150, 'ANDRÉ DE OLIVEIRA LEITE', 'ANDRELEITE.IES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '04ceae72-5acb-4790-b7a4-9ef7cd6884d7', 0, 1, 1, 1, NULL, 0),
(1151, 'SWGR-SC@DATACOM.IND.BR', 'SWGR-SC@DATACOM.IND.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1d32ffa1-6d66-46b3-956f-ce8d310c8962', 0, 1, 1, 1, NULL, 0),
(1152, 'ANDREA MARRERO', 'ANDREAMARRERO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9c32a50e-2f6c-42da-9ea9-3fd1dea4fdb9', 0, 1, 1, 1, 366, 0),
(1153, 'JONGDERMADY@GMAIL.COM', 'JONGDERMADY@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '38e45ec1-1af9-4a3a-9a6a-fa0e97ee6729', 0, 1, 1, 1, NULL, 0),
(1154, 'ANDREZA_LOPES@IG.COM.BR', 'ANDREZA_LOPES@IG.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dadbe771-4793-4bfb-b89b-686c9786d350', 0, 1, 1, 1, NULL, 0),
(1155, 'THIAGO SOARES NUNES', 'ADM.THIAGOSN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b06eebc9-b550-4470-a4b2-38ff564d93a8', 0, 1, 1, 1, 367, 0),
(1156, 'RODRIGO', 'RODRIGORAMOSM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '211c4b52-6388-4017-9b90-a13b3598d05e', 0, 1, 1, 1, NULL, 0),
(1157, 'GAUTHIER@INF.UFSC.BR', 'GAUTHIER@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '01fa1886-9f52-4f71-aa0f-718fd81516d7', 0, 1, 1, 1, NULL, 0),
(1158, 'KAREM.FABIANI@RBSTV.COM.BR', 'KAREM.FABIANI@RBSTV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3465f788-2c13-4f92-b054-8e84f9fe2911', 0, 1, 1, 1, NULL, 0),
(1159, 'FLASH_MOVEIS_77@HOTMAIL.COM', 'FLASH_MOVEIS_77@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cd8b2c41-9c58-4ac3-8631-76aee0d3bc40', 0, 1, 1, 1, NULL, 0),
(1160, 'DALVA MARISA RIBAS BRUM', 'RIBASBRUM.DM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5ccab425-e8f5-4ea9-aa26-d1c37ce9d343', 0, 1, 1, 1, 368, 0),
(1161, 'CONGRESSO TGS', 'TGSORG@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '44134421-8569-40ca-9e99-f51d9eea1d1a', 0, 1, 1, 1, NULL, 0),
(1162, 'KARINE BARBOSA DE OLIVEIRA', 'KARINEB.IES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '88cf5d5f-d98a-441d-8d7d-921b91e31a7b', 0, 1, 1, 1, NULL, 0),
(1163, 'TECINFO2010.2@GMAIL.COM', 'TECINFO2010.2@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1c6dbfd6-d163-4245-be89-917d0710bd93', 0, 1, 1, 1, NULL, 0),
(1164, 'ALESSANDRE LIVRAMENTO', 'ALELIV74@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '86e90e86-a0fd-4832-a5c9-7ec866aa7014', 0, 1, 1, 1, 369, 0),
(1165, 'ALESSANDRE LIVRAMENTO', 'ALELIVRAMENTO@SODISA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '20e2bd49-b6ba-4436-8dc0-5cb6ba7e6bbc', 0, 1, 1, 1, 370, 0),
(1166, 'ANDRE KOERICH', 'ANDRE@ARADIO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5394e8a5-f64f-4b09-a1fb-2b2cfd5620c5', 0, 1, 1, 1, NULL, 0),
(1167, 'IANDRAPAVANATI@HOTMAIL.COM', 'IANDRAPAVANATI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4eefee68-4d42-4106-a787-b1ed02e753e9', 0, 1, 1, 1, NULL, 0),
(1168, 'MARIAE.TEIXEIRA@HOTMAIL.COM', 'MARIAE.TEIXEIRA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd8b46099-4e38-4887-8f6d-2974d148152e', 0, 1, 1, 1, NULL, 0),
(1169, 'EFRAINFARIAS@HOTMAIL.COM', 'EFRAINFARIAS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c5f832ca-04ae-49ce-9d9e-43db0b0d3e98', 0, 1, 1, 1, NULL, 0),
(1170, 'AIRTON ZANCANELA EGC', 'AIRTONZA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7dc7e607-b3b9-4adc-b2ba-02bbe7dbfe7e', 0, 1, 1, 1, 371, 0),
(1171, 'AIRTON ZANCANELA EGC', 'AIRTONZA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '48ac5da9-f9eb-4e2b-8423-b3852c8b32ed', 0, 1, 1, 1, 372, 0),
(1172, 'JEFFERSON JACQUES ANDRADE', 'JEFFERSONJACQUESANDRADE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '52c4f3b0-fc10-4df8-861e-8e3d5df2e3f8', 0, 1, 1, 1, 373, 0),
(1173, 'FLAVIO MONTIBELLER DA MATA', 'FLAVIOMDAMATA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0281effe-ed3f-45aa-aa14-7ade032f0cf8', 0, 1, 1, 1, NULL, 0),
(1174, 'ROBERTO MARTINS DA SILVEIRA', 'RMSGORDINI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7edcd44b-ffb3-4bf4-ba43-22f17b459093', 0, 1, 1, 1, NULL, 0),
(1175, 'ADM.HELIO@BOL.COM.BR', 'ADM.HELIO@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '67d709fe-6603-4a40-85e4-7c8c830e2c2a', 0, 1, 1, 1, NULL, 0),
(1176, 'LISANDRABESSA@UOL.COM.BR', 'LISANDRABESSA@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '192c2db1-1f57-4892-9636-fee69cf18f03', 0, 1, 1, 1, NULL, 0),
(1177, 'EFRAIMFARIAS@HOTMAIL.COM', 'EFRAIMFARIAS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'adaa0023-3aca-40ab-b629-f668071f8dfb', 0, 1, 1, 1, NULL, 0),
(1178, 'JOSÉ FRANCISCO BERNARDES.', 'JOSEBER@REITORIA.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '45af4bd3-a2f5-43ee-aa6a-dc5d7f65833b', 0, 1, 1, 1, NULL, 0),
(1179, 'NIVIO DOS SANTOS', 'NIVIO.SANTOS@REZULTO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bf17ced5-31fe-4c5b-a3f7-8128410dd679', 0, 1, 1, 1, NULL, 0),
(1180, 'MALACMA@ACM.ORG', 'MALACMA@ACM.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '85df2ca4-3009-45b8-a832-32c3fc4faa3c', 0, 1, 1, 1, NULL, 0),
(1181, 'SIMONESTADNICK@GMAIL.COM', 'SIMONESTADNICK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '329a6394-7ebb-432a-a9b5-0f4388cc4da7', 0, 1, 1, 1, NULL, 0),
(1182, 'RENATA TRILHA', 'RENATATRILHA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '51045be5-4ab1-496c-87ad-89ffd04fb723', 0, 1, 1, 1, 374, 0),
(1183, 'GUILHERME GUSTAVO', 'GUILHERME.BATTISTI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '865a731e-eccd-4c26-b999-4e832823ed34', 0, 1, 1, 1, 375, 0),
(1184, 'OSMAR DA CUNHA FILHO', 'OSMARCF.IES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aab1e9f2-6a09-4db8-b085-48507bb73514', 0, 1, 1, 1, NULL, 0),
(1185, 'PATRICIA HERKENHOFF', 'PATRICIAHERK@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f7fc1005-cabf-4043-8710-427b0f4f0599', 0, 1, 1, 1, NULL, 0),
(1186, 'LEANDRO GUSTAVO NEIS', 'LGN200@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '10c99261-29bb-4bb9-b31f-e72492a80e99', 0, 1, 1, 1, 376, 0),
(1187, 'ANDRÉ NESSRALLA', 'NESSRALLA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7ba1e3b2-83c1-4636-a43e-fd300ad4ec7d', 0, 1, 1, 1, 377, 0),
(1188, 'JULIANODAROSA@HOTMAIL.COM', 'JULIANODAROSA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ce252df3-0f94-400d-a67d-3bce93420bc2', 0, 1, 1, 1, NULL, 0),
(1189, 'ALEXANDRECPY', 'ALEXANDRE', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '67786ab1-b8fd-4dc7-a2f8-072e86d1025a', 0, 1, 1, 1, NULL, 0),
(1190, 'THIAGO MARTINS', 'THIAGOMARTINS1984@HOTMAIL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c1a661a3-1fde-4762-bb74-57e975bbed30', 0, 1, 1, 1, 378, 0),
(1191, 'ELISA PIVETTA', 'ELISA@CAFW.UFSM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '95eaa054-913a-4593-a4a3-3c448cb90afc', 0, 1, 1, 1, 379, 0),
(1192, 'ॐ DANIEL QS', 'DANIEL.ADEPT@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '471e0d05-c4b4-4198-a9f1-2b4dcb0b978b', 0, 1, 1, 1, NULL, 0),
(1193, 'JULIANO DANIEL MARCELINO', 'DEVNULL0@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '516999bb-f426-455c-a85b-2c74e34621e6', 0, 1, 1, 1, 380, 0),
(1194, 'FAROFINOCLINICAVETERINARIA@YAHOO.COM.BR', 'FAROFINOCLINICAVETERINARIA@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '450e40d9-6ecc-40dd-90bd-d30ce09ff841', 0, 1, 1, 1, NULL, 0),
(1195, 'OSMAR DA CUNHA FILHO', 'OSMARCF@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6cb0d607-88d2-4cac-8a65-02b802225f54', 0, 1, 1, 1, NULL, 0),
(1196, 'GEISON MACHADO', 'GEISONMCD@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '56e27ed9-c10e-4c72-956d-faf9ca51b62c', 0, 1, 1, 1, NULL, 0),
(1197, 'CLAUDIONOR.KOSMANN@GMAIL.COM', 'CLAUDIONOR.KOSMANN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f3063d1e-3742-43e2-b928-858b4064f932', 0, 1, 1, 1, NULL, 0),
(1198, 'WALDOIR VALENTIM GOMES JUNIOR', 'WALDOIR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '580272c6-db4a-41f7-9ea4-bede60a2d1cc', 0, 1, 1, 1, 381, 0),
(1199, 'ROGÉRIO CHIAVEGATTI', 'SM.CHIAVEGATTI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '99b3516c-6ae4-4c34-8fcc-c55b23b9e761', 0, 1, 1, 1, 382, 0),
(1200, 'JOÃO SCHORNE AMORIM', 'TCAMORIM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'be09bd28-d3a2-449d-a036-1628b386cf85', 0, 1, 1, 1, NULL, 0),
(1201, 'JORGE GONZAGA JUNIOR', 'JORGEGZJR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6a45e935-42a6-4262-9d3f-9ec0d4839303', 0, 1, 1, 1, 383, 0),
(1202, 'ROBERTO PORTUGAL DE ANDRADE FILHO', 'RPAFILHO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1402acc7-0166-48b3-8be7-897cfadc70e4', 0, 1, 1, 1, 384, 0),
(1203, 'RHENRIQUESOUZA@HOTMAIL.COM', 'RHENRIQUESOUZA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2b330db4-713f-42ed-ac6b-d97e7db320af', 0, 1, 1, 1, NULL, 0),
(1204, 'THIAGO@VIRTUALSOLUCOES.COM.BR', 'THIAGO@VIRTUALSOLUCOES.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '78a05fea-b32b-433e-a522-12516cc859c5', 0, 1, 1, 1, NULL, 0),
(1205, 'MORETTO@EGC.UFSC.BR', 'MORETTO@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'edb69b4d-0bb1-413e-a8fe-dda88deefa4d', 0, 1, 1, 1, NULL, 0),
(1206, 'JOSÉ LEOMAR TODESCO', 'TITE@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8431f389-8bea-4bed-900f-856de0b43ec6', 0, 1, 1, 1, 385, 0),
(1207, 'VELEUTHERIOU@GMAIL.COM', 'VELEUTHERIOU@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '678e8853-0d34-4ef0-9b17-0adf07f06f9f', 0, 1, 1, 1, NULL, 0),
(1208, 'MURILO CESCONETTO', 'MURILO@CESCOTELECOM.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c4665139-2ae7-48b5-ae2c-8c74303e3d00', 0, 1, 1, 1, NULL, 0),
(1209, 'MURILO CESCONETTO', 'MCESCONETTO@BRDIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e487e4a9-baa0-447a-8762-1bf17fe0556f', 0, 1, 1, 1, NULL, 0),
(1210, 'CLAUDIA DIAS DA SILVA', 'CLAUDIADIAS@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ae83636f-eedc-4b27-9f9e-30cf0212c717', 0, 1, 1, 1, NULL, 0),
(1211, 'JANA PETER', 'JANICEPETER@GLOBO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '528cd347-3abb-44d6-99f2-389c9c0d9411', 0, 1, 1, 1, NULL, 0),
(1212, 'SILVER_495@HOTMAIL.COM', 'SILVER_495@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6fe250c5-58ad-457b-b3ac-ab1bf5d607a1', 0, 1, 1, 1, NULL, 0),
(1213, 'VINIZAOCCOELHO@HOTMAIL.COM', 'VINIZAOCCOELHO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a840f407-056c-4230-9f71-3034c3575f85', 0, 1, 1, 1, NULL, 0),
(1214, 'JEFFVIIIANA@GMAIL.COM', 'JEFFVIIIANA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0034a883-5591-413d-a961-678876f0f55a', 0, 1, 1, 1, NULL, 0),
(1215, 'MIPOPOZU@HOTMAIL.COM', 'MIPOPOZU@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c925b7b6-fcb2-47ef-a276-37c27d0163bf', 0, 1, 1, 1, NULL, 0),
(1216, 'FERNANDO PIACENTE', 'FERNANDONAZARIO@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f772b072-4723-4652-acea-809433f79457', 0, 1, 1, 1, NULL, 0),
(1217, 'RAVENAPD@HOTMAIL.COM', 'RAVENAPD@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8df1d832-4d0a-4035-bd97-f82b4123cdc7', 0, 1, 1, 1, NULL, 0),
(1218, 'LOZANO@JAVAMAGAZINE.COM.BR', 'LOZANO@JAVAMAGAZINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5cf93126-26b3-4fb8-b2dc-8034e1fab487', 0, 1, 1, 1, NULL, 0),
(1219, 'ALEXESTO@HOTMAIL.COM', 'ALEXESTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f7af14b6-01b9-41eb-a11a-1a50e8849ec1', 0, 1, 1, 1, NULL, 0),
(1220, 'MO.RENNEBERG@GMAIL.COM', 'MO.RENNEBERG@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1534266e-08b1-4d9e-aeb0-6ee406c24592', 0, 1, 1, 1, NULL, 0),
(1221, 'REDACAO@NOTICIASDODIA.COM.BR', 'REDACAO@NOTICIASDODIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4b75db6b-3ec1-4187-b329-bb9b73f5697d', 0, 1, 1, 1, NULL, 0),
(1222, 'CAESC - CONTÁBIL', 'CONTABIL@CAESC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2522132c-a0d0-40e4-b94d-bef61401336d', 0, 1, 1, 1, NULL, 0),
(1223, 'EL_CHERED@HOTMAIL.COM', 'EL_CHERED@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1c9404c0-7f84-4888-86e5-b147b2211d21', 0, 1, 1, 1, NULL, 0),
(1224, 'GIORGIO GILWAN', 'GIORGIOGILWAN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f2ea2853-c7fc-40ee-94ad-56c700330ed7', 0, 1, 1, 1, NULL, 0),
(1225, 'EVERTON MELO', 'EVERTON.GUT@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '66bafb9d-7880-4705-b087-f85cb9876285', 0, 1, 1, 1, 386, 0),
(1226, 'EVERTON MELO', 'EVERTONGUT@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1b05dee3-94dd-4af0-84b8-958fabbf9c44', 0, 1, 1, 1, 387, 0),
(1227, 'LOBINHO', 'DIEGO.AZEVEDO85@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ec3d5f82-fdf4-4221-8c31-7e8f186939e8', 0, 1, 1, 1, 388, 0),
(1228, 'RODRIGO LENGLER', 'DIGAOLENGLER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8ff55bb9-433f-4292-9a02-9f8e8956c117', 0, 1, 1, 1, 389, 0),
(1229, 'NATALIA KINHIRIN', 'KINHIRIN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '009a39b9-b7f9-4a3e-a428-55079cf8d42d', 0, 1, 1, 1, NULL, 0),
(1230, 'LUÍS AUGUSTO MACHADO MORETTO', 'PINO.RSS.FEED@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '037a9fa1-0197-41f7-9ef8-8f5970d43ee2', 0, 1, 1, 1, NULL, 0),
(1231, 'MARINA MORILLOS', 'MARINA@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'acb9ce0b-876c-44c4-9b73-13c7eea4d239', 0, 1, 1, 1, NULL, 0),
(1232, 'DANILO PUCCINI LEMOS', 'PUCCINIDA@TUTOPIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4ccb1901-23ba-4705-afc9-260627ba0d84', 0, 1, 1, 1, NULL, 0),
(1233, 'NEY ORLANDO RIBEIRO', 'NEYOR@SOFTPLAN.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '28633c9f-d1b1-44f2-906b-a72bb62b84d4', 0, 1, 1, 1, NULL, 0),
(1234, 'KATIA SPECK', 'CATIA.SPECK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1344d8b9-02bc-4b19-a138-e03875b15f3b', 0, 1, 1, 1, NULL, 0),
(1235, 'ANDRE_SEIBT@HOTMAIL.COM', 'ANDRE_SEIBT@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a5c065f9-3d4a-4114-953a-c3fc05e1602e', 0, 1, 1, 1, NULL, 0),
(1236, 'LUCIANA MOTA', 'LUCIANA@BRAZILIANPRODUTOS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '96630ccb-99eb-42fb-8e45-2e42822d5b76', 0, 1, 1, 1, NULL, 0),
(1237, 'KAMILGIGLIO@HOTMAIL.COM', 'KAMILGIGLIO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5e6bd835-4361-4501-8695-bd9cc76e50b4', 0, 1, 1, 1, NULL, 0),
(1238, 'WEBMASTER@FUCAP.EDU.BR', 'WEBMASTER@FUCAP.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dbefb935-cc50-4444-bd8e-95152ec19a0e', 0, 1, 1, 1, NULL, 0),
(1239, 'NANDINHA ACOMPANHANTE', 'PATRICIANORTT@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cb668102-abef-4647-9650-3c1cabb5948b', 0, 1, 1, 1, NULL, 0),
(1240, 'DIVINO@EGC.UFSC.BR', 'DIVINO@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '509ac19e-7a6d-4796-a23d-e58cdd75c505', 0, 1, 1, 1, NULL, 0),
(1241, 'CRISTIANE COELHO', 'CCSRCOELHO@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '51d39e0a-c63f-4292-b9f4-6319bf982180', 0, 1, 1, 1, NULL, 0),
(1242, 'RODRIGO LEMOS', 'DEXTER0X@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '215557e8-8d88-42b0-a814-c32ebb25cdd2', 0, 1, 1, 1, 390, 0),
(1243, 'WORKSHOP.EGC.2008@EGC.UFSC.BR', 'WORKSHOP.EGC.2008@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '704555ff-07e1-4019-bd6f-cbac210fc99f', 0, 1, 1, 1, NULL, 0),
(1244, 'ANTONIO MARCOS FELICIANO', 'FELICIANO.ANTONIOMARCOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fe12f712-93f3-476a-bd90-450ddb4be5bc', 0, 1, 1, 1, 391, 0),
(1245, 'CRISTIANO', 'CRISTIANO.SCHWENING@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2730f992-b877-4bcb-91e5-2ac2d41b144e', 0, 1, 1, 1, NULL, 0),
(1246, 'MOBILE@UPLOAD.FOTOLOG.NET', 'MOBILE@UPLOAD.FOTOLOG.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7b5fd3c3-064f-462b-b22d-ee490676c23c', 0, 1, 1, 1, NULL, 0),
(1247, 'CAMILLA FETTER', 'CAMILLA.FETTER@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f1e93d68-2d3c-4c3e-8849-178d796ff647', 0, 1, 1, 1, NULL, 0),
(1248, 'MORETTOPRISCILLA@HOTMAIL.COM', 'MORETTOPRISCILLA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7565e6c2-64e9-467c-a18b-8efcbe8e3ee6', 0, 1, 1, 1, NULL, 0),
(1249, 'EDUARDO LINHARES', 'ROD.NARUTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bd4357e7-bcdc-481b-af36-e27414930880', 0, 1, 1, 1, 392, 0),
(1250, 'NANDINHA81_FLORIPA@HOTMAIL.COM', 'NANDINHA81_FLORIPA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dbd73543-7463-4efd-a61f-6034ecd6b9b0', 0, 1, 1, 1, NULL, 0),
(1251, 'FLIPPY-WAVE@APPSPOT.COM', 'FLIPPY-WAVE@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0e8ebb07-b3af-4046-8e51-cc869119ad13', 0, 1, 1, 1, NULL, 0),
(1252, 'MARÍLIA AMARAL', 'MARILIA.UTFPR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '90b0a54e-ad03-4544-9a86-d3d06e4cd987', 0, 1, 1, 1, 393, 0),
(1253, 'LLESEC@CCE.UFSC.BR', 'LLESEC@CCE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c988c28-5d3f-4a7e-ad99-346e3b5db9ce', 0, 1, 1, 1, NULL, 0),
(1254, 'SOLANGE MACHADO', 'ANGEMACHADO62@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd7c32d75-9df1-4dfd-bc30-d39c900c7be8', 0, 1, 1, 1, NULL, 0),
(1255, 'ENGENHARIAIES1_Q@GOOGLEGROUPS.COM', 'ENGENHARIAIES1_Q@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1984e5cc-e3fd-4b2a-a058-a99515060ca6', 0, 1, 1, 1, NULL, 0),
(1256, 'LUCIA MORAIS', 'LUCIAMORAIS07@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '546705c7-2183-4f07-b315-72f5b65ac06a', 0, 1, 1, 1, 394, 0),
(1257, 'JOSIELSL@HOTMAIL.COM', 'JOSIELSL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8991ad64-1e3b-43c1-a945-a8a7afb6ff4c', 0, 1, 1, 1, NULL, 0),
(1258, 'FABIANA.NASCIMENTO@RBSTV.COM.BR', 'FABIANA.NASCIMENTO@RBSTV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4bed6943-0e62-46ff-813a-dd247e664f48', 0, 1, 1, 1, NULL, 0),
(1259, 'LEONARDO LIMA', 'NARDOLIMA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ab5eb300-9262-4c2d-9405-2c1c540edb65', 0, 1, 1, 1, 395, 0),
(1260, 'RENATA OLTRAMARI', 'RENATA@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bfa7a892-6850-4a35-a01e-56c90c98e611', 0, 1, 1, 1, NULL, 0),
(1261, 'DIEGODIRUI@HOTMAIL.COM', 'DIEGODIRUI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f0599e3a-aee4-4fa8-ace3-eb2b233b2f2c', 0, 1, 1, 1, NULL, 0),
(1262, 'ASALESSANDRO21@GMAIL.COM', 'ASALESSANDRO21@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2544a4df-0476-4028-b06a-2a82c7289bcd', 0, 1, 1, 1, NULL, 0),
(1263, 'CLAUDIA ALEXANDRA S.PINTO', 'CASPINTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1a6f0b63-b407-4d9c-b225-16b77c51d824', 0, 1, 1, 1, 396, 0),
(1264, 'LUIZ.MORETTO', 'LUIZ.MORETTO@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fe67ad7a-c8d6-4eff-b88c-9e0ed7fe7a3c', 0, 1, 1, 1, NULL, 0),
(1265, 'VINICIUS VICENZI', 'VINICIUSVICENZI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2133ec5e-6cd9-427d-92d2-644650cad086', 0, 1, 1, 1, 397, 0),
(1266, 'KELLY CHRISTIANE ZEFERINO', 'KELLYNHA.ZEFERINO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6ae29bf6-38de-4a80-9e0b-2ab92d9b1042', 0, 1, 1, 1, NULL, 0),
(1267, 'M.A.LA.C.MA@GMAIL.COM', 'M.A.LA.C.MA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9b321912-0620-421a-8dad-88cb1a461a5d', 0, 1, 1, 1, NULL, 0),
(1268, 'SAMUCA_PSY@HOTMAIL.COM', 'SAMUCA_PSY@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2bc31053-0933-40e8-884e-82cf8bdf226d', 0, 1, 1, 1, NULL, 0),
(1269, 'SCOZ@HOTMAIL.COM', 'SCOZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e23a6d3e-b85d-4f05-9148-2328f490c797', 0, 1, 1, 1, NULL, 0),
(1270, 'AUDELINOMORETTO@GMAIL.COM', 'AUDELINOMORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '48ab036e-07b6-45d5-a619-143723439f68', 0, 1, 1, 1, NULL, 0),
(1271, 'MORETTOELIANE2009@HOTMAIL.COM', 'MORETTOELIANE2009@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '638b5510-4ef0-4115-8c73-2a1569a6cf94', 0, 1, 1, 1, NULL, 0),
(1272, 'SIMONE MORETTO CESCONETTO', 'MORETTO.SIMONE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '06fbb995-2490-418d-95c6-7a7f46a8b22f', 0, 1, 1, 1, NULL, 0),
(1273, 'RITHIELE SOUZA', 'RITHIELE_SOUZA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '072b6f5a-9fd6-4dfd-ade4-f045799223b3', 0, 1, 1, 1, NULL, 0),
(1274, 'THAYSON_TITAH@HOTMAIL.COM', 'THAYSON_TITAH@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'affb32be-9107-41a8-b4a1-4a352fb35e38', 0, 1, 1, 1, NULL, 0),
(1275, 'ALEX_PANICO16@HOTMAIL.COM', 'ALEX_PANICO16@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7378ff41-7cbc-4172-b104-7def5c783905', 0, 1, 1, 1, NULL, 0),
(1276, 'LUCIANO@ACAFE.ORG.BR', 'LUCIANO@ACAFE.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bc2ef475-a441-4e2c-a4f1-6c6e46b53fee', 0, 1, 1, 1, NULL, 0),
(1277, 'CRISTIAN FERNANDO SANTIANI', 'CRISTIANSANTIANI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6e3c618a-c853-496c-a829-e8d34f93e8c4', 0, 1, 1, 1, NULL, 0),
(1278, 'PALOMA SANTOS', 'PMARIASANTOS@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f829da75-440f-4d44-8fff-50f45a643ee0', 0, 1, 1, 1, NULL, 0),
(1279, 'FERNANDOLUZCARVALHO@GMAIL.COM', 'FERNANDOLUZCARVALHO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '51d171bb-bf84-47ca-9de9-3f4802afc13d', 0, 1, 1, 1, NULL, 0),
(1280, 'NAZUIA-M MENDES', 'NAZUIA@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a3b34ec4-8906-4d01-ab62-2fcc8a478f63', 0, 1, 1, 1, NULL, 0),
(1281, 'LEANDRO GUSTAVO SCHNEIDER NEVES', 'LEANDROGSN@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '91580cc6-1686-4938-816a-62acb0dc9e3f', 0, 1, 1, 1, NULL, 0),
(1282, 'AIRTON J. SANTOS', 'AIRTON@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4b3cb782-3438-4ecf-beba-4f42e4ce9bb8', 0, 1, 1, 1, NULL, 0),
(1283, 'TATIANA TAKIMOTO', 'TATIANA.TAKIMOTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ec71dd54-3f8b-4b26-b67a-11a537bc5ee0', 0, 1, 1, 1, 398, 0),
(1284, 'TATIANA TAKIMOTO', 'TATA0307@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ebbec7ca-c2f8-4a63-b4d3-9c2bd1967ea9', 0, 1, 1, 1, 399, 0),
(1285, 'TATIANA TAKIMOTO', 'TATIANATAKIMOTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4c9ebf8f-0bd0-4e92-87b1-87bb960f9584', 0, 1, 1, 1, 400, 0),
(1286, 'ANICO@PR.SEBRAE.COM.BR', 'ANICO@PR.SEBRAE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8ce28a47-e6bc-4437-a004-2217332b68df', 0, 1, 1, 1, NULL, 0),
(1287, 'JORGELINA_JUSTINA@HOTMAIL.COM', 'JORGELINA_JUSTINA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6d125c57-33c6-4289-ab30-5b3225d0e446', 0, 1, 1, 1, NULL, 0),
(1288, 'VIAJARCOM@NIASTOUR.COM.BR', 'VIAJARCOM@NIASTOUR.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fd5ff8d1-4f9d-49e0-a31d-6dc6acc6881b', 0, 1, 1, 1, NULL, 0),
(1289, 'SINAPSE', 'SINAPSE@FAPESC.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5f265f94-c22b-4b24-a940-ab13c255799c', 0, 1, 1, 1, NULL, 0),
(1290, 'CAROLINAMACHADO@STAFFRH.INF.BR', 'CAROLINAMACHADO@STAFFRH.INF.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e861ec24-456e-4847-9e14-9eb67567d749', 0, 1, 1, 1, NULL, 0),
(1291, 'GUSTAVO.ISENSEE@HOTMAIL.COM', 'GUSTAVO.ISENSEE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'de744843-9462-4987-9bd9-90c9404d3709', 0, 1, 1, 1, NULL, 0),
(1292, 'ROGERIOMULLER16@HOTMAIL.COM', 'ROGERIOMULLER16@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e75e8fa9-7063-424a-8f25-60193c3407df', 0, 1, 1, 1, NULL, 0),
(1293, 'PRIMO@HOTMAIL.COM', 'PRIMO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '287793e1-2afe-46b2-9506-96e73f12e710', 0, 1, 1, 1, NULL, 0),
(1294, 'THIAGO JONES', 'THIAGOJONES89@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ace3e347-f9c7-4dc5-b7bf-f20f6dc92089', 0, 1, 1, 1, NULL, 0),
(1295, 'DEBEIRAO@UOL.COM.BR', 'DEBEIRAO@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '96b7a9cd-56a7-4c8b-9327-b21bef831ed8', 0, 1, 1, 1, NULL, 0),
(1296, 'HALLAN .', 'HMHALLAN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0712eb3a-1bd7-4954-93c8-8ba5d6b6060a', 0, 1, 1, 1, 401, 0),
(1297, 'MARIANA ROSA ALVES', 'MAARI.ROSA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e8551b85-de56-4165-bd5a-e6fc42e20047', 0, 1, 1, 1, 402, 0),
(1298, 'SIDNEI MORETTO', 'SIDNEI.MORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ac55992b-edc2-4743-80a5-e1d3d9491e4f', 0, 1, 1, 1, 403, 0),
(1299, 'EDUARDO SCHMITT ALBA', 'EDUARDO.ALBA.SC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee4483af-ce8f-4732-b659-ee3c50ac12d3', 0, 1, 1, 1, 404, 0),
(1300, 'EDUARDO SCHMITT ALBA', 'EDUARDOALBASC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4ce338c9-784b-4e92-9689-2c17a9ac2686', 0, 1, 1, 1, 405, 0),
(1301, 'CASSIO', 'CASSIODRUZIANI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f89d7cc6-c82d-4e57-8fd2-ba8957342106', 0, 1, 1, 1, 406, 0),
(1302, 'ALEX@STARTA.COM.BR', 'ALEX@STARTA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b5698201-6c2b-4d97-8d0e-d21b3f290274', 0, 1, 1, 1, NULL, 0),
(1303, 'ARIANA MORETTI', 'ARIANAMORETTI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8d7d8bc5-c4a1-4566-af5f-100d612c4afc', 0, 1, 1, 1, NULL, 0),
(1304, 'RICARDO RABELO', 'RICARDORABELO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '42bb3098-f9eb-427c-8af0-3869f6b437c4', 0, 1, 1, 1, NULL, 0),
(1305, 'MEGACHOD@APPSPOT.COM', 'MEGACHOD@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '97aebdb7-7070-4a3e-8eff-91166d9318af', 0, 1, 1, 1, NULL, 0),
(1306, 'EURIDES', 'EURIDES.BAPTISTELLA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '05171413-e225-4707-876d-2e9c08eb0537', 0, 1, 1, 1, NULL, 0),
(1307, 'SUPORTE CAPACITAÇÃO LED/DEGC/UFSC', 'NIVELAMENTO@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6de5e8b0-ad77-4a8c-9955-dd1f4d30e0cc', 0, 1, 1, 1, NULL, 0),
(1308, 'ARMANDO RIBAS', 'MANDORGR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '283336f3-1186-48fe-9dd0-8d95f7f99cac', 0, 1, 1, 1, 407, 0),
(1309, 'TWEETY-WAVE@APPSPOT.COM', 'TWEETY-WAVE@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '30e5393d-a198-4066-8fe1-899edff03365', 0, 1, 1, 1, NULL, 0),
(1310, 'CANTO DECORATTO', 'CANTODECORATTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '730b37d3-c309-4dbd-9bfd-cd82179a656b', 0, 1, 1, 1, NULL, 0),
(1311, 'MARILIA MATOS GONÇALVES', 'MARILINHAMT@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5132b647-716a-4323-ad1b-8d42dedfb672', 0, 1, 1, 1, 408, 0),
(1312, 'TATY-PIM@HOTMAIL.COM', 'TATY-PIM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c6542495-0bc2-4bb8-9d5a-60ab03e8efe7', 0, 1, 1, 1, NULL, 0),
(1313, 'CARLOS SCHWENTER MACHADO', 'CARLOS.SCHWENTER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b139c4b-1151-41f1-9321-fa8a685e7f65', 0, 1, 1, 1, NULL, 0),
(1314, 'JOSÉ EDUARDO DE LUCCA', 'DELUCCA@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6a699920-5e74-4c21-b871-3ea8631c29ab', 0, 1, 1, 1, NULL, 0),
(1315, 'JUNIA SOARES', 'JUNIA_SOARES@ENABRASIL.SC.GOV.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '654ecf90-37e3-406b-89f5-ccedb1c4577f', 0, 1, 1, 1, NULL, 0),
(1316, 'IAVW@BOL.COM.BR', 'IAVW@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fc3e059e-632b-4589-b0ef-b0d983d40f7e', 0, 1, 1, 1, NULL, 0),
(1317, 'LEO@LEOCOELHO.COM', 'LEO@LEOCOELHO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '38a09a74-1479-47ec-9ded-6160f535330c', 0, 1, 1, 1, NULL, 0),
(1318, 'JANIEIRY QUEIROGA', 'JANYQC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '808058d8-a11c-4bc2-9d13-1cd81d1c0597', 0, 1, 1, 1, NULL, 0),
(1319, 'CRISTIANSANTIANI@CEPUNET.COM.BR', 'CRISTIANSANTIANI@CEPUNET.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a5d5bfc8-b601-4205-915f-154bc9880ac0', 0, 1, 1, 1, NULL, 0),
(1320, 'SERGIO GENILSON PFLEGER', 'SERGIO@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a7ed47a7-9a19-4fb3-8f53-b3dac5ff1aca', 0, 1, 1, 1, NULL, 0),
(1321, 'KENIA.PICKLER@GMAIL.COM', 'KENIA.PICKLER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0f51e14a-3f7e-4e69-8a69-08afd12ae981', 0, 1, 1, 1, NULL, 0),
(1322, 'RLV1608@HOTMAIL.COM', 'RLV1608@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9fb9b809-7b4f-4ddc-ace4-f18e873c7b40', 0, 1, 1, 1, NULL, 0),
(1323, 'TESTEFABIO10@HOTMAIL.COM', 'TESTEFABIO10@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '824ad83e-7cc9-4a55-adaf-f7e3eccd1b0c', 0, 1, 1, 1, NULL, 0),
(1324, 'DANIELA SAITO', 'DANIELA.SAITO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1c96a37d-6ae2-4480-aa64-800ffd3c72ea', 0, 1, 1, 1, 409, 0),
(1325, 'DANIELA SAITO', 'DANIELASAITO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5032736d-c9d6-47be-843d-f0d2c44ff52f', 0, 1, 1, 1, 410, 0),
(1326, 'JOCIEL GAMBA', 'JOCIELGAMBA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '41ab5d23-5959-4198-b905-b42fdcee0cc4', 0, 1, 1, 1, NULL, 0),
(1327, 'YOKO-35@HOTMAIL.COM', 'YOKO-35@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2e34cc9c-12d6-4fb1-8df4-b4ef10fbe557', 0, 1, 1, 1, NULL, 0),
(1328, '* PA *', 'SANTOS.PALOMA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cb81a710-74bb-499e-9b06-72d85e571c0d', 0, 1, 1, 1, 411, 0),
(1329, '* PA *', 'SANTOSPALOMA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6b46ab61-9a6c-4abe-add2-03fb1030d7a3', 0, 1, 1, 1, 412, 0),
(1330, 'MARLY ANDRADE', 'MARLYANDRADE@ISCC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'af46799b-45dd-4781-a892-40e14e1351ca', 0, 1, 1, 1, NULL, 0),
(1331, 'MORETTO', 'MORETTO@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '303a4d71-a1d8-4fb8-a695-7e8e18d9559a', 0, 1, 1, 1, NULL, 0),
(1332, 'COMPRADOR INTERESSADO', 'RAFAMOSSI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e979b06f-11ac-4537-8839-8bd4530d878c', 0, 1, 1, 1, NULL, 0),
(1333, 'FABIAN.LONDERO@RBSTV.COM.BR', 'FABIAN.LONDERO@RBSTV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '08971501-9812-4610-8e9c-9f2c9d65df93', 0, 1, 1, 1, NULL, 0),
(1334, 'MARCIACRISTINA@SC.SENAI.BR', 'MARCIACRISTINA@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fadc733b-3936-4d2a-9fa4-049b6540869c', 0, 1, 1, 1, NULL, 0),
(1335, 'PRODUCAO-INDUSTRIAL@GOOGLEGROUPS.COM', 'PRODUCAO-INDUSTRIAL@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e0e1e3b9-cd3b-4d57-8b67-ad732a9b4264', 0, 1, 1, 1, NULL, 0),
(1336, 'RMATIASJR@HOTMAIL.COM', 'RMATIASJR@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '90de3817-e9e1-4329-9ce0-3e50064ccc46', 0, 1, 1, 1, NULL, 0),
(1337, 'KELLY BENETTI', 'KELLYADM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a13fdb2f-eaba-434b-aba6-00b5d2d5567f', 0, 1, 1, 1, NULL, 0),
(1338, 'PROF. LIA CAETANO BASTOS, DRA.', 'ECV1LCB@ECV.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eb909013-df5d-4504-b856-a6226076c557', 0, 1, 1, 1, NULL, 0),
(1339, 'EDO GASPARETTO', 'EDO@CONTEXTODIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '945e29a8-71b4-4496-b319-a4929c91ea5f', 0, 1, 1, 1, NULL, 0),
(1340, 'CESARCDM@YAHOO.COM.BR', 'CESARCDM@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4bc714e5-e33d-41ea-9343-fdcb966662f7', 0, 1, 1, 1, NULL, 0),
(1341, 'LUCIANORATH@GMAIL.COM', 'LUCIANORATH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '669f3f1c-e5ed-4424-8722-2f5c5c4f37b5', 0, 1, 1, 1, NULL, 0),
(1342, 'ADEMIR LEONARDO DUARTE', 'ALDUARTE23@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fb72cfa1-4ec5-415b-90ae-e72094ffa165', 0, 1, 1, 1, NULL, 0),
(1343, 'ANA LUCIA ZANDOMENEGHI', 'ANAZANDOMENEGHI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8e72b087-7928-4221-a4dd-8e56c17e3dd0', 0, 1, 1, 1, NULL, 0),
(1344, 'GUSTAVO ISENSEE', 'GUSTAVO.ISENSEE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a8715462-5e0e-48ca-b567-bbe2f5577681', 0, 1, 1, 1, 413, 0),
(1345, 'LIDIA SOUSA', 'ANGEL_DARK06@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2a9d292b-c701-406f-8e3a-daaf22e01bdc', 0, 1, 1, 1, NULL, 0),
(1346, 'JOE.ALVES@HOTMAIL.COM', 'JOE.ALVES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b2a5a33a-8bfd-4be9-ade4-93e397eb3d8d', 0, 1, 1, 1, NULL, 0),
(1347, '6ENEMPRE@GOOGLEGROUPS.COM', '6ENEMPRE@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9a8e6fda-7f5e-4bc0-b913-dc0ecdce8328', 0, 1, 1, 1, NULL, 0),
(1348, 'HALLAK@MODEL.IAG.USP.BR', 'HALLAK@MODEL.IAG.USP.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '58c43fe3-55ae-4c53-affc-dbfd54b92224', 0, 1, 1, 1, NULL, 0),
(1349, 'LEO.DANIELLI@HOTMAIL.COM', 'LEO.DANIELLI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1aa0d576-cd9e-410f-b37e-70f74cd2e7ae', 0, 1, 1, 1, NULL, 0),
(1350, 'TECNOLOGIA@LABORCIENCIA.COM', 'TECNOLOGIA@LABORCIENCIA.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '751312fd-7924-406f-afe7-620168301f60', 0, 1, 1, 1, NULL, 0),
(1351, 'TECINF2010.2@GMAIL.COM', 'TECINF2010.2@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '99e84885-5043-4047-a883-cf7e239da127', 0, 1, 1, 1, NULL, 0),
(1352, 'PAGO@KINGHOST.COM.BR', 'PAGO@KINGHOST.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'de00bfb2-1e48-4fa5-b28c-674463cd8969', 0, 1, 1, 1, NULL, 0);
INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(1353, 'MNORONHAM@GMAIL.COM', 'MNORONHAM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '46ca9d8f-9078-4de0-acdc-64706f8b68d6', 0, 1, 1, 1, NULL, 0),
(1354, 'ANA PAULA DA CUNDA CORREA DA SILVA', 'ANAPCCS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e4391dba-d87b-410b-87c8-01dbd7fc7a76', 0, 1, 1, 1, NULL, 0),
(1355, 'RAMOSMA@UOL.COM.BR', 'RAMOSMA@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6de6aa0f-51eb-4771-b570-9fbfc3339011', 0, 1, 1, 1, NULL, 0),
(1356, 'PAULONEDA@GMAIL.COM', 'PAULONEDA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '897e9558-2c08-44c7-bc1e-70dc890bb748', 0, 1, 1, 1, NULL, 0),
(1357, 'ADRIVALGAS.CGC.UNIP.BR@GMAIL.COM', 'ADRIVALGAS.CGC.UNIP.BR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a225c9f-47df-404a-8f1d-9dd4f11dae7a', 0, 1, 1, 1, NULL, 0),
(1358, 'ELIAS_LDC@HOTMAIL.COM', 'ELIAS_LDC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b6b4dbbb-a644-43f4-84f3-03f4e23a4057', 0, 1, 1, 1, NULL, 0),
(1359, 'VIVIANE SCHNEIDER', 'VIVIANE.SCH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9e8c039f-a792-42bb-aada-b8561ba87f71', 0, 1, 1, 1, 414, 0),
(1360, 'MEIODIA@RICSC.COM.BR', 'MEIODIA@RICSC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ab7e76a5-2250-48d2-be8b-d6f68e7dcb77', 0, 1, 1, 1, NULL, 0),
(1361, 'FRANCIELLEMARQUINHADEBIQUINI@HOTMAIL.COM', 'FRANCIELLEMARQUINHADEBIQUINI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f0256419-46eb-4651-92f0-3a43dc7457e5', 0, 1, 1, 1, NULL, 0),
(1362, 'JEAN MALAQUIAS', 'BURGUEXX@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5ea30ef7-d6f9-40ea-a2b7-3ed2dbc0377f', 0, 1, 1, 1, 415, 0),
(1363, 'JADES JADES', 'JADES@INTERCORP.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e5036de4-c929-4438-927e-ea74e6c55afe', 0, 1, 1, 1, NULL, 0),
(1364, 'DIEGOSCP@GMAIL.COM', 'DIEGOSCP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1928b2dc-65d8-4d3c-b87b-2c1c0a57284e', 0, 1, 1, 1, NULL, 0),
(1365, 'ACYBIS@GMAIL.COM', 'ACYBIS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '73477430-f07b-4161-8b78-d485ce4cfcda', 0, 1, 1, 1, NULL, 0),
(1366, 'ANDRÉ ALESSANDRO STEIN', 'ANDRESTEIN77@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3415c134-7f92-4c5b-88b6-30f695145b3a', 0, 1, 1, 1, 416, 0),
(1367, 'ANDRÉ ALESSANDRO STEIN', 'ANDRE.STEIN@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dbea34d8-299d-4dbf-bbc9-111fc21a094b', 0, 1, 1, 1, 417, 0),
(1368, 'RODOLFO SCHMIDT', 'RODPH15@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '458d21f2-e934-4128-9bd0-63014b3d6c80', 0, 1, 1, 1, 418, 0),
(1369, 'AQUILA.MATOS@GMAIL.COM', 'AQUILA.MATOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7b3cf168-bc3e-4612-ba18-eedfe8fbc3d6', 0, 1, 1, 1, NULL, 0),
(1370, 'PAULOKIAI@HOTMAIL.COM', 'PAULOKIAI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f847bed6-568d-4318-9b22-790accbc93aa', 0, 1, 1, 1, NULL, 0),
(1371, 'MDIAS@UNIVALI.BR', 'MDIAS@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '261617a5-8e9c-44b8-b274-51d693b20da9', 0, 1, 1, 1, NULL, 0),
(1372, 'BIANCAK@SC.SEBRAE.COM.BR', 'BIANCAK@SC.SEBRAE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0102a4b0-0987-4dc2-97bd-6a8bf409b5b0', 0, 1, 1, 1, NULL, 0),
(1373, 'MARCO@KOERICH.COM.BR', 'MARCO@KOERICH.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd22a0803-7ff9-40ea-ab10-a7b042e0dd6d', 0, 1, 1, 1, NULL, 0),
(1374, 'COORDENAÇÃO ESAB', 'COORDENACAO.ESAB@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '31cb3a0a-c168-4abc-b979-71a945d4626d', 0, 1, 1, 1, NULL, 0),
(1375, 'RODRIGO SILVA', 'RODRIGO@C9CORRETORADEIMOVEIS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9604e899-cc91-479c-9166-4755c3b27372', 0, 1, 1, 1, NULL, 0),
(1376, 'JORGE PAULINO DA SILVA FILHO', 'JORGEPSF@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7f55df14-abec-4577-b68d-71f67142035b', 0, 1, 1, 1, NULL, 0),
(1377, 'ADRIANA RODRIGUES ZILLI', 'ARODRIGUES@SC.SENAI.BRR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '69abe1a3-baf8-409b-8aca-b838613e13fa', 0, 1, 1, 1, NULL, 0),
(1378, 'CCOMP-SJ@LISTAS.UNIVALI.BR', 'CCOMP-SJ@LISTAS.UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3a206a21-02b2-4275-8e9f-35bb47a5245c', 0, 1, 1, 1, NULL, 0),
(1379, 'JANAINA COSTA', 'HEYJANAC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cb18d9dc-695a-419f-9ed9-af7f13afdb5d', 0, 1, 1, 1, 419, 0),
(1380, 'GUAPO@MUNDOJAVA.COM.BR', 'GUAPO@MUNDOJAVA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '811a0177-59ac-4d75-95c5-101fc5e553b0', 0, 1, 1, 1, NULL, 0),
(1381, 'COMPENSADOSFERNANDES@COMPENSADOSFERNANDES.COM.BR', 'COMPENSADOSFERNANDES@COMPENSADOSFERNANDES.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b8a90d56-d2d9-4948-b4eb-c0ae2b8d0f72', 0, 1, 1, 1, NULL, 0),
(1382, 'ELIANE SILVA', 'ELIANEMSILVA2005@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f708a8e3-9d7a-415c-84b9-f6a4d7174d42', 0, 1, 1, 1, NULL, 0),
(1383, 'GEORGE', 'GEORGE.MARTINS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c0577c1a-6352-4bec-a508-5c28297fbca0', 0, 1, 1, 1, NULL, 0),
(1384, 'NAO_ADICIONEM@HOTMAIL.COM', 'NAO_ADICIONEM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '368134b1-41f5-4881-863c-4b25d84034eb', 0, 1, 1, 1, NULL, 0),
(1385, 'PATRÍCIA DE SÁ FREIRE', 'PATRICIASAFREIRE@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8c75f8f8-5902-4e6a-98aa-0bf3222faacd', 0, 1, 1, 1, NULL, 0),
(1386, 'ANA CÉLIA BOHN BIDO', 'ANACELIABIDO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bef84b62-c184-4340-8f82-22090d09829a', 0, 1, 1, 1, 420, 0),
(1387, 'GUIME ॐ', 'GUIME28@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2812bdf2-2299-45ee-9140-27eaea946185', 0, 1, 1, 1, NULL, 0),
(1388, 'MARILENE SPECK', 'NOREPLY@SONICOMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c989f0bd-df59-4a22-9a14-803f32b9aac1', 0, 1, 1, 1, NULL, 0),
(1389, 'MAGNOS PIZZONI', 'MRPIZZONI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '08b325a7-e157-4370-9844-9a694fe3c5c2', 0, 1, 1, 1, NULL, 0),
(1390, 'DVS_DANIEL@HOTMAIL.COM', 'DVS_DANIEL@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e9283e9d-a752-4062-899d-2c206de577f9', 0, 1, 1, 1, NULL, 0),
(1391, 'CARREIRA WPLEX', 'CARREIRA@WPLEX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '03c44ebf-66cc-450f-b05e-aed8aa30bd9f', 0, 1, 1, 1, NULL, 0),
(1392, 'VERÔNICA CÚRCIO', 'VERONICA@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2cdec02e-f02a-47fa-9d60-5d266c703cbf', 0, 1, 1, 1, NULL, 0),
(1393, 'MASHABLE-SUBMITTY@APPSPOT.COM', 'MASHABLE-SUBMITTY@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8c16116a-2e96-477b-8a77-676bdd8870e6', 0, 1, 1, 1, NULL, 0),
(1394, 'PAULO JULIANO BURIN', 'PBURIN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cfcd2b54-6917-4a78-9a3d-2b20ccf7d767', 0, 1, 1, 1, 421, 0),
(1395, 'KETLLE PAES', 'KETLLEP@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '86c4212f-c134-4d3d-b93f-d66d3680635f', 0, 1, 1, 1, NULL, 0),
(1396, 'CCOMPUTACAO_2012_1_2_IES@GOOGLEGROUPS.COM', 'CCOMPUTACAO_2012_1_2_IES@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ade75032-5b7c-47fd-874a-b1b779f0539a', 0, 1, 1, 1, NULL, 0),
(1397, 'JOSÉ JOÃO DA SILVA (BABA JR)', 'BABAJR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c36c1072-7ebb-4280-bf42-22f2f631edf7', 0, 1, 1, 1, 422, 0),
(1398, 'JAISON REIS', 'JAISON_REIS@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e88bb2b1-2992-40da-b841-d2c95f1ce26f', 0, 1, 1, 1, NULL, 0),
(1399, 'MAIÁRA VIEIRA', 'MAY.VIEIRAH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1de9f11c-98a7-4633-959a-dc9ee1e9bcf4', 0, 1, 1, 1, NULL, 0),
(1400, 'MAIÁRA VIEIRA', 'MAYVIEIRAH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '358a9b66-4fc4-4689-97ce-9a27888aeacd', 0, 1, 1, 1, NULL, 0),
(1401, 'LENINJINKINGS@HOTMAIL.COM', 'LENINJINKINGS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '71b69ed3-dade-4f99-8be7-99a6ffdb3c9b', 0, 1, 1, 1, NULL, 0),
(1402, 'ANA JULIA DAL FORNO', 'ANAJUDALFORNO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e3f8bfca-b622-492f-9d82-571e0060b239', 0, 1, 1, 1, 423, 0),
(1403, 'FERNANDO S. GOULART', 'FGOULART70@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c00c9a97-295c-415d-89da-b6d2aaa0d3d5', 0, 1, 1, 1, 424, 0),
(1404, 'TANIA REGINA', 'TANIA.DEON@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2e6cd50d-25b7-443a-b350-5d053e663ac1', 0, 1, 1, 1, NULL, 0),
(1405, 'TECNCOPIAS@GMAIL.COM', 'TECNCOPIAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c559d16c-faa6-4d6f-8079-7b9d275d5991', 0, 1, 1, 1, NULL, 0),
(1406, 'MATHEUSBFAGUNDES@HOTMAIL.COM', 'MATHEUSBFAGUNDES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8ffeb4ee-0429-4de2-bbf1-e97929696196', 0, 1, 1, 1, NULL, 0),
(1407, 'MAC DONALD CAMPOS DE ALMEIDA', 'MAC.ALMEIDA@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fe0d04d9-2d9e-4c5d-9c3c-5b70c5ae8fac', 0, 1, 1, 1, NULL, 0),
(1408, 'LENIRA@FUNIBER.ORG', 'LENIRA@FUNIBER.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '898f88a5-4525-4429-819e-2384b1f35d46', 0, 1, 1, 1, NULL, 0),
(1409, 'PATYGPFLORIPA@HOTMAIL.COM', 'PATYGPFLORIPA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5b9faf15-ceda-42b7-95b3-23c081800102', 0, 1, 1, 1, NULL, 0),
(1410, 'RODMAR.FRASSETTO', 'RODMAR.FRASSETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9049406e-6d5f-4441-bcb4-5843b0c5f8da', 0, 1, 1, 1, 425, 0),
(1411, 'RENATA RODRIGUES', 'RENATA@PTA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1ec3e3bf-9e0a-4665-b2c3-f29e872f24ed', 0, 1, 1, 1, NULL, 0),
(1412, 'MBRAGA@FAPEAL.BR', 'MBRAGA@FAPEAL.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c49eab75-fdd2-4a58-a979-e2bd66658159', 0, 1, 1, 1, NULL, 0),
(1413, 'CHARLESGLA@OUTLOOK.COM', 'CHARLESGLA@OUTLOOK.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '12a43f87-c866-4bba-ac20-82ff06448784', 0, 1, 1, 1, 426, 0),
(1414, 'MARIANA ROSA ALVES', 'MARIANA.RALVES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7763ec99-72c5-4527-8a74-62fe195ed712', 0, 1, 1, 1, 427, 0),
(1415, 'JEAN MALAQUIAS', 'JEAN@SULIT.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f7704e5b-bdb7-411b-ae6c-6362dfebaf4c', 0, 1, 1, 1, NULL, 0),
(1416, 'CASTILHO.POS@GMAIL.COM', 'CASTILHO.POS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7d230420-f300-46f7-9d67-5ba862150248', 0, 1, 1, 1, NULL, 0),
(1417, 'MARGARETTESSARI133@HOTMAIL.COM', 'MARGARETTESSARI133@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '70ed7d27-77ce-4cf5-a966-ab195204deaf', 0, 1, 1, 1, NULL, 0),
(1418, 'FAITER_FC@HOTMAIL.COM', 'FAITER_FC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8ebbccdb-c30d-434f-948d-e78445623200', 0, 1, 1, 1, NULL, 0),
(1419, 'BRUNO INDALÊNCIO DE CAMPOS', 'BRUNO12DESIGN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b1e75952-004d-4a2f-82e8-6aa693bd7d52', 0, 1, 1, 1, NULL, 0),
(1420, 'LISANDRA.N@RBSTV.COM.BR', 'LISANDRA.N@RBSTV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '434f6b9e-be16-492c-8c54-077b94bf3538', 0, 1, 1, 1, NULL, 0),
(1421, 'DEPAULA@UNISUL.BR', 'DEPAULA@UNISUL.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a8266369-c97b-4c8e-a639-4d01e3cd056b', 0, 1, 1, 1, NULL, 0),
(1422, 'ROTEIROS DISCIPLINAS', 'ROTEIROS@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '74c9b14d-fe1b-451c-b34e-61b87bb5d54a', 0, 1, 1, 1, NULL, 0),
(1423, 'MARCIO ZAGO ANDRADE', 'MARCIOZA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '60d14efe-d772-49be-8ea6-cac498b6968f', 0, 1, 1, 1, 428, 0),
(1424, 'SCJA_SUN@GOOGLEGROUPS.COM', 'SCJA_SUN@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '950bb468-ce9f-4cfd-aab1-520e6efeaea3', 0, 1, 1, 1, NULL, 0),
(1425, 'NIVIO_SANTOS@HOTMAIL.COM', 'NIVIO_SANTOS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e3ec43e4-4a9b-43d5-be01-2ded66aa3572', 0, 1, 1, 1, NULL, 0),
(1426, 'ARTUR@GMAIL.COM', 'ARTUR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '82289f09-20ce-4778-9a0f-770e2706b089', 0, 1, 1, 1, NULL, 0),
(1427, 'MLTEMP@GMAIL.COM', 'MLTEMP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd8093f9a-4ddf-49de-8a2c-158f39733fc0', 0, 1, 1, 1, 429, 0),
(1428, 'ROBERTO MARTINS', 'RMSILVEIRA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '34a21af3-02cd-4017-a9c0-63dc6feebd7f', 0, 1, 1, 1, NULL, 0),
(1429, 'ADRIANO HEIS', 'ADRIANO.HEIS@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd9ab8dbc-9e38-40e4-922e-f7cf1f75d164', 0, 1, 1, 1, 430, 0),
(1430, 'ADRIANO HEIS', 'ADRIANO.REIS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7152035c-bbaa-4fc7-9f1c-97ec78ff43cc', 0, 1, 1, 1, 431, 0),
(1431, 'ADRIANO HEIS', 'ADRIANO.HEIS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '868dd8f5-a838-4f68-9b04-bcbbae00eb51', 0, 1, 1, 1, 432, 0),
(1432, 'TIAGO RAUPP', 'TIAGO_RAUPP@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cbe17335-0c1f-412d-9d46-70bbdcb630d0', 0, 1, 1, 1, 433, 0),
(1433, 'COMERCIALDHG@GMAIL.COM', 'COMERCIALDHG@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9572185c-55c7-4f98-a6f3-251e9a75edf8', 0, 1, 1, 1, NULL, 0),
(1434, 'ADILSONPARISE@HOTMAIL.COM', 'ADILSONPARISE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '16c200de-d72f-46fd-a270-9010e9fa7209', 0, 1, 1, 1, NULL, 0),
(1435, 'MURILO O IMORTAL', 'MURILO.ID@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '048e05fa-a11e-4e77-8722-863392dcd38d', 0, 1, 1, 1, NULL, 0),
(1436, 'MARILIA.UFSC@GMAIL.COM', 'MARILIA.UFSC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7d3f8953-e3de-46d2-871c-1883e33f1b1c', 0, 1, 1, 1, NULL, 0),
(1437, 'ANDREABORD@GMAIL.COM', 'ANDREABORD@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '244f7f44-f042-464d-93f4-1d1c12ab023d', 0, 1, 1, 1, NULL, 0),
(1438, 'LEONARDOMANGRICH@HOTMAIL.COM', 'LEONARDOMANGRICH@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e9396ac5-c227-435d-a463-9502e041a807', 0, 1, 1, 1, NULL, 0),
(1439, 'DOUGLAS KAMINSKI', 'KAMINSKI@ENERGIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '726ea48f-c961-4669-a171-3c7eeeb185ea', 0, 1, 1, 1, NULL, 0),
(1440, 'ALEMÃO', 'SERGIOGENILSON@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '86a75c20-530b-4601-b2f2-82554f414924', 0, 1, 1, 1, 434, 0),
(1441, 'EDUARDO MARTINS POLMANN', 'KIETINHU@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '42ac4579-2265-4d54-9ced-fb6bb039002c', 0, 1, 1, 1, 435, 0),
(1442, 'ISABEL MARIA BARREIROS LUCLKTENBERG', 'ISABELMBLU@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5fe28b39-b2a3-48eb-a8d1-856b3cac672f', 0, 1, 1, 1, 436, 0),
(1443, 'JOSÉ RENATO INAITEC', 'JOSERENATO@INAITEC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0054fd81-0854-48b4-b769-b2e6c4321a18', 0, 1, 1, 1, NULL, 0),
(1444, 'LEANDRO LIMA', 'LEANDRO@CEPUNET.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '98a68d45-12ed-48e0-9a3e-59b614b2f3d6', 0, 1, 1, 1, NULL, 0),
(1445, 'ADRIANO GASPAR', 'ADRIANOGASPAR@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2cbb18da-61b2-4209-b25b-fe21e31c4932', 0, 1, 1, 1, NULL, 0),
(1446, 'MAICO.MACHADO@HOTMAIL.COM', 'MAICO.MACHADO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '12091604-6c80-4f56-a814-338554c33b39', 0, 1, 1, 1, NULL, 0),
(1447, 'PALOMA_FAIRY@HOTMAIL.COM', 'PALOMA_FAIRY@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd3f8fc04-5690-494c-a656-e3209ecea629', 0, 1, 1, 1, NULL, 0),
(1448, 'ALF@CCS.UFSC.BR', 'ALF@CCS.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c26d7507-cf4d-47c3-bcf2-1b943c003c79', 0, 1, 1, 1, NULL, 0),
(1449, 'GOMORITZ@CSE.UFSC.BR', 'GOMORITZ@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7596432e-44f2-4d95-a2b5-19323d97fa91', 0, 1, 1, 1, NULL, 0),
(1450, 'ALEX_PAMICO16@HOTMAIL.COM', 'ALEX_PAMICO16@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c18a44c9-1c8e-43b8-8ef2-26431b465a35', 0, 1, 1, 1, NULL, 0),
(1451, 'DR.DIOGENES@ANESTEX.COM.BR', 'DR.DIOGENES@ANESTEX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a293a46-14cd-41d3-a2d6-6fc29ca9b099', 0, 1, 1, 1, NULL, 0),
(1452, 'GIANCARLO.SANTOS@REZULTO.COM.BR', 'GIANCARLO.SANTOS@REZULTO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2e36d174-a085-4242-92cb-15459f8e78ee', 0, 1, 1, 1, NULL, 0),
(1453, 'PEDRO LAUDELINO MORETTO', 'LORDPRIMATA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '135a49d3-8ff6-462d-baa7-71e9aa017626', 0, 1, 1, 1, NULL, 0),
(1454, 'FELIPEW@CONTEXTODIGITAL.COM.BR', 'FELIPEW@CONTEXTODIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8046b85a-9c4e-4607-be78-f188349b6506', 0, 1, 1, 1, NULL, 0),
(1455, 'CLAUDIA SCUDELARI MACEDO', 'CLAUDIA.SCUDELARI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '68fe2fc6-7860-46cd-a1c7-a274a6cfc98a', 0, 1, 1, 1, 437, 0),
(1456, 'REPRESENTANTE DISCENTE DO EGC', 'REP.DISCENTE@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '252f709c-3455-467e-ba90-f6528579e50f', 0, 1, 1, 1, NULL, 0),
(1457, 'RHBRASIL@ARCTOUCH.COM.BR', 'RHBRASIL@ARCTOUCH.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '99762668-c612-4e51-9ea1-9616d59167f0', 0, 1, 1, 1, NULL, 0),
(1458, 'MARCIÉLI', 'MARCIELI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '02535e38-f47e-4bad-91f6-92c2d8594dd9', 0, 1, 1, 1, 438, 0),
(1459, 'SÍLVIO CÉSAR NAZARIO', 'SILVIOBATERA@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '41c72b68-7b3b-4a27-979a-733a362ff7a3', 0, 1, 1, 1, NULL, 0),
(1460, 'JÚLIO CÉSAR LEAL JÚNIOR', 'JULIO@SQE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f7f7552c-eecf-47dc-a921-d216bebeb377', 0, 1, 1, 1, NULL, 0),
(1461, 'PEDRO HENRIQUE (GMAIL)', 'PEDRO.HENRIQUE1@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '73e977d3-0765-4251-9b81-c068f6684e6d', 0, 1, 1, 1, 439, 0),
(1462, 'KARLA SIMAS', 'KAKACINE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dd47f82e-71ab-47a7-b049-8794b7f8c1d3', 0, 1, 1, 1, 440, 0),
(1463, 'JEAN MALAQUIAS', 'BURGUEXX@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '53354259-7405-473a-bced-36f275d7533b', 0, 1, 1, 1, 441, 0),
(1464, 'SIMORETTO@HOTMAIL.COM', 'SIMORETTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '93fcbe2e-fdb1-46f4-bb4e-8a9ee8fa1b9d', 0, 1, 1, 1, NULL, 0),
(1465, 'SAULO VENÂNCIO', 'SAULO.VENANCIO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '09962580-229e-4d11-bb78-75811f0d2886', 0, 1, 1, 1, 442, 0),
(1466, 'MARCELOBRIGATO@GMAIL.COM', 'MARCELOBRIGATO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '09754ae1-634d-47e8-bd5d-9ebd96c73716', 0, 1, 1, 1, NULL, 0),
(1467, 'CAMILA.BECKHAUSER@SC.SENAI.BR', 'CAMILA.BECKHAUSER@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '54ddde52-3556-4df8-9b98-c899e4d258a9', 0, 1, 1, 1, NULL, 0),
(1468, 'CARLOS ALBERTO-SOUZA-COITINHO', 'SOUZACOITINHO@IBEST.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0d1dd656-9cde-4696-9e4d-7e2f326796b9', 0, 1, 1, 1, 443, 0),
(1469, 'SÍLVIA QUEVEDO', 'SILVIAPROJETOS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7481abeb-c2ef-490b-be9d-ebe9e1dcf929', 0, 1, 1, 1, NULL, 0),
(1470, 'LEILA.COSTA@DIGITRO.COM.BR', 'LEILA.COSTA@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9cb812ee-2a09-4df6-93f0-74be8f3b7060', 0, 1, 1, 1, NULL, 0),
(1471, 'VICTORBRASIL9@HOTMAIL.COM', 'VICTORBRASIL9@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '84e09f92-0b60-4917-bbd4-897e682f23d4', 0, 1, 1, 1, NULL, 0),
(1472, 'CARLOS.SOUSA.PINTO@GMAIL.COM', 'CARLOS.SOUSA.PINTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9b03ddf3-df91-45c8-b3b4-98687e2fc3c6', 0, 1, 1, 1, NULL, 0),
(1473, 'LFGAMBA@HOTMAIL.COM', 'LFGAMBA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c0749dfa-7693-4954-8c25-644865ce718b', 0, 1, 1, 1, NULL, 0),
(1474, 'LEONARDO OLIVEIRA', 'NOREPLY@CHAMADADETRABALHOS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b464a7b-4942-4a35-a0a2-4acd377ec3cb', 0, 1, 1, 1, NULL, 0),
(1475, 'ALEXANDRE P. PINHO', 'APINHO@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c7cfa933-1d0e-4b90-b12c-851548a831be', 0, 1, 1, 1, NULL, 0),
(1476, 'RODRIGOBASEGGIO@HOTMAIL.COM', 'RODRIGOBASEGGIO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a90aeffe-6e1e-4891-8f84-8c102332bb9c', 0, 1, 1, 1, NULL, 0),
(1477, 'RICARDO HAUS GUEMBAROVSKI', 'RICARDOHAUS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0f91c910-3b72-4c21-b9d0-df401b649b07', 0, 1, 1, 1, 444, 0),
(1478, 'SISTEMAS-DE-INFORMACAO-SENAI-SJ@GOOGLEGROUPS.COM', 'SISTEMAS-DE-INFORMACAO-SENAI-SJ@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd890617e-ae9f-4b99-9832-2b6246fcf43e', 0, 1, 1, 1, NULL, 0),
(1479, 'ROSANGELA@LEPTEN.UFSC.BR', 'ROSANGELA@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8810ad21-d052-44ba-b9e1-c85b7a1f55e6', 0, 1, 1, 1, NULL, 0),
(1480, 'LEANDRO LINHARES', 'LEANDRUUHH_16@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '21c25a83-c929-4cb0-8cf6-9dd4eb2ef638', 0, 1, 1, 1, NULL, 0),
(1481, 'DANIEL@HLSYS.COM', 'DANIEL@HLSYS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4ddc0209-0708-4ad7-aac3-bc37133dbe77', 0, 1, 1, 1, NULL, 0),
(1482, 'VICURCIO@VIA-RS.NET', 'VICURCIO@VIA-RS.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e20c01d3-7745-471c-ba8f-762d4365f725', 0, 1, 1, 1, NULL, 0),
(1483, 'PINHEIRO.DAVID@YAHOO.COM.BR', 'PINHEIRO.DAVID@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '88253df1-80f4-41f3-ad87-c8a982deeeb7', 0, 1, 1, 1, NULL, 0),
(1484, 'JACKSON VIEIRA', 'JACKSONSILVAVIEIRA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e1ffb2a2-af09-4816-825e-c6238e320b85', 0, 1, 1, 1, 445, 0),
(1485, 'MICHELLE COLIN', 'MICHELLE_COLIN1@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd72b6da3-6488-4c85-8649-699b861f8ab4', 0, 1, 1, 1, NULL, 0),
(1486, 'ENGENHEIROMARQUES@HOTMAIL.COM', 'ENGENHEIROMARQUES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '32c07fda-7048-4f61-a12e-cc9ee509ec02', 0, 1, 1, 1, NULL, 0),
(1487, 'FLAVIO SCHOENELL', 'FLAVIO.SCHOENELL@INTELBRAS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4951cedc-1962-4dea-a1ce-b5ad9af2c358', 0, 1, 1, 1, NULL, 0),
(1488, 'ALFA CONSULTORIA - ALFREDO MAURICIO NETO', 'ALFREDO@ALFACONSULTORIA1.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '32d03960-e1d6-420e-9d1d-5a17ed311cd9', 0, 1, 1, 1, 446, 0),
(1489, 'MICHELE ANDRÉIA BORGES', 'MICHELEANDBORGES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd1d8e600-27b9-4c6a-8f03-3c20c0ef1832', 0, 1, 1, 1, 447, 0),
(1490, 'SECRETARIA@EGC.UFSC.BR', 'SECRETARIA@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '485c8350-9762-43d3-9716-015491ef4291', 0, 1, 1, 1, NULL, 0),
(1491, 'EROS COMUNELLO', 'EROS.COM@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'de0f1e5c-3a73-41ff-b638-83c770fa8b72', 0, 1, 1, 1, NULL, 0),
(1492, 'CTOLFO@GMAIL.COM', 'CTOLFO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1ecabe58-53f3-40e9-b70d-085155cc9598', 0, 1, 1, 1, NULL, 0),
(1493, 'KAMIL GIGLIO', 'KAMILGIGLIO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6d4ea4a5-8696-472c-813f-fbf7a0d65f7e', 0, 1, 1, 1, NULL, 0),
(1494, 'CASSIANO ZEFERINO CARVALHO NETO', 'DG@DIGITAL-EDUCATION.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '463b6134-0ca6-4479-a9c2-bb0ae209f73c', 0, 1, 1, 1, NULL, 0),
(1495, 'THA.SQ@HOTMAIL.COM', 'THA.SQ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8c2758c2-37ca-43d4-ba52-c2301899b566', 0, 1, 1, 1, NULL, 0),
(1496, 'SUELI - CAESC', 'SUELI@CAESC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8a09e62f-4075-4481-bca0-5ed0f3f5e605', 0, 1, 1, 1, NULL, 0),
(1497, 'AS-A-ROBOT@APPSPOT.COM', 'AS-A-ROBOT@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '71f5929f-beca-49eb-b103-1dc44ae554ba', 0, 1, 1, 1, NULL, 0),
(1498, 'ARTHUR SANDERS', 'APSANDERS2@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '62c03800-23a9-4f51-995b-6cb60043e990', 0, 1, 1, 1, 448, 0),
(1499, 'GRAPH-WAVE@APPSPOT.COM', 'GRAPH-WAVE@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4c9e96ef-ba45-4717-b2db-aa8a426ab93d', 0, 1, 1, 1, NULL, 0),
(1500, 'JONATHAS MELLO', 'JONATHAS@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '42e1fadc-fdfa-4aec-bc8a-11e52396d0e3', 0, 1, 1, 1, 449, 0),
(1501, 'JONATHAS MELLO', 'JONATHASMELLO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bf3a2f23-497b-4e5e-a118-82c693e5dd50', 0, 1, 1, 1, 450, 0),
(1502, 'MARGARETE KLEIS', 'MARGARETE@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c3d024c1-f7e5-4aea-b04d-8f289fdc261b', 0, 1, 1, 1, NULL, 0),
(1503, 'MURILO CESCONETTO', 'MCESCONETTO@COMMCORP.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6c6963e9-539e-4624-a13f-319c1da8f241', 0, 1, 1, 1, NULL, 0),
(1504, 'LEONARDO DE OLIVEIRA', 'LEONARDO.OLIVEIRA@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9cdc0594-73e1-4986-a57d-c1fa108a9e5f', 0, 1, 1, 1, NULL, 0),
(1505, 'DOUGLAS, BRUNA E ISAQUE :)', 'DOUGLASTUIUIU@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '826f2548-e467-4372-8d98-248cf8a937e4', 0, 1, 1, 1, 451, 0),
(1506, 'VANESSA TESTONI', 'VAANESSATESTONI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '84482406-b889-4f0f-a30e-8be20775c360', 0, 1, 1, 1, NULL, 0),
(1507, 'LUIZ.CARLSON@IFSC.EDU.BR', 'LUIZ.CARLSON@IFSC.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3e5915c6-7771-4882-aab5-a15a859af600', 0, 1, 1, 1, NULL, 0),
(1508, 'TAISLRAMOS@GMAIL.COM', 'TAISLRAMOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '620a6187-4ff3-43b0-82af-6d65d3856aba', 0, 1, 1, 1, NULL, 0),
(1509, 'TRICKY-BOT@APPSPOT.COM', 'TRICKY-BOT@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c85c2ab-a956-450f-8c9d-7edeadf639c7', 0, 1, 1, 1, NULL, 0),
(1510, 'JGERPEN@HOTMAIL.COM', 'JGERPEN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1b5bdf94-daae-4650-bcca-05be344f351f', 0, 1, 1, 1, NULL, 0),
(1511, 'PROGRAMACAOSENAI@GRUPOS.COM.BR', 'PROGRAMACAOSENAI@GRUPOS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '167b2e60-cf19-4eab-972c-a07c22ea10f7', 0, 1, 1, 1, NULL, 0),
(1512, 'EDISMAFRA@GMAIL.COM', 'EDISMAFRA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1539b84e-35c4-4544-a533-63bf31d55e4e', 0, 1, 1, 1, 452, 0),
(1513, 'DANI HINCKEL', 'DANI.017@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fccfbb94-8c14-4340-91cc-1b6813855e95', 0, 1, 1, 1, NULL, 0),
(1514, 'EWERSONH@GMAIL.COM', 'EWERSONH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0e7f65c0-501d-48c1-8240-3b04adaf7ff9', 0, 1, 1, 1, NULL, 0),
(1515, 'FABRICIO@CETIC.UFSC.BR', 'FABRICIO@CETIC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '498cf97f-cd43-422f-ab2d-0fdba5cf5a64', 0, 1, 1, 1, NULL, 0),
(1516, 'AMANDA RICKES', 'AMANDA.RICKES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '23b62397-9bcf-47f1-a25a-e83e82aa7f32', 0, 1, 1, 1, NULL, 0),
(1517, 'AMANDA RICKES', 'AMANDARICKES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '177e612b-7e7e-4d8e-834f-e5018452c4bb', 0, 1, 1, 1, NULL, 0),
(1518, 'DIOGO MACHADO', 'DIOGOTRNT@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '16049cfa-f1f1-4cd8-a9eb-0c1cfb9c5f72', 0, 1, 1, 1, 453, 0),
(1519, 'LUCIA.C.NEVES@UOL.COM.BR', 'LUCIA.C.NEVES@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9153472c-5afd-47e6-b6e4-29b2f5e80b1e', 0, 1, 1, 1, NULL, 0),
(1520, 'CCS1201@GMAIL.COM', 'CCS1201@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '27f28b1b-50d9-4133-a476-1b678c918346', 0, 1, 1, 1, NULL, 0),
(1521, 'THIAGO SCHNEIDER (TCHAKA)', 'THIAGO.SFL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3f29dd9f-7d7a-4ace-8e47-256cea8b2a94', 0, 1, 1, 1, 454, 0),
(1522, 'LUISINHUHH@GMAIL.COM', 'LUISINHUHH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3813ab12-e893-4061-a464-07d5713077eb', 0, 1, 1, 1, NULL, 0),
(1523, 'THOMAS RANZI', 'TRANZI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c97ac57f-d07e-4901-9f58-6706a2970863', 0, 1, 1, 1, NULL, 0),
(1524, 'MÁRIO DE NORONHA NETO', 'NORONHA@IFSC.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '42ac601c-f38f-4763-8f95-897ed17ad890', 0, 1, 1, 1, 455, 0),
(1525, 'MÁRIO DE NORONHA NETO', 'M.NORONHA.N@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a17cf0db-9dc7-46e4-a68f-e7cce714ff1c', 0, 1, 1, 1, 456, 0),
(1526, 'MÁRIO DE NORONHA NETO', 'MNORONHAN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ef081249-664a-443b-9ff7-9de2c13d9cc4', 0, 1, 1, 1, 457, 0),
(1527, 'JGERPEN@YAHOO.COM.BR', 'JGERPEN@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1a3f8f5c-1fc0-4454-b2d4-1ca20f50b547', 0, 1, 1, 1, NULL, 0),
(1528, 'TARCISIO VANZIN', 'TVANZIN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '95d78b6b-7574-4a8c-baf6-ce91ce793071', 0, 1, 1, 1, NULL, 0),
(1529, '[PROGRAMACAO]', 'PROGRAMACAO@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'adc54332-cdfd-4fa5-a14c-50c728abf60f', 0, 1, 1, 1, NULL, 0),
(1530, 'ACM MEMBER HELP UTILITY', 'ACMHELP@HQ.ACM.ORG', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2c61c448-128c-4ae4-9b8d-0c5bf4abcfb4', 0, 1, 1, 1, NULL, 0),
(1531, 'DIEGO PINTO', 'DIEGOP@SULCATARINENSE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6116c0a5-3105-435f-a74a-6607fe4689e3', 0, 1, 1, 1, NULL, 0),
(1532, 'GUSTAVO HOFFMANN', 'GUS16SURF@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '06c4fe12-1f05-4e19-a5e0-9188bddeaf1c', 0, 1, 1, 1, NULL, 0),
(1533, 'KLEBER', 'KLEBER@FISIOGAMES.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c7aa76f9-923e-4010-9674-6b32e26b33ce', 0, 1, 1, 1, NULL, 0),
(1534, 'RAFAEL MORÉ', 'RAFAEL@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '64eeadc8-fed6-4647-b42d-49c468b83ac2', 0, 1, 1, 1, 458, 0),
(1535, 'RAFAEL MORÉ', 'RAFAMORE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bd0955ed-574e-4fd9-88ee-d08da63e2126', 0, 1, 1, 1, 459, 0),
(1536, 'MARIANAZANIVAN@GMAIL.COM', 'MARIANAZANIVAN@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd507dde6-9f35-4085-9866-701cd5b2c4e5', 0, 1, 1, 1, NULL, 0),
(1537, 'JANAINA', 'JANAINAR.CP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7f0958a6-1677-49d2-94c3-625e40f6d79c', 0, 1, 1, 1, 460, 0),
(1538, 'RENATAMSCOSTA@HOTMAIL.COM', 'RENATAMSCOSTA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '80cefde9-6773-4ef8-a777-d1ba8cb77d47', 0, 1, 1, 1, NULL, 0),
(1539, 'ALEMAO', 'ALE', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '88b828fd-03eb-4411-bfb0-052bd1c6a5b8', 0, 1, 1, 1, NULL, 0),
(1540, 'CAROLINA@LEPTEN.UFSC.BR', 'CAROLINA@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '70f7d2e8-9058-4ab5-97ac-982798dd6bf2', 0, 1, 1, 1, NULL, 0),
(1541, 'COMPUTAÇÃO', 'COMPUTACAO@IES.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5da0a965-150a-48fb-b3bd-9d59f909c2c4', 0, 1, 1, 1, NULL, 0),
(1542, 'CHARLES_DA_SILVA@DELL.COM', 'CHARLES_DA_SILVA@DELL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '98d98f65-2550-43a8-aa07-8978e8076982', 0, 1, 1, 1, NULL, 0),
(1543, 'OTAVIO@EXTRADIGITAL.COM.BR', 'OTAVIO@EXTRADIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5b34d270-6414-436f-8e3f-b76201bc35bf', 0, 1, 1, 1, NULL, 0),
(1544, 'ONE-360@APPSPOT.COM', 'ONE-360@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a2c73af7-9a00-42b3-817c-be7bb7f22edf', 0, 1, 1, 1, NULL, 0),
(1545, 'WESLEY TIAGO ZAPELLINI', 'WESLEYTZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '560b672d-c952-43d3-8576-d04f647e28a8', 0, 1, 1, 1, NULL, 0),
(1546, 'PGCIN - PROGRAMA DE PÓS-GRADUAÇÃO EM CIÊNCIA DA INFORMAÇÃO', 'PGCIN@CIN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'be2a4fa7-8a41-4bf1-a2ef-1c67b82400f1', 0, 1, 1, 1, NULL, 0),
(1547, 'HALLACK@MODEL.IAG.USP.BR', 'HALLACK@MODEL.IAG.USP.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4d9bc9ee-e9fd-4a82-91db-00ced715f363', 0, 1, 1, 1, NULL, 0),
(1548, 'HARRYSSON@UOL.COM.BR', 'HARRYSSON@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '51725727-1eae-43d9-9b4c-a5736dd9a528', 0, 1, 1, 1, NULL, 0),
(1549, 'SILVANA ORTIZ', 'SILVANA@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '62cca910-3ec3-4bf6-807d-315b57f45299', 0, 1, 1, 1, NULL, 0),
(1550, 'ROSANE DEOCLESIA ALÉSSIO DALTOÉ', 'RDA@UNESC.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd3a7e5d1-e078-4749-95d4-66b2b76ee45f', 0, 1, 1, 1, NULL, 0),
(1551, 'MARIO.MOTTA@RBSTV.COM.BR', 'MARIO.MOTTA@RBSTV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cd5bf113-2713-40d6-9675-304106fdddba', 0, 1, 1, 1, NULL, 0),
(1552, 'LAUDELINOMORETTO', 'LAUDELINOMORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7e216b27-086a-4cab-87fc-cbecb19988f8', 0, 1, 1, 1, 461, 0),
(1553, 'LU DOC', 'LUVCOSTA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '28488cf5-e854-4b42-a09c-adf94d1a02a5', 0, 1, 1, 1, 462, 0),
(1554, 'LUIZANTONIO@HOBECO.NET', 'LUIZANTONIO@HOBECO.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5353b880-28f6-4840-a29d-1e72ed97d326', 0, 1, 1, 1, NULL, 0),
(1555, 'COMPRADOR INTERESSADO', 'VCIGNORANTE@BURRO.IT', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '58e37309-8f9f-49eb-a2ad-40907b803ef5', 0, 1, 1, 1, NULL, 0),
(1556, 'ANDRE SCHURHAUS', 'ANDRESCHURHAUS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cc710ada-97aa-4832-aab4-92b28879add1', 0, 1, 1, 1, NULL, 0),
(1557, 'EDSON MACHADO', 'EDMACHADOPR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7009f5a3-cbe4-400a-ac7f-f71120f403fa', 0, 1, 1, 1, NULL, 0),
(1558, 'GABRIEL DIOGO DA SILVA', 'BIEL.DIOGO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9067a241-1962-41fe-b73d-b3bd2d005153', 0, 1, 1, 1, NULL, 0),
(1559, 'RAFAEL EIDT', 'ORIENTACAO.INFORM@CEPUNET.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fc848642-e919-497a-93bb-5278fd4fde53', 0, 1, 1, 1, NULL, 0),
(1560, 'LUCASMR123@HOTMAIL.COM', 'LUCASMR123@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8acba18b-0a95-42a4-95bd-5c6142030e72', 0, 1, 1, 1, NULL, 0),
(1561, 'MÔNICA LEIRIA', 'AUXILIARDP@IES.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6f4f9e3f-1aa6-46a4-b0de-3550ce44b8ac', 0, 1, 1, 1, NULL, 0),
(1562, 'JAIME HULLER', 'BCJUNINHO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '64a1a321-7e88-46ad-ab47-d8fca2b0115b', 0, 1, 1, 1, NULL, 0),
(1563, 'EBERSON SANTOS', 'EBERSONSANTOS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ec83a681-9b10-47c3-9bc3-bf7f0574fec4', 0, 1, 1, 1, 463, 0),
(1564, 'MIMIMORETTO@GMAIL.COM', 'MIMIMORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '218853e5-8cdc-42b5-a0c4-2e3d5f61c9e3', 0, 1, 1, 1, NULL, 0),
(1565, 'MARCIA@TQS-BR.COM', 'MARCIA@TQS-BR.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '951498c8-c891-4154-b521-daf9101df25b', 0, 1, 1, 1, NULL, 0),
(1566, 'ANABOAVISTA@GMAIL.COM', 'ANABOAVISTA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c9c542e7-7b78-41b2-b99b-32354921332d', 0, 1, 1, 1, NULL, 0),
(1567, 'SIMONE REGINA DIAS', 'SIDIAS1@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '37768578-fcc0-4c0a-a94b-4c622ab1ca13', 0, 1, 1, 1, NULL, 0),
(1568, 'BARBARA VIEIRA', 'BARBARA@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '03809c71-a98a-41fb-92b6-304b44c17f40', 0, 1, 1, 1, NULL, 0),
(1569, 'MARINA@EGC.UFSC.BR', 'MARINA@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd200bec7-1c8e-4ab3-8a43-703939d2eb95', 0, 1, 1, 1, NULL, 0),
(1570, 'PAINEL CIENTÍFICO EGC', 'PAINELCIENTIFICOEGC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c87ef4e0-aaf1-4bf3-b430-ed19a04680cb', 0, 1, 1, 1, NULL, 0),
(1571, 'DATACOM - LEONARDO MEDEIROS MARTINS', 'MEDEIROS@DATACOM.IND.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8fd15e31-90d4-48cd-8624-e8706d4a8b77', 0, 1, 1, 1, NULL, 0),
(1572, 'TIAGO@VIAMIDIA.COM', 'TIAGO@VIAMIDIA.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'db4f0084-cb62-4e45-b782-e7829687c621', 0, 1, 1, 1, NULL, 0),
(1573, 'WEBDESIGN-SENAI-SJ@GOOGLEGROUPS.COM', 'WEBDESIGN-SENAI-SJ@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ca17a695-315f-40bf-aa3f-789baa906ae2', 0, 1, 1, 1, NULL, 0),
(1574, 'ALVES .', 'ALVES-TSSC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '505f1a9c-0142-46c3-aee3-c444ed6f403e', 0, 1, 1, 1, NULL, 0),
(1575, 'ELIZANDRA MACHADO', 'ELIZANDRA_MACHADO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '78bff44a-30de-4bf4-9708-c0e1c526fcd9', 0, 1, 1, 1, NULL, 0),
(1576, 'MADJARIZZO@HOTMAIL.COM', 'MADJARIZZO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '71c42178-1b24-42fb-8159-035d6d18a6c1', 0, 1, 1, 1, NULL, 0),
(1577, 'CAMILLA FETTER', 'CAMILLAFETTER@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3a378301-398f-4e6b-9c21-9bbb810d3efa', 0, 1, 1, 1, NULL, 0),
(1578, 'WIENEKE NAU KROON', 'WINIKITCHA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd40bcd67-12d8-4691-93cc-ce53366acfe2', 0, 1, 1, 1, 464, 0),
(1579, 'MARCOS CADAVAL DOS SANTOS', 'MARCOCADAVAL@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '70ceebab-7e73-4c8b-8c1b-08485754a2bb', 0, 1, 1, 1, NULL, 0),
(1580, 'GPAULI@SC.SENAI.BR', 'GPAULI@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9948f150-ccfa-416f-88f9-5f1159394547', 0, 1, 1, 1, NULL, 0),
(1581, 'KAIODUARTE@HOTMAIL.COM', 'KAIODUARTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e2992159-dd14-4cfa-8849-ea73cbc0c8a7', 0, 1, 1, 1, NULL, 0),
(1582, 'ВЯ€ИØ ¢ØЯЯ€ ЯÏ¢ЋǺRЯТƵ', 'BRENO-NANICO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '15637da9-49a4-4632-bf5d-05598837e3b4', 0, 1, 1, 1, NULL, 0),
(1583, 'SORAIA@NDI.UFSC.BR', 'SORAIA@NDI.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '71f60985-0fb7-46b6-80d1-aa4f57610d73', 0, 1, 1, 1, NULL, 0),
(1584, 'ANDRÉ LUIZ', 'ANDRELO89@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ad33b4c6-671b-435c-8487-7b35d5513fd5', 0, 1, 1, 1, NULL, 0),
(1585, 'FERNANDO JORGE MOTA', 'F.J.MOTA13@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8055b8f0-5275-4cb9-bb8d-60e0ce355dd7', 0, 1, 1, 1, 465, 0),
(1586, 'ELUARDSOUZA@HOTMAIL.COM', 'ELUARDSOUZA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1d62356d-7200-4206-b28e-f6f8c61de00d', 0, 1, 1, 1, NULL, 0),
(1587, 'CAROLINE MONTEIRO;', 'CAROOL.MSN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '260db59e-45d8-4183-8bcc-98469c92bf2d', 0, 1, 1, 1, NULL, 0),
(1588, 'JEAN SILVA MALAQUIAS', 'JEAN.MALAQUIAS@WEDOTECHNOLOGIES.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '46b574c6-8d13-4dd1-aede-b2a2ea4c88f0', 0, 1, 1, 1, NULL, 0),
(1589, 'MIMORETTOMORETTO@GMAIL.COM', 'MIMORETTOMORETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2f86b545-76a8-4f08-bae5-8bd667de5a06', 0, 1, 1, 1, NULL, 0),
(1590, 'ANDRE F. GOULART', 'ANDRE@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '99115ce4-b633-4ebc-a511-d406d171e527', 0, 1, 1, 1, NULL, 0),
(1591, 'BAYAVASQUES23@HOTMAIL.COM', 'BAYAVASQUES23@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '667cfa08-5f19-4e04-9e0b-92ac5ac2b66f', 0, 1, 1, 1, NULL, 0),
(1592, 'THA_SQ@HOTMAIL.COM', 'THA_SQ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f4de9ab2-4dc4-4152-be53-ba58758c3b46', 0, 1, 1, 1, NULL, 0),
(1593, 'TECINFO2011@GMAIL.COM', 'TECINFO2011@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c4c4f012-d4cb-454e-ba3f-b87537b69207', 0, 1, 1, 1, NULL, 0),
(1594, 'MURILO LAGHI', 'MURILO.LAGHI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '59b974fc-3188-4baa-b6a0-d1e2e8c40230', 0, 1, 1, 1, 466, 0),
(1595, 'MARIONETTO@HOTMAIL.COM', 'MARIONETTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '69b00c88-695c-4e35-a78b-240a569f3cca', 0, 1, 1, 1, NULL, 0),
(1596, 'MANUBETTONI@HOTMAIL.COM', 'MANUBETTONI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aac1b18e-7fff-4f49-a0f5-5bf7f0828bbd', 0, 1, 1, 1, NULL, 0),
(1597, 'MARCOSR@SC.SEBRAE.COM.BR', 'MARCOSR@SC.SEBRAE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1cd35416-ca45-4bca-9869-b819ec4032a3', 0, 1, 1, 1, NULL, 0),
(1598, 'HENRIQUE.OTTE@GMAIL.COM', 'HENRIQUE.OTTE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a3a08d3f-f697-404b-b074-3b81890f8e3b', 0, 1, 1, 1, 467, 0),
(1600, 'RACHEL@CPS.SOFTEX.BR', 'RACHEL@CPS.SOFTEX.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b2d50aed-1d13-4c70-8de3-12a2db3a4603', 0, 1, 1, 1, NULL, 0),
(1601, 'AMANAJE@GMAIL.COM', 'AMANAJE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2c7a8449-d6cd-4a3e-83e2-e31240ea4f77', 0, 1, 1, 1, NULL, 0),
(1602, 'CARREGARI.LUCAS@GMAIL.COM', 'CARREGARI.LUCAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee4af214-7bce-4905-a708-f675d1a3370c', 0, 1, 1, 1, NULL, 0),
(1603, 'LEONARDO@JAVAMAGAZINE.COM.BR', 'LEONARDO@JAVAMAGAZINE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '504a1516-9a96-44de-9321-37e89ba9ff4b', 0, 1, 1, 1, NULL, 0),
(1604, 'DALMAU@CSE.UFSC.BR', 'DALMAU@CSE.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c7b14f10-5a96-46ce-add2-a7b34bfd1d5e', 0, 1, 1, 1, NULL, 0),
(1605, 'THIAGO_BORN@HOTMAIL.COM', 'THIAGO_BORN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '006a6127-df92-4f26-80df-f4f526017b66', 0, 1, 1, 1, NULL, 0),
(1606, 'AUGUSTO FERREIRA', 'AUGUSTO@LABTUCAL.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '50ad74d6-80e8-4858-824f-25e930e3d978', 0, 1, 1, 1, NULL, 0),
(1607, 'CRISNORTEDAILHA@HOTMAIL.COM', 'CRISNORTEDAILHA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7e4ea8db-bd25-42e2-83fb-23dfe4bfbf7e', 0, 1, 1, 1, NULL, 0),
(1608, 'ENGENHARIA-SOFTWARE-SENAI@GOOGLEGROUPS.COM', 'ENGENHARIA-SOFTWARE-SENAI@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ee84273a-e3d9-4f5b-8dd3-0fd936f66bb6', 0, 1, 1, 1, NULL, 0),
(1609, 'FALECONOSCO@OI.COM.BR', 'FALECONOSCO@OI.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e06f20dc-7d9b-4397-8643-8f79b57eb19a', 0, 1, 1, 1, NULL, 0),
(1610, 'LISANDRA MAURINA DA SILVA SCHMITZ', 'LISANDRA@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b7d385a9-e9e3-483d-a6f6-1a6b15afe38c', 0, 1, 1, 1, NULL, 0),
(1611, 'MASNINA@IBEST.COM.BR', 'MASNINA@IBEST.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1c234ff8-b31e-4d83-a6ef-dc32883c0487', 0, 1, 1, 1, NULL, 0),
(1612, 'DJONATANPEREIRA@HOTMAIL.COM', 'DJONATANPEREIRA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '166ddf04-f0af-4557-9d24-518eefb88578', 0, 1, 1, 1, NULL, 0),
(1613, 'DESTINOS INDUTORES DO DESENVOLVIMENTO TURÍSTICO REGIONAL', '65DESTINOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3359fa05-30bc-47b6-a14b-406f796b725c', 0, 1, 1, 1, 469, 0),
(1614, 'FABRICIO KALBUSCH', 'FABRICIOKALBUSCH@IG.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '367a38e3-f7c1-4ba1-962d-d70219192c07', 0, 1, 1, 1, NULL, 0),
(1615, 'CHIPMASTER.LEANDRO@GMAIL.COM', 'CHIPMASTER.LEANDRO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f0178e1f-ccc6-4b79-924c-fac9ac632153', 0, 1, 1, 1, 470, 0),
(1616, 'ANDERSON4321@HOTMAIL.COM', 'ANDERSON4321@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '18e8fb3e-bf26-40cb-af85-03b6baf0fc45', 0, 1, 1, 1, NULL, 0),
(1617, 'CRISTIAN SANTIANI', 'CRISTIANSANTIANI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7419c517-8166-4f7e-a757-f824d70cd7a1', 0, 1, 1, 1, NULL, 0),
(1618, 'SANTOSPAS@HOTMAIL.COM', 'SANTOSPAS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0184de6e-c537-48dc-b31e-d9a05fb0716d', 0, 1, 1, 1, NULL, 0),
(1619, 'COMPUTACAO', 'COORDENACAOCOMPUTACAO@IES.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a1b4b60e-564b-41ec-bf90-229c84ce9fa9', 0, 1, 1, 1, NULL, 0),
(1620, 'IFSCTIC@GOOGLEGROUPS.COM', 'IFSCTIC@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '34436305-a9ff-4fcc-a70b-daa8fa20355f', 0, 1, 1, 1, NULL, 0),
(1621, 'NERI@EGC.UFSC.BR', 'NERI@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '45673cd4-0baa-42ed-a119-0aa445463390', 0, 1, 1, 1, NULL, 0),
(1622, 'PAULOSELIG@GMAIL.COM', 'PAULOSELIG@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2e8c9be4-63aa-489b-88c0-badd4966d17c', 0, 1, 1, 1, NULL, 0),
(1623, 'ZIALEITE@YAHOO.COM.BR', 'ZIALEITE@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4ae11db9-3b4c-48c7-b79a-13709a523b1b', 0, 1, 1, 1, NULL, 0),
(1624, 'CESARCDM@HOTMAIL.COM', 'CESARCDM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '98a883da-4d63-423e-abdf-bfc6eace298e', 0, 1, 1, 1, NULL, 0),
(1625, 'DOUGLAS KAMINSKI', 'KAMINSKI@FACULDADESENERGIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b5a737a9-184e-4af0-a1f9-2f3d14b94df2', 0, 1, 1, 1, NULL, 0),
(1626, 'PATRÍCIA BATTISTI', 'PATRICIA@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ab26fd7e-ffec-4751-864b-601ac859a394', 0, 1, 1, 1, NULL, 0),
(1627, 'TESES@BU.UFSC.BR', 'TESES@BU.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1dc332c4-460d-4b17-b315-674454cc59b8', 0, 1, 1, 1, NULL, 0),
(1628, 'JULIAN_SURF_@HOTMAIL.COM', 'JULIAN_SURF_@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '819b5b2c-86dd-49d3-99d4-39529bc824dd', 0, 1, 1, 1, NULL, 0),
(1629, 'ANDREZA DUARTE', 'ANDREZA.FLORIPA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2cee2247-df68-4ad3-a30f-9c7affda3d9c', 0, 1, 1, 1, 471, 0),
(1630, 'ROSELBA_COSTA@HOTMAIL.COM', 'ROSELBA_COSTA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eda7bf1c-89be-455e-b923-c4471b715fb5', 0, 1, 1, 1, NULL, 0),
(1631, 'GABRIEL KAUTZMANN', 'GABRIEL.KTZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1f51aa67-3f7e-4aa7-a58b-531f70d4a770', 0, 1, 1, 1, NULL, 0),
(1632, 'GABRIEL KAUTZMANN', 'GABRIELKTZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f1aab515-bf7b-4256-8b27-feae69d4db8d', 0, 1, 1, 1, NULL, 0),
(1633, 'LCBHREMER@GMAIL.COM', 'LCBHREMER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ba560c70-7739-41dd-a580-5551fd145151', 0, 1, 1, 1, NULL, 0),
(1634, 'MAH.ASSUNCAO@HOTMAIL.COM', 'MAH.ASSUNCAO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a5a24674-cdf5-4be8-b8b4-abd31805d7fe', 0, 1, 1, 1, NULL, 0),
(1635, 'AMABLY HOFFMANN FERREIRA', 'AMABLYHOFF@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c5bdedb-6aa3-48b3-98f1-2310c80e2dea', 0, 1, 1, 1, NULL, 0),
(1636, 'ANDX_13@HOTMAIL.COM', 'ANDX_13@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '52d70058-53a8-4af5-88b7-1a4e5d0b4d42', 0, 1, 1, 1, NULL, 0),
(1637, 'DOUGLAAS.SIDNEI@GMAIL.COM', 'DOUGLAAS.SIDNEI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f83700cb-d17e-4f3e-a60b-b7f86dc994cf', 0, 1, 1, 1, NULL, 0),
(1638, 'MACHADO.VALMOR@GMAIL.COM', 'MACHADO.VALMOR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bd4ce467-1003-4a9c-bd2c-ccec10792551', 0, 1, 1, 1, NULL, 0),
(1639, 'MISLENE RICHARTZ', 'MIMIRICHARTZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0a522432-9164-4071-becb-27678b4f7727', 0, 1, 1, 1, NULL, 0);
INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(1640, 'EMERSON DEMETRIO PLÁCIDO', 'EMERSON@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '19a13c9b-c477-4d45-af19-d82cfe78adf1', 0, 1, 1, 1, NULL, 0),
(1641, 'MARCOACSENA@GMAIL.COM', 'MARCOACSENA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ed3e1a96-4f28-4b0d-9af5-cb5f81cfe30e', 0, 1, 1, 1, NULL, 0),
(1642, 'MARCIAMILANI@HOTMAIL.COM', 'MARCIAMILANI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b6f4f83b-f4ab-4096-8f2f-a1fb10eec273', 0, 1, 1, 1, NULL, 0),
(1643, 'TCC-SENAI-2009-A@GOOGLEGROUPS.COM', 'TCC-SENAI-2009-A@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0b07b0ea-db07-4e96-978e-833d0f9b5df0', 0, 1, 1, 1, NULL, 0),
(1644, 'TC.SENAI@SC.SENAI.BR', 'TC.SENAI@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f1a8e700-d818-47ac-bbbf-271e8bb85831', 0, 1, 1, 1, NULL, 0),
(1645, 'LDMFABIO@GMAIL.COM', 'LDMFABIO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2b1f90a6-0da8-48cf-a389-66400e73178e', 0, 1, 1, 1, NULL, 0),
(1647, 'PATRICK MACHADO', 'PAAMACHADO.93@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eb45f5f5-1ccc-49f7-896b-a7fd7a7a37f1', 0, 1, 1, 1, NULL, 0),
(1648, 'MAEL_JS@HOTMAIL.COM', 'MAEL_JS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5230f626-6fa9-41f6-b618-0f33861715f0', 0, 1, 1, 1, NULL, 0),
(1649, 'ALUNOS2009@LISTAS.EGC.UFSC.BR', 'ALUNOS2009@LISTAS.EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd35ccf28-e163-4295-8c5d-f38ce21530e2', 0, 1, 1, 1, NULL, 0),
(1650, 'RAFAEL BOROVIK', 'SM.BOROVIK@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e5f2ac83-1a64-48b3-856c-4eea7369c8d2', 0, 1, 1, 1, NULL, 0),
(1651, 'C. HENRIQUE', 'CMONTHEIR@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9cdfb801-4e86-4e46-b152-d2b253ce81a9', 0, 1, 1, 1, NULL, 0),
(1652, 'SIMONE RENGEL', 'SIMONERENGEL@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ecd1f0d8-6309-4741-9a5b-ffdd4c7a494c', 0, 1, 1, 1, NULL, 0),
(1653, 'WMP_47@HOTMAIL.COM', 'WMP_47@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '73b089be-d787-4d5b-99d3-d3304c45da5a', 0, 1, 1, 1, NULL, 0),
(1654, 'RAFAEL JAPPUR', 'RJAPPUR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '029a62fb-8edd-4540-84c9-a567300f51d0', 0, 1, 1, 1, NULL, 0),
(1655, 'ROBSONFORMOSOX@HOTMAIL.COM', 'ROBSONFORMOSOX@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '83947101-98c4-4db5-b425-1ce9576f03f3', 0, 1, 1, 1, NULL, 0),
(1656, 'STUMM@SC.SENAC.BR', 'STUMM@SC.SENAC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd0076c3b-7bb9-47a0-a31a-3d20981553df', 0, 1, 1, 1, NULL, 0),
(1657, 'DORINHA ♥', 'ISARICHARTZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f798e982-6581-4db0-a67b-b474a417030f', 0, 1, 1, 1, NULL, 0),
(1658, 'HAMBLUES@HOTMAIL.COM', 'HAMBLUES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bda539e4-900d-4926-bac6-481842ca6451', 0, 1, 1, 1, NULL, 0),
(1659, 'GABIACOMPANHANTE@HOTMAIL.COM', 'GABIACOMPANHANTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '688c14da-c3c8-4b6e-83b2-6498cccc3cf9', 0, 1, 1, 1, NULL, 0),
(1660, 'ARIANAVILLELA@YAHOO.COM.BR', 'ARIANAVILLELA@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5e19a970-34a5-41d1-9eef-dad746729caa', 0, 1, 1, 1, NULL, 0),
(1661, 'BORN DAILOR', 'DAILORBORN@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '59d5e303-469e-4891-a785-b33c07bb1854', 0, 1, 1, 1, NULL, 0),
(1662, 'WIGGERS', 'FWIGGERS@YAHOO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '02033b12-0282-4e33-81b5-ba871443c539', 0, 1, 1, 1, NULL, 0),
(1663, 'RUBINEI', 'RUBINEI@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7ce15e54-eb44-4cd6-9993-3fe2bdb06c52', 0, 1, 1, 1, NULL, 0),
(1664, 'MARCUSDMB@GMAIL.COM', 'MARCUSDMB@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '49a6c11b-570f-443f-abd3-e160eb594ebb', 0, 1, 1, 1, 473, 0),
(1665, 'L_BAHIANO@HOTMAIL.COM', 'L_BAHIANO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '66f2477f-c729-4c5d-93e3-9221391a9bf4', 0, 1, 1, 1, NULL, 0),
(1666, 'ALUNOS-ENGCOMP-SJ@LISTAS.UNIVALI.BR', 'ALUNOS-ENGCOMP-SJ@LISTAS.UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '636b5831-a980-4dcf-92f3-06b996e4b210', 0, 1, 1, 1, NULL, 0),
(1668, 'BAMBAFLORIPA@HOTMAIL.COM', 'BAMBAFLORIPA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0c774609-6087-44ef-b9ad-0b6b2188af9a', 0, 1, 1, 1, NULL, 0),
(1669, 'SABRINA SALLES', 'SASOARES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fe4e876c-5110-449a-89f0-40688f9aaa6b', 0, 1, 1, 1, 474, 0),
(1670, 'HALLAN MEDEIROS', 'EU@HALLANMEDEIROS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c05b6270-64e7-42c8-97bd-de20e5883b38', 0, 1, 1, 1, NULL, 0),
(1671, 'ALUCARDWOWP@GMAIL.COM', 'ALUCARDWOWP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '93504a52-6645-4ff8-9b05-30361b16c841', 0, 1, 1, 1, NULL, 0),
(1672, 'CCOMPUTACAO_2014_IESGF@GOOGLEGROUPS.COM', 'CCOMPUTACAO_2014_IESGF@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd99232ef-d42e-40a7-9e33-00faff41cf94', 0, 1, 1, 1, NULL, 0),
(1673, 'RESCHW@GMAIL.COM', 'RESCHW@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd8c533e2-eea0-4fc7-850d-126d364c11c5', 0, 1, 1, 1, NULL, 0),
(1674, 'CARLOS SOUSA PINTO', 'CSP@DSI.UMINHO.PT', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '186178d1-274d-45a9-b183-86dd52b6d7c4', 0, 1, 1, 1, NULL, 0),
(1675, 'CAROLINE BOEING CASAGRANDE', 'CBC@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eaca0107-e003-4d5c-a031-3dd0e1766e0a', 0, 1, 1, 1, NULL, 0),
(1676, 'THAYSSA', 'THAYSSA.MMP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7e9208a3-b7c6-4300-b66e-30d85973cdbd', 0, 1, 1, 1, 475, 0),
(1677, 'THAYSSA', 'THAYSSAMMP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8508659e-8017-4ded-ac0e-9838e0b3339b', 0, 1, 1, 1, 476, 0),
(1678, 'ALESSANDRA MARIA CASTRO', 'ALESSANDRA.MCASTRO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2ddd32d5-809d-4a3e-9039-049c0a94f53e', 0, 1, 1, 1, NULL, 0),
(1679, 'LIDIA P', 'ANGELDARK06@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '40ef5d79-c1a6-4f5f-809e-9fe518c4ec80', 0, 1, 1, 1, 477, 0),
(1680, 'VAIPIRA@HOTMAIL.COM', 'VAIPIRA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd5275fb1-ee6d-4714-a46a-f4c57c4429e9', 0, 1, 1, 1, NULL, 0),
(1681, 'DESIGN@UNISUL.BR', 'DESIGN@UNISUL.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aa0a39c1-f02c-4638-afeb-b0995543bbc0', 0, 1, 1, 1, NULL, 0),
(1682, 'CIKI.INSCRI2011@GMAIL.COM', 'CIKI.INSCRI2011@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '197edbff-a126-4b3a-904e-899d4e27a004', 0, 1, 1, 1, NULL, 0),
(1683, 'VAGAS@CESUSC.EDU.BR', 'VAGAS@CESUSC.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bf8c437f-9ee1-4dec-bcbd-324816deb1b9', 0, 1, 1, 1, NULL, 0),
(1684, 'ELTON IVAN SCHNEIDER', 'ESCHNEIDER@GRUPOUNINTER.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '605f485b-0182-46a5-82cb-db7668da4c6d', 0, 1, 1, 1, NULL, 0),
(1685, 'CRIS...FLORIPA. RICHARTZ', 'CRISSMARIARICHARTZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fcc694d4-303b-4fb9-92ac-9940f45edad3', 0, 1, 1, 1, NULL, 0),
(1686, 'MELFLORIPA26@HOTMAIL.COM', 'MELFLORIPA26@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e75e8a18-b9a5-4291-b712-c6d424322fad', 0, 1, 1, 1, NULL, 0),
(1687, 'EGRESSOS-CCOMP-SJ@LISTAS.UNIVALI.BR', 'EGRESSOS-CCOMP-SJ@LISTAS.UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8b6c035c-cbd1-4e20-a108-3a6021ecf1b7', 0, 1, 1, 1, NULL, 0),
(1688, 'MORGANA LEITE', 'MORGANALEITE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a9dd8240-31ae-41bb-93db-7683595a6ee7', 0, 1, 1, 1, 478, 0),
(1689, 'ACHILLE CARETTE', 'ACAR@SOFSHORE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '706609f1-6907-47e1-a996-15eacfd06abe', 0, 1, 1, 1, NULL, 0),
(1690, 'WAGNER WEBER', 'WAGNERWEBER_@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8d049d79-6bbf-4f5e-ba54-2f7707b9c926', 0, 1, 1, 1, NULL, 0),
(1691, 'FABIO OLIVEIRA', 'STAROSTA.FABIO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '24799b0b-528e-4dff-bc60-ef1c45350910', 0, 1, 1, 1, 479, 0),
(1692, 'ANA.C@YAHOO.COM.BR', 'ANA.C@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a13d9551-2fe4-40fb-a277-0d802e5e456e', 0, 1, 1, 1, NULL, 0),
(1693, 'RECURSOS-SAOJOSE@SC.SENAI.BR', 'RECURSOS-SAOJOSE@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '25c5fcba-f231-4444-ae61-50173dea2917', 0, 1, 1, 1, NULL, 0),
(1694, 'SECRETARIA DE GESTAO DE PESSOAS', 'SEGEPE@UNILA.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5b27676d-c119-4092-b040-d8e56beecf85', 0, 1, 1, 1, NULL, 0),
(1695, 'KLAIBSON RIBEIRO', 'KLAIBSON@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '54290a94-2001-4343-b72f-a0e70aab815a', 0, 1, 1, 1, 480, 0),
(1696, 'JAIMEMJUNIOR@GMAIL.COM', 'JAIMEMJUNIOR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ed08111d-2ea5-4fd3-a4e8-6039bfaf94c8', 0, 1, 1, 1, NULL, 0),
(1697, 'CIRIOVIEIRA@HOTMAIL.COM', 'CIRIOVIEIRA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd6a991c3-bd6a-45ba-bd91-9fd91865ce87', 0, 1, 1, 1, NULL, 0),
(1698, 'NELSON@CCS.UFSC.BR', 'NELSON@CCS.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '804bcde9-d7f5-4b96-bca6-874e1c1280f0', 0, 1, 1, 1, NULL, 0),
(1699, 'RAQUEL_GAROTA_SEXY@HOTMAIL.COM', 'RAQUEL_GAROTA_SEXY@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '36d1c3c3-4f97-4d31-a584-e2bc636a23a1', 0, 1, 1, 1, NULL, 0),
(1700, 'DERLIROYER@HOTMAIL.COM', 'DERLIROYER@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '816c001b-740c-43cd-8594-7b85da0912d8', 0, 1, 1, 1, NULL, 0),
(1701, 'SELECAO@TIBOX.COM.BR', 'SELECAO@TIBOX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ea8a4df5-3a5f-424a-871d-020fc4bdc3d2', 0, 1, 1, 1, NULL, 0),
(1702, 'JOAOE@WEG.NET', 'JOAOE@WEG.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '568b87e6-90fe-40b2-8774-696fe6773895', 0, 1, 1, 1, NULL, 0),
(1703, 'SISTEMAS.EAD@UNIVALI.BR', 'SISTEMAS.EAD@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c30b7124-1647-4cda-a6e4-90002c843bb8', 0, 1, 1, 1, NULL, 0),
(1704, 'LUCIA KINCELER', 'LKINCELER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3344cc3d-f62e-4b3f-85c3-dfaa5752a8e2', 0, 1, 1, 1, NULL, 0),
(1705, 'MARIA EDUARDA F.', 'DUDALIVE83@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '90689262-ec0d-425f-b373-6d54e525eb53', 0, 1, 1, 1, NULL, 0),
(1706, 'JEAN', 'JEAN@TDSA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '73b3097d-5c84-46f9-9509-e31832d0133e', 0, 1, 1, 1, NULL, 0),
(1707, 'KLEBEROC@UNIVALI.BR', 'KLEBEROC@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0d2df3f7-816b-4ff6-a168-07473b6c80c5', 0, 1, 1, 1, NULL, 0),
(1708, 'DOUGLAS JULIANI', 'DOUGLAS@WEBPACK.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9a7d1b5f-6d8c-4021-90bc-10cd7e6c3601', 0, 1, 1, 1, 481, 0),
(1709, 'PUBLIC@A.GWAVE.COM', 'PUBLIC@A.GWAVE.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2defc252-3964-4317-b966-40762903d5be', 0, 1, 1, 1, NULL, 0),
(1710, 'HEILANDMARC@AOL.COM', 'HEILANDMARC@AOL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a836ee0-0135-4506-b5ef-7358a003e013', 0, 1, 1, 1, NULL, 0),
(1711, 'MICHELE ANDRÉIA BORGES', 'MICHELE@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '410561ad-9cd8-452b-903a-04c9456563f0', 0, 1, 1, 1, NULL, 0),
(1712, 'ADRIANO GASPAR', 'ADRIANOGASPAR@CONTEXTODIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8dbfa961-9e54-4059-b9c7-44880aac3e78', 0, 1, 1, 1, NULL, 0),
(1713, 'CLIC@CLICNEGOCIOS.COM', 'CLIC@CLICNEGOCIOS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4067c1d4-de83-4e06-96dc-b995f1373a6b', 0, 1, 1, 1, NULL, 0),
(1714, 'SERGIO@CTC.UFSC.BR', 'SERGIO@CTC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9aa8a700-16c0-4396-9bf2-a9572468b62f', 0, 1, 1, 1, NULL, 0),
(1715, 'CLAUDIO.KERBER@DIGITRO.COM.BR', 'CLAUDIO.KERBER@DIGITRO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '08e22ef3-a563-4091-b9ad-11e5955a59d2', 0, 1, 1, 1, NULL, 0),
(1716, 'CENTRALDECALCULOS@CAIXASEGUROS.COM.BR', 'CENTRALDECALCULOS@CAIXASEGUROS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd6a62944-3a12-494f-8cd9-5dc39408c014', 0, 1, 1, 1, NULL, 0),
(1717, 'SEGURANCA@NOTICIASDODIA.COM.BR', 'SEGURANCA@NOTICIASDODIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f42814d3-6dc1-4d40-9075-5d955d5aad3e', 0, 1, 1, 1, NULL, 0),
(1718, 'PRISCILAXAVIERRAMOS@HOTMAIL.COM', 'PRISCILAXAVIERRAMOS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '343561d6-f709-4b73-821d-8d0aa8371860', 0, 1, 1, 1, NULL, 0),
(1719, 'FALE@LOGIQUE.COM.BR', 'FALE@LOGIQUE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd22c6a95-4f1e-4415-8db5-92edb10f0232', 0, 1, 1, 1, NULL, 0),
(1720, 'LOGIQUEWEB@GMAIL.COM', 'LOGIQUEWEB@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2b54993f-2847-4f42-b510-ba127c213e4a', 0, 1, 1, 1, NULL, 0),
(1721, 'CLOVIS_CECHET@HOTMAIL.COM', 'CLOVIS_CECHET@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0131ac90-8781-4948-954c-e5b6876873a7', 0, 1, 1, 1, NULL, 0),
(1722, 'EMBEDDY@APPSPOT.COM', 'EMBEDDY@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bb062234-a43c-4af8-85ac-6e321d7c7298', 0, 1, 1, 1, NULL, 0),
(1723, 'GLEISY@CIN.UFSC.BR', 'GLEISY@CIN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'acd92b67-a7ca-4183-8ee8-40067c5dc1ee', 0, 1, 1, 1, NULL, 0),
(1724, 'ELIANACC@GMAIL.COM', 'ELIANACC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a0683436-2445-4efb-b2f7-45866cb600a6', 0, 1, 1, 1, 482, 0),
(1725, 'FORUM-BOTTY@APPSPOT.COM', 'FORUM-BOTTY@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9db88e1f-6ef8-4d74-ad95-02e2d5fd438a', 0, 1, 1, 1, NULL, 0),
(1726, 'ANGELA.AMIM@UOL.COM.BR', 'ANGELA.AMIM@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '752649e3-c273-4082-b84c-0b795ca95c2b', 0, 1, 1, 1, NULL, 0),
(1727, 'MARCOSEUFRASIO@HOTMAIL.COM', 'MARCOSEUFRASIO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4108019a-64e2-4c38-a2d0-880e06e87fce', 0, 1, 1, 1, NULL, 0),
(1728, 'ALVARO DIAS', 'PROF.ALVARODIAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c6b10eb3-6499-468f-87d3-5d1e5b4bfd6a', 0, 1, 1, 1, NULL, 0),
(1729, 'THALES SCHULZ', 'THALESSCHULZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '791ee2e4-3a05-4607-8eb5-2c716c98a566', 0, 1, 1, 1, NULL, 0),
(1730, 'CLINIVETINGLESES@HOTMAIL.COM', 'CLINIVETINGLESES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e31f5d60-f88a-4292-aaf0-f9ec6d91f739', 0, 1, 1, 1, NULL, 0),
(1731, 'RICARDINHO@FLORIPA.COM.BR', 'RICARDINHO@FLORIPA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '014eca4b-1514-40c3-99c6-0cbaf74e4ae2', 0, 1, 1, 1, NULL, 0),
(1732, 'FERNANDOVALTER@GMAIL.COM', 'FERNANDOVALTER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9ae37a2a-107e-4909-a13d-e45cc864e664', 0, 1, 1, 1, 483, 0),
(1733, 'JANICI DE SOUZA', 'JANICI@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cb2726ac-26d0-4771-ad97-c646fde7e0d8', 0, 1, 1, 1, NULL, 0),
(1734, 'MARILIA@FFALM.BR', 'MARILIA@FFALM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ffaac723-a916-416f-acaf-b85a1fe0f451', 0, 1, 1, 1, NULL, 0),
(1735, 'ADRIANA@BSCONSULTORIA.COM.BR', 'ADRIANA@BSCONSULTORIA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '53d828a8-a3df-43c1-9914-ae90d2fdaf28', 0, 1, 1, 1, NULL, 0),
(1736, 'MURILO CESCONETTO', 'MCESCONETTO@BRDIGITAL.NET.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f287b1ef-b119-462c-8cb3-88c36ac6cb82', 0, 1, 1, 1, NULL, 0),
(1737, 'JEFERSON ANDRADE', 'JEFERSONJA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '80d1f27b-7030-4b5f-886d-ebf815f6c672', 0, 1, 1, 1, 484, 0),
(1738, 'HUDCORE@GMAIL.COM', 'HUDCORE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a2b0c9b-ab30-4866-8ee3-994312b46763', 0, 1, 1, 1, NULL, 0),
(1739, 'MARCUS@IEA.ORG.BR', 'MARCUS@IEA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ea4c11c7-9a1d-4f3a-ba3b-920a0112aade', 0, 1, 1, 1, NULL, 0),
(1740, 'LUIZ FERNANDO GAMBA', 'GAMBA@SOFTPLAN.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e280a900-8f03-456b-9a3b-8648b39a0eb5', 0, 1, 1, 1, NULL, 0),
(1741, 'GREGO', 'GREGO@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '95bb46d3-da8a-4e23-a6f4-c0703a7c1669', 0, 1, 1, 1, 485, 0),
(1742, 'LEANDRO ALVES', 'LEANDRO.ALVES.PROGRAMACAO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3e38d5db-b1e9-48de-bb7f-b773645580cc', 0, 1, 1, 1, 486, 0),
(1743, 'M.A.U.R.G.O.M.E.S@GMAIL.COM', 'M.A.U.R.G.O.M.E.S@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3a4a625f-98bd-40a2-9ad4-2c01c536f355', 0, 1, 1, 1, NULL, 0),
(1744, 'ERON@INOPLAN.COM.BR', 'ERON@INOPLAN.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '36fb5a9f-0a8c-4160-83af-b445663bccb6', 0, 1, 1, 1, NULL, 0),
(1745, 'YURICARDENAS@GMAIL.COM', 'YURICARDENAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '58174272-5e95-477a-90da-8cdce194958e', 0, 1, 1, 1, NULL, 0),
(1746, 'MARTHINLM@GMAIL.COM', 'MARTHINLM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd0810f10-3316-4074-b2f0-a7cdeab5be1d', 0, 1, 1, 1, NULL, 0),
(1747, 'GILBERTO MASETTO', 'GILBERTO.MASETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f911b767-59a8-4694-ade5-69c65773420f', 0, 1, 1, 1, NULL, 0),
(1748, 'GILBERTO MASETTO', 'GILBERTOMASETTO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fabcb9d0-3b5c-4ccc-8636-fb524ba1d0d3', 0, 1, 1, 1, NULL, 0),
(1749, 'LEOMULER@HOTMAIL.COM', 'LEOMULER@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c9b87368-bbfd-4988-b242-42c93da7f9b2', 0, 1, 1, 1, NULL, 0),
(1750, 'MARCOS EUFRASIO', 'MARCOSEUFRASIO@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1f5c489d-668c-4248-a722-2f45e17cab8c', 0, 1, 1, 1, 487, 0),
(1751, 'MARCOS.STROSCHEIN@IFSC.EDU.BR', 'MARCOS.STROSCHEIN@IFSC.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd2afd143-b59b-4ab0-a04e-c69f2cfd241a', 0, 1, 1, 1, NULL, 0),
(1752, 'ALUCARD_DRAC@HOTMAIL.COM', 'ALUCARD_DRAC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cceccd54-bf46-4f04-a8db-9d02c6c0bef1', 0, 1, 1, 1, NULL, 0),
(1753, 'MATHEUSMEIRAA@GMAIL.COM', 'MATHEUSMEIRAA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'facdcc27-221e-4bbe-9ec1-d3d9e7b29688', 0, 1, 1, 1, NULL, 0),
(1754, 'GISELLE DELLOME DE JESUS', 'GISELLE@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '758018d3-af7c-4f6c-8a73-6984e031e946', 0, 1, 1, 1, NULL, 0),
(1755, 'FABRICIO KALBUSCH', 'FABRICIOKALBUSCH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8d8a0534-dae0-49e0-a617-bf7fb3bd9823', 0, 1, 1, 1, 488, 0),
(1756, 'LETICIA FARIAS', 'LETICIAFARIAS.SC@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bc689239-e7fa-4c76-9691-3c16ca40fab3', 0, 1, 1, 1, 489, 0),
(1757, 'LFCELESTRINO@GMAIL.COM', 'LFCELESTRINO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'af01bb97-4f5e-4a1c-8585-e34429ceec15', 0, 1, 1, 1, NULL, 0),
(1758, 'ANA GIL', 'ANALUCIAGIL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8fa417e2-4348-4cf7-a394-9acc0f04dd09', 0, 1, 1, 1, 490, 0),
(1759, 'THIAGO TRINDADE REIS', 'TTRINDADE@COMMCORP.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ea34f20d-3a22-4b11-a3be-335391836d62', 0, 1, 1, 1, NULL, 0),
(1760, 'PEDRO MACCARINI', 'PEDROEMACCARINI@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4200e5f8-bb6b-4338-9d13-579a337c043a', 0, 1, 1, 1, NULL, 0),
(1761, 'EGC SEMINARIOS', 'EGC.SEMINARIOS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2bdacf3b-2fe5-4a92-b551-ffaed99a8ca4', 0, 1, 1, 1, NULL, 0),
(1762, 'SILVANABERNARDESROSE@GMAIL.COM', 'SILVANABERNARDESROSE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '59ac5a0c-8e27-4218-93cd-c282108b42d4', 0, 1, 1, 1, NULL, 0),
(1763, 'RITA MACEDO', 'RITAMACEDO@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f46f3d9b-e061-473e-a404-c7911e7d170f', 0, 1, 1, 1, NULL, 0),
(1764, 'CIRIO@SENSYS.COM.BR', 'CIRIO@SENSYS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '80c4b305-e04b-4ec9-b67a-abc78df22661', 0, 1, 1, 1, NULL, 0),
(1765, 'ISMAEL BERNARDES', 'MAELBERNARDES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dee2d7f6-9648-49e5-a073-d42d703420fb', 0, 1, 1, 1, 491, 0),
(1766, 'MSN@DEXTER0X.COM', 'MSN@DEXTER0X.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '80b2b007-cf8e-472d-970d-3e4bea73f889', 0, 1, 1, 1, NULL, 0),
(1767, 'ROBERTO PACHECO', 'PACHECO@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2ab428c0-8e8b-4062-90da-f93d686fa816', 0, 1, 1, 1, NULL, 0),
(1768, 'SRSSURFBOARDS@HOTMAIL.COM', 'SRSSURFBOARDS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7360567e-3957-4144-b0db-d9555f425325', 0, 1, 1, 1, NULL, 0),
(1769, 'CLOVISWERNER@GMAIL.COM', 'CLOVISWERNER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3aca67cd-212b-41b9-8548-26ff8be22345', 0, 1, 1, 1, NULL, 0),
(1770, 'DANIEL BOPPRÉ', 'DANIEL@CONTEXTODIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dc8f0c5a-9d61-4c35-95fe-761c8a4b1fe7', 0, 1, 1, 1, 492, 0),
(1771, 'DOUGLAS', 'DOUGLAS@DRM.ENG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f95d7410-fd7c-4b56-abe0-50b4feb9784c', 0, 1, 1, 1, NULL, 0),
(1772, 'CLINICA3IRMAOS@HOTMAIL.COM', 'CLINICA3IRMAOS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '493a7072-2fac-4342-93a1-874ad6b46704', 0, 1, 1, 1, NULL, 0),
(1773, 'LAÍSE GONÇALVES', 'LAISEGONCALVES.12@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd3ef3712-d77a-4a50-bf05-9e504761bbc9', 0, 1, 1, 1, NULL, 0),
(1774, 'WALQUIRIANOGUTI@HOTMAIL.COM', 'WALQUIRIANOGUTI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f06914a9-51c4-4057-a4fc-8c8c1b8e6291', 0, 1, 1, 1, NULL, 0),
(1775, 'RICHARD.PERASSI', 'RICHARD.PERASSI@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a99c4cb5-84a1-44b3-84c2-4d692ef211e2', 0, 1, 1, 1, NULL, 0),
(1776, 'MAURICIO MANHÃES', 'MANHAES@MSN.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'aa01a139-7296-4e74-a013-6fc82a80a230', 0, 1, 1, 1, NULL, 0),
(1777, 'LEONARDO DE OLIVEIRA', 'LEO.SC@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e070114b-821f-4f6b-9ee7-2e189b294b2e', 0, 1, 1, 1, NULL, 0),
(1778, 'LORENA MOREIRA', 'LORENA_MOREIRA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0639d39d-8a8b-421b-a2ab-7161b912b032', 0, 1, 1, 1, NULL, 0),
(1779, 'JOÃO ARTUR SOUZA', 'JARTUR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ec1bb2a7-3c24-4744-8bde-2c16a1615be6', 0, 1, 1, 1, 493, 0),
(1781, 'DESENVOLVIMENTO@OUTPLAN.COM.BR', 'DESENVOLVIMENTO@OUTPLAN.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ba51a5ab-b931-4fd4-a2c4-53934f0aae5b', 0, 1, 1, 1, NULL, 0),
(1782, 'CESAR@EXTRADIGITAL.COM.BR', 'CESAR@EXTRADIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd000eb24-7b3b-48e8-920e-715eeeda6f8f', 0, 1, 1, 1, NULL, 0),
(1783, 'ANGELA FLORES', 'ARQANGELAFLORES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ae7df5b0-71d8-4e9b-ace4-7ca2948c160e', 0, 1, 1, 1, 494, 0),
(1784, 'FABIANE CARDOSO DA SILVA', 'FABIANECARDOSOSILVA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '91d0aa02-5c87-4705-bdc3-5b164e13729e', 0, 1, 1, 1, 495, 0),
(1785, 'LILIAN RICHARTZ', 'LILIANRICHARTZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd854cc13-5f70-4636-9fcb-28f36a9aa2a9', 0, 1, 1, 1, 496, 0),
(1786, 'LILIAN RICHARTZ', 'LILIANRICHARTZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '618af33b-ad59-43fc-b2bb-bde246229dd9', 0, 1, 1, 1, 497, 0),
(1787, 'OAJAC@NEWSITE.COM.BR', 'OAJAC@NEWSITE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd6396490-0175-409f-8077-a6013599bc5a', 0, 1, 1, 1, NULL, 0),
(1788, 'NANCY MOHAMED', 'NANCYMOHAMED777@YAHOO.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '574b725d-79d3-48cd-93ea-d23f8cd21b0e', 0, 1, 1, 1, NULL, 0),
(1789, 'KATIA REGINA BENTO DOS SANTOS', 'KATIA@CTAI.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a44adc50-8855-48ba-b432-09d3ec0ab376', 0, 1, 1, 1, NULL, 0),
(1790, 'VIVIANI FAPEU', 'VIVIANI@FAPEU.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a6cfcfe-ab43-4bb7-94bd-d76d4b2fdb65', 0, 1, 1, 1, NULL, 0),
(1791, 'VIVIANI FAPEU', 'VIVICABRAL10@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b01567b4-6166-4752-94a6-d05079b184fd', 0, 1, 1, 1, NULL, 0),
(1792, 'RITA@STELA.ORG.BR', 'RITA@STELA.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1082fbd8-a9c3-4ff1-ba3d-3b94376b1b44', 0, 1, 1, 1, NULL, 0),
(1793, 'MARCIA JULIANA ASSOLARI', 'MARCIAASSOLARI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8a22009b-2cfc-4813-aaa4-0f31dd344cc4', 0, 1, 1, 1, NULL, 0),
(1794, 'LUTHER2212@HOTMAIL.COM', 'LUTHER2212@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'af6b456e-afc4-4a61-ab8c-3e786fe428f3', 0, 1, 1, 1, NULL, 0),
(1795, 'ROWENHENDRA55@HOTMAIL.COM', 'ROWENHENDRA55@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9339ff2a-108b-4daa-925f-6a5025441529', 0, 1, 1, 1, NULL, 0),
(1796, 'INFORMÁTICA IES/FASC', 'INFORMATICA.ADM@IES.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '070f2cbf-ea03-4010-983c-806a42085475', 0, 1, 1, 1, NULL, 0),
(1797, 'ANDRECOLASANTE@HOTMAIL.COM', 'ANDRECOLASANTE@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e6c2aadb-21e6-489f-b0aa-318aba3c58c1', 0, 1, 1, 1, NULL, 0),
(1798, 'DEPAULA@UNISUL.COM', 'DEPAULA@UNISUL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c29f200-90ab-4e8e-b613-161d90d2710f', 0, 1, 1, 1, NULL, 0),
(1799, 'EDENILSON.BORBA@KINGHOST.COM.BR', 'EDENILSON.BORBA@KINGHOST.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bc8f283e-f286-4484-b1de-17f956d64b90', 0, 1, 1, 1, NULL, 0),
(1800, 'MAI', 'MAIIIIMEISTER@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'edff8711-bc92-452a-af59-cafccbc8de2e', 0, 1, 1, 1, 498, 0),
(1801, 'GERUSA ANDRADE', 'GERUSADEANDRADE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c7642b56-549f-4935-b1be-099ecc639f72', 0, 1, 1, 1, 499, 0),
(1802, 'ANDRÉ SEIBT', 'SEIBT01@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b060452b-ee22-4f52-a6db-9b2f250b36e6', 0, 1, 1, 1, NULL, 0),
(1803, 'LETICIA.RAUPP@ENGEVIX.COM.BR', 'LETICIA.RAUPP@ENGEVIX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c5d3a9e1-9177-47d9-84ab-4dd6ae744f21', 0, 1, 1, 1, NULL, 0),
(1804, 'ELINOREMUDRA6613@HOTMAIL.COM', 'ELINOREMUDRA6613@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e77f7c24-f7dd-4f63-afc0-84a576712d70', 0, 1, 1, 1, NULL, 0),
(1805, 'GUS@FLORIPA.COM.BR', 'GUS@FLORIPA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c2dbd49e-591b-46aa-925c-2d568074e72e', 0, 1, 1, 1, NULL, 0),
(1806, 'ANDRÉ RICARDO RIGHETTO', 'RIGHETTO@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '84c5b5a1-16c3-4644-8bd8-c3df4d3ea1c5', 0, 1, 1, 1, NULL, 0),
(1807, 'KYOSHI TAKEMURA', 'JUNIORTAKEMURA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4af0edf2-7b6f-421c-b19e-252b21e477d6', 0, 1, 1, 1, NULL, 0),
(1808, 'THIAGO S. VIEIRA', 'THIAGO.VIEIRA@RFTRECK.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fd549e30-ad44-4090-88ba-6b56a1657c94', 0, 1, 1, 1, NULL, 0),
(1809, 'COORDENAÇÃO DO CURSO DE ENGENHARIA - IES', 'COORDENACAOENGENHARIAIES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cae16342-fa3f-487c-be39-4c173c0efe54', 0, 1, 1, 1, NULL, 0),
(1810, 'ANDRE_OBSCURO@HOTMAIL.COM', 'ANDRE_OBSCURO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7a9e96d3-a490-4ae5-97a0-4668176dd36b', 0, 1, 1, 1, NULL, 0),
(1811, 'MARCIA@REITORIA.UFSC.BR', 'MARCIA@REITORIA.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b8db8aa8-2caa-4bdd-89e6-321b20cbe5cb', 0, 1, 1, 1, NULL, 0),
(1812, 'JÚNIOR IBAGY', 'MJUNIOR@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5f1c3d99-5228-4acd-a1a9-67e9e82537b5', 0, 1, 1, 1, NULL, 0),
(1813, 'ANITA.FERNANDES@UNIVALI.BR', 'ANITA.FERNANDES@UNIVALI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '702a2955-9e6f-485c-ac02-7a594fedf2ad', 0, 1, 1, 1, NULL, 0),
(1814, 'CEPUTEC_FUNDAMENTOS_PROGRAMACAO_VISUAL@GOOGLEGROUPS.COM', 'CEPUTEC_FUNDAMENTOS_PROGRAMACAO_VISUAL@GOOGLEGROUPS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e6c2ca5d-4f24-47b0-acb1-90975fd6ba13', 0, 1, 1, 1, NULL, 0),
(1815, 'THIAGO DINIZ', 'TFBATERA@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b1e35438-bb9b-463d-bddc-7af1e301d005', 0, 1, 1, 1, NULL, 0),
(1816, 'PATRYCKRM@HOTMAIL.COM', 'PATRYCKRM@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1ff9fa14-0b40-466f-a88b-c057e59fc192', 0, 1, 1, 1, NULL, 0),
(1817, 'MARCUSVINICIUS@ISCC.COM.BR', 'MARCUSVINICIUS@ISCC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f307e0d0-db5f-4329-8aa3-c172a12dd604', 0, 1, 1, 1, NULL, 0),
(1818, 'ANDRÉ RICARDO RIGHETTO', 'RIGHETTO@LED.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1a3a32c2-3e35-444b-a366-9005fc1999af', 0, 1, 1, 1, NULL, 0),
(1819, 'JOAOHGS_3@HOTMAIL.COM', 'JOAOHGS_3@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ebf5d431-ed7c-419d-b094-2478d3dbef60', 0, 1, 1, 1, NULL, 0),
(1820, 'GLAUCIA-RENATA ROSA', 'GRROSA@AGUARANI.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bdc11e6c-dd2c-4448-a2c6-8c0ce69dae1c', 0, 1, 1, 1, NULL, 0),
(1821, 'CONTACT@BOOKESS.COM', 'CONTACT@BOOKESS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9643de7c-808f-4913-b8bf-3ccea4858ab3', 0, 1, 1, 1, NULL, 0),
(1822, 'IVAN NOGUEIRA', 'PIGASFLORIPA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '30083485-8305-448a-8c28-2db1bbd1a97d', 0, 1, 1, 1, 500, 0),
(1823, 'JOSÉ HENRIQUE CARDOSO', 'HENRIKEJH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f41da90b-0c5b-4891-9c02-377e0c1d8ea2', 0, 1, 1, 1, NULL, 0),
(1824, 'ANDRELUIZHAAG@GMAIL.COM', 'ANDRELUIZHAAG@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4aa9cba7-9928-4f44-81ad-c99f81917bb7', 0, 1, 1, 1, NULL, 0),
(1825, 'ARMANDO RIBAS', 'MANDORGR@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '57c3c0a7-6e07-4946-ac5e-0b3da0145e5e', 0, 1, 1, 1, NULL, 0),
(1826, 'LOJIQUEWEB@GMAIL.COM', 'LOJIQUEWEB@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8969ae53-ab18-4faf-b648-85c15a1d89bb', 0, 1, 1, 1, NULL, 0),
(1827, 'SCUSSEL@LEPTEN.UFSC.BR', 'SCUSSEL@LEPTEN.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7ef2ed35-6029-40f6-a426-2e31f7716fb0', 0, 1, 1, 1, NULL, 0),
(1828, 'JBOSCO', 'JBOSCO@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '33481991-7d3a-4fe8-a297-510e035e0e5e', 0, 1, 1, 1, NULL, 0),
(1829, 'MIRELA@BARDDAL.BR', 'MIRELA@BARDDAL.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'db0bb935-84f1-4d10-a908-b96a58d5380c', 0, 1, 1, 1, NULL, 0),
(1830, 'SINAPSE DA INOVAÇÃO', 'SINAPSE@SINAPSEDAINOVACAO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'ff7da012-4981-476d-bb66-b4b7f7c3e94b', 0, 1, 1, 1, NULL, 0),
(1831, 'MARCONE HRAMI', 'MARCONEH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4bc2709e-f7f3-43c7-855e-fdcc2088f339', 0, 1, 1, 1, NULL, 0),
(1832, 'MARCIA ADRIANA PELEPEK', 'MARCIA.PELEPEK@FLN.SESISC.ORG.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '98e509a5-99ca-491a-b36b-bda7af46c2ce', 0, 1, 1, 1, NULL, 0),
(1833, 'VIADO', 'WEBMASTER@MATRIX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fd7fcd27-f7af-4080-a5bd-55d109a394f0', 0, 1, 1, 1, NULL, 0),
(1834, 'MARCO CHAGA', 'MARCO@CONTEXTODIGITAL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a939e6bb-c45a-40da-93cc-3dcb496adf4d', 0, 1, 1, 1, 501, 0),
(1835, 'KARIN REGINA COELHO QUANDT', 'JAQUEMPO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '50eedfc3-fb80-437e-bdaa-d6faf4715d5d', 0, 1, 1, 1, 502, 0),
(1836, 'MHHSU@CCMS.NKFUST.EDU.TW', 'MHHSU@CCMS.NKFUST.EDU.TW', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4c3f9b0b-47f1-4e25-9940-3ec57a245059', 0, 1, 1, 1, NULL, 0),
(1837, 'ANDREIA DE BEM', 'ANDREIADEBEM@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cf5d2d93-0255-4e4b-85f7-a98a9e40cdf3', 0, 1, 1, 1, 503, 0),
(1838, 'EDUARDO MOREIRA DA COSTA', 'EDUCOSTAINOVACAO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7d2d94ba-2913-458c-8710-91598cdfab47', 0, 1, 1, 1, NULL, 0),
(1839, 'ROGERIO@INF.UFSC.BR', 'ROGERIO@INF.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a15fbfe4-c2a3-4235-b73f-68e740643680', 0, 1, 1, 1, NULL, 0),
(1840, 'LAINE.VALGAS@RBSTV.COM.BR', 'LAINE.VALGAS@RBSTV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '72fb8722-f83c-4050-ac3b-c7e2f39e2dd6', 0, 1, 1, 1, NULL, 0),
(1841, 'ALEXANDRE.PASE@SC.SENAI.BR', 'ALEXANDRE.PASE@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd14eb5ca-4c50-4ba2-a83b-675aab1227fc', 0, 1, 1, 1, NULL, 0),
(1842, 'ROSANE FATIMA ANTUNES OBREGON', 'ANTUNESOBREGON@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '31491054-37f7-425b-b594-9caf9b348285', 0, 1, 1, 1, 504, 0),
(1843, 'CASSIANO ZEFERINO DE CARVALHO NETO', 'CARVALHONETOCZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'edbb53ad-0a40-4b48-8a62-3621774a2373', 0, 1, 1, 1, 505, 0),
(1844, 'JANINE_ALVES@HOTMAIL.COM', 'JANINE_ALVES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '043846ec-259c-405e-b88e-c09bba8a2ab7', 0, 1, 1, 1, 506, 0),
(1845, 'CRISTINA - SUPERÀTO DESENVOLVIMENTO HUMANO', 'CRISTINA@SUPERATO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '1d31e049-299c-432a-a549-5e6bf32774b8', 0, 1, 1, 1, NULL, 0),
(1846, 'FRONZAJR@GMAIL.COM', 'FRONZAJR@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c4ee6ad-0dc4-4db5-b9b4-be5b4b4eed6e', 0, 1, 1, 1, NULL, 0),
(1847, 'MAGNOS PIZZONI', 'MAGNOSPIZZONI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b5a12bf8-fd92-4ca4-af66-16b9e1254f7b', 0, 1, 1, 1, NULL, 0),
(1848, 'ROSANEALESSIO@UNESC.NET', 'ROSANEALESSIO@UNESC.NET', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b97ab691-d544-4a30-aaac-091db9a8c857', 0, 1, 1, 1, NULL, 0),
(1849, 'EDUARDO MELO', 'EDUARDO.WE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4118ec4d-b897-40d7-ad01-37f0e4297da8', 0, 1, 1, 1, 507, 0),
(1850, 'EDUARDO MELO', 'EDUARDOWE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '899e4ac0-5c33-46ae-bfb5-ff705760a331', 0, 1, 1, 1, 508, 0),
(1851, 'NICOLAVILARDO@HOTMAIL.COM', 'NICOLAVILARDO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7605857c-a17a-4528-8a0c-be9d16c41d65', 0, 1, 1, 1, NULL, 0),
(1852, 'ISMAEL.DOSANTOS@UOL.COM.BR', 'ISMAEL.DOSANTOS@UOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e5c431bd-7ef7-4b15-8830-e5771127a610', 0, 1, 1, 1, NULL, 0),
(1853, 'FRANCINI RENSI SCHMITZ', 'FRANCINI@CCS.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e962e755-f24c-43d4-af30-2fd159618661', 0, 1, 1, 1, NULL, 0),
(1854, 'JEFFERSONRUBENS@HOTMAIL.COM', 'JEFFERSONRUBENS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8e2fe732-6209-47be-93c6-0eef90941b33', 0, 1, 1, 1, NULL, 0),
(1855, 'DAIANE HAHN', 'DAI.HAHN@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8e15a48d-74d1-4fb1-9f4a-a15000a898f2', 0, 1, 1, 1, NULL, 0),
(1856, 'RAFAEL@PONTESMARTINS.COM.BR', 'RAFAEL@PONTESMARTINS.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '21b2ff2e-de98-451d-808f-bc241827afa2', 0, 1, 1, 1, NULL, 0),
(1857, 'MORENAROSA.00@HOTMAIL.COM', 'MORENAROSA.00@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '6754fef3-9c63-416b-a224-a9ce91ced1b6', 0, 1, 1, 1, NULL, 0),
(1858, 'PCASSETTARI@HOTMAIL.COM', 'PCASSETTARI@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e9015ba9-11b7-4b9e-9018-edbed5b6cde5', 0, 1, 1, 1, NULL, 0),
(1859, 'DUEDU21@HOTMAIL.COM', 'DUEDU21@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'd1575e28-d5ba-468f-84fc-e00e347d303a', 0, 1, 1, 1, NULL, 0),
(1860, 'FRANCOFRETTA@HOTMAIL.COM', 'FRANCOFRETTA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9488bf11-4aa6-4f04-9301-dfb7cd9cd9be', 0, 1, 1, 1, NULL, 0),
(1861, 'GEISONSAISS@HOTMAIL.COM', 'GEISONSAISS@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bdec192e-b5e3-4a5c-85ca-55bf14d581cb', 0, 1, 1, 1, NULL, 0),
(1862, 'VALDETE', 'JANINEALVES@BRTURBO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'caec0d14-4a0e-4c38-b24a-6be6a293092e', 0, 1, 1, 1, NULL, 0),
(1863, 'IBOTIRAMA2@HOTMAIL.COM', 'IBOTIRAMA2@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e5228878-ffdc-40ef-97c2-4ae6865aa3f9', 0, 1, 1, 1, NULL, 0),
(1864, 'MICHELESRICHARTZ@HOTMAIL.COM', 'MICHELESRICHARTZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '939c056d-bce5-43fa-9764-2df64733f4ff', 0, 1, 1, 1, NULL, 0),
(1865, 'DAVID BRÉS DOS SANTOS', 'DAVIDSKT@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'da53ac71-9d6c-4e83-8885-9606f0b06148', 0, 1, 1, 1, 509, 0),
(1866, 'KATIA REGINA BENTO DOS SANTOS', 'KATIA@SC.SENAI.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '648cc6a5-63b6-4f66-9908-bcea4f1e626c', 0, 1, 1, 1, NULL, 0),
(1867, 'EDSON V. MACHADO', 'MACHADOEV@BOL.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c60c38e3-0d6e-4ae3-bcbb-7078cedb027a', 0, 1, 1, 1, NULL, 0),
(1868, 'JUAN.COTO@EADADM.UFSC.BR', 'JUAN.COTO@EADADM.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bcf70a3f-ba2e-4a5f-9e64-db21309430e6', 0, 1, 1, 1, NULL, 0),
(1869, 'MYWAVEID@APPSPOT.COM', 'MYWAVEID@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'e38efb25-962b-497b-a576-d020dec93584', 0, 1, 1, 1, NULL, 0),
(1870, 'EDUARDO_LOPES@HOTMAIL.COM', 'EDUARDO_LOPES@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7a671bc4-ece8-46bc-8e78-ec1a0e13fb3e', 0, 1, 1, 1, NULL, 0),
(1871, 'ANNNALUCIA', 'ANNNALUCIA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2b59bd63-29ee-4a4a-be96-9911e4120a36', 0, 1, 1, 1, NULL, 0),
(1872, 'CAROLINA SCHMITT NUNES', 'NUNES.CAROLINAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f33d1b03-4015-4715-8818-514e158316ab', 0, 1, 1, 1, 510, 0),
(1873, 'ALEJANDRO GARCIA', 'GARCIA.RAMIREZ@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '255dd4c5-f3fb-4e0c-a47e-ea017e9d5e9f', 0, 1, 1, 1, NULL, 0),
(1874, 'NNNATHALIA@HOTMAIL.COM', 'NNNATHALIA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'f061de52-56ed-403d-b423-d5ee6f2fe112', 0, 1, 1, 1, NULL, 0),
(1875, 'ELIZIANABEATRIZ@HOTMAIL.COM', 'ELIZIANABEATRIZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9cc703cf-f6a3-4836-82a9-5e265887199e', 0, 1, 1, 1, NULL, 0),
(1876, 'JORGE GONZAGA JR', 'JORGEGONZAGA@EGC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bbe21817-4418-4278-9f2a-00021a093533', 0, 1, 1, 1, NULL, 0),
(1877, 'CESAR AFONSO AFONSO', 'CESARAFONSO2010@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a39abf81-0d28-4ebb-ba66-31af12f5fb48', 0, 1, 1, 1, 511, 0),
(1878, 'RHBRASIL@ARCTOUCH.COM', 'RHBRASIL@ARCTOUCH.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '04dca01e-47d0-4fa2-8f8f-466a9787dafa', 0, 1, 1, 1, NULL, 0),
(1879, 'MAURO SERGIO SILVA', 'MAURO.SILVA@PDCASE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '871d9136-7683-4d91-abac-ade004b81be8', 0, 1, 1, 1, NULL, 0),
(1880, 'MERYSCHULTZ@HOTMAIL.COM', 'MERYSCHULTZ@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'bca466a8-2e13-41e0-b2fa-8768df015862', 0, 1, 1, 1, NULL, 0),
(1881, 'MURILO 737', 'MURILO737@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '24e50378-5e2b-42eb-8aa7-5535f8d09e3c', 0, 1, 1, 1, NULL, 0),
(1882, 'FRANCINI RENSI SCHMITZ', 'FRANRENSI@YAHOO.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '972cfdd4-fb18-4533-ad2e-d6f33e0152a1', 0, 1, 1, 1, NULL, 0),
(1884, 'JÉSSICA VANESSA', 'XEROX.COORDENACAO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'dc1feb7a-759b-4396-8213-e3af2350e04b', 0, 1, 1, 1, 512, 0),
(1885, 'HUMBERTOSENA@GMAIL.COM', 'HUMBERTOSENA@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '41dd2ff9-b4e6-4ddc-9d47-ba29c5644ac0', 0, 1, 1, 1, NULL, 0),
(1886, 'SRS SURFBOARDS', 'CONTATO@SRSSURFBOARDS.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '46904583-2b58-47ff-9e16-065a176d0845', 0, 1, 1, 1, NULL, 0),
(1887, 'DECARVALHO.KRIS1916@GMAIL.COM', 'DECARVALHO.KRIS1916@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '23e700f1-9a3a-4705-839f-f94568d28741', 0, 1, 1, 1, NULL, 0),
(1889, 'LUCAS LINO PINHEIRO', 'MARIAH.LUCAS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '3b21c180-aef2-4576-9b3c-9a621b9637b5', 0, 1, 1, 1, NULL, 0),
(1890, 'INF.SENAI-SC@HOTMAIL.COM', 'INF.SENAI-SC@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '843922eb-324e-4b5d-86a3-8a4467b88bb3', 0, 1, 1, 1, NULL, 0),
(1891, 'CTTMARCUS@GMAIL.COM', 'CTTMARCUS@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '569a2c49-45ac-454d-bf2c-1c677806f3fa', 0, 1, 1, 1, NULL, 0),
(1892, 'VINICIUSVGUEDES@GMAIL.COM', 'VINICIUSVGUEDES@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '4a8bce29-13e0-4f8c-bbd3-c0cbed9bb507', 0, 1, 1, 1, NULL, 0),
(1893, 'DANYZINHAX@GMAIL.COM', 'DANYZINHAX@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0cf7198a-f315-4006-9ff8-78f5602ae465', 0, 1, 1, 1, 513, 0),
(1894, 'FICHE DE BOUTEILLE PLASTIQUE', 'FICHEDEBOUTEILLE@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'fd09f87e-b5f0-4830-86cb-c2cc36e41ef0', 0, 1, 1, 1, NULL, 0),
(1895, 'DANTE. GIRARDI', 'DANTE.GIRARDI@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2e8c0849-be77-4d96-9383-cc694a7f6c20', 0, 1, 1, 1, NULL, 0),
(1896, 'CRISTIANO DEANGELIS', 'ANGELIS.CRISTIANO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5a4ae7f4-6e43-46c8-9e52-8b93effd9e83', 0, 1, 1, 1, 514, 0),
(1897, 'CRISTIANO DEANGELIS', 'ANGELISCRISTIANO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'eafcaf42-309e-47fd-87b8-6158a8f6cd42', 0, 1, 1, 1, 515, 0),
(1898, 'RAPHAEL.FARACO@RBSTV.COM.BR', 'RAPHAEL.FARACO@RBSTV.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '53ac572d-0aed-4575-aec1-298dfa613ba9', 0, 1, 1, 1, NULL, 0),
(1899, 'DJEFFERSON SILVA', 'DJEFFERSONX@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '377b000e-ee39-4654-bad4-72b861463a66', 0, 1, 1, 1, 516, 0),
(1900, 'LIANEBUENO@GMAIL.COM', 'LIANEBUENO@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '37258c97-ef1e-479c-be71-a1ccfef04bad', 0, 1, 1, 1, NULL, 0),
(1901, 'EDUHAWERROTH@GMAIL.COM', 'EDUHAWERROTH@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8b3289a5-2262-4705-b46a-366f8609b07d', 0, 1, 1, 1, NULL, 0),
(1902, 'MEGARON PERIN', 'MEGARONP@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '46e21b38-5171-4dfc-bffa-590be501468d', 0, 1, 1, 1, 517, 0),
(1903, 'CAMINOVINHASAFADA@HOTMAIL.COM', 'CAMINOVINHASAFADA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '709cae6e-4a66-4dbc-9d63-2a62f93a9717', 0, 1, 1, 1, NULL, 0),
(1904, 'RENANBINDA1@GMAIL.COM', 'RENANBINDA1@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '91ac4660-10e2-4925-bcb8-ec50af1e54a4', 0, 1, 1, 1, NULL, 0),
(1905, 'GEISON MACHADO', 'GEISONMCD@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '46c87d34-591f-427c-8121-0da9d55e910d', 0, 1, 1, 1, NULL, 0),
(1906, 'MARIAHNASCIMENTO@TERRA.COM.BR', 'MARIAHNASCIMENTO@TERRA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c1511d50-7702-4898-9e51-b1fcd9e81bc9', 0, 1, 1, 1, NULL, 0),
(1907, 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-01', '2d44d00b-ab5f-4857-889d-1b966e221d6d', 598.333, 2, 3, 4, 531, 0),
(1908, 'ANDREZA LOPES', 'ANDREZA@DELINEA.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-01', 'a2d65f15-6774-4c19-a7e3-1b82102a8006', 0, 1, 7, 1, 519, 0),
(1909, 'JEH___@HOTMAIL.COM', 'JEH___@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'cc72626d-5f5a-4d86-93e6-2dbf60eb5032', 0, 1, 1, 1, NULL, 0),
(1910, 'EXTENSÃO - UNIFEBE', 'EXTENSAO@UNIFEBE.EDU.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a245445d-7f69-44f3-a4d1-3c87b3cd4b9e', 0, 1, 1, 1, NULL, 0),
(1911, 'MAJURUIVA@HOTMAIL.COM', 'MAJURUIVA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '467b87ba-d610-4041-948d-da7d8381fa56', 0, 1, 1, 1, NULL, 0),
(1912, 'ELIZAROBOT@APPSPOT.COM', 'ELIZAROBOT@APPSPOT.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'c8423de3-228d-489e-8e14-0145d6290a9e', 0, 1, 1, 1, NULL, 0),
(1913, 'SERGIO COLLE', 'COLLE@EMC.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'a0a76142-0472-4772-b915-ca5c619c1309', 0, 1, 1, 1, NULL, 0),
(1914, 'EMACHADOPR@HOTMAIL.COM', 'EMACHADOPR@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '9c156c19-fa73-41fb-a83e-a8774e586e11', 0, 1, 1, 1, NULL, 0),
(1915, 'ADRIELLE .', 'ADRIELLEDUARTESILVA@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '8df727ff-a5cb-4565-a0d4-8c650001afde', 0, 1, 1, 1, NULL, 0),
(1916, 'CONTATO@LUCIOANODUQUE.COM.BR', 'CONTATO@LUCIOANODUQUE.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'abec5461-1436-455a-ae2a-cd760a3c8eee', 0, 1, 1, 1, NULL, 0),
(1917, 'DAILOR BORN', 'ROLIAD@MATRIX.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '2f31059f-e810-4b91-a794-e8479e739a5f', 0, 1, 1, 1, NULL, 0),
(1918, 'ROBERTLUIZVILVERT@HOTMAIL.COM', 'ROBERTLUIZVILVERT@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '5c45f1ef-8d55-46f2-81c2-99b78dd44d1b', 0, 1, 1, 1, NULL, 0),
(1919, 'WESMORETTO@HOTMAIL.COM', 'WESMORETTO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'b7a9acd0-5c14-4b3f-bc07-7c3ab905f0cb', 0, 1, 1, 1, NULL, 0),
(1920, 'ALINE@DEPS.UFSC.BR', 'ALINE@DEPS.UFSC.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '7f06f995-cbc8-4992-833c-195605e1ae53', 0, 1, 1, 1, NULL, 0),
(1921, 'CHARLESMTL@GMAIL.COM', 'CHARLESMTL@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '0ceaaa1d-2ed4-4983-bf4e-361e76fda336', 0, 1, 1, 1, NULL, 0),
(1922, 'WIENEKE NAU KROON', 'PASSARUMAPAGADORNOPASSADO@HOTMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '463862a4-9a58-4483-acf7-ab1d4fc49d51', 0, 1, 1, 1, NULL, 0),
(1923, 'ÉDIS MAFRA', 'EDISPANDION@GMAIL.COM', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', 'af625c66-b109-4983-b0aa-fe56594cac1b', 0, 1, 1, 1, NULL, 0),
(1924, 'KARINE QUINT', 'KARINE.QUIM@CEPUNET.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 0, 0, '2014-06-01', '92a98d77-8598-41e5-aa57-bd7ff6259de7', 0, 1, 1, 1, NULL, 0),
(1925, 'MARIO.MOTTA@HORASC.COM.BR', 'MARIO.MOTTA@HORASC.COM.BR', 'e10adc3949ba59abbe56e057f20f883e', 1, 1, '2014-06-01', '2abe63cf-83b6-4056-9946-8a7604cacd26', 0, 2, 7, 4, NULL, 0),
(2105, 'MALACMA', 'MALACMA@GMAIL.COM', '60e9a81299f4b1a2c744514ad0645cfe', 1, 1, '2010-01-01', '4103efb9-f23d-4665-a4fc-c290c1795bc1', 0, 1, 1, 1, 1, 0),
(2106, 'NOME', 'EMAIL@GMAIL.NET', 'ed2b1f468c5f915f3f1cf75d7068baae', 0, 0, '2014-06-12', 'wpUnvx0.9681714153848588', 0, 1, 1, 1, 1, 0),
(2107, 'NOME', 'EMAIL@NEGAO.COM.BR', '2aded67a70dc4694c360cc6f23d2bd3d', 0, 0, '2014-06-28', 'wpUnvx0.5215317886322737', 0, 1, 1, 1, 1, 0),
(2108, 'EMAIL@NEGAO.COM.BR', 'EMAIL@NEGAO.COM.BRA', '2aded67a70dc4694c360cc6f23d2bd3d', 0, 0, '2014-06-12', 'wpUnvx0.5218676833901554', 0, 1, 1, 1, 1, 0),
(2112, 'NOME', 'MAIL@MAIL.COM', 'd23336029a95dbd0f2cb6ab6ee3db4e2', 0, 0, '2014-06-06', 'wpUnvx0.34986555110663176', 0, 2, 1, 1, 1, 0),
(2129, 'BOMB', 'meme@nail.com', 'e373a9be7afbfa19aa17eaa54f19af88', 0, 0, '2014-06-09', 'e6b96caf-e992-411d-8382-f29122856714', 0, 2, 1, 7, 526, 0);
INSERT INTO `profile` (`id_user`, `name`, `email`, `passwd`, `online`, `avaliable`, `birthday`, `paypall_acc`, `credits`, `fk_id_role`, `nature`, `proficiency`, `avatar_idavatar`, `qualified`) VALUES
(2142, 'GEORGE', 'george.rm@hotmail.com', '75fceec028d4f1edcddd3fc0fd1181e8', 1, 1, '1982-11-03', '0f7a8dca-52cf-4cf1-b89c-6750b9bd7c10', 0, 1, 1, 1, 1, 0),
(2143, 'ARTHUR', 'artur@labirinto.com.br', 'd8578edf8458ce06fbc5bb76a58c5ca4', 1, 1, '0000-00-00', 'e2e245cc-4fb4-4726-8b41-f53afd19c1e8', 0, 1, 1, 1, 1, 0),
(2144, 'ARTHUR', 'asanders2@gmail.com', 'd8578edf8458ce06fbc5bb76a58c5ca4', 1, 1, '0000-00-00', '244a1324-3955-4e5f-a73e-c5b7ee49ad52', 0, 1, 1, 1, 1, 0),
(2145, 'USER1', 'user1@labirinto.com.br', '24c9e15e52afc47c225b757e7bee1f9d', 0, 0, '0000-00-00', '6a3210e9-df90-4cbe-821e-63b87e640a18', 0, 1, 1, 1, 1, 0),
(2146, 'USERT1', 'usert1@labirinto.com.br', '3a1dc8ce15b12c9733b6468cf3694ab2', 0, 0, '2014-07-14', 'eff28d3f-47be-4f23-975f-db8fd5c30c8a', 0, 2, 1, 2, 1, 0),
(2147, 'GUIME', 'jgoliveira78@gmail.com', 'ad477cae0be072d0a2a49ade6d09970d', 1, 1, '1977-12-28', '9e72fa93-8faf-4405-bcb2-991ffd9f241e', 0, 1, 1, 1, 1, 0),
(2148, 'TRADUTOR1', 'tradutor1@labirinto.com.br', '0a0affcee14062e476dfee3338cccdc4', 1, 1, '0000-00-00', '17a9ec65-ffa6-4ce8-a0a9-b9fa45f295ec', 0, 2, 1, 2, 1, 0),
(2149, 'TRADUTOR2', 'tradutor2@labirinto.com.br', '76d80224611fc919a5d54f0ff9fba446', 1, 1, '0000-00-00', 'cbfc8a86-26c3-4844-a806-8bd68c602e31', 0, 2, 1, 2, 1, 0);

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=71 ;

--
-- Extraindo dados da tabela `purchase`
--

INSERT INTO `purchase` (`id`, `invoice`, `trasaction_id`, `log_id`, `user_id`, `product_id`, `product_name`, `product_quantity`, `product_amount`, `payer_fname`, `payer_lname`, `payer_address`, `payer_city`, `payer_state`, `payer_zip`, `payer_country`, `payer_email`, `payment_status`, `posted_date`) VALUES
(35, '2116145762', '75G43751RJ068211Y', NULL, 300, '1', 'Babel2u Coins', '1', '20', 'CIRIO VIEIRA', 'CIRIO VIEIRA', 'Quadra 2 Conjunto A-6 Bloco 1/Sobradinho', 'BrasÃ­lia', 'Santa Catarina', '73015-132', 'BR', 'CV11491@TJ.SC.GOV.BR', 'Completed', '2014-06-04 21:17:12'),
(38, '1440247463', '1PU70975A6193332C', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', '', '', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Completed', '2014-06-07 14:40:35'),
(39, '1442348287', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-07 14:42:48'),
(40, '1713181958', '6MU16503JS914123X', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Completed', '2014-06-07 17:13:28'),
(41, '2017379205', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-07 20:17:56'),
(42, '1250463293', '', NULL, 1907, '1', 'Babel2u Coins', '1', '20', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-09 12:50:51'),
(43, '1257148789', '', NULL, 1907, '1', 'Babel2u Coins', '1', '100', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-09 12:57:23'),
(44, '1257148789', '', NULL, 1907, '1', 'Babel2u Coins', '1', '25', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-09 12:57:55'),
(45, '1257148789', '', NULL, 1907, '1', 'Babel2u Coins', '1', '25', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-09 12:58:38'),
(46, '1257148789', '', NULL, 1907, '1', 'Babel2u Coins', '1', '25', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-09 12:59:51'),
(47, '1257148789', '', NULL, 1907, '1', 'Babel2u Coins', '1', '25', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-09 13:00:03'),
(48, '1257148789', '', NULL, 1907, '1', 'Babel2u Coins', '1', '25', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-09 13:00:16'),
(49, '1257148789', '', NULL, 1907, '1', 'Babel2u Coins', '1', '25', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-09 13:00:52'),
(50, '1954421522', '', NULL, 251, '1', 'Babel2u Coins', '1', '10', 'ALEXANDRE PY', 'ALEXANDRE PY', '', '', 'Santa Catarina', '88020100', 'BR', 'ALEXANDREPY@GMAIL.COM', 'pending', '2014-06-09 16:55:05'),
(51, '1931496807', '', NULL, 1907, '1', 'Babel2u Coins', '1', '20', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'IjuÃ­', '', '98700000', '', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-10 19:32:16'),
(52, '2123121570', '', NULL, 2145, '1', 'Babel2u Coins', '1', '20', 'USER1', 'USER1', 'Rua francisco goulart 96,405', 'florianopolis', 'Santa Catarina', '88036600', 'BR', 'user1@labirinto.com.br', 'pending', '2014-06-14 21:25:15'),
(53, '1526396363', '', NULL, 1907, '1', 'Babel2u Coins', '1', '20', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-16 15:26:45'),
(54, '1526396363', '', NULL, 1907, '1', 'Babel2u Coins', '1', '20', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-16 15:50:55'),
(55, '1716562752', '', NULL, 1907, '1', 'Babel2u Coins', '1', '15', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-16 17:17:03'),
(56, '1716562752', '', NULL, 1907, '1', 'Babel2u Coins', '1', '5', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-16 17:18:37'),
(57, '1728518556', '', NULL, 1907, '1', 'Babel2u Coins', '1', '5', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-16 17:29:00'),
(58, '2044313689', '', NULL, 1907, '1', 'Babel2u Coins', '1', '20', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-16 20:44:51'),
(59, '2046175370', '', NULL, 1907, '1', 'Babel2u Coins', '1', '20', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'IjuÃ­', 'Santa Catarina', '98700000', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-16 20:46:50'),
(60, '2054464894', '', NULL, 1907, '1', 'Babel2u Coins', '1', '20', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-16 20:54:51'),
(61, '2055152327', '', NULL, 2147, '1', 'Babel2u Coins', '1', '5', 'GUIME', 'GUIME', 'antonio da silveira, 225', 'FlorianÃ³polis', 'Santa Catarina', '88062155', 'BR', 'jgoliveira78@gmail.com', 'pending', '2014-06-18 20:56:41'),
(62, '0443454750', '', NULL, 1907, '1', 'Babel2u Coins', '1', '20', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'IjuÃ­', '', '98700000', 'EU', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-23 04:44:01'),
(63, '2238588268', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-23 22:39:08'),
(64, '2238588268', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-23 22:39:44'),
(65, '2238588268', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-23 22:40:09'),
(66, '2238588268', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-23 22:40:36'),
(67, '2238588268', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-23 23:51:31'),
(68, '2238588268', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', '/', 'IjuÃ­', 'Santa Catarina', '98700000', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-23 23:52:13'),
(69, '2238588268', '', NULL, 1907, '1', 'Babel2u Coins', '1', '200', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', '/', 'IjuÃ­', 'Santa Catarina', '98700000', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-23 23:52:43'),
(70, '0006335677', '', NULL, 1907, '1', 'Babel2u Coins', '1', '1000', 'MARCELO.LEANDRO@UNIVILLE.BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'Rua General Bittencourt/Centro', 'FlorianÃ³polis', 'Santa Catarina', '88020100', 'BR', 'MARCELO.LEANDRO@UNIVILLE.BR', 'pending', '2014-06-24 00:06:41');

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
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=31 ;

--
-- Extraindo dados da tabela `sip_user`
--

INSERT INTO `sip_user` (`idsip_user`, `user`, `pass`, `profile_id_user`, `sip_server_idsip_server`) VALUES
(0, 'user_pt_bt', 'user_pt_bt', NULL, 1),
(1, 'Univoxer3', 'Univoxer3', NULL, 1),
(2, 'Univoxer2', 'Univoxer2', NULL, 1),
(3, 'Univoxer1', 'Univoxer1', NULL, 1),
(4, 'Univoxer4', 'Univoxer4', NULL, 1),
(6, 'translator_pt_en', 'translator_pt_en', NULL, 1),
(7, 'ekooossss', 'ekooossss', NULL, 1),
(8, 'Univoxer5', 'Univoxer5', NULL, 1),
(11, 'Univoxer6', 'Univoxer6', NULL, 1),
(13, 'Univoxer7', 'Univoxer7', NULL, 1),
(14, 'univoxer8', 'univoxer8', NULL, 1),
(15, 'univoxer9', 'univoxer9', NULL, 1),
(16, 'univoxera', 'univoxera', NULL, 1),
(17, 'univoxerb', 'univoxerb', NULL, 1),
(18, 'univoxer1b', 'univoxer1b', NULL, 1),
(19, 'univoxer1c', 'univoxer1c', NULL, 1),
(20, 'univoxer1d', 'univoxer1d', NULL, 1),
(21, 'univoxer1e', 'univoxer1e', NULL, 1),
(22, 'univoxer1f', 'univoxer1f', NULL, 1),
(23, 'univoxer1g', 'univoxer1g', NULL, 1),
(24, 'univoxer1h', 'univoxer1h', NULL, 1),
(25, 'univoxerk1', 'univoxerk1', NULL, 1),
(26, 'univoxerk2', 'univoxerk2', NULL, 1),
(27, 'univoxerk3', 'univoxerk3', NULL, 1),
(28, 'univoxerk4', 'univoxerk4', NULL, 1),
(29, 'univoxerk5', 'univoxerk5', NULL, 1),
(30, 'univoxerk6', 'univoxerk6', NULL, 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_call_info`
--
DROP VIEW IF EXISTS `view_call_info`;
CREATE TABLE IF NOT EXISTS `view_call_info` (
`token` varchar(220)
,`end_t` timestamp
,`start_t` timestamp
,`id_from` bigint(11)
,`id_to` bigint(11)
,`credits_user` double
,`credits_translator` double
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_find_away`
--
DROP VIEW IF EXISTS `view_find_away`;
CREATE TABLE IF NOT EXISTS `view_find_away` (
`id_user` int(11)
,`idlog` int(11)
,`date` timestamp
,`agora` datetime
,`awayTime` double(17,0)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_paypall`
--
DROP VIEW IF EXISTS `view_paypall`;
CREATE TABLE IF NOT EXISTS `view_paypall` (
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
,`payer_address` varchar(300)
,`payer_city` varchar(300)
,`payer_state` varchar(300)
,`payer_zip` varchar(300)
,`payer_country` varchar(300)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_profile`
--
DROP VIEW IF EXISTS `view_profile`;
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
DROP VIEW IF EXISTS `view_profile_by_last_ip`;
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
DROP VIEW IF EXISTS `view_profile_count`;
CREATE TABLE IF NOT EXISTS `view_profile_count` (
`passwd` varchar(240)
,`total` bigint(21)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `view_profile_sip_acc`
--
DROP VIEW IF EXISTS `view_profile_sip_acc`;
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
DROP VIEW IF EXISTS `view_profile_tomaps`;
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

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_call_info` AS select `a`.`token` AS `token`,`a`.`end_t` AS `end_t`,`a`.`start_t` AS `start_t`,(select `c`.`id_user` from `profile` `c` where (`c`.`id_user` = `a`.`from_c`)) AS `id_from`,(select `c`.`id_user` from `profile` `c` where (`c`.`id_user` = `a`.`to_c`)) AS `id_to`,(select `c`.`credits` from `profile` `c` where (`c`.`id_user` = `a`.`from_c`)) AS `credits_user`,(select `c`.`credits` from `profile` `c` where (`c`.`id_user` = `a`.`to_c`)) AS `credits_translator` from `call` `a`;

-- --------------------------------------------------------

--
-- Structure for view `view_find_away`
--
DROP TABLE IF EXISTS `view_find_away`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_find_away` AS select `log`.`id_user` AS `id_user`,`log`.`idlog` AS `idlog`,`log`.`date` AS `date`,now() AS `agora`,(date_format(now(),'%Y%m%e%I%i%s') - date_format(`log`.`date`,'%Y%m%e%I%i%s')) AS `awayTime` from `log` order by `log`.`date` desc WITH CASCADED CHECK OPTION;

-- --------------------------------------------------------

--
-- Structure for view `view_paypall`
--
DROP TABLE IF EXISTS `view_paypall`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_paypall` AS select `a1`.`id_user` AS `id_user`,`a1`.`name` AS `name`,`a1`.`email` AS `email`,`a1`.`passwd` AS `passwd`,`a1`.`online` AS `online`,`a1`.`avaliable` AS `avaliable`,`a1`.`birthday` AS `birthday`,`a1`.`paypall_acc` AS `paypall_acc`,`a1`.`credits` AS `credits`,`a1`.`fk_id_role` AS `fk_id_role`,`a1`.`nature` AS `nature`,`a1`.`proficiency` AS `proficiency`,`a1`.`avatar_idavatar` AS `avatar_idavatar`,`a1`.`qualified` AS `qualified`,`a2`.`payer_address` AS `payer_address`,`a2`.`payer_city` AS `payer_city`,`a2`.`payer_state` AS `payer_state`,`a2`.`payer_zip` AS `payer_zip`,`a2`.`payer_country` AS `payer_country` from (`profile` `a1` left join `purchase` `a2` on((`a1`.`id_user` = `a2`.`user_id`)));

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
