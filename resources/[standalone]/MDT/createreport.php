<?php
    require "requires/config.php";
    if (!$_SESSION['loggedin']) {
        Header("Location: login");
    }
    $result = $con->query("SELECT * FROM laws ORDER BY months ASC");
    $laws_array = [];
    while ($data = $result->fetch_assoc()) {
        $laws_array[] = $data;
    }
    $respone = false;
    if ($_SERVER['REQUEST_METHOD'] == "POST") {
        if ($_POST['type'] == "createnew") {
            $query = $con->query("SELECT * FROM profiles WHERE id = ".$con->real_escape_string($_POST["profileid"]));
            $selectedprofile = $query->fetch_assoc();
        } elseif ($_POST['type'] == "create") {
            $profileid = NULL;
            $lawids = array_map('intval', explode(',', $_POST["laws"]));
            array_shift($lawids);
            if (isset($_POST["citizenid"]) && $_POST["citizenid"] != "") {
                $query = $con->query("SELECT * FROM profiles WHERE citizenid = '".$con->real_escape_string($_POST["citizenid"])."'");
                $profile = $query->fetch_assoc();
                if ($profile != NULL) {
                    $profileid = $profile["id"];
                }
            }
            $reportnote = nl2br($_POST["report"]);
            $total_fines = ($_POST["total-fine"]);
            $bsn = $_POST["citizenid"];
            $insert = $con->query("INSERT INTO reports (title,author,profileid,report,laws,created) VALUES('".$con->real_escape_string($_POST['title'])."','".$con->real_escape_string($_POST['author'])."','".$con->real_escape_string($profileid)."','".$con->real_escape_string($reportnote)."', '".json_encode($lawids)."',".time().")");
            if ($insert) {
                $last_id = $con->insert_id;
                $_SESSION["reportid"] = $last_id;
                $respone = true;
                header('Location: reports');
                if ($total_fines != 0) {
                    $con2->query("INSERT INTO bills (citizenid,type,amount) VALUES('".$bsn."', 'police','".$total_fines."')");
                }
            }
        } elseif ($_POST["type"] == "edit") {
            $query = $con->query("SELECT * FROM reports WHERE id = ".$con->real_escape_string($_POST['reportid']));
            $selectedreport = $query->fetch_assoc();
            $laws = json_decode($selectedreport["laws"], true);
            $lawsedit_array = [];
            $totalprice = 0;
            $totalmonths = 0;
            if (!empty($laws)) {
                foreach($laws as $lawid) {
                    $law = $con->query("SELECT * FROM laws WHERE id = ".$con->real_escape_string($lawid));
                    $selectedlaw = $law->fetch_assoc();
                    $totalmonths = $totalmonths + $selectedlaw["months"];
                    $totalprice = $totalprice + $selectedlaw["fine"];
                    $lawsedit_array[] = $selectedlaw;
                }
            }
            $profile = $con->query("SELECT * FROM profiles WHERE id = ".$con->real_escape_string($selectedreport['profileid']));
            $profiledata = $profile->fetch_assoc();
        } elseif ($_POST["type"] == "realedit") {
            $report = nl2br($_POST["report"]);
            $profile = $con->query("SELECT * FROM profiles WHERE citizenid = '".$con->real_escape_string($_POST['citizenid'])."'");
            $profileid = 0;
            if ($profile->num_rows > 0) {
                $profiledata = $profile->fetch_assoc();
                $profileid = $profiledata['id'];
            }
            $reportnote = nl2br($_POST["report"]);
            $update = $con->query("UPDATE reports SET title = '".$con->real_escape_string($_POST['title'])."', author = '".$con->real_escape_string($_POST['author'])."', profileid = ".$con->real_escape_string($profileid).", report = '".$con->real_escape_string($reportnote)."', created = ".time()." WHERE id = ".$_POST['reportid']);
            if ($update) {
                $_SESSION["reportid"] = $_POST['reportid'];
                $respone = true;
                header('Location: reports');
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
        <link href="assets/css/laws.css" rel="stylesheet">
         <!-- Froala text-editor scripts -->
        <link href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.3.0/codemirror.min.css" rel="stylesheet">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.3.0/codemirror.min.js"></script>
        <script src=" https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.3.0/mode/xml/xml.min.js"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/froala-editor/3.1.0/js/froala_editor.pkgd.min.js"></script>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/froala-editor/3.1.0/css/froala_editor.pkgd.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/froala-editor/3.1.0/css/froala_editor.min.css" rel="stylesheet">
        <script src="./assets/js/nl.js"></script>

        <!-- Froala Style Rules (This is not in seperate file because of testing) -->
        <style>
            .fr-box.fr-basic .fr-element.fr-view,
            .fr-wrapper.show-placeholder .fr-element.fr-view {
                font-family: 'Roboto Mono', monospace!important;
            }

            .fr-toolbar {
                border-radius: .25rem .25rem 0vh 0vh !important;
                border: 1px solid #ced4da;
            }

            .second-toolbar {
                border-radius: 0vh 0vh .25rem .25rem !important;
                border: 1px solid #ced4da;
            }

            .fr-active{
                fill: #004682 !important;
            }

            .fr-floating-btn {
                border-radius:.25em !important;
            }

			.fr-wrapper::before{
                font-family: 'Roboto Mono', monospace!important;
                text-align: left;
                content: "Unlicensed copy of the Froala Editor. Use it legally by purchasing a license.";
                position:absolute;
                width:100%;
                z-index:10000;
                height:fit-content;

                padding: 12.5px 25px;
                color:#FFF;
                text-decoration:none;
                background-color:transparent;
                /* background:rgba(58, 122, 176); */
                display:block;
                font-size:14px;
                font-family:sans-serif;
            }

            .none {
                display:none;
            }

            .fr-quick-insert {
                display: none !important;
            }
        </style>
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
                <h3>Create Report</h3>
                <p class="lead">Here you can create a new report.<br />You can link a citizen service number to a report (a profile MUST exist for this) or you can leave it empty and add it later.<br />Je kunt ook straffen toevoegen (wanneer nodig) onderaan de pagina.</br>Om een straf weg te halen kun je klikken op dezelfde straf bij "Geselecteerde Straffen"</p>
            </div>
            <div class="createreport-container">
                <div class="createreport-left">
                <?php if ($_SERVER['REQUEST_METHOD'] == "POST" && $_POST['type'] == "edit" && !empty($selectedreport)) { ?>
                    <form method="post">
                        <input type="hidden" name="type" value="realedit">
                        <input type="hidden" name="author" class="form-control login-pass" value="<?php echo $_SESSION["name"]; ?>" placeholder="" required>
                        <input type="hidden" name="reportid" class="form-control login-pass" value="<?php echo $selectedreport["id"]; ?>" placeholder="" required>
                        <div class="input-group mb-3">
                            <input type="text" name="title" class="form-control login-user" value="<?php echo $selectedreport["title"]; ?>" placeholder="Title" required>
                        </div>
                        <?php if (!empty($profiledata)) { ?>
                            <div class="input-group mb-3">
                                <input type="text" name="citizenid" class="form-control login-user" value="<?php echo $profiledata["citizenid"]; ?>" placeholder="Couple CSN (May be empty)">
                            </div>
                        <?php } else {?>
                            <div class="input-group mb-3">
                                <input type="text" name="citizenid" class="form-control login-user" value="" placeholder="Couple CSN (May be empty)">
                            </div>
                        <?php } ?>
                        <?php $report = str_replace( "<br />", '', $selectedreport["report"]); ?>
                        <div class="input-group mb-2">
                            <textarea id="froala-editor" name="report" class="form-control" value="" placeholder="Report.." required><?php echo $report; ?></textarea>
                        </div>
                        <div class="form-group">
                            <button type="submit" name="create" class="btn btn-primary btn-police">Edit Report</button>
                        </div>
                    </form>
                <?php } else { ?>
                    <form method="post">
                        <input type="hidden" name="type" value="create">
                        <input type="hidden" name="laws" class="report-law-punishments" value="">
                        <input type="hidden" name="total-fine" class="fines-law" value="">
                        <input type="hidden" name="author" class="form-control login-pass" value="<?php echo $_SESSION["name"]; ?>" placeholder="" required>
                        <div class="input-group mb-3">
                            <input type="text" name="title" class="form-control login-user" value="" placeholder="Title" required>
                        </div>
                        <?php if ($_SERVER['REQUEST_METHOD'] == "POST" && $_POST['type'] == "createnew") { ?>
                            <div class="input-group mb-3">
                                <input type="text" name="citizenid" class="form-control login-user" value="<?php echo $selectedprofile["citizenid"]; ?>" placeholder="Couple CSN (May be empty)">
                            </div>
                        <?php } else {?>
                            <div class="input-group mb-3">
                                <input type="text" name="citizenid" class="form-control login-user" value="" placeholder="Couple CSN (May be empty)">
                            </div>
                        <?php } ?>
                        <div class="input-group mb-2">
                            <textarea id="froala-editor" name="report" class="form-control" value="" placeholder="Report.." required></textarea>
                        </div>
                        <div class="form-group">
                            <button type="submit" name="create" class="btn btn-primary btn-police">Create Report</button>
                        </div>
                    </form>
                <?php } ?>
                </div>
                <?php if ($_SERVER['REQUEST_METHOD'] == "POST" && $_POST['type'] == "edit" && !empty($selectedreport)) { ?>
                    <div class="createreport-right">
                        <h5>Selected Fines</h5>
                        <p class="total-punishment">Total: $<?php echo $totalprice; ?> - <?php echo $totalmonths; ?> months</p>
                        <div class="added-laws">
                        <?php if (!empty($lawsedit_array)) { ?>
                            <?php foreach($lawsedit_array as $issalaw) { ?>
                                <div class="report-law-item" data-toggle="tooltip" data-html="true" title="<?php echo $issalaw["description"]; ?>">
                                    <h5 class="lawlist-title"><?php echo $issalaw["name"]; ?></h5>
                                    <p class="lawlist-fine">Boete: €<span class="fine-amount"><?php echo $issalaw["fine"]; ?></span></p>
                                    <p class="lawlist-months">Cel: <span class="months-amount"><?php echo $issalaw["months"]; ?></span> months</p>
                                </div>
                            <?php } ?>
                        <?php } ?>
                        </div>
                    </div>
                <?php } else { ?>
                    <div class="createreport-right">
                        <h5>Selected Fines</h5>
                        <p class="total-punishment">Total: $0 - 0 months</p>
                        <div class="added-laws">
                        </div>
                    </div>
                <?php } ?>
            </div>
            <?php if ($_SERVER['REQUEST_METHOD'] != "POST" || $_SERVER['REQUEST_METHOD'] == "POST" && $_POST['type'] != "edit") { ?>
                <button type="button" class="btn btn-primary btn-police" id="togglelaws" style="margin-bottom:2vh!important;">TOGGLE FINES</button>
                <div class="laws">
                    <div class="lawlist-search">
                        <div class="input-group input-group-sm mb-3">
                            <div class="input-group-prepend">
                            <span class="input-group-text" id="inputGroup-sizing-sm">Search</span>
                            </div>
                            <input type="text" class="lawsearch form-control" aria-label="Zoeken" aria-describedby="inputGroup-sizing-sm">
                        </div>
                    </div>
                    <?php foreach($laws_array as $law){?>
                        <div class="report-law-item-tab" data-toggle="tooltip" data-html="true" title="<?php echo $law['description']; ?>">
                            <input type="hidden" class="lawlist-id" value="<?php echo $law['id']; ?>">
                            <h5 class="lawlist-title"><?php echo $law['name']; ?></h5>
                            <p class="lawlist-fine">Fine: $<span class="fine-amount"><?php echo $law['fine']; ?></span></p>
                            <p class="lawlist-months">Jail: <span class="months-amount"><?php echo $law['months']; ?></span> months</p>
                        </div>
                    <?php }?>
                    </div>
                </div>
            <?php } ?>
        </main><!-- /.container -->

        <!-- Optional JavaScript -->
        <!-- jQuery first, then Popper.js, then Bootstrap JS -->
        <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
        <script src="assets/js/main.js"></script>

         <!-- Froala Text-Editor (THIS CODE IS NOT IN SEPERATE FILE BECAUSE OF TESTING) -->
         <script>
            let name = "<?php echo $firstname ?> <?php echo $lastname ?>";
            let rank = "<?php echo $_SESSION["rank"] ?>";
            let date = curday('-');
            let templates = [
                `<p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><img src="./assets/images/pv_logo.png" style="width: 205px;" class="fr-fic fr-dii"></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><span style="font-size: 14px;"><strong>EENHEID LOS SANTOS</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">DISTRICT LS-ZUID</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">BASISTEAM MISSION ROW</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><br></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style="vertical-align: baseline;"><strong>S M A L L - P O L I C E - R E P O R T</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style="background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;"><strong>beschikking</strong></span></p>
                <p >
                    <br>Me, reporting officer, ${name}, ${rank} of the Los Santos Police Unit, states the following.</p>
                <p >On ${date}, about <span style="color: rgb(235, 107, 86);">TIME</span> a clock, I was dressed in uniform and charged with general police duties on the public road,&nbsp;</p>
                <p style="line-height: 1.2;">FINDINGS</p>
                <p >Locatie:
                    <br>Gepleegde overtreding:
                    <br>Fact code:
                    <br>Penalty amount:
                    <br>Statement:&nbsp;</p>
                <p>
                    <br>
                    <br>
                </p>
                <p><em><span style="font-size: 10px;">If Speeding</span></em>
                    <br>Measured speed:
                    <br>Toegestane snelheid:
                    <br>Correction: - 10%
                    <br>Ultimate Speed:&nbsp;</p>

                `
                ,
                `<p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Logo_politie.svg/1200px-Logo_politie.svg.png" style="width: 205px;" class="fr-fic fr-dii"></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><span style="font-size: 14px; "><strong>UNIT LOS SANTOS</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">DISTRICT LS-SOUTH</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">BASETEAM MISSION ROW</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style=" vertical-align: baseline;"><strong>S E I Z U R E</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style=" background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;"><strong>voertuig</strong></span></p>
                <p>
                    <br>
                </p>
                <p>
                    <br>
                </p>
                <p >Me, reporting officer, ${name}, ${rank} of the Los Santos Police Unit, states the following. On ${date}, about <span style="color: rgb(235, 107, 86);">TIME</span> a clock, I have confiscated one or more goods from Mr / Ms <span style="color: rgb(235, 107, 86);">NAME</span>. </p>
                <p >
                    <br>
                </p>
                <p style=" line-height: 1.2;">FINDINGS</p>
                <p >
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Vehicle type:&nbsp;Car/Bike/Scooter
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Model/Type:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Color:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Licenseplate:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Reason:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Pick-up date:&nbsp;</p>
                <p >
                    <br>
                </p>`
               /* `<p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><img src="./assets/images/pv_logo.png" style="width: 205px;" class="fr-fic fr-dii"></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><span><strong>EENHEID LOS SANTOS</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span>DISTRICT LS-ZUID</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span>BASISTEAM MISSION ROW</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><span>Proces-verbaalnummer: (pv nummer)</span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style="vertical-align: baseline;"><strong>P R O C E S - V E R B A A L</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style="background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;"><strong>bewijsmateriaal</strong></span></p>
                <p>
                    <br>
                </p>
                <p>
                    <br>
                </p>
                <p>Ik, verbalisant, ${name}, ${rank} van Politie Eenheid Los Santos, verklaar het volgende.</p>
                <p>
                    <br>
                </p>
                <p style="line-height: 1.2;">BEVINDINGEN</p>
                <p >
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Adres Bedrijf/Winkel:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Datum/tijd:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Bewijs:&nbsp;</p>

                <p>
                    <br>
                </p> */
                ,
                `<p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><img src="./assets/images/pv_logo.png" style="width: 205px;" class="fr-fic fr-dii"></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><span style="font-size: 14px; "><strong>EENHEID LOS SANTOS</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">DISTRICT LS-ZUID</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">BASISTEAM MISSION ROW</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><br></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style=" vertical-align: baseline;"><strong>P O L I C E - R E P O R T</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style="background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;"><strong>aangifte</strong></span></p>
                <p >Feit:
                    <br>Crimescene:
                    <br>Commitment date / time:&nbsp;</p>
                <p >
                    <br>
                </p>
                <p >Me, reporting officer, ${name}, ${rank} of the Los Santos Police Unit, states the following.</p>
                <p >On ${date}, about <span style="color: rgb(235, 107, 86);">TIME</span> a clock, appeared infront of me, in the police station, Mission Row, Sinner Street, Los Santos, a person, the person reporting me to be:&nbsp;</p>
                <p >Achternaam:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Voornamen:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Geboren:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Geboorteplaats:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Geslacht:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Nationaliteit:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65);">Adres:&nbsp;</p>

                <p>He/She filed a report and stated the following about the incident referred to in the opening lines, which took place at the location referred to as the crime scene, on the aforementioned date/time.</p>
                <p style=" line-height: 1.2;">
                    <br>
                </p>
                <p style=" line-height: 1.2;">FINDINGS</p>
                <p >
                    <br>
                </p>
                <p >No one was given the right or consent to commit this offense.</p>
                <p >The officer,</p>
                <p >${name}</p>
                <p >
                    <br>
                </p>
                <p >Me, <span style="color: rgb(235, 107, 86);">NAME OF SIGNIFIER</span>, verklaar dat ik dit proces-verbaal heb gelezen. Ik verklaar dat ik de waarheid heb verteld. Ik verklaar dat mijn verhaal goed is weergegeven in het proces-verbaal. Ik weet dat het doen van een valse aangifte strafbaar is.</p>
                <p >De aangever,</p>
                <p style=" line-height: 1.2; color: rgb(235, 107, 86);">NAME OF SIGNIFIER</p>
                <p style=" line-height: 1.2; color: rgb(235, 107, 86);">
                    <br>
                </p>
                <p style=" line-height: 1.2; color: rgb(235, 107, 86);">
                    <br>
                </p>
                <p style=" line-height: 1.2;"><strong>Any comments reporter</strong></p>
                <p style=" line-height: 1.2;">
                    <br>
                </p>
                <p >Waarvan door mij is opgemaakt dit proces-verbaal, dat ik sloot en ondertekende te Los Santos op ${date}/<span style='color: rgb(235, 107, 86); font-size: 14px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;'>TIJD</span>&nbsp;</p>
                <p >${name}</p>`
                ,
                `<p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><img src="./assets/images/pv_logo.png" style="width: 205px;" class="fr-fic fr-dii"></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><span style="font-size: 14px; "><strong>EENHEID LOS SANTOS</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">DISTRICT LS-ZUID</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">BASISTEAM MISSION ROW</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><br></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style=" vertical-align: baseline;"><strong>P R O C E S - V E R B A A L</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style=" background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;"><strong>aanhouding</strong></span></p>
                <p >
                    <br>Ik, verbalisant, ${name}, ${rank} van Politie Eenheid Los Santos, verklaar het volgende.</p>
                <p >Op ${date}, omstreeks <span style="color: rgb(235, 107, 86);">TIJD</span> uur, bevond ik mij in uniform gekleed en met algemene politietaak belast op de openbare weg,</p>
                <p >Daar heb ik aangehouden:
                    <br>Een verdachte die op basis van nader identiteitsonderzoek, bleek te zijn:&nbsp;</p>
                <p >Achternaam:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Voornamen:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Geboren:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Geboorteplaats:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Geslacht:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Nationaliteit:&nbsp;
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-family: ;">Adres:&nbsp;</p>

                <p >
                    <br>
                </p>
                <p >Identiteitsfouillering:
                    <br>Ja/Nee</p>
                <p >Veiligheidsfouillering:
                    <br>Ja/Nee</p>
                <p >Inbeslagneming:
                    <br>Ja/Nee, zo ja wat?</p>
                <p >Gebruik transportboeien:
                    <br>Ja/Nee</p>
                <p >Gebruik geweld:
                    <br>Ja/Nee</p>
                <p >Rechtsbijstand:
                    <br>Ja/Nee</p>
                <p >
                    <br>
                </p>

                <p >Reden van aanhouding:
                    <br>De verdachte werd aangehouden als verdachte van overtreding van artikel(en).</p>
                <p >
                    <br>
                </p>
                <p style=" line-height: 1.2;">BEVINDINGEN</p>
                <p style=" line-height: 1.2;">
                    <br>
                </p>
                <p >Ik heb de verdachte tijdens de aanhouding verteld dat hij/zij zich mag beroepen op zijn zwijgrecht.</p>
                <p >
                    <br>
                </p>
                <p >Voorgeleiding:
                    <br>Op genoemd bureau werd de verdachte ten spoedigste voorgeleid voor de hulpofficier van justitie. Deze gaf op te <span style="color: rgb(235, 107, 86);">TIJD</span> uur het bevel de verdachte op te houden voor onderzoek.</p>
                <p >
                    <br>
                </p>
                <p >Waarvan door mij, ${name}, op ambtseed is opgemaakt, dit proces-verbaal te Los Santos op ${date}/<span style="color: rgb(235, 107, 86);">TIJD</span>.</p>
                <p >
                    <br>
                </p>
                <p >Strafeis:
                    <br>Gekregen straf:</p>`
                ,
                `<p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><img src="./assets/images/pv_logo.png" style="width: 205px;" class="fr-fic fr-dii"></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><span style="font-size: 14px; "><strong>EENHEID LOS SANTOS</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">DISTRICT LS-ZUID</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;"><strong><span style="font-size: 14px; ">BASISTEAM MISSION ROW</span></strong></p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: left; margin-top: 0pt; margin-bottom: 0pt;">
                    <br>
                </p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style=" vertical-align: baseline;"><strong>P R O C E S - V E R B A A L</strong></span></p>
                <p dir="ltr" style="line-height: 1.38; text-align: center; margin-top: 0pt; margin-bottom: 0pt;"><span style=" background-color: transparent; font-weight: 400; font-style: normal; font-variant: normal; text-decoration: none; vertical-align: baseline; white-space: pre-wrap;"><strong>bewijsmateriaal</strong></span></p>
                    <br>
                </p>
                <p >Ik, verbalisant, ${name}, ${rank} van Politie Eenheid Los Santos, verklaar het volgende.</p>
                <p >
                    <br>
                </p>
                <p style=" line-height: 1.2;">BEVINDINGEN</p>
                <p style=" line-height: 1.2;">
                    <br>
                </p>
                <p ><span style='color: rgb(65, 65, 65); font-size: 14px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;'>Adres Bedrijf/Winkel:&nbsp;</span>
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-size: 14px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial;"><span style='color: rgb(65, 65, 65); font-size: 14px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;'>Datum/tijd:&nbsp;</span>
                    <br style="box-sizing: border-box; color: rgb(65, 65, 65); font-size: 14px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial;"><span style='color: rgb(65, 65, 65); font-size: 14px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;'>Bewijs</span>:&nbsp;</p>
                <p >
                    <br>
                </p>`
            ];


            FroalaEditor.DefineIcon('sjablonen', {NAME: 'cog', SVG_KEY: 'add'});
            FroalaEditor.RegisterCommand('sjablonen', {
                title: 'Sjablonen',
                type: 'dropdown',
                focus: false,
                undo: true,
                refreshAfterCallback: true,
                options: {
                '0': 'Mini Proces Verbaal',
                '1': 'Voertuig Inbeslagname',
                '2': 'Proces Verbaal Aangifte',
                '3': 'Proces Verbaal Aanhouding',
                '4': 'Proces Verbaal Bewijsmateriaal'
                },
                callback: function (cmd, val) {
                    this.html.insert(templates[val]);
                },
                // Callback on refresh.
                refresh: function ($btn) {
                },
                // Callback on dropdown show.
                refreshOnShow: function ($btn, $dropdown) {
                },
            });

            new FroalaEditor('textarea#froala-editor', {
                width: '1000',
                attribution: false,
                imageUpload: false,
                useClasses: false,
                spellcheck: false,
                language: 'nl',
                placeholderText: "Rapportage opstellen...",
                toolbarButtons: 	{
                    'moreText': {
                        'buttons': ['bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript', 'fontSize', 'textColor', 'backgroundColor', 'clearFormatting']
                    },
                    'moreParagraph': {
                        'buttons': ['alignLeft', 'alignCenter', 'formatOLSimple', 'alignRight', 'alignJustify', 'formatOL', 'formatUL', 'paragraphFormat', 'lineHeight', 'outdent', 'indent'],
                        'buttonsVisible': 3
                    },
                    'moreRich': {
                        'buttons': [ 'sjablonen', 'insertLink', 'insertImage', 'insertTable', 'fontAwesome', 'specialCharacters', 'insertHR'],
                        'buttonsVisible': 3
                    },
                    'moreMisc': {
                        'buttons': ['undo', 'redo', 'fullscreen', 'spellChecker', 'selectAll', 'help'],
                        'align': 'right',
                        'buttonsVisible': 2
                    }
                },
                imageDefaultDisplay: 'block',
                imageInsertButtons: ['imageByURL'],
                imageEditButtons: ['imageReplace', 'imageAlign', 'imageSize', 'linkOpen', 'linkEdit', 'linkRemove', 'imageDisplay', 'imageAlt', 'imageRemove']
            });

            function curday(sp){
                today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth()+1; //As January is 0.
                var yyyy = today.getFullYear();

                if(dd<10) dd='0'+dd;
                if(mm<10) mm='0'+mm;
                return (dd+sp+mm+sp+yyyy);
            };

            setTimeout(() => {
                $("#logo").html("");
            }, 100);
        </script>
    </body>
</html>
