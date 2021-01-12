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
    <style>
        .map-container {
            overflow: hidden;
            padding-bottom: 56.25%;
            position: absolute;
            height: 0;
        }

        .map-container iframe {
            left: 0;
            top: 0;
            height: 100%;
            width: 100%;
            position: absolute;
        }
    </style>

    <!--Demmarrage du server sur le port 8000 : C:\xampp\php\php.exe -S localhost:8000 -t src/www-->
</head>

<body>
    <div class="w3-sidebar  w3-black w3-bar-block w3-border-right" style="display:none" id="mySidebar">
        <button onclick="w3_close()" class="w3-bar-item w3-large">Close &times;</button>
        <a href="materiel.php" class="w3-bar-item w3-button"><h3><i class="fa fa-wrench"> Gestion du matériel</i></h3></a>
        <a href="patient.php" class="w3-bar-item w3-button"><h3><i class="fa fa-bed"> Gestion des patients</i></h3></a>
        <a href="personnel.php" class="w3-bar-item w3-button"><h3><i class="fa fa-male"> Gestion du personnel</i></h3></a>
    </div>
    <div class=" w3-card  w3-green">
        <button class="w3-button w3-teal w3-xlarge" onclick="w3_open()">☰</button>
        <div class="w3-container">
            <h1 class="w3-center w3-green w3-padding w3-margin w3-xxlarge"><i>Projet CleanMed</i></h1>
        </div>
    </div>
    <div class="w3-padding w3-margin w3-card">
        <p class="w3-padding w3-margin w3-center"><i>Bonjour bienvenu ! </i><br> </p>
        <p class="w3-justify">Vous êtes ici sur votre site de gestion de clinique. Vous avez accès à toutes les informations que vous souhaitez. Il vous suffit de naviguer grâce à l'onglet disponible sur le côté gauche. Ce site va effectuer pour vous l'ensemble des requêtes dans la base de données de la clinique.</p>
    </div>
    <div class="w3-padding w3-margin">
        <div id="map-container-google-1" class="z-depth-1-half map-container" style="width:70%;height:200px">
            <iframe src="https://maps.google.com/maps?q=paris&t=&z=13&ie=UTF8&iwloc=&output=embed" frameborder="0" style="border:0" allowfullscreen></iframe>
        </div>
    </div>
</body>

</html>