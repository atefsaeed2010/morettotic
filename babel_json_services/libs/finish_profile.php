<?php

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * FINISH A CALL AND UPDATES A CALL HISTORY. 
 * 
 * @TODO Also calculates Translator and CLient Credits!!!!!!
 * 
 * @data 11/03/2014
 * 
 * */
include 'db_vars.config.php';

//init vars
$token = $_GET['token'];
$date = new DateTime();
$timestamp = $date->getTimestamp();
$mensagem = "FINISH CONF";

//Finish time from call
$end_time = gmdate("Y-m-d H:i:s", $timestamp);

//Update a call set finish time
$query = "UPDATE  `call` SET  `end_t` =  '$end_time' WHERE  token = '$token'";
$result = mysqli_query($con, $query);

/**
 * UPDATE USER AND TRANSLATOR CREDITS ON SYSTEM
 */
$query = "SELECT end_t,start_t,
            ((select id_user from profile as c where c.id_user = a.from_c)) as id_from,
            ((select id_user from profile as c where c.id_user = a.to_c)) as id_to,
            ((select credits from profile as c where c.id_user = a.from_c)) as credits_user,
            ((select credits from profile as c where c.id_user = a.to_c)) as credits_translator
        FROM `call` as a WHERE token = '$token'";

$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);

$id = $row['id_from'];
$id_translator = $row['id_to'];
$start_time = $row['start_t'];
$credits_user = $row['credits_user'];
$credits_translator = $row['credits_translator'];

//*************************************
//Update currency
//*************************************

$start_date = new DateTime($start_time, new DateTimeZone('Pacific/Nauru'));
$end_date = new DateTime($end_time, new DateTimeZone('Pacific/Nauru'));

$interval = $start_date->diff($end_date);
$hours = $interval->format('%h');
$minutes = $interval->format('%i');

$credits = ($minutes);
$credits_user-=$credits;
$credits_translator+=$credits;

$query = "update profile set credits='$credits_translator', online=true,avaliable=true where id_user=" . $id_translator;
$result = mysqli_query($con, $query);
$query = "update profile set credits='$credits_user', online=true,avaliable=true where id_user=" . $id;
$result = mysqli_query($con, $query);

//*************************************
//JSON DATA
//*************************************
$profile->call_start = $start_time;
$profile->call_finish = $end_time;
$profile->credits_user = $credits_user;
$profile->credits_translator = $credits_translator;
$profile->call_token = $token;
$profile->credits = $credits;
$profile->id_translator = $id_translator;

include 'json_profile.php';
?>
