<?php
/**
 * Copyright 2011 Facebook, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may
 * not use this file except in compliance with the License. You may obtain
 * a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
require 'facebook.php';

// Create our Application instance (replace this with your appId and secret).
$facebook = new Facebook(array(
    'appId' => '754601351216534',
    'secret' => 'd9ed7cf6495fba5f78e09032740669f6',
        ));

// Get User ID
$user = $facebook->getUser();

// We may or may not have this data based on whether the user is logged in.
//
// If we have a $user id here, it means we know the user is logged into
// Facebook, but we don't know if the access token is valid. An access
// token is invalid if the user logged out of Facebook.

if ($user) {
    try {
        // Proceed knowing you have a logged in user who's authenticated.
        $user_profile = $facebook->api('/me');
        $friends = $facebook->api('/me/friends');

        //print_r($friends);
        //echo "<img src=\"https://graph.facebook.com/" . $user->id . "/picture\">";
    } catch (FacebookApiException $e) {
        error_log($e);
        $user = null;
    }
}

// Login or logout url will be needed depending on current user state.
if ($user) {
    $logoutUrl = $facebook->getLogoutUrl();
} else {
    $statusUrl = $facebook->getLoginStatusUrl();
    $loginUrl = $facebook->getLoginUrl();
}

// This call will always work since we are fetching public data.
//$naitik = $facebook->api('/naitik');



function get_file_name($copyurl) {
    return $copyurl . "jpg";
}
?>
<!doctype html>
<html xmlns:fb="http://www.facebook.com/2008/fbml">
    <head>
        <link rel="stylesheet" href="http://code.jquery.com/ui/1.8.24/themes/base/jquery-ui.css">
        <script language="javascript" src="http://code.jquery.com/jquery-1.11.1.min.js"></script>
        <script language="javascript" src="http://code.jquery.com/ui/jquery-ui-git.js"></script>
        <title>UNIVOXER FACEBOOK</title>
        <style>
            body {
                font-family: 'Lucida Grande', Verdana, Arial, sans-serif;
                margin-left: 0px;
            }
            h1 a {
                text-decoration: none;
                color: #3b5998;
            }
            h1 a:hover {
                text-decoration: underline;
            }
            .as_wrapper1{
                margin:0 auto;
                width:300px;
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
                margin:0px;
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
                width: 100%;
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
                width: 100%;
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
    <body >


        <?php if ($user): ?>

        <?php else: ?>
            <div>
                <a href="<?php echo $loginUrl; ?>">Login with Facebook</a>
            </div>
        <?php endif ?>




        <?php if ($user): ?>

            <?php
            //$json = json_encode($user_profile);
            // var_dump($json);
            //var_dump($user_profile);
            //copia a imagem do face pro meu diretorio

            $dir = '../libs/avatars/';

            $iurm = "https://graph.facebook.com/" . $user . "/picture";
            //echo get_file_name($iurm);
            $fName = "resized_$user.jpg";

            copy($iurm, $dir . $fName);
            //var_dump($content);
            //Store in the filesystem.
            //echo $dir . get_file_name();
            ?>
            <a href="index.php"></a>
            <form action="paypal." method="post" name="form1"> 

                <table class="as_wrapper1">
                    <tr>
                        <td colspan="2">
                            <h3>Univoxer - facebook</h3>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <h4>Registre-se</h4>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type="hidden" name="avatar" value="<?php echo "https://graph.facebook.com/$user/picture" ?>" />
                            <input type="hidden" name="id_user" value="-1" />
                        </td>
                    </tr>

                    <tr>
                        <td><label>Avatar</label></td>
                        <td><img src="<?php echo $iurm; ?>"></td>
                    </tr>

                    <tr>
                        <td><label>Welcome:</label></td>
                        <td><input type="text" name="name" value="<?php echo strtoupper($user_profile['name']); ?>" class="mbt1"/></td>
                    </tr>
                    <tr>
                        <td><label>email</label></td>
                        <td><input type="text" name="email" value="<?php echo ""; ?>" class="mbt1"/></td>
                    </tr>
                    <tr>
                        <td><label>Birthday</label></td>
                        <td><input type="text" name="birthday"id="datepicker" value="<?php echo ""; ?>" class="mbt1"/></td>
                    </tr>
                    <tr>
                        <td><label>Password</label></td>
                        <td><input type="password" name="passwd" value="<?php echo ""; ?>" class="mbt1"/></td>
                    </tr>
                    <tr>
                        <td><label>Password 1</label></td>
                        <td><input type="password" name="passwd1" value="<?php echo ""; ?>" class="mbt1"/></td>
                    </tr>
                    <tr>
                        <td colspan="2" align="right">
                            <input type="button" id="submit1" value="Register" class="mbt"/>
                        </td>
                    </tr>
                </table>
            </form>
<?php else: ?>
            <strong><em>You are not Connected.</em></strong>
        <?php endif ?>
        <script>
            document.getElementById("submit1").onclick = function() {
                //alert();
                if (!validateEmail(document.form1.email.value)) {
                    alert("Email invalid!");
                    return;
                }
                if (document.form1.email.value == "") {
                    alert("Email required!");
                    return;
                }
                if (document.form1.name.value == "") {
                    alert("Name required!");
                    return;
                }
                if (document.form1.birthday.value == "") {
                    alert("Birthday required!");
                    return;
                }
                if (document.form1.passwd.value != document.form1.passwd.value) {
                    alert("Password dont match!");
                    return;
                }
                if (document.form1.passwd.value.length < 7) {
                    alert("Password requires at least 7 characters!");
                    return;
                }

                var birth = $('#datepicker').datepicker({dateFormat: 'yy-mm-dd'}).val();
                var vBirth = birth.split("/");

                birth = vBirth[2] + "-" + vBirth[0] + "-" + vBirth[1];

                var MyUrl = "http://www.nosnaldeia.com.br/babel_json_services/?action=SAVE_PROFILE&"
                        + "id_user=-1&email="
                        + document.form1.email.value.toUpperCase()
                        + "&name="
                        + document.form1.name.value.toUpperCase()
                        + "&birthday="
                        + birth
                        + "&paypall_acc="
                        + "fcb<?php echo $user; ?>"
                        + "&nature=1&proficiency=BR&id_role=1&passwd="
                        + document.form1.passwd.value.toUpperCase();

                $.ajax({
                    // url para o arquivo json.php 
                    url: MyUrl,
                    // dataType json
                    dataType: "json",
                    // função para de sucesso
                    success: function(data) {
                        alert(data.id_user);
                        if (data.id_user == "-1") {
                            alert("Already registered!")
                        } else {
                            document.form1.id_user.value = data.id_user;
                            alert("Welcome!")
                            saveAvatar()
                            //atualiza o usuario maldito com a foto do facebook
                        }

                    }
                });
            }

            function saveAvatar() {
                MyUrl = "http://www.nosnaldeia.com.br/babel_json_services/?action=AVATAR&id_user="
                        +document.form1.id_user.value
                        +"&image_path=<?php echo $user; ?>.jpg";
                $.ajax({
                    // url para o arquivo json.php 
                    url: MyUrl,
                    // dataType json
                    dataType: "json",
                    // função para de sucesso
                    success: function(data) {
                        alert(data);
                        

                    }
                });
            }

            $(function() {
                $("#datepicker").datepicker();
            });
            function validateEmail(email) {
                var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                return re.test(email);
            }
        </script>
    </body>
</html>