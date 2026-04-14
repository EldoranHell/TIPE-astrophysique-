using CSV, DataFrames

### CONSTANTES ###
const G = 6.674e-11
const delta_t = 86400   # 1 jour

### MASSES ###
M1 = 1.989e30      # masse du Soleil
M2 = 1.989e30      # masse de Saturne

### CONDITIONS INITIALES ###
x1_0 = 0.0
y1_0 = 0.0
vx1_0 = 0.0
vy1_0 = 0.0

x2_0 = 1.4271e12
y2_0 = 0.0
vx2_0 = 0.0
vy2_0 = 9.68e3

### NOMBRE D'ITÉRATIONS ###
N = 30 * 365 * 24  # 30 ans pour observer les résonances

### PRE-ALLOCATION ###
x1  = zeros(Float64, N+1)
y1  = zeros(Float64, N+1)
vx1 = zeros(Float64, N+1)
vy1 = zeros(Float64, N+1)

x2  = zeros(Float64, N+1)
y2  = zeros(Float64, N+1)
vx2 = zeros(Float64, N+1)
vy2 = zeros(Float64, N+1)

ax1 = zeros(Float64, N+1)
ay1 = zeros(Float64, N+1)
ax2 = zeros(Float64, N+1)
ay2 = zeros(Float64, N+1)

### INITIALISATION ###
x1[1] = x1_0 ; y1[1] = y1_0
vx1[1] = vx1_0 ; vy1[1] = vy1_0

x2[1] = x2_0 ; y2[1] = y2_0
vx2[1] = vx2_0 ; vy2[1] = vy2_0

# accélérations initiales
dx = x2[1] - x1[1]
dy = y2[1] - y1[1]
r2 = dx^2 + dy^2
inv_r32 = 1 / (sqrt(r2)*r2)

ax1[1] =  G * M2 * dx * inv_r32
ay1[1] =  G * M2 * dy * inv_r32
ax2[1] = -G * M1 * dx * inv_r32
ay2[1] = -G * M1 * dy * inv_r32

### VERLET POSITIONNEL ###
for i in 1:N

    ### 1) Mise à jour des positions ###
    x1[i+1] = x1[i] + vx1[i]*delta_t + 0.5*ax1[i]*delta_t^2
    y1[i+1] = y1[i] + vy1[i]*delta_t + 0.5*ay1[i]*delta_t^2

    x2[i+1] = x2[i] + vx2[i]*delta_t + 0.5*ax2[i]*delta_t^2
    y2[i+1] = y2[i] + vy2[i]*delta_t + 0.5*ay2[i]*delta_t^2

    ### 2) Nouvelles accélérations ###
    dx = x2[i+1] - x1[i+1]
    dy = y2[i+1] - y1[i+1]
    r2 = dx^2 + dy^2
    inv_r32 = 1 / (sqrt(r2)*r2)

    ax1_new =  G * M2 * dx * inv_r32
    ay1_new =  G * M2 * dy * inv_r32
    ax2_new = -G * M1 * dx * inv_r32
    ay2_new = -G * M1 * dy * inv_r32

    ### 3) Mise à jour des vitesses ###
    vx1[i+1] = vx1[i] + 0.5*(ax1[i] + ax1_new)*delta_t
    vy1[i+1] = vy1[i] + 0.5*(ay1[i] + ay1_new)*delta_t

    vx2[i+1] = vx2[i] + 0.5*(ax2[i] + ax2_new)*delta_t
    vy2[i+1] = vy2[i] + 0.5*(ay2[i] + ay2_new)*delta_t

    ### 4) Stockage des nouvelles accélérations ###
    ax1[i+1] = ax1_new
    ay1[i+1] = ay1_new
    ax2[i+1] = ax2_new
    ay2[i+1] = ay2_new

    if i % 1000 == 0
        println("Étape : ", i)
    end
end

### EXPORT ###
df = DataFrame(
    X1 = x1, Y1 = y1,
    X2 = x2, Y2 = y2
)

CSV.write("resultats_2corps_Verlet.csv", df)

println("Simulation terminée ✔️ (Méthode Verlet - 2 corps)")
