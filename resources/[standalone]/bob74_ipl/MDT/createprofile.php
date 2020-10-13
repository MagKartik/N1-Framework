<?php
    require "requires/config.php";
    if (!$_SESSION['loggedin']) {
        Header("Location: login");
    }
    $respone = false;
    if ($_SERVER['REQUEST_METHOD'] == "POST") {
        if ($_POST['type'] == "create") {
            $note = nl2br($_POST["note"]);
            $insert = $con->query("INSERT INTO profiles (citizenid,fullname,avatar,fingerprint,dnacode,note,lastsearch) VALUES('".$con->real_escape_string($_POST['citizenid'])."','".$con->real_escape_string($_POST['fullname'])."','".$con->real_escape_string($_POST['avatar'])."','".$con->real_escape_string($_POST['fingerprint'])."','".$con->real_escape_string($_POST['dnacode'])."','".$con->real_escape_string($note)."',".time().")");
            if ($insert) {
                $last_id = $con->insert_id;
                $_SESSION["personid"] = $last_id;
                $respone = true;
                header('Location: profiles');
            }
        } elseif ($_POST['type'] == "edit") {
            $query = $con->query("SELECT * FROM profiles WHERE id = ".$con->real_escape_string($_POST['profileid']));
            $selectedprofile = $query->fetch_assoc();
        } elseif ($_POST['type'] == "realedit") {
            $note = nl2br($_POST["note"]);
            $update = $con->query("UPDATE profiles SET citizenid = '".$con->real_escape_string($_POST['citizenid'])."', fullname = '".$con->real_escape_string($_POST['fullname'])."', avatar = '".$con->real_escape_string($_POST['avatar'])."', fingerprint = '".$con->real_escape_string($_POST['fingerprint'])."', dnacode = '".$con->real_escape_string($_POST['dnacode'])."', note = '".$con->real_escape_string($note)."' WHERE id = ".$_POST['profileid']);
            if ($update) {
                $_SESSION["personid"] = $_POST['profileid'];
                $respone = true;
                header('Location: profiles');
            } else {
                $response = false;
            }
        }
    }
    $name = explode(" ", $_SESSION["name"]);
    $firstname = $name[0];
    $last_word_start = strrpos($_SESSION["name"], ' ') + 1;
    $lastname = substr($_SESSION["name"], $last_word_start);
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

        <title>Police MDT</title>

        <link rel="canonical" href="https://getbootstrap.com/docs/4.0/examples/starter-template/">

        <!-- Bootstrap core CSS -->
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

        <!-- Custom styles for this template -->
        <link href="assets/css/main.css" rel="stylesheet">
        <link href="assets/css/profiles.css" rel="stylesheet">
    </head>
    <body>
        <nav class="navbar fixed-top navbar-expand-lg navbar-custom bg-custom">
            <div class="collapse navbar-collapse" id="navbarsExampleDefault">

                <!-- Left menu -->
                <ul class="navbar-nav mr-auto">
                    <li class="nav-item">
                        <a class="nav-label" href="#">
                            <img src="assets/images/icon.png" width="22" height="22" alt="">
                            <span class="title">
                                Welcome <?php echo $_SESSION["rank"] . " " . $firstname . " " . substr($lastname, 0, 1); ?>.
                            </span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-button" href="logout">
                            <button class="btn btn-outline-light btn-logout my-2 my-sm-0" type="button">LOG OUT</button>
                        </a>
                    </li>
                </ul>

                <!-- Right menu -->
                <ul class="navbar-nav ml-auto">
                    <li class="nav-item active">
                        <a class="nav-link" href="dashboard">DASHBOARD</a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            SEARCH
                        </a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <a class="dropdown-item" href="profiles">PERSON</a>
                            <a class="dropdown-item" href="reports">REPORTS</a>
                            <a class="dropdown-item" href="vehicles">VEHICLES</a>
                            <a class="dropdown-item" href="houses">HOUSES</a>
                        </div>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="warrants">WARRANTS</a>
                    </li>
                    <?php if ($_SESSION["role"] == "admin") { ?>
                        <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        ADMIN
                        </a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <a class="dropdown-item" href="laws">FINES</a>
                            <a class="dropdown-item" href="users">USERS</a>
                        </div>
                    </li>
                    <?php } ?>
                    <li class="nav-item">
                        <a class="nav-link-report" href="createreport">NEW REPORT</a>
                    </li>
                </ul>
            </div>
        </nav>

        <main role="main" class="container">
            <div class="content-introduction">
                <h3>Make Profile</h3>
                <p class="lead">HHere you create a profile when a new criminal is brought in.<br />Make sure that all information is correct and that a correct photo has been posted!</p>
            </div>
            <div class="createprofile-container">
            <?php if ($_SERVER['REQUEST_METHOD'] == "POST" && $_POST['type'] == "edit" && !empty($selectedprofile)) { ?>
                <form method="post">
                    <input type="hidden" name="type" value="realedit">
                    <input type="hidden" name="profileid" value="<?php echo $selectedprofile["id"]; ?>">
                    <div class="input-group mb-3">
                        <input type="text" name="citizenid" class="form-control login-user" value="<?php echo $selectedprofile["citizenid"]; ?>" placeholder="CSN" required>
                    </div>
                    <div class="input-group mb-2">
                        <input type="text" name="fullname" class="form-control login-pass" value="<?php echo $selectedprofile["fullname"]; ?>" placeholder="Full name" required>
                    </div>
                    <div class="input-group mb-3">
                        <input type="text" name="avatar" class="form-control login-user" value="<?php echo $selectedprofile["avatar"]; ?>" placeholder="Profile Picture (imgur URL e.g. https://i.imgur.com/zKDjdhe.png)" required>
                    </div>
                    <div class="input-group mb-3">
                        <input type="text" name="fingerprint" class="form-control login-user" value="<?php echo $selectedprofile["fingerprint"]; ?>" placeholder="Fingerprint">
                    </div>
                    <div class="input-group mb-3">
                        <input type="text" name="dnacode" class="form-control login-user" value="<?php echo $selectedprofile["dnacode"]; ?>" placeholder="DNA code">
                    </div>
                    <?php $notes = str_replace( "<br />", '', $selectedprofile["note"]); ?>
                    <div class="input-group mb-2">
                        <textarea name="note" class="form-control" value="<?php echo $notes; ?>" placeholder="Note" required><?php echo $notes; ?></textarea>
                    </div>
                    <div class="form-group">
                        <button type="submit" name="create" class="btn btn-primary btn-police">Edit</button>
                    </div>
                </form>
            <?php } else { ?>
                <form method="post">
                    <input type="hidden" name="type" value="create">
                    <div class="input-group mb-3">
                        <input type="text" name="citizenid" class="form-control login-user" value="" placeholder="CSN" required>
                    </div>
                    <div class="input-group mb-2">
                        <input type="text" name="fullname" class="form-control login-pass" value="" placeholder="Full name" required>
                    </div>
                    <div class="input-group mb-3">
                        <input type="text" name="avatar" class="form-control login-user" value="" placeholder="Profile Picture (imgur URL e.g. https://i.imgur.com/zKDjdhe.png)">
                    </div>
                    <div class="input-group mb-3">
                        <input type="text" name="fingerprint" class="form-control login-user" value="" placeholder="Fingerprint">
                    </div>
                    <div class="input-group mb-3">
                        <input type="text" name="dnacode" class="form-control login-user" value="" placeholder="DNA code">
                    </div>
                    <div class="input-group mb-2">
                        <textarea name="note" class="form-control" value="" placeholder="Note"></textarea>
                    </div>
                    <div class="form-group">
                        <button type="submit" name="create" class="btn btn-primary btn-police">Add</button>
                    </div>
                </form>
            <?php } ?>
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
