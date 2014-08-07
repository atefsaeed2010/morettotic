<?php
include_once 'db_vars.config.php';

$query = "select a1.ip,a2.name as nick,a2.id_user,a3.role_name, description
            from log as a1,profile as a2, role as a3, language as a4
            where a1.id_user = a2.id_user and a2.fk_id_role = a3.id_role
            and a4.id_lang = nature
            group by a2.name";

$result = mysqli_query($con, $query);
///var_dump($result);
$jsonMaps = "";

//var_dump($result);
$lat = "";
$lon = "";
while ($row = mysqli_fetch_array($result)) {
    
    $ip = stripslashes($row['ip']);
    
    $geoInfo = visitor_country($ip);
    
    $lat = $geoInfo->geoplugin_latitude;
    $lon = $geoInfo->geoplugin_longitude;
    
    $jsonMaps.= " map.addMarker({ 
  lat: $lat,
  lng: $lon,
  title: '" . $row['description'] . "',
  infoWindow: {
    content: '<p>Nick:" . $row['nick'] . " Role:" . $row['role_name'] . "</p>'
  }
 });\n";


    $lat = $geoInfo->geoplugin_latitude;
    $lon = $geoInfo->geoplugin_longitude;
}
?>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Univoxer Around The World</title>
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
        <script src="//maps.google.com/maps/api/js?sensor=true"></script>
        <script src="http://hpneo.github.io/gmaps/gmaps.js"></script>
        <script src="http://hpneo.github.io/gmaps/prettify/prettify.js"></script>
        <link rel="stylesheet" href='//fonts.googleapis.com/css?family=Convergence|Bitter|Droid+Sans|Ubuntu+Mono' />
        <link rel="stylesheet" href="http://hpneo.github.io/gmaps/styles.css" />
        <link rel="stylesheet" href="http://hpneo.github.io/gmaps/prettify/prettify.css" />
        <link rel="stylesheet" href="examples.css" />
        <script>


            var map;
            $(document).ready(function() {
                prettyPrint();
                map = new GMaps({
                    div: '#map',
                    zoom: 10,
                    lat: <?php echo $lat; ?>,
                    lng: <?php echo $lon; ?>,
                });
                map.addControl({
                    position: 'top_right',
                    content: 'Geolocate',
                    style: {
                        margin: '5px',
                        padding: '1px 6px',
                        border: 'solid 1px #717B87',
                        background: '#fff'
                    },
                    events: {
                        click: function() {
                            GMaps.geolocate({
                                success: function(position) {
                                    map.setCenter(position.coords.latitude, position.coords.longitude);
                                },
                                error: function(error) {
                                    alert('Geolocation failed: ' + error.message);
                                },
                                not_supported: function() {
                                    alert("Your browser does not support geolocation");
                                }
                            });
                        }
                    }
                });
                map.addMarker({
                    lat: 51.5007396,
                    lng: -0.1245299,
                    title: 'Big Ben',
                    infoWindow: {
                        content: '<p>Big Ben is the nickname for the great bell of the clock at the north end of the Palace of Westminster in London, and often extended to refer to the clock and the clock tower, officially named Elizabeth Tower.</p>'
                    }
                });
<?php echo $jsonMaps; ?>
            });
        </script>
    </head>
    <body>

        <div id="body">

            <div class="row">
                <div class="span11">
                    <div class="popin" style="width: 610px;height: 300px">
                        <div id="map"></div>
                    </div>
                </div>

            </div>
        </div>
    </body>
</html>
