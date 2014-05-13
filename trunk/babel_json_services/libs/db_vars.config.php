<?php

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
$database = "173.248.156.2"; //"mysql.nosnaldeia.com.br";
$db_user = "seenergi_babel";
$db_pass = "1qaz2wsx";
$db = "seenergi_babel"; //"nosnaldeia01";

$IMAGE_PATH = "http://www.seenergia.com.br/babel_json_services/libs/avatars/";

//Conexao global
$con = mysqli_connect($database, $db_user, $db_pass, $db);
// Check connection
if (mysqli_connect_errno()) {
    echo "Erro ao conectar ao mysql: " . mysqli_connect_error();
}

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
    $result = @json_decode(file_get_contents("http://www.geoplugin.net/json.gp?ip=" . $ip));
    //var_dump($result);
    return $result <> NULL ? $result : "Unknown";
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
