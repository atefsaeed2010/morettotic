<?php

/**
 * http://www.nosnaldeia.com.br/babel_json_services/?action=SAVE_PROFILE&id_user=69&email=super@mail.com&passwd=123456&name=USUARIO%20SUPER%201&birthday=2010-01-01&paypall_acc=zxcvbasdAAA&nature=PT&proficiency=PT&id_role=1&passwd=123456
 * MAIN BABEL JSON SERVICES
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * SAVES OR UPDATES A PROFILE
 * 
 * @data 11/03/2014
 * 
 **/
include 'db_vars.config.php';

//init vars
$id = $_GET['id_user'];
$email = $_GET['email'];
$name = $_GET['name'];
$birth = $_GET['birthday'];
$paypall = $_GET['paypall_acc'];
$natureP = $_GET['nature'];
$proficiencyP = $_GET['proficiency'];
$avatar = $_GET['avatar'];
$role = $_GET['id_role'];
$passwd = $_GET['passwd'];

//Acha a pk da lingua de proficiencia
$query = "SELECT id_lang FROM language WHERE token =  '$proficiencyP'";

//echo $query;

$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);
$proficiency = $row['id_lang'];

//Acha a pk da lingua nativa
/*$query = "SELECT id_lang FROM language WHERE token =  '$natureP'";
$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);
$nature = $row['id_lang'];*/

$mensagem = "";
$query = "";
$isNew = false;
//INSERT A NEW PROFILE
if ($id == "-1" || $id == "") {

    $query = "INSERT INTO  profile (
                name ,
                email ,
                passwd ,
                online ,
                avaliable ,
                birthday ,
                paypall_acc ,
                credits ,
                fk_id_role ,
                nature ,
                proficiency ,
                avatar_idavatar
        )
        VALUES (
                '" . $name . "',  
                '" . $email . "',  
                '" . md5($passwd) . "',  
                'true',  
                'true',  
                '" . $birth . "',  
                '" . $paypall . "',  
                '0',  
                '" . $role . "',  
                '" . $natureP . "', 
                '" . $proficiency . "' ,  
                '1')";
    $mensagem = "Saved";
    $isNew = true;
} else {//UPDATE A PROFILE @todo Update Passwd
    $query = " UPDATE  "
            . "     profile "
            . "SET  "
            . "     paypall_acc =  '$paypall' ,"
            //. "     passwd =  '".md5($passwd)."' ,"//Password nao e atualizado. Deve entrar no site ou opcao e menu
            . "     name =  '$name' ,"
            . "     nature =  '$natureP' ,"
            . "     fk_id_role =  '$role' ,"
            . "     proficiency =  '$proficiency',"
            . "     birthday = '$birth' "
            . " WHERE "
            . "id_user = " . $id;
     $mensagem = "Updated";
}
//echo $query;
//Insere ou atualiza o usuario / tradutor
$result = mysqli_query($con, $query);

//Novo usuario. 
//Vincula a conta sip
//Pega uma conta no banco de dados cadastrada previamente e associa com o usuario
if($isNew){
    $query = "SELECT idsip_user FROM sip_user WHERE profile_id_user IS NULL  LIMIT 1";
    //Executa a consulta 
    $result = mysqli_query($con, $query);
    $row = mysqli_fetch_array($result);
    $idSipAcc = $row['idsip_user'];
    //Consulta id usuario para atualiza o sip acc
    $query = "SELECT id_user from profile where email = '" . $email . "' and passwd = '" . md5($passwd) . "'";
    $result = mysqli_query($con, $query);
    $row = mysqli_fetch_array($result);
    $idUserP = $row['id_user'];
    //Atualiza o sip user com o novo profile
    $query = "update sip_user set profile_id_user = $idUserP where idsip_user = $idSipAcc";
    $result = mysqli_query($con, $query);
}


//Vincula a conta SIP a

//Objeto default para imprimir o json
include 'json_profile.php';
?>