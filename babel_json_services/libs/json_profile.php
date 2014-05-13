<?php

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * PRINTS JSON FOR ALL CALLBACK
 * 
 * @data 11/03/2014
 * 
 * */
$query = '';
if (isset($id) && $id != "-1") {//modo edicao
    $query = "SELECT * FROM `view_profile` WHERE id_user ='$id'";
    $query1 = "update profile set online = true, avaliable = true WHERE id_user ='$id'";
    $result = mysqli_query($con, $query1);
    $row = mysqli_fetch_array($result);
    $query1 = null;
} else {
    $query = "select passwd, count(*) as total from profile where email = '$email'";
    $result = mysqli_query($con, $query);
    $row = mysqli_fetch_array($result);
    //Verificar se o email existe e a senha nao confere....
    if ($row['passwd'] != md5($passwd) && $row['total'] != '0') {
        $profile->passWdError = 'Username or password dont match!';
    } else {
        $mensagem = "newuser";
    }
    //Recupera o usuario pelo email e senha
    $query = "SELECT * FROM `view_profile` WHERE email ='" . $email . "' AND passwd ='" . md5($passwd) . "'";
}

//echo $query;
$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);

//JSON PROFILE ATTRS
$profile->id_user = $row['id_user'] == null ? "-1" : $row['id_user'];
$profile->name = $row['name'] == null ? "" : $row['name'];
$profile->email = $row['email'] == null ? $email : $row['email'];
$profile->birthday = $row['birthday'] == null ? "" : $row['birthday'];
$profile->paypall_acc = $row['paypall_acc'] == null ? '' : $row['paypall_acc'];
$profile->credits = (isset($profile->credits) ? $profile->credits : ($row['credits'] == null ? "0" : $row['credits']));
$profile->nature = (isset($nature) ? $nature : ($row['nature'] == null ? "1" : $row['nature'])); //Lungua default portugues
$profile->proficiency = $row['proficiency'] == null ? "null" : $row['proficiency'];
$profile->serverName = $row['servername'] == null ? "ekiga.net" : $row['servername'];
$profile->user = $row['user'] == null ? "trandutoringles" : $row['user'];
$profile->pass = $row['pass'] == null ? "translate1" : $row['pass'];
$profile->role = $row['fk_id_role'] == null ? "1" : $row['fk_id_role'];
$profile->message = $mensagem;

//Encode to JSON
//print_r($profile);

echo json_encode($profile);

mysqli_close($con);
?>