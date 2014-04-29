<?php

/*
  PAYPAL IPN RETURN SERVER TO SERVER COMMUNICATION
 * 
 * 
 * 
 * UPDATE purchase SET trasaction_id = 'x', log_id = 1 payment_status = 'aaaa" WHERE invoice = 'x'
 * {    
 *      mc_gross:5.00,
 *      invoice:0449524211,
 *      protection_eligibility:Partially Eligible - INR Only,
 *      address_status:unconfirmed,
 *      item_number1:1,
 *      payer_id:DGV5Q2363653Y,
 *      tax:0.00,
 *      address_street:Rua General Bittencourt  397  casaCentro,
 *      payment_date:00:51:28 Apr 08, 2014 PDT,
 *      payment_status:Completed,
 *      charset:windows-1252,
 *      address_zip:88020-100,
 *      mc_shipping:0.00,
 *      mc_handling:0.00,
 *      first_name:MORETTO TIC,
 *      mc_fee:0.50,
 *      address_country_code:BR,
 *      address_name:MORETTO TIC MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO's Test Store,
 *      notify_version:3.7,
 *      custom:,
 *      payer_status:verified,
 *      business:malacma-facilitator@gmail.com,
 *      address_country:Brazil,
 *      num_cart_items:1,
 *      mc_handling1:0.00,
 *      address_city:Florianópolis,
 *      verify_sign:AAml4.aXmUY-9IqTsmxtSUqQOoeWAwTh9TE6kacS2dGoXkYwn.9kqx.P,
 *      payer_email:malacma@gmail.com,
 *      mc_shipping1:0.00,
 *      tax1:0.00,
 *      txn_id:4X974407LT030000N,
 *      payment_type:instant,payer_business_name:MORETTO TIC MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO's Test Store,
 *      last_name:MORETTO TECNOLOGIA DA INFORMACAO E COMUNICACAO,
 *      address_state:SC,
 *      item_name1:Babel2u Coins,
 *      receiver_email:malacma-facilitator@gmail.com,
 *      payment_fee:0.50,
 *      quantity1:1,
 *      receiver_id:REQ8GEKT48VW6,
 *      txn_type:cart,
 *      mc_gross_1:5.00,
 *      mc_currency:USD,
 *      residence_country:BR,test_ipn:1,
 *      transaction_subject:,
 *      payment_gross:5.00,
 *      ipn_track_id:13a7b5b4211aa,
 *      a1:null
 * }
 * 
 * 
 */
require_once 'paypall_dump.php';


/**
  @Monta o Objeto com os parametros IPN do paypal
 * */
$paypalReturn = new stdClass();
$paypalReturn->txn_id = null;
$paypalReturn->payment_status = null;
$paypalReturn->invoice = null;
$paypalReturn->payer_email = null;
$paypalReturn->payment_date = null;
$paypalReturn->payer_email = null;
$paypalReturn->paypal_log_id = -1;
$paypalReturn->mc_gross_1 = 0.0;
$paypalReturn->id_profile = -1;
$paypalReturn->credits = 0;

/**
 * Monta o log e recupera os parametros da URL
 */

$log_msg = "{";
foreach ($_POST as $k => $v) {
    if ($k == "txn_id") {
        $paypalReturn->txn_id = $v;
    } else if ($k == "payment_status") {
        $paypalReturn->payment_status = $v;
    } else if ($k == "invoice") {
        $paypalReturn->invoice = $v;
    } else if ($k == "payer_email") {
        $paypalReturn->payer_email = $v;
    } else if ($k == "payment_date") {
        $paypalReturn->payment_date = $v;
    }else if ($k == "mc_gross_1") {
        $paypalReturn->mc_gross_1 = $v;
    }
    $log_msg.=$k.":".$v.",";
}
$log_msg.="a1:null}";
//$saida = $con;
//insere no log
//Armazena o log id para atualizar a venda se esta for completada
$queryId = "(SELECT id FROM paypal_log WHERE txn_id = '" . $paypalReturn->txn_id . "')";
$saida.= $queryId . ';';

$query = "insert into paypal_log (txn_id,log,posted_date) values('" . $paypalReturn->txn_id . "','".$log_msg."',now())";
$saida = $query . ';';
mysqli_query($con, $query);

//Se a venda foi concretizada
if ($paypalReturn->payment_status == PAYMENT_COMPLETED) {
    $query = "UPDATE purchase SET "
            . " trasaction_id = '" . $paypalReturn->txn_id . "',"
            . " log_id = " . $queryId . ","
            . " payment_status = '" . $paypalReturn->payment_status . "'"
            . " WHERE invoice = '" . $paypalReturn->invoice . "'";

    $saida.=$query . ';';
    mysqli_query($con, $query);
    
    //Calcula o total de creditos
    $payed_babel_coins = ($paypalReturn->mc_gross_1*1.5);
 
    //Atualiza no banco de dados os creditos do usuario
    $query = "SELECT `fn_add_credits`('".$paypalReturn->invoice."', '".$payed_babel_coins."') AS fn_add_credits";
    $result = mysqli_query($con, $query);
    $row = mysql_fetch_array($result);
    
    //Novos creditos do usuario
    $payed_babel_coins = $row['fn_add_credits'];
    
    $saida.=$query;
    
    //notifica o babel e os usuarios
    $message = 'Instant Payment Notification - Recieved Payment (Babel2u Coins)';
    $message.= '\n';
    $message.= 'Your payment status is:' . $paypalReturn->payment_status;
    $message.= '\n';
    $message.= 'Date:' . $paypalReturn->payment_date;
    $message.= '\n';
    $message.= 'Thank you. Enjoy it';

    $saida.=$message;

    mail("malacma@gmail.com", "BABEL2u Coins", $message.' '.$saida, "From: " . $paypalReturn->payer_email . "\n");
    mail($paypalReturn->payer_email, "BABEL2u Coins (Sucess)", $message, "From: malacma@gmail.com\n");
} else {
     mail($paypalReturn->payer_email, "BABEL2u Coins (Failure)", $message, "From: malacma@gmail.com\n");
}
//GERA O LOG DE SAIDA!
$file = fopen("pplog.dat", "w+");
echo fwrite($file, $saida);
fclose($file);

?>
