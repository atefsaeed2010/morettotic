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
$ip = $_SERVER["REMOTE_ADDR"];
if (filter_var(@$_SERVER['HTTP_X_FORWARDED_FOR'], FILTER_VALIDATE_IP))
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
if (filter_var(@$_SERVER['HTTP_CLIENT_IP'], FILTER_VALIDATE_IP))
    $ip = $_SERVER['HTTP_CLIENT_IP'];

$query = " SELECT `fn_login`('$ip', '$email','$proficiency') AS `fn_login`";
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

//Objeto default para imprimir o json
include 'json_profile.php';
//var_dump($profile);
?>