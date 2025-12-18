<?php
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

$con=mysqli_connect("localhost","root", "","deadtrack");
// Check connection
if (mysqli_connect_errno())
  {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }

$sql = "select * from users";
if ($result = mysqli_query($con,$sql))
  {
   $emparray = array();
   while($row =mysqli_fetch_assoc($result))
       $emparray[] = $row;

  echo(json_encode($emparray));
  mysqli_free_result($result);
  mysqli_close($con);
  }

?> 	