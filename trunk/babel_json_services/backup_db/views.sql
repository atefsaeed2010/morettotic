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
-- Stand-in structure for view `view_profile_count`
--
CREATE TABLE IF NOT EXISTS `view_profile_count` (
`passwd` varchar(240)
,`total` bigint(21)
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
-- Structure for view `view_profile_count`
--
DROP TABLE IF EXISTS `view_profile_count`;

CREATE ALGORITHM=UNDEFINED DEFINER=`seenergi`@`localhost` SQL SECURITY DEFINER VIEW `view_profile_count` AS select `profile`.`passwd` AS `passwd`,count(0) AS `total` from `profile`;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
