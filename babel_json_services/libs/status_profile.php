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
/* @var $_GET type */
$online = $_GET['online'];

$query = null;
//Default offline
if($online=="ON"){
    $query = " SELECT fn_online($id) AS fn_status";
}else{
    $query = " SELECT fn_offline($id) AS fn_status";
}

//echo $query;

$result = mysqli_query($con, $query);

//var_dump($result);

$row = mysqli_fetch_array($result);

mysqli_close($con);

?>