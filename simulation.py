import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# ============================================================
# CONSTANTES
# ============================================================

G = 4 * np.pi**2
M_sun = 1.0
M_j = 0.0009543
M_s = 0.0002857
M_u = 0.00004365

bodies_masses = np.array([M_j, M_s, M_u])

# ============================================================
# CONDITIONS INITIALES
# ============================================================

r = np.array([
    [5.4, 0.0],
    [9.8, 0.0],
    [19.5, 0.0]
], dtype=float)

v = np.array([
    [0.0, np.sqrt(G*M_sun/5.4)],
    [0.0, np.sqrt(G*M_sun/9.8)],
    [0.0, np.sqrt(G*M_sun/19.5)]
], dtype=float)

# Lyapunov
epsilon0 = 1e-8
r_pert = r.copy()
r_pert[0,0] += epsilon0
v_pert = v.copy()

# ============================================================
# PARAMETRES
# ============================================================

dt = 0.05
t_max = 10000
steps = int(t_max / dt)

# ============================================================
# ACCELERATION
# ============================================================

def compute_accelerations(r):
    n = len(r)
    a = np.zeros_like(r)

    for i in range(n):
        diff_sun = -r[i]
        a[i] += G * M_sun * diff_sun / np.linalg.norm(diff_sun)**3

        for j in range(n):
            if i != j:
                diff = r[j] - r[i]
                a[i] += G * bodies_masses[j] * diff / np.linalg.norm(diff)**3

    return a

# ============================================================
# STOCKAGE
# ============================================================

times = []
theta = []
lyapunov_vals = []
traj = []

poincare_x = []
poincare_v = []

# ============================================================
# INTEGRATION
# ============================================================

a = compute_accelerations(r)
a_pert = compute_accelerations(r_pert)

for step in range(steps):

    t = step * dt

    # Leapfrog
    r += v * dt + 0.5 * a * dt**2
    r_pert += v_pert * dt + 0.5 * a_pert * dt**2

    a_new = compute_accelerations(r)
    a_pert_new = compute_accelerations(r_pert)

    v += 0.5 * (a + a_new) * dt
    v_pert += 0.5 * (a_pert + a_pert_new) * dt

    a = a_new
    a_pert = a_pert_new

    # Stockage
    traj.append(r.copy())
    times.append(t)

    # Angles
    angles = np.arctan2(r[:,1], r[:,0])
    theta.append(angles)

    # Lyapunov
    delta_vec = r_pert - r
    delta = np.linalg.norm(delta_vec)

    if step > 0 and delta > 0:
        lyap = np.log(delta/epsilon0) / t
    else:
        lyap = 0

    lyapunov_vals.append(lyap)

    # Renormalisation
    r_pert = r + epsilon0 * delta_vec / (delta + 1e-16)

    # ============================
    # POINCARÉ (passage Jupiter y>0)
    # ============================

    if r[0,1] > 0 and v[0,1] > 0:
        poincare_x.append(r[1,0])   # Saturne x
        poincare_v.append(v[1,0])   # Saturne vx

# ============================================================
# POST-TRAITEMENT
# ============================================================

traj = np.array(traj)
theta = np.unwrap(np.array(theta), axis=0)
times = np.array(times)

r_j = traj[:,0,:]
r_s = traj[:,1,:]
r_u = traj[:,2,:]

# Fréquences
omega = np.gradient(theta, dt, axis=0)
T = 2*np.pi / omega

ratio_SJ = T[:,1] / T[:,0]
ratio_US = T[:,2] / T[:,1]

# Lyapunov moyen
lyapunov_vals = np.array(lyapunov_vals)
lyap_moy = np.mean(lyapunov_vals[int(len(lyapunov_vals)*0.2):])

# ============================================================
# CSV
# ============================================================

df = pd.DataFrame({
    "temps": times,
    "ratio_SJ": ratio_SJ,
    "ratio_US": ratio_US,
    "lyapunov": lyapunov_vals
})

df.to_csv("simulation.csv", index=False)

# ============================================================
# GRAPHIQUES
# ============================================================

# 1️) Rapport des périodes
plt.figure()
plt.plot(times, ratio_SJ)
plt.axhline(2.5, linestyle="--")
plt.xlabel("Temps")
plt.ylabel("T_S / T_J")
plt.ylim(2,3)
plt.title("Rapport des périodes (résonance 5:2)")
plt.savefig('Rapport des periodes.pdf')
plt.show()

# 2️) Lyapunov
plt.figure()
plt.plot(times[1:], lyapunov_vals[1:])
plt.xlabel("Temps")
plt.ylabel("Lyapunov")
plt.title("Chaos du système")
plt.savefig("Lyapunov.pdf")
plt.show()

# 3️) Fourier
r_j_norm = np.linalg.norm(r_j, axis=1)
freq = np.fft.fftfreq(len(r_j_norm), dt)
fft_j = np.abs(np.fft.fft(r_j_norm - np.mean(r_j_norm)))


mask = freq > 0
plt.figure()
plt.plot(freq[mask], fft_j[mask])
plt.xlim(0, 0.2)
plt.xlabel("Fréquence")
plt.ylabel("Amplitude")
plt.title("Spectre de Fourier Jupiter")
plt.savefig('Spectre de fourier Jupiter.pdf')
plt.show()

# 4️) Orbites
plt.figure()
plt.plot(r_j[:,0], r_j[:,1], label="Jupiter")
plt.plot(r_s[:,0], r_s[:,1], label="Saturne")
plt.plot(r_u[:,0], r_u[:,1], label="Uranus")
plt.scatter(0,0)
plt.legend()
plt.axis("equal")
plt.title("Orbites planétaires")
plt.savefig('Orbitale planetaire.pdf')
plt.show()

# 5️) Angle de résonance
phi = np.unwrap(5*theta[:,1] - 2*theta[:,0])

plt.figure()
plt.plot(times, phi)
plt.xlabel("Temps")
plt.ylabel("Angle résonant")
plt.title("Absence ou présence de résonance")
plt.savefig('Diagramme angle resonnant.pdf')
plt.show()

# 6️) Diagramme de Poincaré
plt.figure()
plt.scatter(poincare_x, poincare_v, s=1)
plt.xlabel("x Saturne")
plt.ylabel("vx Saturne")
plt.title("Diagramme de Poincaré")
plt.savefig('Diagramme de poincaré.pdf')
plt.show()

# ============================================================
# 7️) CARTE DE STABILITÉ
# ============================================================

a_values = np.linspace(8.5, 11, 40)
stability = []

for a_test in a_values:

    r_test = np.array([
        [5.4,0],
        [a_test,0],
        [19.5,0]
    ], dtype=float)

    v_test = np.array([
        [0,np.sqrt(G/5.4)],
        [0,np.sqrt(G/a_test)],
        [0,np.sqrt(G/19.5)]
    ], dtype=float)

    delta0 = 1e-6
    r2 = r_test.copy()
    r2[1,0] += delta0

    for _ in range(2000):
        a1 = compute_accelerations(r_test)
        a2 = compute_accelerations(r2)

        r_test += v_test * dt
        r2 += v_test * dt

        v_test += a1 * dt

    delta = np.linalg.norm(r2 - r_test)
    stability.append(np.log(delta/delta0))

plt.figure()
plt.plot(a_values, stability)
plt.xlabel("Demi-grand axe Saturne")
plt.ylabel("Instabilité")
plt.title("Carte de stabilité")
plt.savefig('Carte de stabilité.pdf')
plt.show()

print("Lyapunov moyen :", lyap_moy)