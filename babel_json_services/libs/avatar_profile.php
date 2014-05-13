
<?php
/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * SHOWS AVATAR IMAGE
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * @data 25/03/2014
 * 
 * 
  ;# 1 linha(s) afetadas.


  update profile set avatar_idavatar = (select idavatar from avatar where image_path = 'tttttt') where id_user = 1;# 1 linha(s) afetadas.

 * 
 * */
include_once 'db_vars.config.php';

$id_user = $_GET['id_user'];
$image_path1 = $_GET['image_path'];

if (!empty($id_user)) {
    //Insere a nova imagem no banco usando a funcao no mysql 
    $query = " SELECT `fn_set_avatar`('$image_path1', '$id_user') AS `fn_set_avatar`";
    $result = mysqli_query($con, $query);
    $row = mysqli_fetch_array($result);
}
mysql_close($con);
?>
<html>
    <body bgcolor="#ffffff" marginheight="0" marginwidth="0">
        <img src="<?php echo $IMAGE_PATH . 'resized_' . $image_path1; ?>">
    </body>
</html>

