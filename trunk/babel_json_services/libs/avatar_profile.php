<?php

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * SHOWS AVATAR IMAGE
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
include 'db_vars.config.php';

$id_user = $_GET['id_user'];
//Declara o id para o jsonobject
$id = $_GET['id_user'];
$image_path1 = $_GET['image_path'];

if (!empty($id_user)) {
    //Insere a nova imagem no banco 
    $query = "insert into avatar (image_path) values ('$image_path1')";
    $result = mysqli_query($con, $query);
    $row = mysqli_fetch_array($result);
    //Atualiza o profile para a nova imagem
    $query = "update profile"
            . " set avatar_idavatar = (select idavatar from avatar where image_path = '$image_path1' order by idavatar desc limit 1) where id_user = $id_user";
    
    //echo $query;
    
    $result = mysqli_query($con, $query);
    $row = mysqli_fetch_array($result);
    //var_dump($row);
}

include 'json_profile.php';

?>
