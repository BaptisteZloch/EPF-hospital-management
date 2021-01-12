<!DOCTYPE html>
<html lang="fr">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CleanMed</title>
    <link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" integrity="sha384-HSMxcRTRxnN+Bdg0JdbxYKrThecOKuH5zCYotlSAcp1+c8xmyTe9GYg1l9a69psu" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <script src="https://canvasjs.com/assets/script/canvasjs.min.js"></script>
    <script src="script.js"></script>

    <!--Demmarrage du server sur le port 8000 : C:\xampp\php\php.exe -S localhost:8000 -t src/www-->
</head>

<body>
    <div class="w3-sidebar  w3-black w3-bar-block w3-border-right" style="display:none" id="mySidebar">
        <button onclick="w3_close()" class="w3-bar-item w3-large">Close &times;</button>
        <a href="index.php" class="w3-bar-item w3-button">
            <h3><i class="fa fa-home"> Accueil</i></h3>
        </a>
        <a href="patient.php" class="w3-bar-item w3-button">
            <h3><i class="fa fa-bed"> Gestion des patients</i></h3>
        </a>
        <a href="personnel.php" class="w3-bar-item w3-button">
            <h3><i class="fa fa-male"> Gestion du personnel</i></h3>
        </a>
    </div>
    <div class=" w3-card  w3-green">
        <button class="w3-button w3-teal w3-xlarge" onclick="w3_open()">☰</button>
        <div class="w3-container">
            <h1 class="w3-center w3-padding w3-margin w3-xxlarge">Projet CleanMed</h1>
            <h3 class="w3-center w3-large"><i>Gestion du matériel</i></h3>
        </div>
    </div>
    <div class="w3-bar w3-blue">
        <form method="POST">
            <input type=submit name="Ajouter" value="Ajouter" class="w3-button w3-bar-item">
            <input type=submit name="Montant" value="Montant" class="w3-button w3-bar-item">
            <input type=submit name="Diagnostic" value="Diagnostic" class="w3-button w3-bar-item">
            <input type=submit name="Nouvelle_consultation" value="Nouvelle consultation" class="w3-button w3-bar-item">
            <input type=submit name="Historique_patient" value="Historique patient" class="w3-button w3-bar-item">
            <input type=submit name="Examen" value="Examen" class="w3-button w3-bar-item">
            <input type=submit name="Patients" value="Les patients" class="w3-button w3-bar-item">
        </form>
    </div>

    <?php
    if (isset($_POST["Ajouter"])) {
    }
    ?>

</body>