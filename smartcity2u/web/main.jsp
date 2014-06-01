<%-- 
    Document   : newjsp
    Created on : May 27, 2014, 5:11:14 PM
    Author     : lamm
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="stylesheets/main.css" rel="stylesheet" type="text/css"/>
        <title>Smartcities - Ubiquos data</title>
    </head>
    <body>
        <h1>Smartcities - Ubiquos data</h1>
        <ul>
            <li><a href="cepservice?cep=88020100">cep (DADOS POR CEP)</a></li>
            <li><a href="geocodeservice?ip=150.162.141.1">ip lat lon (LAT LON PARA UM IP)</a></li>         
            <li><a href="ufservice">ufservice (UF do IBGE)</a></li>         
            <li><a href="weatherservice?city=florianopolis">weatherservice?city=florianopolis (noa por cidade)</a></li>         
            <li><a href="weatherservice?city=florianopolis&country=br">weatherservice?city=florianopolis&country=br (dados noa)</a></li>         
            <li><a href="weatherservice?lat=-27.5833&lon=-48.5667">weatherservice?lat=2&lon=2 (dados hj CPTEC)</a></li> 
            <li><a href="weatherservice?lat=-27.5833&lon=-48.5667&p">weatherservice?lat=2&lon=2&p (previsao 7 dias CPTEC)</a></li> 
            <li><a href="weatherservice?cdAeroporto=SBFL">weatherservice?cdAeroporto=SBFL (CPTEC)</a></li> 
            
           
        </ul>






    </body>
</html>
