<?php
    ini_set("session.hash_function","sha512");
    session_start();

    ini_set("max_execution_time",500);

    $db_host = "localhost";
    $db_user = "root";
    $db_pass = "";
    $db_data = "your-db";

    $con = new mysqli($db_host,$db_user,$db_pass,$db_data);

    $db_host2 = "localhost";
    $db_user2 = "root";
    $db_pass2 = "";
    $db_data2 = "your-db";

    $con2 = new mysqli($db_host2,$db_user2,$db_pass2,$db_data2);

?>
