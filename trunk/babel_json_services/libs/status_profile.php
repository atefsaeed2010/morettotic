<?php

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * LOGIN LOL
 * 
 * @data 11/03/2014
 * http://nosnaldeia.com.br/babel_json_services/?login=super@gmail.com&passwd=123456&proficiency=FR
 * */
include_once 'db_vars.config.php';

//Recupera parametros

$id = $_GET['id_user'];
$online = $_GET['online'];

$query = null;

//Default offline
if($online=="ON"){
    $query = " SELECT fn_online($id) AS fn_status";
}else{
    $query = " SELECT fn_offline($id) AS fn_status";
}

$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);

//Libera a conta sip do server
if($online=="EXIT"){
    $query = "UPDATE `sip_user` SET `profile_id_user`=null WHERE `profile_id_user` = $id";
    echo $query;
}
$result = mysqli_query($con, $query);
var_dump($result);

//fecha conn
mysqli_close($con);

?>