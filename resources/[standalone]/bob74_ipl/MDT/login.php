<?php
    require "requires/config.php";
    if ($_SERVER['REQUEST_METHOD'] == "POST") {
        if (trim($_POST['username']) == NULL) {
            Header("Location:login?error");
        }
        if (trim($_POST['password']) == NULL) {
            Header("Location:login?error");
        }        
        $query = $con->query("SELECT * FROM users WHERE username = '".$con->real_escape_string($_POST['username'])."'");

        if ($query->num_rows == 1) {
            $row = $query->fetch_assoc();
            if (password_verify($_POST['password'],$row['password'])) {
                $_SESSION['loggedin'] = true;
                $_SESSION['username'] = $_POST['username'];
                $_SESSION['role'] = $row['role'];
                $_SESSION['name'] = $row['name'];
                $_SESSION['rank'] = $row['rank'];
                $_SESSION['id'] = $row['id'];
                $_SESSION["personid"] = NULL;
                $_SESSION["reportid"] = NULL;
                
                $con->query("UPDATE users SET last_login = '".date('Y-m-d')."' WHERE id = '".$row['id']."'");
                
                if ($_SERVER['HTTP_REFFER'] != "") {
                    header('Location: ' . $_SERVER['HTTP_REFERER']);
                } else {
                    Header("Location: dashboard");
                }
            } else {
                Header("Location: login?error");
            }
        } else {
            Header("Location: login?error");
        }
    }
?>

<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="description" content="">
        <meta name="author" content="">
        <link rel="shortcut icon" href="https://www.politie.nl/politie2018/assets/images/icons/favicon.ico" type="image/x-icon" />
        <link rel="icon" type="image/png" sizes="16x16" href="https://www.politie.nl/politie2018/assets/images/icons/favicon-16.png">
        <link rel="icon" type="image/png" sizes="32x32" href="https://www.politie.nl/politie2018/assets/images/icons/favicon-32.png">
        <link rel="icon" type="image/png" sizes="64x64" href="https://www.politie.nl/politie2018/assets/images/icons/favicon-64.png">

        <title>Politie Databank</title>

        <link rel="canonical" href="https://getbootstrap.com/docs/4.0/examples/starter-template/">

        <!-- Bootstrap core CSS -->
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

        <!-- Custom styles for this template -->
        <link href="assets/css/main.css" rel="stylesheet">
        <link href="assets/css/login.css" rel="stylesheet">
    </head>
    <body>
        <nav class="navbar fixed-top navbar-expand-lg navbar-custom bg-custom">
            <div class="collapse navbar-collapse" id="navbarsExampleDefault">

                <!-- Left menu -->
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item">
                        <a class="nav-label" href="#">
                            <img src="assets/images/icon.png" width="22" height="22" alt="">
                            <span class="title">Log in om verder te gaan..</span>
                        </a>
                    </li>
                </ul>
            </div>
        </nav>

        <main role="main" class="container">
            <div class="login-container">
                <div class="login-content">
                    <h4><strong>Log In</strong></h4>
                    <hr>
                    <?php if (isset($_GET['error'])) { ?>
                    <p style="color:#9f1010;">Verkeerde inlog gegevens!</p>
                    <?php } ?>
                    <form method="post">
                        <div class="input-group mb-3">
                            <input type="text" name="username" class="form-control login-user" value="" placeholder="gebruikersnaam">
                        </div>
                        <div class="input-group mb-2">
                            <input type="password" name="password" class="form-control login-pass" value="" placeholder="wacthtwoord">
                        </div>
                        <div class="form-group">
                            <button type="submit" name="login" class="btn btn-primary btn-login">Log in</button>
                        </div>
                    </form>
                </div>
            </div>
        </main><!-- /.container -->

        <!-- Optional JavaScript -->
        <!-- jQuery first, then Popper.js, then Bootstrap JS -->
        <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
        <script src="assets/js/main.js"></script>
    </body>
</html>
