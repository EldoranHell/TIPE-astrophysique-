require 'csv'

puts "\n=== ANALYSE TIPE TRAPPIST-1 ==="

# ==============================
# Chargement des données
# ==============================

donnees = Hash.new { |h,k| h[k] = [] }

CSV.foreach("trappist1_output.csv", headers: true) do |row|
  corps = row["body"].to_i
  x = row["x"].to_f
  y = row["y"].to_f
  donnees[corps] << [x,y]
end

# ==============================
# OUTILS MATHÉMATIQUES
# ==============================

def rayon(x,y)
  Math.sqrt(x*x + y*y)
end

def angle(x,y)
  Math.atan2(y,x)
end

# ==============================
# PÉRIODES ORBITALES
# ==============================

def periode(coords)
  angles = coords.map { |x,y| angle(x,y) }
  passages = []

  angles.each_with_index do |a,i|
    if i > 0 && angles[i-1] < 0 && a >= 0
      passages << i
    end
  end

  return nil if passages.size < 2
  passages[1] - passages[0]
end

puts "\n--- Vérification des rapports de périodes ---"

periodes = {}

(2..8).each do |corps|
  p = periode(donnees[corps])
  periodes[corps] = p if p
end

periodes.each_cons(2) do |(c1,p1),(c2,p2)|
  ratio = p2.to_f/p1
  puts "Rapport T#{c2}/T#{c1} = #{ratio}"
end

puts "\nLes valeurs attendues sont proches de :"
puts "1.6  (8:5)"
puts "1.666 (5:3)"
puts "1.5  (3:2)"
puts "1.333 (4:3)"

# ==============================
# ANGLES RÉSONANTS
# ==============================

puts "\n--- Analyse des angles résonants ---"

def angle_resonant(coords1, coords2, m, n)
  angles1 = coords1.map { |x,y| angle(x,y) }
  angles2 = coords2.map { |x,y| angle(x,y) }

  theta = []

  angles1.each_index do |i|
    theta << m*angles2[i] - n*angles1[i]
  end

  theta
end

puts "\n--- Analyse complète des résonances ---"

resonances = [
  [2, 3, 8, 5, "8:5 (planète 1–planète 2)"],
  [3, 4, 5, 3, "5:3 (planète 2–planète 3)"],
  [4, 5, 3, 2, "3:2 (planète 3–planète 4)"],
  [5, 6, 3, 2, "3:2 (planète 4–planète 5)"],
  [6, 7, 4, 3, "4:3 (planète 5–planète 6)"],
  [7, 8, 3, 2, "3:2 (planète 6–planète 7)"]
]

resonances.each do |c1, c2, m, n, nom|

  theta = angle_resonant(donnees[c1], donnees[c2], m, n)

  moyenne = theta.sum / theta.size
  amplitude = theta.map { |t| (t - moyenne).abs }.max

  puts "\nRésonance #{nom}"
  puts "Amplitude de libration = #{amplitude}"

  if amplitude < Math::PI
    puts "→ Libration détectée : résonance confirmée"
  else
    puts "→ Circulation : pas de verrouillage résonant"
  end

end


# ==============================
# STABILITÉ RADIALE
# ==============================

puts "\n--- Stabilité orbitale ---"

(2..8).each do |corps|
  rayons = donnees[corps].map { |x,y| rayon(x,y) }
  moyenne = rayons.sum / rayons.size
  variance = rayons.map { |r| (r-moyenne)**2 }.sum / rayons.size

  puts "Corps #{corps} : variance radiale = #{variance}"
end

# ==============================
#  INDICATEUR DE CHAOS
# ==============================

puts "\n--- Indicateur simplifié de chaos ---"

(2..8).each do |corps|
  angles = donnees[corps].map { |x,y| angle(x,y) }
  derive = angles.last - angles.first

  puts "Corps #{corps} : dérive angulaire = #{derive}"
end

puts "\nSi la dérive croît non linéairement avec le temps → chaos."
puts "Si évolution régulière → dynamique quasi-intégrable."
