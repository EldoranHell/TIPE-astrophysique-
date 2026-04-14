import pandas as pd
import matplotlib.pyplot as plt

# Noms des corps
names = {
    1: "Etoile",
    2: "planète 1",
    3: "planète 2",
    4: "planète 3",
    5: "planète 4",
    6: "planète 5",
    7: "planète 6",
    8: "planète 7"
}

df = pd.read_csv("trappist1_output.csv")

plt.figure(figsize=(8,8))

for body in sorted(df["body"].unique()):
    data = df[df["body"] == body]
    plt.plot(data["x"], data["y"], label=names[body])

plt.gca().set_aspect("equal")
plt.title("TRAPPIST-1 — Simulation N-corps")
plt.xlabel("x (AU)")
plt.ylabel("y (AU)")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig("pbNcorps.pdf")
plt.show()
