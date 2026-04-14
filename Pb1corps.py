import matplotlib.pyplot as plt
import pandas as pd

#=== CONSTANTES ===
G = 6.674e-11       # m^3 / kg / s^2
Ms = 1.989e30       # masse du Soleil (kg)
delta_t = 84600      # pas de temps : 1 heure

#=== CONDITIONS INITIALES ===
x0 = 1.4271e12      # m (distance Saturne-Soleil)
y0 = 0.0
vx0 = 0.0
vy0 = 9.68e3        # m/s

#=== ACCELERATIONS ===
def ax(x, y):
    return -G * Ms * x / ((x**2 + y**2)**1.5)

def ay(x, y):
    return -G * Ms * y / ((x**2 + y**2)**1.5)

#=== LISTES ===
x = [x0]
y = [y0]
vx = [vx0]
vy = [vy0]
a_x = [ax(x0, y0)]
a_y = [ay(x0, y0)]

#=== METHODE LEAPFROG ===
def leapfrog():
    x_n, y_n = x[-1], y[-1]
    vx_n, vy_n = vx[-1], vy[-1]
    ax_n, ay_n = a_x[-1], a_y[-1]

    # position à t + dt
    x_n1 = x_n + vx_n * delta_t + 0.5 * ax_n * delta_t**2
    y_n1 = y_n + vy_n * delta_t + 0.5 * ay_n * delta_t**2

    # nouvelle accélération
    ax_n1 = ax(x_n1, y_n1)
    ay_n1 = ay(x_n1, y_n1)

    # nouvelle vitesse
    vx_n1 = vx_n + 0.5 * (ax_n + ax_n1) * delta_t
    vy_n1 = vy_n + 0.5 * (ay_n + ay_n1) * delta_t

    # ajout aux listes
    x.append(x_n1)
    y.append(y_n1)
    vx.append(vx_n1)
    vy.append(vy_n1)
    a_x.append(ax_n1)
    a_y.append(ay_n1)

#=== BOUCLE D’INTEGRATION ===
N = int(30000 * 365 * 24)   # ~29,5 ans (période de Saturne)
#for _ in range(N):
#    leapfrog()

#=== TRACE ===

df = pd.read_csv("resultats_PB_1corps.csv")
plt.style.use("dark_background")
plt.figure(figsize=(6,6))
plt.plot([0], [0], 'yo', label="Soleil")
plt.plot(df['X'], df['Y'], 'b-', label="Saturne")
plt.axis('equal')
plt.xlabel("x (m)")
plt.ylabel("y (m)")
plt.legend()
plt.title("Orbite de Saturne autour du Soleil (méthode Leapfrog)")
plt.savefig("Leapfrog_1corps.pdf")
plt.show()

