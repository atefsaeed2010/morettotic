<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
$con = mysql_connect('mysql.nosnaldeia.com.br', 'nosnaldeia01', '666171');
if (!$con) {
   die('Não conseguiu conectar: ' . mysql_error());
}

// seleciona o banco nosnaldeia01
$db = mysql_select_db('nosnaldeia01', $con);
if (!$db) {
   die ('Não pode selecionar o banco nosnaldeia01 : ' . mysql_error());
}
//Login returns a json object from profile
function loginBabel($login,$pass){
    //die("SELECT * FROM profile WHERE email =  '".$login."'  AND passwd =  '".$pass."'");
    $result = mysql_query($con,"SELECT * FROM profile WHERE email =  '".$login."'.com' AND passwd =  '".$pass."'");
    while($row = mysql_fetch_array($result)){
        var_dump($row);
    }
}
?>

