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
    <script src="https://code.jquery.com/jquery-3.5.1.js" integrity="sha256-QWo7LDvxbWT2tbbQ97B53yJnYU3WhH/C8ycbRAkjPDc=" crossorigin="anonymous"></script>
    <script src="script.js"></script>

    <!--Demmarrage du server sur le port 8000 : C:\xampp\php\php.exe -S localhost:8000 -t src/www-->
</head>

<body>
    <div class="w3-sidebar w3-black w3-bar-block w3-border-right" style="display:none" id="mySidebar">
        <button onclick="w3_close()" class="w3-bar-item w3-large">Close &times;</button>
        <a href="index.php" class="w3-bar-item w3-button">
            <h3><i class="fa fa-home"> Accueil</i></h3>
        </a>
        <a href="materiel.php" class="w3-bar-item w3-button">
            <h3><i class="fa fa-wrench"> Gestion du matériel</i></h3>
        </a>
        <a href="personnel.php" class="w3-bar-item w3-button">
            <h3><i class="fa fa-male"> Gestion du personnel</i></h3>
        </a>
    </div>
    <div class=" w3-card  w3-green">
        <button class="w3-button w3-teal w3-xlarge" onclick="w3_open()">☰</button>
        <div class="w3-container">
            <h1 class="w3-center w3-padding w3-margin w3-xxlarge">Projet CleanMed</h1>
            <h3 class="w3-center w3-large"><i>Gestion des patients</i></h3>
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
        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }

        $result = mysqli_query($conn, "SELECT ID_consultation,Type_consultation, Montant,Symptomes,patient.Prenom_patient,
        patient.Nom_patient From consultation INNER JOIN patient on consultation.ID_patient = patient.ID_patient Where Diagnostic IS NULL;");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ('<div class="w3-container w3-center">
        <h2 class="w3-center w3-padding w3-margin">');
        echo ("Ajout d'un nouveau patient :</h2>");
        echo ('
        <form method="post">
          <h3 class="w3-center">Nom du patient :</h3>
            <input type=text class="w3-input" name="Nom" style="width:60%;margin-left:20%" required >
          <h3 class="w3-center ">Prénom du patient :</h3>
            <input type=text class="w3-input" name="Prenom" style="width:60%;margin-left:20%" required >
          <h3 class="w3-center ">Adresse du patient :</h3>
            <input type=text class="w3-input" name="Adresse" style="width:60%;margin-left:20%" required >
          <h3 class="w3-center  ">Code postale du patient :</h3>
            <input type=text class="w3-input" name="codepost" style="width:60%;margin-left:20%" required >
          <h3 class="w3-center ">Ville du patient :</h3>
            <input type=text class="w3-input" name="Ville" style="width:60%;margin-left:20%">
          <h3 class="w3-center  ">Mail du patient :</h3>
            <input type=text class="w3-input" name="Mail" style="width:60%;margin-left:20%" required >
          <h3 class="w3-center  ">Téléphone du patient</h3>
            <input type=text class="w3-input" name="Tel" style="width:60%;margin-left:20%" required >
          <h3 class="w3-center  ">Age du patient :</h3>
          <div class="w3-bar">
            <div class="w3-bar-item">
                <input type="number" min="0" max="100" required class="w3-input" name="Age" style="width:60%;margin-left:20%">
            </div>
            <div class="w3-bar-item">
                <p>ans</p>
            </div>
          </div>
          <h3 class="w3-center">Poids du patient :</h3>
          <div class="w3-bar">
          <div class="w3-bar-item">
              <input type="number" min="0" max="300" required class="w3-input" name="Poids" style="width:60%;margin-left:20%">
          </div>
          <div class="w3-bar-item">
              <p>Kg</p>
          </div>
            </div>
            <h3 class="w3-center">Taille du patient :</h3>
            <div class="w3-bar">
            <div class="w3-bar-item">
                <input type="number" min="50" max="300" required class="w3-input" name="Taille" style="width:60%;margin-left:20%">
            </div>
            <div class="w3-bar-item">
                <p>cm</p>
            </div>
            </div>
            <h3 class="w3-center">Sexe du patient :</h3>
            <select name="CB_sexe" class="w3-select w3-center" style="width:60%" required>
                <option value="M">Masculin</option>
                <option value="F">Féminin</option>
            </select>
            <h3 class="w3-center">Allergies du patient</h3>
                <input type=text class="w3-input" name="All" style="width:60%;margin-left:20%">
            <h3 class="w3-center">CMU ou sécurité sociale du patient</h3>
                <input type="checkbox" class="w3-input" name="CMU" checked>');
        $result = mysqli_query($conn, "SELECT * FROM Mutuelle");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ("<h3 class='w3-center w3-padding w3-margin'>Mutuelle du patient :</h3>
            <select name='CB_mutuelle' class='w3-select w3-center' style='width:60%'required >
          ");
        do {
            $num = $row['ID_mutuelle'];
            $typemut = $row['Nom_mutuelle'];
            echo ("<option value='" . $num . "'>
               " . $num . " - " . $typemut . "
                    </option>
              ");
        } while ($row = mysqli_fetch_array($result));
        echo ('</select>');
        $result->close();
        $result = mysqli_query($conn, "SELECT * FROM Etablissement");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ("<h3 class='w3-center w3-padding w3-margin'>Etablissement du patient :</h3>
            <select name='CB_etab' class='w3-select w3-center' style='width:60%'required >
          ");
        do {
            $id = $row['ID_etablissement'];
            $add = $row['Adresse_etablissement'];
            $postcode = $row['Code_postale_etablissement'];
            $ville = $row['Ville_etablissement'];
            echo ("<option value='" . $id . "'>
               " . $id . " - " . $add . " - " . $postcode . " " . $ville . "
                    </option>
              ");
        } while ($row = mysqli_fetch_array($result));
        echo ('</select>');
        $result->close();
        echo ('<br><br>
        <input type=submit name="Valider4" value="Valider" class="w3-button w3-green">
        </form>
        </div>');
        $conn->close();
    } else if (isset($_POST["Patients"])) {
        $servername = 'localhost';
        $username = 'root';
        $password = '';
        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }
        $result = mysqli_query($conn, "SELECT
        ID_patient,
        Nom_patient,
        prenom_patient,
        Adresse_patient,
        Code_postale_patient,
        Ville_patient,
        Mail_patient,
        Telephone_patient,
        Age_patient,
        Poids_patient,
        Taille_patient,
        Sexe_patient,
        Allergie,
        Securite_sociale_CMU,
        mutuelle.nom_mutuelle,
        ID_etablissement
    FROM
        `patient`
    INNER JOIN mutuelle ON patient.ID_mutuelle = mutuelle.ID_mutuelle
    WHERE
        1 ORDER BY Nom_patient");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ('
        <div class=" w3-container">
        <h2 class="w3-center w3-padding w3-margin">Voici la liste de tous les patients :</h2>
      
        <table class="w3-table-all w3-centered w3-striped">
          <tr class="w3-gray w3-text-white">
          <th>Matricule du patient</th>
            <th>Nom et prénom du patient</th>
            <th>Adresse du patient</th>
            <th>Mail du patient</th>
            <th>Téléphone du patient</th>
            <th>Age du patient</th>
            <th>Poids du patient</th>
            <th>Taille du patient</th>
            <th>Sexe du patient</th>
            <th>Allergies du patient</th>
            <th>Tributaire éligible la sécurité sociale/CMU</th>
            <th>Nom de la mutuelle du patient</th>
            <th>Etablissement</th>
          </tr>');

        do {
            $id = $row['ID_patient'];
            $nom = $row['Nom_patient'];
            $prenom = $row['prenom_patient'];
            $add = $row['Adresse_patient'];
            $codpost = $row['Code_postale_patient'];
            $ville = $row['Ville_patient'];
            $mail = $row['Mail_patient'];
            $tel = $row['Telephone_patient'];
            $age = $row['Age_patient'];
            $poids = $row['Poids_patient'];
            $taille = $row['Taille_patient'];
            $sexe = $row['Sexe_patient'];
            $all = $row['Allergie'];
            $cmu = $row['Securite_sociale_CMU'];
            $mut = $row['nom_mutuelle'];
            $etab = $row['ID_etablissement'];
            echo ("
                <tr>
                <td>" . $id . "</td>
                <td>" . $nom . " " . $prenom . "</td>
                <td>" . $add . " - " . $codpost . " " . $ville . "</td>
                <td>" . $mail . "</td>
                <td>" . $tel . "</td>
                <td>" . $age . " ans</td>
                <td>" . $poids . " kg</td>
                <td>" . $taille . " cm</td>
                <td>" . $sexe . "</td>
                <td>" . $all . "</td>
                <td>" . $cmu . "</td>
                <td>" . $mut . "</td>
                <td>" . $etab . "</td>
                </tr>
          ");
        } while ($row = mysqli_fetch_array($result));
        echo (" </table>
        </div>
       ");
        $result->close();
        $conn->close();
    } else if (isset($_POST["Montant"])) {
        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }
        $result = mysqli_query($conn, "SELECT * FROM `montant_par_patient`");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ('
        <div class=" w3-container">
        <h2 class="w3-center w3-padding w3-margin">Voici le montant total payé par patient :</h2>
      
        <table class="w3-table-all w3-centered w3-striped">
          <tr class="w3-gray w3-text-white">
            <th>Nom du patient</th>
            <th>Prénom du patient</th>
            <th>Montant total payé</th>
          </tr>');

        do {
            $nom = $row['Nom_patient'];
            $prenom = $row['Prenom_patient'];
            $montant = $row['Montant_paye_par_patient'];
            echo ("
                <tr>
                <td>" . $nom . "</td>
                <td>" . $prenom . "</td>
                <td>" . $montant . "€</td>
                </tr>
          ");
        } while ($row = mysqli_fetch_array($result));
        echo (" </table>
        </div>
       ");


        $result->close();
        $conn->close();
    } else if (isset($_POST["Diagnostic"])) {
        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }

        $result = mysqli_query($conn, "SELECT ID_consultation,Type_consultation, Montant,Symptomes,patient.Prenom_patient,
        patient.Nom_patient From consultation INNER JOIN patient on consultation.ID_patient = patient.ID_patient Where Diagnostic IS NULL;");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ('<div class="w3-container w3-center">
        <h3 class="w3-center w3-padding w3-margin">Selectionnez la consultation en question :</h3>
        <form method="post">
        <select name="CB_consult" class="w3-select w3-center" style="width:60%">
      ');
        do {
            $num = $row['ID_consultation'];
            $type = $row['Type_consultation'];
            $montant = $row['Montant'];
            $symp = $row['Symptomes'];
            $nom = $row['Nom_patient'];
            $prenom = $row['Prenom_patient'];
            echo ("<option value='" . $num . "'>
           " . $type . " - " . $montant . " € - " . $symp . " - 
               " . $nom . " 
                " . $prenom . "
                </option>
          ");
        } while ($row = mysqli_fetch_array($result));
        echo (' </select>
        <h3 class="w3-center w3-padding w3-margin">Ajouter le diagnostic :</h3>
        <input type=text class="w3-input" name="Diag" style="width:60%;margin-left:20%">
        <br>
        <input type=submit name="Valider3" value="Valider" class="w3-button w3-green">
        </form>
        </div>');
    } else if (isset($_POST["Nouvelle_consultation"])) {











        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }
        echo ('<div class="w3-container w3-center">
        <h2 class="w3-center w3-padding w3-margin">');
        echo ("Ajout d'une nouvelle consultation :</h2>");
        echo ('
        <form method="post">
        <h3 class="w3-center">Sexe du patient :</h3>
        <select name="CB_type" class="w3-select w3-center" style="width:60%" required>
            <option value="Rendez-vous">Rendez-vous</option>
            <option value="Hospitalisation">Hospitalisation</option>
        </select>
        <h3 class="w3-center  ">Prix de la consultation :</h3>
        <div class="w3-bar">
            <div class="w3-bar-item">
                <input type="number" min="0" max="2000" value="200" required class="w3-input" name="montant" style="width:60%;margin-left:20%">
            </div>
            <div class="w3-bar-item">
                <p>€</p>
            </div>
        </div>
        <h3 class="w3-center">Symptômes :</h3>
        <input type=text class="w3-input" name="symptomes" style="width:60%;margin-left:20%" required >');



        $result = mysqli_query($conn, "SELECT * FROM Patient");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ("<h3 class='w3-center w3-padding w3-margin'>Patient en question :</h3>
            <select name='CB_patient' class='w3-select w3-center' style='width:60%'required >
          ");
        do {
            $id = $row['ID_patient'];
            $nom = $row['Nom_patient'];
            $prenom = $row['Prenom_patient'];
            echo ("<option value='" . $id . "'>
               " . $nom . " " . $prenom . "
                    </option>
              ");
        } while ($row = mysqli_fetch_array($result));
        echo ('</select>');
        $result = mysqli_query($conn, "SELECT * FROM personnel");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ("<h3 class='w3-center w3-padding w3-margin'>Personnel en question :</h3>
            <select name='Cb_personnel' class='w3-select w3-center' style='width:60%'required >
          ");
        do {
            $num = $row['ID_personnel'];
            $nom = $row['Nom_personnel'];
            $prenom = $row['Prenom_personnel'];
            echo ("<option value='" . $num . "'>
               " . $nom . " " . $prenom . "
                    </option>
              ");
        } while ($row = mysqli_fetch_array($result));
        echo ('</select>');
        $result = mysqli_query($conn, "SELECT * FROM Jour");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ("<h3 class='w3-center w3-padding w3-margin'>Jour de début :</h3>
            <select name='Cb_jour_entree' class='w3-select w3-center' style='width:60%'required >
          ");
        do {
            $id = $row['ID_jour'];
            $j = $row['Date_jour'];
            echo ("<option value='" . $id . "'>
               " . $j . "
                    </option>
              ");
        } while ($row = mysqli_fetch_array($result));
        echo ('</select>
        <h3 class="w3-center w3-padding w3-margin">Heure de début :</h3>
        <input type="time" name="heure_debut" step="2"
        min="01:00" max="00:00" required>');

        $result = mysqli_query($conn, "SELECT * FROM Jour");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ("<h3 class='w3-center w3-padding w3-margin'>Jour de fin :</h3>
            <select name='Cb_jour_sortie' class='w3-select w3-center' style='width:60%'required >
          ");
        do {
            $id = $row['ID_jour'];
            $j = $row['Date_jour'];
            echo ("<option value='" . $id . "'>
               " . $j . "
                    </option>
              ");
        } while ($row = mysqli_fetch_array($result));
        echo ('</select><h3 class="w3-center w3-padding w3-margin">Heure de fin :</h3>
        <input type="time" name="heure_fin"step="2"
        min="01:00:00" max="00:00:00" required>');
        $result->close();
        echo ('<br><br>
        <input type=submit name="Valider5" value="Valider" class="w3-button w3-green">
        </form>
        </div>');
        $conn->close();
    } else if (isset($_POST["Historique_patient"])) {

        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }

        $result = mysqli_query($conn, "SELECT Nom_patient, Prenom_patient FROM patient");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ('<div class="w3-container w3-center">
        <h2 class="w3-center w3-padding w3-margin">Selectionnez le patient en question :</h2>
        <form method="post">
        <select name="CB_patient" class="w3-select w3-center" style="width:60%">
      ');
        do {
            $nom = $row['Nom_patient'];
            $prenom = $row['Prenom_patient'];
            echo ("<option value='" . $nom . "'>
               " . $nom . " 
                " . $prenom . "
                </option>
          ");
        } while ($row = mysqli_fetch_array($result));
        echo (' </select>
        <input type=submit name="Valider" value="Valider" class="w3-button w3-green">
        </form>
        </div>');
        $result->close();
        $conn->close();
    } else if (isset($_POST["Examen"])) {
        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }

        $result = mysqli_query($conn, "SELECT ID_consultation,Type_consultation, Montant,Symptomes,patient.Prenom_patient,
        patient.Nom_patient From consultation INNER JOIN patient on consultation.ID_patient = patient.ID_patient;");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ('<div class="w3-container w3-center">
        <h3 class="w3-center w3-padding w3-margin">Selectionnez la consultation en question :</h3>
        <form method="post">
        <select name="CB_consult" class="w3-select w3-center" style="width:60%">
      ');
        do {
            $num = $row['ID_consultation'];
            $type = $row['Type_consultation'];
            $montant = $row['Montant'];
            $symp = $row['Symptomes'];
            $nom = $row['Nom_patient'];
            $prenom = $row['Prenom_patient'];
            echo ("<option value='" . $num . "'>
           " . $type . " - " . $montant . " € - " . $symp . " - 
               " . $nom . " 
                " . $prenom . "
                </option>
          ");
        } while ($row = mysqli_fetch_array($result));
        echo (' </select><br>');

        $result = mysqli_query($conn, "SELECT * FROM Examen");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ("<div class='w3-container w3-center'>
        <h3 class='w3-center w3-padding w3-margin'>Selectionnez l'examen en question :</h3>
        <select name='CB_exam' class='w3-select w3-center' style='width:60%'>
      ");
        do {
            $num = $row['ID_examen'];
            $typExam = $row['Nom_examen'];
            echo ("<option value='" . $num . "'>
           " . $num . " - " . $typExam . "
                </option>
          ");
        } while ($row = mysqli_fetch_array($result));
        echo (' </select><br><br>');
        $result = mysqli_query($conn, "SELECT * FROM Jour");
        $row = mysqli_fetch_array($result);
        if ($result) {
            // printf("\nSelect a retourné %d lignes :", $result->num_rows);
        }
        echo ("<div class='w3-container w3-center'>
        <h3 class='w3-center w3-padding w3-margin'>Selectionnez l'examen en question :</h3>
        <select name='CB_jour' class='w3-select w3-center' style='width:60%'>
      ");
        do {
            $num = $row['ID_jour'];
            $jour = $row['Date_jour'];
            echo ("<option value='" . $jour . "'>
           " . $jour . "
                </option>
          ");
        } while ($row = mysqli_fetch_array($result));
        echo (' </select><br>');
        echo ('<br>
        <input type=submit name="Valider2" value="Valider" class="w3-button w3-green">
        </form>
        </div>');
        $result->close();
        $conn->close();
    }
    if (isset($_POST["Valider2"])) {
        $choixE = $_POST['CB_exam'];
        $choixC = $_POST['CB_consult'];
        $choixJ = $_POST['CB_jour'];
        // echo ($choix);
        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }
        $result = mysqli_query($conn, "INSERT INTO passer(ID_consultation,ID_examen,Date_examen) VALUES
        (" . $choixC . "," . $choixE . ",'" . $choixJ . "')");
        echo ('<h3 class="w3-center w3-text-green w3-padding w3-margin">Examen bien pris en compte !</h3>');
        $conn->close();
    }
    if (isset($_POST["Valider3"])) {
        $choixD = $_POST['Diag'];
        $choixC = $_POST['CB_consult'];

        // echo ($choix);
        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }
        $result = mysqli_query($conn, "UPDATE consultation
        SET consultation.Diagnostic = '" . $choixD . "'
        WHERE consultation.ID_consultation = " . $choixC);
        echo ('<h3 class="w3-center w3-text-green w3-padding w3-margin">Examen bien pris en compte !</h3>');
        $conn->close();
    }


    if (isset($_POST["Valider4"])) {

        $nom = $_POST['Nom'];
        $etabli = $_POST['CB_etab'];
        $prenom = $_POST['Prenom'];
        $adr = $_POST['Adresse'];
        $postcode = $_POST['codepost'];
        $ville = $_POST['Ville'];
        $mail = $_POST['Mail'];
        $tel = $_POST['Tel'];
        $age = $_POST['Age'];
        $all = $_POST['All'];
        $poids = $_POST['Poids'];
        $taille = $_POST['Taille'];
        if ($_POST['CMU']) {
            $cmu = 1;
        } else {
            $cmu = 0;
        }
        $sexe = $_POST['CB_sexe'];
        $mut = $_POST['CB_mutuelle'];

        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }
        $result = mysqli_query($conn, "INSERT INTO patient(
        Nom_patient,
        Prenom_patient,
        Adresse_patient,
        Code_postale_patient
        ,Ville_patient
        ,Mail_patient
        , Telephone_patient
        ,Age_patient
        ,Poids_patient
        ,Taille_patient
        ,Sexe_patient
        ,Allergie,
        Securite_sociale_CMU,
        ID_mutuelle,
        ID_etablissement
        ) VALUES(
        '" . $nom . "',
        '" . $prenom . "',
        '" . $adr . "',
        " . $postcode . ",
        '" . $ville . "',
        '" . $mail . "',
        '" . $tel . "',
        " . $age . ",
        " . $poids . ",
        " . $taille . ",
        '" . $sexe . "',
        '" . $all . "',
        " . $cmu . ",
        " . $mut . ",
        " . $etabli . ")");
        echo ('<h3 class="w3-center w3-text-green w3-padding w3-margin">Patient bien ajouté !</h3>');
        $conn->close();
    }

    if (isset($_POST["Valider"])) {
        $choix = $_POST['CB_patient'];
        // echo ($choix);
        $servername = 'localhost';
        $username = 'root';
        $password = '';

        //On établit la connexion
        $conn = new \MySQLi($servername, $username, $password);
        //On vérifie la connexion
        if ($conn->connect_error) {
            die('Erreur : ' . $conn->connect_error);
        }
        //echo 'Connexion réussie <br>';
        $db_selected = mysqli_select_db($conn, 'clinique');
        if (!$db_selected) {
            die('Impossible de sélectionner la base de données : ' . mysqli_error($conn));
        }
        $result = mysqli_query($conn, "SELECT Nom_patient, ID_consultation, Type_consultation, Montant, Symptomes, Diagnostic, Heure_debut
        FROM Consultation
        INNER JOIN Patient ON Consultation.ID_patient = Patient.ID_patient
        WHERE nom_patient = '" . $choix . "';");
        $row = mysqli_fetch_array($result);
        if ($result->num_rows > 0) {
            //$row = mysqli_fetch_array($result);
            if ($result) {
                //  printf("\nSelect a retourné %d lignes :", $result->num_rows);
            }
            echo ('<div class="w3-container">
        <h2 class="w3-center w3-padding w3-margin">Historique de M. ' . $choix . ' :</h2>
      
        <table class="w3-table-all w3-centered w3-striped">
          <tr class="w3-gray w3-text-white">
            <th>Nom du patient</th>
            <th>Numéro de consultation</th>
            <th>Type de consultation</th>
            <th>Montant de la consultation</th>
            <th>Symptômes</th>
            <th>Diagnostic</th>
            <th>Heure de début</th>
          </tr>');
            do {
                $nom = $row['Nom_patient'];
                $cons = $row['ID_consultation'];
                $type = $row['Type_consultation'];
                $montant = $row['Montant'];
                $symp = $row['Symptomes'];
                $diag = $row['Diagnostic'];
                $heure = $row['Heure_debut'];
                echo ("
                <tr>
                <td>" . $nom . "</td>
                <td>" . $cons . "</td>
                <td>" . $type . "</td>
                <td>" . $montant . " €</td>
                <td>" . $symp . "</td>
                <td>" . $diag . "</td>
                <td>" . $heure . "</td>
                </tr>
          ");
            } while ($row = mysqli_fetch_array($result));
            echo (" </table>
        </div>");
            $result->close();
        } else {
            echo ('<h3 class="w3-center w3-text-red w3-padding w3-margin">Aucun historique pour ce patient...</h3>');
        }
        $conn->close();
    }
    ?>

</body>