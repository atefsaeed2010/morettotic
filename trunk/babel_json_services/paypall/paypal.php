<?php
//header('HTTP/1.1 200 OK');
session_start();
/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * PAYPALL APP
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * @data 7/4/2014
 * 
  //PAYPALL RESPONSE POST PARAMETERS
 * 
 * === post fields
  [residence_country] => US
  [invoice] => abc1234
  [address_city] => San Jose
  [first_name] => John
  [payer_id] => TESTBUYERID01
  [shipping] => 3.04
  [mc_fee] => 0.44
  [txn_id] => 129214768
  [receiver_email] => seller@paypalsandbox.com
  [quantity] => 1
  [custom] => xyz123
  [payment_date] => 17:00:40 7 Apr 2014 PDT
  [address_country_code] => US
  [address_zip] => 95131
  [tax] => 2.02
  [item_name] => something
  [address_name] => John Smith
  [last_name] => Smith
  [receiver_id] => seller@paypalsandbox.com
  [item_number] => AK-1234
  [verify_sign] => An5ns1Kso7MWUdW4ErQKJJJ4qi4-AdCReyTXlzli69B.VtAI0VezCQrC
  [address_country] => United States
  [payment_status] => Completed
  [address_status] => confirmed
  [business] => seller@paypalsandbox.com
  [payer_email] => buyer@paypalsandbox.com
  [notify_version] => 2.1
  [txn_type] => web_accept
  [test_ipn] => 1
  [payer_status] => verified
  [mc_currency] => USD
  [mc_gross] => 12.34
  [address_state] => CA
  [mc_gross1] => 9.34
  [payment_type] => instant
  [address_street] => 123, any street
  === http request headers
  [User-Agent] => PayPal Sandbox
  [Content-Type] => application/x-www-form-urlencoded
  [Host] => 150.162.29.8
  //[Accept] => text/html, image/gif, image/jpeg, *; q=.2, *//* ; q=.2
  [Connection] => keep-alive
  [Content-Length] => 830
 * === post fields
  [residence_country] => US
  [invoice] => abc1234
  [address_city] => San Jose
  [first_name] => John
  [payer_id] => TESTBUYERID01
  [shipping] => 3.04
  [mc_fee] => 0.44
  [txn_id] => 674871486
  [receiver_email] => seller@paypalsandbox.com
  [quantity] => 1
  [custom] => xyz123
  [payment_date] => 17:03:53 7 Apr 2014 PDT
  [address_country_code] => US
  [address_zip] => 95131
  [tax] => 2.02
  [item_name] => something
  [address_name] => John Smith
  [last_name] => Smith
  [receiver_id] => seller@paypalsandbox.com
  [item_number] => AK-1234
  [verify_sign] => AFcWxV21C7fd0v3bYYYRCpSSRl31AnllJkyFPac0YALxfrb2ue6nEhpf
  [address_country] => United States
  [payment_status] => Denied
  [address_status] => confirmed
  [business] => seller@paypalsandbox.com
  [payer_email] => buyer@paypalsandbox.com
  [notify_version] => 2.1
  [txn_type] => web_accept
  [test_ipn] => 1
  [payer_status] => verified
  [mc_currency] => USD
  [mc_gross] => 12.34
  [address_state] => CA
  [mc_gross1] => 9.34
  [payment_type] => instant
  [address_street] => 123, any street
  === http request headers
  [User-Agent] => PayPal Sandbox
  [Content-Type] => application/x-www-form-urlencoded
  [Host] => 150.162.29.8
  [Accept] => text/html, image/gif, image/jpeg, *; q=.2, *//* ; q=.2
  [Connection] => keep-alive
  [Content-Length] => 827
 */
?>

<body style="background-image: url('http://www.nosnaldeia.com.br/babel_json_services/libs/avatars/bg_icon.png')">
    <br>
    <br>
    <br>
    <br>
    <?php
    require_once("paypal_class.php");
    require_once("../libs/db_vars.config.php"); // include the library file

    define('EMAIL_ADD', 'malacma@gmail.com'); // define any notification email
    define('PAYPAL_EMAIL_ADD', 'malacma-facilitator@gmail.com'); // facilitator email which will receive payments change this email to a live paypal account id when the site goes live
    define('PAYMENT_COMPLETED', 'Completed');

    $p = new paypal_class(); // paypal class
    $p->admin_mail = EMAIL_ADD; // set notification email

    $action = $_REQUEST["action"];

    switch ($action) {
        case "process": // case process insert the form data in DB and process to the paypal
            include_once 'paypal_process.php';
            break;
        case "success": // success case to show the user payment got success
            include_once 'paypal_sucess.php';
            break;
        case "cancel": // case cancel to show user the transaction was cancelled
            include_once 'paypal_canceled.php';
            break;
        case "ipn":
            include_once 'paypal_ipn.php';
            break;
    }
    mysql_close($con);
    ?>


</body>