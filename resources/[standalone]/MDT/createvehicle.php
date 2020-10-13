<?php
    require "requires/config.php";
    if (!$_SESSION['loggedin']) {
        Header("Location: login");
    }
    $respone = false;
    if ($_SERVER['REQUEST_METHOD'] == "POST") {
        if ($_POST["type"] == "edit") {
                $vehicleid = $_POST['vehicleid'];

                $get_vehicle = $con->query("SELECT info FROM player_vehicles WHERE id = '$vehicleid'");
                while ($vehicles = $get_vehicle->fetch_object()){
                  $info = json_decode($vehicles->info, true);
                  $note = isset($info['note']) ? $info['note'] : ' ';
                  $apk = isset($info['apk']) ? $info['apk'] : ' ';
                  $warrant = isset($info['warrant']) ? $info['warrant'] : ' ';
                }

        } elseif ($_POST["type"] == "realedit") {
            $vehicleid = $_POST['vehicleid'];

            $updated_note = $_POST['note'];
            $updated_apk = $_POST['apk'];
            $updated_warrant = $_POST['warrant'];

            $updated = array("note"=>$updated_note, "apk"=>$updated_apk, "warrant"=>$updated_warrant);
            $updated_data = json_encode($updated);
            $update = $con->query("UPDATE player_vehicles SET info = '$updated_data' WHERE id = '$vehicleid'");
            if ($update) {
                $_SESSION["vehicleid"] = $_POST['vehicleid'];
                $respone = true;
                header('Location: vehicles');
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

        <title>Politie Databank</title>

        <link rel="canonical" href="https://getbootstrap.com/docs/4.0/examples/starter-template/">

        <!-- Bootstrap core CSS -->
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

        <!-- Custom styles for this template -->
        <link href="assets/css/main.css" rel="stylesheet">
        <link href="assets/css/profiles.css" rel="stylesheet">
        <link href="assets/css/laws.css" rel="stylesheet">
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
                                Welkom <?php echo $_SESSION["rank"] . " " . $firstname . " " . substr($lastname, 0, 1); ?>.
                            </span>
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-button" href="logout">
                            <button class="btn btn-outline-light btn-logout my-2 my-sm-0" type="button">LOG UIT</button>
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
                            OPZOEKEN
                        </a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <a class="dropdown-item" href="profiles">PERSONEN</a>
                            <a class="dropdown-item" href="reports">REPORTS</a>
                            <a class="dropdown-item" href="vehicles">VOERTUIGEN</a>
                            <a class="dropdown-item" href="houses">HUIZEN</a>
                        </div>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="warrants">ARRESTATIEBEVELEN</a>
                    </li>
                    <?php if ($_SESSION["role"] == "admin") { ?>
                        <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        ADMIN
                        </a>
                        <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                            <a class="dropdown-item" href="laws">STRAFFEN</a>
                            <a class="dropdown-item" href="users">GEBRUIKERS</a>
                        </div>
                    </li>
                    <?php } ?>
                    <li class="nav-item">
                        <a class="nav-link-report" href="createreport">NIEUW RAPPORT</a>
                    </li>
                </ul>
            </div>
        </nav>

        <main role="main" class="container">
            <div class="content-introduction">
                <h3>Voertuig Bewerken</h3>
                <p class="lead">Hier kun je een voertuig bewerken.<br />Je kunt hier een notitie toevoegen aan een voertuig. Tevens kun je een voertuig signaleren.</p>
            </div>
            <div class="createprofile-container">
                <div class="createprofile-left">
                <?php if ($_SERVER['REQUEST_METHOD'] == "POST" && $_POST['type'] == "edit") { ?>
                    <form method="post">
                        <input type="hidden" name="type" value="realedit">
                        <input type="hidden" name="vehicleid" value="<?php echo $vehicleid; ?>">
                        <div class="input-group mb-3">
                            <input type="text" name="note" class="form-control login-user" value="<?php echo $note; ?>" placeholder="notitie..." required>
                        </div>
                        <div class="form-check">
                            <input type="hidden" name="apk" value="0">
                            <input class="form-check-input" type="checkbox" value="1" name="apk" <?php if(trim($apk) == '1') echo 'checked = "checked"' ?>>
                            <label class="form-check-label">
                                APK
                            </label>
                        </div>
                        <div class="form-check mb-4">
                            <input type="hidden" name="warrant" value="0">
                            <input class="form-check-input" type="checkbox" value="1" name="warrant" <?php if(trim($warrant) == '1') echo 'checked = "checked"' ?>>
                            <label class="form-check-label">
                                GESIGNALEERD
                            </label>
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-primary btn-police">Bewerk voertuig</button>
                        </div>
                    </form>
                <?php } ?>
                </div>
            </div>
        </main>

        <!-- Optional JavaScript -->
        <!-- jQuery first, then Popper.js, then Bootstrap JS -->
        <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
        <script src="assets/js/main.js"></script>
        <script src="assets/js/car-replace-names.js"></script>
    </body>
</html>
