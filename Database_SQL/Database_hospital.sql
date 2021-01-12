-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 17 déc. 2020 à 15:09
-- Version du serveur :  10.4.17-MariaDB
-- Version de PHP : 8.0.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `clinique`
--
CREATE DATABASE IF NOT EXISTS `clinique` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `clinique`;

DELIMITER $$
--
-- Procédures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Ajouter_materiel` (IN `Nom du matériel` VARCHAR(100), IN `Fournisseur` VARCHAR(100), IN `Service concerné` VARCHAR(100), IN `Numero établissement concerné` INT(5), IN `Prix unitaire` FLOAT, IN `Optionnel : Quantité (pensement, compresses...)` INT)  NO SQL
IF ISNULL(`Optionnel : Quantité (pensement, compresses...)`) THEN
INSERT INTO materiel(Nom_materiel,Prix_unitaire,ID_service,ID_fournisseur) VALUES
(`Nom du matériel`,`Prix unitaire`, (SELECT service.ID_service FROM service INNER JOIN etablissement ON service.ID_etablissement= etablissement.ID_etablissement WHERE service.Nom_service = `Service concerné` AND etablissement.ID_etablissement = `Numero établissement concerné`),(SELECT fournisseur.ID_fournisseur FROM fournisseur WHERE fournisseur.Nom_fournisseur = `Fournisseur` ));
ELSE 
INSERT INTO materiel(Nom_materiel,Quantité_materiel,Prix_unitaire,ID_service,ID_fournisseur) VALUES
(`Nom du matériel`,`Optionnel : Quantité (pensement, compresses...)`,`Prix unitaire`, (SELECT service.ID_service FROM service INNER JOIN etablissement ON service.ID_etablissement= etablissement.ID_etablissement WHERE service.Nom_service = `Service concerné` AND etablissement.ID_etablissement = `Numero établissement concerné`),(SELECT fournisseur.ID_fournisseur FROM fournisseur WHERE fournisseur.Nom_fournisseur = `Fournisseur` ));
END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Ajout_diagnostic` (IN `Numero de consultation` INT(5), IN `Diagnostic` VARCHAR(200))  NO SQL
UPDATE consultation
SET consultation.Diagnostic = `Diagnostic`
WHERE consultation.ID_consultation = `Numero de consultation`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Contenu_commande_materiel` (IN `Numero de la commande` INT(5), IN `Numero du service concerné` INT(5), IN `Nom du matériel` VARCHAR(100), IN `Quantité de matériel` INT)  NO SQL
INSERT INTO contenir_4
   (ID_materiel  ,
      ID_commande,
      Quantite_materiel
   )
   VALUES
   (
   (
      SELECT
         materiel.ID_materiel
      FROM
         materiel
      WHERE
         materiel.Nom_materiel   = `Nom du matériel`
         /*AND materiel.ID_service = `Numero du service concerné`*/
       limit 1
   )
   ,
   `Numero de la commande`,
   `Quantité de matériel`
   )$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Contenu_commande_medicament` (IN `Numero de la commande` INT(5), IN `Nom du médicament` VARCHAR(100), IN `Nombre de boîtes` INT)  NO SQL
INSERT INTO contenir_3(ID_commande,ID_medicament,Quantite_medicament)
VALUES (`Numero de la commande`, (SELECT medicament.ID_medicament FROM medicament WHERE medicament.Nom_medicament = `Nom du médicament`),`Nombre de boîtes`)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Creation_commande` (IN `Date (AAAA-MM-JJ)` DATE, IN `Adresse établissement` VARCHAR(100))  INSERT INTO commande (Date_commande, ID_etablissement)
VALUES (`Date (AAAA-MM-JJ)`,(SELECT etablissement.ID_etablissement FROM etablissement WHERE etablissement.Adresse_etablissement = `Adresse établissement`))$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Date_maintenance` (IN `Nom du matériel` VARCHAR(100), IN `Numéro du matériel concerné` INT(5), IN `Date de maintenance (AAAA-MM-JJ)` DATE)  NO SQL
UPDATE materiel
SET materiel.Date_derniere_maintenance = `Date de maintenance (AAAA-MM-JJ)`
WHERE materiel.ID_materiel = `Numéro du matériel concerné` AND materiel.Nom_materiel = `Nom du matériel`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Medicament_prescription` (IN `Numero de la consultation` INT, IN `Nom du médicament` VARCHAR(100), IN `Nombre de boites` INT, IN `Date de début (AAAA-MM-JJ)` DATE, IN `Nombre de jour` INT, IN `Fréquence` VARCHAR(100))  NO SQL
BEGIN
   INSERT INTO contenir
      (ID_consultation       ,
         ID_medicament       ,
         Quantite_medicament ,
         Date_prescrption    ,
         Duree_prescription  ,
         Frequence_prise
      )
      VALUES
      (`Numero de la consultation` ,
         (
            SELECT
               medicament.ID_medicament
            FROM
               medicament
            WHERE
               medicament.Nom_medicament = `Nom du médicament`
         )
         ,
         `Nombre de boites`           ,
         `Date de début (AAAA-MM-JJ)` ,
         `Nombre de jour`             ,
         `Fréquence`
      )
   ;
   
   UPDATE
      medicament
   SET medicament.Quantite_nb_boites = medicament.Quantite_nb_boites - `Nombre de boites`
   WHERE
      medicament.ID_medicament =
      (
         SELECT
            medicament.ID_medicament
         FROM
            medicament
         WHERE
            medicament.Nom_medicament = `Nom du médicament`
      )
   ;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Modification_patient` (IN `Numero du patient` INT(5), IN `Age` INT(3), IN `Taille (cm)` FLOAT, IN `Poids (kg)` FLOAT, IN `Allergies` VARCHAR(100))  NO SQL
IF ISNULL(`Age`) = 0 THEN
UPDATE patient
SET patient.Age_patient = `Age`
WHERE patient.ID_patient = `Numero du patient`;
ELSEIF ISNULL(`Taille (cm)`) THEN
UPDATE patient
SET patient.Taille_patient= `Taille (cm)`
WHERE patient.ID_patient = `Numero du patient`;
ELSEIF ISNULL(`Poids (kg)`) THEN
UPDATE patient
SET patient.Poids_patient = `Poids (kg)`
WHERE patient.ID_patient = `Numero du patient`;
ELSEIF ISNULL(`Allergies`) THEN
UPDATE patient
SET patient.Allergie = CONCAT(patient.Allergie, `Allergies`)
WHERE patient.ID_patient = `Numero du patient`;
END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Nouvelle_consultation` (IN `Nom du patient` VARCHAR(100), IN `Prénom du patient` VARCHAR(100), IN `Type de consultation` ENUM('Rendez-vous','Hospitalisation'), IN `Prix` FLOAT, IN `Symptômes` VARCHAR(200), IN `Heure de début` TIME, IN `Heure de fin` TIME, IN `Date de début` DATE, IN `Date de fin` DATE, IN `Nom du personnel` VARCHAR(200), IN `Prénom du personnel` VARCHAR(200))  NO SQL
INSERT into consultation
   (Type_consultation,
      montant        ,
      symptomes      ,
      Heure_debut    ,
      Heure_fin      ,
      ID_patient     ,
      ID_personnel   ,
      ID_jour_entree ,
      ID_jour_sortie
   )
   VALUES
   (`Type de consultation`,
      `Prix`              ,
      `Symptômes`         ,
      `Heure de début`    ,
      `Heure de fin`      ,
      (
         SELECT
            patient.ID_patient
         From
            Patient
         WHERE
            patient.Nom_patient        = `Nom du patient`
            And patient.Prenom_patient =`Prénom du patient`
      )
      ,
      (
         SELECT
            personnel.ID_personnel
         From
            Personnel
         WHERE
            personnel.Nom_personnel        = `Nom du personnel`
            And personnel.Prenom_personnel =`Prénom du personnel`
          LIMIT 1
      )
      ,
      (
         SELECT
            jour.ID_jour
         From
            jour
         WHERE
            jour.Date_jour = `Date de début`
      )
      ,
      (
         SELECT
            jour.ID_jour
         From
            jour
         WHERE
            jour.Date_jour = `Date de fin`
      )
   )$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Occupation_chambre_par_service` (IN `Service` ENUM('Ophtalmologie','Oncologie','Urgence','Psychiatrie','Urologie','Dermatologie','Endocrinologie','Dépistage','Médecine générale','Chirurgie','Imagerie','Neurochirurgie','Covid19','Réanimation'), IN `Numero établissement` INT(5), IN `Date choisie (AAAA-MM-JJ)` DATE)  NO SQL
SELECT
   patient.Nom_patient   ,
   patient.Prenom_patient,
   service.Nom_service   ,
   chambre.ID_chambre AS `Numéro de chambre`
FROM
   patient
   INNER JOIN
      occuper
      ON
         patient.ID_patient = occuper.ID_patient
   INNER JOIN
      chambre
      ON
         occuper.ID_chambre = chambre.ID_chambre
   INNER JOIN
      service
      ON
         service.ID_service = chambre.ID_service
WHERE
   service.Nom_service          = `Service`
   AND service.ID_etablissement = `Numero établissement`
   AND occuper.Date_occuper     = `Date choisie (AAAA-MM-JJ)`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Prescription_examen` (IN `Numero_consultation` INT(5), IN `Type_examen` VARCHAR(100), IN `Date de l'examen(AAAA-MM-DD)` DATE)  INSERT INTO passer(ID_consultation,ID_examen,Date_examen) VALUES
(Numero_consultation,(SELECT examen.ID_examen FROM examen WHERE examen.Nom_examen = Type_examen),`Date de l'examen(AAAA-MM-DD)`)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Recherche_de_personnel` (IN `Nom_du_Personnel` VARCHAR(50))  SELECT service.Nom_service, personnel.Nom_personnel, personnel.Prenom_personnel  
FROM personnel
INNER JOIN service ON personnel.ID_service=service.ID_service
WHERE INSTR(personnel.Nom_personnel , Nom_du_Personnel) != 0 /* au cas ou le personne ne tape pas un texte correspondant on verifie si la chaine est contenu*/$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Recherche_patient` (IN `Patient_Nom` VARCHAR(100))  SELECT patient.Nom_patient, Consultation.ID_consultation, consultation.Type_consultation, consultation.Montant, consultation.Symptomes, consultation.Diagnostic, consultation.Heure_debut
FROM Consultation
INNER JOIN Patient ON Consultation.ID_patient = Patient.ID_patient
WHERE Patient.nom_patient = Patient_Nom Or Patient.nom_patient LIKE concat(`Patient_Nom`,'%')$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Rendez_vous_semaine_prochaine` (IN `Numero_Semaine` INT(2), IN `Service_concerne` VARCHAR(50))  NO SQL
SELECT * FROM Consultation

INNER JOIN Jour ON Consultation.ID_jour_entree = Jour.ID_jour

INNER JOIN Personnel ON Consultation.ID_personnel = Personnel.ID_personnel

INNER JOIN Service ON Personnel.ID_service = Service.ID_service

WHERE Jour.N_semaines = Numero_Semaine AND Service.Nom_service = Service_concerne$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Rentrer_note` (IN `Patient_Note` FLOAT, IN `Patient_commentaire` VARCHAR(200), IN `Patient_ID` INT(5), IN `Clinique_ID` INT(5))  INSERT INTO note(Note_sur_10,Commentaire,ID_patient,ID_etablissement) VALUES (Patient_Note,Patient_commentaire, Patient_ID,Clinique_ID)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Reservation_chambre` (IN `Nom du patient` VARCHAR(100), IN `Prénom du patient` VARCHAR(100), IN `Date d'entrée (AAAA-MM-JJ)` DATE, IN `Durée du séjour` INT(4), IN `Numero de chambre` INT(5))  MODIFIES SQL DATA
IF ISNULL((SELECT occuper.ID_chambre FROM occuper INNER JOIN chambre ON occuper.ID_chambre = chambre.ID_chambre WHERE occuper.Date_occuper BETWEEN `Date d'entrée (AAAA-MM-JJ)` AND ADDDATE(`Date d'entrée (AAAA-MM-JJ)`,`Durée du séjour`) AND chambre.ID_chambre = `Numero de chambre` LIMIT 1)) THEN
BEGIN
     DECLARE i INT Default 0;
     DECLARE date_i DATE DEFAULT `Date d'entrée (AAAA-MM-JJ)` ;
      simple_loop: LOOP  
      
         insert into occuper(ID_chambre,ID_patient,Date_occuper) values
         (`Numero de chambre`,(SELECT patient.ID_patient FROM patient WHERE patient.Nom_patient =  `Nom du patient` AND patient.Prenom_patient = `Prénom du patient`),date_i);
         
         SET i=i+1;
         SET date_i = ADDDATE(`Date d'entrée (AAAA-MM-JJ)`, i);
         
         IF i=(`Durée du séjour`-1) THEN
            LEAVE simple_loop;
         END IF;
   END LOOP simple_loop;
  END;
  ELSE 
   SELECT "Erreur chambre indisponible pendant ces dates !";   
END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Saisir_patient` (IN `Nom du patient` VARCHAR(100), IN `Prénom du patient` VARCHAR(100), IN `Adresse( N° nom (type de voix))` VARCHAR(100), IN `Code postal` INT(5), IN `Ville` VARCHAR(100), IN `Adresse mail` VARCHAR(100), IN `Numero de téléphone` VARCHAR(10), IN `Age` INT(3), IN `Poids (kg)` FLOAT, IN `Taille (cm)` FLOAT, IN `Sexe` ENUM('F','M'), IN `Allergies` VARCHAR(200), IN `Sécurité sociale ou CMU (1= oui, 0 = non)` TINYINT, IN `Nom_mutuelle` VARCHAR(200), IN `Numero_etablissement` INT(5))  NO SQL
INSERT INTO patient(Nom_patient,Prenom_patient,Adresse_patient,Code_postale_patient,Ville_patient,Mail_patient,Telephone_patient,Age_patient,Poids_patient,Taille_patient,Sexe_patient, Allergie,Securite_sociale_CMU,ID_mutuelle,ID_etablissement)VALUES (`Nom du patient`,`Prénom du patient`,`Adresse( N° nom (type de voix))`,`Code postal`,`Ville`,`Adresse mail`,`Numero de téléphone`,`Age`,`Poids (kg)`,`Taille (cm)`,Sexe,Allergies,`Sécurité sociale ou CMU (1= oui, 0 = non)`,(SELECT mutuelle.ID_mutuelle FROM mutuelle WHERE mutuelle.Nom_mutuelle = `Nom_mutuelle`),`Numero_etablissement`)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Saisir_personnnel` (IN `Nom du personnel` VARCHAR(100), IN `Prénom du personnel` VARCHAR(100), IN `Type de personnel` ENUM('Personnel médical','Personnel administratif','Personnel de nettoyage'), IN `Fonction` ENUM('Médecin','Chirurgien','Ophtalmologue','Oncologue','Infirmier','Aide soignant','Sage femme','Personnel de nettoyage','Personnel d''entretien','Secrétaire','Directeur','Hôte/Hôtesse d''accueil','Responsable ressources humaines','Psychologue','Urologue'), IN `Salaire` FLOAT, IN `Téléphone` VARCHAR(10), IN `Adresse` VARCHAR(100), IN `Code postal` INT(5), IN `Ville` VARCHAR(100), IN `Mail` VARCHAR(100), IN `Etablissement` INT(5), IN `Service` VARCHAR(100))  NO SQL
If ISNULL(`Service`) THEN
   INSERT into personnel
      (Nom_personnel           ,
         Prenom_personnel      ,
         Personnel             ,
         Fonction              ,
         Date_embauche         ,
         Salaire_personnel     ,
         Telephone_personnel   ,
         Adresse_personnel     ,
         Code_postal_personnel ,
         Ville_personnel       ,
         Mail_personnel        ,
         ID_Etablissement
      )
      VALUES
      (`Nom du personnel`     ,
         `Prénom du personnel`,
         `Type de personnel`  ,
         `Fonction`           ,
         DATE( NOW() )        ,
         `Salaire`            ,
         `Téléphone`          ,
         `Adresse`            ,
         `Code postal`        ,
         `Ville`              ,
         `Mail`               ,
         `Etablissement`
      )
   ;

Else
   INSERT into personnel
      (Nom_personnel           ,
         Prenom_personnel      ,
         Personnel             ,
         Fonction              ,
         Date_embauche         ,
         Salaire_personnel     ,
         Telephone_personnel   ,
         Adresse_personnel     ,
         Code_postal_personnel ,
         Ville_personnel       ,
         Mail_personnel        ,
         ID_Etablissement      ,
         ID_service
      )
      VALUES
      (`Nom du personnel`     ,
         `Prénom du personnel`,
         `Type de personnel`  ,
         `Fonction`           ,
         DATE( NOW() )        ,
         `Salaire`            ,
         `Téléphone`          ,
         `Adresse`            ,
         `Code postal`        ,
         `Ville`              ,
         `Mail`               ,
         `Etablissement`      ,
         (
            SELECT
               service.ID_service
            From
               Service
            WHERE
               service.nom_service          = `Service`
               AND service.ID_Etablissement = `Etablissement`
         )
      )
   ;

END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Suivi_occupation_des_chambres` (IN `Numero de chambre` INT(5))  NO SQL
SELECT
   `clinique`.`etablissement`.`ID_etablissement`                                                                                                                        AS `Etablissement n°`,
   `clinique`.`etablissement`.`Adresse_etablissement`                                                                                                                   AS `Adresse`         ,
   `clinique`.`etablissement`.`Code_postale_etablissement`                                                                                                              AS `Code_postal`     ,
   `clinique`.`service`.`Nom_service`                                                                                                                                   AS `Service`         ,
   `clinique`.`service`.`Etage`                                                                                                                                         AS `Etage`           ,
   DATE_FORMAT( `clinique`.`occuper`.`Date_occuper`, '%Y-%m' )                                                                                                          AS `Mois`            ,
   ROUND( 100                                           * COUNT(`clinique`.`occuper`.`Date_occuper`) / DAYOFMONTH( last_day(`clinique`.`occuper`.`Date_occuper`) ), 0 ) AS `% d occupation de la chambre par mois`
FROM
   ( ( ( `clinique`.`occuper`
   JOIN
      `clinique`.`chambre`
      ON
         (
            `clinique`.`occuper`.`ID_chambre` = `clinique`.`chambre`.`ID_chambre`
         )
   )
   JOIN
      `clinique`.`service`
      ON
         (
            `clinique`.`chambre`.`ID_service` = `clinique`.`service`.`ID_service`
         )
   )
   JOIN
      `clinique`.`etablissement`
      ON
         (
            `clinique`.`service`.`ID_etablissement` = `clinique`.`etablissement`.`ID_etablissement`
         )
   )
WHERE
   `clinique`.`occuper`.`ID_chambre` = `Numero de chambre`
GROUP BY
   DATE_FORMAT( `clinique`.`occuper`.`Date_occuper`, '%Y-%m' )$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Suppression_Rdv` (IN `Numero de consultation` INT(5))  MODIFIES SQL DATA
DELETE FROM consultation
WHERE consultation.ID_consultation = `Numero de consultation`$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `chambre`
--

CREATE TABLE `chambre` (
  `ID_chambre` int(5) UNSIGNED NOT NULL,
  `Type_chambre` varchar(6) NOT NULL COMMENT 'simple/double',
  `ID_service` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `chambre`
--

INSERT INTO `chambre` (`ID_chambre`, `Type_chambre`, `ID_service`) VALUES
(1, 'D', 40),
(2, 'D', 40),
(3, 'D', 40),
(4, 'D', 40),
(5, 'D', 40),
(6, 'D', 40),
(7, 'S', 40),
(8, 'D', 40),
(9, 'D', 40),
(10, 'S', 40),
(11, 'S', 40),
(12, 'D', 40),
(13, 'S', 40),
(14, 'D', 40),
(15, 'D', 40),
(16, 'D', 40),
(17, 'D', 40),
(18, 'S', 40),
(19, 'D', 40),
(20, 'S', 40),
(21, 'S', 40),
(22, 'D', 41),
(23, 'S', 41),
(24, 'S', 41),
(25, 'S', 41),
(26, 'D', 41),
(27, 'S', 41),
(28, 'D', 41),
(29, 'S', 41),
(30, 'S', 41),
(31, 'D', 41),
(32, 'D', 41),
(33, 'D', 41),
(34, 'D', 41),
(35, 'S', 41),
(36, 'D', 41),
(37, 'D', 41),
(38, 'D', 41),
(39, 'D', 41),
(40, 'D', 41),
(41, 'S', 41),
(42, 'S', 41),
(43, 'S', 42),
(44, 'S', 42),
(45, 'S', 42),
(46, 'S', 42),
(47, 'S', 42),
(48, 'D', 42),
(49, 'S', 42),
(50, 'S', 42),
(51, 'D', 42),
(52, 'D', 42),
(53, 'D', 42),
(54, 'D', 42),
(55, 'D', 42),
(56, 'S', 42),
(57, 'D', 42),
(58, 'S', 42),
(59, 'S', 42),
(60, 'D', 42),
(61, 'D', 42),
(62, 'D', 42),
(63, 'D', 42),
(64, 'S', 43),
(65, 'D', 43),
(66, 'D', 43),
(67, 'S', 43),
(68, 'S', 43),
(69, 'D', 43),
(70, 'D', 43),
(71, 'D', 43),
(72, 'S', 43),
(73, 'D', 43),
(74, 'S', 43),
(75, 'D', 43),
(76, 'S', 43),
(77, 'D', 43),
(78, 'S', 43),
(79, 'D', 43),
(80, 'D', 43),
(81, 'S', 43),
(82, 'D', 43),
(83, 'S', 43),
(84, 'D', 43),
(85, 'D', 44),
(86, 'S', 44),
(87, 'S', 44),
(88, 'D', 44),
(89, 'S', 44),
(90, 'S', 44),
(91, 'S', 44),
(92, 'D', 44),
(93, 'D', 44),
(94, 'S', 44),
(95, 'D', 44),
(96, 'S', 44),
(97, 'S', 44),
(98, 'S', 44),
(99, 'S', 44),
(100, 'D', 44),
(101, 'S', 44),
(102, 'D', 44),
(103, 'S', 44),
(104, 'D', 44),
(105, 'S', 44),
(106, 'D', 45),
(107, 'D', 45),
(108, 'D', 45),
(109, 'D', 45),
(110, 'S', 45),
(111, 'D', 45),
(112, 'D', 45),
(113, 'D', 45),
(114, 'D', 45),
(115, 'D', 45),
(116, 'S', 45),
(117, 'S', 45),
(118, 'S', 45),
(119, 'D', 45),
(120, 'D', 45),
(121, 'D', 45),
(122, 'D', 45),
(123, 'S', 45),
(124, 'D', 45),
(125, 'D', 45),
(126, 'S', 45),
(127, 'D', 46),
(128, 'S', 46),
(129, 'D', 46),
(130, 'D', 46),
(131, 'D', 46),
(132, 'D', 46),
(133, 'S', 46),
(134, 'D', 46),
(135, 'S', 46),
(136, 'S', 46),
(137, 'D', 46),
(138, 'S', 46),
(139, 'D', 46),
(140, 'S', 46),
(141, 'D', 46),
(142, 'D', 46),
(143, 'S', 46),
(144, 'S', 46),
(145, 'D', 46),
(146, 'D', 46),
(147, 'S', 46),
(148, 'D', 47),
(149, 'D', 47),
(150, 'S', 47),
(151, 'D', 47),
(152, 'S', 47),
(153, 'S', 47),
(154, 'D', 47),
(155, 'S', 47),
(156, 'D', 47),
(157, 'D', 47),
(158, 'S', 47),
(159, 'D', 47),
(160, 'S', 47),
(161, 'D', 47),
(162, 'D', 47),
(163, 'S', 47),
(164, 'D', 47),
(165, 'S', 47),
(166, 'S', 47),
(167, 'S', 47),
(168, 'D', 47),
(169, 'S', 48),
(170, 'S', 48),
(171, 'D', 48),
(172, 'S', 48),
(173, 'S', 48),
(174, 'D', 48),
(175, 'D', 48),
(176, 'D', 48),
(177, 'D', 48),
(178, 'S', 48),
(179, 'D', 48),
(180, 'D', 48),
(181, 'D', 48),
(182, 'D', 48),
(183, 'S', 48),
(184, 'S', 48),
(185, 'S', 48),
(186, 'D', 48),
(187, 'D', 48),
(188, 'S', 48),
(189, 'D', 48),
(190, 'D', 49),
(191, 'D', 49),
(192, 'D', 49),
(193, 'S', 49),
(194, 'S', 49),
(195, 'D', 49),
(196, 'D', 49),
(197, 'S', 49),
(198, 'D', 49),
(199, 'D', 49),
(200, 'D', 49),
(201, 'D', 49),
(202, 'S', 49),
(203, 'S', 49),
(204, 'S', 49),
(205, 'D', 49),
(206, 'D', 49),
(207, 'D', 49),
(208, 'S', 49),
(209, 'S', 49),
(210, 'S', 49),
(211, 'D', 50),
(212, 'D', 50),
(213, 'D', 50),
(214, 'S', 50),
(215, 'S', 50),
(216, 'D', 50),
(217, 'D', 50),
(218, 'D', 50),
(219, 'D', 50),
(220, 'S', 50),
(221, 'S', 50),
(222, 'D', 50),
(223, 'S', 50),
(224, 'D', 50),
(225, 'S', 50),
(226, 'S', 50),
(227, 'D', 50),
(228, 'D', 50),
(229, 'D', 50),
(230, 'S', 50),
(231, 'D', 50),
(232, 'S', 51),
(233, 'S', 51),
(234, 'S', 51),
(235, 'D', 51),
(236, 'S', 51),
(237, 'S', 51),
(238, 'D', 51),
(239, 'D', 51),
(240, 'S', 51),
(241, 'D', 51),
(242, 'S', 51),
(243, 'S', 51),
(244, 'D', 51),
(245, 'D', 51),
(246, 'S', 51),
(247, 'S', 51),
(248, 'D', 51),
(249, 'D', 51),
(250, 'S', 51),
(251, 'S', 51),
(252, 'S', 51),
(253, 'S', 52),
(254, 'D', 52),
(255, 'S', 52),
(256, 'D', 52),
(257, 'D', 52),
(258, 'S', 52),
(259, 'S', 52),
(260, 'S', 52),
(261, 'S', 52),
(262, 'D', 52),
(263, 'S', 52),
(264, 'S', 52),
(265, 'S', 52),
(266, 'D', 52),
(267, 'S', 52),
(268, 'S', 52),
(269, 'D', 52),
(270, 'D', 52),
(271, 'S', 52),
(272, 'D', 52),
(273, 'D', 52),
(274, 'S', 53),
(275, 'D', 53),
(276, 'S', 53),
(277, 'D', 53),
(278, 'D', 53),
(279, 'S', 53),
(280, 'D', 53),
(281, 'D', 53),
(282, 'D', 53),
(283, 'D', 53),
(284, 'D', 53),
(285, 'S', 53),
(286, 'D', 53),
(287, 'S', 53),
(288, 'D', 53),
(289, 'S', 53),
(290, 'D', 53),
(291, 'D', 53),
(292, 'D', 53),
(293, 'S', 53),
(294, 'S', 53),
(295, 'S', 54),
(296, 'S', 54),
(297, 'S', 54),
(298, 'D', 54),
(299, 'S', 54),
(300, 'D', 54),
(301, 'S', 54),
(302, 'D', 54),
(303, 'S', 54),
(304, 'S', 54),
(305, 'S', 54),
(306, 'S', 54),
(307, 'S', 54),
(308, 'D', 54),
(309, 'D', 54),
(310, 'D', 54),
(311, 'D', 54),
(312, 'S', 54),
(313, 'D', 54),
(314, 'D', 54),
(315, 'S', 54),
(316, 'D', 55),
(317, 'S', 55),
(318, 'S', 55),
(319, 'D', 55),
(320, 'D', 55),
(321, 'S', 55),
(322, 'D', 55),
(323, 'D', 55),
(324, 'D', 55),
(325, 'S', 55),
(326, 'S', 55),
(327, 'S', 55),
(328, 'D', 55),
(329, 'S', 55),
(330, 'D', 55),
(331, 'D', 55),
(332, 'D', 55),
(333, 'D', 55),
(334, 'D', 55),
(335, 'S', 55),
(336, 'D', 55),
(337, 'D', 56),
(338, 'S', 56),
(339, 'D', 56),
(340, 'D', 56),
(341, 'S', 56),
(342, 'S', 56),
(343, 'S', 56),
(344, 'D', 56),
(345, 'D', 56),
(346, 'S', 56),
(347, 'D', 56),
(348, 'D', 56),
(349, 'D', 56),
(350, 'D', 56),
(351, 'D', 56),
(352, 'D', 56),
(353, 'D', 56),
(354, 'S', 56),
(355, 'D', 56),
(356, 'S', 56),
(357, 'S', 56),
(358, 'D', 57),
(359, 'S', 57),
(360, 'S', 57),
(361, 'D', 57),
(362, 'S', 57),
(363, 'S', 57),
(364, 'S', 57),
(365, 'D', 57),
(366, 'S', 57),
(367, 'D', 57),
(368, 'S', 57),
(369, 'D', 57),
(370, 'S', 57),
(371, 'D', 57),
(372, 'D', 57),
(373, 'D', 57),
(374, 'D', 57),
(375, 'D', 57),
(376, 'D', 57),
(377, 'D', 57),
(378, 'S', 57),
(379, 'D', 58),
(380, 'D', 58),
(381, 'S', 58),
(382, 'S', 58),
(383, 'S', 58),
(384, 'S', 58),
(385, 'D', 58),
(386, 'S', 58),
(387, 'S', 58),
(388, 'S', 58),
(389, 'S', 58),
(390, 'S', 58),
(391, 'D', 58),
(392, 'S', 58),
(393, 'S', 58),
(394, 'S', 58),
(395, 'S', 58),
(396, 'S', 58),
(397, 'S', 58),
(398, 'D', 58),
(399, 'D', 58),
(400, 'S', 59),
(401, 'D', 59),
(402, 'S', 59),
(403, 'S', 59),
(404, 'D', 59),
(405, 'D', 59),
(406, 'S', 59),
(407, 'S', 59),
(408, 'D', 59),
(409, 'S', 59),
(410, 'D', 59),
(411, 'D', 59),
(412, 'S', 59),
(413, 'D', 59),
(414, 'S', 59),
(415, 'S', 59),
(416, 'S', 59),
(417, 'S', 59),
(418, 'S', 59),
(419, 'D', 59),
(420, 'S', 59),
(421, 'D', 60),
(422, 'D', 60),
(423, 'S', 60),
(424, 'S', 60),
(425, 'D', 60),
(426, 'S', 60),
(427, 'D', 60),
(428, 'S', 60),
(429, 'D', 60),
(430, 'S', 60),
(431, 'D', 60),
(432, 'S', 60),
(433, 'D', 60),
(434, 'D', 60),
(435, 'D', 60),
(436, 'D', 60),
(437, 'S', 60),
(438, 'S', 60),
(439, 'S', 60),
(440, 'D', 60),
(441, 'D', 60),
(442, 'D', 61),
(443, 'S', 61),
(444, 'D', 61),
(445, 'D', 61),
(446, 'D', 61),
(447, 'D', 61),
(448, 'S', 61),
(449, 'D', 61),
(450, 'S', 61),
(451, 'S', 61),
(452, 'D', 61),
(453, 'S', 61),
(454, 'D', 61),
(455, 'D', 61),
(456, 'S', 61),
(457, 'S', 61),
(458, 'D', 61),
(459, 'S', 61),
(460, 'S', 61),
(461, 'D', 61),
(462, 'D', 61),
(463, 'S', 62),
(464, 'S', 62),
(465, 'S', 62),
(466, 'S', 62),
(467, 'D', 62),
(468, 'S', 62),
(469, 'D', 62),
(470, 'S', 62),
(471, 'S', 62),
(472, 'D', 62),
(473, 'D', 62),
(474, 'D', 62),
(475, 'S', 62),
(476, 'S', 62),
(477, 'D', 62),
(478, 'D', 62),
(479, 'S', 62),
(480, 'D', 62),
(481, 'S', 62),
(482, 'S', 62),
(483, 'S', 62),
(484, 'S', 63),
(485, 'S', 63),
(486, 'D', 63),
(487, 'S', 63),
(488, 'D', 63),
(489, 'D', 63),
(490, 'S', 63),
(491, 'S', 63),
(492, 'D', 63),
(493, 'S', 63),
(494, 'S', 63),
(495, 'S', 63),
(496, 'S', 63),
(497, 'D', 63),
(498, 'S', 63),
(499, 'D', 63),
(500, 'D', 63),
(501, 'D', 63),
(502, 'S', 63),
(503, 'S', 63),
(504, 'D', 63),
(505, 'S', 64),
(506, 'D', 64),
(507, 'S', 64),
(508, 'D', 64),
(509, 'S', 64),
(510, 'D', 64),
(511, 'S', 64),
(512, 'D', 64),
(513, 'S', 64),
(514, 'D', 64),
(515, 'S', 64),
(516, 'D', 64),
(517, 'S', 64),
(518, 'D', 64),
(519, 'D', 64),
(520, 'D', 64),
(521, 'D', 64),
(522, 'S', 64),
(523, 'S', 64),
(524, 'S', 64),
(525, 'S', 64),
(526, 'S', 65),
(527, 'D', 65),
(528, 'D', 65),
(529, 'S', 65),
(530, 'D', 65),
(531, 'D', 65),
(532, 'S', 65),
(533, 'S', 65),
(534, 'S', 65),
(535, 'S', 65),
(536, 'D', 65),
(537, 'S', 65),
(538, 'S', 65),
(539, 'S', 65),
(540, 'S', 65),
(541, 'S', 65),
(542, 'S', 65),
(543, 'S', 65),
(544, 'D', 65),
(545, 'D', 65),
(546, 'D', 65),
(547, 'S', 66),
(548, 'D', 66),
(549, 'S', 66),
(550, 'S', 66),
(551, 'S', 66),
(552, 'S', 66),
(553, 'D', 66),
(554, 'D', 66),
(555, 'S', 66),
(556, 'D', 66),
(557, 'S', 66),
(558, 'D', 66),
(559, 'S', 66),
(560, 'D', 66),
(561, 'D', 66),
(562, 'S', 66),
(563, 'S', 66),
(564, 'D', 66),
(565, 'D', 66),
(566, 'S', 66),
(567, 'D', 66),
(568, 'S', 67),
(569, 'S', 67),
(570, 'D', 67),
(571, 'S', 67),
(572, 'D', 67),
(573, 'S', 67),
(574, 'S', 67),
(575, 'S', 67),
(576, 'D', 67),
(577, 'S', 67),
(578, 'S', 67),
(579, 'S', 67),
(580, 'D', 67),
(581, 'S', 67),
(582, 'D', 67),
(583, 'D', 67),
(584, 'D', 67),
(585, 'D', 67),
(586, 'D', 67),
(587, 'D', 67),
(588, 'S', 67),
(589, 'S', 68),
(590, 'S', 68),
(591, 'S', 68),
(592, 'S', 68),
(593, 'S', 68),
(594, 'S', 68),
(595, 'D', 68),
(596, 'S', 68),
(597, 'S', 68),
(598, 'S', 68),
(599, 'D', 68),
(600, 'D', 68),
(601, 'S', 68),
(602, 'D', 68),
(603, 'D', 68),
(604, 'D', 68),
(605, 'S', 68),
(606, 'D', 68),
(607, 'D', 68),
(608, 'S', 68),
(609, 'S', 68),
(610, 'D', 69),
(611, 'D', 69),
(612, 'D', 69),
(613, 'S', 69),
(614, 'D', 69),
(615, 'D', 69),
(616, 'D', 69),
(617, 'S', 69),
(618, 'D', 69),
(619, 'S', 69),
(620, 'S', 69),
(621, 'S', 69),
(622, 'D', 69),
(623, 'S', 69),
(624, 'D', 69),
(625, 'S', 69),
(626, 'S', 69),
(627, 'S', 69),
(628, 'S', 69),
(629, 'D', 69),
(630, 'S', 69),
(631, 'D', 70),
(632, 'S', 70),
(633, 'D', 70),
(634, 'D', 70),
(635, 'D', 70),
(636, 'D', 70),
(637, 'D', 70),
(638, 'D', 70),
(639, 'S', 70),
(640, 'D', 70),
(641, 'S', 70),
(642, 'S', 70),
(643, 'D', 70),
(644, 'D', 70),
(645, 'D', 70),
(646, 'S', 70),
(647, 'D', 70),
(648, 'S', 70),
(649, 'D', 70),
(650, 'S', 70),
(651, 'S', 70),
(652, 'S', 71),
(653, 'S', 71),
(654, 'S', 71),
(655, 'S', 71),
(656, 'S', 71),
(657, 'D', 71),
(658, 'S', 71),
(659, 'D', 71),
(660, 'S', 71),
(661, 'D', 71),
(662, 'S', 71),
(663, 'D', 71),
(664, 'S', 71),
(665, 'S', 71),
(666, 'S', 71),
(667, 'S', 71),
(668, 'D', 71),
(669, 'S', 71),
(670, 'D', 71),
(671, 'D', 71),
(672, 'S', 71),
(673, 'S', 72),
(674, 'S', 72),
(675, 'S', 72),
(676, 'D', 72),
(677, 'S', 72),
(678, 'D', 72),
(679, 'D', 72),
(680, 'D', 72),
(681, 'S', 72),
(682, 'D', 72),
(683, 'D', 72),
(684, 'S', 72),
(685, 'S', 72),
(686, 'S', 72),
(687, 'S', 72),
(688, 'D', 72),
(689, 'S', 72),
(690, 'D', 72),
(691, 'D', 72),
(692, 'S', 72),
(693, 'D', 72),
(694, 'S', 73),
(695, 'S', 73),
(696, 'S', 73),
(697, 'S', 73),
(698, 'S', 73),
(699, 'S', 73),
(700, 'S', 73),
(701, 'D', 73),
(702, 'S', 73),
(703, 'D', 73),
(704, 'S', 73),
(705, 'S', 73),
(706, 'S', 73),
(707, 'D', 73),
(708, 'D', 73),
(709, 'S', 73),
(710, 'D', 73),
(711, 'D', 73),
(712, 'D', 73),
(713, 'D', 73),
(714, 'D', 73),
(715, 'D', 74),
(716, 'D', 74),
(717, 'S', 74),
(718, 'D', 74),
(719, 'D', 74),
(720, 'S', 74),
(721, 'D', 74),
(722, 'D', 74),
(723, 'D', 74),
(724, 'D', 74),
(725, 'D', 74),
(726, 'D', 74),
(727, 'S', 74),
(728, 'S', 74),
(729, 'S', 74),
(730, 'D', 74),
(731, 'D', 74),
(732, 'S', 74),
(733, 'S', 74),
(734, 'D', 74),
(735, 'S', 74),
(736, 'D', 75),
(737, 'D', 75),
(738, 'S', 75),
(739, 'D', 75),
(740, 'S', 75),
(741, 'D', 75),
(742, 'D', 75),
(743, 'D', 75),
(744, 'S', 75),
(745, 'S', 75),
(746, 'D', 75),
(747, 'D', 75),
(748, 'D', 75),
(749, 'S', 75),
(750, 'D', 75),
(751, 'S', 75),
(752, 'S', 75),
(753, 'S', 75),
(754, 'D', 75),
(755, 'S', 75),
(756, 'D', 75),
(757, 'S', 76),
(758, 'D', 76),
(759, 'S', 76),
(760, 'D', 76),
(761, 'D', 76),
(762, 'D', 76),
(763, 'S', 76),
(764, 'S', 76),
(765, 'S', 76),
(766, 'D', 76),
(767, 'S', 76),
(768, 'D', 76),
(769, 'D', 76),
(770, 'S', 76),
(771, 'D', 76),
(772, 'D', 76),
(773, 'S', 76),
(774, 'S', 76),
(775, 'D', 76),
(776, 'S', 76),
(777, 'D', 76),
(778, 'D', 77),
(779, 'D', 77),
(780, 'D', 77),
(781, 'D', 77),
(782, 'D', 77),
(783, 'D', 77),
(784, 'S', 77),
(785, 'D', 77),
(786, 'S', 77),
(787, 'D', 77),
(788, 'S', 77),
(789, 'D', 77),
(790, 'S', 77),
(791, 'S', 77),
(792, 'D', 77),
(793, 'D', 77),
(794, 'S', 77),
(795, 'D', 77),
(796, 'S', 77),
(797, 'S', 77),
(798, 'D', 77),
(799, 'D', 78),
(800, 'S', 78),
(801, 'S', 78),
(802, 'S', 78),
(803, 'D', 78),
(804, 'S', 78),
(805, 'S', 78),
(806, 'D', 78),
(807, 'S', 78),
(808, 'S', 78),
(809, 'D', 78),
(810, 'D', 78),
(811, 'S', 78),
(812, 'S', 78),
(813, 'S', 78),
(814, 'D', 78),
(815, 'S', 78),
(816, 'S', 78),
(817, 'S', 78),
(818, 'S', 78),
(819, 'S', 78);

-- --------------------------------------------------------

--
-- Structure de la table `commande`
--

CREATE TABLE `commande` (
  `ID_commande` int(5) UNSIGNED NOT NULL,
  `Date_commande` date NOT NULL,
  `Date_livraison` date DEFAULT NULL,
  `Montant_commande` float DEFAULT 0,
  `ID_etablissement` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `commande`
--

INSERT INTO `commande` (`ID_commande`, `Date_commande`, `Date_livraison`, `Montant_commande`, `ID_etablissement`) VALUES
(1, '2021-02-15', NULL, 31062, 1),
(2, '2021-04-15', NULL, 5251.99, 1);

-- --------------------------------------------------------

--
-- Structure de la table `consultation`
--

CREATE TABLE `consultation` (
  `ID_consultation` int(5) UNSIGNED NOT NULL,
  `Type_consultation` enum('Rendez-vous','Hospitalisation') NOT NULL COMMENT 'Choix entre : RDV ou hospitalisation',
  `Montant` float NOT NULL,
  `Symptomes` varchar(100) NOT NULL,
  `Diagnostic` varchar(200) DEFAULT NULL,
  `Heure_debut` time NOT NULL,
  `Heure_fin` time DEFAULT NULL,
  `ID_patient` int(5) UNSIGNED NOT NULL,
  `ID_personnel` int(5) UNSIGNED NOT NULL,
  `ID_jour_entree` int(5) UNSIGNED NOT NULL,
  `ID_jour_sortie` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `consultation`
--

INSERT INTO `consultation` (`ID_consultation`, `Type_consultation`, `Montant`, `Symptomes`, `Diagnostic`, `Heure_debut`, `Heure_fin`, `ID_patient`, `ID_personnel`, `ID_jour_entree`, `ID_jour_sortie`) VALUES
(1, 'Rendez-vous', 97, 'Démances', 'Paranoïa', '12:45:00', '09:30:00', 495, 982, 66, 72),
(3, 'Hospitalisation', 129, 'Maux de gorges', 'Grippe', '11:45:00', '12:45:00', 572, 997, 385, 475),
(4, 'Rendez-vous', 235, 'Démances', 'Stresse post traumatique', '07:45:00', '08:45:00', 626, 904, 36, 74),
(5, 'Hospitalisation', 58, 'Vertiges', NULL, '19:45:00', '07:15:00', 513, 951, 337, 361),
(6, 'Hospitalisation', 56, 'Contractions', NULL, '12:45:00', '07:45:00', 607, 956, 124, 216),
(7, 'Hospitalisation', 111, 'Douleurs', 'Grippe', '14:45:00', '15:00:00', 568, 897, 137, 220),
(8, 'Rendez-vous', 84, 'Vertiges', NULL, '12:00:00', '14:15:00', 403, 940, 24, 47),
(9, 'Rendez-vous', 188, 'Maux de ventre', NULL, '19:45:00', '08:00:00', 590, 955, 249, 250),
(10, 'Hospitalisation', 162, 'Pertes de mémoire', NULL, '19:45:00', '20:45:00', 555, 909, 226, 304),
(11, 'Hospitalisation', 111, 'Maux de dos', NULL, '18:00:00', '18:15:00', 583, 962, 187, 199),
(12, 'Hospitalisation', 10, 'Vertiges', NULL, '17:30:00', '14:30:00', 406, 949, 262, 304),
(13, 'Rendez-vous', 127, 'Fourmis', NULL, '12:30:00', '07:00:00', 609, 952, 72, 86),
(14, 'Rendez-vous', 227, 'Rien', NULL, '19:00:00', '20:00:00', 599, 983, 373, 467),
(15, 'Hospitalisation', 108, 'Fourmis', NULL, '16:15:00', '14:30:00', 383, 974, 206, 272),
(16, 'Rendez-vous', 194, 'Maux de dos', NULL, '07:30:00', '08:30:00', 592, 942, 86, 161),
(17, 'Rendez-vous', 151, 'Rien', NULL, '12:30:00', '17:45:00', 419, 972, 316, 384),
(18, 'Rendez-vous', 18, 'Fourmis', NULL, '13:00:00', '19:15:00', 542, 938, 217, 279),
(19, 'Rendez-vous', 166, 'Contractions', NULL, '17:45:00', '08:45:00', 579, 992, 292, 354),
(20, 'Hospitalisation', 53, 'Maux de dos', NULL, '22:00:00', '10:30:00', 513, 888, 155, 219),
(21, 'Rendez-vous', 246, 'Maux de gorges', NULL, '17:30:00', '20:00:00', 478, 926, 138, 231),
(22, 'Hospitalisation', 154, 'Pertes de mémoire', NULL, '18:30:00', '14:00:00', 527, 974, 266, 320),
(23, 'Hospitalisation', 46, 'Vertiges', NULL, '12:00:00', '11:45:00', 373, 917, 172, 173),
(24, 'Hospitalisation', 63, 'Contractions', NULL, '09:15:00', '11:30:00', 532, 918, 304, 307),
(25, 'Hospitalisation', 13, 'Rien', NULL, '11:30:00', '17:15:00', 542, 930, 286, 366),
(26, 'Hospitalisation', 60, 'Maux de ventre', NULL, '18:45:00', '12:15:00', 495, 1020, 252, 291),
(27, 'Hospitalisation', 55, 'Maux de dos', NULL, '11:45:00', '15:15:00', 435, 982, 57, 86),
(28, 'Hospitalisation', 121, 'Maux de ventre', NULL, '15:30:00', '12:30:00', 517, 924, 313, 350),
(29, 'Rendez-vous', 96, 'Maux de dos', NULL, '11:45:00', '20:15:00', 582, 907, 263, 316),
(30, 'Hospitalisation', 19, 'Rien', NULL, '19:30:00', '15:45:00', 461, 1014, 228, 306),
(31, 'Rendez-vous', 10, 'Contractions', NULL, '18:30:00', '11:15:00', 420, 940, 320, 355),
(32, 'Rendez-vous', 166, 'Démances', NULL, '09:45:00', '11:45:00', 514, 930, 227, 254),
(33, 'Rendez-vous', 86, 'Maux de ventre', NULL, '11:15:00', '10:15:00', 612, 953, 346, 388),
(34, 'Hospitalisation', 12, 'Pertes de mémoire', NULL, '19:30:00', '09:00:00', 625, 961, 69, 160),
(35, 'Hospitalisation', 44, 'Maux de gorges', NULL, '15:30:00', '19:30:00', 653, 1004, 151, 168),
(36, 'Rendez-vous', 137, 'Maux de dos', NULL, '17:15:00', '10:15:00', 467, 931, 170, 244),
(37, 'Rendez-vous', 202, 'Fourmis', NULL, '16:45:00', '21:30:00', 402, 956, 276, 324),
(38, 'Rendez-vous', 110, 'Fourmis', NULL, '14:30:00', '21:30:00', 412, 970, 253, 314),
(39, 'Hospitalisation', 228, 'Pertes de mémoire', NULL, '07:15:00', '21:15:00', 445, 979, 202, 250),
(40, 'Rendez-vous', 17, 'Démances', NULL, '14:45:00', '08:15:00', 517, 900, 368, 420),
(41, 'Rendez-vous', 17, 'Douleurs', NULL, '22:15:00', '08:00:00', 335, 978, 170, 230),
(42, 'Rendez-vous', 152, 'Contractions', NULL, '22:30:00', '20:45:00', 593, 1000, 6, 28),
(43, 'Rendez-vous', 181, 'Fourmis', NULL, '07:15:00', '12:45:00', 530, 1007, 63, 129),
(44, 'Rendez-vous', 19, 'Pertes de mémoire', NULL, '15:30:00', '09:00:00', 358, 1003, 36, 109),
(45, 'Rendez-vous', 177, 'Démances', NULL, '14:30:00', '18:00:00', 560, 910, 247, 331),
(46, 'Hospitalisation', 160, 'Vertiges', NULL, '16:00:00', '17:30:00', 485, 998, 353, 431),
(47, 'Hospitalisation', 151, 'Maux de gorges', NULL, '10:15:00', '09:45:00', 412, 951, 384, 447),
(48, 'Rendez-vous', 171, 'Vertiges', NULL, '12:15:00', '09:30:00', 408, 897, 388, 449),
(49, 'Rendez-vous', 80, 'Démances', NULL, '16:00:00', '13:00:00', 609, 979, 120, 174),
(50, 'Rendez-vous', 133, 'Maux de ventre', NULL, '08:30:00', '19:45:00', 508, 940, 217, 228),
(51, 'Hospitalisation', 213, 'Rien', NULL, '10:30:00', '18:45:00', 498, 1009, 341, 422),
(52, 'Rendez-vous', 111, 'Démances', NULL, '08:15:00', '20:15:00', 333, 908, 261, 323),
(53, 'Rendez-vous', 193, 'Contractions', NULL, '09:30:00', '09:00:00', 499, 884, 170, 264),
(54, 'Hospitalisation', 188, 'Pertes de mémoire', NULL, '19:45:00', '22:00:00', 466, 1011, 175, 187),
(55, 'Rendez-vous', 66, 'Maux de gorges', NULL, '15:45:00', '13:15:00', 629, 890, 293, 385),
(56, 'Rendez-vous', 225, 'Pertes de mémoire', NULL, '13:00:00', '19:00:00', 395, 949, 163, 239),
(57, 'Rendez-vous', 226, 'Douleurs', NULL, '12:30:00', '16:30:00', 628, 1016, 357, 432),
(58, 'Rendez-vous', 39, 'Pertes de mémoire', NULL, '22:30:00', '17:45:00', 601, 903, 201, 289),
(59, 'Hospitalisation', 91, 'Maux de ventre', NULL, '19:30:00', '15:00:00', 343, 980, 348, 375),
(60, 'Hospitalisation', 217, 'Démances', NULL, '17:30:00', '11:15:00', 608, 899, 286, 325),
(61, 'Hospitalisation', 103, 'Contractions', NULL, '13:30:00', '09:30:00', 435, 917, 201, 251),
(62, 'Hospitalisation', 33, 'Maux de dos', NULL, '19:30:00', '17:45:00', 628, 973, 191, 262),
(63, 'Hospitalisation', 166, 'Maux de ventre', NULL, '11:30:00', '10:45:00', 530, 963, 229, 275),
(64, 'Hospitalisation', 178, 'Fourmis', NULL, '09:15:00', '08:00:00', 441, 989, 347, 413),
(65, 'Hospitalisation', 200, 'Maux de ventre', NULL, '14:15:00', '10:45:00', 405, 1022, 382, 458),
(66, 'Rendez-vous', 157, 'Pertes de mémoire', NULL, '08:00:00', '14:30:00', 658, 910, 323, 411),
(67, 'Rendez-vous', 208, 'Maux de gorges', NULL, '21:00:00', '09:00:00', 576, 1023, 201, 231),
(68, 'Hospitalisation', 10, 'Démances', NULL, '21:15:00', '19:45:00', 395, 950, 90, 134),
(69, 'Hospitalisation', 56, 'Démances', NULL, '15:15:00', '09:00:00', 409, 1016, 271, 282),
(70, 'Rendez-vous', 85, 'Maux de dos', NULL, '21:00:00', '19:15:00', 526, 960, 340, 357),
(71, 'Hospitalisation', 191, 'Contractions', NULL, '21:00:00', '17:15:00', 443, 970, 164, 258),
(72, 'Rendez-vous', 212, 'Démances', NULL, '12:00:00', '20:45:00', 354, 952, 163, 177),
(73, 'Hospitalisation', 41, 'Douleurs', NULL, '09:30:00', '17:45:00', 619, 1001, 344, 356),
(74, 'Hospitalisation', 189, 'Maux de gorges', NULL, '10:15:00', '17:15:00', 537, 1023, 85, 168),
(75, 'Rendez-vous', 171, 'Maux de dos', NULL, '16:30:00', '18:30:00', 387, 988, 58, 70),
(76, 'Hospitalisation', 155, 'Douleurs', NULL, '21:45:00', '11:00:00', 396, 1001, 361, 395),
(77, 'Hospitalisation', 132, 'Fourmis', NULL, '20:15:00', '18:30:00', 593, 940, 198, 243),
(78, 'Hospitalisation', 39, 'Fourmis', NULL, '12:00:00', '08:15:00', 355, 1007, 16, 44),
(79, 'Hospitalisation', 52, 'Démances', NULL, '14:30:00', '09:00:00', 612, 909, 23, 37),
(81, 'Hospitalisation', 186, 'Maux de dos', NULL, '16:30:00', '21:15:00', 553, 887, 193, 234),
(82, 'Hospitalisation', 192, 'Démances', NULL, '20:15:00', '18:45:00', 478, 946, 110, 112),
(83, 'Hospitalisation', 59, 'Contractions', NULL, '18:15:00', '14:15:00', 589, 941, 129, 200),
(84, 'Hospitalisation', 44, 'Maux de gorges', NULL, '21:30:00', '12:30:00', 609, 935, 315, 328),
(85, 'Hospitalisation', 131, 'Maux de dos', NULL, '12:45:00', '08:00:00', 365, 939, 162, 173),
(86, 'Hospitalisation', 71, 'Rien', NULL, '17:30:00', '18:30:00', 520, 991, 208, 223),
(87, 'Rendez-vous', 69, 'Maux de dos', NULL, '14:00:00', '16:45:00', 586, 911, 125, 176),
(88, 'Rendez-vous', 73, 'Pertes de mémoire', NULL, '20:15:00', '08:45:00', 468, 930, 259, 340),
(89, 'Hospitalisation', 176, 'Contractions', NULL, '07:00:00', '09:00:00', 600, 964, 275, 323),
(90, 'Rendez-vous', 45, 'Maux de ventre', NULL, '07:15:00', '09:15:00', 498, 894, 343, 379),
(91, 'Rendez-vous', 231, 'Fourmis', NULL, '12:30:00', '19:45:00', 375, 889, 298, 397),
(92, 'Hospitalisation', 55, 'Maux de dos', NULL, '09:00:00', '09:45:00', 584, 977, 123, 127),
(93, 'Hospitalisation', 15, 'Maux de ventre', NULL, '12:15:00', '14:30:00', 516, 997, 160, 182),
(94, 'Hospitalisation', 195, 'Contractions', NULL, '09:15:00', '22:30:00', 422, 949, 32, 102),
(95, 'Rendez-vous', 245, 'Pertes de mémoire', NULL, '11:45:00', '20:30:00', 563, 1018, 155, 217),
(96, 'Hospitalisation', 211, 'Maux de gorges', NULL, '12:30:00', '10:00:00', 648, 975, 216, 261),
(97, 'Rendez-vous', 245, 'Douleurs', NULL, '11:00:00', '09:15:00', 415, 1016, 310, 336),
(98, 'Hospitalisation', 225, 'Fourmis', NULL, '19:30:00', '21:30:00', 447, 891, 215, 246),
(99, 'Hospitalisation', 93, 'Pertes de mémoire', NULL, '21:00:00', '09:45:00', 620, 1024, 284, 381),
(100, 'Hospitalisation', 212, 'Démances', NULL, '15:00:00', '20:00:00', 484, 953, 115, 166),
(101, 'Hospitalisation', 94, 'Maux de dos', NULL, '15:15:00', '10:00:00', 425, 917, 33, 42),
(102, 'Rendez-vous', 57, 'Pertes de mémoire', NULL, '22:00:00', '22:30:00', 366, 909, 295, 353),
(103, 'Hospitalisation', 198, 'Fourmis', NULL, '22:30:00', '11:00:00', 405, 890, 94, 185),
(104, 'Rendez-vous', 20, 'Vertiges', NULL, '19:30:00', '17:30:00', 503, 986, 385, 385),
(105, 'Rendez-vous', 23, 'Démances', NULL, '16:00:00', '20:45:00', 474, 929, 248, 289),
(106, 'Hospitalisation', 61, 'Fourmis', NULL, '18:30:00', '17:30:00', 572, 907, 335, 362),
(107, 'Rendez-vous', 8, 'Rien', NULL, '16:00:00', '17:15:00', 498, 890, 193, 229),
(108, 'Hospitalisation', 250, 'Vertiges', NULL, '16:00:00', '22:30:00', 609, 919, 46, 91),
(109, 'Rendez-vous', 147, 'Maux de gorges', NULL, '21:15:00', '12:30:00', 586, 958, 84, 178),
(110, 'Rendez-vous', 19, 'Maux de ventre', NULL, '15:45:00', '13:45:00', 592, 904, 35, 105),
(111, 'Hospitalisation', 41, 'Douleurs', NULL, '09:15:00', '15:30:00', 547, 1000, 295, 309),
(112, 'Rendez-vous', 248, 'Maux de dos', NULL, '11:15:00', '10:15:00', 396, 983, 363, 416),
(113, 'Hospitalisation', 39, 'Douleurs', NULL, '07:15:00', '09:45:00', 593, 982, 312, 406),
(114, 'Hospitalisation', 130, 'Vertiges', NULL, '13:30:00', '11:30:00', 357, 1024, 376, 382),
(115, 'Hospitalisation', 56, 'Fourmis', NULL, '15:15:00', '18:00:00', 594, 974, 96, 124),
(116, 'Rendez-vous', 94, 'Rien', NULL, '22:15:00', '13:30:00', 444, 976, 375, 421),
(118, 'Hospitalisation', 222, 'Maux de gorges', NULL, '11:30:00', '07:15:00', 460, 941, 95, 121),
(119, 'Hospitalisation', 229, 'Fourmis', NULL, '22:45:00', '14:30:00', 454, 998, 145, 177),
(120, 'Hospitalisation', 63, 'Fourmis', NULL, '07:30:00', '16:15:00', 529, 979, 309, 399),
(121, 'Hospitalisation', 92, 'Maux de dos', NULL, '19:00:00', '08:45:00', 454, 995, 399, 465),
(122, 'Hospitalisation', 61, 'Vertiges', NULL, '10:15:00', '15:30:00', 501, 972, 359, 421),
(123, 'Hospitalisation', 63, 'Fourmis', NULL, '14:45:00', '13:00:00', 470, 918, 36, 73),
(124, 'Rendez-vous', 120, 'Rien', NULL, '21:15:00', '19:00:00', 429, 910, 276, 294),
(125, 'Hospitalisation', 214, 'Démances', NULL, '21:00:00', '11:00:00', 546, 1007, 396, 468),
(126, 'Rendez-vous', 22, 'Douleurs', NULL, '19:45:00', '15:45:00', 596, 907, 94, 189),
(127, 'Hospitalisation', 143, 'Vertiges', NULL, '19:30:00', '16:30:00', 438, 893, 242, 305),
(128, 'Hospitalisation', 195, 'Maux de ventre', NULL, '09:00:00', '13:45:00', 547, 1025, 35, 70),
(129, 'Hospitalisation', 49, 'Vertiges', NULL, '17:45:00', '12:00:00', 618, 981, 50, 64),
(130, 'Rendez-vous', 59, 'Maux de gorges', NULL, '10:30:00', '15:30:00', 363, 989, 288, 338),
(131, 'Rendez-vous', 245, 'Maux de gorges', NULL, '11:30:00', '18:30:00', 473, 960, 264, 328),
(132, 'Rendez-vous', 14, 'Maux de gorges', NULL, '13:30:00', '16:00:00', 548, 1010, 42, 128),
(133, 'Hospitalisation', 111, 'Contractions', NULL, '14:00:00', '21:45:00', 474, 927, 208, 237),
(134, 'Rendez-vous', 131, 'Maux de ventre', NULL, '08:00:00', '21:30:00', 513, 965, 131, 207),
(135, 'Hospitalisation', 155, 'Rien', NULL, '17:00:00', '10:00:00', 659, 996, 363, 396),
(136, 'Hospitalisation', 128, 'Contractions', NULL, '18:15:00', '18:00:00', 412, 917, 115, 175),
(137, 'Rendez-vous', 129, 'Vertiges', NULL, '16:45:00', '15:00:00', 356, 914, 184, 185),
(138, 'Hospitalisation', 213, 'Vertiges', NULL, '17:00:00', '13:45:00', 535, 944, 273, 334),
(139, 'Hospitalisation', 42, 'Douleurs', NULL, '18:45:00', '22:15:00', 535, 978, 303, 319),
(140, 'Rendez-vous', 232, 'Douleurs', NULL, '10:45:00', '15:00:00', 587, 1002, 309, 378),
(141, 'Rendez-vous', 30, 'Douleurs', NULL, '14:00:00', '13:45:00', 572, 1013, 196, 246),
(142, 'Hospitalisation', 144, 'Contractions', NULL, '16:45:00', '07:00:00', 626, 913, 140, 234),
(143, 'Hospitalisation', 94, 'Pertes de mémoire', NULL, '14:15:00', '07:00:00', 486, 992, 393, 403),
(144, 'Hospitalisation', 127, 'Rien', NULL, '10:45:00', '12:30:00', 537, 1016, 338, 359),
(145, 'Rendez-vous', 144, 'Maux de ventre', NULL, '14:00:00', '11:45:00', 371, 892, 108, 184),
(146, 'Hospitalisation', 220, 'Douleurs', NULL, '22:00:00', '11:30:00', 532, 1005, 227, 247),
(147, 'Hospitalisation', 145, 'Démances', NULL, '14:15:00', '21:15:00', 554, 920, 329, 375),
(148, 'Rendez-vous', 18, 'Douleurs', NULL, '10:30:00', '08:00:00', 454, 1008, 267, 271),
(149, 'Hospitalisation', 107, 'Maux de gorges', NULL, '13:45:00', '22:15:00', 546, 925, 149, 182),
(150, 'Hospitalisation', 231, 'Vertiges', NULL, '22:45:00', '11:00:00', 496, 956, 255, 340),
(151, 'Rendez-vous', 196, 'Vertiges', NULL, '17:45:00', '07:30:00', 610, 886, 372, 468),
(152, 'Hospitalisation', 146, 'Pertes de mémoire', NULL, '15:00:00', '08:45:00', 509, 1020, 184, 268),
(153, 'Rendez-vous', 184, 'Rien', NULL, '16:15:00', '18:45:00', 641, 980, 344, 413),
(154, 'Hospitalisation', 94, 'Vertiges', NULL, '13:30:00', '22:45:00', 653, 958, 348, 366),
(155, 'Rendez-vous', 152, 'Démances', NULL, '18:30:00', '18:45:00', 559, 931, 86, 166),
(156, 'Rendez-vous', 100, 'Démances', NULL, '14:45:00', '11:00:00', 570, 941, 324, 397),
(157, 'Hospitalisation', 176, 'Maux de dos', NULL, '19:45:00', '08:30:00', 542, 947, 304, 356),
(158, 'Hospitalisation', 99, 'Douleurs', NULL, '20:45:00', '18:00:00', 641, 1012, 304, 401),
(159, 'Hospitalisation', 234, 'Démances', NULL, '10:00:00', '17:00:00', 437, 1004, 213, 288),
(160, 'Hospitalisation', 196, 'Douleurs', NULL, '15:45:00', '12:30:00', 401, 929, 270, 362),
(161, 'Rendez-vous', 136, 'Maux de gorges', NULL, '14:15:00', '22:00:00', 628, 899, 65, 70),
(162, 'Rendez-vous', 210, 'Démances', NULL, '19:30:00', '22:00:00', 344, 949, 201, 275),
(163, 'Rendez-vous', 112, 'Maux de dos', NULL, '07:15:00', '09:00:00', 469, 947, 335, 428),
(164, 'Rendez-vous', 197, 'Contractions', NULL, '13:15:00', '13:45:00', 608, 909, 31, 47),
(165, 'Hospitalisation', 130, 'Fourmis', NULL, '07:45:00', '08:30:00', 555, 908, 202, 221),
(166, 'Hospitalisation', 129, 'Fourmis', NULL, '15:15:00', '10:00:00', 544, 908, 72, 172),
(167, 'Hospitalisation', 176, 'Maux de ventre', NULL, '10:15:00', '17:45:00', 403, 979, 249, 250),
(168, 'Rendez-vous', 192, 'Contractions', NULL, '08:00:00', '17:30:00', 657, 951, 372, 415),
(169, 'Rendez-vous', 164, 'Douleurs', NULL, '19:00:00', '16:00:00', 411, 986, 230, 278),
(170, 'Rendez-vous', 91, 'Maux de dos', NULL, '18:00:00', '12:15:00', 520, 1023, 208, 251),
(171, 'Rendez-vous', 65, 'Contractions', NULL, '18:15:00', '11:30:00', 584, 1013, 223, 270),
(172, 'Hospitalisation', 147, 'Fourmis', NULL, '19:15:00', '08:00:00', 456, 971, 31, 99),
(173, 'Rendez-vous', 123, 'Fourmis', NULL, '11:15:00', '20:45:00', 629, 956, 92, 105),
(174, 'Rendez-vous', 19, 'Pertes de mémoire', NULL, '08:30:00', '22:30:00', 451, 999, 44, 50),
(175, 'Rendez-vous', 146, 'Pertes de mémoire', NULL, '18:15:00', '18:00:00', 397, 958, 38, 79),
(176, 'Rendez-vous', 58, 'Maux de ventre', NULL, '16:00:00', '10:30:00', 459, 995, 3, 62),
(177, 'Hospitalisation', 237, 'Vertiges', NULL, '11:45:00', '12:15:00', 348, 928, 11, 99),
(178, 'Rendez-vous', 178, 'Démances', NULL, '18:00:00', '19:15:00', 512, 932, 226, 227),
(179, 'Rendez-vous', 146, 'Rien', NULL, '18:15:00', '22:30:00', 429, 931, 188, 205),
(180, 'Hospitalisation', 131, 'Vertiges', NULL, '07:45:00', '19:15:00', 525, 892, 388, 451),
(181, 'Rendez-vous', 113, 'Pertes de mémoire', NULL, '09:00:00', '20:30:00', 544, 1006, 343, 355),
(182, 'Rendez-vous', 75, 'Fourmis', NULL, '07:45:00', '20:45:00', 635, 969, 22, 96),
(183, 'Hospitalisation', 89, 'Maux de dos', NULL, '08:45:00', '16:00:00', 338, 952, 228, 255),
(184, 'Rendez-vous', 244, 'Rien', NULL, '08:30:00', '08:45:00', 388, 897, 121, 205),
(185, 'Rendez-vous', 900, 'Mal partout', NULL, '08:06:00', '07:06:00', 332, 1112, 27, 29);

--
-- Déclencheurs `consultation`
--
DELIMITER $$
CREATE TRIGGER `Suppression_contenir_medicaments` BEFORE DELETE ON `consultation` FOR EACH ROW DELETE FROM contenir
WHERE contenir.ID_consultation = OLD.ID_consultation
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Suppression_intervention` BEFORE DELETE ON `consultation` FOR EACH ROW DELETE FROM intervention
WHERE intervention.ID_consultation = OLD.ID_consultation
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `Suppression_passer_examen` BEFORE DELETE ON `consultation` FOR EACH ROW DELETE FROM passer
WHERE passer.ID_consultation = OLD.ID_consultation
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `contenir`
--

CREATE TABLE `contenir` (
  `ID_consultation` int(5) UNSIGNED NOT NULL,
  `ID_medicament` int(5) UNSIGNED NOT NULL,
  `Quantite_medicament` int(11) NOT NULL,
  `Date_prescrption` date NOT NULL,
  `Duree_prescription` int(11) NOT NULL,
  `Frequence_prise` varchar(15) NOT NULL COMMENT 'matin, midi, soir'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déclencheurs `contenir`
--
DELIMITER $$
CREATE TRIGGER `Mise_à_jour_stocks_medicaments_suppression` AFTER DELETE ON `contenir` FOR EACH ROW UPDATE medicament
SET medicament.Quantite_nb_boites = medicament.Quantite_nb_boites+OLD.Quantite_medicament
WHERE medicament.ID_medicament = OLD.ID_medicament
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `contenir_3`
--

CREATE TABLE `contenir_3` (
  `ID_commande` int(5) UNSIGNED NOT NULL,
  `ID_medicament` int(5) UNSIGNED NOT NULL,
  `Quantite_medicament` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `contenir_3`
--

INSERT INTO `contenir_3` (`ID_commande`, `ID_medicament`, `Quantite_medicament`) VALUES
(1, 1506, 200),
(1, 1507, 400),
(2, 1506, 50);

--
-- Déclencheurs `contenir_3`
--
DELIMITER $$
CREATE TRIGGER `Mise_a_jour_prix_commande_medicaments` AFTER INSERT ON `contenir_3` FOR EACH ROW UPDATE commande
SET commande.Montant_commande =
((SELECT medicament.Prix_boite FROM medicament WHERE NEW.ID_medicament = medicament.ID_medicament) *NEW.Quantite_medicament) + commande.Montant_commande
WHERE commande.ID_commande = NEW.ID_commande
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `contenir_4`
--

CREATE TABLE `contenir_4` (
  `ID_materiel` int(5) UNSIGNED NOT NULL,
  `ID_commande` int(5) UNSIGNED NOT NULL,
  `Quantite_materiel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `contenir_4`
--

INSERT INTO `contenir_4` (`ID_materiel`, `ID_commande`, `Quantite_materiel`) VALUES
(1, 2, 2),
(10, 1, 2),
(10, 2, 1),
(131, 1, 30);

--
-- Déclencheurs `contenir_4`
--
DELIMITER $$
CREATE TRIGGER `Mise_a_jour_prix_commande_materiel` AFTER INSERT ON `contenir_4` FOR EACH ROW UPDATE commande
SET commande.Montant_commande = commande.Montant_commande + 
((SELECT materiel.Prix_unitaire FROM materiel WHERE NEW.ID_materiel = materiel.ID_materiel) *NEW.Quantite_materiel)
WHERE commande.ID_commande = NEW.ID_commande
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `effectuer_3`
--

CREATE TABLE `effectuer_3` (
  `ID_personnel` int(5) UNSIGNED NOT NULL,
  `ID_intervention` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `effectuer_4`
--

CREATE TABLE `effectuer_4` (
  `ID_garde` int(5) UNSIGNED NOT NULL,
  `ID_personnel` int(5) UNSIGNED NOT NULL,
  `Obligatoire` tinyint(1) NOT NULL COMMENT 'True = obligatoire False = pas obligatoire'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `effectuer_4`
--

INSERT INTO `effectuer_4` (`ID_garde`, `ID_personnel`, `Obligatoire`) VALUES
(498, 926, 1),
(498, 952, 1),
(500, 938, 0),
(500, 981, 0),
(503, 933, 1),
(504, 1004, 1),
(510, 922, 0),
(513, 908, 0),
(513, 929, 0),
(513, 986, 0),
(513, 1005, 0),
(513, 1021, 0),
(514, 970, 1),
(514, 997, 0),
(515, 1011, 1),
(516, 1003, 1),
(517, 929, 0),
(518, 1016, 1),
(519, 953, 0),
(519, 962, 0),
(519, 983, 1),
(521, 905, 0),
(521, 1013, 0),
(522, 1008, 1),
(526, 908, 1),
(528, 933, 0),
(528, 942, 0),
(529, 939, 0),
(529, 988, 0),
(530, 1021, 0),
(533, 893, 1),
(535, 1019, 1),
(536, 1013, 0),
(539, 900, 0),
(539, 903, 0),
(539, 914, 0),
(539, 939, 1),
(541, 896, 1),
(541, 949, 0),
(543, 956, 1),
(545, 922, 1),
(546, 908, 1),
(547, 1018, 1),
(548, 961, 1),
(549, 924, 1),
(549, 1023, 0),
(550, 1023, 1),
(551, 980, 1),
(553, 930, 1),
(553, 957, 0),
(554, 984, 0),
(554, 1013, 1),
(557, 885, 1),
(557, 900, 1),
(558, 941, 1),
(558, 942, 1),
(560, 911, 1),
(560, 955, 1),
(561, 902, 0),
(561, 939, 1),
(563, 889, 0),
(564, 1009, 0),
(566, 981, 0),
(567, 994, 0),
(569, 890, 0),
(569, 900, 0),
(569, 1022, 0),
(571, 893, 0),
(571, 937, 1),
(575, 996, 1),
(578, 895, 0),
(578, 902, 1),
(578, 951, 1),
(578, 988, 1),
(578, 989, 0),
(580, 912, 0),
(582, 932, 1),
(582, 940, 1),
(583, 976, 0),
(585, 894, 0),
(585, 961, 1),
(585, 1013, 0),
(587, 907, 1),
(587, 1008, 1),
(589, 989, 0),
(589, 1014, 0),
(590, 891, 0),
(590, 974, 0),
(591, 1008, 1),
(592, 930, 0),
(594, 1007, 1),
(596, 903, 0),
(596, 945, 0),
(598, 1022, 0),
(599, 1018, 1),
(601, 997, 0),
(604, 963, 1),
(606, 983, 1),
(607, 888, 0),
(607, 941, 0),
(608, 988, 0),
(609, 890, 0),
(611, 955, 1),
(612, 941, 0),
(613, 922, 1),
(613, 977, 1),
(613, 978, 1),
(615, 911, 0),
(615, 931, 1),
(615, 945, 0),
(615, 963, 0),
(616, 904, 1),
(619, 901, 1),
(619, 932, 0),
(620, 993, 0),
(621, 936, 0),
(622, 1023, 1),
(623, 914, 0),
(623, 998, 0),
(626, 892, 1),
(628, 1011, 0),
(629, 921, 0),
(631, 891, 0),
(631, 946, 0),
(632, 1012, 0),
(633, 939, 0),
(634, 975, 1),
(635, 1014, 1),
(636, 954, 0),
(637, 983, 0),
(638, 901, 0),
(639, 916, 0),
(639, 926, 0),
(639, 952, 0),
(640, 894, 0),
(640, 947, 1),
(640, 958, 1),
(640, 976, 0),
(642, 1003, 0),
(644, 902, 0),
(644, 1008, 0),
(645, 902, 1),
(645, 910, 0),
(645, 986, 1),
(646, 981, 1),
(646, 997, 1),
(648, 892, 0),
(649, 1017, 1),
(650, 898, 0),
(650, 995, 0),
(651, 978, 0),
(652, 932, 1),
(653, 926, 0),
(653, 938, 1),
(654, 1020, 0),
(659, 971, 0),
(659, 1003, 1),
(659, 1012, 0),
(660, 970, 1),
(664, 956, 1),
(665, 902, 1),
(666, 893, 1),
(666, 972, 1),
(668, 986, 0),
(669, 889, 0),
(669, 912, 0),
(670, 993, 1),
(671, 909, 1),
(671, 911, 0),
(674, 936, 1),
(675, 956, 1),
(676, 918, 1),
(676, 996, 0),
(677, 888, 1),
(678, 911, 0),
(678, 988, 0),
(679, 943, 0),
(679, 1019, 0),
(680, 922, 1),
(681, 919, 1),
(682, 1002, 0),
(684, 915, 0),
(685, 986, 0),
(685, 988, 0),
(687, 946, 0),
(688, 924, 1),
(690, 950, 1),
(691, 940, 0),
(692, 939, 0),
(693, 933, 1),
(694, 927, 1),
(696, 885, 0),
(696, 948, 1),
(696, 969, 0),
(698, 943, 0),
(699, 904, 1),
(700, 962, 0),
(702, 886, 1),
(702, 978, 1),
(705, 979, 1),
(705, 1004, 1),
(706, 902, 0),
(707, 920, 1),
(707, 991, 1),
(708, 910, 0),
(710, 953, 0),
(710, 997, 1),
(712, 978, 0),
(713, 990, 0),
(713, 1007, 1),
(714, 921, 0),
(715, 949, 1),
(716, 1022, 0),
(718, 885, 1),
(718, 948, 1),
(719, 944, 1),
(719, 965, 0),
(719, 991, 1),
(720, 949, 0),
(720, 998, 0),
(721, 947, 0),
(722, 916, 0),
(722, 921, 0),
(722, 925, 0),
(722, 952, 0),
(722, 979, 0),
(723, 909, 0),
(724, 920, 0),
(725, 936, 0),
(728, 1019, 0),
(729, 911, 1),
(730, 890, 1),
(731, 1023, 1),
(732, 962, 0),
(732, 1012, 1),
(733, 995, 1),
(735, 899, 0),
(735, 976, 1),
(736, 980, 1),
(738, 918, 0),
(739, 893, 1),
(740, 919, 0),
(746, 1017, 0),
(747, 887, 1),
(747, 897, 0),
(747, 939, 0),
(748, 889, 0),
(748, 1002, 1),
(749, 900, 0),
(749, 933, 0),
(750, 918, 1),
(750, 999, 0),
(750, 1007, 1),
(750, 1017, 0),
(751, 917, 0),
(753, 914, 0),
(755, 968, 0),
(755, 1020, 1),
(756, 967, 0),
(757, 903, 1),
(757, 910, 0),
(757, 915, 0),
(757, 947, 0),
(762, 976, 0),
(763, 930, 0),
(763, 1002, 1),
(764, 892, 1),
(765, 894, 0),
(768, 983, 1),
(769, 906, 1),
(769, 924, 1),
(771, 1003, 0),
(771, 1025, 1),
(773, 908, 1),
(775, 911, 0),
(775, 1002, 1),
(776, 919, 1),
(776, 987, 1),
(780, 884, 0),
(780, 913, 1),
(781, 931, 1),
(783, 987, 1),
(784, 991, 0),
(785, 954, 1),
(785, 957, 0),
(787, 1022, 0),
(788, 889, 0),
(788, 1018, 0),
(791, 888, 1),
(794, 937, 0),
(794, 978, 1),
(796, 930, 1),
(797, 945, 0),
(798, 931, 1),
(798, 965, 0),
(800, 985, 0),
(800, 990, 1),
(802, 972, 0),
(803, 1024, 0),
(804, 953, 1),
(805, 1009, 1),
(806, 893, 1),
(809, 898, 0),
(812, 919, 0),
(812, 928, 1),
(813, 888, 0),
(814, 954, 1),
(820, 889, 1),
(822, 905, 1),
(827, 1019, 1),
(828, 908, 1),
(828, 993, 0),
(831, 911, 0),
(831, 935, 0),
(831, 959, 0),
(833, 898, 1),
(833, 900, 0),
(837, 988, 1),
(839, 986, 0),
(841, 994, 0),
(844, 1006, 1),
(845, 937, 1),
(846, 933, 0),
(846, 984, 1),
(848, 956, 1),
(849, 901, 0),
(849, 1002, 0),
(850, 1008, 0),
(851, 986, 1),
(852, 995, 0),
(853, 962, 1),
(853, 1018, 0),
(854, 895, 1),
(854, 931, 0),
(855, 963, 1),
(856, 981, 0),
(856, 982, 0),
(856, 1010, 0),
(858, 950, 0),
(859, 929, 0),
(859, 947, 1),
(861, 966, 0),
(861, 991, 1),
(861, 1025, 1),
(864, 975, 1),
(866, 950, 0),
(867, 991, 0),
(869, 889, 1),
(869, 899, 1),
(869, 957, 0),
(870, 923, 1),
(870, 972, 0),
(872, 939, 0),
(872, 993, 0),
(872, 1020, 1),
(874, 938, 1),
(875, 934, 0),
(877, 969, 1),
(878, 974, 1),
(878, 979, 0),
(878, 993, 1),
(879, 924, 1),
(882, 958, 0),
(882, 1019, 1),
(883, 899, 0),
(883, 947, 1),
(884, 894, 0),
(884, 923, 0),
(885, 889, 1),
(885, 995, 1),
(885, 1011, 1),
(887, 918, 0),
(887, 964, 0),
(887, 1001, 0),
(891, 941, 0),
(891, 961, 1),
(891, 982, 0),
(892, 925, 0),
(893, 965, 0),
(893, 969, 1),
(894, 910, 1),
(894, 1009, 1),
(895, 989, 0),
(896, 948, 1),
(896, 956, 0),
(897, 1000, 0),
(899, 1011, 0),
(901, 911, 1),
(912, 1014, 0),
(913, 897, 1),
(913, 920, 0),
(913, 956, 0),
(913, 972, 0),
(913, 1008, 1),
(914, 961, 1),
(915, 1001, 0),
(916, 945, 1),
(917, 947, 1),
(918, 904, 1),
(919, 977, 1),
(919, 999, 0),
(920, 926, 0),
(920, 963, 1),
(921, 897, 1),
(922, 926, 1),
(923, 907, 1),
(924, 936, 1),
(925, 987, 1),
(925, 997, 0),
(925, 1005, 1),
(928, 936, 1),
(930, 932, 0),
(931, 922, 0),
(932, 925, 0),
(932, 938, 0),
(933, 973, 0),
(936, 1014, 0),
(937, 1001, 1),
(937, 1008, 1),
(938, 904, 1),
(938, 917, 0),
(938, 932, 0),
(938, 934, 0),
(942, 970, 0),
(946, 999, 0),
(947, 921, 1),
(952, 917, 1),
(953, 952, 1),
(953, 992, 0),
(954, 929, 1),
(954, 992, 0),
(956, 951, 0),
(958, 953, 0),
(959, 1009, 0),
(960, 938, 1),
(963, 901, 1),
(964, 1004, 1),
(966, 939, 1),
(970, 932, 1),
(970, 944, 0),
(974, 959, 1),
(974, 960, 1),
(974, 971, 1),
(975, 937, 1),
(976, 932, 1),
(976, 997, 0),
(976, 1015, 0),
(979, 913, 1),
(979, 915, 0),
(980, 1019, 0),
(981, 962, 1),
(982, 891, 0),
(984, 1025, 1),
(986, 924, 1),
(987, 941, 1),
(987, 1005, 0),
(988, 941, 1),
(988, 984, 1),
(988, 1004, 1),
(989, 959, 1),
(990, 988, 1),
(991, 925, 1),
(994, 947, 0),
(995, 919, 1),
(996, 1016, 0),
(997, 908, 1),
(998, 919, 1),
(998, 943, 0),
(998, 975, 0),
(999, 1017, 0),
(999, 1023, 1);

-- --------------------------------------------------------

--
-- Structure de la table `etablissement`
--

CREATE TABLE `etablissement` (
  `ID_etablissement` int(5) UNSIGNED NOT NULL,
  `Adresse_etablissement` varchar(100) NOT NULL,
  `Ville_etablissement` varchar(50) DEFAULT NULL,
  `Code_postale_etablissement` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `etablissement`
--

INSERT INTO `etablissement` (`ID_etablissement`, `Adresse_etablissement`, `Ville_etablissement`, `Code_postale_etablissement`) VALUES
(1, '5 rue Berger', 'Paris', 75001),
(2, '3 boulevard Malesherbes', 'Paris', 75008),
(3, '19 rue des Gobelins', 'Paris', 75013);

-- --------------------------------------------------------

--
-- Structure de la table `examen`
--

CREATE TABLE `examen` (
  `ID_examen` int(5) UNSIGNED NOT NULL,
  `Nom_examen` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `examen`
--

INSERT INTO `examen` (`ID_examen`, `Nom_examen`) VALUES
(1, 'IRM'),
(2, 'PET-scan'),
(3, 'Coloscopie'),
(4, 'Calcémie'),
(5, 'Caryotype'),
(6, 'Doppler'),
(7, 'ECBU'),
(8, 'ECG'),
(9, 'Echographie'),
(10, 'Endoscopie'),
(11, 'Fibroscopie'),
(12, 'Glycémie'),
(13, 'Mammographie'),
(14, 'PCR'),
(15, 'QI'),
(16, 'Tomographie'),
(17, 'Test de grossesse');

-- --------------------------------------------------------

--
-- Structure de la table `fournisseur`
--

CREATE TABLE `fournisseur` (
  `ID_fournisseur` int(5) UNSIGNED NOT NULL,
  `Nom_fournisseur` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `fournisseur`
--

INSERT INTO `fournisseur` (`ID_fournisseur`, `Nom_fournisseur`) VALUES
(1, 'Sanofi'),
(3, 'Siemens'),
(6, 'Bayer'),
(7, 'Théa'),
(8, 'Servier'),
(9, 'LFB'),
(10, 'Pierre Fabre'),
(12, 'Boiron'),
(14, 'Pfaizer'),
(15, 'Roche'),
(16, 'Biogaran'),
(17, 'France neir'),
(18, 'Sécurimed'),
(19, 'Smith & Nephew'),
(20, 'Hartman');

-- --------------------------------------------------------

--
-- Structure de la table `garde`
--

CREATE TABLE `garde` (
  `ID_garde` int(5) UNSIGNED NOT NULL,
  `Montant_garde` float NOT NULL,
  `ID_jour` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `garde`
--

INSERT INTO `garde` (`ID_garde`, `Montant_garde`, `ID_jour`) VALUES
(498, 130, 3),
(499, 130, 4),
(500, 130, 5),
(501, 130, 6),
(502, 130, 7),
(503, 130, 8),
(504, 130, 9),
(505, 130, 10),
(506, 130, 11),
(507, 130, 12),
(508, 130, 13),
(509, 130, 14),
(510, 130, 15),
(511, 130, 16),
(512, 130, 17),
(513, 130, 18),
(514, 130, 19),
(515, 130, 20),
(516, 130, 21),
(517, 130, 22),
(518, 130, 23),
(519, 130, 24),
(520, 130, 25),
(521, 130, 26),
(522, 130, 27),
(523, 130, 28),
(524, 130, 29),
(525, 130, 30),
(526, 130, 31),
(527, 130, 32),
(528, 130, 33),
(529, 130, 34),
(530, 130, 35),
(531, 130, 36),
(532, 130, 37),
(533, 130, 38),
(534, 130, 39),
(535, 130, 40),
(536, 130, 41),
(537, 130, 42),
(538, 130, 43),
(539, 130, 44),
(540, 130, 45),
(541, 130, 46),
(542, 130, 47),
(543, 130, 48),
(544, 130, 49),
(545, 130, 50),
(546, 130, 51),
(547, 130, 52),
(548, 130, 53),
(549, 130, 54),
(550, 130, 55),
(551, 130, 56),
(552, 130, 57),
(553, 130, 58),
(554, 130, 59),
(555, 130, 60),
(556, 130, 61),
(557, 130, 62),
(558, 130, 63),
(559, 130, 64),
(560, 130, 65),
(561, 130, 66),
(562, 130, 67),
(563, 130, 68),
(564, 130, 69),
(565, 130, 70),
(566, 130, 71),
(567, 130, 72),
(568, 130, 73),
(569, 130, 74),
(570, 130, 75),
(571, 130, 76),
(572, 130, 77),
(573, 130, 78),
(574, 130, 79),
(575, 130, 80),
(576, 130, 81),
(577, 130, 82),
(578, 130, 83),
(579, 130, 84),
(580, 130, 85),
(581, 130, 86),
(582, 130, 87),
(583, 130, 88),
(584, 130, 89),
(585, 130, 90),
(586, 130, 91),
(587, 130, 92),
(588, 130, 93),
(589, 130, 94),
(590, 130, 95),
(591, 130, 96),
(592, 130, 97),
(593, 130, 98),
(594, 130, 99),
(595, 130, 100),
(596, 130, 101),
(597, 130, 102),
(598, 130, 103),
(599, 130, 104),
(600, 130, 105),
(601, 130, 106),
(602, 130, 107),
(603, 130, 108),
(604, 130, 109),
(605, 130, 110),
(606, 130, 111),
(607, 130, 112),
(608, 130, 113),
(609, 130, 114),
(610, 130, 115),
(611, 130, 116),
(612, 130, 117),
(613, 130, 118),
(614, 130, 119),
(615, 130, 120),
(616, 130, 121),
(617, 130, 122),
(618, 130, 123),
(619, 130, 124),
(620, 130, 125),
(621, 130, 126),
(622, 130, 127),
(623, 130, 128),
(624, 130, 129),
(625, 130, 130),
(626, 130, 131),
(627, 130, 132),
(628, 130, 133),
(629, 130, 134),
(630, 130, 135),
(631, 130, 136),
(632, 130, 137),
(633, 130, 138),
(634, 130, 139),
(635, 130, 140),
(636, 130, 141),
(637, 130, 142),
(638, 130, 143),
(639, 130, 144),
(640, 130, 145),
(641, 130, 146),
(642, 130, 147),
(643, 130, 148),
(644, 130, 149),
(645, 130, 150),
(646, 130, 151),
(647, 130, 152),
(648, 130, 153),
(649, 130, 154),
(650, 130, 155),
(651, 130, 156),
(652, 130, 157),
(653, 130, 158),
(654, 130, 159),
(655, 130, 160),
(656, 130, 161),
(657, 130, 162),
(658, 130, 163),
(659, 130, 164),
(660, 130, 165),
(661, 130, 166),
(662, 130, 167),
(663, 130, 168),
(664, 130, 169),
(665, 130, 170),
(666, 130, 171),
(667, 130, 172),
(668, 130, 173),
(669, 130, 174),
(670, 130, 175),
(671, 130, 176),
(672, 130, 177),
(673, 130, 178),
(674, 130, 179),
(675, 130, 180),
(676, 130, 181),
(677, 130, 182),
(678, 130, 183),
(679, 130, 184),
(680, 130, 185),
(681, 130, 186),
(682, 130, 187),
(683, 130, 188),
(684, 130, 189),
(685, 130, 190),
(686, 130, 191),
(687, 130, 192),
(688, 130, 193),
(689, 130, 194),
(690, 130, 195),
(691, 130, 196),
(692, 130, 197),
(693, 130, 198),
(694, 130, 199),
(695, 130, 200),
(696, 130, 201),
(697, 130, 202),
(698, 130, 203),
(699, 130, 204),
(700, 130, 205),
(701, 130, 206),
(702, 130, 207),
(703, 130, 208),
(704, 130, 209),
(705, 130, 210),
(706, 130, 211),
(707, 130, 212),
(708, 130, 213),
(709, 130, 214),
(710, 130, 215),
(711, 130, 216),
(712, 130, 217),
(713, 130, 218),
(714, 130, 219),
(715, 130, 220),
(716, 130, 221),
(717, 130, 222),
(718, 130, 223),
(719, 130, 224),
(720, 130, 225),
(721, 130, 226),
(722, 130, 227),
(723, 130, 228),
(724, 130, 229),
(725, 130, 230),
(726, 130, 231),
(727, 130, 232),
(728, 130, 233),
(729, 130, 234),
(730, 130, 235),
(731, 130, 236),
(732, 130, 237),
(733, 130, 238),
(734, 130, 239),
(735, 130, 240),
(736, 130, 241),
(737, 130, 242),
(738, 130, 243),
(739, 130, 244),
(740, 130, 245),
(741, 130, 246),
(742, 130, 247),
(743, 130, 248),
(744, 130, 249),
(745, 130, 250),
(746, 130, 251),
(747, 130, 252),
(748, 130, 253),
(749, 130, 254),
(750, 130, 255),
(751, 130, 256),
(752, 130, 257),
(753, 130, 258),
(754, 130, 259),
(755, 130, 260),
(756, 130, 261),
(757, 130, 262),
(758, 130, 263),
(759, 130, 264),
(760, 130, 265),
(761, 130, 266),
(762, 130, 267),
(763, 130, 268),
(764, 130, 269),
(765, 130, 270),
(766, 130, 271),
(767, 130, 272),
(768, 130, 273),
(769, 130, 274),
(770, 130, 275),
(771, 130, 276),
(772, 130, 277),
(773, 130, 278),
(774, 130, 279),
(775, 130, 280),
(776, 130, 281),
(777, 130, 282),
(778, 130, 283),
(779, 130, 284),
(780, 130, 285),
(781, 130, 286),
(782, 130, 287),
(783, 130, 288),
(784, 130, 289),
(785, 130, 290),
(786, 130, 291),
(787, 130, 292),
(788, 130, 293),
(789, 130, 294),
(790, 130, 295),
(791, 130, 296),
(792, 130, 297),
(793, 130, 298),
(794, 130, 299),
(795, 130, 300),
(796, 130, 301),
(797, 130, 302),
(798, 130, 303),
(799, 130, 304),
(800, 130, 305),
(801, 130, 306),
(802, 130, 307),
(803, 130, 308),
(804, 130, 309),
(805, 130, 310),
(806, 130, 311),
(807, 130, 312),
(808, 130, 313),
(809, 130, 314),
(810, 130, 315),
(811, 130, 316),
(812, 130, 317),
(813, 130, 318),
(814, 130, 319),
(815, 130, 320),
(816, 130, 321),
(817, 130, 322),
(818, 130, 323),
(819, 130, 324),
(820, 130, 325),
(821, 130, 326),
(822, 130, 327),
(823, 130, 328),
(824, 130, 329),
(825, 130, 330),
(826, 130, 331),
(827, 130, 332),
(828, 130, 333),
(829, 130, 334),
(830, 130, 335),
(831, 130, 336),
(832, 130, 337),
(833, 130, 338),
(834, 130, 339),
(835, 130, 340),
(836, 130, 341),
(837, 130, 342),
(838, 130, 343),
(839, 130, 344),
(840, 130, 345),
(841, 130, 346),
(842, 130, 347),
(843, 130, 348),
(844, 130, 349),
(845, 130, 350),
(846, 130, 351),
(847, 130, 352),
(848, 130, 353),
(849, 130, 354),
(850, 130, 355),
(851, 130, 356),
(852, 130, 357),
(853, 130, 358),
(854, 130, 359),
(855, 130, 360),
(856, 130, 361),
(857, 130, 362),
(858, 130, 363),
(859, 130, 364),
(860, 130, 365),
(861, 130, 366),
(862, 130, 367),
(863, 130, 368),
(864, 130, 369),
(865, 130, 370),
(866, 130, 371),
(867, 130, 372),
(868, 130, 373),
(869, 130, 374),
(870, 130, 375),
(871, 130, 376),
(872, 130, 377),
(873, 130, 378),
(874, 130, 379),
(875, 130, 380),
(876, 130, 381),
(877, 130, 382),
(878, 130, 383),
(879, 130, 384),
(880, 130, 385),
(881, 130, 386),
(882, 130, 387),
(883, 130, 388),
(884, 130, 389),
(885, 130, 390),
(886, 130, 391),
(887, 130, 392),
(888, 130, 393),
(889, 130, 394),
(890, 130, 395),
(891, 130, 396),
(892, 130, 397),
(893, 130, 398),
(894, 130, 399),
(895, 130, 400),
(896, 130, 401),
(897, 130, 402),
(898, 130, 403),
(899, 130, 404),
(900, 130, 405),
(901, 130, 406),
(902, 130, 407),
(903, 130, 408),
(904, 130, 409),
(905, 130, 410),
(906, 130, 411),
(907, 130, 412),
(908, 130, 413),
(909, 130, 414),
(910, 130, 415),
(911, 130, 416),
(912, 130, 417),
(913, 130, 418),
(914, 130, 419),
(915, 130, 420),
(916, 130, 421),
(917, 130, 422),
(918, 130, 423),
(919, 130, 424),
(920, 130, 425),
(921, 130, 426),
(922, 130, 427),
(923, 130, 428),
(924, 130, 429),
(925, 130, 430),
(926, 130, 431),
(927, 130, 432),
(928, 130, 433),
(929, 130, 434),
(930, 130, 435),
(931, 130, 436),
(932, 130, 437),
(933, 130, 438),
(934, 130, 439),
(935, 130, 440),
(936, 130, 441),
(937, 130, 442),
(938, 130, 443),
(939, 130, 444),
(940, 130, 445),
(941, 130, 446),
(942, 130, 447),
(943, 130, 448),
(944, 130, 449),
(945, 130, 450),
(946, 130, 451),
(947, 130, 452),
(948, 130, 453),
(949, 130, 454),
(950, 130, 455),
(951, 130, 456),
(952, 130, 457),
(953, 130, 458),
(954, 130, 459),
(955, 130, 460),
(956, 130, 461),
(957, 130, 462),
(958, 130, 463),
(959, 130, 464),
(960, 130, 465),
(961, 130, 466),
(962, 130, 467),
(963, 130, 468),
(964, 130, 469),
(965, 130, 470),
(966, 130, 471),
(967, 130, 472),
(968, 130, 473),
(969, 130, 474),
(970, 130, 475),
(971, 130, 476),
(972, 130, 477),
(973, 130, 478),
(974, 130, 479),
(975, 130, 480),
(976, 130, 481),
(977, 130, 482),
(978, 130, 483),
(979, 130, 484),
(980, 130, 485),
(981, 130, 486),
(982, 130, 487),
(983, 130, 488),
(984, 130, 489),
(985, 130, 490),
(986, 130, 491),
(987, 130, 492),
(988, 130, 493),
(989, 130, 494),
(990, 130, 495),
(991, 130, 496),
(992, 130, 497),
(993, 130, 498),
(994, 130, 499),
(995, 130, 500),
(996, 130, 501),
(997, 130, 502),
(998, 130, 503),
(999, 130, 504),
(1000, 130, 505);

-- --------------------------------------------------------

--
-- Structure de la table `intervention`
--

CREATE TABLE `intervention` (
  `ID_intervention` int(5) UNSIGNED NOT NULL,
  `Resultats` varchar(50) NOT NULL,
  `Membre_concerne` varchar(50) NOT NULL,
  `ID_consultation` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déclencheurs `intervention`
--
DELIMITER $$
CREATE TRIGGER `Mise_a_jour_table_effectuer_3` BEFORE DELETE ON `intervention` FOR EACH ROW DELETE FROM effectuer_3 
WHERE effectuer_3.ID_intervention = OLD.ID_intervention
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `jour`
--

CREATE TABLE `jour` (
  `ID_jour` int(5) UNSIGNED NOT NULL,
  `N_semaines` int(2) NOT NULL,
  `Date_jour` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `jour`
--

INSERT INTO `jour` (`ID_jour`, `N_semaines`, `Date_jour`) VALUES
(3, 1, '2021-01-01'),
(4, 1, '2021-01-02'),
(5, 2, '2021-01-03'),
(6, 2, '2021-01-04'),
(7, 2, '2021-01-05'),
(8, 2, '2021-01-06'),
(9, 2, '2021-01-07'),
(10, 2, '2021-01-08'),
(11, 2, '2021-01-09'),
(12, 3, '2021-01-10'),
(13, 3, '2021-01-11'),
(14, 3, '2021-01-12'),
(15, 3, '2021-01-13'),
(16, 3, '2021-01-14'),
(17, 3, '2021-01-15'),
(18, 3, '2021-01-16'),
(19, 4, '2021-01-17'),
(20, 4, '2021-01-18'),
(21, 4, '2021-01-19'),
(22, 4, '2021-01-20'),
(23, 4, '2021-01-21'),
(24, 4, '2021-01-22'),
(25, 4, '2021-01-23'),
(26, 5, '2021-01-24'),
(27, 5, '2021-01-25'),
(28, 5, '2021-01-26'),
(29, 5, '2021-01-27'),
(30, 5, '2021-01-28'),
(31, 5, '2021-01-29'),
(32, 5, '2021-01-30'),
(33, 6, '2021-01-31'),
(34, 6, '2021-02-01'),
(35, 6, '2021-02-02'),
(36, 6, '2021-02-03'),
(37, 6, '2021-02-04'),
(38, 6, '2021-02-05'),
(39, 6, '2021-02-06'),
(40, 7, '2021-02-07'),
(41, 7, '2021-02-08'),
(42, 7, '2021-02-09'),
(43, 7, '2021-02-10'),
(44, 7, '2021-02-11'),
(45, 7, '2021-02-12'),
(46, 7, '2021-02-13'),
(47, 8, '2021-02-14'),
(48, 8, '2021-02-15'),
(49, 8, '2021-02-16'),
(50, 8, '2021-02-17'),
(51, 8, '2021-02-18'),
(52, 8, '2021-02-19'),
(53, 8, '2021-02-20'),
(54, 9, '2021-02-21'),
(55, 9, '2021-02-22'),
(56, 9, '2021-02-23'),
(57, 9, '2021-02-24'),
(58, 9, '2021-02-25'),
(59, 9, '2021-02-26'),
(60, 9, '2021-02-27'),
(61, 10, '2021-02-28'),
(62, 10, '2021-03-01'),
(63, 10, '2021-03-02'),
(64, 10, '2021-03-03'),
(65, 10, '2021-03-04'),
(66, 10, '2021-03-05'),
(67, 10, '2021-03-06'),
(68, 11, '2021-03-07'),
(69, 11, '2021-03-08'),
(70, 11, '2021-03-09'),
(71, 11, '2021-03-10'),
(72, 11, '2021-03-11'),
(73, 11, '2021-03-12'),
(74, 11, '2021-03-13'),
(75, 12, '2021-03-14'),
(76, 12, '2021-03-15'),
(77, 12, '2021-03-16'),
(78, 12, '2021-03-17'),
(79, 12, '2021-03-18'),
(80, 12, '2021-03-19'),
(81, 12, '2021-03-20'),
(82, 13, '2021-03-21'),
(83, 13, '2021-03-22'),
(84, 13, '2021-03-23'),
(85, 13, '2021-03-24'),
(86, 13, '2021-03-25'),
(87, 13, '2021-03-26'),
(88, 13, '2021-03-27'),
(89, 14, '2021-03-28'),
(90, 14, '2021-03-29'),
(91, 14, '2021-03-30'),
(92, 14, '2021-03-31'),
(93, 14, '2021-04-01'),
(94, 14, '2021-04-02'),
(95, 14, '2021-04-03'),
(96, 15, '2021-04-04'),
(97, 15, '2021-04-05'),
(98, 15, '2021-04-06'),
(99, 15, '2021-04-07'),
(100, 15, '2021-04-08'),
(101, 15, '2021-04-09'),
(102, 15, '2021-04-10'),
(103, 16, '2021-04-11'),
(104, 16, '2021-04-12'),
(105, 16, '2021-04-13'),
(106, 16, '2021-04-14'),
(107, 16, '2021-04-15'),
(108, 16, '2021-04-16'),
(109, 16, '2021-04-17'),
(110, 17, '2021-04-18'),
(111, 17, '2021-04-19'),
(112, 17, '2021-04-20'),
(113, 17, '2021-04-21'),
(114, 17, '2021-04-22'),
(115, 17, '2021-04-23'),
(116, 17, '2021-04-24'),
(117, 18, '2021-04-25'),
(118, 18, '2021-04-26'),
(119, 18, '2021-04-27'),
(120, 18, '2021-04-28'),
(121, 18, '2021-04-29'),
(122, 18, '2021-04-30'),
(123, 18, '2021-05-01'),
(124, 19, '2021-05-02'),
(125, 19, '2021-05-03'),
(126, 19, '2021-05-04'),
(127, 19, '2021-05-05'),
(128, 19, '2021-05-06'),
(129, 19, '2021-05-07'),
(130, 19, '2021-05-08'),
(131, 20, '2021-05-09'),
(132, 20, '2021-05-10'),
(133, 20, '2021-05-11'),
(134, 20, '2021-05-12'),
(135, 20, '2021-05-13'),
(136, 20, '2021-05-14'),
(137, 20, '2021-05-15'),
(138, 21, '2021-05-16'),
(139, 21, '2021-05-17'),
(140, 21, '2021-05-18'),
(141, 21, '2021-05-19'),
(142, 21, '2021-05-20'),
(143, 21, '2021-05-21'),
(144, 21, '2021-05-22'),
(145, 22, '2021-05-23'),
(146, 22, '2021-05-24'),
(147, 22, '2021-05-25'),
(148, 22, '2021-05-26'),
(149, 22, '2021-05-27'),
(150, 22, '2021-05-28'),
(151, 22, '2021-05-29'),
(152, 23, '2021-05-30'),
(153, 23, '2021-05-31'),
(154, 23, '2021-06-01'),
(155, 23, '2021-06-02'),
(156, 23, '2021-06-03'),
(157, 23, '2021-06-04'),
(158, 23, '2021-06-05'),
(159, 24, '2021-06-06'),
(160, 24, '2021-06-07'),
(161, 24, '2021-06-08'),
(162, 24, '2021-06-09'),
(163, 24, '2021-06-10'),
(164, 24, '2021-06-11'),
(165, 24, '2021-06-12'),
(166, 25, '2021-06-13'),
(167, 25, '2021-06-14'),
(168, 25, '2021-06-15'),
(169, 25, '2021-06-16'),
(170, 25, '2021-06-17'),
(171, 25, '2021-06-18'),
(172, 25, '2021-06-19'),
(173, 26, '2021-06-20'),
(174, 26, '2021-06-21'),
(175, 26, '2021-06-22'),
(176, 26, '2021-06-23'),
(177, 26, '2021-06-24'),
(178, 26, '2021-06-25'),
(179, 26, '2021-06-26'),
(180, 27, '2021-06-27'),
(181, 27, '2021-06-28'),
(182, 27, '2021-06-29'),
(183, 27, '2021-06-30'),
(184, 27, '2021-07-01'),
(185, 27, '2021-07-02'),
(186, 27, '2021-07-03'),
(187, 28, '2021-07-04'),
(188, 28, '2021-07-05'),
(189, 28, '2021-07-06'),
(190, 28, '2021-07-07'),
(191, 28, '2021-07-08'),
(192, 28, '2021-07-09'),
(193, 28, '2021-07-10'),
(194, 29, '2021-07-11'),
(195, 29, '2021-07-12'),
(196, 29, '2021-07-13'),
(197, 29, '2021-07-14'),
(198, 29, '2021-07-15'),
(199, 29, '2021-07-16'),
(200, 29, '2021-07-17'),
(201, 30, '2021-07-18'),
(202, 30, '2021-07-19'),
(203, 30, '2021-07-20'),
(204, 30, '2021-07-21'),
(205, 30, '2021-07-22'),
(206, 30, '2021-07-23'),
(207, 30, '2021-07-24'),
(208, 31, '2021-07-25'),
(209, 31, '2021-07-26'),
(210, 31, '2021-07-27'),
(211, 31, '2021-07-28'),
(212, 31, '2021-07-29'),
(213, 31, '2021-07-30'),
(214, 31, '2021-07-31'),
(215, 32, '2021-08-01'),
(216, 32, '2021-08-02'),
(217, 32, '2021-08-03'),
(218, 32, '2021-08-04'),
(219, 32, '2021-08-05'),
(220, 32, '2021-08-06'),
(221, 32, '2021-08-07'),
(222, 33, '2021-08-08'),
(223, 33, '2021-08-09'),
(224, 33, '2021-08-10'),
(225, 33, '2021-08-11'),
(226, 33, '2021-08-12'),
(227, 33, '2021-08-13'),
(228, 33, '2021-08-14'),
(229, 34, '2021-08-15'),
(230, 34, '2021-08-16'),
(231, 34, '2021-08-17'),
(232, 34, '2021-08-18'),
(233, 34, '2021-08-19'),
(234, 34, '2021-08-20'),
(235, 34, '2021-08-21'),
(236, 35, '2021-08-22'),
(237, 35, '2021-08-23'),
(238, 35, '2021-08-24'),
(239, 35, '2021-08-25'),
(240, 35, '2021-08-26'),
(241, 35, '2021-08-27'),
(242, 35, '2021-08-28'),
(243, 36, '2021-08-29'),
(244, 36, '2021-08-30'),
(245, 36, '2021-08-31'),
(246, 36, '2021-09-01'),
(247, 36, '2021-09-02'),
(248, 36, '2021-09-03'),
(249, 36, '2021-09-04'),
(250, 37, '2021-09-05'),
(251, 37, '2021-09-06'),
(252, 37, '2021-09-07'),
(253, 37, '2021-09-08'),
(254, 37, '2021-09-09'),
(255, 37, '2021-09-10'),
(256, 37, '2021-09-11'),
(257, 38, '2021-09-12'),
(258, 38, '2021-09-13'),
(259, 38, '2021-09-14'),
(260, 38, '2021-09-15'),
(261, 38, '2021-09-16'),
(262, 38, '2021-09-17'),
(263, 38, '2021-09-18'),
(264, 39, '2021-09-19'),
(265, 39, '2021-09-20'),
(266, 39, '2021-09-21'),
(267, 39, '2021-09-22'),
(268, 39, '2021-09-23'),
(269, 39, '2021-09-24'),
(270, 39, '2021-09-25'),
(271, 40, '2021-09-26'),
(272, 40, '2021-09-27'),
(273, 40, '2021-09-28'),
(274, 40, '2021-09-29'),
(275, 40, '2021-09-30'),
(276, 40, '2021-10-01'),
(277, 40, '2021-10-02'),
(278, 41, '2021-10-03'),
(279, 41, '2021-10-04'),
(280, 41, '2021-10-05'),
(281, 41, '2021-10-06'),
(282, 41, '2021-10-07'),
(283, 41, '2021-10-08'),
(284, 41, '2021-10-09'),
(285, 42, '2021-10-10'),
(286, 42, '2021-10-11'),
(287, 42, '2021-10-12'),
(288, 42, '2021-10-13'),
(289, 42, '2021-10-14'),
(290, 42, '2021-10-15'),
(291, 42, '2021-10-16'),
(292, 43, '2021-10-17'),
(293, 43, '2021-10-18'),
(294, 43, '2021-10-19'),
(295, 43, '2021-10-20'),
(296, 43, '2021-10-21'),
(297, 43, '2021-10-22'),
(298, 43, '2021-10-23'),
(299, 44, '2021-10-24'),
(300, 44, '2021-10-25'),
(301, 44, '2021-10-26'),
(302, 44, '2021-10-27'),
(303, 44, '2021-10-28'),
(304, 44, '2021-10-29'),
(305, 44, '2021-10-30'),
(306, 45, '2021-10-31'),
(307, 45, '2021-11-01'),
(308, 45, '2021-11-02'),
(309, 45, '2021-11-03'),
(310, 45, '2021-11-04'),
(311, 45, '2021-11-05'),
(312, 45, '2021-11-06'),
(313, 46, '2021-11-07'),
(314, 46, '2021-11-08'),
(315, 46, '2021-11-09'),
(316, 46, '2021-11-10'),
(317, 46, '2021-11-11'),
(318, 46, '2021-11-12'),
(319, 46, '2021-11-13'),
(320, 47, '2021-11-14'),
(321, 47, '2021-11-15'),
(322, 47, '2021-11-16'),
(323, 47, '2021-11-17'),
(324, 47, '2021-11-18'),
(325, 47, '2021-11-19'),
(326, 47, '2021-11-20'),
(327, 48, '2021-11-21'),
(328, 48, '2021-11-22'),
(329, 48, '2021-11-23'),
(330, 48, '2021-11-24'),
(331, 48, '2021-11-25'),
(332, 48, '2021-11-26'),
(333, 48, '2021-11-27'),
(334, 49, '2021-11-28'),
(335, 49, '2021-11-29'),
(336, 49, '2021-11-30'),
(337, 49, '2021-12-01'),
(338, 49, '2021-12-02'),
(339, 49, '2021-12-03'),
(340, 49, '2021-12-04'),
(341, 50, '2021-12-05'),
(342, 50, '2021-12-06'),
(343, 50, '2021-12-07'),
(344, 50, '2021-12-08'),
(345, 50, '2021-12-09'),
(346, 50, '2021-12-10'),
(347, 50, '2021-12-11'),
(348, 51, '2021-12-12'),
(349, 51, '2021-12-13'),
(350, 51, '2021-12-14'),
(351, 51, '2021-12-15'),
(352, 51, '2021-12-16'),
(353, 51, '2021-12-17'),
(354, 51, '2021-12-18'),
(355, 52, '2021-12-19'),
(356, 52, '2021-12-20'),
(357, 52, '2021-12-21'),
(358, 52, '2021-12-22'),
(359, 52, '2021-12-23'),
(360, 52, '2021-12-24'),
(361, 52, '2021-12-25'),
(362, 53, '2021-12-26'),
(363, 53, '2021-12-27'),
(364, 53, '2021-12-28'),
(365, 53, '2021-12-29'),
(366, 53, '2021-12-30'),
(367, 53, '2021-12-31'),
(368, 1, '2022-01-01'),
(369, 2, '2022-01-02'),
(370, 2, '2022-01-03'),
(371, 2, '2022-01-04'),
(372, 2, '2022-01-05'),
(373, 2, '2022-01-06'),
(374, 2, '2022-01-07'),
(375, 2, '2022-01-08'),
(376, 3, '2022-01-09'),
(377, 3, '2022-01-10'),
(378, 3, '2022-01-11'),
(379, 3, '2022-01-12'),
(380, 3, '2022-01-13'),
(381, 3, '2022-01-14'),
(382, 3, '2022-01-15'),
(383, 4, '2022-01-16'),
(384, 4, '2022-01-17'),
(385, 4, '2022-01-18'),
(386, 4, '2022-01-19'),
(387, 4, '2022-01-20'),
(388, 4, '2022-01-21'),
(389, 4, '2022-01-22'),
(390, 5, '2022-01-23'),
(391, 5, '2022-01-24'),
(392, 5, '2022-01-25'),
(393, 5, '2022-01-26'),
(394, 5, '2022-01-27'),
(395, 5, '2022-01-28'),
(396, 5, '2022-01-29'),
(397, 6, '2022-01-30'),
(398, 6, '2022-01-31'),
(399, 6, '2022-02-01'),
(400, 6, '2022-02-02'),
(401, 6, '2022-02-03'),
(402, 6, '2022-02-04'),
(403, 6, '2022-02-05'),
(404, 7, '2022-02-06'),
(405, 7, '2022-02-07'),
(406, 7, '2022-02-08'),
(407, 7, '2022-02-09'),
(408, 7, '2022-02-10'),
(409, 7, '2022-02-11'),
(410, 7, '2022-02-12'),
(411, 8, '2022-02-13'),
(412, 8, '2022-02-14'),
(413, 8, '2022-02-15'),
(414, 8, '2022-02-16'),
(415, 8, '2022-02-17'),
(416, 8, '2022-02-18'),
(417, 8, '2022-02-19'),
(418, 9, '2022-02-20'),
(419, 9, '2022-02-21'),
(420, 9, '2022-02-22'),
(421, 9, '2022-02-23'),
(422, 9, '2022-02-24'),
(423, 9, '2022-02-25'),
(424, 9, '2022-02-26'),
(425, 10, '2022-02-27'),
(426, 10, '2022-02-28'),
(427, 10, '2022-03-01'),
(428, 10, '2022-03-02'),
(429, 10, '2022-03-03'),
(430, 10, '2022-03-04'),
(431, 10, '2022-03-05'),
(432, 11, '2022-03-06'),
(433, 11, '2022-03-07'),
(434, 11, '2022-03-08'),
(435, 11, '2022-03-09'),
(436, 11, '2022-03-10'),
(437, 11, '2022-03-11'),
(438, 11, '2022-03-12'),
(439, 12, '2022-03-13'),
(440, 12, '2022-03-14'),
(441, 12, '2022-03-15'),
(442, 12, '2022-03-16'),
(443, 12, '2022-03-17'),
(444, 12, '2022-03-18'),
(445, 12, '2022-03-19'),
(446, 13, '2022-03-20'),
(447, 13, '2022-03-21'),
(448, 13, '2022-03-22'),
(449, 13, '2022-03-23'),
(450, 13, '2022-03-24'),
(451, 13, '2022-03-25'),
(452, 13, '2022-03-26'),
(453, 14, '2022-03-27'),
(454, 14, '2022-03-28'),
(455, 14, '2022-03-29'),
(456, 14, '2022-03-30'),
(457, 14, '2022-03-31'),
(458, 14, '2022-04-01'),
(459, 14, '2022-04-02'),
(460, 15, '2022-04-03'),
(461, 15, '2022-04-04'),
(462, 15, '2022-04-05'),
(463, 15, '2022-04-06'),
(464, 15, '2022-04-07'),
(465, 15, '2022-04-08'),
(466, 15, '2022-04-09'),
(467, 16, '2022-04-10'),
(468, 16, '2022-04-11'),
(469, 16, '2022-04-12'),
(470, 16, '2022-04-13'),
(471, 16, '2022-04-14'),
(472, 16, '2022-04-15'),
(473, 16, '2022-04-16'),
(474, 17, '2022-04-17'),
(475, 17, '2022-04-18'),
(476, 17, '2022-04-19'),
(477, 17, '2022-04-20'),
(478, 17, '2022-04-21'),
(479, 17, '2022-04-22'),
(480, 17, '2022-04-23'),
(481, 18, '2022-04-24'),
(482, 18, '2022-04-25'),
(483, 18, '2022-04-26'),
(484, 18, '2022-04-27'),
(485, 18, '2022-04-28'),
(486, 18, '2022-04-29'),
(487, 18, '2022-04-30'),
(488, 19, '2022-05-01'),
(489, 19, '2022-05-02'),
(490, 19, '2022-05-03'),
(491, 19, '2022-05-04'),
(492, 19, '2022-05-05'),
(493, 19, '2022-05-06'),
(494, 19, '2022-05-07'),
(495, 20, '2022-05-08'),
(496, 20, '2022-05-09'),
(497, 20, '2022-05-10'),
(498, 20, '2022-05-11'),
(499, 20, '2022-05-12'),
(500, 20, '2022-05-13'),
(501, 20, '2022-05-14'),
(502, 21, '2022-05-15'),
(503, 21, '2022-05-16'),
(504, 21, '2022-05-17'),
(505, 21, '2022-05-18'),
(506, 21, '2022-05-19'),
(507, 21, '2022-05-20'),
(508, 21, '2022-05-21'),
(509, 22, '2022-05-22'),
(510, 22, '2022-05-23'),
(511, 22, '2022-05-24'),
(512, 22, '2022-05-25'),
(513, 22, '2022-05-26'),
(514, 22, '2022-05-27'),
(515, 22, '2022-05-28'),
(516, 23, '2022-05-29'),
(517, 23, '2022-05-30'),
(518, 23, '2022-05-31'),
(519, 23, '2022-06-01'),
(520, 23, '2022-06-02'),
(521, 23, '2022-06-03'),
(522, 23, '2022-06-04'),
(523, 24, '2022-06-05'),
(524, 24, '2022-06-06'),
(525, 24, '2022-06-07'),
(526, 24, '2022-06-08'),
(527, 24, '2022-06-09');

-- --------------------------------------------------------

--
-- Structure de la table `materiel`
--

CREATE TABLE `materiel` (
  `ID_materiel` int(5) UNSIGNED NOT NULL,
  `Nom_materiel` varchar(50) NOT NULL,
  `Quantité_materiel` int(11) DEFAULT NULL,
  `Prix_unitaire` float DEFAULT 0,
  `Date_derniere_maintenance` date DEFAULT NULL,
  `ID_service` int(5) UNSIGNED NOT NULL,
  `ID_fournisseur` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `materiel`
--

INSERT INTO `materiel` (`ID_materiel`, `Nom_materiel`, `Quantité_materiel`, `Prix_unitaire`, `Date_derniere_maintenance`, `ID_service`, `ID_fournisseur`) VALUES
(1, 'Scope', NULL, 500.5, '2021-12-12', 46, 3),
(2, 'Scope', NULL, 500.5, '2021-04-11', 47, 3),
(3, 'Scope', NULL, 500.5, '2021-03-04', 48, 3),
(4, 'Scope', NULL, 500.5, '2021-11-17', 46, 3),
(5, 'Scope', NULL, 500.5, '2021-04-12', 47, 3),
(6, 'Scope', NULL, 500.5, '2021-02-19', 48, 3),
(7, 'Scope', NULL, 500.5, '2021-12-03', 46, 3),
(8, 'Scope', NULL, 500.5, '2021-08-10', 47, 3),
(9, 'Scope', NULL, 500.5, '2021-01-02', 48, 3),
(10, 'Respirateur', NULL, 3000.99, '2021-08-07', 46, 3),
(11, 'Respirateur', NULL, 3000.99, '2021-02-16', 47, 3),
(12, 'Respirateur', NULL, 3000.99, '2021-12-02', 48, 3),
(13, 'Respirateur', NULL, 3000.99, '2021-03-21', 46, 3),
(14, 'Respirateur', NULL, 3000.99, '2021-10-14', 47, 3),
(15, 'Respirateur', NULL, 3000.99, '2021-06-20', 48, 3),
(16, 'Respirateur', NULL, 3000.99, '2021-04-10', 46, 3),
(17, 'Respirateur', NULL, 3000.99, '2021-06-15', 47, 3),
(18, 'Respirateur', NULL, 3000.99, '2021-02-03', 48, 3),
(19, 'Scope', NULL, 500.5, '2021-12-16', 58, 3),
(20, 'Scope', NULL, 500.5, '2021-04-03', 59, 3),
(21, 'Scope', NULL, 500.5, '2021-05-23', 60, 3),
(22, 'Scope', NULL, 500.5, '2021-02-18', 58, 3),
(23, 'Scope', NULL, 500.5, '2021-02-19', 59, 3),
(24, 'Scope', NULL, 500.5, '2021-08-09', 60, 3),
(25, 'Scope', NULL, 500.5, '2021-10-04', 58, 3),
(26, 'Scope', NULL, 500.5, '2021-09-06', 59, 3),
(27, 'Scope', NULL, 500.5, '2021-10-23', 60, 3),
(28, 'Respirateur', NULL, 3000.99, '2021-03-10', 58, 3),
(29, 'Respirateur', NULL, 3000.99, '2021-01-03', 59, 3),
(30, 'Respirateur', NULL, 3000.99, '2021-05-25', 60, 3),
(31, 'Respirateur', NULL, 3000.99, '2021-09-23', 58, 3),
(32, 'Respirateur', NULL, 3000.99, '2021-09-10', 59, 3),
(33, 'Respirateur', NULL, 3000.99, '2021-09-18', 60, 3),
(34, 'Respirateur', NULL, 3000.99, '2021-04-08', 58, 3),
(35, 'Respirateur', NULL, 3000.99, '2021-06-08', 59, 3),
(36, 'Respirateur', NULL, 3000.99, '2021-04-07', 60, 3),
(37, 'Dialyseur', NULL, 8000.75, '2021-07-23', 51, 19),
(38, 'Dialyseur', NULL, 8000.75, '2021-11-07', 52, 19),
(39, 'Dialyseur', NULL, 8000.75, '2021-07-08', 53, 19),
(40, 'Dialyseur', NULL, 8000.75, '2021-08-04', 51, 19),
(41, 'Dialyseur', NULL, 8000.75, '2021-09-12', 52, 19),
(42, 'Dialyseur', NULL, 8000.75, '2021-08-16', 53, 19),
(43, 'Dialyseur', NULL, 8000.75, '2021-09-20', 51, 19),
(44, 'Dialyseur', NULL, 8000.75, '2021-06-07', 52, 19),
(45, 'Dialyseur', NULL, 8000.75, '2021-11-03', 53, 19),
(46, 'Pinces', 186, 12.8, NULL, 43, 20),
(47, 'Pinces', 718, 12.8, NULL, 44, 20),
(48, 'Pinces', 973, 12.8, NULL, 45, 20),
(49, 'Pinces', 85, 12.8, NULL, 46, 20),
(50, 'Pinces', 600, 12.8, NULL, 47, 20),
(51, 'Pinces', 262, 12.8, NULL, 48, 20),
(52, 'Pinces', 808, 12.8, NULL, 64, 20),
(53, 'Pinces', 257, 12.8, NULL, 65, 20),
(54, 'Pinces', 504, 12.8, NULL, 66, 20),
(55, 'Pinces', 352, 12.8, NULL, 67, 20),
(56, 'Pinces', 898, 12.8, NULL, 68, 20),
(57, 'Pinces', 369, 12.8, NULL, 69, 20),
(58, 'Pinces', 870, 12.8, NULL, 76, 20),
(59, 'Pinces', 639, 12.8, NULL, 77, 20),
(60, 'Pinces', 523, 12.8, NULL, 78, 20),
(61, 'Pinces', 142, 12.8, NULL, 82, 20),
(62, 'Pinces', 624, 12.8, NULL, 83, 20),
(63, 'Pinces', 223, 12.8, NULL, 84, 20),
(64, 'Pansement', 491, 5.8, NULL, 43, 18),
(65, 'Pansement', 789, 5.8, NULL, 44, 18),
(66, 'Pansement', 559, 5.8, NULL, 45, 18),
(67, 'Pansement', 479, 5.8, NULL, 46, 18),
(68, 'Pansement', 243, 5.8, NULL, 47, 18),
(69, 'Pansement', 645, 5.8, NULL, 48, 18),
(70, 'Pansement', 480, 5.8, NULL, 64, 18),
(71, 'Pansement', 279, 5.8, NULL, 65, 18),
(72, 'Pansement', 353, 5.8, NULL, 66, 18),
(73, 'Pansement', 126, 5.8, NULL, 67, 18),
(74, 'Pansement', 85, 5.8, NULL, 68, 18),
(75, 'Pansement', 455, 5.8, NULL, 69, 18),
(76, 'Pansement', 928, 5.8, NULL, 76, 18),
(77, 'Pansement', 847, 5.8, NULL, 77, 18),
(78, 'Pansement', 705, 5.8, NULL, 78, 18),
(79, 'Pansement', 591, 5.8, NULL, 82, 18),
(80, 'Pansement', 843, 5.8, NULL, 83, 18),
(81, 'Pansement', 282, 5.8, NULL, 84, 18),
(82, 'Scalpel', 400, 10, NULL, 43, 14),
(83, 'Scalpel', 719, 10, NULL, 44, 14),
(84, 'Scalpel', 975, 10, NULL, 45, 14),
(85, 'Scalpel', 781, 10, NULL, 46, 14),
(86, 'Scalpel', 364, 10, NULL, 47, 14),
(87, 'Scalpel', 747, 10, NULL, 48, 14),
(88, 'Scalpel', 484, 10, NULL, 64, 14),
(89, 'Scalpel', 869, 10, NULL, 65, 14),
(90, 'Scalpel', 262, 10, NULL, 66, 14),
(91, 'Scalpel', 165, 10, NULL, 67, 14),
(92, 'Scalpel', 109, 10, NULL, 68, 14),
(93, 'Scalpel', 621, 10, NULL, 69, 14),
(94, 'Scalpel', 93, 10, NULL, 76, 14),
(95, 'Scalpel', 979, 10, NULL, 77, 14),
(96, 'Scalpel', 124, 10, NULL, 78, 14),
(97, 'Scalpel', 947, 10, NULL, 82, 14),
(98, 'Scalpel', 198, 10, NULL, 83, 14),
(99, 'Scalpel', 139, 10, NULL, 84, 14),
(100, 'Boustourie électrique', 285, 90, NULL, 43, 15),
(101, 'Boustourie électrique', 991, 90, NULL, 44, 15),
(102, 'Boustourie électrique', 563, 90, NULL, 45, 15),
(103, 'Boustourie électrique', 498, 90, NULL, 46, 15),
(104, 'Boustourie électrique', 524, 90, NULL, 47, 15),
(105, 'Boustourie électrique', 562, 90, NULL, 48, 15),
(106, 'Boustourie électrique', 729, 90, NULL, 64, 15),
(107, 'Boustourie électrique', 378, 90, NULL, 65, 15),
(108, 'Boustourie électrique', 101, 90, NULL, 66, 15),
(109, 'Boustourie électrique', 536, 90, NULL, 67, 15),
(110, 'Boustourie électrique', 353, 90, NULL, 68, 15),
(111, 'Boustourie électrique', 441, 90, NULL, 69, 15),
(112, 'Boustourie électrique', 912, 90, NULL, 76, 15),
(113, 'Boustourie électrique', 299, 90, NULL, 77, 15),
(114, 'Boustourie électrique', 391, 90, NULL, 78, 15),
(115, 'Boustourie électrique', 157, 90, NULL, 82, 15),
(116, 'Boustourie électrique', 569, 90, NULL, 83, 15),
(117, 'Boustourie électrique', 951, 90, NULL, 84, 15),
(121, 'Respirateur', NULL, 3000.99, '2021-07-18', 82, 3),
(122, 'Respirateur', NULL, 3000.99, '2021-09-26', 83, 3),
(123, 'Respirateur', NULL, 3000.99, '2021-02-18', 84, 3),
(124, 'Respirateur', NULL, 3000.99, '2021-02-21', 82, 3),
(125, 'Respirateur', NULL, 3000.99, '2021-06-02', 83, 3),
(126, 'Respirateur', NULL, 3000.99, '2021-10-12', 84, 3),
(127, 'Respirateur', NULL, 3000.99, '2021-07-10', 82, 3),
(128, 'Respirateur', NULL, 3000.99, '2021-05-16', 83, 3),
(129, 'Respirateur', NULL, 3000.99, '2021-07-02', 84, 3),
(130, 'Scope', 0, 500, NULL, 40, 3),
(131, 'Compresses', 500, 2, NULL, 40, 8);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `materiels_populaires`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `materiels_populaires` (
`Nom_materiel` varchar(50)
,`Nombre de commandes du matériel` bigint(21)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `medecin_par_service`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `medecin_par_service` (
`Nom_service` varchar(50)
,`Etablissemet concerné` int(5) unsigned
,`Nombre_medecin_par_service` bigint(21)
);

-- --------------------------------------------------------

--
-- Structure de la table `medicament`
--

CREATE TABLE `medicament` (
  `ID_medicament` int(5) UNSIGNED NOT NULL,
  `Nom_medicament` varchar(300) NOT NULL,
  `Quantite_nb_boites` int(11) NOT NULL,
  `Seuil` int(11) DEFAULT NULL,
  `Prix_boite` float DEFAULT NULL,
  `ID_fournisseur` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `medicament`
--

INSERT INTO `medicament` (`ID_medicament`, `Nom_medicament`, `Quantite_nb_boites`, `Seuil`, `Prix_boite`, `ID_fournisseur`) VALUES
(1506, 'Doliprane', 111, 200, 25, 1),
(1507, 'Fervex', 728, 80, 50, 1),
(1508, 'Ibuprofène', 469, 150, 10, 7),
(1509, 'Morphine', 159, 100, 15, 8),
(1510, 'Inssuline', 648, 150, 40.6, 10),
(1511, 'Dafalgan', 309, 200, 56.8, 16),
(1512, 'Accupan', 189, 70, 45.5, 10),
(1513, 'Biprofenide', 263, 200, 15.5, 16),
(1514, 'Débrida', 832, 400, 78, 10),
(1515, 'Prinpéran', 257, 75, 40.5, 10),
(1516, 'Spasfon', 850, 200, 39.99, 7),
(1517, 'Smecta', 314, 120, 19.99, 8),
(1518, 'Imodium', 979, 80, 20, 12),
(1519, 'Donomyl', 853, 300, 25.5, 16),
(1520, 'Lexomyl', 192, 10, 50, 9),
(1521, 'Lamaline', 682, 50, 27, 10),
(1522, 'Codoliprane', 489, 200, 90, 16),
(1523, 'Ketoprofène', 581, 100, 70, 6),
(1524, 'Météoxane', 675, 140, 55.99, 12),
(1525, 'Lasilix', 941, 90, 80, 7),
(1526, 'Sinvastatine', 398, 100, 42, 9);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `medicaments_populaires`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `medicaments_populaires` (
`Nom_medicament` varchar(300)
,`Nombre de commandes du médicament` bigint(21)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `montant_par_patient`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `montant_par_patient` (
`Nom_patient` varchar(50)
,`Prenom_patient` varchar(50)
,`Montant_paye_par_patient` double
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `moyenne_des_indemnités_dues_aux_gardes_supplémentaires`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `moyenne_des_indemnités_dues_aux_gardes_supplémentaires` (
`AAAA-MM` varchar(7)
,`Nombre de gardes volontaires` bigint(21)
,`Moyenne des gardes volontaires` double
);

-- --------------------------------------------------------

--
-- Structure de la table `mutuelle`
--

CREATE TABLE `mutuelle` (
  `ID_mutuelle` int(5) UNSIGNED NOT NULL,
  `Nom_mutuelle` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `mutuelle`
--

INSERT INTO `mutuelle` (`ID_mutuelle`, `Nom_mutuelle`) VALUES
(1, 'ACORIS MUTUELLES'),
(2, 'ADREA MUTUELLE'),
(3, 'ALLIANCE DES MUTUALISTES DU TRANSPORT ET DU SECTEUR SOCIAL - ALMUTRA'),
(4, 'AMELLIS MUTUELLES'),
(5, 'AMICALE DU PERSONNEL DE FLEURY MICHON SA'),
(6, 'APICIL MUTUELLE'),
(7, 'APIVIA MUTUELLE'),
(8, 'ASSOCIATION GENERALE DES MEDECINS DE FRANCE PREVOYANCE'),
(9, 'AUBEANE MUTUELLE DE FRANCE'),
(10, 'AVENIR MUTUELLE'),
(11, 'AVENIR SANTE MUTUELLE'),
(12, 'BANQUE POPULAIRE MUTUALITE'),
(13, 'BPCE MUTUELLE'),
(14, 'CCMO MUTUELLE'),
(15, 'CDC MUTUELLE'),
(16, 'CHORALIS - MUTUELLE LE LIBRE CHOIX'),
(17, 'COMPLEMENTAIRE ASSURANCE MALADIE INTERDEPARTEMENTALE ET FAMILIALE'),
(18, 'CPAM - SOCIETE MUTUALISTE INTERENTREPRISE DU PERSONNEL DES ORGANISMES SOCIAUX DU LOT'),
(19, 'CYBELE SOLIDARITE'),
(20, 'ENERGIE MUTUELLE'),
(21, 'EOVI-MCD MUTUELLE'),
(22, 'FRANCE MUTUELLE'),
(23, 'GARANCE'),
(24, 'GROUPE DES MUTUELLES INDEPENDANTES'),
(25, 'HARMONIE MUTUELLE'),
(26, 'IDENTITES MUTUELLE'),
(27, 'INTEGRANCE'),
(28, 'INTERIALE MUTUELLE'),
(29, 'IRCEM MUTUELLE'),
(30, 'KLESIA MUT\''),
(31, 'L\'INTERPROFESSIONNELLE'),
(32, 'LA FRANCE MUTUALISTE'),
(33, 'LA FRATERNELLE'),
(34, 'LA FRATERNELLE DES TERRITORIAUX'),
(35, 'LA FRATERNELLE MUTUELLE INTERENTREPRISES'),
(36, 'LA FRATERNITE'),
(37, 'LA MARSILLARGUOISE'),
(38, 'LA MUTUELLE DES ETUDIANTS'),
(39, 'LA MUTUELLE GENERALE'),
(40, 'LA MUTUELLE VERTE'),
(41, 'LA PHILANTHROPIQUE'),
(42, 'LA PREVOYANCE ARTISANALE COMMERCIALE ET SALARIALE'),
(43, 'LA PROBITE'),
(44, 'LA SOLIDARITE MUTUALISTE'),
(45, 'LA VENDARGUOISE'),
(46, 'LAMIE MUTUELLE'),
(47, 'LOU CLAPAS - L\'AVEYRONNAISE'),
(48, 'MACIF MUTUALITE'),
(49, 'MALAKOFF HUMANIS NATIONALE'),
(50, 'MATMUT MUTUALITE'),
(51, 'MCEN - MUTUELLE DES CLERCS ET EMPLOYES DE NOTAIRE'),
(52, 'MCLR'),
(53, 'MFPRECAUTION'),
(54, 'MGDF - MUTUELLE GOODYEAR DUNLOP FRANCE'),
(55, 'MGEFI - MUTUELLE GENERALE DE L\'ECONOMIE DES FINANCES ET DE L\'INDUSTRIE'),
(56, 'MGEN FILIA'),
(57, 'MGP'),
(58, 'MOS'),
(59, 'MPOSS'),
(60, 'MUROS'),
(61, 'MUTAC'),
(62, 'MUTAERO'),
(63, 'MUTAG'),
(64, 'MUTAME & PLUS'),
(65, 'MUTAME SAVOIE MONT BLANC'),
(66, 'MUTAMI'),
(67, 'MUTEST'),
(68, 'MUTEX COLLECTIVES'),
(69, 'MUTEX UNION'),
(70, 'MUTLOG GARANTIES'),
(71, 'MUTUALITE DE LA REUNION'),
(72, 'MUTUELLE 403'),
(73, 'MUTUELLE ACCIDENTS DE LA CONFEDERATION GENERALE DES OEUVRES LAIQUES'),
(74, 'MUTUELLE AIDE ET SOLIDARITE'),
(75, 'MUTUELLE APREVA'),
(76, 'MUTUELLE AVENIR SANTE'),
(77, 'MUTUELLE BLEUE'),
(78, 'MUTUELLE CENTRALE DES FINANCES'),
(79, 'MUTUELLE CHEMINOTS DU NORD'),
(80, 'MUTUELLE CHORUM'),
(81, 'MUTUELLE CNM'),
(82, 'MUTUELLE COMPLEMENTAIRE D\'ALSACE'),
(83, 'MUTUELLE COMPLEMENTAIRE DE LA VILLE DE PARIS DE L\'ASSISTANCE PUBLIQUE ET DES ADMINISTRATIONS ANNEXES'),
(84, 'MUTUELLE D ENTREPRISE DES ETABLISSEMENTS DU BON SAUVEUR'),
(85, 'MUTUELLE D\'ASSURANCE DU PERSONNEL EXTERIEUR SALARIES DU GROUPE AXA'),
(86, 'MUTUELLE D\'ENTRAIDE DE LA MUTUALITE FRANCAISE'),
(87, 'MUTUELLE D\'ENTREPRISE DU PERSONNEL DE LA SOCIETE DES EAUX DE MARSEILLE'),
(88, 'MUTUELLE D\'ENTREPRISE TANIN ET PANNEAUX DE LABRUGUIERE'),
(89, 'MUTUELLE D\'ENTREPRISE UGINE GUEUGNON & ALZ'),
(90, 'MUTUELLE D\'ENTREPRISES SCHNEIDER ELECTRIC'),
(91, 'MUTUELLE D\'EPARGNE DE RETRAITE ET DE PREVOYANCE CARAC'),
(92, 'MUTUELLE D\'IVRY (LA FRATERNELLE)'),
(93, 'MUTUELLE D\'OUEST-FRANCE'),
(94, 'MUTUELLE DE BAGNEAUX'),
(95, 'MUTUELLE DE FRANCE ALPES DU SUD'),
(96, 'MUTUELLE DE FRANCE DES HOSPITALIERS'),
(97, 'MUTUELLE DE FRANCE DU LACYDON'),
(98, 'MUTUELLE DE FRANCE LOIRE FOREZ'),
(99, 'MUTUELLE DE L\'ENSEIGNEMENT CATHOLIQUE DE L\'ANJOU'),
(100, 'MUTUELLE DE L\'ENSEIGNEMENT CATHOLIQUE DES COTES D\'ARMOR'),
(101, 'MUTUELLE DE L\'ENTREPRISE CITRAM'),
(102, 'MUTUELLE DE L\'ENTREPRISE GUILLERM'),
(103, 'MUTUELLE DE L\'INDUSTRIE DU PETROLE'),
(104, 'MUTUELLE DE L\'IRSID'),
(105, 'MUTUELLE DE L\'OISE DES AGENTS TERRITORIAUX'),
(106, 'MUTUELLE DE LA CORSE'),
(107, 'MUTUELLE DE LA DEPECHE DU MIDI'),
(108, 'MUTUELLE DE LA PAPETERIE D\'ARCHES'),
(109, 'MUTUELLE DE LA REGIE DES TRANSPORTS EN COMMUN DE L\'AGGLOMERATION TROYENNE'),
(110, 'MUTUELLE DE LA VERRERIE D\'ALBI'),
(111, 'MUTUELLE DE PONTOISE'),
(112, 'MUTUELLE DE PREVOYANCE DU PERSONNEL DE LA MACIF'),
(113, 'MUTUELLE DE PREVOYANCE ET DE SANTE'),
(114, 'MUTUELLE DE PREVOYANCE INTERPROFESSIONNELLE'),
(115, 'MUTUELLE DE SAINT JUNIEN ET DES ENVIRONS'),
(116, 'MUTUELLE DES AFFAIRES ETRANGERES ET EUROPEENNES'),
(117, 'MUTUELLE DES ANCIENS DE NATIXIS'),
(118, 'MUTUELLE DES ANCIENS DES CHANTIERS LA ROCHELLE-PALLICE'),
(119, 'MUTUELLE DES AUTEURS COMPOSITEURS ET EDITEURS DE MUSIQUE'),
(120, 'MUTUELLE DES CHAMBRES DE COMMERCE ET D\'INDUSTRIE'),
(121, 'MUTUELLE DES CHEMINOTS DE LA REGION DE NANTES'),
(122, 'MUTUELLE DES CHEMINOTS DE NORMANDIE'),
(123, 'MUTUELLE DES ELUS LOCAUX'),
(124, 'MUTUELLE DES EMPLOYES TERRITORIAUX DE SAINT RAPHAEL'),
(125, 'MUTUELLE DES ENTREPRISES ET DES INDEPENDANTS DU COMMERCE DE L\'INDUSTRIE ET DES SERVICES'),
(126, 'MUTUELLE DES ETUDIANTS DE BRETAGNE ATLANTIQUE MAINE ANJOU VENDEE'),
(127, 'MUTUELLE DES FONCTIONNAIRES'),
(128, 'MUTUELLE DES HOPITAUX DE LA VIENNE'),
(129, 'MUTUELLE DES HOSPITALIERS'),
(130, 'MUTUELLE DES INDUSTRIES AERONAUTIQUES SPATIALES ET CONNEXES'),
(131, 'MUTUELLE DES METIERS ELECTRONIQUE ET INFORMATIQUE'),
(132, 'MUTUELLE DES PATENTES ET LIBERAUX DE NOUVELLE CALEDONIE'),
(133, 'MUTUELLE DES PERSONNELS DU CENTRE HOSPITALIER D\'ALES'),
(134, 'MUTUELLE DES PERSONNELS DU CH MONTPERRIN'),
(135, 'MUTUELLE DES PERSONNELS MARITIMES'),
(136, 'MUTUELLE DES PROFESSIONS JUDICIAIRES'),
(137, 'MUTUELLE DES RETRAITES AGF ET ALLIANZ'),
(138, 'MUTUELLE DES SAPEURS POMPIERS'),
(139, 'MUTUELLE DES SAPEURS POMPIERS DE PARIS'),
(140, 'MUTUELLE DES SCOP ET DES SCIC'),
(141, 'MUTUELLE DES SERVICES PUBLICS'),
(142, 'MUTUELLE DES SPORTIFS'),
(143, 'MUTUELLE DES TERRITORIAUX ET HOSPITALIERS'),
(144, 'MUTUELLE DES TRANSPORTS'),
(145, 'MUTUELLE DU BATIMENT ET DES TRAVAUX PUBLICS DU SUD EST'),
(146, 'MUTUELLE DU BATIMENT TRAVAUX PUBLICS & REGIONS FRANCE & EUROPE'),
(147, 'MUTUELLE DU CHAMPAGNE'),
(148, 'MUTUELLE DU CHU ET HOPITAUX DU PUY DE DOME'),
(149, 'MUTUELLE DU COMMERCE'),
(150, 'MUTUELLE DU GRAND PORT MARITIME DU HAVRE'),
(151, 'MUTUELLE DU GROUPE BNP PARIBAS'),
(152, 'MUTUELLE DU LOGEMENT'),
(153, 'MUTUELLE DU MINISTERE DE LA JUSTICE'),
(154, 'MUTUELLE DU MONDE COMBATTANT'),
(155, 'MUTUELLE DU NICKEL'),
(156, 'MUTUELLE DU PERSONNEL DE LA BANQUE POPULAIRE DU SUD'),
(157, 'MUTUELLE DU PERSONNEL DES COLLECTIVITES TERRITORIALE DE LA REUNION'),
(158, 'MUTUELLE DU PERSONNEL DES PORTS DU DETROIT'),
(159, 'MUTUELLE DU PERSONNEL DES TRANSPORTS URBAINS DE CANNES - BUS AZUR'),
(160, 'MUTUELLE DU PERSONNEL DU CHU'),
(161, 'MUTUELLE DU PERSONNEL DU GROUPE RATP'),
(162, 'MUTUELLE DU PERSONNEL DU GROUPE SOCIETE GENERALE'),
(163, 'MUTUELLE DU PIC ST LOUP - LA SCOLAIRE'),
(164, 'MUTUELLE DU PORT DE BORDEAUX'),
(165, 'MUTUELLE DU TELEGRAMME'),
(166, 'MUTUELLE DU VAL DE SEVRE'),
(167, 'MUTUELLE ENTRAIN'),
(168, 'MUTUELLE ENTRENOUS'),
(169, 'MUTUELLE EPARGNE RETRAITE'),
(170, 'MUTUELLE EPC'),
(171, 'MUTUELLE FACOM'),
(172, 'MUTUELLE FAMILIALE'),
(173, 'MUTUELLE FAMILIALE DE LA REUNION'),
(174, 'MUTUELLE FAMILIALE DE NORMANDIE'),
(175, 'MUTUELLE FAMILIALE DES CHEMINOTS DE FRANCE'),
(176, 'MUTUELLE FAMILIALE DES TRAVAILLEURS DU GROUPE SAFRAN'),
(177, 'MUTUELLE GENERALE DE L\'EDUCATION NATIONALE'),
(178, 'MUTUELLE GENERALE DE PREVOYANCE'),
(179, 'MUTUELLE GENERALE DE PREVOYANCE ET D\'ASSISTANCE'),
(180, 'MUTUELLE GENERALE DE PREVOYANCE SOCIALE'),
(181, 'MUTUELLE GENERALE DES AFFAIRES SOCIALES'),
(182, 'MUTUELLE GENERALE DES CHEMINOTS'),
(183, 'MUTUELLE GENERALE DES ETUDIANTS DE L\'EST'),
(184, 'MUTUELLE GENERALE INTERPROFESSIONNELLE'),
(185, 'MUTUELLE GENERALE SOLIDARITE DE LA REUNION'),
(186, 'MUTUELLE GEODIS'),
(187, 'MUTUELLE IBAMEO'),
(188, 'MUTUELLE INTERENTREPRISE ERAM 526'),
(189, 'MUTUELLE INTERENTREPRISES DES CAVES DE ROQUEFORT'),
(190, 'MUTUELLE INTERGROUPES D\'ENTRAIDE'),
(191, 'MUTUELLE INTERGROUPES POLIET ET CIMENT FRANCAIS'),
(192, 'MUTUELLE INTERPROFESSIONNELLE ANTILLES GUYANE (MIAG)'),
(193, 'MUTUELLE INTERPROFESSIONNELLE DE LA REGION SUD EST DE PARIS'),
(194, 'MUTUELLE INTERPROFESSIONNELLE DE PREVOYANCE'),
(195, 'MUTUELLE KEOLIS RENNES'),
(196, 'MUTUELLE LA CHOLETAISE'),
(197, 'MUTUELLE LA FRANCE MARITIME'),
(198, 'MUTUELLE LA SECURITE ASTURIENNE'),
(199, 'MUTUELLE LA SOLIDARITE D\'AQUITAINE'),
(200, 'MUTUELLE LES MENAGES PREVOYANTS'),
(201, 'MUTUELLE MAE'),
(202, 'MUTUELLE MALAKOFF HUMANIS'),
(203, 'MUTUELLE MARE GAILLARD'),
(204, 'MUTUELLE MARSEILLE METROPOLE MUTAME PROVENCE'),
(205, 'MUTUELLE MEDICALE CHIRURGICALE ATLANTIQUE'),
(206, 'MUTUELLE MEUSREC'),
(207, 'MUTUELLE MFTSV'),
(208, 'MUTUELLE MIEUX-ETRE'),
(209, 'MUTUELLE MMH'),
(210, 'MUTUELLE NATIONALE DES CONSTRUCTEURS ET ACCEDANTS A LA PROPRIETE'),
(211, 'MUTUELLE NATIONALE DES FONCTIONNAIRES DES COLLECTIVITES TERRITORIALES'),
(212, 'MUTUELLE NATIONALE DES HOSPITALIERS ET DES PROFESSIONNELS DE LA SANTE ET DU SOCIAL'),
(213, 'MUTUELLE NATIONALE DES PERSONNELS AIR FRANCE'),
(214, 'MUTUELLE NATIONALE DES SAPEURS POMPIERS DE FRANCE'),
(215, 'MUTUELLE NATIONALE DU PERSONNEL DES ETABLISSEMENTS MICHELIN'),
(216, 'MUTUELLE NATIONALE TERRITORIALE'),
(217, 'MUTUELLE OCIANE MATMUT'),
(218, 'MUTUELLE PREVOYANCE ALSACE'),
(219, 'MUTUELLE PREVOYANCE ET DE L\'HABITAT DE LA REUNION'),
(220, 'MUTUELLE PROVENCE ENTREPRISES'),
(221, 'MUTUELLE RENAULT'),
(222, 'MUTUELLE SAINT AUBANNAISE'),
(223, 'MUTUELLE SAINT SIMON'),
(224, 'MUTUELLE SANTE EIFFAGE ENERGIE'),
(225, 'MUTUELLE SANTE INDEPENDANTS'),
(226, 'MUTUELLE SMATIS FRANCE'),
(227, 'MUTUELLE SMH'),
(228, 'MUTUELLE SOLIDARITE AERONAUTIQUE'),
(229, 'MUTUELLE SOLIMUT CENTRE OCEAN'),
(230, 'MUTUELLE UNEO'),
(231, 'MUTUELLE VALEO'),
(232, 'MUTUELLE VAROISE DES TRAVAILLEURS DE L\'ETAT'),
(233, 'MUTUELLE VERRIERS ET ASSIMILES'),
(234, 'MUTUELLE VIASANTE'),
(235, 'MUTUELLES DE LORRAINE'),
(236, 'MUTUELLES DU PAYS HAUT'),
(237, 'MUTUELLES DU SOLEIL - LIVRE II'),
(238, 'NYMPHEA SANTE'),
(239, 'OCEANE SANTE - SAINTE PHILOMENE'),
(240, 'ORPHELINAT MUTUALISTE DE LA POLICE NATIONALE PREVOYANCE'),
(241, 'PAVILLON PREVOYANCE'),
(242, 'PRECOCIA'),
(243, 'RADIANCE MUTUELLE'),
(244, 'RESSOURCES MUTUELLES ASSISTANCE'),
(245, 'SANTEMUT ROANNE'),
(246, 'SO\'LYON MUTUELLE'),
(247, 'SOCIETE DE PREVOYANCE MUTUALISTE DU PERSONNEL DE LA BANQUE DE FRANCE'),
(248, 'SOCIETE INTERPROFESSIONNELLE MUTUALISTE INDEPENDANTE DE LA REGION PARISIENNE'),
(249, 'SOCIETE MUTUALISTE CHIRURGICALE ET COMPLEMENTAIRE DU PERSONNEL DE LA BANQUE DE FRANCE'),
(250, 'SOCIETE MUTUALISTE D\'ENTREPRISE PERNOD'),
(251, 'SOCIETE MUTUALISTE DU PERSONNEL ACTIF ET RETRAITE DE LA MARQUE'),
(252, 'SOCIETE MUTUALISTE DU PERSONNEL DE LA SNECMA'),
(253, 'SOCIETE MUTUALISTE DU SALEVE'),
(254, 'SOCIETE MUTUALISTE INTER-ENTREPRISES'),
(255, 'SOCIETE MUTUALISTE INTERDEPARTEMENTALE DE BANQUE'),
(256, 'SOCIETE MUTUALISTE INTERPROFESSIONNELLE'),
(257, 'SOLIMUT MUTUELLE DE FRANCE'),
(258, 'SOLIMUT MUTUELLE PERSONNELS ORGANISMES SOCIAUX'),
(259, 'SORUAL'),
(260, 'SUD-OUEST MUTUALITE'),
(261, 'TERRITORIA MUTUELLE'),
(262, 'TUTELAIRE'),
(263, 'UMEN'),
(264, 'UNION DES MUTUELLES DE LA REUNION'),
(265, 'UNION HARMONIE MUTUALITE'),
(266, 'UNION MUTUALISTE DE PREVOYANCE'),
(267, 'UNION MUTUALISTE NATIONALE COMPLEMENTAIRE'),
(268, 'UNION MUTUALISTE RETRAITE'),
(269, 'UNION MUTUELLE AGRICOLE CHIRURGICALE'),
(270, 'UNION NATIONALE DES MUTUELLES D\'ENTREPRISE - GARANTIE'),
(271, 'UNION NATIONALE DES MUTUELLES DES ORGANISMES SOCIAUX ET SIMILAIRES'),
(272, 'UNION NATIONALE MUTUALISTE INTERPROFESSIONNELLE'),
(273, 'UNMI\'MUT'),
(274, '525ÈME MUTUELLE D\'ENTREPRISES');

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `médicament_en_rupture`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `médicament_en_rupture` (
`ID_medicament` int(5) unsigned
,`Nom_medicament` varchar(300)
,`Quantite_nb_boites` int(11)
,`Seuil` int(11)
,`Prix_boite` float
,`ID_fournisseur` int(5) unsigned
);

-- --------------------------------------------------------

--
-- Structure de la table `note`
--

CREATE TABLE `note` (
  `ID_note` int(5) UNSIGNED NOT NULL,
  `Note_sur_10` float NOT NULL,
  `Commentaire` varchar(200) NOT NULL,
  `ID_patient` int(5) UNSIGNED NOT NULL,
  `ID_etablissement` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `note`
--

INSERT INTO `note` (`ID_note`, `Note_sur_10`, `Commentaire`, `ID_patient`, `ID_etablissement`) VALUES
(240, 5.4, 'Correcte', 644, 1),
(241, 4.9, 'Moyen', 535, 3),
(242, 8.7, 'Correcte', 562, 1),
(243, 8.6, 'Médiocre', 540, 1),
(244, 6.5, 'Génial !', 651, 1),
(245, 5.4, 'Génial !', 517, 1),
(246, 4.6, 'Très bien !', 586, 1),
(247, 8.4, 'Médiocre', 528, 3),
(248, 1.5, 'A fuir !', 632, 3),
(249, 0.2, 'Médiocre', 436, 1),
(250, 6.1, 'Génial !', 408, 2),
(251, 0.9, 'Moyen', 474, 2),
(252, 9.5, 'A fuir !', 366, 1),
(253, 9.9, 'Génial !', 377, 1),
(254, 5.8, 'Très bien !', 500, 3),
(255, 8.3, 'Moyen', 650, 3),
(256, 0.9, 'A fuir !', 350, 1),
(257, 3.6, 'Moyen', 570, 1),
(258, 1.6, 'Correcte', 600, 2),
(259, 5.3, 'A fuir !', 395, 2),
(260, 4.1, 'A fuir !', 650, 1),
(261, 6.4, 'Correcte', 332, 2),
(262, 3.3, 'Correcte', 475, 3),
(263, 9.1, 'Génial !', 425, 2),
(264, 7.7, 'Génial !', 414, 1),
(265, 3.9, 'A fuir !', 640, 2),
(266, 2.5, 'Correcte', 581, 1),
(267, 8.4, 'A fuir !', 421, 1),
(268, 8.2, 'A fuir !', 555, 3),
(269, 4.2, 'Correcte', 456, 1),
(270, 8.4, 'A fuir !', 435, 1),
(271, 1.5, 'Très bien !', 343, 1),
(272, 0.5, 'Médiocre', 405, 1),
(273, 1.8, 'Correcte', 509, 3),
(274, 3.6, 'Très bien !', 396, 2),
(275, 0.7, 'Moyen', 384, 2),
(276, 3.6, 'Très bien !', 601, 1),
(277, 2.8, 'Très bien !', 530, 3),
(278, 1.6, 'Très bien !', 405, 1),
(279, 4.6, 'Correcte', 575, 1),
(280, 6.2, 'A fuir !', 416, 3),
(281, 4.3, 'Correcte', 382, 1),
(282, 3.1, 'Moyen', 384, 1),
(283, 8.6, 'Très bien !', 473, 1),
(284, 3.8, 'Médiocre', 523, 1),
(285, 2.5, 'Moyen', 465, 2),
(286, 5.3, 'Correcte', 593, 2),
(287, 7.4, 'Moyen', 496, 2),
(288, 6.2, 'A fuir !', 511, 1),
(289, 7.4, 'Correcte', 609, 2),
(290, 7.3, 'Très bien !', 629, 2),
(291, 3.1, 'Génial !', 388, 2),
(292, 3.9, 'Correcte', 478, 1),
(293, 6.9, 'Très bien !', 491, 3),
(294, 4.8, 'Très bien !', 593, 2),
(295, 5.4, 'A fuir !', 517, 2),
(296, 4.1, 'Moyen', 377, 2),
(297, 8.1, 'Correcte', 413, 2),
(298, 8.6, 'Moyen', 494, 3),
(299, 6.6, 'Médiocre', 632, 1),
(300, 2.8, 'Correcte', 504, 2),
(301, 9.8, 'Moyen', 559, 3),
(302, 5.2, 'Correcte', 454, 2),
(303, 1.9, 'Très bien !', 567, 2),
(304, 0.8, 'A fuir !', 554, 3),
(305, 3.7, 'Correcte', 362, 3),
(306, 2.4, 'Moyen', 561, 1),
(307, 2.6, 'A fuir !', 546, 2),
(308, 9.3, 'Très bien !', 547, 3),
(309, 8.3, 'Moyen', 457, 2),
(310, 7.1, 'A fuir !', 407, 1),
(311, 4.3, 'Génial !', 347, 1),
(312, 4.4, 'Moyen', 361, 1),
(313, 5.6, 'Très bien !', 620, 3),
(314, 8.8, 'Très bien !', 443, 1),
(315, 8.6, 'Correcte', 555, 1),
(316, 9.1, 'Moyen', 563, 1),
(317, 4.2, 'Médiocre', 602, 3),
(318, 4.4, 'Correcte', 429, 1),
(319, 3.1, 'Médiocre', 437, 3),
(320, 8.2, 'Correcte', 587, 1),
(321, 9.1, 'Médiocre', 661, 1),
(322, 5.4, 'Moyen', 613, 2),
(323, 6.6, 'Génial !', 392, 3),
(324, 8.5, 'Moyen', 583, 2),
(325, 2.4, 'Très bien !', 562, 2),
(326, 8.1, 'Médiocre', 487, 2),
(327, 7.3, 'Très bien !', 579, 1),
(328, 5.5, 'A fuir !', 660, 2),
(329, 8.8, 'Moyen', 422, 2),
(330, 5.6, 'Génial !', 527, 2),
(331, 6.3, 'Génial !', 335, 2),
(332, 4.8, 'Moyen', 617, 1),
(333, 6.7, 'Très bien !', 598, 1),
(334, 6.5, 'Médiocre', 353, 2),
(335, 1.7, 'Moyen', 378, 3),
(336, 7.7, 'Génial !', 562, 3),
(337, 2.9, 'Médiocre', 368, 3),
(338, 5.5, 'Génial !', 651, 2),
(339, 1.7, 'Génial !', 601, 2),
(340, 8.9, 'Moyen', 368, 1),
(341, 7.9, 'Moyen', 479, 1),
(342, 8.1, 'Génial !', 386, 3),
(343, 4.4, 'Correcte', 592, 1),
(344, 6.1, 'A fuir !', 634, 1),
(345, 0.6, 'Moyen', 494, 3),
(346, 3.1, 'Moyen', 462, 1),
(347, 5.1, 'Moyen', 559, 1),
(348, 7.1, 'Moyen', 611, 2),
(349, 2.1, 'Très bien !', 428, 3),
(350, 4.1, 'Moyen', 621, 1),
(351, 1.6, 'Médiocre', 341, 3),
(352, 6.1, 'Moyen', 400, 2),
(353, 2.7, 'Génial !', 572, 1),
(354, 0.4, 'Moyen', 488, 2),
(355, 0.4, 'Génial !', 438, 1),
(356, 7.2, 'Génial !', 389, 3),
(357, 8.1, 'A fuir !', 461, 1),
(358, 1.4, 'Médiocre', 555, 2),
(359, 5.2, 'Génial !', 409, 1),
(360, 1.6, 'Médiocre', 344, 2),
(361, 5.6, 'Correcte', 382, 3),
(362, 7.3, 'Très bien !', 632, 1),
(363, 5.4, 'Médiocre', 421, 1),
(364, 4.8, 'Génial !', 563, 1),
(365, 9.3, 'Moyen', 423, 1),
(366, 7.1, 'Moyen', 588, 2),
(367, 6.9, 'Moyen', 516, 2),
(368, 2.4, 'A fuir !', 566, 1),
(369, 9.1, 'Génial !', 342, 2),
(370, 9.9, 'Correcte', 429, 3),
(371, 5.7, 'Moyen', 435, 3),
(372, 5.2, 'Médiocre', 577, 2),
(373, 8.7, 'Correcte', 357, 3),
(374, 3.6, 'Très bien !', 620, 2),
(375, 5.5, 'Très bien !', 421, 3),
(376, 9.3, 'Moyen', 434, 3),
(377, 6.8, 'Génial !', 474, 1),
(378, 6.4, 'Correcte', 491, 2),
(379, 8.8, 'Correcte', 442, 1),
(380, 9.6, 'Médiocre', 608, 2),
(381, 4.5, 'A fuir !', 406, 1),
(382, 4.3, 'A fuir !', 471, 3),
(383, 1.5, 'A fuir !', 623, 1),
(384, 1.2, 'Correcte', 565, 3),
(385, 4.6, 'Correcte', 517, 1),
(386, 6.9, 'Très bien !', 465, 2),
(387, 9.1, 'Correcte', 475, 3),
(388, 6.6, 'Très bien !', 620, 1),
(389, 8.2, 'A fuir !', 402, 1),
(390, 6.4, 'Moyen', 662, 1),
(391, 7.7, 'A fuir !', 419, 2),
(392, 7.2, 'Génial !', 601, 3),
(393, 9.4, 'A fuir !', 603, 1),
(394, 7.3, 'Correcte', 355, 2),
(395, 6.1, 'A fuir !', 580, 2),
(396, 2.7, 'Correcte', 570, 2),
(397, 0.1, 'Moyen', 571, 2),
(398, 3.2, 'A fuir !', 570, 2),
(399, 7.4, 'A fuir !', 593, 3),
(400, 8.4, 'Correcte', 370, 3),
(401, 1.3, 'Correcte', 444, 3),
(402, 1.1, 'Médiocre', 408, 1),
(403, 9.5, 'Génial !', 384, 2),
(404, 0.5, 'Correcte', 507, 2),
(405, 8.6, 'Génial !', 637, 3),
(406, 2.8, 'Correcte', 384, 3),
(407, 3.6, 'Génial !', 440, 1),
(408, 2.1, 'A fuir !', 560, 1),
(409, 0.5, 'Correcte', 557, 2),
(410, 7.3, 'Moyen', 455, 3),
(411, 4.3, 'Correcte', 653, 2),
(412, 4.1, 'Moyen', 590, 2),
(413, 8.4, 'Moyen', 465, 1),
(414, 7.6, 'Correcte', 412, 2),
(415, 1.4, 'Médiocre', 513, 1),
(416, 7.9, 'A fuir !', 335, 2),
(417, 6.7, 'Génial !', 423, 1),
(418, 4.6, 'Très bien !', 487, 1),
(419, 0.3, 'Correcte', 504, 3),
(420, 1.5, 'Moyen', 364, 1),
(421, 5.4, 'Correcte', 564, 1),
(422, 6.3, 'Médiocre', 637, 2),
(423, 0.7, 'Moyen', 463, 1),
(424, 9.5, 'Génial !', 529, 2),
(425, 9.2, 'Génial !', 347, 2),
(426, 0.9, 'A fuir !', 427, 3),
(427, 8.3, 'A fuir !', 653, 3),
(428, 6.3, 'A fuir !', 375, 1),
(429, 2.9, 'Moyen', 349, 2),
(430, 4.4, 'Médiocre', 453, 3),
(431, 9.9, 'Correcte', 460, 3),
(432, 0.1, 'Correcte', 462, 3),
(433, 8.1, 'Très bien !', 351, 1),
(434, 6.9, 'Très bien !', 342, 2),
(435, 8.7, 'Très bien !', 593, 1),
(436, 6.7, 'Génial !', 364, 2),
(437, 8.9, 'Moyen', 445, 2),
(438, 0.3, 'Médiocre', 405, 1),
(439, 6.2, 'A fuir !', 342, 1),
(440, 6.5, 'Moyen', 503, 3),
(441, 4.4, 'Moyen', 660, 3),
(442, 6.9, 'Médiocre', 594, 1),
(443, 5.7, 'Correcte', 656, 1),
(444, 8.4, 'Moyen', 434, 1),
(445, 9.6, 'Moyen', 543, 3),
(446, 9.4, 'Médiocre', 349, 2),
(447, 3.2, 'Moyen', 653, 1),
(448, 6.1, 'Très bien !', 587, 3),
(449, 3.8, 'Génial !', 428, 1),
(450, 0.5, 'A fuir !', 416, 3),
(451, 8.9, 'Médiocre', 447, 3),
(452, 2.5, 'Génial !', 421, 3),
(453, 8.4, 'Correcte', 606, 3),
(454, 6.8, 'A fuir !', 492, 1),
(455, 8.1, 'A fuir !', 516, 1),
(456, 3.5, 'Génial !', 500, 1),
(457, 3.5, 'Médiocre', 560, 1),
(458, 9.6, 'Correcte', 553, 3),
(459, 4.9, 'A fuir !', 475, 2),
(460, 9.8, 'Très bien !', 342, 1),
(461, 6.3, 'Médiocre', 584, 2),
(462, 4.7, 'Moyen', 527, 3),
(463, 1.7, 'Très bien !', 606, 3),
(464, 6.5, 'Médiocre', 341, 3),
(465, 2.2, 'Moyen', 556, 2),
(466, 1.9, 'Moyen', 569, 1),
(467, 5.9, 'Très bien !', 394, 2),
(468, 9.1, 'Médiocre', 568, 1),
(469, 7.1, 'Correcte', 529, 1),
(470, 2.6, 'A fuir !', 427, 1),
(471, 6.3, 'Très bien !', 419, 1),
(472, 8.2, 'Génial !', 391, 2),
(473, 6.6, 'Correcte', 502, 1),
(474, 3.2, 'Correcte', 598, 1),
(475, 1.6, 'Correcte', 636, 1),
(476, 6.2, 'Moyen', 616, 3),
(477, 5.5, 'A fuir !', 494, 3),
(478, 0.6, 'Correcte', 629, 1),
(479, 4, 'Cetait pas top', 333, 2);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `notes_cliniques`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `notes_cliniques` (
`ID_etablissement` int(5) unsigned
,`Adresse_etablissement` varchar(100)
,`Note moyenne` double(19,2)
,`Ecart type` double(19,2)
,`Nombre de notes` bigint(21)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `occupation_des_services_par_mois`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `occupation_des_services_par_mois` (
`Etablissement n°` int(5) unsigned
,`Adresse` varchar(100)
,`Code_postal` int(5)
,`Service` varchar(50)
,`Mois` varchar(7)
,`% d'Occupation du service` decimal(25,0)
);

-- --------------------------------------------------------

--
-- Structure de la table `occuper`
--

CREATE TABLE `occuper` (
  `ID_occupation` int(5) UNSIGNED NOT NULL,
  `ID_chambre` int(5) UNSIGNED NOT NULL,
  `ID_patient` int(5) UNSIGNED NOT NULL,
  `Date_occuper` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `occuper`
--

INSERT INTO `occuper` (`ID_occupation`, `ID_chambre`, `ID_patient`, `Date_occuper`) VALUES
(1, 5, 663, '2021-01-07'),
(2, 5, 663, '2021-01-08'),
(3, 5, 663, '2021-01-09'),
(4, 5, 663, '2021-01-10'),
(5, 5, 663, '2021-01-11'),
(6, 8, 332, '2021-08-09'),
(7, 8, 332, '2021-08-10'),
(8, 8, 332, '2021-08-11'),
(9, 8, 332, '2021-08-12'),
(10, 8, 332, '2021-08-13'),
(11, 8, 332, '2021-08-14'),
(12, 8, 332, '2021-08-15'),
(13, 8, 332, '2021-08-16'),
(14, 8, 332, '2021-08-17'),
(15, 5, 660, '2021-01-12'),
(16, 5, 660, '2021-01-13'),
(17, 5, 660, '2021-01-14'),
(18, 5, 660, '2021-01-15'),
(19, 5, 660, '2021-01-16'),
(20, 5, 660, '2021-01-17'),
(21, 5, 660, '2021-01-18'),
(22, 5, 660, '2021-01-19'),
(23, 5, 660, '2021-01-20'),
(24, 5, 660, '2021-01-21'),
(25, 5, 660, '2021-01-22'),
(26, 5, 660, '2021-01-23'),
(27, 5, 660, '2021-01-24'),
(28, 5, 660, '2021-01-25'),
(29, 5, 660, '2021-01-26'),
(30, 5, 660, '2021-01-27'),
(31, 5, 660, '2021-01-28'),
(32, 5, 660, '2021-01-29'),
(33, 5, 651, '2021-06-07'),
(34, 5, 651, '2021-06-08'),
(35, 5, 651, '2021-06-09'),
(36, 5, 651, '2021-06-10'),
(37, 5, 651, '2021-06-11'),
(38, 5, 651, '2021-06-12'),
(39, 5, 651, '2021-06-13'),
(40, 5, 651, '2021-06-14'),
(41, 5, 651, '2021-06-15'),
(42, 5, 651, '2021-06-16'),
(43, 5, 651, '2021-06-17'),
(44, 5, 651, '2021-06-18'),
(45, 5, 651, '2021-06-19'),
(46, 5, 651, '2021-06-20'),
(47, 5, 651, '2021-06-21'),
(48, 5, 651, '2021-06-22'),
(49, 5, 651, '2021-06-23'),
(50, 5, 651, '2021-06-24'),
(51, 5, 651, '2021-06-25'),
(52, 5, 660, '2022-01-08'),
(53, 5, 660, '2022-01-09'),
(54, 5, 660, '2022-01-10');

-- --------------------------------------------------------

--
-- Structure de la table `passer`
--

CREATE TABLE `passer` (
  `ID_consultation` int(5) UNSIGNED NOT NULL,
  `ID_examen` int(5) UNSIGNED NOT NULL,
  `Date_examen` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `passer`
--

INSERT INTO `passer` (`ID_consultation`, `ID_examen`, `Date_examen`) VALUES
(1, 1, '2021-01-01'),
(3, 15, '2021-01-11'),
(5, 14, '2021-01-20'),
(12, 14, '2021-02-17'),
(183, 2, '2021-03-17');

-- --------------------------------------------------------

--
-- Structure de la table `patient`
--

CREATE TABLE `patient` (
  `ID_patient` int(5) UNSIGNED NOT NULL,
  `Nom_patient` varchar(50) NOT NULL,
  `Prenom_patient` varchar(50) NOT NULL,
  `Adresse_patient` varchar(200) NOT NULL,
  `Code_postale_patient` int(5) NOT NULL,
  `Ville_patient` varchar(100) NOT NULL,
  `Mail_patient` varchar(50) NOT NULL,
  `Telephone_patient` varchar(10) NOT NULL,
  `Age_patient` int(11) NOT NULL,
  `Poids_patient` float NOT NULL,
  `Taille_patient` float NOT NULL,
  `Sexe_patient` enum('F','M') NOT NULL,
  `Allergie` varchar(100) DEFAULT NULL,
  `Securite_sociale_CMU` tinyint(1) NOT NULL,
  `ID_mutuelle` int(5) UNSIGNED NOT NULL,
  `ID_etablissement` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `patient`
--

INSERT INTO `patient` (`ID_patient`, `Nom_patient`, `Prenom_patient`, `Adresse_patient`, `Code_postale_patient`, `Ville_patient`, `Mail_patient`, `Telephone_patient`, `Age_patient`, `Poids_patient`, `Taille_patient`, `Sexe_patient`, `Allergie`, `Securite_sociale_CMU`, `ID_mutuelle`, `ID_etablissement`) VALUES
(332, 'Zloch', 'Baptiste', '23 ANDRE CHENIER (rue)', 92160, 'Antony', 'BQQVZR@wanadoo.fr', '0679919646', 10, 118, 196, 'M', 'Klamoxyl', 1, 197, 2),
(333, 'Otis', 'Mirjam', '27 COURTIL (Rue du)', 91883, 'Saint-Quentin en Yvelines', 'CUEGCJ@gmail.com', '0664812663', 70, 63, 90, 'F', 'Aspirine', 1, 99, 3),
(334, 'Archimedes', 'Griffith', '25 ANTILLES (Rue des)', 93838, 'Rungis', 'IIKEKH@wanadoo.fr', '0691093632', 51, 69, 149, 'M', '0', 1, 190, 3),
(335, 'Basma', 'Janus', '19 HOGUETTE (Avenue de la)', 93649, 'Saint-denis', 'QKZEBD@free.fr', '0666208896', 56, 62, 128, 'F', 'Pénicilline', 0, 28, 3),
(336, 'Merlyn', 'Bijoy', '44 DE CHATILLON (Place Jean)', 75333, 'l\'Hay-les-roses', 'VNFXVW@hotmail.fr', '0679901649', 104, 109, 112, 'M', '0', 0, 116, 3),
(337, 'Roald', 'Ingemar', '3 VARDE (Avenue de la)', 78732, 'Boulogne-billancourt', 'LIFPJX@free.fr', '0652279529', 15, 41, 219, 'F', 'Klamoxyl', 0, 15, 1),
(338, 'Frang', 'Kevork', '29 FONTAINE (Rue de la)', 78618, 'Neuilly', 'FWOKRJ@hotmail.fr', '0673174432', 91, 30, 160, 'M', 'Klamoxyl', 0, 150, 2),
(339, 'Babette', 'Stanislas', '34 CLAUDEL (Rue Marguerite)', 93715, 'Rungis', 'GVIKUM@hotmail.fr', '0692556106', 56, 136, 156, 'M', 'Neuroleptique', 1, 65, 2),
(340, 'Mscislaw', 'Corin', '32 LAURENCIN (Rue Marie)', 75837, 'Puteaux', 'VUKSWX@free.fr', '0636932714', 52, 36, 122, 'F', 'Pénicilline', 1, 264, 2),
(341, 'Hjalmar', 'Nsonowa', '28 GUADELOUPE (Rue de la)', 75850, 'Gentilly', 'GTFQKH@hotmail.fr', '0664835379', 100, 75, 213, 'M', '0', 1, 123, 3),
(342, 'Kathy', 'Dragica', '29 AIGUILLE (Impasse de l\')', 94568, 'Villeneuve Saint-Georges', 'CSXYNM@gmail.com', '0636194615', 39, 91, 228, 'F', '0', 1, 157, 3),
(343, 'Sini', 'Krystine', '28 TUNIS (Rue de)', 75228, 'Boulogne-billancourt', 'SYEWBK@hotmail.fr', '0622558516', 7, 150, 120, 'M', 'Homéopathie', 1, 227, 1),
(344, 'Seraphine', 'Muirgheal', '46 BELLEVENT (Rue de)', 94999, 'Saint-Quentin en Yvelines', 'FBDGKE@hotmail.fr', '0636888241', 73, 72, 139, 'M', 'Aspirine', 0, 153, 3),
(345, 'Judita', 'Sly', '38 MANOIR (Place du)', 78130, 'Paris', 'BJPXVQ@hotmail.fr', '0644971134', 63, 27, 108, 'M', 'Pénicilline', 1, 179, 2),
(346, 'Severo', 'Nancy', '34 FLAUDAIS (Allée de la)', 94646, 'Massy', 'EGGDGJ@wanadoo.fr', '0645326326', 98, 74, 203, 'M', 'Insuline', 1, 34, 2),
(347, 'Beatrice', 'Polyxena', '40 SURCOUF (Rue Robert)', 91776, 'Vanves', 'ZDRVQC@free.fr', '0662368781', 63, 66, 103, 'M', '0', 1, 89, 3),
(348, 'Anton', 'Eutropius', '44 GENERAL FERRIE (Avenue du)', 95262, 'Vélizy', 'DCRCAX@free.fr', '0676958861', 65, 105, 157, 'F', 'Klamoxyl', 0, 168, 2),
(349, 'Valerio', 'Lisa', '47 FRESNE (Rue du)', 94231, 'Orsay', 'VMDPXA@gmail.com', '0631277799', 42, 90, 226, 'F', '0', 0, 215, 3),
(350, 'Grusha', 'Augusta', '35 NOGUES (Rue Maurice)', 93743, 'Boulogne-billancourt', 'WHSAME@orange.fr', '0646293786', 8, 53, 214, 'F', 'Neuroleptique', 1, 142, 1),
(351, 'Jerry', 'Jaxon', '48 AULNES (Rue des)', 91855, 'Vélizy', 'WJKSZD@free.fr', '0684525240', 34, 130, 166, 'F', 'Aspirine', 0, 239, 3),
(352, 'Phobos', 'Misha', '46 PETITE HUPEE (Impasse de la)', 92112, 'Massy', 'BWYWYD@wanadoo.fr', '0618758330', 26, 109, 182, 'F', 'Neuroleptique', 1, 180, 2),
(353, 'Kenshin', 'Jitendra', '42 SAVEANT (Rue Jean)', 93366, 'Neuilly', 'ZQRPCS@hotmail.fr', '0682556183', 45, 64, 131, 'M', 'Aspirine', 1, 12, 1),
(354, 'Jeremiah', 'Alesha', '28 CLAUDEL (Rue Marguerite)', 95720, 'Antony', 'PUDVJM@orange.fr', '0646196959', 39, 39, 207, 'M', 'Iode', 0, 270, 1),
(355, 'Bodil', 'Elain', '11 GRANDE MOINERIE (Rue de la)', 91469, 'Cachan', 'LKANHS@wanadoo.fr', '0669461859', 6, 30, 118, 'F', 'Iode', 1, 234, 1),
(356, 'Andreja', 'Witold', '25 SERVANTINE (Allée de la)', 91606, 'Massy', 'XCUIIY@hotmail.fr', '0612444802', 34, 25, 102, 'F', '0', 0, 165, 3),
(357, 'Slavomir', 'Sarita', '47 ENCLOS DU MOULIN (Rue de l\')', 93304, 'Versailles', 'FRGMSO@wanadoo.fr', '0660268391', 61, 35, 102, 'M', 'Homéopathie', 1, 192, 3),
(358, 'Gobind', 'Florine', '42 GOELETRIE (Impasse de la)', 92943, 'Rungis', 'KQIKPI@free.fr', '0671486749', 33, 118, 193, 'M', 'Aspirine', 1, 129, 2),
(359, 'Hosanna', 'Gaenor', '30 CORMORANS (Impasse des)', 91461, 'Versailles', 'KCDCOP@gmail.com', '0630460905', 19, 69, 165, 'F', 'Aspirine', 1, 85, 1),
(360, 'Mick', 'Mnason', '20 PLESSIS (Rue du)', 92413, 'Bourg-la-reine', 'IQYIJJ@orange.fr', '0624187780', 68, 150, 168, 'F', '0', 0, 234, 2),
(361, 'Hadya', 'Tillo', '6 CHENARD DE LA GIRAUDAIS (Rue)', 78474, 'Vélizy', 'KYGQAD@orange.fr', '0661403112', 64, 36, 199, 'M', 'Iode', 1, 235, 1),
(362, 'Zinovia', 'Caoilainn', '40 DANYCAN (Rue)', 92557, 'Thiais', 'VYIXAW@free.fr', '0682755740', 45, 103, 117, 'F', '0', 0, 186, 3),
(363, 'Britta', 'Ju', '4 PORCON DE LA BARBINAIS (Rue)', 93429, 'Saint-denis', 'DFJKOS@gmail.com', '0625785822', 102, 34, 227, 'F', 'Neuroleptique', 0, 97, 1),
(364, 'Cernunnos', 'Delphina', '48 LAENNEC (Rue)', 95981, 'Malakoff', 'PGEVDR@free.fr', '0672030966', 26, 5, 205, 'M', '0', 0, 273, 2),
(365, 'Ofra', 'Kaleb', '14 VILLE JOUAN (Rue de la)', 78849, 'Gometz-le-chatel', 'BEQSJW@hotmail.fr', '0672371070', 45, 91, 139, 'F', '0', 1, 266, 3),
(366, 'Beathan', 'Sylvana', '35 NATION (Rue de la)', 92659, 'Thiais', 'SMRQYM@gmail.com', '0615155990', 23, 119, 97, 'M', '0', 1, 94, 3),
(367, 'Aleksi', 'Breandán', '32 CROIX CHEMIN (Rue de la)', 91797, 'Orsay', 'XEZLMJ@free.fr', '0647732380', 76, 69, 140, 'F', 'Aspirine', 1, 259, 2),
(368, 'Haley', 'Béibhinn', '2 MALOUINIERE (Impasse de la)', 75492, 'Gentilly', 'QPAMFI@orange.fr', '0617057977', 32, 102, 209, 'M', 'Pénicilline', 0, 161, 3),
(369, 'Shahrokh', 'Usagi', '36 CASTOR (Rue du)', 95630, 'Vélizy', 'WILTJC@orange.fr', '0694626531', 98, 31, 197, 'F', '0', 1, 161, 3),
(370, 'Camron', 'Roslyn', '20 CHENES (Rue des)', 93523, 'Antony', 'CJYIQS@gmail.com', '0655795234', 96, 46, 138, 'F', '0', 1, 18, 1),
(371, 'Hanan', 'Lane', '6 BOISOUZE (Place)', 92915, 'Massy', 'GMDXXM@hotmail.fr', '0637592161', 50, 137, 113, 'F', '0', 1, 252, 2),
(372, 'Jerusha', 'Eutropius', '38 JARNOUEN DE VILLARTAY (Rue Guy)', 75386, 'Saint-denis', 'LSTVZP@orange.fr', '0620986463', 93, 127, 203, 'M', '0', 0, 96, 3),
(373, 'Eldred', 'Alisa', '9 SALINETTE (Rue de la)', 94156, 'Sceaux', 'KADJOY@wanadoo.fr', '0653423861', 103, 90, 118, 'F', '0', 0, 163, 3),
(374, 'Vilhelmi', 'Leanna', '34 DURAND (Rue Mathieu)', 92636, 'Gentilly', 'XXHBPU@hotmail.fr', '0614939948', 65, 126, 212, 'M', '0', 0, 165, 2),
(375, 'Heida', 'Joses', '7 LORETTE (Avenue de)', 91803, 'Villeneuve Saint-Georges', 'FBUJGS@wanadoo.fr', '0632449897', 90, 51, 227, 'M', 'Insuline', 0, 61, 2),
(376, 'Hadassah', 'Jaan', '39 JOSSEAUME (Place jacques Etienne)', 95481, 'Bourg-la-reine', 'QNGIWX@hotmail.fr', '0678127145', 23, 57, 152, 'F', '0', 0, 101, 2),
(377, 'Shai', 'Sharona', '42 VAL ANTIQUE (Impasse du)', 93453, 'Montrouge', 'IEILIL@hotmail.fr', '0662210245', 5, 121, 147, 'F', 'Iode', 0, 194, 1),
(378, 'Fionnghall', 'Gioconda', '1 PETIT CHAMP (Square du)', 91521, 'Sceaux', 'VCHYAB@gmail.com', '0656003699', 98, 139, 88, 'F', 'Homéopathie', 0, 37, 3),
(379, 'Cosimo', 'Cearra', '25 RENAN (Rue Ernest)', 93216, 'Saint-denis', 'SIYPBN@wanadoo.fr', '0693477902', 28, 79, 177, 'F', '0', 1, 159, 2),
(380, 'Swithun', 'Joos', '10 DEJAN (Rue René)', 91567, 'Villeneuve Saint-Georges', 'BIGAFT@free.fr', '0621580321', 98, 34, 115, 'M', '0', 0, 233, 1),
(381, 'Gerontius', 'Gwilherm', '47 RANCE (Passage de la)', 92886, 'Saint-cyr', 'UKEIXB@wanadoo.fr', '0630742900', 68, 112, 179, 'M', 'Neuroleptique', 1, 84, 3),
(382, 'Katelyn', 'Loreen', '1 HESRY (Rue Jacques)', 91796, 'Puteaux', 'YOZNUR@hotmail.fr', '0668687766', 83, 45, 129, 'F', '0', 1, 257, 1),
(383, 'Grigor', 'Gratia', '38 CHARTRES (Rue de)', 75781, 'Neuilly', 'BFATMH@gmail.com', '0682756753', 79, 117, 154, 'F', '0', 1, 235, 2),
(384, 'Dene', 'Austen', '18 VICTOIRE (Rue de la)', 94723, 'Vélizy', 'DGPTWH@gmail.com', '0655795569', 19, 41, 157, 'F', '0', 1, 99, 3),
(385, 'Camryn', 'Rachelle', '14 SAINT VINCENT (Quai)', 93374, 'Vanves', 'NPIEUU@gmail.com', '0640880312', 55, 30, 191, 'F', '0', 1, 265, 3),
(386, 'Andra', 'Arundhati', '33 BON VENT (Impasse du)', 75617, 'Arcueil', 'UNAJUX@free.fr', '0613765542', 12, 147, 142, 'F', '0', 1, 52, 2),
(387, 'Lachlan', 'Gianpaolo', '12 FOURS A CHAUX (Rue des)', 92147, 'Robinson', 'UKNQLK@free.fr', '0686106243', 98, 12, 157, 'M', 'Neuroleptique', 1, 104, 1),
(388, 'Antonio', 'Szilvia', '5 VAN GOGH (Allée Vincent)', 78124, 'Saint-cyr', 'GAQPTC@orange.fr', '0699631025', 105, 97, 153, 'F', 'Klamoxyl', 1, 262, 2),
(389, 'Luce', 'Paki', '23 GROS CHENE (Impasse du)', 92697, 'Saint-Quentin en Yvelines', 'EZTJSX@orange.fr', '0646935996', 79, 27, 200, 'M', 'Insuline', 1, 52, 1),
(390, 'Gunter', 'Pascaline', '26 CROIX RAUX (Rue de la)', 75192, 'Neuilly', 'MVCKJU@free.fr', '0683564304', 38, 53, 209, 'M', '0', 1, 92, 1),
(391, 'Ulrika', 'Hallvard', '12 DE LA MORVONNAIS (Rue Hippolyte)', 94570, 'Thiais', 'YCROVP@hotmail.fr', '0610430185', 69, 24, 107, 'F', 'Insuline', 1, 100, 3),
(392, 'Izzy', 'Diarmaid', '10 JONQUILLES (Rue des)', 94978, 'Rungis', 'QEHZJH@gmail.com', '0665246749', 12, 21, 153, 'F', '0', 0, 62, 1),
(393, 'Isocrates', 'Russell', '21 FLOURIE (Place de la)', 75422, 'Versailles', 'UYBRUV@free.fr', '0697846629', 57, 45, 203, 'F', 'Neuroleptique', 1, 43, 2),
(394, 'Jenci', 'Lennie', '33 AMOUREUX (Chemin des)', 78826, 'Vanves', 'XMJSCC@free.fr', '0670359573', 26, 86, 188, 'M', 'Aspirine', 1, 174, 1),
(395, 'Orna', 'Modesto', '18 MAURIERS (Rue des)', 91693, 'Robinson', 'DNCXYU@hotmail.fr', '0678023005', 2, 128, 210, 'M', '0', 1, 172, 3),
(396, 'Qiu', 'Abednego', '39 CORBINIERE (Passage de la)', 93351, 'Versailles', 'VPJUSE@hotmail.fr', '0678281278', 41, 59, 99, 'M', '0', 0, 74, 1),
(397, 'Bratumil', 'Czeslaw', '38 DALI (Rue Salvador)', 95851, 'Arcueil', 'JMHPUB@hotmail.fr', '0653835124', 25, 73, 149, 'F', 'Pénicilline', 1, 144, 1),
(398, 'Kriemhilde', 'Cowal', '31 BASSE VILLE AU ROUX (Rue de la)', 95989, 'Montrouge', 'WVASII@free.fr', '0680506964', 91, 85, 116, 'M', '0', 0, 2, 1),
(399, 'Leonore', 'Helga', '32 CHAMP PEGASE (Ruelle du)', 92510, 'Versailles', 'VTELWO@gmail.com', '0662127460', 20, 116, 144, 'F', 'Aspirine', 0, 212, 3),
(400, 'Uberto', 'Orson', '3 LE BRAZ (Rue Anatole)', 75106, 'Garges-lès-gonesses', 'JFDIBB@orange.fr', '0675073696', 57, 18, 194, 'M', '0', 1, 137, 2),
(401, 'Jock', 'Vasilica', '43 TAVET (Rue Constant)', 94382, 'Gometz-le-chatel', 'FBFMZZ@orange.fr', '0685033480', 41, 8, 185, 'F', 'Klamoxyl', 1, 84, 3),
(402, 'Godofredo', 'Jemma', '10 DRAKKAR (Rue du)', 91669, 'Thiais', 'JCQFXJ@orange.fr', '0679518279', 17, 12, 120, 'M', 'Neuroleptique', 0, 232, 2),
(403, 'Gigi', 'Edmé', '6 PONT QUI TREMBLE (Rue du)', 75263, 'Montrouge', 'QSZESO@gmail.com', '0684556773', 43, 102, 200, 'F', 'Aspirine', 0, 153, 3),
(404, 'Firmino', 'Gwenda', '12 JACINTHES (Rue des)', 95912, 'Villeneuve Saint-Georges', 'EUAXDF@wanadoo.fr', '0660778900', 32, 35, 207, 'F', 'Pénicilline', 1, 173, 2),
(405, 'Mimi', 'Elva', '5 COMPTOIRS (Avenue des)', 95933, 'Garges-lès-gonesses', 'YPPTNP@wanadoo.fr', '0629611564', 24, 121, 201, 'F', '0', 1, 176, 2),
(406, 'Lawahiz', 'Niloofar', '50 PERRINE (Rue de la)', 91357, 'Neuilly', 'QQHHVH@orange.fr', '0675845246', 18, 35, 228, 'M', '0', 0, 165, 2),
(407, 'Teunis', 'Kynaston', '16 CURIE (Square)', 95191, 'Asnières', 'LFHQDH@orange.fr', '0655733212', 98, 15, 111, 'M', '0', 1, 48, 3),
(408, 'Shelley', 'Wawrzyniec', '46 BOULNAYE (Rue de la)', 78286, 'Versailles', 'DMPXCW@wanadoo.fr', '0680381425', 58, 19, 112, 'M', 'Insuline', 0, 118, 3),
(409, 'Chandler', 'Gaila', '1 BALUE (Rue de la)', 94535, 'Vanves', 'DXQFEY@gmail.com', '0627237049', 82, 135, 220, 'F', '0', 0, 48, 3),
(410, 'Zelpha', 'Jayda', '2 CHARTRES (Rue de)', 91527, 'Paris', 'VTWUXN@free.fr', '0655357763', 110, 27, 221, 'F', '0', 0, 245, 3),
(411, 'Ira', 'Svyatopolk', '16 PERRIER (Boulevard)', 94361, 'Massy', 'OYPZVD@free.fr', '0651578137', 110, 148, 199, 'F', '0', 0, 265, 3),
(412, 'Young', 'Orval', '48 METZ (Rue de)', 91869, 'Saint-denis', 'LGXBJN@gmail.com', '0648930472', 43, 107, 209, 'M', 'Neuroleptique', 1, 185, 2),
(413, 'Suraj', 'Gilbert', '25 MIRIEL (Rue)', 95623, 'Cachan', 'ANCTVT@gmail.com', '0672921784', 21, 78, 108, 'F', '0', 0, 50, 3),
(414, 'Niklas', 'Ulrich', '14 MAUPERTUIS (Rue)', 95123, 'Antony', 'PUTKWN@wanadoo.fr', '0696344244', 11, 51, 204, 'F', 'Klamoxyl', 0, 260, 1),
(415, 'Aghavni', 'Azeneth', '33 CORMORANS (Impasse des)', 75606, 'Saint-cyr', 'NLIZQT@orange.fr', '0664268070', 93, 115, 96, 'F', 'Iode', 1, 101, 2),
(416, 'Brunella', 'Una', '40 MONTADOR (Rue Jean-François)', 91409, 'Neuilly', 'YKMWBT@hotmail.fr', '0621289135', 80, 55, 218, 'M', '0', 0, 74, 2),
(417, 'Roeland', 'Xoán', '42 ORIEUX (Rue des)', 94940, 'Gometz-le-chatel', 'VCZOAA@wanadoo.fr', '0679662734', 71, 124, 185, 'F', 'Aspirine', 1, 119, 2),
(418, 'Flora', 'Somhairle', '42 BOTREL (Bd Théodore)', 78747, 'Saint-Quentin en Yvelines', 'OJCFTN@gmail.com', '0647464842', 37, 72, 129, 'M', '0', 1, 62, 2),
(419, 'Petrica', 'Kjetil', '37 PORT (Rue du)', 78477, 'Boulogne-billancourt', 'EQURKD@orange.fr', '0611469442', 62, 12, 217, 'F', 'Insuline', 1, 176, 3),
(420, 'Lavrenti', 'Salli', '19 BROUSSAIS (Rue)', 78227, 'l\'Hay-les-roses', 'DUTXBZ@wanadoo.fr', '0676820678', 11, 45, 193, 'F', 'Homéopathie', 1, 184, 3),
(421, 'Nyssa', 'Katelyn', '48 LUCET (Rue de)', 92817, 'Bourg-la-reine', 'ZVINOS@gmail.com', '0613277856', 83, 82, 100, 'M', '0', 0, 266, 2),
(422, 'Ran', 'Larrie', '43 DINAN (Quai de)', 92764, 'Paris', 'DZYDLO@free.fr', '0659282209', 76, 92, 160, 'F', 'Insuline', 0, 126, 1),
(423, 'Malka', 'Merrick', '22 BELLEVUE (Rue de)', 95590, 'l\'Hay-les-roses', 'MEAFFW@hotmail.fr', '0627615745', 1, 95, 116, 'F', '0', 0, 39, 2),
(424, 'Marielle', 'Aniela', '21 HAVRE (Chemin du)', 94557, 'Paris', 'TJBMNL@hotmail.fr', '0634326435', 100, 42, 149, 'M', 'Insuline', 0, 259, 3),
(425, 'Dona', 'Aloysius', '8 BRIAND (Place Aristide)', 75482, 'Gometz-le-chatel', 'RIVYIP@wanadoo.fr', '0669069106', 99, 135, 169, 'M', '0', 1, 222, 3),
(426, 'Tristin', 'Coralie', '1 MARE (Rue de la)', 75532, 'l\'Hay-les-roses', 'TDOZCZ@orange.fr', '0667883272', 36, 53, 149, 'F', 'Neuroleptique', 0, 239, 2),
(427, 'Thyra', 'Cupid', '17 HAUT-PUITS (Rue du)', 75299, 'Versailles', 'VGNXEY@orange.fr', '0627996495', 39, 3, 86, 'F', '0', 1, 164, 3),
(428, 'Doron', 'Lawanda', '12 CERTAIN (Rue Pierre)', 78366, 'Malakoff', 'JZDZWT@hotmail.fr', '0698270286', 99, 19, 185, 'M', '0', 1, 152, 2),
(429, 'Pancrazio', 'Katey', '30 ILE HARBOUR (Allée de l\')', 93975, 'Vanves', 'AOYVKP@free.fr', '0645017686', 97, 74, 139, 'M', 'Iode', 0, 97, 3),
(430, 'Kshitij', 'Iokua', '19 SAINT PHILIPPE (Rue)', 91725, 'Cachan', 'UBTWTX@gmail.com', '0687103565', 104, 104, 151, 'F', 'Homéopathie', 0, 91, 2),
(431, 'Bálint', 'Matilda', '46 PONT QUI TREMBLE (Rue du)', 75728, 'Montrouge', 'QUYBSS@hotmail.fr', '0621799396', 37, 46, 215, 'F', 'Pénicilline', 0, 174, 1),
(432, 'Haruko', 'Damon', '11 BERT (Rue Paul)', 78390, 'Gentilly', 'FQVYJR@free.fr', '0653470288', 95, 17, 187, 'F', 'Neuroleptique', 0, 96, 2),
(433, 'Apolinar', 'Shelia', '25 BRIGANTIN (Allée du)', 91174, 'l\'Hay-les-roses', 'VBDAXC@wanadoo.fr', '0615329830', 100, 33, 126, 'F', 'Klamoxyl', 0, 50, 3),
(434, 'Christoph', 'Cleisthenes', '49 COTTERET (Rue des Frères)', 95585, 'Villeneuve Saint-Georges', 'BXVPHI@hotmail.fr', '0659058408', 9, 6, 182, 'F', 'Aspirine', 0, 253, 2),
(435, 'Awotwi', 'Milogost', '16 DAGNET (Rue Amand)', 78805, 'Vanves', 'YGOCUN@free.fr', '0660679330', 64, 32, 219, 'F', '0', 1, 72, 3),
(436, 'Mars', 'Shaquille', '30 MARECHAL LECLERC (Place du)', 92747, 'Villeneuve Saint-Georges', 'XVFNEH@wanadoo.fr', '0697085438', 2, 78, 183, 'F', 'Pénicilline', 1, 216, 2),
(437, 'Drake', 'Donovan', '25 BAJOYER (Quai)', 94367, 'Villeneuve Saint-Georges', 'VJHIGR@hotmail.fr', '0630033380', 9, 75, 147, 'M', '0', 1, 184, 2),
(438, 'Özlem', 'Fleuretta', '9 POREE (Rue Alain)', 93801, 'Gometz-le-chatel', 'JAZIWO@hotmail.fr', '0621989518', 14, 70, 148, 'M', '0', 1, 135, 3),
(439, 'Baqir', 'Kali', '15 CINEMA (Impasse du)', 93337, 'Boulogne-billancourt', 'DCWKBS@gmail.com', '0681219399', 108, 113, 128, 'M', 'Klamoxyl', 0, 111, 3),
(440, 'Shahpur', 'Kaylin', '29 SAINT EXUPERY (Rue Antoine de)', 78707, 'Cachan', 'YBUWIK@wanadoo.fr', '0666564386', 59, 125, 173, 'F', 'Aspirine', 1, 199, 1),
(441, 'Janna', 'Muirín', '11 SAINT THOMAS (Esplanade)', 94371, 'Boulogne-billancourt', 'UTLCWV@wanadoo.fr', '0679135523', 43, 81, 198, 'F', '0', 0, 159, 3),
(442, 'Bente', 'Cosmin', '7 CANADA (Place du)', 92702, 'Vanves', 'JDQIOS@gmail.com', '0669169882', 100, 6, 120, 'F', 'Aspirine', 1, 255, 2),
(443, 'Kakalina', 'Matty', '14 DEROULEDE (Avenue Paul)', 92466, 'Rungis', 'PEZXBX@orange.fr', '0622865311', 89, 36, 140, 'F', 'Aspirine', 1, 105, 2),
(444, 'Ramsay', 'Zebadiah', '18 FUENTES (Avenue)', 94797, 'Sceaux', 'WGCNNB@gmail.com', '0671199064', 104, 71, 185, 'M', '0', 0, 146, 2),
(445, 'Abby', 'Ziyad', '46 FEVAL (Rue Paul)', 95753, 'Cachan', 'MSAQKL@gmail.com', '0687207855', 45, 95, 176, 'F', '0', 0, 66, 3),
(446, 'Jobeth', 'Maarten', '25 PETITS BOIS (Rue des)', 94846, 'Gentilly', 'VCMCBX@orange.fr', '0686393753', 75, 136, 204, 'F', 'Aspirine', 1, 205, 1),
(447, 'Midas', 'Missie', '10 TOUR D\'AUVERGNE (Boulevard de la)', 92123, 'Paris', 'TCMEPC@gmail.com', '0627132729', 91, 42, 98, 'M', '0', 0, 29, 3),
(448, 'Juana', 'Iolo', '20 BOURNAZEL (Avenue de)', 92739, 'Asnières', 'TFDTZB@orange.fr', '0655077144', 30, 132, 104, 'F', 'Pénicilline', 0, 38, 3),
(449, 'Ermenegildo', 'Brenda', '5 GODEST (Rue René)', 95884, 'Thiais', 'MZJHRC@wanadoo.fr', '0686363234', 3, 72, 188, 'M', '0', 1, 116, 3),
(450, 'Proserpine', 'Gamil', '43 FLOURIE (Place de la)', 91845, 'Boulogne-billancourt', 'BJSFWZ@free.fr', '0672171257', 32, 80, 174, 'F', '0', 1, 97, 3),
(451, 'Heinrich', 'Aurore', '17 COMMANDANT DUBOSQ (Rue du)', 94761, 'Antony', 'OPFCJE@orange.fr', '0622507988', 34, 7, 113, 'F', 'Homéopathie', 0, 266, 3),
(452, 'Amadeo', 'Zipporah', '10 ASTROLABE (Rue de l\')', 94356, 'Cachan', 'USPYSN@wanadoo.fr', '0643521189', 26, 22, 98, 'M', 'Aspirine', 1, 158, 2),
(453, 'Ciel', 'Shaelyn', '40 LOUISIANE (Jardin de la)', 91470, 'Gentilly', 'HKETJM@wanadoo.fr', '0647712530', 72, 42, 119, 'M', '0', 1, 29, 1),
(454, 'Alexej', 'Firmin', '22 MOTTAIS (Rue du)', 93155, 'Gentilly', 'EUXMBH@gmail.com', '0623012230', 16, 78, 206, 'F', 'Iode', 0, 128, 1),
(455, 'Robin', 'Xenophon', '30 JOUANJAN (Rue)', 94734, 'Orsay', 'HGYFBK@orange.fr', '0613654212', 87, 16, 170, 'M', '0', 0, 91, 2),
(456, 'Renard', 'Jep', '15 DORADE (Rue de la)', 91860, 'Thiais', 'KKHPIS@gmail.com', '0665247154', 38, 56, 152, 'F', 'Neuroleptique', 1, 35, 3),
(457, 'Mercy', 'Hanan', '45 PATELLES (Rue des)', 94891, 'Saint-cyr', 'JYFQLU@free.fr', '0686123323', 52, 39, 173, 'F', 'Homéopathie', 0, 247, 1),
(458, 'Indy', 'Bernd', '4 RIVIERE (Cour)', 92134, 'Villeneuve Saint-Georges', 'GRUZAI@free.fr', '0634322549', 105, 95, 93, 'M', '0', 0, 34, 1),
(459, 'Eilís', 'Dacre', '6 TROIS JOURNAUX (Rue des)', 75280, 'Malakoff', 'CGNCNX@orange.fr', '0682753949', 83, 140, 129, 'M', '0', 0, 70, 3),
(460, 'Barb', 'Kunigunde', '4 MARAIS (Rue Elie)', 93528, 'Villeneuve Saint-Georges', 'LRYZIK@hotmail.fr', '0679192298', 97, 12, 122, 'M', 'Aspirine', 1, 107, 2),
(461, 'Marajha', 'Romulus', '19 MAILLARD (Rue Ella)', 75408, 'Puteaux', 'GKBRCG@gmail.com', '0690672920', 32, 95, 152, 'M', 'Aspirine', 1, 122, 3),
(462, 'Bridget', 'Sofiya', '6 GRANDE HERMINE (Place de la)', 94391, 'Asnières', 'BMSVBV@orange.fr', '0637306757', 77, 87, 142, 'M', '0', 0, 148, 3),
(463, 'Akamu', 'Leocadia', '47 QUEBEC (Avenue de)', 75680, 'Robinson', 'GDYHDX@hotmail.fr', '0686609219', 3, 61, 178, 'F', '0', 1, 139, 2),
(464, 'Avedis', 'Donatienne', '25 GRANDE HERMINE (Rue de la)', 93407, 'Vélizy', 'CRZABE@wanadoo.fr', '0641038859', 42, 66, 134, 'F', '0', 1, 248, 3),
(465, 'Shichiro', 'Hoyt', '30 DURAND (Rue Mathieu)', 75441, 'Villeneuve Saint-Georges', 'CYNWSG@orange.fr', '0648004529', 110, 43, 205, 'M', '0', 1, 255, 2),
(466, 'Rachelle', 'Iikka', '16 DIXMUDE (Rue de)', 78598, 'Montrouge', 'GPANUD@hotmail.fr', '0668349220', 84, 27, 122, 'M', 'Insuline', 0, 48, 2),
(467, 'Montague', 'Agafya', '12 HIPPOCAMPE (Impasse de l\')', 75531, 'Vanves', 'JRUSZL@hotmail.fr', '0620163328', 38, 96, 167, 'M', 'Neuroleptique', 0, 26, 1),
(468, 'Philomena', 'Philis', '33 CAP HORN (Passage du)', 94857, 'Garges-lès-gonesses', 'QJPKCC@wanadoo.fr', '0685502490', 92, 65, 197, 'F', '0', 1, 274, 1),
(469, 'Shprintzel', 'Tadeu', '13 JOUANJAN (Rue)', 78613, 'Asnières', 'KCZBBS@wanadoo.fr', '0654551040', 11, 142, 133, 'F', 'Pénicilline', 0, 202, 1),
(470, 'Jeetendra', 'Elvin', '5 GEMEAUX (Rue des)', 78474, 'Rungis', 'ISLJCM@free.fr', '0615040267', 85, 74, 216, 'F', 'Insuline', 0, 122, 1),
(471, 'Janice', 'Terra', '7 PER JAKEZ HELIAS (Rue)', 92571, 'Vanves', 'WSVBYT@free.fr', '0621781421', 18, 140, 204, 'M', 'Klamoxyl', 0, 119, 2),
(472, 'Duygu', 'Garth', '30 LA CHAMBRE (Place Guy)', 92954, 'Villeneuve Saint-Georges', 'LTPCAD@orange.fr', '0635607104', 1, 33, 218, 'M', '0', 1, 230, 1),
(473, 'Pipra', 'Franciscus', '48 RESISTANCE (Enclos de la)', 75105, 'Paris', 'CHXUKM@hotmail.fr', '0617004231', 25, 138, 150, 'F', 'Homéopathie', 1, 227, 3),
(474, 'Arienne', 'Ixchel', '21 DE LA BARDELIERE (Rue Michel)', 92168, 'Paris', 'ZRUFHM@orange.fr', '0664820759', 61, 56, 158, 'F', 'Iode', 0, 109, 1),
(475, 'Padmavati', 'Jericho', '41 POREE (Rue Alain)', 91269, 'Boulogne-billancourt', 'NTRCZK@gmail.com', '0670237429', 94, 21, 179, 'M', 'Neuroleptique', 0, 72, 2),
(476, 'Yaa', 'Sandro', '47 PEPINIERE (Impasse de la)', 92388, 'Gentilly', 'KFLSJV@hotmail.fr', '0630244635', 31, 142, 213, 'F', '0', 0, 23, 2),
(477, 'Madisyn', 'Alyx', '22 METTRIE (Rue de la)', 92905, 'Neuilly', 'OQRMZR@free.fr', '0616584211', 29, 63, 203, 'M', 'Homéopathie', 1, 97, 3),
(478, 'Dana (2)', 'Orrell', '1 EXCELSIOR (Avenue)', 93138, 'Garges-lès-gonesses', 'GHSOHS@hotmail.fr', '0626150811', 78, 71, 130, 'F', 'Pénicilline', 1, 97, 1),
(479, 'Ingmar', 'Kimberly', '1 LIERRES (Rue des)', 78336, 'Gometz-le-chatel', 'SEEHWQ@gmail.com', '0655821021', 4, 111, 107, 'M', '0', 0, 260, 3),
(480, 'Kailyn', 'Joselyn', '43 ARABIE (Rue de l\')', 91165, 'Gometz-le-chatel', 'AWYAVC@orange.fr', '0654527900', 82, 68, 124, 'F', 'Pénicilline', 0, 61, 3),
(481, 'Cairbre', 'Mihai', '39 SPHINX (Allée du)', 92413, 'Arcueil', 'TRHJGI@free.fr', '0655516585', 33, 57, 164, 'M', 'Insuline', 0, 146, 3),
(482, 'Feodor', 'Selby', '14 ACHILLE (Rue de l\')', 93499, 'Rungis', 'IVZOBO@wanadoo.fr', '0647582335', 67, 31, 140, 'F', '0', 1, 37, 3),
(483, 'Akua', 'Estavan', '11 VILLE COLLET (Cour)', 95201, 'Boulogne-billancourt', 'VCWYNZ@gmail.com', '0634296362', 10, 55, 203, 'F', 'Neuroleptique', 0, 157, 1),
(484, 'Stavros', 'Gopal', '44 HEBERT (Impasse)', 75456, 'Rungis', 'NQHEQD@hotmail.fr', '0644132626', 73, 116, 136, 'F', '0', 0, 66, 2),
(485, 'Gianmaria', 'Alfons', '44 CORDERIE (Chemin de la)', 75229, 'Asnières', 'JBZGEI@wanadoo.fr', '0664240364', 36, 22, 108, 'F', 'Iode', 1, 167, 1),
(486, 'Gershom', 'Bernie', '43 BONNEVILLE (Rue de)', 92272, 'Saint-denis', 'YJOFJY@wanadoo.fr', '0629579364', 38, 49, 153, 'F', 'Neuroleptique', 0, 138, 3),
(487, 'Xochipilli', 'Attilio', '15 PARC (Rue du)', 78368, 'Cachan', 'JPJAMO@wanadoo.fr', '0639729547', 106, 142, 139, 'M', '0', 0, 151, 2),
(488, 'Désirée', 'Fionnghuala', '9 MONTREAL (Avenue de)', 93596, 'Montrouge', 'WMOVEW@orange.fr', '0664062932', 99, 36, 124, 'F', '0', 1, 197, 1),
(489, 'Rosina', 'Jorck', '33 CHOPIER (Rue Louis)', 91848, 'Vélizy', 'OBPLPO@free.fr', '0672686195', 10, 29, 174, 'F', 'Iode', 0, 172, 1),
(490, 'Meinhard', 'Scarlett', '46 FOLIGNE (Rue André)', 75406, 'Sceaux', 'EZISJP@orange.fr', '0694002879', 103, 101, 148, 'M', '0', 1, 12, 1),
(491, 'Robbie', 'Hoa', '16 GRILLE (Escalier de la)', 94574, 'Bourg-la-reine', 'QSMESD@orange.fr', '0675722728', 24, 19, 150, 'M', 'Neuroleptique', 1, 29, 1),
(492, 'Kip', 'Lachina', '35 VAU GARNI (Chemin du)', 91144, 'Massy', 'NJTQTX@wanadoo.fr', '0641037642', 50, 4, 143, 'F', 'Insuline', 0, 95, 1),
(493, 'Lula', 'Art', '40 ARROMANCHES (Rue d\')', 75901, 'Massy', 'DRVGCN@free.fr', '0622579481', 51, 88, 139, 'M', '0', 0, 82, 3),
(494, 'Meadow', 'Cleto', '20 CROIX AU FEVRE (Rue de la )', 91561, 'Asnières', 'LKIUAG@gmail.com', '0669329004', 67, 54, 154, 'F', '0', 1, 154, 2),
(495, 'Briar', 'Naum', '25 ESPERANCE (Impasse de l\')', 92793, 'Orsay', 'QXHITD@free.fr', '0618430543', 76, 143, 102, 'F', 'Klamoxyl', 1, 36, 1),
(496, 'Jameel', 'Miska', '7 BOIS AURANT (rue du)', 78875, 'l\'Hay-les-roses', 'VNHOLF@free.fr', '0630566588', 49, 18, 220, 'F', '0', 1, 141, 1),
(497, 'Eliseo', 'Trecia', '7 COUDRIERS (Rue des)', 78244, 'Arcueil', 'FGKENP@gmail.com', '0666479693', 11, 46, 183, 'M', 'Pénicilline', 1, 234, 2),
(498, 'Arienne', 'Tristão', '32 GOUAZON (Boulevard)', 91834, 'Vélizy', 'ZOTJRM@hotmail.fr', '0674438994', 31, 103, 229, 'M', 'Aspirine', 0, 33, 3),
(499, 'Hanaa', 'Modestine', '26 CONNETABLE (Rue du)', 95811, 'Thiais', 'HWOBNU@orange.fr', '0634626624', 70, 94, 117, 'M', '0', 1, 120, 1),
(500, 'Teunis', 'Frederico', '22 PETITE BARONNIE ( Impasse)', 95454, 'Boulogne-billancourt', 'TCTXTL@wanadoo.fr', '0658941795', 22, 120, 85, 'M', 'Klamoxyl', 0, 182, 3),
(501, 'Idowu', 'Raschelle', '48 GRAND VERGER (Rue du)', 94648, 'Vanves', 'PQJXDR@gmail.com', '0654836192', 82, 106, 163, 'M', 'Neuroleptique', 1, 165, 3),
(502, 'Raquel', 'Hamlet', '37 IFS (Chemin des)', 94159, 'Massy', 'TIDGKS@hotmail.fr', '0646130691', 103, 16, 170, 'M', 'Iode', 1, 78, 2),
(503, 'Tristán', 'Laban', '2 MENETRIERS (Rue des)', 75459, 'Vanves', 'JNUVWN@wanadoo.fr', '0647343865', 103, 101, 197, 'M', 'Klamoxyl', 0, 48, 1),
(504, 'Juliana', 'Vicki', '30 DALI (Rue Salvador)', 75376, 'Cachan', 'VRUWYJ@gmail.com', '0631426330', 98, 37, 158, 'F', 'Homéopathie', 1, 60, 3),
(505, 'Tovia', 'Malka', '8 JUPITER (Rue de)', 91746, 'Rungis', 'SMJPSI@hotmail.fr', '0669837550', 64, 36, 90, 'M', 'Neuroleptique', 0, 192, 1),
(506, 'Rusty', 'Meinir', '37 VARDE (Avenue de la)', 91589, 'Neuilly', 'TGZAQC@wanadoo.fr', '0657196890', 6, 87, 156, 'F', '0', 1, 54, 3),
(507, 'Mikelo', 'Feidhelm', '25 VARDE (Avenue de la)', 78266, 'Malakoff', 'RBHHES@free.fr', '0697885266', 95, 92, 96, 'F', '0', 0, 119, 3),
(508, 'Agneta', 'Ouranos', '8 GUYMAUVIERE (Rue de la)', 78689, 'Bourg-la-reine', 'JVJNDA@gmail.com', '0646996613', 69, 92, 109, 'M', '0', 0, 147, 3),
(509, 'Evpraksiya', 'Jörgen', '30 DE LA CONDAMINE (Impasse)', 91888, 'Garges-lès-gonesses', 'ZSXSEY@wanadoo.fr', '0648796201', 86, 20, 86, 'F', 'Homéopathie', 1, 177, 1),
(510, 'Xiomara', 'Bertrand', '40 TRIEUX (Square du)', 95165, 'Garges-lès-gonesses', 'TSXQFS@wanadoo.fr', '0641508041', 54, 109, 128, 'M', '0', 1, 207, 1),
(511, 'Cecil', 'Ib', '34 MERISIERS (Rue des)', 92381, 'Vélizy', 'HHGYAE@gmail.com', '0676564072', 26, 98, 91, 'M', 'Klamoxyl', 0, 168, 1),
(512, 'Deja', 'Edsel', '17 ROSEAUX (Passage des)', 75573, 'Bobigny', 'LLBVNF@gmail.com', '0635019382', 101, 145, 88, 'F', 'Iode', 1, 100, 1),
(513, 'Chizoba', 'Desislava', '26 COLONEL DEMOLINS (Boulevard du)', 75423, 'Robinson', 'QLOWEO@free.fr', '0644428697', 37, 9, 111, 'F', '0', 1, 274, 2),
(514, 'Halldóra', 'Mitchell', '15 MACLAW (Rue)', 95703, 'Rungis', 'RWCCGV@orange.fr', '0620514206', 3, 67, 136, 'M', '0', 0, 247, 1),
(515, 'Edurne', 'Ikaika', '1 JACQUES II (Rue)', 91392, 'Vélizy', 'WMMNAY@wanadoo.fr', '0672749415', 21, 100, 191, 'M', 'Neuroleptique', 0, 78, 2),
(516, 'Nestor', 'Dosia', '36 CONSTANTINE (Rue)', 95609, 'Neuilly', 'DRSHMN@orange.fr', '0674869026', 78, 106, 97, 'M', '0', 1, 7, 3),
(517, 'Theodoros', 'Amal', '35 GARANGEAU (Rue)', 91573, 'Saint-denis', 'ILZOPQ@orange.fr', '0666716688', 12, 141, 168, 'M', 'Klamoxyl', 0, 134, 1),
(518, 'Gordon', 'Eugênio', '15 PLESSIS (Rue du)', 75443, 'Antony', 'RDZZPT@wanadoo.fr', '0622763907', 85, 123, 196, 'M', 'Iode', 0, 268, 1),
(519, 'Peterkin', 'Vern', '39 LEVANT (Rue du)', 92504, 'Thiais', 'IPSFBM@orange.fr', '0617358486', 71, 21, 218, 'M', 'Aspirine', 0, 47, 1),
(520, 'Afanen', 'Kezia', '13 HIPPOCAMPE (Impasse de l\')', 92881, 'Saint-cyr', 'BDEKXA@gmail.com', '0688682956', 99, 41, 171, 'F', '0', 1, 195, 2),
(521, 'Matryona', 'Greet', '45 DECOUVERTE (Cour de la)', 93155, 'Paris', 'ECOYVE@wanadoo.fr', '0653503323', 35, 122, 164, 'F', 'Pénicilline', 0, 129, 3),
(522, 'Prissy', 'Fíona', '37 PENTHIEVRE (Square de)', 91544, 'Asnières', 'NMLHZL@gmail.com', '0666347144', 46, 53, 141, 'M', 'Aspirine', 0, 87, 2),
(523, 'Minna', 'Menes', '7 SAULAIE  (Rue de la)', 92226, 'Antony', 'DEPDJJ@free.fr', '0690424763', 79, 27, 181, 'M', 'Klamoxyl', 0, 108, 1),
(524, 'Cuc', 'Servius', '23 CHATEAUBRIAND (Place)', 95688, 'Antony', 'EJRFBM@wanadoo.fr', '0654783477', 20, 19, 139, 'F', '0', 1, 49, 1),
(525, 'Augusta', 'Imre', '31 AUBEPINE (Rue de l\')', 94934, 'Bourg-la-reine', 'LJJFBT@wanadoo.fr', '0643781057', 31, 24, 214, 'M', 'Iode', 1, 167, 2),
(526, 'Gaila', 'Barbra', '27 BASSE FLOURIE (Chemin de la)', 91655, 'l\'Hay-les-roses', 'RPLHUB@wanadoo.fr', '0699609859', 97, 48, 180, 'M', 'Neuroleptique', 0, 254, 2),
(527, 'Rafa', 'Karen', '31 GOELAND (Rue du)', 93691, 'Neuilly', 'YEITEB@orange.fr', '0670940705', 34, 82, 116, 'M', 'Aspirine', 1, 186, 1),
(528, 'Yachna', 'Lorenz', '27 SOLIDOR (Quai)', 91163, 'Gometz-le-chatel', 'XJHIJO@free.fr', '0693360348', 92, 70, 158, 'F', 'Homéopathie', 0, 80, 3),
(529, 'Totty', 'Cynefrið', '44 BOIS JOLI (Passage du)', 78916, 'Cachan', 'JLCBAN@wanadoo.fr', '0666676543', 105, 37, 145, 'F', '0', 1, 11, 1),
(530, 'Masood', 'Cheyanne', '7 CEZANNE (Rue Paul)', 75364, 'Gometz-le-chatel', 'YEISRQ@gmail.com', '0684778918', 107, 144, 153, 'M', '0', 0, 51, 1),
(531, 'Giustina', 'Amara', '5 BON VENT (Impasse du)', 75295, 'Neuilly', 'BHMMKB@orange.fr', '0680496529', 87, 52, 132, 'M', 'Neuroleptique', 1, 189, 1),
(532, 'Piet', 'Lydia', '22 CLOS POUCET (Rue du)', 94721, 'Bourg-la-reine', 'CDKEGH@hotmail.fr', '0678686135', 59, 89, 159, 'M', 'Neuroleptique', 1, 67, 1),
(533, 'Asaph', 'Susanita', '14 SERRES (Chemin des)', 95301, 'Orsay', 'QMALEY@gmail.com', '0695980517', 60, 135, 134, 'M', '0', 0, 183, 1),
(534, 'Dores', 'Dragan', '3 COUDRAY (Place Georges)', 91534, 'Saint-cyr', 'XNIQJM@wanadoo.fr', '0681563744', 107, 127, 108, 'M', 'Homéopathie', 0, 251, 2),
(535, 'Jytte', 'Stellan', '12 MANET (Rue)', 92310, 'Cachan', 'FTJLSL@wanadoo.fr', '0638839145', 63, 76, 209, 'F', 'Aspirine', 1, 171, 2),
(536, 'Asenath', 'Angela', '8 GAUGUIN (Rue Paul)', 95134, 'Vélizy', 'LZBELA@orange.fr', '0695180872', 39, 95, 85, 'F', 'Insuline', 0, 160, 3),
(537, 'Gruffud', 'Chantel', '41 DOCTEUR GUIOT (Impasse du)', 93329, 'Paris', 'IYDBKZ@gmail.com', '0669559354', 8, 54, 195, 'M', '0', 0, 109, 1),
(538, 'Stylianos', 'Aminda', '27 PORCARO (Allée des dames de)', 95659, 'Puteaux', 'MLKWTR@wanadoo.fr', '0627771469', 104, 129, 134, 'F', 'Aspirine', 0, 227, 1),
(539, 'Aeronwen', 'Antti', '34 VARANGOT (Rue)', 75254, 'Sceaux', 'YWYQUB@free.fr', '0633848773', 33, 116, 192, 'M', '0', 1, 30, 2),
(540, 'Laia', 'Piety', '5 GENERAL DE CASTELNAU (Rue du)', 78630, 'Gentilly', 'JTRHPM@wanadoo.fr', '0688177856', 81, 42, 208, 'F', 'Insuline', 0, 144, 1),
(541, 'Lachie', 'Gobnait', '19 SAUT DE LOUP (Rue du)', 94965, 'Gometz-le-chatel', 'KFUZDP@gmail.com', '0684621162', 78, 16, 122, 'F', 'Pénicilline', 1, 150, 1),
(542, 'Rina', 'Heiner', '18 BOLTZ (Rue René)', 91705, 'Bourg-la-reine', 'WXBUGY@hotmail.fr', '0648217633', 30, 61, 157, 'F', 'Neuroleptique', 1, 216, 2),
(543, 'Prudence', 'Trix', '23 FORGEURS (Rue des)', 75377, 'Boulogne-billancourt', 'LITDCD@wanadoo.fr', '0657065245', 2, 14, 122, 'M', '0', 0, 157, 3),
(544, 'Coline', 'Newt', '24 GRANDE COTIERE (Impasse de la)', 93826, 'Montrouge', 'MXHZUY@gmail.com', '0656052199', 6, 137, 229, 'F', '0', 1, 98, 3),
(545, 'Jathbiyya', 'Guy', '20 BAZILLE (Rue Frédéric)', 78391, 'Villeneuve Saint-Georges', 'JSMYGS@hotmail.fr', '0668496023', 97, 100, 190, 'M', 'Klamoxyl', 1, 164, 3),
(546, 'Mitxel', 'Nomusa', '18 LYS (Rue du)', 75141, 'Gentilly', 'NITZJX@gmail.com', '0621915261', 34, 43, 117, 'F', '0', 0, 21, 1),
(547, 'Ezar', 'Kázmér', '15 HUS (Rue Jean)', 95873, 'Villeneuve Saint-Georges', 'KMJRUQ@hotmail.fr', '0691913754', 67, 142, 100, 'M', '0', 0, 198, 2),
(548, 'Edwena', 'Trafford', '44 ROC AUX DOGUES (Impasse du)', 92151, 'Boulogne-billancourt', 'FAGWBY@orange.fr', '0652971940', 109, 93, 116, 'M', 'Insuline', 1, 115, 3),
(549, 'Oberon', 'Lupita', '14 BROUASSIN (Rue)', 78722, 'Thiais', 'EUWTDT@wanadoo.fr', '0643603354', 10, 98, 124, 'M', 'Iode', 0, 56, 3),
(550, 'Govannon', 'Kathie', '34 ALCYON (Rue de l\')', 93890, 'Massy', 'MVFZND@wanadoo.fr', '0614761563', 10, 50, 94, 'M', 'Insuline', 0, 186, 3),
(551, 'Kekepania', 'Gualtiero', '48 REVENANT (Rue du)', 93480, 'Villeneuve Saint-Georges', 'ZVJNPI@wanadoo.fr', '0674659458', 103, 61, 86, 'F', 'Homéopathie', 1, 192, 3),
(552, 'Bernardino', 'Munroe', '33 QUEBEC (Place du)', 92169, 'Saint-cyr', 'GQNMWU@hotmail.fr', '0689360784', 29, 68, 88, 'F', '0', 1, 135, 1),
(553, 'Hadewych', 'Petros', '40 FOUERE (Rue Jules)', 94495, 'Bobigny', 'YAFIWD@hotmail.fr', '0635614704', 88, 93, 110, 'M', '0', 1, 259, 1),
(554, 'Davie', 'Ianthe', '6 COMMANDANT BOURDAIS (Passage du)', 78267, 'Versailles', 'ZRSEDI@free.fr', '0692454498', 42, 89, 230, 'M', '0', 1, 135, 2),
(555, 'Chanel', 'Jérôme', '50 EOLE (Impasse d\')', 93349, 'Versailles', 'GHNWJN@hotmail.fr', '0659993421', 8, 29, 100, 'F', 'Homéopathie', 1, 2, 3),
(556, 'Hikmat', 'Erick', '2 DESIRADE (Rue de la)', 95550, 'Arcueil', 'OJIVUO@free.fr', '0675836331', 37, 59, 138, 'F', 'Iode', 1, 112, 1),
(557, 'Kyla', 'Fayvel', '23 HURE (Place de la)', 95377, 'Orsay', 'IOLXRV@gmail.com', '0686788688', 60, 70, 219, 'M', '0', 0, 89, 1),
(558, 'Firmin', 'Chenda', '12 DEJAN (Rue René)', 78576, 'Puteaux', 'UVXCNM@wanadoo.fr', '0684205617', 87, 70, 116, 'F', '0', 1, 191, 3),
(559, 'Cornélio', 'Liesl', '38 ROCHEBONNE (Digue de)', 93746, 'l\'Hay-les-roses', 'CGBECA@wanadoo.fr', '0653506097', 22, 73, 222, 'F', '0', 0, 111, 3),
(560, 'Matej', 'Kunigunde', '30 TOULLIER (Rue)', 91511, 'Puteaux', 'ZPXJZO@gmail.com', '0668211759', 95, 146, 182, 'M', '0', 0, 251, 3),
(561, 'Marcelle', 'Suniti', '12 SAINT PIERRE (Place)', 91347, 'Asnières', 'KCGVNB@orange.fr', '0652581480', 6, 11, 137, 'M', 'Iode', 1, 45, 1),
(562, 'Alfonso', 'Dorean', '19 GOELAND (Impasse du)', 95505, 'Villeneuve Saint-Georges', 'YWJAEO@wanadoo.fr', '0667886633', 49, 13, 162, 'M', '0', 0, 217, 3),
(563, 'Gail', 'Torin', '20 DUGUESCLIN (Place)', 75713, 'Orsay', 'LMROOV@free.fr', '0646972535', 38, 93, 158, 'F', '0', 1, 179, 3),
(564, 'Alain', 'Rozanne', '47 ROCHER (Rue du)', 78607, 'Cachan', 'XBKXML@hotmail.fr', '0653336298', 31, 23, 95, 'M', 'Neuroleptique', 1, 74, 1),
(565, 'Sammie', 'Ivanna', '20 DE VINCI (Rue Léonard)', 94150, 'Paris', 'ILKACD@free.fr', '0617989014', 82, 86, 221, 'M', 'Neuroleptique', 0, 143, 3),
(566, 'Tuulikki', 'Tresha', '2 FRESNEL (Impasse Augustin)', 92972, 'Sceaux', 'GYCCND@hotmail.fr', '0622377821', 4, 58, 215, 'F', 'Iode', 1, 143, 2),
(567, 'Maud', 'Thales', '47 PICPUS (Jardin de)', 93684, 'l\'Hay-les-roses', 'MTKQPQ@wanadoo.fr', '0684815178', 3, 3, 125, 'F', 'Iode', 1, 47, 2),
(568, 'Gladwin', 'Elsdon', '37 ENCLOS DU MOULIN (Rue de l\')', 93130, 'Asnières', 'ZTZOJT@wanadoo.fr', '0632998654', 28, 47, 96, 'F', 'Neuroleptique', 1, 176, 3),
(569, 'Jacquetta', 'Chandana', '10 TAMARIS (Rue des)', 91658, 'Gentilly', 'ESNWJH@wanadoo.fr', '0682774126', 71, 66, 141, 'F', '0', 0, 263, 1),
(570, 'Dáire', 'Dougal', '22 ENCLOS DU VERGER (Rue de l\')', 92859, 'Malakoff', 'VQCSYB@hotmail.fr', '0652779946', 41, 26, 148, 'M', '0', 0, 187, 2),
(571, 'Ilbert', 'Marek', '47 CHAPELLE (Rue de la)', 95370, 'l\'Hay-les-roses', 'LJJIGH@wanadoo.fr', '0670124097', 83, 140, 159, 'M', '0', 1, 164, 2),
(572, 'Tatienne', 'Artemis', '19 BANQUEREAU (impasse du)', 75625, 'Saint-cyr', 'PBIKWJ@hotmail.fr', '0688573180', 42, 69, 193, 'M', 'Iode', 0, 233, 1),
(573, 'Éloise', 'Charna', '11 ARTILLEURS (Rue des)', 92299, 'Thiais', 'RKSBGY@wanadoo.fr', '0652807022', 31, 21, 104, 'M', '0', 0, 202, 3),
(574, 'Eloisa', 'Ninel', '5 MOKA (Avenue de)', 94411, 'Malakoff', 'VUOXNC@gmail.com', '0665107843', 80, 42, 92, 'F', 'Homéopathie', 1, 5, 3),
(575, 'Kishori', 'Gervais', '31 MONET (Rue Claude)', 92324, 'Sceaux', 'SCFKWS@free.fr', '0687892008', 94, 5, 118, 'F', 'Aspirine', 1, 159, 1),
(576, 'Tracy', 'Aias', '19 CHARCOT (Place)', 78881, 'Saint-cyr', 'HRYTHE@free.fr', '0657930908', 7, 63, 182, 'M', 'Neuroleptique', 1, 231, 2),
(577, 'Devereux', 'Luce', '7 POUDRIERE (Passage de la)', 92463, 'Saint-denis', 'KDOEGS@hotmail.fr', '0665901382', 58, 64, 155, 'M', '0', 1, 187, 2),
(578, 'Brava', 'Elly', '17 GAMBETTA (Boulevard)', 92331, 'Saint-Quentin en Yvelines', 'JJZRJG@orange.fr', '0638033905', 8, 118, 183, 'M', 'Aspirine', 1, 60, 3),
(579, 'Kunthea', 'Maeve', '8 FLEURS (Rue des)', 95796, 'Saint-cyr', 'PKOXBX@orange.fr', '0610510751', 14, 81, 200, 'F', '0', 0, 194, 3),
(580, 'Jim', 'Brutus', '29 EGLISE  (Place de l\')', 91216, 'Cachan', 'HOJZPK@orange.fr', '0617734281', 56, 96, 112, 'F', 'Aspirine', 1, 249, 1),
(581, 'Lucie', 'Chrissy', '23 CORBINIERE (Rue de la)', 95220, 'Bobigny', 'HDBCWF@orange.fr', '0624491754', 46, 112, 148, 'M', 'Homéopathie', 1, 49, 3),
(582, 'Raleigh', 'Agatha', '47 PLATIER (Impasse du)', 94441, 'Boulogne-billancourt', 'KIMWBC@orange.fr', '0623769755', 25, 140, 140, 'F', '0', 0, 240, 1),
(583, 'Kekepania', 'Maybelle', '6 MARCHE (Place du)', 93765, 'Massy', 'QJAEYZ@hotmail.fr', '0633791815', 58, 142, 139, 'F', '0', 0, 105, 2),
(584, 'Blanca', 'Laverne', '22 CROLANTE (Allée de la)', 75328, 'Thiais', 'WLHPBX@wanadoo.fr', '0679025511', 88, 14, 199, 'M', 'Aspirine', 1, 184, 2),
(585, 'Laurent', 'Davy', '3 BEAULIEU (Rue de)', 95107, 'l\'Hay-les-roses', 'FFIOPS@orange.fr', '0687228538', 74, 63, 95, 'F', 'Iode', 0, 268, 2),
(586, 'Apikalia', 'Walenty', '1 PLESSIS (Rue du)', 75119, 'Versailles', 'QPCOSR@wanadoo.fr', '0664345918', 79, 105, 165, 'F', 'Iode', 0, 151, 3),
(587, 'Epona', 'Suraya', '47 CAPUCINES (Rue des)', 91691, 'Puteaux', 'KCWCRQ@wanadoo.fr', '0699963556', 101, 55, 224, 'F', 'Neuroleptique', 1, 20, 3),
(588, 'Prue', 'Randi', '50 HOCHELAGA (Rue de)', 93288, 'Malakoff', 'XRQALI@gmail.com', '0672774458', 75, 32, 223, 'F', 'Homéopathie', 1, 202, 2),
(589, 'Neifion', 'Lexus', '45 ROUSSE (Impasse de)', 92179, 'Saint-denis', 'XOFRLL@wanadoo.fr', '0688424392', 102, 30, 95, 'F', 'Neuroleptique', 1, 50, 3),
(590, 'Yewande', 'Kaden', '1 SEURAT (Rue Georges)', 94574, 'Puteaux', 'BZZSYE@free.fr', '0629871748', 36, 129, 170, 'M', '0', 1, 42, 3),
(591, 'Gutxi', 'Cierra', '27 NATIERE (Rue de la)', 92915, 'Robinson', 'MKLVSL@free.fr', '0696377606', 83, 44, 195, 'F', '0', 0, 81, 2),
(592, 'Indra', 'Ryo', '32 CORMORANS (Impasse des)', 94927, 'Arcueil', 'ZJCZFR@free.fr', '0623439227', 80, 49, 100, 'F', '0', 0, 142, 1),
(593, 'Kiran', 'Rica', '29 NAYE (Fort du)', 95228, 'Malakoff', 'WBXFFN@orange.fr', '0667291296', 1, 38, 165, 'M', 'Neuroleptique', 1, 200, 2),
(594, 'Tinek', 'Habacuc', '11 BEAUSEJOUR (Rue)', 93724, 'Massy', 'COTCLB@gmail.com', '0653686731', 10, 79, 100, 'F', 'Neuroleptique', 0, 61, 3),
(595, 'Anahid', 'Hartley', '40 TONNELLES (Rue des)', 93709, 'l\'Hay-les-roses', 'GSJWFU@free.fr', '0693979593', 79, 7, 174, 'F', '0', 0, 67, 2),
(596, 'Ssanyu', 'Eleutherius', '43 SAINTE MARGUERITE (Rue)', 92757, 'Malakoff', 'UNARYN@wanadoo.fr', '0623408162', 79, 120, 162, 'M', '0', 0, 157, 3),
(597, 'Valdemar', 'Ernõ', '3 CYPRES (Rue des)', 94108, 'Paris', 'LLBPHK@gmail.com', '0625686818', 54, 34, 170, 'F', '0', 1, 104, 1),
(598, 'Nandag', 'Hinrich', '42 ANEMONES(rue des)', 93934, 'Paris', 'CXZDJO@wanadoo.fr', '0657462634', 6, 112, 197, 'F', 'Neuroleptique', 1, 201, 1),
(599, 'Xene', 'Trinidad', '34 COLOMB (Rue Christophe)', 95669, 'Saint-denis', 'FVYHOZ@free.fr', '0684800305', 68, 140, 217, 'F', 'Insuline', 0, 195, 2),
(600, 'Finola', 'Dorothy', '21 MORISOT (Rue Berthe)', 75292, 'Massy', 'BZDAXQ@gmail.com', '0683028056', 101, 33, 194, 'M', 'Homéopathie', 1, 124, 3),
(601, 'Hiltrud', 'Leonardo', '16 PUITS SAUVAGE (Rue du )', 93544, 'Paris', 'QZRVQO@hotmail.fr', '0660538455', 80, 42, 169, 'M', 'Pénicilline', 1, 193, 3),
(602, 'Alexandria', 'Louise', '34 LE GUEN (Rue Emmanuel)', 95679, 'Thiais', 'LZWSME@wanadoo.fr', '0665725380', 48, 25, 97, 'M', '0', 1, 249, 1),
(603, 'Vulcan', 'Kanta', '16 GILLE (Rue Georges)', 95428, 'Versailles', 'IRPLAJ@orange.fr', '0637851507', 47, 59, 193, 'F', 'Homéopathie', 1, 95, 1),
(604, 'Josef', 'Rupert', '10 MERCIERS (Rue des)', 93902, 'Cachan', 'ASDIZH@free.fr', '0677527720', 55, 118, 184, 'F', '0', 0, 12, 2),
(605, 'Tova', 'Rosalva', '12 ABBAYE ST-JEAN (Rue)', 94606, 'Boulogne-billancourt', 'QPFMPC@gmail.com', '0618009957', 41, 67, 202, 'F', '0', 0, 3, 3),
(606, 'Dottie', 'Eris', '49 BIR HAKEIM (Impasse)', 93487, 'Bobigny', 'FQBLVW@orange.fr', '0649716756', 1, 126, 130, 'M', '0', 0, 246, 3),
(607, 'Ginny', 'Lorenza', '23 ANEMONES(rue des)', 94418, 'Cachan', 'BDOPOW@hotmail.fr', '0638887589', 91, 130, 171, 'M', 'Insuline', 1, 121, 3),
(608, 'Salvatore', 'Zelpah', '34 LAMENNAIS (Esplanade Félicité)', 94506, 'Cachan', 'UEDXUZ@gmail.com', '0628885395', 7, 55, 207, 'F', '0', 1, 197, 3),
(609, 'Toribio', 'Ayishah', '13 MARCHE (Place du)', 78815, 'Paris', 'OQKUZS@wanadoo.fr', '0696875938', 104, 98, 157, 'M', 'Pénicilline', 0, 105, 2),
(610, 'Jóna', 'Éloise', '14 DAHLIAS (Rue des)', 95858, 'Vélizy', 'NRFMQH@free.fr', '0646308284', 43, 143, 205, 'M', 'Insuline', 0, 174, 1),
(611, 'Harland', 'Christin', '20 PRUNIERS (Rue des)', 91404, 'l\'Hay-les-roses', 'TOJSBD@wanadoo.fr', '0687011066', 28, 145, 86, 'F', '0', 0, 43, 1),
(612, 'Pollyanna', 'Jarred', '21 CLOS BARON (Rue du)', 95549, 'Antony', 'IXWJLY@orange.fr', '0644573830', 64, 40, 137, 'F', '0', 1, 239, 1),
(613, 'Dyan', 'Yarden', '10 QUEBEC (Place du)', 91111, 'Neuilly', 'VMPPZV@free.fr', '0653425706', 92, 57, 172, 'F', 'Iode', 1, 262, 2),
(614, 'Sara', 'Venetia', '13 DE CHATILLON (Place Jean)', 92519, 'Antony', 'HPDUXO@wanadoo.fr', '0625553113', 8, 32, 197, 'F', 'Insuline', 0, 238, 2),
(615, 'Meical', 'Caradog', '19 PONT-PINEL (Rue du)', 91824, 'Versailles', 'PVDMLP@orange.fr', '0644439795', 96, 21, 177, 'F', 'Klamoxyl', 0, 56, 3),
(616, 'Suibhne', 'Maeva', '14 GEMEAUX (Rue des)', 95316, 'Saint-denis', 'OOYMCZ@free.fr', '0692065625', 13, 74, 137, 'F', '0', 0, 210, 3),
(617, 'Jasmyn', 'Erzsébet', '20 BOURELAIS (Impasse de la)', 95544, 'Villeneuve Saint-Georges', 'EXLFCX@wanadoo.fr', '0694394355', 21, 3, 158, 'M', '0', 0, 205, 2),
(618, 'Jep', 'Josef', '23 DUGUESCLIN (Avenue)', 75872, 'Saint-cyr', 'PULGFT@gmail.com', '0657611124', 1, 13, 168, 'F', 'Iode', 1, 154, 2),
(619, 'Ríona', 'Miia', '38 POURPRIS (Rue du)', 95318, 'Orsay', 'LHKFMA@free.fr', '0629172587', 94, 95, 134, 'F', '0', 0, 15, 3),
(620, 'Karina', 'Wiremu', '18 ANCIENS COMBATTANTS (R.P.)', 75970, 'Thiais', 'TRNFOT@hotmail.fr', '0664333169', 52, 29, 163, 'F', '0', 1, 119, 1),
(621, 'Dániel', 'Krisztián', '22 NORMANDS (Rue des)', 95135, 'Massy', 'FNAZAI@gmail.com', '0698311561', 39, 24, 177, 'F', '0', 1, 157, 1),
(622, 'Webster', 'Chonsie', '37 AULNES (Rue des)', 93131, 'Arcueil', 'RRQVSO@hotmail.fr', '0616640632', 89, 57, 155, 'F', 'Iode', 1, 139, 2),
(623, 'Opal', 'Netuno', '38 CHATEAUBRIAND (Boulevard)', 75796, 'Boulogne-billancourt', 'FTXHOR@gmail.com', '0696694756', 13, 78, 87, 'F', 'Klamoxyl', 1, 132, 2),
(624, 'Jaqueline', 'Ellen', '28 EMERILLON (Passage de l\')', 94291, 'Vanves', 'DCERLY@orange.fr', '0667350714', 47, 88, 210, 'F', 'Klamoxyl', 0, 253, 1),
(625, 'Rich', 'Abd-Al-Qadir', '9 CHAMP PEGASE (Ruelle du)', 94755, 'Puteaux', 'XZILOE@wanadoo.fr', '0660529121', 90, 98, 169, 'M', 'Homéopathie', 1, 138, 1),
(626, 'Curt', 'Bláthnaid', '37 CARNOT (Rue)', 93521, 'Paris', 'HZWFGB@wanadoo.fr', '0625751518', 94, 97, 115, 'M', '0', 0, 143, 2),
(627, 'Katherina', 'Nancy', '10 DUPARQUIER (Rue)', 91988, 'Bobigny', 'ALNFHW@orange.fr', '0651729824', 87, 90, 158, 'M', 'Aspirine', 1, 117, 2),
(628, 'Byrne', 'Selena', '41 CORDONNERIE (Rue de la)', 95518, 'Gometz-le-chatel', 'KYTDFK@orange.fr', '0677970095', 37, 65, 181, 'M', 'Iode', 0, 152, 3),
(629, 'Pearle', 'Bautista', '42 PLEIN SOLEIL (Allée du)', 92256, 'Bobigny', 'WOLTJU@hotmail.fr', '0648507910', 21, 70, 104, 'F', '0', 0, 112, 2),
(630, 'Meinhard', 'Janene', '49 NIELLES (Avenue des)', 75485, 'Neuilly', 'IXJLPN@free.fr', '0682645654', 69, 38, 188, 'F', 'Klamoxyl', 0, 188, 1),
(631, 'Blodeuyn', 'Marni', '3 BEAUFILS (Impasse Edouard)', 93501, 'l\'Hay-les-roses', 'RTIXBK@wanadoo.fr', '0623024729', 108, 37, 112, 'F', '0', 1, 66, 1),
(632, 'Rizwan', 'Giovanna', '29 AMIRAL PROTET (Rue)', 94159, 'Villeneuve Saint-Georges', 'HBFUWE@orange.fr', '0698584868', 107, 9, 90, 'M', '0', 1, 233, 1),
(633, 'Angelia', 'Fernand', '25 BANQUEREAU (impasse du)', 94161, 'Vanves', 'PCDYXR@hotmail.fr', '0637059105', 77, 112, 184, 'F', '0', 1, 182, 2),
(634, 'Chaz', 'Séafra', '33 NOIRES (Môle des)', 75811, 'Orsay', 'UPPTKV@wanadoo.fr', '0610174082', 24, 45, 214, 'F', 'Insuline', 1, 54, 3),
(635, 'Xenon', 'Mabella', '31 MAURIERS (Rue des)', 75939, 'Arcueil', 'ZHPCOF@hotmail.fr', '0649575839', 47, 93, 122, 'F', 'Pénicilline', 1, 170, 3),
(636, 'Neelam', 'Tertius', '13 GODEST (Rue René)', 95458, 'Thiais', 'JRUGMZ@wanadoo.fr', '0693736743', 59, 4, 175, 'M', 'Iode', 1, 51, 2),
(637, 'Brooke', 'Lodewijk', '39 HEBERT (Rue)', 93802, 'Neuilly', 'NYRADA@hotmail.fr', '0616332306', 68, 45, 181, 'F', '0', 0, 120, 1),
(638, 'Kamila', 'Romey', '36 NIELLES (Avenue des)', 91986, 'Bourg-la-reine', 'RSZBJD@hotmail.fr', '0696128325', 57, 46, 152, 'F', '0', 0, 230, 1),
(639, 'Caitria', 'Ronny', '12 CLOS BARON (Rue du)', 78650, 'Sceaux', 'ZGIWXW@free.fr', '0635728091', 7, 97, 209, 'M', '0', 1, 87, 3),
(640, 'Pryderi', 'Chava', '49 BIGNON (Chemin du) ', 93695, 'Neuilly', 'NTAWQO@wanadoo.fr', '0667761140', 25, 14, 224, 'M', 'Homéopathie', 0, 273, 2),
(641, 'Harun', 'Blaine', '18 FORTS (Impasse des)', 92624, 'Asnières', 'FLUKEP@free.fr', '0653298738', 51, 111, 94, 'F', 'Pénicilline', 0, 84, 3),
(642, 'Rémi', 'Nahor', '11 ECHEVINS (Rue des)', 94651, 'Montrouge', 'NGVHYM@hotmail.fr', '0652573228', 81, 93, 194, 'F', '0', 1, 96, 3),
(643, 'Al', 'Réamann', '48 VIEUX REMPARTS (Rue des)', 92104, 'Vanves', 'AXDLZE@wanadoo.fr', '0674861306', 82, 64, 90, 'M', '0', 0, 198, 2),
(644, 'Henrike', 'Aaliyah', '21 NATION (Rue de la)', 92815, 'Montrouge', 'QMKVIP@free.fr', '0673233446', 44, 150, 134, 'F', 'Pénicilline', 1, 152, 2),
(645, 'Zita', 'Vidal', '12 CHARMILLES (Rue des)', 93512, 'Antony', 'KNFAMJ@gmail.com', '0627243961', 54, 84, 102, 'M', '0', 0, 7, 3),
(646, 'Paula', 'Kausalya', '11 CORBIERE (Rue Tristan)', 78180, 'Versailles', 'DBNTLL@free.fr', '0617311103', 84, 128, 111, 'F', '0', 1, 262, 3),
(647, 'Ailbhe', 'Jordana', '34 HOLLANDE (Bastion de la)', 93457, 'Orsay', 'SOHXNO@orange.fr', '0629979694', 68, 141, 163, 'F', 'Iode', 1, 245, 2),
(648, 'Erskine', 'Raja', '11 BOUGAINVILLE (Rue)', 92381, 'Robinson', 'PFQTXV@orange.fr', '0661462468', 65, 123, 213, 'M', 'Pénicilline', 0, 194, 3),
(649, 'Jaynie', 'Ksenia', '13 NORMANDS (Rue des)', 92940, 'Arcueil', 'LQDZMJ@gmail.com', '0645048403', 87, 76, 147, 'F', '0', 1, 75, 3),
(650, 'Philokrates', 'Seamour', '9 VILLES ALLIS (Rue des)', 75853, 'Neuilly', 'MYYPWF@hotmail.fr', '0615026625', 90, 76, 221, 'M', 'Insuline', 1, 48, 3),
(651, 'Alonzo', 'Lilias', '14 MIMOSAS (Rue des)', 78576, 'Orsay', 'OVIFZK@orange.fr', '0648425448', 25, 66, 106, 'M', 'Homéopathie', 1, 107, 1),
(652, 'Sive', 'Nicoleta', '20 JASMIN (Rue du)', 95115, 'Asnières', 'FGEQOZ@hotmail.fr', '0674203878', 45, 72, 217, 'M', '0', 0, 200, 2),
(653, 'Willis', 'Leonzio', '47 POURQUOI PAS (Rue du)', 75909, 'Thiais', 'OIWJZJ@hotmail.fr', '0623780505', 28, 106, 218, 'M', '0', 0, 253, 3),
(654, 'Celyn', 'Beylke', '13 FLORE (Rue de)', 75708, 'Saint-denis', 'QGMPDO@wanadoo.fr', '0616678879', 66, 24, 93, 'F', '0', 1, 98, 2),
(655, 'Teigue', 'Faustus', '24 MARETTES (Rue des)', 91790, 'Montrouge', 'TFAVDP@free.fr', '0665834426', 96, 23, 168, 'M', 'Aspirine', 0, 120, 3),
(656, 'Edwina', 'Thoth', '21 GOELAND (Rue du)', 95154, 'Puteaux', 'PINMGX@wanadoo.fr', '0628424157', 45, 44, 104, 'F', 'Iode', 0, 53, 3),
(657, 'Hana', 'Joanne', '23 CHEVALIERS (Rue des)', 93264, 'Saint-denis', 'JYIMQI@free.fr', '0618918105', 48, 119, 122, 'F', 'Iode', 1, 46, 2),
(658, 'Joost', 'Minako', '15 SERVANTINE (Allée de la)', 91812, 'Vélizy', 'UAGXUN@free.fr', '0631908712', 11, 56, 220, 'M', 'Insuline', 0, 213, 1),
(659, 'Jacenty', 'Petera', '33 PUITS SAUVAGE (Rue du )', 92372, 'Asnières', 'HEPRBD@free.fr', '0687133959', 80, 79, 144, 'M', 'Iode', 0, 238, 3),
(660, 'Jazmine', 'Kiarra', '6 DUCLOS GUYOT (Place)', 78129, 'Neuilly', 'AYBBFA@hotmail.fr', '0637331436', 24, 66, 217, 'F', 'Homéopathie', 0, 191, 1),
(661, 'Satish', 'Telesphore', '48 CROIX BEAUGEARD (Rue de la)', 78977, 'Antony', 'QKPRIU@orange.fr', '0666544555', 25, 43, 224, 'F', '0', 0, 170, 2),
(662, 'Dolph', 'Santos', '46 SAINTE ANNE (Rue)', 78688, 'Gometz-le-chatel', 'YKHJCW@gmail.com', '0698117740', 71, 92, 150, 'F', '0', 1, 160, 2),
(663, 'Sido', 'Gautier', '3 Vanves (RUE)', 75015, 'Paris', 'g.sido@epfedu.fr', '0603846799', 21, 60, 178, 'M', 'Doliprane', 1, 23, 1),
(664, 'Serre', 'Thibault', '4 rue Auguste', 75015, 'Paris', 't.serre@gmail.com', '093738908', 20, 71, 175, 'M', 'Doliprane', 1, 19, 2);

-- --------------------------------------------------------

--
-- Structure de la table `personnel`
--

CREATE TABLE `personnel` (
  `ID_personnel` int(5) UNSIGNED NOT NULL,
  `Nom_personnel` varchar(50) NOT NULL,
  `Prenom_personnel` varchar(50) NOT NULL,
  `Personnel` enum('Personnel médical','Personnel administratif','Personnel de nettoyage') DEFAULT NULL,
  `Fonction` enum('Médecin','Chirurgien','Ophtalmologue','Oncologue','Infirmier','Aide soignant','Sage femme','Personnel de nettoyage','Personnel d''entretien','Secrétaire','Directeur','Hôte/Hôtesse d''accueil','Responsable ressources humaines','Psychologue','Urologue') DEFAULT NULL,
  `Date_embauche` date NOT NULL,
  `Salaire_personnel` float NOT NULL,
  `Telephone_personnel` varchar(10) NOT NULL,
  `Adresse_personnel` varchar(200) NOT NULL,
  `Code_postal_personnel` int(5) NOT NULL,
  `Ville_personnel` varchar(100) NOT NULL,
  `Mail_personnel` varchar(50) NOT NULL,
  `ID_etablissement` int(5) UNSIGNED NOT NULL,
  `ID_service` int(5) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `personnel`
--

INSERT INTO `personnel` (`ID_personnel`, `Nom_personnel`, `Prenom_personnel`, `Personnel`, `Fonction`, `Date_embauche`, `Salaire_personnel`, `Telephone_personnel`, `Adresse_personnel`, `Code_postal_personnel`, `Ville_personnel`, `Mail_personnel`, `ID_etablissement`, `ID_service`) VALUES
(884, 'Melaina', 'Eddie', 'Personnel médical', 'Aide soignant', '2017-12-19', 6002, '0652089911', '11 COETQUEN (Rue du)', 95820, 'Massy', 'VXMIIC@orange.fr', 3, 69),
(885, 'Ffion', 'Timoteus', 'Personnel médical', 'Ophtalmologue', '2014-01-07', 5323, '0694192954', '26 CURAÇAO (Impasse du)', 75692, 'Vélizy', 'VGKJFB@hotmail.fr', 1, 42),
(886, 'Arcadia', 'Veera', 'Personnel médical', 'Chirurgien', '2011-09-04', 4423, '0684433226', '18 FUENTES (Avenue)', 75368, 'Antony', 'HSEXXZ@free.fr', 3, 67),
(887, 'Amadi', 'Tuvya', 'Personnel médical', 'Psychologue', '2016-04-26', 2565, '0686838320', '20 GOUAZON (Boulevard)', 95641, 'Bobigny', 'MRBOGR@free.fr', 3, 50),
(888, 'Morgan', 'Madeline', 'Personnel médical', 'Psychologue', '2011-02-11', 4681, '0663575324', '4 RENCONTRE (Allée de la)', 92714, 'Rungis', 'LPSTPQ@free.fr', 2, 50),
(889, 'Gry', 'Steenie', 'Personnel médical', 'Sage femme', '2014-04-16', 7739, '0682855406', '43 MOUETTES (Rue des)', 78280, 'Vanves', 'XSYVOH@gmail.com', 1, 64),
(890, 'Miranda', 'Tina', 'Personnel médical', 'Médecin', '2016-12-10', 1689, '0624449374', '20 TULIPES (Rue des)', 75157, 'Malakoff', 'BDIINN@hotmail.fr', 2, 71),
(891, 'Zusman', 'Zosimos', 'Personnel médical', 'Oncologue', '2017-06-02', 6270, '0650384366', '34 JONQUILLES (Rue des)', 91708, 'Bobigny', 'QFBVTI@wanadoo.fr', 2, 43),
(892, 'Wojciech', 'Fachtna', 'Personnel médical', 'Sage femme', '2012-12-12', 1472, '0697952187', '19 GRANDE MOINERIE (Rue de la)', 95908, 'Bourg-la-reine', 'GTEJEZ@hotmail.fr', 3, 66),
(893, 'Fikriyya', 'Herbert', 'Personnel médical', 'Ophtalmologue', '2011-01-06', 1118, '0630522941', '35 CANADA (Place du)', 75456, 'Montrouge', 'EGHBJC@hotmail.fr', 1, 42),
(894, 'Fryderyk', 'Pascuala', 'Personnel médical', 'Infirmier', '2017-03-17', 2721, '0653739282', '2 SAINT PIERRE ET MIQUELON (Avenue)', 93765, 'Garges-lès-gonesses', 'ANMEXB@wanadoo.fr', 3, 76),
(895, 'Jacqui', 'Kama', 'Personnel médical', 'Oncologue', '2018-11-10', 3346, '0696286086', '23 QUEBEC (Avenue de)', 75273, 'Antony', 'LDBOCQ@free.fr', 1, 44),
(896, 'Pearle', 'Reynaud', 'Personnel médical', 'Chirurgien', '2011-09-18', 1230, '0671131236', '25 CHAPELET (Rue Roger)', 95410, 'Montrouge', 'PEBMIQ@wanadoo.fr', 1, 68),
(897, 'Linford', 'Yaffa', 'Personnel médical', 'Infirmier', '2013-10-25', 1358, '0629568737', '40 CHASSE (Impasse Charles)', 78627, 'Vélizy', 'FQBQYD@free.fr', 1, 71),
(898, 'Przemo', 'Hedda', 'Personnel médical', 'Sage femme', '2020-07-24', 1625, '0693867757', '11 SEMILLANTE (Allée de la)', 91474, 'Cachan', 'QEQVLA@gmail.com', 2, 66),
(899, 'Cheryl', 'Damiano', 'Personnel médical', 'Chirurgien', '2015-03-14', 1787, '0653095392', '36 HARPE (Rue de la)', 94418, 'Saint-cyr', 'UEKGZD@wanadoo.fr', 2, 67),
(900, 'Sapphire', 'Mahavir', 'Personnel médical', 'Infirmier', '2010-10-15', 6874, '0657151896', '24 FREGATE (Allée de la)', 75543, 'Montrouge', 'HOEPWJ@hotmail.fr', 2, 52),
(901, 'Vilmar', 'Eleanor', 'Personnel médical', 'Sage femme', '2012-12-13', 7287, '0689065504', '31 BATELEURS (Rue des)', 78510, 'Sceaux', 'JRGYGG@hotmail.fr', 1, 66),
(902, 'Eduard', 'Madoline', 'Personnel médical', 'Psychologue', '2016-11-14', 2393, '0679132214', '9 JONGLEURS (Rue des)', 94876, 'Villeneuve Saint-Georges', 'CEFBKP@free.fr', 1, 49),
(903, 'Hammond', 'Lan', 'Personnel médical', 'Chirurgien', '2015-03-22', 1613, '0692092950', '8 BAZILLE (Rue Frédéric)', 95374, 'Garges-lès-gonesses', 'LBILSQ@gmail.com', 3, 67),
(904, 'Sunshine', 'Miksa', 'Personnel médical', 'Urologue', '2020-08-06', 7150, '0686196719', '47 TERTRE VERRINE (Rue du)', 91735, 'Malakoff', 'EABYAY@free.fr', 1, 67),
(905, 'Ömer', 'Ronald', 'Personnel médical', 'Médecin', '2020-09-03', 2374, '0686699864', '9 PETITE BARONNIE (Chemin de la)', 78471, 'Villeneuve Saint-Georges', 'BSUKUG@hotmail.fr', 2, 65),
(906, 'Eoforhild', 'Genoveffa', 'Personnel médical', 'Ophtalmologue', '2019-02-05', 1466, '0612371534', '9 COUDRIERS (Rue des)', 78829, 'Bourg-la-reine', 'YQKFMF@hotmail.fr', 2, 40),
(907, 'Sarai', 'Reggie', 'Personnel médical', 'Médecin', '2011-03-11', 1971, '0677591798', '21 CYTISES (Impasse des)', 93282, 'Saint-cyr', 'LXJWSB@gmail.com', 2, 64),
(908, 'Éadaoin', 'Baal', 'Personnel médical', 'Urologue', '2012-07-09', 4549, '0640935168', '47 NORMANDS (Impasse des)', 75767, 'Antony', 'ITTSZW@wanadoo.fr', 2, 67),
(909, 'Sophie', 'Carlton', 'Personnel médical', 'Psychologue', '2012-10-20', 3085, '0614486424', '26 CORDIERS (Rue des)', 78458, 'Arcueil', 'NQOVJA@orange.fr', 1, 51),
(910, 'Spiros', 'Sylvana', 'Personnel médical', 'Psychologue', '2012-07-22', 7841, '0617288946', '9 ACACIAS (Rue des)', 93655, 'Puteaux', 'DQETAW@wanadoo.fr', 3, 51),
(911, 'Sancho', 'Christophe', 'Personnel médical', 'Chirurgien', '2020-09-24', 7359, '0678574976', '49 HUGO (Avenue Victor)', 94753, 'Arcueil', 'FDQFDP@orange.fr', 3, 68),
(912, 'Joab', 'Jaumet', 'Personnel médical', 'Sage femme', '2016-01-09', 2627, '0621351582', '27 SAULAIE  (Rue de la)', 75567, 'Montrouge', 'SOIKIW@hotmail.fr', 1, 64),
(913, 'Narcisse', 'Iqbal', 'Personnel médical', 'Infirmier', '2010-07-22', 5173, '0651906600', '27 MARCHES (Rue des)', 78971, 'Bobigny', 'HRYCDI@gmail.com', 3, 76),
(914, 'Kristine', 'Ngai', 'Personnel médical', 'Urologue', '2012-01-25', 5894, '0681345345', '17 HOUSSAYE (Cour la)', 91394, 'Malakoff', 'BNMFWH@gmail.com', 1, 69),
(915, 'Beatrice', 'Ralf', 'Personnel médical', 'Oncologue', '2012-04-28', 4384, '0658875000', '48 SAINTE (Rue)', 75311, 'Saint-Quentin en Yvelines', 'BJYLBV@wanadoo.fr', 1, 44),
(916, 'Ranald', 'Grover', 'Personnel médical', 'Ophtalmologue', '2016-09-25', 3128, '0629762141', '18 FONTAINE AU BONHOMME (Avenue de la)', 78333, 'Thiais', 'BJBQIL@wanadoo.fr', 1, 42),
(917, 'Fatima', 'Kourtney', 'Personnel médical', 'Ophtalmologue', '2011-12-05', 6346, '0632045644', '19 PINS (Allée des)', 92889, 'Sceaux', 'UHHZVD@gmail.com', 3, 41),
(918, 'Chad', 'Theodoric', 'Personnel médical', 'Urologue', '2015-11-17', 3123, '0660712410', '14 ARTOIS (Rue de l\')', 91458, 'Malakoff', 'IFHNAY@free.fr', 1, 69),
(919, 'Caden', 'Dominik', 'Personnel médical', 'Psychologue', '2018-02-17', 5696, '0633122169', '18 LAUNAY BRETON (Avenue de)', 94218, 'Orsay', 'PUKGAS@free.fr', 3, 50),
(920, 'Oleksander', 'Aatto', 'Personnel médical', 'Sage femme', '2010-02-22', 2864, '0669225370', '30 LANCETTE (Passage de la)', 75406, 'Versailles', 'EIHJLQ@wanadoo.fr', 1, 65),
(921, 'Thekla', 'Maha', 'Personnel médical', 'Chirurgien', '2013-05-12', 5693, '0689546693', '24 BEAULIEU (Rue de)', 75789, 'Robinson', 'DWSZLF@orange.fr', 3, 69),
(922, 'Hashim', 'Khadiga', 'Personnel médical', 'Oncologue', '2017-09-25', 3939, '0636593039', '12 CORBIERE (Rue Tristan)', 78174, 'Orsay', 'RSPUPZ@wanadoo.fr', 2, 44),
(923, 'Philippa', 'Artemisia', 'Personnel médical', 'Ophtalmologue', '2013-02-07', 5622, '0625486718', '42 BOULAIE (Chemin de la)', 94548, 'Rungis', 'AHGLJQ@gmail.com', 1, 41),
(924, 'Shiphrah', 'Eluned', 'Personnel médical', 'Ophtalmologue', '2018-03-13', 6995, '0630266334', '13 MYOSOTIS (Rue du)', 75383, 'Saint-cyr', 'NNGQZW@gmail.com', 1, 42),
(925, 'Vince', 'Tuija', 'Personnel médical', 'Aide soignant', '2010-09-17', 7763, '0611997739', '42 BERNARD (Rue Claude)', 78549, 'Puteaux', 'IZIHZM@gmail.com', 1, 77),
(926, 'Bailey', 'Greet', 'Personnel médical', 'Médecin', '2011-01-05', 2244, '0644791550', '21 TOULOUSE LAUTREC (Rue Henri de)', 75458, 'Arcueil', 'PNPXFF@wanadoo.fr', 1, 72),
(927, 'Herk', 'Bernadette', 'Personnel médical', 'Chirurgien', '2017-11-28', 7158, '0611409110', '44 BURON (Allée du)', 75897, 'Bobigny', 'OKVLCP@orange.fr', 1, 68),
(928, 'Boyd', 'Lanford', 'Personnel médical', 'Sage femme', '2018-11-22', 2721, '0694890165', '15 HOGUETTE (Avenue de la)', 91380, 'Versailles', 'EXXAXR@gmail.com', 2, 66),
(929, 'Gorka', 'Eideard', 'Personnel médical', 'Oncologue', '2010-12-02', 2296, '0696222393', '13 POREE (Boulevard)', 92470, 'Malakoff', 'PAHNWA@orange.fr', 1, 43),
(930, 'Delia', 'Fritjof', 'Personnel médical', 'Psychologue', '2017-09-08', 4489, '0686256935', '2 EGLISE  (Place de l\')', 92605, 'Neuilly', 'YSRHHZ@free.fr', 2, 50),
(931, 'Foka', 'Akeem', 'Personnel médical', 'Ophtalmologue', '2016-08-23', 1522, '0631483356', '27 MINIHIC (Rue du)', 95851, 'Villeneuve Saint-Georges', 'CZMVYS@wanadoo.fr', 2, 40),
(932, 'Sorcha', 'Peni', 'Personnel médical', 'Chirurgien', '2017-01-25', 2937, '0613142373', '46 IRIS (Rue des)', 91690, 'Neuilly', 'KCURBA@free.fr', 2, 69),
(933, 'Antony', 'Abegail', 'Personnel médical', 'Chirurgien', '2013-01-04', 7152, '0670559227', '20 SERRES (Impasse des)', 78283, 'Gometz-le-chatel', 'DFPPAU@gmail.com', 2, 69),
(934, 'Isabel', 'Venceslao', 'Personnel médical', 'Urologue', '2010-04-13', 3061, '0642808691', '21 IRIS (Rue des)', 95917, 'Gentilly', 'RLCXUF@orange.fr', 3, 69),
(935, 'Marla', 'Ward', 'Personnel médical', 'Médecin', '2015-02-01', 1414, '0632523148', '48 CHAPELLE (Rue de la)', 78478, 'Bourg-la-reine', 'TVCYMB@orange.fr', 1, 42),
(936, 'Merlin', 'Zak', 'Personnel médical', 'Médecin', '2010-04-03', 5561, '0633103487', '50 LEMARIE (Rue Henri)', 93322, 'Massy', 'XAYDFB@hotmail.fr', 1, 45),
(937, 'Esteve', 'Gerrard', 'Personnel médical', 'Aide soignant', '2019-09-01', 1634, '0643966911', '20 DESIRADE (Rue de la)', 78772, 'l\'Hay-les-roses', 'KJSWHX@hotmail.fr', 3, 65),
(938, 'Solvig', 'Nerissa', 'Personnel médical', 'Infirmier', '2016-10-14', 6057, '0697519998', '31 PERRIER (Boulevard)', 94772, 'Orsay', 'GCOWDM@orange.fr', 3, 65),
(939, 'Cináed', 'Rada', 'Personnel médical', 'Psychologue', '2015-09-11', 6934, '0688380298', '44 ANCIENS COMBATTANTS D\'AFRIQUE DU NORD', 95212, 'Sceaux', 'EDTZLU@free.fr', 3, 51),
(940, 'Laraine', 'Mykhaylo', 'Personnel médical', 'Médecin', '2019-11-02', 6113, '0696636976', '27 VILLES ALLIS (Rue des)', 93447, 'Gentilly', 'ZZJJUN@hotmail.fr', 2, 60),
(941, 'Glyn', 'Ruaidrí', 'Personnel médical', 'Sage femme', '2018-12-18', 2924, '0672217486', '33 EOLE (Impasse d\')', 92825, 'Antony', 'KCVDNZ@hotmail.fr', 1, 65),
(942, 'Confucius', 'Ofydd', 'Personnel médical', 'Psychologue', '2020-07-13', 4145, '0646173844', '3 SURCOUF (Rue Robert)', 95295, 'Gometz-le-chatel', 'CNHJJO@orange.fr', 3, 50),
(943, 'Melor', 'Suzie', 'Personnel médical', 'Médecin', '2016-01-17', 1983, '0652440183', '32 MINIHIC (Rue du)', 93571, 'Puteaux', 'ZRSBTO@gmail.com', 1, 76),
(944, 'Faunus', 'Lindsey', 'Personnel médical', 'Sage femme', '2019-07-14', 5241, '0681009888', '23 CONFIANCE (Rue de la)', 93788, 'Sceaux', 'IAPRQF@gmail.com', 1, 65),
(945, 'Dido', 'Ciaran', 'Personnel médical', 'Aide soignant', '2013-05-02', 2930, '0655874853', '36 TESSERIE (Avenue de la)', 75356, 'Orsay', 'SIWHXJ@wanadoo.fr', 3, 83),
(946, 'Benjamín', 'Merry', 'Personnel médical', 'Aide soignant', '2013-04-14', 4347, '0630994019', '9 EOLE (Impasse d\')', 91228, 'Massy', 'PZUVDD@hotmail.fr', 1, 46),
(947, 'Steen', 'Mateo', 'Personnel médical', 'Chirurgien', '2013-03-14', 4295, '0636784971', '14 NEPTUNE (Rue de)', 93724, 'Thiais', 'CHQQEZ@orange.fr', 1, 69),
(948, 'Shari', 'Fridtjof', 'Personnel médical', 'Oncologue', '2017-06-25', 3824, '0678494146', '44 DIXMUDE (Rue de)', 94730, 'Sceaux', 'GCNKEW@wanadoo.fr', 2, 45),
(949, 'Paulene', 'Alease', 'Personnel médical', 'Urologue', '2012-11-08', 3161, '0695670359', '41 ARGENTEUIL (Rue d\')', 94262, 'Boulogne-billancourt', 'AJDHCP@gmail.com', 2, 68),
(950, 'Ásdís', 'Amie', 'Personnel médical', 'Urologue', '2010-03-10', 3290, '0620653977', '41 BEAUSITE (Impasse)', 91967, 'Cachan', 'YQJFIJ@hotmail.fr', 1, 68),
(951, 'Rufino', 'Jaylin', 'Personnel médical', 'Urologue', '2010-03-17', 5169, '0630076900', '36 CHENES (Rue des)', 75446, 'Rungis', 'VOANNP@orange.fr', 1, 67),
(952, 'Tormod', 'Joost', 'Personnel médical', 'Infirmier', '2011-01-19', 7765, '0665473457', '32 POINTE DU CHRIST (allée de la)', 92579, 'Neuilly', 'WAUWNK@gmail.com', 3, 80),
(953, 'Ivanna', 'Gull', 'Personnel médical', 'Oncologue', '2014-03-07', 4581, '0630238140', '36 GASNIER DUPARC (Place)', 91724, 'Neuilly', 'SEGDGK@wanadoo.fr', 3, 44),
(954, 'Larisa', 'Otis', 'Personnel médical', 'Infirmier', '2011-11-08', 7077, '0670531672', '24 GRAND JARDIN (Impasse du)', 95966, 'Gometz-le-chatel', 'EUSYPQ@orange.fr', 2, 63),
(955, 'Melaina', 'Eddie', 'Personnel médical', 'Aide soignant', '2017-12-19', 6002, '0652089911', '11 COETQUEN (Rue du)', 95820, 'Massy', 'VXMIIC@orange.fr', 3, 69),
(956, 'Ffion', 'Timoteus', 'Personnel médical', 'Ophtalmologue', '2014-01-07', 5323, '0694192954', '26 CURAÇAO (Impasse du)', 75692, 'Vélizy', 'VGKJFB@hotmail.fr', 1, 42),
(957, 'Arcadia', 'Veera', 'Personnel médical', 'Chirurgien', '2011-09-04', 4423, '0684433226', '18 FUENTES (Avenue)', 75368, 'Antony', 'HSEXXZ@free.fr', 3, 67),
(958, 'Amadi', 'Tuvya', 'Personnel médical', 'Psychologue', '2016-04-26', 2565, '0686838320', '20 GOUAZON (Boulevard)', 95641, 'Bobigny', 'MRBOGR@free.fr', 3, 50),
(959, 'Morgan', 'Madeline', 'Personnel médical', 'Psychologue', '2011-02-11', 4681, '0663575324', '4 RENCONTRE (Allée de la)', 92714, 'Rungis', 'LPSTPQ@free.fr', 2, 50),
(960, 'Gry', 'Steenie', 'Personnel médical', 'Sage femme', '2014-04-16', 7739, '0682855406', '43 MOUETTES (Rue des)', 78280, 'Vanves', 'XSYVOH@gmail.com', 1, 64),
(961, 'Miranda', 'Tina', 'Personnel médical', 'Médecin', '2016-12-10', 1689, '0624449374', '20 TULIPES (Rue des)', 75157, 'Malakoff', 'BDIINN@hotmail.fr', 2, 71),
(962, 'Zusman', 'Zosimos', 'Personnel médical', 'Oncologue', '2017-06-02', 6270, '0650384366', '34 JONQUILLES (Rue des)', 91708, 'Bobigny', 'QFBVTI@wanadoo.fr', 2, 43),
(963, 'Wojciech', 'Fachtna', 'Personnel médical', 'Sage femme', '2012-12-12', 1472, '0697952187', '19 GRANDE MOINERIE (Rue de la)', 95908, 'Bourg-la-reine', 'GTEJEZ@hotmail.fr', 3, 66),
(964, 'Fikriyya', 'Herbert', 'Personnel médical', 'Ophtalmologue', '2011-01-06', 1118, '0630522941', '35 CANADA (Place du)', 75456, 'Montrouge', 'EGHBJC@hotmail.fr', 1, 42),
(965, 'Fryderyk', 'Pascuala', 'Personnel médical', 'Infirmier', '2017-03-17', 2721, '0653739282', '2 SAINT PIERRE ET MIQUELON (Avenue)', 93765, 'Garges-lès-gonesses', 'ANMEXB@wanadoo.fr', 3, 76),
(966, 'Jacqui', 'Kama', 'Personnel médical', 'Oncologue', '2018-11-10', 3346, '0696286086', '23 QUEBEC (Avenue de)', 75273, 'Antony', 'LDBOCQ@free.fr', 1, 44),
(967, 'Pearle', 'Reynaud', 'Personnel médical', 'Chirurgien', '2011-09-18', 1230, '0671131236', '25 CHAPELET (Rue Roger)', 95410, 'Montrouge', 'PEBMIQ@wanadoo.fr', 1, 68),
(968, 'Linford', 'Yaffa', 'Personnel médical', 'Infirmier', '2013-10-25', 1358, '0629568737', '40 CHASSE (Impasse Charles)', 78627, 'Vélizy', 'FQBQYD@free.fr', 1, 71),
(969, 'Przemo', 'Hedda', 'Personnel médical', 'Sage femme', '2020-07-24', 1625, '0693867757', '11 SEMILLANTE (Allée de la)', 91474, 'Cachan', 'QEQVLA@gmail.com', 2, 66),
(970, 'Cheryl', 'Damiano', 'Personnel médical', 'Chirurgien', '2015-03-14', 1787, '0653095392', '36 HARPE (Rue de la)', 94418, 'Saint-cyr', 'UEKGZD@wanadoo.fr', 2, 67),
(971, 'Sapphire', 'Mahavir', 'Personnel médical', 'Infirmier', '2010-10-15', 6874, '0657151896', '24 FREGATE (Allée de la)', 75543, 'Montrouge', 'HOEPWJ@hotmail.fr', 2, 52),
(972, 'Vilmar', 'Eleanor', 'Personnel médical', 'Sage femme', '2012-12-13', 7287, '0689065504', '31 BATELEURS (Rue des)', 78510, 'Sceaux', 'JRGYGG@hotmail.fr', 1, 66),
(973, 'Eduard', 'Madoline', 'Personnel médical', 'Psychologue', '2016-11-14', 2393, '0679132214', '9 JONGLEURS (Rue des)', 94876, 'Villeneuve Saint-Georges', 'CEFBKP@free.fr', 1, 49),
(974, 'Hammond', 'Lan', 'Personnel médical', 'Chirurgien', '2015-03-22', 1613, '0692092950', '8 BAZILLE (Rue Frédéric)', 95374, 'Garges-lès-gonesses', 'LBILSQ@gmail.com', 3, 67),
(975, 'Sunshine', 'Miksa', 'Personnel médical', 'Urologue', '2020-08-06', 7150, '0686196719', '47 TERTRE VERRINE (Rue du)', 91735, 'Malakoff', 'EABYAY@free.fr', 1, 67),
(976, 'Ömer', 'Ronald', 'Personnel médical', 'Médecin', '2020-09-03', 2374, '0686699864', '9 PETITE BARONNIE (Chemin de la)', 78471, 'Villeneuve Saint-Georges', 'BSUKUG@hotmail.fr', 2, 65),
(977, 'Eoforhild', 'Genoveffa', 'Personnel médical', 'Ophtalmologue', '2019-02-05', 1466, '0612371534', '9 COUDRIERS (Rue des)', 78829, 'Bourg-la-reine', 'YQKFMF@hotmail.fr', 2, 40),
(978, 'Sarai', 'Reggie', 'Personnel médical', 'Médecin', '2011-03-11', 1971, '0677591798', '21 CYTISES (Impasse des)', 93282, 'Saint-cyr', 'LXJWSB@gmail.com', 2, 64),
(979, 'Éadaoin', 'Baal', 'Personnel médical', 'Urologue', '2012-07-09', 4549, '0640935168', '47 NORMANDS (Impasse des)', 75767, 'Antony', 'ITTSZW@wanadoo.fr', 2, 67),
(980, 'Sophie', 'Carlton', 'Personnel médical', 'Psychologue', '2012-10-20', 3085, '0614486424', '26 CORDIERS (Rue des)', 78458, 'Arcueil', 'NQOVJA@orange.fr', 1, 51),
(981, 'Spiros', 'Sylvana', 'Personnel médical', 'Psychologue', '2012-07-22', 7841, '0617288946', '9 ACACIAS (Rue des)', 93655, 'Puteaux', 'DQETAW@wanadoo.fr', 3, 51),
(982, 'Sancho', 'Christophe', 'Personnel médical', 'Chirurgien', '2020-09-24', 7359, '0678574976', '49 HUGO (Avenue Victor)', 94753, 'Arcueil', 'FDQFDP@orange.fr', 3, 68),
(983, 'Joab', 'Jaumet', 'Personnel médical', 'Sage femme', '2016-01-09', 2627, '0621351582', '27 SAULAIE  (Rue de la)', 75567, 'Montrouge', 'SOIKIW@hotmail.fr', 1, 64),
(984, 'Narcisse', 'Iqbal', 'Personnel médical', 'Infirmier', '2010-07-22', 5173, '0651906600', '27 MARCHES (Rue des)', 78971, 'Bobigny', 'HRYCDI@gmail.com', 3, 76),
(985, 'Kristine', 'Ngai', 'Personnel médical', 'Urologue', '2012-01-25', 5894, '0681345345', '17 HOUSSAYE (Cour la)', 91394, 'Malakoff', 'BNMFWH@gmail.com', 1, 69),
(986, 'Beatrice', 'Ralf', 'Personnel médical', 'Oncologue', '2012-04-28', 4384, '0658875000', '48 SAINTE (Rue)', 75311, 'Saint-Quentin en Yvelines', 'BJYLBV@wanadoo.fr', 1, 44),
(987, 'Ranald', 'Grover', 'Personnel médical', 'Ophtalmologue', '2016-09-25', 3128, '0629762141', '18 FONTAINE AU BONHOMME (Avenue de la)', 78333, 'Thiais', 'BJBQIL@wanadoo.fr', 1, 42),
(988, 'Fatima', 'Kourtney', 'Personnel médical', 'Ophtalmologue', '2011-12-05', 6346, '0632045644', '19 PINS (Allée des)', 92889, 'Sceaux', 'UHHZVD@gmail.com', 3, 41),
(989, 'Chad', 'Theodoric', 'Personnel médical', 'Urologue', '2015-11-17', 3123, '0660712410', '14 ARTOIS (Rue de l\')', 91458, 'Malakoff', 'IFHNAY@free.fr', 1, 69),
(990, 'Caden', 'Dominik', 'Personnel médical', 'Psychologue', '2018-02-17', 5696, '0633122169', '18 LAUNAY BRETON (Avenue de)', 94218, 'Orsay', 'PUKGAS@free.fr', 3, 50),
(991, 'Oleksander', 'Aatto', 'Personnel médical', 'Sage femme', '2010-02-22', 2864, '0669225370', '30 LANCETTE (Passage de la)', 75406, 'Versailles', 'EIHJLQ@wanadoo.fr', 1, 65),
(992, 'Thekla', 'Maha', 'Personnel médical', 'Chirurgien', '2013-05-12', 5693, '0689546693', '24 BEAULIEU (Rue de)', 75789, 'Robinson', 'DWSZLF@orange.fr', 3, 69),
(993, 'Hashim', 'Khadiga', 'Personnel médical', 'Oncologue', '2017-09-25', 3939, '0636593039', '12 CORBIERE (Rue Tristan)', 78174, 'Orsay', 'RSPUPZ@wanadoo.fr', 2, 44),
(994, 'Philippa', 'Artemisia', 'Personnel médical', 'Ophtalmologue', '2013-02-07', 5622, '0625486718', '42 BOULAIE (Chemin de la)', 94548, 'Rungis', 'AHGLJQ@gmail.com', 1, 41),
(995, 'Shiphrah', 'Eluned', 'Personnel médical', 'Ophtalmologue', '2018-03-13', 6995, '0630266334', '13 MYOSOTIS (Rue du)', 75383, 'Saint-cyr', 'NNGQZW@gmail.com', 1, 42),
(996, 'Vince', 'Tuija', 'Personnel médical', 'Aide soignant', '2010-09-17', 7763, '0611997739', '42 BERNARD (Rue Claude)', 78549, 'Puteaux', 'IZIHZM@gmail.com', 1, 77),
(997, 'Bailey', 'Greet', 'Personnel médical', 'Médecin', '2011-01-05', 2244, '0644791550', '21 TOULOUSE LAUTREC (Rue Henri de)', 75458, 'Arcueil', 'PNPXFF@wanadoo.fr', 1, 72),
(998, 'Herk', 'Bernadette', 'Personnel médical', 'Chirurgien', '2017-11-28', 7158, '0611409110', '44 BURON (Allée du)', 75897, 'Bobigny', 'OKVLCP@orange.fr', 1, 68),
(999, 'Boyd', 'Lanford', 'Personnel médical', 'Sage femme', '2018-11-22', 2721, '0694890165', '15 HOGUETTE (Avenue de la)', 91380, 'Versailles', 'EXXAXR@gmail.com', 2, 66),
(1000, 'Gorka', 'Eideard', 'Personnel médical', 'Oncologue', '2010-12-02', 2296, '0696222393', '13 POREE (Boulevard)', 92470, 'Malakoff', 'PAHNWA@orange.fr', 1, 43),
(1001, 'Delia', 'Fritjof', 'Personnel médical', 'Psychologue', '2017-09-08', 4489, '0686256935', '2 EGLISE  (Place de l\')', 92605, 'Neuilly', 'YSRHHZ@free.fr', 2, 50),
(1002, 'Foka', 'Akeem', 'Personnel médical', 'Ophtalmologue', '2016-08-23', 1522, '0631483356', '27 MINIHIC (Rue du)', 95851, 'Villeneuve Saint-Georges', 'CZMVYS@wanadoo.fr', 2, 40),
(1003, 'Sorcha', 'Peni', 'Personnel médical', 'Chirurgien', '2017-01-25', 2937, '0613142373', '46 IRIS (Rue des)', 91690, 'Neuilly', 'KCURBA@free.fr', 2, 69),
(1004, 'Antony', 'Abegail', 'Personnel médical', 'Chirurgien', '2013-01-04', 7152, '0670559227', '20 SERRES (Impasse des)', 78283, 'Gometz-le-chatel', 'DFPPAU@gmail.com', 2, 69),
(1005, 'Isabel', 'Venceslao', 'Personnel médical', 'Urologue', '2010-04-13', 3061, '0642808691', '21 IRIS (Rue des)', 95917, 'Gentilly', 'RLCXUF@orange.fr', 3, 69),
(1006, 'Marla', 'Ward', 'Personnel médical', 'Médecin', '2015-02-01', 1414, '0632523148', '48 CHAPELLE (Rue de la)', 78478, 'Bourg-la-reine', 'TVCYMB@orange.fr', 1, 42),
(1007, 'Merlin', 'Zak', 'Personnel médical', 'Médecin', '2010-04-03', 5561, '0633103487', '50 LEMARIE (Rue Henri)', 93322, 'Massy', 'XAYDFB@hotmail.fr', 1, 45),
(1008, 'Esteve', 'Gerrard', 'Personnel médical', 'Aide soignant', '2019-09-01', 1634, '0643966911', '20 DESIRADE (Rue de la)', 78772, 'l\'Hay-les-roses', 'KJSWHX@hotmail.fr', 3, 65),
(1009, 'Solvig', 'Nerissa', 'Personnel médical', 'Infirmier', '2016-10-14', 6057, '0697519998', '31 PERRIER (Boulevard)', 94772, 'Orsay', 'GCOWDM@orange.fr', 3, 65),
(1010, 'Cináed', 'Rada', 'Personnel médical', 'Psychologue', '2015-09-11', 6934, '0688380298', '44 ANCIENS COMBATTANTS D\'AFRIQUE DU NORD', 95212, 'Sceaux', 'EDTZLU@free.fr', 3, 51),
(1011, 'Laraine', 'Mykhaylo', 'Personnel médical', 'Médecin', '2019-11-02', 6113, '0696636976', '27 VILLES ALLIS (Rue des)', 93447, 'Gentilly', 'ZZJJUN@hotmail.fr', 2, 60),
(1012, 'Glyn', 'Ruaidrí', 'Personnel médical', 'Sage femme', '2018-12-18', 2924, '0672217486', '33 EOLE (Impasse d\')', 92825, 'Antony', 'KCVDNZ@hotmail.fr', 1, 65),
(1013, 'Confucius', 'Ofydd', 'Personnel médical', 'Psychologue', '2020-07-13', 4145, '0646173844', '3 SURCOUF (Rue Robert)', 95295, 'Gometz-le-chatel', 'CNHJJO@orange.fr', 3, 50),
(1014, 'Melor', 'Suzie', 'Personnel médical', 'Médecin', '2016-01-17', 1983, '0652440183', '32 MINIHIC (Rue du)', 93571, 'Puteaux', 'ZRSBTO@gmail.com', 1, 76),
(1015, 'Faunus', 'Lindsey', 'Personnel médical', 'Sage femme', '2019-07-14', 5241, '0681009888', '23 CONFIANCE (Rue de la)', 93788, 'Sceaux', 'IAPRQF@gmail.com', 1, 65),
(1016, 'Dido', 'Ciaran', 'Personnel médical', 'Aide soignant', '2013-05-02', 2930, '0655874853', '36 TESSERIE (Avenue de la)', 75356, 'Orsay', 'SIWHXJ@wanadoo.fr', 3, 83),
(1017, 'Benjamín', 'Merry', 'Personnel médical', 'Aide soignant', '2013-04-14', 4347, '0630994019', '9 EOLE (Impasse d\')', 91228, 'Massy', 'PZUVDD@hotmail.fr', 1, 46),
(1018, 'Steen', 'Mateo', 'Personnel médical', 'Chirurgien', '2013-03-14', 4295, '0636784971', '14 NEPTUNE (Rue de)', 93724, 'Thiais', 'CHQQEZ@orange.fr', 1, 69),
(1019, 'Shari', 'Fridtjof', 'Personnel médical', 'Oncologue', '2017-06-25', 3824, '0678494146', '44 DIXMUDE (Rue de)', 94730, 'Sceaux', 'GCNKEW@wanadoo.fr', 2, 45),
(1020, 'Paulene', 'Alease', 'Personnel médical', 'Urologue', '2012-11-08', 3161, '0695670359', '41 ARGENTEUIL (Rue d\')', 94262, 'Boulogne-billancourt', 'AJDHCP@gmail.com', 2, 68),
(1021, 'Ásdís', 'Amie', 'Personnel médical', 'Urologue', '2010-03-10', 3290, '0620653977', '41 BEAUSITE (Impasse)', 91967, 'Cachan', 'YQJFIJ@hotmail.fr', 1, 68),
(1022, 'Rufino', 'Jaylin', 'Personnel médical', 'Urologue', '2010-03-17', 5169, '0630076900', '36 CHENES (Rue des)', 75446, 'Rungis', 'VOANNP@orange.fr', 1, 67),
(1023, 'Tormod', 'Joost', 'Personnel médical', 'Infirmier', '2011-01-19', 7765, '0665473457', '32 POINTE DU CHRIST (allée de la)', 92579, 'Neuilly', 'WAUWNK@gmail.com', 3, 80),
(1024, 'Ivanna', 'Gull', 'Personnel médical', 'Oncologue', '2014-03-07', 4581, '0630238140', '36 GASNIER DUPARC (Place)', 91724, 'Neuilly', 'SEGDGK@wanadoo.fr', 3, 44),
(1025, 'Larisa', 'Otis', 'Personnel médical', 'Infirmier', '2011-11-08', 7077, '0670531672', '24 GRAND JARDIN (Impasse du)', 95966, 'Gometz-le-chatel', 'EUSYPQ@orange.fr', 2, 63),
(1026, 'Ajith', 'Noelle', 'Personnel de nettoyage', 'Personnel d\'entretien', '2015-10-13', 2227, '0648522392', '24 GAUGUIN (Rue Paul)', 91816, 'Saint-denis', 'KYJVLM@wanadoo.fr', 2, NULL),
(1027, 'Eris', 'Serenity', 'Personnel de nettoyage', 'Personnel d\'entretien', '2015-12-20', 2824, '0667263256', '44 HESRY (Rue Jacques)', 92693, 'Antony', 'GELSYJ@wanadoo.fr', 2, NULL),
(1028, 'Guilherme', 'Conchobhar', 'Personnel administratif', 'Secrétaire', '2019-01-11', 3166, '0612423064', '23 CLOS DE MATIGNON (Allée du)', 78715, 'Bourg-la-reine', 'TQKBWB@wanadoo.fr', 1, NULL),
(1029, 'Euthymius', 'Sapphira', 'Personnel administratif', 'Responsable ressources humaines', '2019-03-20', 7220, '0626920924', '14 BROCHET (Impasse du )', 91692, 'Bobigny', 'XLXRTI@free.fr', 3, NULL),
(1030, 'Coralie', 'Sunitha', 'Personnel administratif', 'Secrétaire', '2013-12-09', 6297, '0679042319', '33 BASSE FLOURIE (Chemin de la)', 94739, 'Versailles', 'OMMCSC@free.fr', 2, NULL),
(1031, 'Eniola', 'Plamen', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2010-01-13', 6138, '0668587194', '34 GUIMORAIS (Avenue de la)', 92160, 'Robinson', 'HKDDJE@hotmail.fr', 2, NULL),
(1032, 'Honey', 'Claus', 'Personnel administratif', 'Responsable ressources humaines', '2010-04-03', 3311, '0696447572', '34 TOUR DU BONHEUR (Rue de la)', 94990, 'Rungis', 'UHMSTZ@orange.fr', 2, NULL),
(1033, 'Joona', 'Romano', 'Personnel de nettoyage', 'Personnel d\'entretien', '2013-09-09', 7467, '0614005761', '25 LEONORE (Impasse de la)', 75582, 'Orsay', 'LYLOMW@orange.fr', 1, NULL),
(1034, 'Alcyone', 'Gwyneth', 'Personnel administratif', 'Responsable ressources humaines', '2010-09-15', 6207, '0636183822', '23 BONNET FLAMAND (Rue du)', 91602, 'Vélizy', 'PFEWPK@hotmail.fr', 3, NULL),
(1035, 'Anne', 'Yusra', 'Personnel administratif', 'Directeur', '2018-01-18', 5518, '0694762777', '24 BOURNAZEL (Avenue de)', 92489, 'Garges-lès-gonesses', 'VDGATE@orange.fr', 1, NULL),
(1036, 'Tristen', 'Fitz', 'Personnel de nettoyage', 'Personnel d\'entretien', '2017-04-12', 1648, '0648001708', '21 BEAULIEU (Impasse du Tertre de)', 92764, 'Vélizy', 'ABHBVF@hotmail.fr', 1, NULL),
(1037, 'Aaren', 'Aatami', 'Personnel administratif', 'Responsable ressources humaines', '2012-11-10', 4317, '0668691907', '8 PARENTHOINE (Rue Alfred)', 94858, 'Robinson', 'AAXAMC@hotmail.fr', 1, NULL),
(1038, 'Gormlaith', 'Erykah', 'Personnel administratif', 'Directeur', '2012-05-24', 1811, '0612840150', '45 GRANDE ANGUILLE (Rue de la)', 94655, 'Garges-lès-gonesses', 'LKSRVV@free.fr', 1, NULL),
(1039, 'Nolene', 'Naomhán', 'Personnel administratif', 'Directeur', '2018-02-21', 6090, '0678794407', '17 CORBIERES (Impasse des)', 78513, 'Sceaux', 'GCOKZU@free.fr', 3, NULL),
(1040, 'Bedros', 'Seòsaidh', 'Personnel administratif', 'Directeur', '2017-01-08', 5776, '0688722977', '39 DE TRIQUERVILLE (Rue J.P.)', 78429, 'Bobigny', 'MDNMMN@gmail.com', 3, NULL),
(1041, 'Vishnu', 'Mu', 'Personnel administratif', 'Secrétaire', '2013-11-18', 3237, '0696831918', '26 ETRILLES (Rue des)', 95149, 'Gentilly', 'GWBXQS@hotmail.fr', 1, NULL),
(1042, 'Shakuntala', 'Trahaearn', 'Personnel de nettoyage', 'Personnel d\'entretien', '2019-02-20', 5666, '0646198999', '25 SAFFRAY (Rue Jules)', 94204, 'Saint-cyr', 'UVCYEP@gmail.com', 2, NULL),
(1043, 'Leia', 'Ili', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2019-12-18', 4715, '0611347428', '16 ANCIENS COMBATTANTS (R.P.)', 94925, 'Villeneuve Saint-Georges', 'TKOTGA@orange.fr', 1, NULL),
(1044, 'Mansoor', 'Diamond', 'Personnel administratif', 'Directeur', '2015-02-17', 7802, '0695023737', '17 NAYE (Fort du)', 94975, 'Cachan', 'TOFJTO@hotmail.fr', 3, NULL),
(1045, 'Dumitru', 'Ragnhildur', 'Personnel administratif', 'Directeur', '2018-05-06', 4658, '0683882191', '9 VERON (Paul) et ACPG (Rond Point)', 94679, 'Malakoff', 'HSFRDT@free.fr', 2, NULL),
(1046, 'Petrina', 'Wallis', 'Personnel administratif', 'Secrétaire', '2019-05-06', 2195, '0688200343', '22 VIGUIER (Rue)', 93295, 'Massy', 'QNMIVK@wanadoo.fr', 1, NULL),
(1047, 'Mat', 'Vulcan', 'Personnel de nettoyage', 'Personnel d\'entretien', '2011-01-17', 5480, '0677711185', '46 MAINE (Rue du)', 75693, 'Vélizy', 'FUDKKZ@free.fr', 2, NULL),
(1048, 'Peyton', 'Fortunato', 'Personnel de nettoyage', 'Personnel de nettoyage', '2015-09-26', 4888, '0668382897', '3 BIR HAKEIM (Impasse)', 94450, 'Gentilly', 'UCEWSM@wanadoo.fr', 3, NULL),
(1049, 'Yale', 'Nanook', 'Personnel de nettoyage', 'Personnel d\'entretien', '2015-06-13', 4303, '0631370532', '25 DESCARTES (Rue)', 95446, 'Thiais', 'FJLPJR@gmail.com', 2, NULL),
(1050, 'Shiloh', 'Avis', 'Personnel de nettoyage', 'Personnel de nettoyage', '2012-09-21', 6612, '0619668455', '20 OLLIVRAULT (Impasse)', 93820, 'Thiais', 'KPWTXJ@orange.fr', 3, NULL),
(1051, 'Hákan', 'Deepak', 'Personnel de nettoyage', 'Personnel de nettoyage', '2016-11-08', 5211, '0694352511', '50 DUGUESCLIN (Avenue)', 95849, 'Arcueil', 'YEWSSR@gmail.com', 1, NULL),
(1052, 'Hamza', 'Yahveh', 'Personnel administratif', 'Directeur', '2020-02-02', 7985, '0676916895', '25 VILLE COLLET (Cour)', 92335, 'Asnières', 'YETHOJ@hotmail.fr', 3, NULL),
(1053, 'Elain', 'Kamryn', 'Personnel de nettoyage', 'Personnel de nettoyage', '2020-12-05', 6397, '0676985964', '37 NOGUES (Impasse Maurice)', 91642, 'Vélizy', 'EYWUKJ@free.fr', 2, NULL),
(1054, 'Meaveen', 'Rune', 'Personnel administratif', 'Secrétaire', '2011-09-20', 7792, '0647850365', '45 BRISELAINE (Rue de)', 94901, 'Vanves', 'QUHBCW@orange.fr', 3, NULL),
(1055, 'Mokosh', 'Encarnacion', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2018-10-27', 7423, '0671401924', '39 HEMAR (Rue Victor)', 91258, 'Massy', 'URJIZD@hotmail.fr', 2, NULL),
(1056, 'Þórr', 'Agrona', 'Personnel administratif', 'Secrétaire', '2016-03-28', 3800, '0633221335', '32 LEFORESTIER (Rue René)', 95673, 'Bourg-la-reine', 'NCXFOH@gmail.com', 2, NULL),
(1057, 'Lucia', 'Thalia', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2017-05-20', 5421, '0690105092', '20 ARGONAUTES (Rue des)', 93156, 'Saint-cyr', 'KSEQVH@orange.fr', 2, NULL),
(1058, 'Star', 'Treasa', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2017-02-11', 2013, '0625204258', '42 TERTRE (Impasse du)', 78264, 'Vanves', 'ZKRFCH@orange.fr', 2, NULL),
(1059, 'Eallair', 'Tye', 'Personnel administratif', 'Responsable ressources humaines', '2020-12-21', 3414, '0666367273', '9 LA CHAMBRE (Rue Charles)', 78493, 'Villeneuve Saint-Georges', 'AELTNO@gmail.com', 1, NULL),
(1060, 'Liesa', 'Servius', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2017-12-15', 1426, '0678171318', '4 BEAUSITE (Impasse)', 94910, 'Bobigny', 'NZVEQE@free.fr', 2, NULL),
(1061, 'Ekaterina', 'Nadir', 'Personnel de nettoyage', 'Personnel de nettoyage', '2020-09-26', 2481, '0653454964', '22 DOUTRELEAU (Rue)', 95807, 'Boulogne-billancourt', 'MCXJQF@wanadoo.fr', 2, NULL),
(1062, 'Erica', 'Patricia', 'Personnel de nettoyage', 'Personnel d\'entretien', '2018-04-26', 5448, '0623769320', '38 ANCIENS COMBATTANTS D\'AFRIQUE DU NORD', 91144, 'l\'Hay-les-roses', 'JNTZMM@orange.fr', 3, NULL),
(1063, 'Milburn', 'Maria', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2019-03-13', 4102, '0664797629', '16 ANEMONES(rue des)', 94472, 'Rungis', 'WVQNIH@orange.fr', 3, NULL),
(1064, 'Friedhold', 'Cambria', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2013-09-12', 7819, '0629602849', '40 SOUVESTRE (Impasse Emile)', 94979, 'Montrouge', 'EKEVKK@free.fr', 3, NULL),
(1065, 'Laxmi', 'Alix', 'Personnel de nettoyage', 'Personnel de nettoyage', '2014-11-24', 3695, '0675503070', '14 SERVANNAIS (Terre Plein des)', 78348, 'Gentilly', 'CSYWHY@wanadoo.fr', 3, NULL),
(1066, 'Berthold', 'Örjan', 'Personnel de nettoyage', 'Personnel de nettoyage', '2010-05-28', 5800, '0628817118', '31 DEMALVILAIN (Boulevard Léonce)', 95541, 'Boulogne-billancourt', 'GVTFBQ@free.fr', 1, NULL),
(1067, 'Andreja', 'Savanna', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2020-03-14', 7505, '0622452585', '44 ORME (Rue de l\')', 93154, 'Saint-Quentin en Yvelines', 'VOBFEQ@orange.fr', 3, NULL),
(1068, 'Léopold', 'Metin', 'Personnel de nettoyage', 'Personnel de nettoyage', '2014-05-03', 7611, '0657537749', '50 MOUETTES (Rue des)', 94364, 'Robinson', 'DDEILY@hotmail.fr', 2, NULL),
(1069, 'Mars', 'Firmin', 'Personnel de nettoyage', 'Personnel de nettoyage', '2010-07-05', 2158, '0649721641', '27 ETOUPE (Rue de l\')', 92744, 'Arcueil', 'ZXQAJS@hotmail.fr', 3, NULL),
(1070, 'Janan', 'Amos', 'Personnel administratif', 'Directeur', '2019-10-11', 3546, '0635014138', '48 SAINT IDEUC (Rue de)', 91141, 'Vélizy', 'TKIARK@gmail.com', 1, NULL),
(1071, 'Temujin', 'Maddalena', 'Personnel administratif', 'Secrétaire', '2013-03-20', 7820, '0664613705', '3 MENESTRELS (Rue des)', 78230, 'Vélizy', 'MGJIXN@wanadoo.fr', 3, NULL),
(1072, 'Álvaro', 'Tzofiya', 'Personnel de nettoyage', 'Personnel de nettoyage', '2020-12-16', 2690, '0624711950', '34 CAP (Enclos du)', 75361, 'Montrouge', 'ETGZLM@gmail.com', 3, NULL),
(1073, 'Lonnie', 'Osborn', 'Personnel administratif', 'Directeur', '2019-08-12', 1458, '0659745084', '16 NATION (Rue de la)', 94235, 'Montrouge', 'FDFCNH@free.fr', 3, NULL),
(1074, 'Kelia', 'Olumide', 'Personnel administratif', 'Secrétaire', '2016-01-19', 5331, '0612985476', '28 GOELETRIE (Rue de la)', 94979, 'Arcueil', 'HUAHSX@free.fr', 2, NULL),
(1075, 'Antero', 'Myriam', 'Personnel de nettoyage', 'Personnel de nettoyage', '2018-06-11', 3241, '0648811036', '18 HOUSSAYE (Cour la)', 93462, 'Vélizy', 'IPYCYS@hotmail.fr', 1, NULL),
(1076, 'Annikki', 'Kiera', 'Personnel de nettoyage', 'Personnel de nettoyage', '2019-12-04', 6333, '0696267405', '12 CHASSE (Impasse Charles)', 95581, 'Bobigny', 'HJWRZF@gmail.com', 1, NULL),
(1077, 'Sophronius', 'Anahita', 'Personnel de nettoyage', 'Personnel de nettoyage', '2014-03-04', 2350, '0667765122', '27 PETIT PARAMÉ (Rue du)', 92510, 'Bourg-la-reine', 'GWRDWN@gmail.com', 2, NULL),
(1078, 'Süleyman', 'Marwa', 'Personnel de nettoyage', 'Personnel de nettoyage', '2018-12-19', 2671, '0637424349', '37 QUEBEC (Place du)', 91315, 'Paris', 'GFAWFW@gmail.com', 1, NULL),
(1079, 'Carl', 'Renée', 'Personnel administratif', 'Directeur', '2020-10-26', 2297, '0636466276', '37 CORNE DE CERF (Rue de la)', 93934, 'Gentilly', 'GKEKDV@gmail.com', 3, NULL),
(1080, 'Eli', 'Anasztázia', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2017-01-24', 2439, '0673087409', '34 CLOS VERT (Rue du)', 75400, 'Asnières', 'SPNLVH@hotmail.fr', 3, NULL),
(1081, 'Debbi', 'Paise', 'Personnel de nettoyage', 'Personnel de nettoyage', '2017-12-21', 7577, '0674887464', '17 PETITS DEGRES (Rue des)', 78673, 'Robinson', 'IWFAHY@orange.fr', 2, NULL),
(1082, 'Kazuko', 'Nereida', 'Personnel de nettoyage', 'Personnel de nettoyage', '2020-12-16', 5266, '0635773977', '30 PETIT PARAMÉ (Place du)', 92151, 'Sceaux', 'BVPIIT@free.fr', 2, NULL),
(1083, 'Emiliana', 'Mikhail', 'Personnel de nettoyage', 'Personnel de nettoyage', '2012-11-01', 6551, '0693336332', '36 PRIEURE SAINT-DOMIN (Rue du)', 92361, 'Saint-denis', 'ZGNOFN@orange.fr', 3, NULL),
(1084, 'Daithí', 'Sophie', 'Personnel administratif', 'Secrétaire', '2018-03-01', 1562, '0670868958', '35 SAINT MICHEL (Avenue)', 93655, 'Vanves', 'EERCDT@hotmail.fr', 3, NULL),
(1085, 'Tadej', 'Lysandra', 'Personnel de nettoyage', 'Personnel de nettoyage', '2016-01-23', 5752, '0623694002', '13 CROIX DU FIEF (Place de la)', 95470, 'Saint-Quentin en Yvelines', 'XWOJDZ@hotmail.fr', 2, NULL),
(1086, 'Manuel', 'Estachio', 'Personnel de nettoyage', 'Personnel de nettoyage', '2020-09-24', 2166, '0695982978', '47 CORMORANS (Impasse des)', 91587, 'Thiais', 'OFWVJF@gmail.com', 3, NULL),
(1087, 'Olavi', 'Merry', 'Personnel administratif', 'Responsable ressources humaines', '2011-11-01', 4970, '0610148502', '30 LE TURC (Rue)', 91297, 'Vélizy', 'YZJNXT@free.fr', 3, NULL),
(1088, 'Ciril', 'Purdie', 'Personnel de nettoyage', 'Personnel de nettoyage', '2018-06-12', 5570, '0647699301', '23 DIXMUDE (Rue de)', 95536, 'Antony', 'VMLZGL@wanadoo.fr', 3, NULL),
(1089, 'Vesa', 'Noémie', 'Personnel administratif', 'Directeur', '2019-12-02', 1731, '0635762699', '15 SALINES (Rue des)', 91456, 'Garges-lès-gonesses', 'FTTUOT@free.fr', 3, NULL),
(1090, 'Trini', 'Ikaika', 'Personnel administratif', 'Secrétaire', '2018-06-16', 4268, '0647892413', '49 GRAND VERGER (Rue du)', 95946, 'Versailles', 'DPQMRC@wanadoo.fr', 2, NULL),
(1091, 'Fernand', 'Bryanna', 'Personnel de nettoyage', 'Personnel d\'entretien', '2020-04-04', 7876, '0617123116', '46 CONNETABLE (Rue du)', 91888, 'Garges-lès-gonesses', 'AKMXRC@wanadoo.fr', 3, NULL),
(1092, 'Finn', 'Terrell', 'Personnel administratif', 'Secrétaire', '2018-07-17', 2890, '0650308579', '17 GAUGUIN (Rue Paul)', 92207, 'Montrouge', 'HISWFJ@orange.fr', 1, NULL),
(1093, 'Mahmood', 'Atarah', 'Personnel de nettoyage', 'Personnel de nettoyage', '2013-03-22', 3138, '0659787308', '33 MARSOUIN (Impasse du)', 75583, 'Vanves', 'XCRHYA@orange.fr', 1, NULL),
(1094, 'Bhaskar', 'Carlito', 'Personnel administratif', 'Secrétaire', '2011-06-25', 3950, '0625028208', '16 VICTOIRE (Rue de la)', 75700, 'Boulogne-billancourt', 'BILFFE@orange.fr', 3, NULL),
(1095, 'Hortensia', 'Artturi', 'Personnel de nettoyage', 'Personnel d\'entretien', '2017-12-20', 7518, '0637377753', '45 DELASTELLE (Impasse)', 91458, 'Malakoff', 'LLVHFB@free.fr', 2, NULL),
(1096, 'Ern', 'Lommán', 'Personnel de nettoyage', 'Personnel de nettoyage', '2018-04-19', 4008, '0697891559', '45 FONTAINE AUX PELERINS (Rue de la)', 92611, 'Sceaux', 'DRUTQO@hotmail.fr', 2, NULL),
(1097, 'Luitgard', 'Alphonzo', 'Personnel de nettoyage', 'Personnel d\'entretien', '2016-05-04', 2314, '0610110205', '43 TROIS MATS (Impasse des)', 78125, 'Gentilly', 'MJVNKP@orange.fr', 3, NULL),
(1098, 'Boghos', 'Fredrik', 'Personnel administratif', 'Responsable ressources humaines', '2012-03-26', 5265, '0671765049', '22 COCHET (Rue Jean-Marie)', 94595, 'Saint-cyr', 'SKGSDI@free.fr', 2, NULL),
(1099, 'Ilker', 'Frannie', 'Personnel administratif', 'Responsable ressources humaines', '2014-01-07', 7500, '0633734360', '7 EPHYRA (Allée)', 91183, 'Gometz-le-chatel', 'OHXPUY@wanadoo.fr', 2, NULL),
(1100, 'Kaiser', 'Giovanna', 'Personnel administratif', 'Secrétaire', '2012-02-17', 1841, '0629634035', '36 GRAND JARDIN (Impasse du)', 95408, 'Garges-lès-gonesses', 'KVZCCS@gmail.com', 1, NULL),
(1101, 'Matrona', 'Pat', 'Personnel de nettoyage', 'Personnel de nettoyage', '2015-12-18', 5812, '0639937776', '14 BELETTES (Rue des)', 95387, 'Vanves', 'XFTWDW@gmail.com', 2, NULL),
(1102, 'Kiyoko', 'Ashleigh', 'Personnel de nettoyage', 'Personnel de nettoyage', '2017-07-15', 2725, '0651615968', '19 CAPITAINE LESCOT (Impasse)', 95838, 'Bobigny', 'LYPDVE@orange.fr', 1, NULL),
(1103, 'Ríghnach', 'Gershon', 'Personnel de nettoyage', 'Personnel de nettoyage', '2020-08-23', 2030, '0651545074', '11 POINT DU JOUR (Rue du)', 78405, 'Saint-denis', 'VYHZYE@wanadoo.fr', 2, NULL),
(1104, 'Zdenek', 'Shayla', 'Personnel de nettoyage', 'Personnel d\'entretien', '2011-08-13', 1311, '0611861386', '24 ALET (Rue d\')', 75931, 'Neuilly', 'TDMABN@wanadoo.fr', 2, NULL),
(1105, 'Boyce', 'Cilka', 'Personnel administratif', 'Directeur', '2019-11-08', 5542, '0632676009', '45 MOULIN DE LA MOTTE (Impasse du)', 94501, 'Malakoff', 'LBXRSE@wanadoo.fr', 3, NULL),
(1106, 'Joshua', 'Régis', 'Personnel administratif', 'Secrétaire', '2020-09-20', 5405, '0668504825', '23 CHANOINE E. LAINE (Rue du)', 94343, 'Villeneuve Saint-Georges', 'XMCXKG@gmail.com', 2, NULL),
(1107, 'Eluned', 'Kreszentia', 'Personnel de nettoyage', 'Personnel de nettoyage', '2012-03-25', 6457, '0619787714', '4 GARDELLE (Rue de la)', 92145, 'Arcueil', 'TYUBEH@hotmail.fr', 3, NULL),
(1108, 'Gwladus', 'Heliodoro', 'Personnel de nettoyage', 'Personnel d\'entretien', '2012-09-24', 2659, '0643975224', '13 DEMALVILAIN (Boulevard Léonce)', 91897, 'Rungis', 'STCVFT@wanadoo.fr', 1, NULL),
(1109, 'Phoenix', 'Constantia', 'Personnel administratif', 'Directeur', '2011-06-24', 6170, '0622773785', '45 SAVEANT (Rue Jean)', 78485, 'Arcueil', 'CRGYJS@wanadoo.fr', 2, NULL),
(1110, 'Sepp', 'Jordi', 'Personnel administratif', 'Directeur', '2011-05-27', 3940, '0616612802', '39 DUPONT (Rue Etienne)', 92873, 'Robinson', 'CMMLIX@wanadoo.fr', 3, NULL),
(1111, 'Firenze', 'Rowan', 'Personnel de nettoyage', 'Personnel de nettoyage', '2016-06-12', 5137, '0612445039', '10 LIBERATION (Rond-Point de la)', 93471, 'Saint-Quentin en Yvelines', 'JXWJRB@wanadoo.fr', 2, NULL),
(1112, 'Ann', 'Odette', 'Personnel administratif', 'Responsable ressources humaines', '2014-10-13', 5454, '0651522678', '37 GRAND DOMAINE (Allée du)', 95942, 'Villeneuve Saint-Georges', 'YSZFOH@orange.fr', 2, NULL),
(1113, 'Pollux', 'Luther', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2013-03-23', 7525, '0686297107', '25 ARTOIS (Rue de l\')', 95421, 'Versailles', 'ORYXDG@free.fr', 1, NULL),
(1114, 'Ngaio', 'Alanis', 'Personnel administratif', 'Secrétaire', '2015-01-17', 5733, '0613262648', '37 NAVIGATEURS (Rue des)', 91797, 'Puteaux', 'UAIHYI@free.fr', 3, NULL),
(1115, 'Liviu', 'Takako', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2016-03-11', 1842, '0674938203', '36 GUIBERT (Rue)', 91186, 'Bobigny', 'PFUIAO@free.fr', 2, NULL),
(1116, 'Frederico', 'Den', 'Personnel de nettoyage', 'Personnel d\'entretien', '2015-11-26', 2385, '0669850534', '2 VILLE COLLET (Cour)', 93560, 'Bourg-la-reine', 'SSADDR@gmail.com', 1, NULL),
(1117, 'Heaven', 'Bartal', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2019-04-25', 7672, '0683898774', '25 MONTAGNE Saint-Joseph (Rue de la)', 93158, 'Saint-denis', 'ETFPPQ@free.fr', 2, NULL),
(1118, 'Jovita', 'Euthalia', 'Personnel de nettoyage', 'Personnel d\'entretien', '2012-05-10', 1755, '0690330153', '18 CROIX CHEMIN (Rue de la)', 95639, 'Neuilly', 'GBPQGP@gmail.com', 1, NULL),
(1119, 'Luther', 'Zella', 'Personnel de nettoyage', 'Personnel de nettoyage', '2015-01-14', 7506, '0678423908', '38 BERTHAUT (Rue Léon)', 95936, 'Saint-cyr', 'YSZTXU@orange.fr', 3, NULL),
(1120, 'Susumu', 'Scotty', 'Personnel administratif', 'Secrétaire', '2020-02-10', 5451, '0665532964', '49 TINTIAUX (Rue des)', 92361, 'Saint-cyr', 'JDFXFR@hotmail.fr', 3, NULL),
(1121, 'Kali', 'Venceslav', 'Personnel administratif', 'Responsable ressources humaines', '2010-11-25', 5112, '0612866889', '18 DREUX (Rue)', 94828, 'Rungis', 'QHRACB@gmail.com', 2, NULL),
(1122, 'Francene', 'Trijntje', 'Personnel administratif', 'Responsable ressources humaines', '2019-04-05', 4954, '0691793139', '29 BEAUSEJOUR (Rue)', 75174, 'Saint-cyr', 'PCLUTV@hotmail.fr', 1, NULL),
(1123, 'Cybele', 'Eirlys', 'Personnel de nettoyage', 'Personnel d\'entretien', '2019-05-12', 2345, '0621276346', '44 PONT (Rue du)', 93857, 'Villeneuve Saint-Georges', 'JODZTS@hotmail.fr', 3, NULL),
(1124, 'Manus', 'Talya', 'Personnel administratif', 'Secrétaire', '2014-10-06', 6772, '0686751239', '27 CHAPELET (Rue Roger)', 94885, 'Versailles', 'UFPICV@wanadoo.fr', 2, NULL),
(1125, 'Jirí', 'Terese', 'Personnel administratif', 'Responsable ressources humaines', '2013-01-04', 3031, '0671132106', '20 COQ HARDI (Impasse du)', 92332, 'Saint-cyr', 'LGELHC@gmail.com', 1, NULL),
(1126, 'Madison', 'Evdokiya', 'Personnel de nettoyage', 'Personnel de nettoyage', '2019-11-17', 2478, '0618417348', '8 PETITE BARONNIE (Chemin de la)', 95646, 'Puteaux', 'UIDWEE@hotmail.fr', 2, NULL),
(1127, 'Ciara', 'Christen', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2013-11-26', 2429, '0617687174', '37 CAMUS (Rue Albert)', 92548, 'Versailles', 'WAKVHN@orange.fr', 1, NULL),
(1128, 'Rémi', 'Grenville', 'Personnel de nettoyage', 'Personnel d\'entretien', '2018-09-12', 7131, '0690127576', '7 VAUBOREL (Rue)', 93765, 'Antony', 'VVWDVO@free.fr', 2, NULL),
(1129, 'Janice', 'Lothario', 'Personnel administratif', 'Responsable ressources humaines', '2017-10-20', 3722, '0610173117', '13 MARCHE (Place du)', 91508, 'Vélizy', 'QBUURP@gmail.com', 2, NULL),
(1130, 'Zaray', 'Krishna', 'Personnel administratif', 'Directeur', '2018-10-08', 3777, '0687475090', '22 SAINT-ETIENNE (Rue de )', 95225, 'Bourg-la-reine', 'VLZAWM@gmail.com', 1, NULL),
(1131, 'Xiomara', 'Hamish', 'Personnel de nettoyage', 'Personnel d\'entretien', '2010-12-28', 4542, '0640655191', '48 COUDRAY (Place Georges)', 91875, 'Arcueil', 'KHBBKI@free.fr', 1, NULL),
(1132, 'Lucasta', 'Tabatha', 'Personnel administratif', 'Directeur', '2020-12-12', 1240, '0693158997', '39 TRITON (Passage du)', 95689, 'Antony', 'CRPXGS@wanadoo.fr', 2, NULL),
(1133, 'Gladwyn', 'Sam', 'Personnel de nettoyage', 'Personnel de nettoyage', '2011-02-27', 4759, '0610681954', '26 GUENE (Rue Emile)', 93449, 'Garges-lès-gonesses', 'YJJKVQ@orange.fr', 3, NULL),
(1134, 'Riaz', 'Tímea', 'Personnel administratif', 'Secrétaire', '2018-08-26', 7452, '0633409786', '25 MARTINIQUE (Rue de la)', 93678, 'Gometz-le-chatel', 'ZGFABB@wanadoo.fr', 2, NULL),
(1135, 'Antony', 'Enok', 'Personnel de nettoyage', 'Personnel d\'entretien', '2011-02-19', 1105, '0659779933', '34 DINAN (Quai de)', 95652, 'Boulogne-billancourt', 'RWCSFS@gmail.com', 2, NULL),
(1136, 'Randy', 'Lyall', 'Personnel administratif', 'Secrétaire', '2019-07-17', 3931, '0688071065', '41 AURIGNY (Allée d\')', 93720, 'Puteaux', 'IVEJFA@gmail.com', 3, NULL),
(1137, 'Sebestyen', 'Fouad', 'Personnel administratif', 'Secrétaire', '2012-06-03', 6211, '0641613554', '14 TERTRE BELOT (Rue du)', 92136, 'Vélizy', 'OQWMPZ@wanadoo.fr', 2, NULL),
(1138, 'Wilkie', 'Gilchrist', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2019-07-08', 6578, '0645030137', '21 MAC DONALD STEWART (Rue David)', 94315, 'l\'Hay-les-roses', 'MKVMVW@orange.fr', 1, NULL),
(1139, 'Feardorcha', 'Ena', 'Personnel de nettoyage', 'Personnel de nettoyage', '2014-02-26', 7166, '0675280040', '26 SAINT AARON (Place)', 93354, 'Cachan', 'YRBSXZ@hotmail.fr', 1, NULL),
(1140, 'Denise', 'Obadiah', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2016-01-02', 1353, '0670170609', '22 COSNES (Rue des)', 75192, 'Vanves', 'PSIJTB@free.fr', 1, NULL),
(1141, 'Fawn', 'Samuele', 'Personnel de nettoyage', 'Personnel d\'entretien', '2017-08-07', 6123, '0614699522', '43 HACHE (Rue de la)', 92546, 'Bourg-la-reine', 'VAKYXG@wanadoo.fr', 1, NULL),
(1142, 'Hadassah', 'Torger', 'Personnel administratif', 'Responsable ressources humaines', '2011-06-16', 6842, '0641799583', '23 GENERAL PATTON (Rue du)', 75817, 'Sceaux', 'YMPBXM@gmail.com', 2, NULL),
(1143, 'Anjelica', 'Cillín', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2013-05-27', 3930, '0658315591', '31 GUENE (Rue Emile)', 95198, 'Garges-lès-gonesses', 'ILRWVD@gmail.com', 3, NULL),
(1144, 'Hugh', 'Braelyn', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2015-03-10', 2271, '0659106094', '24 TOUR D\'AUVERGNE (Boulevard de la)', 91463, 'Gometz-le-chatel', 'LUUTEP@gmail.com', 1, NULL),
(1145, 'Elzbieta', 'Hyam', 'Personnel administratif', 'Directeur', '2018-12-07', 5674, '0695174902', '15 RUSSY (Rue de)', 91720, 'l\'Hay-les-roses', 'HXPCFX@hotmail.fr', 3, NULL),
(1146, 'Gafar', 'Justyna', 'Personnel de nettoyage', 'Personnel de nettoyage', '2020-03-02', 4218, '0684017618', '21 BRISELAINE (Rue de)', 94946, 'Gometz-le-chatel', 'VMPSGR@wanadoo.fr', 1, NULL),
(1147, 'Donovan', 'Lior', 'Personnel de nettoyage', 'Personnel de nettoyage', '2019-11-23', 2061, '0653002150', '25 PETIT CHAMP (Square du)', 93330, 'Antony', 'LGALWB@orange.fr', 1, NULL),
(1148, 'Estrella', 'Photine', 'Personnel de nettoyage', 'Personnel d\'entretien', '2020-10-08', 3282, '0629809732', '6 ABBAYE (Rue de l\')', 91598, 'l\'Hay-les-roses', 'EQQPDQ@wanadoo.fr', 3, NULL),
(1149, 'Kasia', 'Siv', 'Personnel administratif', 'Directeur', '2014-02-18', 3023, '0655518200', '6 SAPINS (Avenue des)', 95503, 'Antony', 'ESVBGY@gmail.com', 1, NULL),
(1150, 'Caspar', 'Fabian', 'Personnel administratif', 'Directeur', '2020-05-22', 7510, '0617240484', '19 SAINT FRANCOIS XAVIER (Place)', 92122, 'Puteaux', 'XLIEFD@hotmail.fr', 1, NULL),
(1151, 'Ashlie', 'Jedrzej', 'Personnel administratif', 'Secrétaire', '2015-06-26', 3797, '0663725366', '24 BOUVET (Place)', 93983, 'Cachan', 'TQCTCZ@hotmail.fr', 2, NULL),
(1152, 'Yvo', 'Halldóra', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2017-11-07', 7822, '0669754583', '34 PARE  (Rue Ambroise)', 75113, 'Puteaux', 'YIVAQZ@free.fr', 2, NULL),
(1153, 'Ruaridh', 'Zena', 'Personnel administratif', 'Responsable ressources humaines', '2020-04-06', 5769, '0679498560', '31 DELALANDE (Rue Jean)', 95638, 'Puteaux', 'RXLZLL@wanadoo.fr', 1, NULL),
(1154, 'Sylvana', 'Mervyn', 'Personnel administratif', 'Responsable ressources humaines', '2013-01-14', 5776, '0684903644', '35 MAISON NEUVE (Rue de la )', 78688, 'Versailles', 'UQAHEX@hotmail.fr', 2, NULL),
(1155, 'Henrik', 'Damiana', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2012-05-16', 3597, '0686740612', '34 TERTRE BELOT (Rue du)', 78229, 'Paris', 'MEBRHR@orange.fr', 1, NULL),
(1156, 'Farrah', 'Hamlet', 'Personnel de nettoyage', 'Personnel de nettoyage', '2013-12-15', 3644, '0637760995', '43 NOROIT (Passage)', 94715, 'Gentilly', 'AHPLWY@gmail.com', 2, NULL),
(1157, 'Alannis', 'Peder', 'Personnel de nettoyage', 'Personnel d\'entretien', '2013-05-26', 1714, '0695956877', '44 AMARYLLIS (rue des)', 92108, 'Antony', 'SCEYOT@gmail.com', 2, NULL),
(1158, 'Brandt', 'Aarne', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2015-01-12', 1455, '0639870303', '25 NEPTUNE (Rue de)', 92590, 'Thiais', 'UXOGKM@gmail.com', 3, NULL),
(1159, 'Aloisia', 'Tendai', 'Personnel administratif', 'Responsable ressources humaines', '2012-03-13', 6613, '0662212375', '28 ROUTHOUAN (Rue du)', 92152, 'l\'Hay-les-roses', 'ZALBHC@gmail.com', 1, NULL),
(1160, 'Ráichéal', 'Natasha', 'Personnel de nettoyage', 'Personnel de nettoyage', '2013-06-15', 5938, '0633119291', '45 GASPE (Rue de)', 78934, 'Saint-denis', 'EZWMYM@wanadoo.fr', 2, NULL),
(1161, 'Elpis', 'Ignatius', 'Personnel de nettoyage', 'Personnel d\'entretien', '2017-06-11', 6638, '0681980542', '26 FLAUBERT (Impasse Gustave)', 78107, 'Gentilly', 'QOKSSB@hotmail.fr', 3, NULL);
INSERT INTO `personnel` (`ID_personnel`, `Nom_personnel`, `Prenom_personnel`, `Personnel`, `Fonction`, `Date_embauche`, `Salaire_personnel`, `Telephone_personnel`, `Adresse_personnel`, `Code_postal_personnel`, `Ville_personnel`, `Mail_personnel`, `ID_etablissement`, `ID_service`) VALUES
(1162, 'Filippo', 'Oliver', 'Personnel de nettoyage', 'Personnel de nettoyage', '2016-01-25', 7627, '0690715712', '19 LANCETTE (Passage de la)', 78370, 'Vanves', 'ADPGTS@gmail.com', 3, NULL),
(1163, 'Eliphelet', 'Petr', 'Personnel de nettoyage', 'Personnel de nettoyage', '2011-06-26', 6615, '0695249077', '49 RIVASSELOU (Allée de)', 75953, 'Antony', 'TEQGCS@orange.fr', 2, NULL),
(1164, 'Pål', 'Sroel', 'Personnel administratif', 'Responsable ressources humaines', '2016-08-21', 3910, '0617997118', '16 COQUELIN (Parking Jean)', 91409, 'Asnières', 'LJSMJB@free.fr', 2, NULL),
(1165, 'Xyleena', 'Farley', 'Personnel administratif', 'Directeur', '2010-07-26', 4945, '0696445061', '31 ROULAIS (Place de la)', 93762, 'Saint-Quentin en Yvelines', 'NIOBMS@orange.fr', 3, NULL),
(1166, 'Estella', 'Harry', 'Personnel de nettoyage', 'Personnel de nettoyage', '2017-04-11', 3799, '0678876506', '38 CEZEMBRE  (Rue de)', 78432, 'Thiais', 'RQNLLK@gmail.com', 2, NULL),
(1167, 'Earleen', 'Ruben', 'Personnel administratif', 'Secrétaire', '2011-01-16', 3143, '0688795400', '3 CHAMP PEGASE (Ruelle du)', 75578, 'Massy', 'WCQEXQ@orange.fr', 2, NULL),
(1168, 'Yorick', 'Zella', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2016-06-28', 4637, '0636932615', '24 POIDS DU ROI (Place du)', 93477, 'Orsay', 'CVQMYK@orange.fr', 3, NULL),
(1169, 'Kameron', 'Malia', 'Personnel administratif', 'Secrétaire', '2016-08-27', 6016, '0629065065', '5 TERRE NEUVE (Quai de)', 95184, 'Saint-cyr', 'OFQFSE@free.fr', 3, NULL),
(1170, 'Chas', 'Anat', 'Personnel administratif', 'Responsable ressources humaines', '2010-07-08', 3055, '0641370494', '9 DELALANDE (Rue Jean)', 95473, 'Malakoff', 'IQQLTJ@gmail.com', 1, NULL),
(1171, 'Kolman', 'Iqbal', 'Personnel de nettoyage', 'Personnel de nettoyage', '2020-08-11', 7041, '0634218582', '31 PLESSIS (Rue du)', 92453, 'Paris', 'NRWMSC@wanadoo.fr', 1, NULL),
(1172, 'Iolo', 'Hale', 'Personnel de nettoyage', 'Personnel d\'entretien', '2020-07-10', 4901, '0622087478', '38 JARNOUEN DE VILLARTAY (Rue Guy)', 95573, 'Arcueil', 'BXCMSI@gmail.com', 3, NULL),
(1173, 'Kohar', 'Adriaan', 'Personnel administratif', 'Hôte/Hôtesse d\'accueil', '2017-06-20', 4578, '0658389014', '27 PIPERIE (Rue de la)', 94230, 'l\'Hay-les-roses', 'JWBKPV@free.fr', 3, NULL),
(1174, 'Dark', 'Vador', 'Personnel administratif', 'Directeur', '0000-00-00', 2000, '093883930', '23 rue berger', 92808, 'Neuilly', 'dv@gmail.com', 2, NULL);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `rendez-vous_patient_service`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `rendez-vous_patient_service` (
`ID_patient` int(5) unsigned
,`Nom du patient` varchar(50)
,`Prenom du patient` varchar(50)
,`Heure de debut` time
,`Heure de fin` time
,`Date consultation` date
,`Service concerné` varchar(50)
,`Nom du personnel` varchar(50)
,`Prenom du personnel` varchar(50)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `sejour_moyen`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `sejour_moyen` (
`Adresse_etablissement` varchar(100)
,`Ville_etablissement` varchar(50)
,`Nom_service` varchar(50)
,`Séjour moyen dans le service` decimal(43,0)
);

-- --------------------------------------------------------

--
-- Structure de la table `service`
--

CREATE TABLE `service` (
  `ID_service` int(5) UNSIGNED NOT NULL,
  `Nom_service` varchar(50) NOT NULL,
  `Etage` int(11) NOT NULL,
  `ID_etablissement` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `service`
--

INSERT INTO `service` (`ID_service`, `Nom_service`, `Etage`, `ID_etablissement`) VALUES
(40, 'Ophtalmologie', 0, 1),
(41, 'Ophtalmologie', 5, 2),
(42, 'Ophtalmologie', 6, 3),
(43, 'Oncologie', 4, 1),
(44, 'Oncologie', 3, 2),
(45, 'Oncologie', 3, 3),
(46, 'Urgence', 3, 1),
(47, 'Urgence', 4, 2),
(48, 'Urgence', 3, 3),
(49, 'Psychiatrie', 3, 1),
(50, 'Psychiatrie', 6, 2),
(51, 'Psychiatrie', 5, 3),
(52, 'Urologie', 2, 1),
(53, 'Urologie', 0, 2),
(54, 'Urologie', 0, 3),
(55, 'Dermatologie', 5, 1),
(56, 'Dermatologie', 5, 2),
(57, 'Dermatologie', 4, 3),
(58, 'Endrocrinologie', 2, 1),
(59, 'Endrocrinologie', 4, 2),
(60, 'Endrocrinologie', 1, 3),
(61, 'Dépistage', 4, 1),
(62, 'Dépistage', 1, 2),
(63, 'Dépistage', 6, 3),
(64, 'Médecine générale', 5, 1),
(65, 'Médecine générale', 1, 2),
(66, 'Médecine générale', 6, 3),
(67, 'Chirurgie', 4, 1),
(68, 'Chirurgie', 5, 2),
(69, 'Chirurgie', 4, 3),
(70, 'Dentaire', 2, 1),
(71, 'Dentaire', 3, 2),
(72, 'Dentaire', 1, 3),
(73, 'Imagerie', 5, 1),
(74, 'Imagerie', 0, 2),
(75, 'Imagerie', 4, 3),
(76, 'Neurochirurgie', 6, 1),
(77, 'Neurochirurgie', 3, 2),
(78, 'Neurochirurgie', 5, 3),
(79, 'Covid19', 2, 1),
(80, 'Covid19', 3, 2),
(81, 'Covid19', 5, 3),
(82, 'Réanimation', 1, 1),
(83, 'Réanimation', 0, 2),
(84, 'Réanimation', 4, 3);

-- --------------------------------------------------------

--
-- Structure de la table `travailler`
--

CREATE TABLE `travailler` (
  `ID_jour` int(5) UNSIGNED NOT NULL,
  `ID_personnel` int(5) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Déchargement des données de la table `travailler`
--

INSERT INTO `travailler` (`ID_jour`, `ID_personnel`) VALUES
(3, 1058),
(3, 1112),
(3, 1171),
(4, 899),
(4, 997),
(4, 1143),
(5, 1141),
(6, 995),
(6, 1099),
(7, 948),
(7, 1140),
(8, 1002),
(10, 926),
(10, 1154),
(11, 919),
(11, 1032),
(11, 1036),
(11, 1046),
(11, 1149),
(12, 1071),
(13, 1052),
(16, 1068),
(17, 992),
(17, 1103),
(17, 1173),
(18, 1049),
(18, 1080),
(18, 1154),
(20, 1159),
(21, 969),
(21, 1141),
(21, 1150),
(22, 1168),
(24, 901),
(25, 971),
(25, 991),
(25, 998),
(27, 1166),
(28, 998),
(30, 1133),
(31, 961),
(31, 1015),
(31, 1149),
(34, 940),
(34, 1006),
(36, 1003),
(37, 930),
(38, 1068),
(38, 1081),
(39, 947),
(41, 1090),
(43, 915),
(43, 1007),
(43, 1081),
(44, 1098),
(46, 1090),
(46, 1139),
(47, 928),
(47, 945),
(47, 965),
(47, 1041),
(50, 903),
(50, 908),
(50, 1075),
(51, 907),
(52, 949),
(52, 1034),
(53, 1159),
(53, 1169),
(54, 1081),
(55, 914),
(55, 1165),
(56, 1011),
(57, 884),
(58, 1139),
(59, 920),
(59, 1167),
(61, 1035),
(62, 1076),
(62, 1163),
(64, 1003),
(66, 1007),
(67, 1008),
(69, 982),
(70, 1053),
(71, 1126),
(73, 1134),
(74, 886),
(74, 1090),
(75, 972),
(75, 978),
(76, 989),
(76, 1139),
(76, 1165),
(77, 964),
(77, 1026),
(77, 1057),
(78, 951),
(79, 950),
(79, 1011),
(82, 1023),
(83, 1153),
(84, 889),
(84, 891),
(84, 892),
(84, 995),
(85, 940),
(85, 1051),
(85, 1132),
(86, 971),
(88, 1024),
(88, 1091),
(88, 1117),
(89, 1098),
(90, 979),
(90, 1029),
(91, 1013),
(91, 1128),
(92, 946),
(93, 926),
(94, 912),
(94, 995),
(95, 1145),
(96, 921),
(97, 905),
(97, 1005),
(97, 1026),
(98, 1115),
(99, 1126),
(101, 915),
(101, 916),
(103, 1142),
(105, 1055),
(105, 1146),
(106, 911),
(106, 965),
(109, 973),
(109, 1096),
(110, 1158),
(111, 1059),
(113, 892),
(114, 1011),
(119, 1034),
(120, 960),
(120, 1017),
(121, 1003),
(121, 1051),
(122, 897),
(122, 1081),
(122, 1155),
(123, 1110),
(124, 959),
(125, 1116),
(127, 1022),
(127, 1048),
(129, 921),
(130, 916),
(130, 1049),
(132, 971),
(133, 926),
(133, 1079),
(133, 1090),
(134, 1120),
(136, 894),
(137, 1050),
(137, 1168),
(138, 1159),
(139, 1040),
(139, 1110),
(139, 1122),
(140, 1066),
(142, 939),
(142, 1031),
(143, 918),
(144, 906),
(147, 1126),
(149, 1010),
(150, 1020),
(152, 1064),
(154, 1119),
(155, 929),
(155, 1032),
(155, 1040),
(155, 1102),
(157, 933),
(157, 1143),
(158, 1033),
(160, 890),
(162, 1004),
(163, 923),
(163, 1025),
(165, 896),
(165, 1145),
(167, 927),
(168, 1082),
(168, 1087),
(168, 1112),
(169, 914),
(169, 990),
(169, 1088),
(171, 1021),
(171, 1063),
(171, 1164),
(171, 1171),
(174, 901),
(174, 1057),
(176, 979),
(176, 988),
(176, 1104),
(177, 1028),
(178, 946),
(178, 1122),
(178, 1134),
(179, 1050),
(181, 1114),
(182, 910),
(184, 991),
(185, 1010),
(185, 1062),
(185, 1123),
(186, 1039),
(186, 1047),
(187, 954),
(187, 1031),
(188, 908),
(189, 1120),
(190, 997),
(190, 1088),
(190, 1168),
(191, 1003),
(193, 1090),
(194, 913),
(195, 931),
(195, 993),
(196, 1126),
(197, 915),
(197, 1044),
(197, 1157),
(198, 1112),
(198, 1140),
(201, 1127),
(202, 1145),
(203, 1168),
(206, 977),
(206, 996),
(206, 1012),
(208, 958),
(208, 995),
(208, 1036),
(209, 1023),
(209, 1160),
(211, 950),
(212, 907),
(212, 916),
(212, 1164),
(214, 961),
(214, 1084),
(215, 988),
(216, 973),
(216, 1077),
(216, 1093),
(217, 1123),
(217, 1157),
(218, 1166),
(219, 945),
(219, 1060),
(220, 899),
(220, 1052),
(221, 936),
(221, 1140),
(222, 1149),
(224, 1153),
(225, 926),
(225, 1068),
(225, 1092),
(225, 1122),
(225, 1165),
(226, 972),
(226, 1026),
(226, 1075),
(226, 1134),
(227, 948),
(228, 1129),
(229, 1048),
(229, 1072),
(230, 907),
(230, 1137),
(231, 934),
(231, 1061),
(232, 1001),
(232, 1020),
(232, 1123),
(233, 889),
(234, 1007),
(234, 1038),
(234, 1172),
(236, 1109),
(237, 983),
(237, 1027),
(238, 1071),
(239, 940),
(240, 1001),
(241, 1117),
(242, 1029),
(246, 889),
(246, 987),
(246, 1086),
(247, 1167),
(248, 886),
(250, 901),
(250, 988),
(250, 991),
(250, 1026),
(250, 1082),
(250, 1104),
(253, 1004),
(255, 951),
(255, 1058),
(256, 932),
(256, 1145),
(258, 903),
(261, 938),
(261, 997),
(262, 1102),
(263, 1103),
(264, 995),
(264, 1025),
(264, 1034),
(265, 1050),
(266, 1041),
(267, 1029),
(268, 947),
(269, 1030),
(269, 1107),
(269, 1112),
(269, 1144),
(270, 975),
(270, 1124),
(271, 909),
(271, 1156),
(272, 1017),
(272, 1054),
(274, 1117),
(275, 906),
(275, 1088),
(276, 978),
(276, 1098),
(277, 923),
(277, 1057),
(280, 967),
(280, 978),
(280, 1039),
(281, 1117),
(283, 997),
(283, 1014),
(284, 891),
(284, 895),
(284, 1015),
(284, 1086),
(285, 1101),
(286, 1085),
(288, 1118),
(290, 1003),
(292, 1053),
(292, 1114),
(292, 1123),
(292, 1166),
(293, 1006),
(296, 994),
(296, 1087),
(299, 1099),
(299, 1131),
(300, 884),
(300, 1119),
(302, 972),
(304, 901),
(306, 1095),
(307, 949),
(307, 975),
(308, 1059),
(310, 1012),
(310, 1152),
(313, 984),
(313, 1081),
(315, 1105),
(316, 955),
(316, 1115),
(316, 1135),
(316, 1159),
(317, 936),
(317, 1044),
(317, 1089),
(317, 1132),
(319, 937),
(319, 1025),
(319, 1133),
(320, 993),
(320, 1113),
(321, 1093),
(321, 1132),
(324, 1076),
(325, 921),
(325, 1099),
(325, 1139),
(326, 982),
(326, 997),
(326, 1001),
(326, 1127),
(327, 1099),
(328, 906),
(328, 922),
(328, 1014),
(328, 1032),
(328, 1099),
(329, 950),
(331, 996),
(332, 1081),
(332, 1092),
(333, 903),
(333, 1059),
(334, 898),
(334, 1049),
(335, 954),
(335, 979),
(336, 902),
(336, 941),
(338, 1018),
(338, 1106),
(340, 994),
(340, 1026),
(341, 902),
(342, 912),
(342, 1067),
(342, 1075),
(343, 985),
(344, 1115),
(345, 1075),
(345, 1121),
(348, 952),
(348, 1104),
(348, 1166),
(349, 916),
(349, 982),
(349, 1160),
(352, 908),
(352, 1041),
(352, 1059),
(353, 945),
(353, 1038),
(354, 1122),
(355, 1084),
(356, 1034),
(358, 979),
(358, 1016),
(359, 893),
(359, 937),
(359, 1026),
(360, 1104),
(361, 1007),
(362, 996),
(365, 1142),
(365, 1172),
(366, 967),
(367, 978),
(367, 1019),
(368, 1009),
(369, 943),
(370, 900),
(371, 893),
(371, 1158),
(372, 1098),
(373, 907),
(373, 929),
(374, 905),
(374, 1111),
(375, 1031),
(378, 1127),
(379, 891),
(379, 908),
(379, 910),
(379, 959),
(379, 995),
(379, 1004),
(379, 1126),
(379, 1154),
(380, 885),
(380, 930),
(381, 886),
(382, 1013),
(383, 1160),
(384, 976),
(384, 1098),
(385, 999),
(385, 1001),
(385, 1048),
(386, 1033),
(386, 1167),
(388, 891),
(389, 1035),
(390, 964),
(390, 1033),
(395, 1131),
(395, 1145),
(397, 1014),
(400, 1019),
(401, 1022),
(401, 1124),
(402, 1159),
(405, 1016),
(406, 909),
(408, 1133),
(410, 914),
(410, 977),
(410, 1170),
(411, 1094),
(412, 913),
(412, 1148),
(413, 988),
(413, 1078),
(414, 964),
(415, 1107),
(416, 905),
(416, 1105),
(417, 891),
(417, 998),
(417, 1019),
(419, 937),
(419, 977),
(419, 989),
(419, 1109),
(420, 904),
(420, 935),
(420, 1042),
(420, 1073),
(421, 905),
(421, 944),
(421, 1168),
(422, 947),
(423, 1122),
(425, 955),
(425, 1112),
(426, 999),
(426, 1022),
(427, 914),
(427, 943),
(427, 1004),
(427, 1050),
(428, 898),
(429, 1060),
(430, 932),
(430, 934),
(430, 962),
(430, 1165),
(431, 992),
(432, 910),
(433, 940),
(433, 1002),
(435, 911),
(435, 971),
(435, 995),
(435, 1011),
(436, 1074),
(436, 1076),
(436, 1089),
(438, 900),
(438, 1052),
(439, 979),
(439, 1102),
(440, 927),
(442, 922),
(442, 963),
(442, 1166),
(443, 1125),
(443, 1159),
(444, 910),
(445, 1136),
(447, 908),
(447, 983),
(447, 1148),
(448, 885),
(448, 1027),
(448, 1155),
(448, 1162),
(450, 1095),
(453, 1139),
(453, 1173),
(454, 999),
(454, 1093),
(455, 1068),
(456, 1044),
(456, 1072),
(456, 1138),
(457, 901),
(457, 1082),
(459, 1028),
(460, 979),
(460, 1008),
(460, 1035),
(464, 1150),
(465, 899),
(465, 1084),
(467, 929),
(467, 1077),
(468, 989),
(469, 958),
(469, 968),
(469, 1068),
(469, 1149),
(470, 887),
(470, 988),
(470, 1068),
(470, 1116),
(471, 916),
(471, 980),
(471, 1043),
(471, 1055),
(471, 1097),
(471, 1156),
(472, 1043),
(472, 1145),
(473, 1098),
(474, 990),
(475, 932),
(475, 1024),
(477, 920),
(477, 1063),
(478, 906),
(478, 943),
(478, 1002),
(478, 1010),
(478, 1077),
(478, 1121),
(479, 905),
(481, 974),
(481, 1154),
(484, 1040),
(484, 1113),
(485, 1133),
(486, 1153),
(488, 910),
(488, 1080),
(489, 986),
(489, 1043),
(490, 999),
(490, 1162),
(492, 1134),
(493, 918),
(493, 1071),
(496, 1009),
(497, 911),
(498, 947),
(498, 1017),
(498, 1161),
(499, 1110),
(500, 992),
(500, 1037),
(500, 1145),
(500, 1146),
(504, 1129),
(504, 1146),
(505, 964),
(506, 983),
(507, 1056),
(508, 970),
(508, 1005),
(509, 898),
(512, 1003),
(512, 1136),
(512, 1168),
(514, 949),
(514, 1017),
(514, 1032),
(514, 1040),
(516, 1049),
(517, 993),
(517, 1143),
(518, 934),
(519, 1002),
(520, 994),
(521, 918),
(521, 1003),
(521, 1033),
(521, 1042),
(522, 987),
(523, 1087),
(525, 1147),
(525, 1169),
(526, 1002),
(527, 937),
(527, 980),
(527, 1050),
(527, 1124);

-- --------------------------------------------------------

--
-- Structure de la vue `materiels_populaires`
--
DROP TABLE IF EXISTS `materiels_populaires`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `materiels_populaires`  AS SELECT `materiel`.`Nom_materiel` AS `Nom_materiel`, count(`contenir_4`.`ID_materiel`) AS `Nombre de commandes du matériel` FROM (`materiel` join `contenir_4` on(`materiel`.`ID_materiel` = `contenir_4`.`ID_materiel`)) GROUP BY `contenir_4`.`ID_materiel` ORDER BY count(`contenir_4`.`ID_materiel`) DESC ;

-- --------------------------------------------------------

--
-- Structure de la vue `medecin_par_service`
--
DROP TABLE IF EXISTS `medecin_par_service`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `medecin_par_service`  AS SELECT `service`.`Nom_service` AS `Nom_service`, `service`.`ID_etablissement` AS `Etablissemet concerné`, count(`personnel`.`ID_personnel`) AS `Nombre_medecin_par_service` FROM (`personnel` join `service` on(`personnel`.`ID_service` = `service`.`ID_service`)) WHERE `personnel`.`Fonction` = 'medecin' OR `personnel`.`Fonction` = 'médecin' GROUP BY `personnel`.`ID_service` ;

-- --------------------------------------------------------

--
-- Structure de la vue `medicaments_populaires`
--
DROP TABLE IF EXISTS `medicaments_populaires`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `medicaments_populaires`  AS SELECT `medicament`.`Nom_medicament` AS `Nom_medicament`, count(`contenir_3`.`ID_medicament`) AS `Nombre de commandes du médicament` FROM (`medicament` join `contenir_3` on(`medicament`.`ID_medicament` = `contenir_3`.`ID_medicament`)) GROUP BY `contenir_3`.`ID_medicament` ORDER BY count(`contenir_3`.`ID_medicament`) DESC ;

-- --------------------------------------------------------

--
-- Structure de la vue `montant_par_patient`
--
DROP TABLE IF EXISTS `montant_par_patient`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `montant_par_patient`  AS SELECT `patient`.`Nom_patient` AS `Nom_patient`, `patient`.`Prenom_patient` AS `Prenom_patient`, sum(`consultation`.`Montant`) AS `Montant_paye_par_patient` FROM (`patient` join `consultation` on(`patient`.`ID_patient` = `consultation`.`ID_patient`)) GROUP BY `patient`.`ID_patient` ;

-- --------------------------------------------------------

--
-- Structure de la vue `moyenne_des_indemnités_dues_aux_gardes_supplémentaires`
--
DROP TABLE IF EXISTS `moyenne_des_indemnités_dues_aux_gardes_supplémentaires`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `moyenne_des_indemnités_dues_aux_gardes_supplémentaires`  AS SELECT date_format(`matable`.`Date_jour`,'%Y-%m') AS `AAAA-MM`, count(`matable`.`moyenne des gardes volontaires`) AS `Nombre de gardes volontaires`, avg(`matable`.`moyenne des gardes volontaires`) AS `Moyenne des gardes volontaires` FROM (select `jour`.`Date_jour` AS `Date_jour`,sum(`garde`.`Montant_garde`) AS `moyenne des gardes volontaires` from (((`personnel` join `effectuer_4` on(`personnel`.`ID_personnel` = `effectuer_4`.`ID_personnel`)) join `garde` on(`effectuer_4`.`ID_garde` = `garde`.`ID_garde`)) join `jour` on(`garde`.`ID_jour` = `jour`.`ID_jour`)) where `effectuer_4`.`Obligatoire` = 0 group by `personnel`.`ID_personnel`) AS `matable` GROUP BY date_format(`matable`.`Date_jour`,'%Y-%m') ;

-- --------------------------------------------------------

--
-- Structure de la vue `médicament_en_rupture`
--
DROP TABLE IF EXISTS `médicament_en_rupture`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `médicament_en_rupture`  AS SELECT `medicament`.`ID_medicament` AS `ID_medicament`, `medicament`.`Nom_medicament` AS `Nom_medicament`, `medicament`.`Quantite_nb_boites` AS `Quantite_nb_boites`, `medicament`.`Seuil` AS `Seuil`, `medicament`.`Prix_boite` AS `Prix_boite`, `medicament`.`ID_fournisseur` AS `ID_fournisseur` FROM `medicament` WHERE `medicament`.`Quantite_nb_boites` < `medicament`.`Seuil` ;

-- --------------------------------------------------------

--
-- Structure de la vue `notes_cliniques`
--
DROP TABLE IF EXISTS `notes_cliniques`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `notes_cliniques`  AS SELECT `etablissement`.`ID_etablissement` AS `ID_etablissement`, `etablissement`.`Adresse_etablissement` AS `Adresse_etablissement`, round(avg(`note`.`Note_sur_10`),2) AS `Note moyenne`, round(std(`note`.`Note_sur_10`),2) AS `Ecart type`, count(`note`.`Note_sur_10`) AS `Nombre de notes` FROM (`note` join `etablissement` on(`note`.`ID_etablissement` = `etablissement`.`ID_etablissement`)) GROUP BY `etablissement`.`ID_etablissement` ;

-- --------------------------------------------------------

--
-- Structure de la vue `occupation_des_services_par_mois`
--
DROP TABLE IF EXISTS `occupation_des_services_par_mois`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `occupation_des_services_par_mois`  AS SELECT `matable`.`Etablissement n°` AS `Etablissement n°`, `matable`.`Adresse` AS `Adresse`, `matable`.`Code_postal` AS `Code_postal`, `matable`.`Service` AS `Service`, `matable`.`Mois` AS `Mois`, round(avg(`matable`.`% d'occupation par mois`),0) AS `% d'Occupation du service` FROM (select `etablissement`.`ID_etablissement` AS `Etablissement n°`,`etablissement`.`Adresse_etablissement` AS `Adresse`,`etablissement`.`Code_postale_etablissement` AS `Code_postal`,`service`.`Nom_service` AS `Service`,`service`.`Etage` AS `Etage`,date_format(`occuper`.`Date_occuper`,'%Y-%m') AS `Mois`,round(100 * count(`occuper`.`Date_occuper`) / dayofmonth(last_day(`occuper`.`Date_occuper`)),0) AS `% d'occupation par mois` from (((`occuper` join `chambre` on(`occuper`.`ID_chambre` = `chambre`.`ID_chambre`)) join `service` on(`chambre`.`ID_service` = `service`.`ID_service`)) join `etablissement` on(`service`.`ID_etablissement` = `etablissement`.`ID_etablissement`)) where 1 group by date_format(`occuper`.`Date_occuper`,'%Y-%m')) AS `matable` GROUP BY `matable`.`Service`, `matable`.`Mois` ORDER BY `matable`.`Mois` ASC ;

-- --------------------------------------------------------

--
-- Structure de la vue `rendez-vous_patient_service`
--
DROP TABLE IF EXISTS `rendez-vous_patient_service`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `rendez-vous_patient_service`  AS SELECT `patient`.`ID_patient` AS `ID_patient`, `patient`.`Nom_patient` AS `Nom du patient`, `patient`.`Prenom_patient` AS `Prenom du patient`, `consultation`.`Heure_debut` AS `Heure de debut`, `consultation`.`Heure_fin` AS `Heure de fin`, `jour`.`Date_jour` AS `Date consultation`, `service`.`Nom_service` AS `Service concerné`, `personnel`.`Nom_personnel` AS `Nom du personnel`, `personnel`.`Prenom_personnel` AS `Prenom du personnel` FROM ((((`consultation` join `patient` on(`consultation`.`ID_patient` = `patient`.`ID_patient`)) join `jour` on(`consultation`.`ID_jour_entree` = `jour`.`ID_jour`)) join `personnel` on(`consultation`.`ID_personnel` = `personnel`.`ID_personnel`)) join `service` on(`personnel`.`ID_service` = `service`.`ID_service`)) WHERE to_days(`jour`.`Date_jour`) - to_days(current_timestamp()) > 0 ORDER BY `jour`.`Date_jour` ASC ;

-- --------------------------------------------------------

--
-- Structure de la vue `sejour_moyen`
--
DROP TABLE IF EXISTS `sejour_moyen`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `sejour_moyen`  AS SELECT `matable`.`Adresse_etablissement` AS `Adresse_etablissement`, `matable`.`Ville_etablissement` AS `Ville_etablissement`, `matable`.`Nom_service` AS `Nom_service`, round(sum(`matable`.`Nombre de jours`) / count(`matable`.`Nombre de jours`),0) AS `Séjour moyen dans le service` FROM (select `occuper`.`ID_occupation` AS `ID_occupation`,`occuper`.`ID_chambre` AS `ID_chambre`,`occuper`.`ID_patient` AS `ID_patient`,`occuper`.`Date_occuper` AS `Date_occuper`,`etablissement`.`Adresse_etablissement` AS `Adresse_etablissement`,`etablissement`.`Ville_etablissement` AS `Ville_etablissement`,`service`.`Nom_service` AS `Nom_service`,count(`occuper`.`Date_occuper`) AS `Nombre de jours` from (((`occuper` join `chambre` on(`occuper`.`ID_chambre` = `chambre`.`ID_chambre`)) join `service` on(`chambre`.`ID_service` = `service`.`ID_service`)) join `etablissement` on(`service`.`ID_etablissement` = `etablissement`.`ID_etablissement`)) group by `occuper`.`ID_patient`) AS `matable` WHERE 1 GROUP BY `matable`.`Nom_service`, `matable`.`Adresse_etablissement` ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `chambre`
--
ALTER TABLE `chambre`
  ADD PRIMARY KEY (`ID_chambre`),
  ADD KEY `Chambre_Service_FK` (`ID_service`);

--
-- Index pour la table `commande`
--
ALTER TABLE `commande`
  ADD PRIMARY KEY (`ID_commande`),
  ADD KEY `Commande_Etablissement_FK` (`ID_etablissement`);

--
-- Index pour la table `consultation`
--
ALTER TABLE `consultation`
  ADD PRIMARY KEY (`ID_consultation`),
  ADD KEY `Consultation_Patient_FK` (`ID_patient`),
  ADD KEY `Consultation_Personnel0_FK` (`ID_personnel`),
  ADD KEY `Consultation_Jour1_FK` (`ID_jour_entree`),
  ADD KEY `Consultation_Jour2_FK` (`ID_jour_sortie`);

--
-- Index pour la table `contenir`
--
ALTER TABLE `contenir`
  ADD PRIMARY KEY (`ID_consultation`,`ID_medicament`),
  ADD KEY `Contenir_Medicament0_FK` (`ID_medicament`);

--
-- Index pour la table `contenir_3`
--
ALTER TABLE `contenir_3`
  ADD PRIMARY KEY (`ID_commande`,`ID_medicament`),
  ADD KEY `Contenir_3_Medicament0_FK` (`ID_medicament`);

--
-- Index pour la table `contenir_4`
--
ALTER TABLE `contenir_4`
  ADD PRIMARY KEY (`ID_materiel`,`ID_commande`),
  ADD KEY `Contenir_4_Commande0_FK` (`ID_commande`);

--
-- Index pour la table `effectuer_3`
--
ALTER TABLE `effectuer_3`
  ADD PRIMARY KEY (`ID_personnel`,`ID_intervention`),
  ADD KEY `Effectuer_3_Intervention0_FK` (`ID_intervention`);

--
-- Index pour la table `effectuer_4`
--
ALTER TABLE `effectuer_4`
  ADD PRIMARY KEY (`ID_garde`,`ID_personnel`),
  ADD KEY `Effectuer_4_Personnel0_FK` (`ID_personnel`);

--
-- Index pour la table `etablissement`
--
ALTER TABLE `etablissement`
  ADD PRIMARY KEY (`ID_etablissement`);

--
-- Index pour la table `examen`
--
ALTER TABLE `examen`
  ADD PRIMARY KEY (`ID_examen`);

--
-- Index pour la table `fournisseur`
--
ALTER TABLE `fournisseur`
  ADD PRIMARY KEY (`ID_fournisseur`);

--
-- Index pour la table `garde`
--
ALTER TABLE `garde`
  ADD PRIMARY KEY (`ID_garde`),
  ADD KEY `Garde_Jour_FK` (`ID_jour`);

--
-- Index pour la table `intervention`
--
ALTER TABLE `intervention`
  ADD PRIMARY KEY (`ID_intervention`),
  ADD KEY `Intervention_Consultation_FK` (`ID_consultation`);

--
-- Index pour la table `jour`
--
ALTER TABLE `jour`
  ADD PRIMARY KEY (`ID_jour`);

--
-- Index pour la table `materiel`
--
ALTER TABLE `materiel`
  ADD PRIMARY KEY (`ID_materiel`),
  ADD KEY `Materiel_Service_FK` (`ID_service`),
  ADD KEY `Materiel_Fournisseur0_FK` (`ID_fournisseur`);

--
-- Index pour la table `medicament`
--
ALTER TABLE `medicament`
  ADD PRIMARY KEY (`ID_medicament`),
  ADD KEY `Medicament_Fournisseur_FK` (`ID_fournisseur`);

--
-- Index pour la table `mutuelle`
--
ALTER TABLE `mutuelle`
  ADD PRIMARY KEY (`ID_mutuelle`);

--
-- Index pour la table `note`
--
ALTER TABLE `note`
  ADD PRIMARY KEY (`ID_note`),
  ADD KEY `Note_Patient_FK` (`ID_patient`),
  ADD KEY `Note_Etablissement0_FK` (`ID_etablissement`);

--
-- Index pour la table `occuper`
--
ALTER TABLE `occuper`
  ADD PRIMARY KEY (`ID_occupation`),
  ADD KEY `Occuper_Chambre0_FK` (`ID_chambre`),
  ADD KEY `Occuper_Patient0_FK` (`ID_patient`);

--
-- Index pour la table `passer`
--
ALTER TABLE `passer`
  ADD PRIMARY KEY (`ID_consultation`,`ID_examen`),
  ADD KEY `Passer_Examen0_FK` (`ID_examen`);

--
-- Index pour la table `patient`
--
ALTER TABLE `patient`
  ADD PRIMARY KEY (`ID_patient`),
  ADD KEY `Patient_Mutuelle_FK` (`ID_mutuelle`),
  ADD KEY `Patient_Etablissement0_FK` (`ID_etablissement`);

--
-- Index pour la table `personnel`
--
ALTER TABLE `personnel`
  ADD PRIMARY KEY (`ID_personnel`),
  ADD KEY `Personnel_Service0_FK` (`ID_service`);

--
-- Index pour la table `service`
--
ALTER TABLE `service`
  ADD PRIMARY KEY (`ID_service`),
  ADD KEY `Service_Etablissement_FK` (`ID_etablissement`);

--
-- Index pour la table `travailler`
--
ALTER TABLE `travailler`
  ADD PRIMARY KEY (`ID_jour`,`ID_personnel`),
  ADD KEY `Travailler_Personnel0_FK` (`ID_personnel`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `chambre`
--
ALTER TABLE `chambre`
  MODIFY `ID_chambre` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=820;

--
-- AUTO_INCREMENT pour la table `commande`
--
ALTER TABLE `commande`
  MODIFY `ID_commande` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `consultation`
--
ALTER TABLE `consultation`
  MODIFY `ID_consultation` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=186;

--
-- AUTO_INCREMENT pour la table `etablissement`
--
ALTER TABLE `etablissement`
  MODIFY `ID_etablissement` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `examen`
--
ALTER TABLE `examen`
  MODIFY `ID_examen` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT pour la table `fournisseur`
--
ALTER TABLE `fournisseur`
  MODIFY `ID_fournisseur` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT pour la table `garde`
--
ALTER TABLE `garde`
  MODIFY `ID_garde` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1001;

--
-- AUTO_INCREMENT pour la table `intervention`
--
ALTER TABLE `intervention`
  MODIFY `ID_intervention` int(5) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jour`
--
ALTER TABLE `jour`
  MODIFY `ID_jour` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=528;

--
-- AUTO_INCREMENT pour la table `materiel`
--
ALTER TABLE `materiel`
  MODIFY `ID_materiel` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=132;

--
-- AUTO_INCREMENT pour la table `medicament`
--
ALTER TABLE `medicament`
  MODIFY `ID_medicament` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1527;

--
-- AUTO_INCREMENT pour la table `mutuelle`
--
ALTER TABLE `mutuelle`
  MODIFY `ID_mutuelle` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=275;

--
-- AUTO_INCREMENT pour la table `note`
--
ALTER TABLE `note`
  MODIFY `ID_note` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=480;

--
-- AUTO_INCREMENT pour la table `occuper`
--
ALTER TABLE `occuper`
  MODIFY `ID_occupation` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT pour la table `patient`
--
ALTER TABLE `patient`
  MODIFY `ID_patient` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=665;

--
-- AUTO_INCREMENT pour la table `personnel`
--
ALTER TABLE `personnel`
  MODIFY `ID_personnel` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1175;

--
-- AUTO_INCREMENT pour la table `service`
--
ALTER TABLE `service`
  MODIFY `ID_service` int(5) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `chambre`
--
ALTER TABLE `chambre`
  ADD CONSTRAINT `Chambre_Service_FK` FOREIGN KEY (`ID_service`) REFERENCES `service` (`ID_service`);

--
-- Contraintes pour la table `commande`
--
ALTER TABLE `commande`
  ADD CONSTRAINT `Commande_Etablissement_FK` FOREIGN KEY (`ID_etablissement`) REFERENCES `etablissement` (`ID_etablissement`);

--
-- Contraintes pour la table `consultation`
--
ALTER TABLE `consultation`
  ADD CONSTRAINT `Consultation_Jour1_FK` FOREIGN KEY (`ID_jour_entree`) REFERENCES `jour` (`ID_jour`),
  ADD CONSTRAINT `Consultation_Jour2_FK` FOREIGN KEY (`ID_jour_sortie`) REFERENCES `jour` (`ID_jour`),
  ADD CONSTRAINT `Consultation_Patient_FK` FOREIGN KEY (`ID_patient`) REFERENCES `patient` (`ID_patient`),
  ADD CONSTRAINT `Consultation_Personnel0_FK` FOREIGN KEY (`ID_personnel`) REFERENCES `personnel` (`ID_personnel`);

--
-- Contraintes pour la table `contenir`
--
ALTER TABLE `contenir`
  ADD CONSTRAINT `Contenir_Consultation_FK` FOREIGN KEY (`ID_consultation`) REFERENCES `consultation` (`ID_consultation`),
  ADD CONSTRAINT `Contenir_Medicament0_FK` FOREIGN KEY (`ID_medicament`) REFERENCES `medicament` (`ID_medicament`);

--
-- Contraintes pour la table `contenir_3`
--
ALTER TABLE `contenir_3`
  ADD CONSTRAINT `Contenir_3_Commande_FK` FOREIGN KEY (`ID_commande`) REFERENCES `commande` (`ID_commande`),
  ADD CONSTRAINT `Contenir_3_Medicament0_FK` FOREIGN KEY (`ID_medicament`) REFERENCES `medicament` (`ID_medicament`);

--
-- Contraintes pour la table `contenir_4`
--
ALTER TABLE `contenir_4`
  ADD CONSTRAINT `Contenir_4_Commande0_FK` FOREIGN KEY (`ID_commande`) REFERENCES `commande` (`ID_commande`),
  ADD CONSTRAINT `Contenir_4_Materiel_FK` FOREIGN KEY (`ID_materiel`) REFERENCES `materiel` (`ID_materiel`);

--
-- Contraintes pour la table `effectuer_3`
--
ALTER TABLE `effectuer_3`
  ADD CONSTRAINT `Effectuer_3_Intervention0_FK` FOREIGN KEY (`ID_intervention`) REFERENCES `intervention` (`ID_intervention`),
  ADD CONSTRAINT `Effectuer_3_Personnel_FK` FOREIGN KEY (`ID_personnel`) REFERENCES `personnel` (`ID_personnel`);

--
-- Contraintes pour la table `effectuer_4`
--
ALTER TABLE `effectuer_4`
  ADD CONSTRAINT `Effectuer_4_Garde_FK` FOREIGN KEY (`ID_garde`) REFERENCES `garde` (`ID_garde`),
  ADD CONSTRAINT `Effectuer_4_Personnel0_FK` FOREIGN KEY (`ID_personnel`) REFERENCES `personnel` (`ID_personnel`);

--
-- Contraintes pour la table `garde`
--
ALTER TABLE `garde`
  ADD CONSTRAINT `Garde_Jour_FK` FOREIGN KEY (`ID_jour`) REFERENCES `jour` (`ID_jour`);

--
-- Contraintes pour la table `intervention`
--
ALTER TABLE `intervention`
  ADD CONSTRAINT `Intervention_Consultation_FK` FOREIGN KEY (`ID_consultation`) REFERENCES `consultation` (`ID_consultation`);

--
-- Contraintes pour la table `materiel`
--
ALTER TABLE `materiel`
  ADD CONSTRAINT `Materiel_Fournisseur0_FK` FOREIGN KEY (`ID_fournisseur`) REFERENCES `fournisseur` (`ID_fournisseur`),
  ADD CONSTRAINT `Materiel_Service_FK` FOREIGN KEY (`ID_service`) REFERENCES `service` (`ID_service`);

--
-- Contraintes pour la table `medicament`
--
ALTER TABLE `medicament`
  ADD CONSTRAINT `Medicament_Fournisseur_FK` FOREIGN KEY (`ID_fournisseur`) REFERENCES `fournisseur` (`ID_fournisseur`);

--
-- Contraintes pour la table `note`
--
ALTER TABLE `note`
  ADD CONSTRAINT `Note_Etablissement0_FK` FOREIGN KEY (`ID_etablissement`) REFERENCES `etablissement` (`ID_etablissement`),
  ADD CONSTRAINT `Note_Patient_FK` FOREIGN KEY (`ID_patient`) REFERENCES `patient` (`ID_patient`);

--
-- Contraintes pour la table `occuper`
--
ALTER TABLE `occuper`
  ADD CONSTRAINT `Occuper_Chambre_FK` FOREIGN KEY (`ID_chambre`) REFERENCES `chambre` (`ID_chambre`),
  ADD CONSTRAINT `Occuper_Patient0_FK` FOREIGN KEY (`ID_patient`) REFERENCES `patient` (`ID_patient`);

--
-- Contraintes pour la table `passer`
--
ALTER TABLE `passer`
  ADD CONSTRAINT `Passer_Consultation_FK` FOREIGN KEY (`ID_consultation`) REFERENCES `consultation` (`ID_consultation`),
  ADD CONSTRAINT `Passer_Examen0_FK` FOREIGN KEY (`ID_examen`) REFERENCES `examen` (`ID_examen`);

--
-- Contraintes pour la table `patient`
--
ALTER TABLE `patient`
  ADD CONSTRAINT `Patient_Etablissement0_FK` FOREIGN KEY (`ID_etablissement`) REFERENCES `etablissement` (`ID_etablissement`),
  ADD CONSTRAINT `Patient_Mutuelle_FK` FOREIGN KEY (`ID_mutuelle`) REFERENCES `mutuelle` (`ID_mutuelle`);

--
-- Contraintes pour la table `personnel`
--
ALTER TABLE `personnel`
  ADD CONSTRAINT `Personnel_Service0_FK` FOREIGN KEY (`ID_service`) REFERENCES `service` (`ID_service`);

--
-- Contraintes pour la table `service`
--
ALTER TABLE `service`
  ADD CONSTRAINT `Service_Etablissement_FK` FOREIGN KEY (`ID_etablissement`) REFERENCES `etablissement` (`ID_etablissement`);

--
-- Contraintes pour la table `travailler`
--
ALTER TABLE `travailler`
  ADD CONSTRAINT `Travailler_Jour_FK` FOREIGN KEY (`ID_jour`) REFERENCES `jour` (`ID_jour`),
  ADD CONSTRAINT `Travailler_Personnel0_FK` FOREIGN KEY (`ID_personnel`) REFERENCES `personnel` (`ID_personnel`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
