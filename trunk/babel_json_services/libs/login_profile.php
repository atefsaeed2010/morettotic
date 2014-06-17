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
$email = $_GET['login'];
$passwd = $_GET['passwd'];
$proficiency = $_GET['proficiency'];

$mensagem = "Login";

//Atualiza o perfil para o status online e disponivel quando loga no sistema atualiza a lingua nativa tb
$ip = getRemoteIp();

$query = " SELECT `fn_login`('$ip', '$email','$proficiency') AS `fn_login`";

//echo $query;

$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);
$nature = $row['fn_login'];

//Cria a session do ususario
if ($result) {
    session_start();
    $_SESSION["BABELON"] = true;
    $_SESSION["NATURE"] = $nature;
    $_SESSION["EMAIL"] = $email;
    $_SESSION["PASSWD"] = md5($passwd);
}
//
//Atualiza conta sip
$query = " select id_user from profile where email like '%$email%'";
$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);
$myId = $row['id_user'];

//Remove contas e atualiza sip user do pool
$query = "SELECT `fn_update_sip`($myId) AS `fn_update_sip`";
$result = mysqli_query($con, $query);

//Objeto default para imprimir o json
include 'json_profile.php';
//var_dump($profile);
?>