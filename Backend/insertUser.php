<?php
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

$con=mysqli_connect("localhost","root", "","deadtrack");
// Check connection
if (mysqli_connect_errno()){
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

$jsonData = file_get_contents("php://input");
$data = json_decode($jsonData,true);

$n = $data['username'];
$p = $data['password'];

$sql = "insert into users (username,password) values ('$n','$p')";
if (mysqli_query($con,$sql)){
	mysqli_close($con);
}

?> 	