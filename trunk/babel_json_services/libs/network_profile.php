<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 * 
 * ?SERIAL=89550440000343042053&COUNTRY=BR&GOOGLE=malacma@gmail.com&MICROSOFT=malacma@hotmail.com&SKYPE=luisaugustomachadomoretto&FACEBOOK=malacma@hotmail.com&WHATSAPP=WhatsApp&VIBER=+554896004929&LINKEDIN=malacma@gmail.com
 */

include_once 'db_vars.config.php';

//init vars
$facebook = $_GET['FACEBOOK'];
$country = $_GET['COUNTRY'];
$whatsapp = $_GET['WHATSAPP'];
$skype = $_GET['SKYPE'];
$linkedin = $_GET['LINKEDIN'];
$microsoft = $_GET['MICROSOFT'];
$serial = $_GET['SERIAL'];
$google = $_GET['GOOGLE'];
$viber = $_GET['VIBER'];

//Acha a pk da lingua de proficiencia
$query = "  INSERT INTO network(facebook, country, whatsapp, viber, skype, linkedin, microsoft, serial, google)"
        . "        VALUES ('$facebook','$country','$whatsapp','$viber','$skype','$linkedin','$microsoft','$serial','$google')";
$result = mysqli_query($con, $query);

var_dump($result);

mysql_close($con);

?>

