<?php
include_once 'webservice.php';

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * DATABASE CONNECTION AND CONFIG HERE
 * 
 * @author Malacma <malacma@gmail.com>
 * 874u425
 * @data 11/03/2014
 * 
 * */
//parametros do banco
$database = "173.248.156.2"; //"mysql.nosnaldeia.com.br";
$db_user = "seenergi_babel";
$db_pass = "1qaz2wsx";
$db = "seenergi_babel"; //"nosnaldeia01";
//
//Parametros do sistema
$IMAGE_PATH = "http://www.nosnaldeia.com.br/babel_json_services/libs/avatars/";

$mensagem = "WARNING: MENSAGEM NAO INFORMADA !";


//Conexao global
$con = mysqli_connect($database, $db_user, $db_pass, $db);
// Check connection
if (mysqli_connect_errno()) {
    echo "Erro ao conectar ao mysql: " . mysqli_connect_error();
}
mysql_query("SET NAMES 'utf8'");
mysql_query('SET character_set_connection=utf8');
mysql_query('SET character_set_client=utf8');
mysql_query('SET character_set_results=utf8');

/**
  Global std object to create json data to response
 *  */
$profile = new stdClass();

//
function isActive() {
    $isEnabled = isset($_SESSION["BABELON"]) ? $_SESSION["BABELON"] : false;
}

function visitor_country() {
    $ip = getRemoteIp();
    $ws = new WebService();
    return $ws->geGeoLocationInfoJSON($ip);    
}

function getRemoteIp() {
    $ip = $_SERVER["REMOTE_ADDR"];
    
    if (filter_var(@$_SERVER['HTTP_X_FORWARDED_FOR'], FILTER_VALIDATE_IP))
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    
    if (filter_var(@$_SERVER['HTTP_CLIENT_IP'], FILTER_VALIDATE_IP))
        $ip = $_SERVER['HTTP_CLIENT_IP'];
    
    return $ip;
}

?>
