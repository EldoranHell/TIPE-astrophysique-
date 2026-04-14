using DelimitedFiles

# ==============================
# UNITÉS
# ==============================
const G = 4π^2
const Mearth = 3.003e-6

# ==============================
# PARAMÈTRES TRAPPIST-1
# ==============================

Mstar = 0.0898

a_vals = [0.01154,0.01580,0.02227,0.02925,0.03849,0.04683,0.06189]
m_vals = [1.37,1.31,0.39,0.69,1.04,1.32,0.33] .* Mearth

N = 8   # étoile + 7 planètes

# masses
m = zeros(Float64, N)
m[1] = Mstar
for i in 1:7
    m[i+1] = m_vals[i]
end

# positions et vitesses
r = zeros(Float64, N, 3)
v = zeros(Float64, N, 3)
a = zeros(Float64, N, 3)

# conditions initiales circulaires
for i in 1:7
    a_i = a_vals[i]
    v_i = sqrt(G*Mstar/a_i)
    r[i+1,1] = a_i
    v[i+1,2] = v_i
end

# ==============================
# ACCÉLÉRATION (aucune allocation)
# ==============================

function compute_acc!(a, r, m)
    fill!(a, 0.0)

    @inbounds for i in 1:N
        for j in 1:N
            if i != j
                dx = r[j,1] - r[i,1]
                dy = r[j,2] - r[i,2]
                dz = r[j,3] - r[i,3]

                dist2 = dx*dx + dy*dy + dz*dz
                dist3 = dist2 * sqrt(dist2)

                factor = G * m[j] / dist3

                a[i,1] += factor * dx
                a[i,2] += factor * dy
                a[i,3] += factor * dz
            end
        end
    end
end

# ==============================
# SIMULATION
# ==============================

dt = 5e-5
steps = 120000

# CSV output
open("trappist1_output.csv", "w") do io
    println(io, "step,body,x,y")

    compute_acc!(a, r, m)

    for s in 1:steps

        # Kick
        @inbounds for i in 1:N
            v[i,1] += 0.5*dt*a[i,1]
            v[i,2] += 0.5*dt*a[i,2]
            v[i,3] += 0.5*dt*a[i,3]
        end

        # Drift
        @inbounds for i in 1:N
            r[i,1] += dt*v[i,1]
            r[i,2] += dt*v[i,2]
            r[i,3] += dt*v[i,3]
        end

        compute_acc!(a, r, m)

        # Kick
        @inbounds for i in 1:N
            v[i,1] += 0.5*dt*a[i,1]
            v[i,2] += 0.5*dt*a[i,2]
            v[i,3] += 0.5*dt*a[i,3]
        end

        # Export toutes les 10 étapes (réduit taille fichier)
        if s % 10 == 0
            for i in 1:N
                println(io, "$s,$i,$(r[i,1]),$(r[i,2])")
            end
        end
    end
end

println("Simulation terminée")
