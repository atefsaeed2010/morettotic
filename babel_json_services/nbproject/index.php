<!DOCTYPE html>
<!--
To change this license header, choose License Headers in Project Properties.
To change this template file, choose Tools | Templates
and open the template in the editor.
-->

<?php
include './libs/conn.php';//Connection
$login = $_GET['login'];
$pass = $_GET['passwd'];

loginBabel($login ,$pass);
?>
    