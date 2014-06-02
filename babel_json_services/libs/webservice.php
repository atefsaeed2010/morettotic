<?php
header ('Content-type: text/html; charset=UTF-8');
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of WebService
 *
 * @author lamm
 */
class WebService {

    //put your code here

    public function findAddressByCEP($pcep) {
        $url = "http://apps.widenet.com.br/busca-cep/api/cep/" . $pcep . ".json";
        
        echo $url;
        return file_get_contents($url);
    }

    public function geGeoLocationInfoJSON($pip) {
        /* @var $GEOIP_PATH type */
        $file = file_get_contents("http://www.geoplugin.net/json.gp?ip=" . $pip);
        //echo $file;
        $result = json_decode($file);
        //ar_dump($result);
        return $result <> NULL ? $result : "Unknown";
    }

    public function getStatesXML() {
        try {
            $url = "http://hidroweb.ana.gov.br/fcthservices/mma.asmx/Estado";
            $xml = file_get_contents($url);

            return $xml;
        } catch (Exception $e) {
            return "Exception occured: " . $e;
        }
    }

}
