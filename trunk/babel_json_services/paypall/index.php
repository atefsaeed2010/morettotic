<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<pre>
<?php
require_once("../libs/db_vars.config.php"); // include the library file

$id = $_GET['id'];
$ip = getRemoteIp();
//Log acess to paypall
$query = "SELECT `fn_log`($id, '$ip') AS `fn_log`;";
$result = mysqli_query($con, $query);
//Seleciona o usuario
$query = "select * from view_paypall WHERE id_user=$id ORDER BY payer_address desc limit 1";

//echo $query;;

$result = mysqli_query($con, $query);
$row = mysqli_fetch_array($result);

//var_dump($row);

//var_dump($row);
?>
</pre>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>Babel2u Buy translate coins</title>
        <script language="javascript" src="http://code.jquery.com/jquery-1.11.1.min.js"></script>
        <style>
            .as_wrapper1{
                margin:0 auto;
                width:200px;
                font-family:Arial;
                color:#333;
                font-size:22px;
                background: aqua;
                opacity:0.65;
                -moz-opacity: 0.65;
                filter: alpha(opacity=65);
                font-family:Arial, Helvetica, sans-serif;
                text-shadow: 1px 1px 0px #fff;
                background:#eaebec;
                margin:20px;
                border:#ccc 1px solid;

                -moz-border-radius:3px;
                -webkit-border-radius:3px;
                border-radius:3px;

                -moz-box-shadow: 0 1px 2px #d1d1d1;
                -webkit-box-shadow: 0 1px 2px #d1d1d1;
                box-shadow: 0 1px 2px #d1d1d1;
            }
            .as_wrapper{
                margin:0 auto;
                width:90%px;
                font-family:Arial;
                color:#333;
                font-size:11px;

            }
            .as_country_container{
                padding:20px;
                border:2px dashed #17A3F7;
                margin-bottom:10px;
            }
            .mbt1{
                width: 70%;
                border:1px solid #f9f68a; -webkit-border-radius: 3px; -moz-border-radius: 3px;border-radius: 3px;font-size:12px;font-family:arial, helvetica, sans-serif; padding: 10px 10px 10px 10px; text-decoration:none; display:inline-block;text-shadow: 5px 5px 0 rgba(0,0,0,0.3);font-weight:bold; color: #000000;
                background-color: #fcfac0; background-image: -webkit-gradient(linear, left top, left bottom, from(#fcfac0), to(#f6f283));
                background-image: -webkit-linear-gradient(top, #fcfac0, #f6f283);
                background-image: -moz-linear-gradient(top, #fcfac0, #f6f283);
                background-image: -ms-linear-gradient(top, #fcfac0, #f6f283);
                background-image: -o-linear-gradient(top, #fcfac0, #f6f283);
                background-image: linear-gradient(to bottom, #fcfac0, #f6f283);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#fcfac0, endColorstr=#f6f283);
                height: 15px;
            }
            .mbt{
                width: 70%;
                border:1px solid #ffc826; -webkit-border-radius: 3px; -moz-border-radius: 3px;border-radius: 3px;font-size:12px;font-family:arial, helvetica, sans-serif; padding: 10px 10px 10px 10px; text-decoration:none; display:inline-block;text-shadow: -1px -1px 0 rgba(0,0,0,0.3);font-weight:bold; color: #FFFFFF;
                background-color: #ffd65e; background-image: -webkit-gradient(linear, left top, left bottom, from(#ffd65e), to(#febf04));
                background-image: -webkit-linear-gradient(top, #ffd65e, #febf04);
                background-image: -moz-linear-gradient(top, #ffd65e, #febf04);
                background-image: -ms-linear-gradient(top, #ffd65e, #febf04);
                background-image: -o-linear-gradient(top, #ffd65e, #febf04);
                background-image: linear-gradient(to bottom, #ffd65e, #febf04);filter:progid:DXImageTransform.Microsoft.gradient(GradientType=0,startColorstr=#ffd65e, endColorstr=#febf04);
                height: 30px;
              
            }
        </style>
    </head>

    <body style="background-size: 100% 100% ;background-image: url('http://www.nosnaldeia.com.br/babel_json_services/libs/avatars/bg_icon.png'); background-repeat: no-repeat">
        <div class="as_wrapper">
            <br>
                <br>
                    <br>
                        <form action="paypal.php?id=<?php echo $id ?>" method="post" name="form1"> <?php // remove sandbox=1 for live transactions                     ?>
                            <input type="hidden" name="action" value="process" />
                            <input type="hidden" name="cmd" value="_cart" /> <?php // use _cart for cart checkout                     ?>
                            <input type="hidden" name="currency_code" value="USD" />
                            <input type="hidden" name="invoice" value="<?php echo date("His") . rand(1234, 9632); ?>" />
                            <table>
                                <tr>
                                    <td colspan="2">
                                        Welcome:<b>
                                            <label><?php echo $row['name']; ?><br>Email:(<?php echo $row['email']; ?>)</label>
                                        </b>
                                        <input type="hidden" name="payer_lname" value="<?php echo $row['name']; ?>" />
                                        <input type="hidden" name="user_id" value="<?php echo $id; ?>" />
                                        <input type="hidden" name="payer_fname" readonly value="<?php echo $row['name']; ?>" />
                                        <input type="hidden" readonly name="payer_email" value="<?php echo $row['email']; ?>" />
                                        <input type="hidden" name="product_id" value="1" />
                                        <input type="hidden" name="product_name"  value="Babel2u Coins" />
                                    </td>
                                </tr>
                                <tr>

                                    <td class="as_wrapper1" colspan="2">
                                        <label><b>Service Coins</b></label><p>
                                            <ul>
                                                <li>1hour  = 50$</li>
                                            </ul>
                                        </p>
                                        <input type="hidden" name="product_quantity" value="1" />
                                    </td>
                                </tr>
                                <tr>
                                    <td><label>Total</label></td>
                                    <td>
                                        <select name="product_amount" class="mbt1">
                                            <option value="5">5$</option> 
                                            <option value="10">10$</option> 
                                            <option value="15">15$</option> 
                                            <option value="20" selected>20$</option>  
                                            <option value="25">25$</option> 
                                            <option value="50">50$</option> 
                                            <option value="100">100$</option> 
                                            <option value="200">200$</option> 
                                            <option value="500">500$</option>
                                            <option value="750">750$</option>
                                            <option value="1000">1000$</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr>
                                    <td><label>Zip</label></td>
                                    <td><input type="text" name="payer_zip" id="payer_zip" value="<?php echo $row['payer_zip']; ?>" class="mbt1"/></td>
                                </tr>
                                <tr>
                                    <td><label>Address</label></td>
                                    <td><input type="text" name="payer_address" value="<?php echo $row['payer_address']; ?>" class="mbt1"/></td>
                                </tr>
                                <tr>
                                    <td><label>City</label></td>
                                    <td><input type="text" name="payer_city" value="<?php echo $row['payer_city']; ; ?>" class="mbt1"/></td>
                                </tr>
                                <tr>
                                    <td><label>State</label></td>
                                    <td><input type="text" readonly name="payer_state" value="<?php echo visitor_country()!="Unknown"?visitor_country()->geoplugin_regionName:$row['payer_state']; ?>" class="mbt1"/></td>
                                </tr>     

                                <tr>
                                    <td><label>Country</label></td>
                                    <td><input type="text" name="payer_country" value="<?php echo visitor_country()!="Unknown"?visitor_country()->geoplugin_countryCode:$row['payer_city'] ?>" class="mbt1"/></td>
                                </tr> 
                                <tr>
                                    <td colspan="2" align="right"><input type="submit" name="submit" value="Buy" class="mbt"/></td>
                                </tr>
                            </table>
                        </form>
                        </table>
                        <script>
                            document.getElementById("payer_zip").onblur = function() {
                                //alert();
                                var MyUrl = "http://www.nosnaldeia.com.br/babel_json_services/?action=BUSCACEP&cep=" + this.value;
                                $.ajax({
                                    // url para o arquivo json.php 
                                    url: MyUrl,
                                    // dataType json
                                    dataType: "json",
                                    // função para de sucesso
                                    success: function(data) {
                                        if (data.address !== undefined)
                                            document.form1.payer_address.value = data.address + "/" + data.district;
                                        if (data.city !== undefined)
                                            document.form1.payer_city.value = data.city;
                                        //alert(data);
                                    }
                                });
                            }

                        </script>
                        </div>
                        </body>
                        </html>
                        <?php
// Output Country name [Ex: United States]
                        mysql_close($con);
                        ?>
