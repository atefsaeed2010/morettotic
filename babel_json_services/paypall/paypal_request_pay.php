<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


$tot = "NAO ENCONTRADO";
if (isset($_GET['email'])) {
    
    $my_file = 'paypall/request.pay';
    
    $handle = fopen($my_file, 'a+') or die('Cannot open file:  ' . $my_file);
    
    $data = fread($handle, filesize($my_file));
    
    //$handle = fopen($my_file, 'r+') or die('Cannot open file:  ' . $my_file);
    
    $p12.= 'ø' . $_GET['email'];
    
    fwrite($handle, $p12);
    fclose($handle);
    
    
    //echo $data;
    $v = explode("ø", $data);
    //var_dump($v);
    
    $tot = count($v);
    
} 

echo "Solicitação processada Em breve você receberá um email com maiores instruções.<br>Posição na fila de processamento:$tot";
?>
