<?php

/**
 * 
 * MAIN BABEL JSON SERVICES
 * 
 * RESIZE IMAGE AND UPLOAD IT
 * 
 * @author Malacma <malacma@gmail.com>
 * 
 * @data 11/03/2014
 * 
 * */

function ak_img_resize($target, $newcopy, $w, $h, $ext) {
    list($w_orig, $h_orig) = getimagesize($target);
    $scale_ratio = $w_orig / $h_orig;
    if (($w / $h) > $scale_ratio) {
        $w = $h * $scale_ratio;
    } else {
        $h = $w / $scale_ratio;
    }
    $img = "";
    $ext = strtolower($ext);
    if ($ext == "gif") {
        $img = imagecreatefromgif($target);
    } else if ($ext == "png") {
        $img = imagecreatefrompng($target);
    } else {
        $img = imagecreatefromjpeg($target);
    }
    $tci = imagecreatetruecolor($w, $h);
    // imagecopyresampled(dst_img, src_img, dst_x, dst_y, src_x, src_y, dst_w, dst_h, src_w, src_h)
    imagecopyresampled($tci, $img, 0, 0, 0, 0, $w, $h, $w_orig, $h_orig);
    imagejpeg($tci, $newcopy, 80);
}
/**

 *  */
$fileName = $_FILES["uploaded_file"]["name"]; // The file name
$fileTmpLoc = $_FILES["uploaded_file"]["tmp_name"]; // File in the PHP tmp folder
$fileType = $_FILES["uploaded_file"]["type"]; // The type of file it is
$fileSize = $_FILES["uploaded_file"]["size"]; // File size in bytes
$fileErrorMsg = $_FILES["uploaded_file"]["error"]; // 0 for false... and 1 for true
$kaboom = explode(".", $fileName); // Split file name into an array using the dot


$file_path = "./avatars/";

$file_path = $file_path . basename($_FILES['uploaded_file']['name']);
if (move_uploaded_file($_FILES['uploaded_file']['tmp_name'], $file_path)) {
    echo "success";
} else {
    echo "fail";
}
$target_file = $file_path;
$resized_file = "./avatars/resized_$fileName";
$wmax = 120;
$hmax = 120;
//Redimensiona a imagem
ak_img_resize($target_file, $resized_file, $wmax, $hmax, $fileExt);
//Remove imagem original
unlink($target_file);
?>
