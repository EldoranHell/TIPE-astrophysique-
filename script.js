// === PARAMÈTRES === //
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const vitesseSlider = document.getElementById("vitesse");

let positions = [];    // tableau (x,y) importé du CSV
let frame = 0;          // frame actuelle
let scale = 2e-11;      // mise à l'échelle pour afficher sur l'écran

// === CHARGEMENT DU CSV === //
fetch("resultats_PB_1corps.csv")
    .then(response => response.text())
    .then(data => {
        let lignes = data.split("\n");

        // sauter l’en-tête X,Y
        for (let i = 1; i < lignes.length; i++) {
            let [x, y] = lignes[i].split(",");
            if (x && y) positions.push([parseFloat(x), parseFloat(y)]);
        }

        console.log("Données importées :", positions.length, "points");

        // démarrer l’animation
        requestAnimationFrame(loop);
    });

// === FONCTION POUR DESSINER UN POINT === //
function dessinerPoint(x, y, couleur, taille = 5) {
    ctx.fillStyle = couleur;
    ctx.beginPath();
    ctx.arc(x, y, taille, 0, Math.PI * 2);
    ctx.fill();
}

// === ANIMATION === //
function loop() {
    // FADE pour faire une traînée douce
    ctx.fillStyle = "rgba(0, 0, 0, 0.1)";
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    if (positions.length > 0) {
        // vitesse contrôlée par le slider (plus le slider est élevé → animation + rapide)
        const speed = parseInt(vitesseSlider.value);

        for (let s = 0; s < speed; s++) {
            frame = (frame + 1) % positions.length;
        }

        let [x, y] = positions[frame];

        // convertir coordonnées réelles → écran
        let x_aff = canvas.width / 2  + x * scale;
        let y_aff = canvas.height / 2 + y * scale;

        // SOLEIL (fixe)
        dessinerPoint(canvas.width/2, canvas.height/2, "yellow", 8);

        // SATURNE (avec traînée)
        dessinerPoint(x_aff, y_aff, "white", 4);
    }

    requestAnimationFrame(loop);
}
