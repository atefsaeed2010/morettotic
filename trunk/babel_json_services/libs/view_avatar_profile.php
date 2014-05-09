<html>
    <body bgcolor="#ffffff" marginheight="0" marginwidth="0">
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


         * 
         * */
        include_once 'db_vars.config.php';

        $id_user = $_GET['id_user'];
        
        
        //echo $id_user;

        $query = "select image_path from avatar where idavatar = (select avatar_idavatar from profile where id_user = $id_user) order by idavatar desc limit 1";

        //echo $query;

        $result = mysqli_query($con, $query);
        $row = mysqli_fetch_array($result);
        //var_dump($row);
        $image = $row['image_path'];

        echo "<img src=". $IMAGE_PATH . 'resized_' . $image . " />";

        mysql_close($con);
        ?>
    </body>
</html>