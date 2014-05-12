<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<?php
require_once("../libs/db_vars.config.php"); // include the library file

$id = $_GET['id'];

$query = "SELECT * FROM profile WHERE id_user ='$id'";

$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);

//var_dump($row);
?>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>Babel2u Buy translate coins</title>
        <style>
            .as_wrapper1{
                margin:0 auto;
                width:98%px;
                font-family:Arial;
                color:#333;
                font-size:11px;
                background: aqua;
                opacity:0.65;
                -moz-opacity: 0.65;
                filter: alpha(opacity=65);
            }
            .as_wrapper{
                margin:0 auto;
                width:98%px;
                font-family:Arial;
                color:#333;
                font-size:11px;
            }
            .as_country_container{
                padding:20px;
                border:2px dashed #17A3F7;
                margin-bottom:10px;
            }
        </style>
    </head>

    <body style="background-image: url('http://www.seenergia.com.br/babel_json_services/libs/avatars/bg_icon.png')">
        <div class="as_wrapper">
            <h1>            </h1>
<br><br><br>
            <form action="paypal.php?sandbox=1&id=<?php echo $id ?>" method="post"> <?php // remove sandbox=1 for live transactions          ?>
                <input type="hidden" name="action" value="process" />
                <input type="hidden" name="cmd" value="_cart" /> <?php // use _cart for cart checkout          ?>
                <input type="hidden" name="currency_code" value="USD" />
                <input type="hidden" name="invoice" value="<?php echo date("His") . rand(1234, 9632); ?>" />
                <table>
                    <tr>
                        <td colspan="2">
                            <label><?php echo $row['name']; ?>(<?php echo $row['email']; ?>)</label>
                            <input type="hidden" name="payer_lname" value="<?php echo $row['name']; ?>" />
                            <input type="hidden" name="user_id" value="<?php echo $id; ?>" />
                            <input type="hidden" name="payer_fname" readonly value="<?php echo $row['name']; ?>" />
                            <input type="hidden" readonly name="payer_email" value="<?php echo $row['email']; ?>" />
                            <input type="hidden" name="product_id" value="1" />
                            <input type="hidden" name="product_name"  value="Babel2u Coins" />
                        </td>
                    </tr>
                    <tr>
                        <td><label>Service Coins</label></td>
                        <td class="as_wrapper1">
                            5$ Coins = 10 translate sessions<br/>
                            10$ Coins = 20 translate sessions<br/>
                            15$ Coins = 30 translate sessions<br/>
                            20$ Coins = 50 translate sessions<br/>
                            25$ Coins = 80 translate sessions<br/>
                            50$ Coins = 130 translate sessions<br/>
                            100$ Coins = 210 translate sessions<br/>
                            <input type="hidden" name="product_quantity" value="1" />
                        </td>
                    </tr>
                    <tr>
                        <td><label>Product Amount</label></td>
                        <td>
                            <select name="product_amount">
                                <option value="5">5</option> 
                                <option value="10">10</option> 
                                <option value="15">15</option> 
                                <option value="20">20</option>  
                                <option value="25">25</option> 
                                <option value="50">50</option> 
                                <option value="100">100</option> 

                            </select></td>
                    </tr>

                    <tr>
                        <td><label>Address</label></td>
                        <td><input type="text" name="payer_address" value="" /></td>
                    </tr>
                    <tr>
                        <td><label>City</label></td>
                        <td><input type="text" name="payer_city" value="<?php echo visitor_country()->geoplugin_city; ?>" /></td>
                    </tr>
                    <tr>
                        <td><label>State</label></td>
                        <td><input type="text" readonly name="payer_state" value="<?php echo visitor_country()->geoplugin_regionName; ?>" /></td>
                    </tr>     
                    <tr>
                        <td><label>Zip</label></td>
                        <td><input type="text" name="payer_zip" value="" /></td>
                    </tr>
                    <tr>
                        <td><label>Country</label></td>
                        <td><input type="text" name="payer_country" value="<?php echo visitor_country()->geoplugin_countryCode; ?>" /></td>
                    </tr> 
                    <tr>
                        <td colspan="2" align="right"><input type="submit" name="submit" value="Buy" /></td>
                    </tr>
                </table>
            </form>
            </table>
        </div>
    </body>
</html>
<?php
// Output Country name [Ex: United States]
mysql_close($con);
?>