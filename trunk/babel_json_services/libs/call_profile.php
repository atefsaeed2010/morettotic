<?php

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * CALL A TRANSLATOR AVALIABLE HERE
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * @data 11/03/2014
 * 
 * */
include 'db_vars.config.php';

$id = $_GET['id_user'];
$nature = $_GET['nature'];
$proficiency = $_GET['proficiency'];
$id_service_type = $_GET['id_service_type'];

//Already has loggedin

/**
 * 
 *  SELECTS TRANSLATOR AVALIABLE AND ONLINE FOR A GIVEN LANGUAGE
 * 
 *  */
$query = "SELECT 
                id_user, 
                name,
                b.user,
                b.pass,
                c.servername,
                email,
                passwd
            FROM 
                profile AS a 
            left join 
                sip_user AS b on a.id_user = b.profile_id_user 
            left join 
                sip_server as c on b.sip_server_idsip_server = c.idsip_server 
            where 
                a.fk_id_role = 2
                and avaliable = 1
                and (nature = $nature or nature = $proficiency) 
                and (proficiency = $nature or proficiency = $proficiency)
		and id_user<>$id";

//echo $query;

$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);




//Init values
$date = new DateTime();
$timestamp = $date->getTimestamp();
$token = md5(uniqid(rand(), true));
$mensagem = "CONFERENCE";
$email = $row['email'];
$passwd = $row['passwd'];

//Set profile json object attrs
$profile->id_translator = $row['id_user'];
$profile->translator_name = $row['name'];
$profile->sip_user_t = $row['user'];
$profile->sip_pass_t = $row['pass'];
$profile->servername = $row['servername'];
$profile->start_t = $date->getTimestamp();
$profile->call_token = $token;

/**
 * 
 *  SAVE CALL INFO WITH A UNIQUE TOKEN
 * 
 *  */
//if ($profile->sip_user_t != null) {

    $query = "SELECT fn_get_avatar('" . $profile->id_translator . "') AS fn_get_avatar";
    $result = mysqli_query($con, $query);
    $row = mysqli_fetch_array($result);
    $profile->translator_avatar = $row['fn_get_avatar'];

    $query = "SELECT fn_get_avatar('" . $id . "') AS fn_get_avatar";
    $result = mysqli_query($con, $query);
    $row = mysqli_fetch_array($result);
    $profile->user_avatar = $row['fn_get_avatar'];

    $query = "INSERT INTO `call` ("
            . " `id_call`, "
            . " `start_t`, "
            . " `end_t`, "
            . " `from_c`, "
            . " `to_c`, "
            . " `service_type_idservice_type`, "
            . " `token`) "
            . "VALUES (NULL, '" . gmdate("Y-m-d\TH:i:s\Z", $timestamp) . "', '" . gmdate("Y-m-d\TH:i:s\Z", $timestamp) . "', '$id', '" . $profile->id_translator . "', '$id_service_type', '$token');";
//Insert call info
    $result = mysqli_query($con, $query);
//echo $query;
//var_dump($result);
//Update User and translator status
    $query = "update profile set online = 1 and avaliable = false where id_user=" . $row['id_user'];
    $result = mysqli_query($con, $query);
    $query = "update profile set online = 1 and avaliable = false where id_user=" . $id;
    $result = mysqli_query($con, $query);
//}
//Show Call json object
include 'json_profile.php';
?>