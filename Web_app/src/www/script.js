var dataPoints = [];
function fillxy(X, Y) {
    dataPoints.push({
        label: X,//date
        y: Y//valeur de la donnée
    });
    console.log("Valeurs X :\n" + X + "\nValeurs Y :\n" + Y);
}

function w3_open() {
    document.getElementById("mySidebar").style.display = "block";
}

function w3_close() {
    document.getElementById("mySidebar").style.display = "none";
}