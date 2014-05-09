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
 **/
include_once 'db_vars.config.php';

//Recupera parametros
$email = $_GET['login'];
$passwd = $_GET['passwd'];
$proficiency = $_GET['proficiency'];

$mensagem = "Login";

//Acha a pk da lingua
$query = "SELECT id_lang FROM language WHERE token =  '$proficiency'";
$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);

//echo $query;

$nature = $row['id_lang'];

//Atualiza o perfil para o status online e disponivel quando loga no sistema atualiza a lingua nativa tb
$query =  " update profile set avaliable = true, "
        . "                 online =true "
        //. "                 nature = ".$nature
        . " where "
        . "                 email = '$email' ";
        //. "                 and passwd = '".md5($passwd)."'";

//echo $query;

$result = mysqli_query($con, $query);

//Cria a session do ususario
if($result){
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