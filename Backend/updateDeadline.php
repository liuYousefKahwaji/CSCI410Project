<?php
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

$con=mysqli_connect("localhost","root", "","deadtrack");
if (mysqli_connect_errno()){
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$jsonData = file_get_contents("php://input");
$data = json_decode($jsonData,true);

$username = $data['username'];
$d_id = $data['d_id'];
$d_name = $data['d_name'];
$d_date = $data['d_date'];

$sql = "update deadlines set d_name = '$d_name', d_date = '$d_date' where d_id = $d_id and username = '$username'";
if (mysqli_query($con,$sql)){
	mysqli_close($con);
}

?> 	
