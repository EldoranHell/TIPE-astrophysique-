import pandas as pd
import matplotlib.pyplot as plt

# --- Chargement du CSV ---
df = pd.read_csv("resultats_2corps_Verlet.csv")

# Extraction des colonnes
x1 = df["X1"]
y1 = df["Y1"]
x2 = df["X2"]
y2 = df["Y2"]

# --- Tracé ---
plt.figure(figsize=(8, 8))

plt.plot(x1, y1, label="Corps 1 (ex: Soleil)")
plt.plot(x2, y2, label="Corps 2 (ex: Saturne)")

# Marqueurs des positions initiales
plt.scatter([x1.iloc[0]], [y1.iloc[0]], label="Init Corps 1")
plt.scatter([x2.iloc[0]], [y2.iloc[0]], label="Init Corps 2")

# Mise en forme
plt.xlabel("X (m)")
plt.ylabel("Y (m)")
plt.title("Trajectoires des deux corps (Méthode de Verlet)")
plt.legend()
plt.grid(True)
plt.axis("equal")  # important pour voir l'orbite correctement

plt.show()
plt.savefig("Pb2_corps_verlet_masses_eq.pdf")
