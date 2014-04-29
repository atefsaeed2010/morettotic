<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
$query = "INSERT INTO purchase (invoice, product_id, product_name, product_quantity, product_amount, payer_fname, payer_lname, payer_address, payer_city, payer_state, payer_zip, payer_country, payer_email, payment_status, posted_date, user_id) VALUES ('" . $_POST["invoice"] . "', '" . $_POST["product_id"] . "', '" . $_POST["product_name"] . "', '" . $_POST["product_quantity"] . "', '" . $_POST["product_amount"] . "', '" . $_POST["payer_fname"] . "', '" . $_POST["payer_lname"] . "', '" . $_POST["payer_address"] . "', '" . $_POST["payer_city"] . "', '" . $_POST["payer_state"] . "', '" . $_POST["payer_zip"] . "', '" . $_POST["payer_country"] . "', '" . $_POST["payer_email"] . "', 'pending', NOW()," . $_POST['user_id'] . ")";
$result = mysqli_query($con, $query);

$_SESSION['invoice'] = $_POST["invoice"];

//echo $query;

$row = mysqli_fetch_array($result);

//var_dump($row);

$this_script = 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'];
$p->add_field('business', PAYPAL_EMAIL_ADD); // Call the facilitator eaccount
$p->add_field('cmd', $_POST["cmd"]); // cmd should be _cart for cart checkout
$p->add_field('upload', '1');
$p->add_field('return', $this_script . '?action=success'); // return URL after the transaction got over
$p->add_field('cancel_return', $this_script . '?action=cancel'); // cancel URL if the trasaction was cancelled during half of the transaction
$p->add_field('notify_url', $this_script . '?action=ipn'); // Notify URL which received IPN (Instant Payment Notification)
$p->add_field('currency_code', $_POST["currency_code"]);
$p->add_field('invoice', $_POST["invoice"]);
$p->add_field('item_name_1', $_POST["product_name"]);
$p->add_field('item_number_1', $_POST["product_id"]);
$p->add_field('quantity_1', $_POST["product_quantity"]);
$p->add_field('amount_1', $_POST["product_amount"]);
$p->add_field('first_name', $_POST["payer_fname"]);
$p->add_field('last_name', $_POST["payer_lname"]);
$p->add_field('address1', $_POST["payer_address"]);
$p->add_field('city', $_POST["payer_city"]);
$p->add_field('state', $_POST["payer_state"]);
$p->add_field('country', $_POST["payer_country"]);
$p->add_field('zip', $_POST["payer_zip"]);
$p->add_field('email', $_POST["payer_email"]);
$p->submit_paypal_post(); // POST it to paypal
            //$p->dump_fields(); // Show the posted values for a reference, comment this line before app goes live
?>
