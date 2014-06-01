<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


$cep = $_GET['cep'];
$url = "http://apps.widenet.com.br/busca-cep/api/cep/".$cep.".json";
echo file_get_contents($url);
?>
