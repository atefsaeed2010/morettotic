
<?php

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * PROFILE EVALUATION
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * @data 25/03/2014
 * 
 * 
  ;# 1 linha(s) afetadas.


  update profile set avatar_idavatar = (select idavatar from avatar where image_path = 'tttttt') where id_user = 1;# 1 linha(s) afetadas.

 * 
 * */
include_once 'db_vars.config.php';

$id_user = $_GET['id_user'];
$id_trans = $_GET['id_trans'];
$rate = $_GET['rate'];

//Insere a nova imagem no banco usando a funcao no mysql 
$query = " SELECT `fn_rate_translator`($id_user, $id_trans, $rate) AS `fn_rate_translator`;";
$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);
mysql_close($con);
?>
