using CSV, DataFrames
### L'UTILISATION DE JULIA POUR LES CALCULS PERMET UNE VITESSE ACCRUE LORS DE CES DERNIERS ###
### JULIA EST DE 50 A 200 FOIS PLUS RAPIDE QUE PYTHON ###

### ZONE D'ASSISTANCE AU CALCUL DU PB A  1 CORPS ###

### METHODE LEAPFROG ###

### CONSTANTES ###
const G = 6.674e-11
const Ms = 1.989e30
const delta_t = 86400     # pas de temps : 1 jour

### CONDITIONS INITIALES ###
x0 = 1.4271e12
y0 = 0.0
vx0 = 0.0
vy0 = 9.68e3

### NOMBRE D'ITÉRATIONS ###
# période orbitale de Saturne ≈ 29.5 années
# 29.5 ans × 365 jours ≈ 10767 pas
N = 300 * 365 *24   # marge de sécurité

### PRE-ALLOCATION ###
x  = zeros(Float64, N+1)
y  = zeros(Float64, N+1)
vx = zeros(Float64, N+1)
vy = zeros(Float64, N+1)
a_x = zeros(Float64, N+1)
a_y = zeros(Float64, N+1)

### ALLOCATION DES CONDITIONS INITIALES ###
x[1], y[1] = x0, y0
vx[1], vy[1] = vx0, vy0

r2 = x0^2 + y0^2
a_x[1] = -G * Ms * x0 / (r2^(3/2))
a_y[1] = -G * Ms * y0 / (r2^(3/2))

### LEAPFROG ###
for i in 1:N
    # position
    x[i+1] = x[i] + vx[i]*delta_t + 0.5 * a_x[i] * delta_t^2
    y[i+1] = y[i] + vy[i]*delta_t + 0.5 * a_y[i] * delta_t^2

    # accélération
    r2 = x[i+1]^2 + y[i+1]^2
    inv_r32 = 1 / (sqrt(r2) * r2)
    ax_new = -G * Ms * x[i+1] * inv_r32
    ay_new = -G * Ms * y[i+1] * inv_r32

    # vitesse
    vx[i+1] = vx[i] + 0.5*(a_x[i] + ax_new)*delta_t
    vy[i+1] = vy[i] + 0.5*(a_y[i] + ay_new)*delta_t

    # stockage
    a_x[i+1] = ax_new
    a_y[i+1] = ay_new

    # affichage tous les 100 cycles
    if i % 100 == 0
        println("Step : ", i)
    end
end

### EXPORTATION DES RESULTATS PAR CSV ###
df = DataFrame(X = x, Y = y)
CSV.write("resultats_PB_1corps.csv", df)
println("Simulation terminée ✔️")

### METHODE D'EULER ###

### CONDITIONS INITIALES ###
x0 = 1.4271e12
y0 = 0.0
vx0 = 0.0
vy0 = 9.68e3

### NOMBRE D'ITÉRATIONS ###
N = 300 * 365 * 24   # marge de sécurité

### PRE-ALLOCATION ###
x  = zeros(Float64, N+1)
y  = zeros(Float64, N+1)
vx = zeros(Float64, N+1)
vy = zeros(Float64, N+1)
a_x = zeros(Float64, N+1)
a_y = zeros(Float64, N+1)

### ALLOCATION DES CONDITIONS INITIALES ###
x[1], y[1] = x0, y0
vx[1], vy[1] = vx0, vy0

r2 = x0^2 + y0^2
a_x[1] = -G * Ms * x0 / (r2^(3/2))
a_y[1] = -G * Ms * y0 / (r2^(3/2))

### EULER EXPLICITE ###
for i in 1:N

    # mise à jour des vitesses
    vx[i+1] = vx[i] + a_x[i] * delta_t
    vy[i+1] = vy[i] + a_y[i] * delta_t

    # mise à jour des positions
    x[i+1] = x[i] + vx[i] * delta_t
    y[i+1] = y[i] + vy[i] * delta_t

    # recalcul des accélérations
    r2 = x[i+1]^2 + y[i+1]^2
    inv_r32 = 1 / (sqrt(r2) * r2)
    a_x[i+1] = -G * Ms * x[i+1] * inv_r32
    a_y[i+1] = -G * Ms * y[i+1] * inv_r32

    # affichage tous les 100 cycles
    if i % 100 == 0
        println("Step : ", i)
    end
end

### EXPORTATION DES RESULTATS PAR CSV ###
df = DataFrame(X = x, Y = y)
CSV.write("resultats_PB_1corps_EULER.csv", df)
println("Simulation terminée ✔️ (Méthode d'Euler)")

