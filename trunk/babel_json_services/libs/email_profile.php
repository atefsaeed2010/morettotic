
<?php

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * CHANGE PASSWORD
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * @data 4/06/2014
 * 
 * 
  ;# 1 linha(s) afetadas.


  update profile set avatar_idavatar = (select idavatar from avatar where image_path = 'tttttt') where id_user = 1;# 1 linha(s) afetadas.

 * 
 * */
include_once 'db_vars.config.php';

$email = $_GET['email'];
$newpasswd = "Un1_" . date("His") . rand(1234, 9632) . "_V0X";
$md5PassWd = md5($newpasswd);

//Atualiza senha 
$query = " SELECT `fn_change_pass`('$email', '$md5PassWd') AS `fn_change_pass`;";
$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);

//Loga a operação
$ip = getRemoteIp();
$query = "INSERT INTO `log`(`ip`, `date`, `id_user`, `optype`) VALUES ('$ip',now(),(select id_user from profile where email = '$email') ,'password')";
$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);

//Mensagem de email confirmando
//$title = "UNIVOXER - PASSWORD CHANGE ($md5PassWd)";

$message = 'Password change (UNIVOXER Coins)';
$message.= '\n';
$message.= 'New Password :' . $newpasswd;
$message.= '\n';
$message.= 'Date:' . date("d-m-y");
$message.= '\n';
$message.= 'Thank you. Enjoy it';
$message.= '\n';
$message.= 'If you arent the owner of this message please ignore it.';
//echo $query;
//mail(
//mail(, "BABEL2u Coins", $message.' '.$saida, "From: " . $paypalReturn->payer_email . "\n");
$email_headers = implode("\n", 
        array(  "From: univoxer@nosnaldeia.com.br", 
                "Reply-To: univoxer@nosnaldeia.com.br", 
                "Subject: UNIVOXER - PASSWORD CHANGE", 
                "Return-Path:  univoxer@nosnaldeia.com.br", 
                "MIME-Version: 1.0", "X-Priority: 3", 
                "Content-Type: text/html; charset=UTF-8"));
//====================================================
//Enviando o email
//====================================================
mail($email, "UNIVOXER - PASSWORD CHANGE", $message);
if (mail($email, "UNIVOXER - PASSWORD CHANGE", nl2br($message), $email_headers)) {
    echo "EMAIL OK";
}


//var_dump($mail);
//var_dump($row);

mysql_close($con);

echo "<a href='http://univoxer.com/'>http://univoxer.com/</a>";

/* Make sure that code below does not get executed when we redirect. */
exit;
?>
