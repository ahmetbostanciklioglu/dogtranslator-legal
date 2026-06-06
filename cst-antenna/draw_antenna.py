#!/usr/bin/env python3
"""
2.45 GHz inset-fed mikroserit yama antenin teknik cizimini uretir.
Cikti: antenna_layout.png  (ustten gorunum + katman kesiti + bilgi paneli)

Boyutlar patch_antenna_2450MHz.bas makrosundaki degerlerle birebir aynidir.
"""
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, FancyArrowPatch

# ---- Tasarim parametreleri (mm) ----
W_patch = 37.234
L_patch = 28.809
W_feed  = 3.083
y_inset = 9.935
g_inset = 1.0
L_feed  = 12.0
h_sub   = 1.6
t_met   = 0.035
marg    = 6 * h_sub
W_sub   = W_patch + marg           # 46.834
L_sub   = L_patch + L_feed + marg  # 50.409

# Renkler
C_SUB   = "#cdb87a"   # FR-4
C_GND   = "#c98a4b"   # bakir
C_CU    = "#d98c4a"   # bakir yama
C_PORT  = "#d23b3b"

plt.rcParams.update({"font.size": 9, "font.family": "DejaVu Sans"})
fig = plt.figure(figsize=(13, 7.2))
fig.suptitle("2.45 GHz Inset-Fed Mikroserit Yama Anten  —  CST Studio Suite 2025",
             fontsize=14, fontweight="bold")

# ============================================================
# (1) USTTEN GORUNUM  (x = genislik, y = uzunluk)
# ============================================================
ax = fig.add_axes([0.05, 0.08, 0.46, 0.82])
ax.set_title("Ustten Gorunum (Top View)", fontsize=11, fontweight="bold")

# Altlik
ax.add_patch(Rectangle((-W_sub/2, -L_sub/2), W_sub, L_sub,
                        facecolor=C_SUB, edgecolor="#6b5d2f", lw=1.2, zorder=1))
# Yama govdesi
patch_y0 = -L_patch/2
ax.add_patch(Rectangle((-W_patch/2, patch_y0), W_patch, L_patch,
                        facecolor=C_CU, edgecolor="#7a3d12", lw=1.2, zorder=2))
# Inset bosluklar (altlik rengine geri boya = metal yok)
ax.add_patch(Rectangle((W_feed/2, patch_y0), g_inset, y_inset,
                        facecolor=C_SUB, edgecolor="#7a3d12", lw=0.8, zorder=3))
ax.add_patch(Rectangle((-W_feed/2 - g_inset, patch_y0), g_inset, y_inset,
                        facecolor=C_SUB, edgecolor="#7a3d12", lw=0.8, zorder=3))
# Besleme hatti
feed_y1 = -L_sub/2
feed_y2 = patch_y0 + y_inset
ax.add_patch(Rectangle((-W_feed/2, feed_y1), W_feed, feed_y2 - feed_y1,
                        facecolor=C_CU, edgecolor="#7a3d12", lw=1.0, zorder=2))
# Dalga kilavuzu portu (hattin dis ucu)
port_w = W_feed + 6*h_sub
ax.plot([-port_w/2, port_w/2], [feed_y1, feed_y1], color=C_PORT, lw=3, zorder=5)
ax.text(0, feed_y1 - 1.8, "Port 1 (50 Ω)", color=C_PORT, ha="center",
        va="top", fontsize=8, fontweight="bold")

# --- Olcu oklari ---
def dim(ax, p1, p2, text, off=0, horiz=True, color="#1f4e79"):
    a = FancyArrowPatch(p1, p2, arrowstyle="<->", mutation_scale=10,
                        color=color, lw=1.0, zorder=6)
    ax.add_patch(a)
    mx, my = (p1[0]+p2[0])/2, (p1[1]+p2[1])/2
    if horiz:
        ax.text(mx, my+0.6, text, ha="center", va="bottom", color=color, fontsize=8)
    else:
        ax.text(mx+0.6, my, text, ha="left", va="center", color=color,
                fontsize=8, rotation=90)

# W_patch (ust)
dim(ax, (-W_patch/2, L_patch/2+2.2), (W_patch/2, L_patch/2+2.2),
    f"W = {W_patch:.2f} mm")
# L_patch (sag)
dim(ax, (W_patch/2+2.5, -L_patch/2), (W_patch/2+2.5, L_patch/2),
    f"L = {L_patch:.2f} mm", horiz=False)
# W_sub (en ust)
dim(ax, (-W_sub/2, L_sub/2+1.0), (W_sub/2, L_sub/2+1.0),
    f"W_sub = {W_sub:.2f} mm", color="#555")
# L_sub (en sol)
dim(ax, (-W_sub/2-1.2, -L_sub/2), (-W_sub/2-1.2, L_sub/2),
    f"L_sub = {L_sub:.2f} mm", horiz=False, color="#555")
# inset derinligi
dim(ax, (W_feed/2+g_inset+1.0, patch_y0), (W_feed/2+g_inset+1.0, patch_y0+y_inset),
    f"y0 = {y_inset:.2f}", horiz=False, color="#7a3d12")
# besleme genisligi
ax.annotate(f"W_feed = {W_feed:.2f} mm\n(50 Ω hat)", xy=(0, feed_y1+3),
            xytext=(W_sub/2-2, feed_y1+6), fontsize=8, color="#7a3d12",
            ha="right", arrowprops=dict(arrowstyle="->", color="#7a3d12"))

ax.set_xlim(-W_sub/2-9, W_sub/2+9)
ax.set_ylim(-L_sub/2-6, L_sub/2+6)
ax.set_aspect("equal")
ax.set_xlabel("x  (mm)")
ax.set_ylabel("y  (mm)")
ax.grid(True, ls=":", alpha=0.4)

# ============================================================
# (2) KATMAN KESITI  (yan gorunum, x=0 duzlemi)
# ============================================================
ax2 = fig.add_axes([0.58, 0.55, 0.39, 0.34])
ax2.set_title("Katman Kesiti (Cross-section @ x=0)", fontsize=11, fontweight="bold")
scale_z = 6.0  # z eksenini gorunur kilmak icin abart
# Ground
ax2.add_patch(Rectangle((-L_sub/2, -t_met*scale_z), L_sub, t_met*scale_z,
                        facecolor=C_GND, edgecolor="k", lw=0.8))
# Substrate
ax2.add_patch(Rectangle((-L_sub/2, 0), L_sub, h_sub,
                        facecolor=C_SUB, edgecolor="k", lw=0.8))
# Ust metal (besleme + yama, x=0 boyunca)
ax2.add_patch(Rectangle((-L_sub/2, h_sub), (L_sub/2 + L_patch/2), t_met*scale_z,
                        facecolor=C_CU, edgecolor="k", lw=0.8))
# Port
ax2.plot([-L_sub/2, -L_sub/2], [0, h_sub], color=C_PORT, lw=3)
# Etiketler
ax2.text(L_sub/2-1, -t_met*scale_z/2, "Ground (Cu, 35 µm)", ha="right",
         va="center", fontsize=7)
ax2.text(L_sub/2-1, h_sub/2, "FR-4  εr=4.4,  h=1.6 mm", ha="right",
         va="center", fontsize=7)
ax2.text(0, h_sub + t_met*scale_z + 0.25, "Patch + Feed (Cu)", ha="center",
         va="bottom", fontsize=7, color="#7a3d12")
ax2.set_xlim(-L_sub/2-2, L_sub/2+2)
ax2.set_ylim(-t_met*scale_z-0.6, h_sub+1.4)
ax2.set_xlabel("y  (mm)")
ax2.set_ylabel("z  (z abartili)")
ax2.set_aspect("auto")

# ============================================================
# (3) BILGI PANELI
# ============================================================
ax3 = fig.add_axes([0.58, 0.06, 0.39, 0.42])
ax3.axis("off")
info = (
    "TASARIM OZETI\n"
    "──────────────────────────────\n"
    "• Merkez frekans      : 2.45 GHz (ISM / WLAN)\n"
    "• Altlik              : FR-4, εr=4.4, tanδ=0.02\n"
    "• Altlik kalinligi    : 1.6 mm\n"
    "• Iletken             : Bakir, 35 µm\n"
    "• Besleme             : 50 Ω mikroserit + inset\n"
    "• Polarizasyon        : Dogrusal (lineer)\n"
    "• Cozucu              : Time Domain (Transient)\n"
    "\n"
    "NASIL CALISIR\n"
    "──────────────────────────────\n"
    "Yama, λ/2 rezonator gibi davranir; L kenar\n"
    "uzunlugu 2.45 GHz'de rezonansi belirler. Isima\n"
    "yamanin acik kenarlarindaki sacak (fringing)\n"
    "alanlarindan olur. Inset (girinti) derinligi y0,\n"
    "yuksek kenar empedansini 50 Ω'a dusurerek\n"
    "besleme hatti ile uyum saglar:\n"
    "      Rin(y0) = Rin(0)·cos²(π·y0 / L)\n"
    "\n"
    "BEKLENEN PERFORMANS\n"
    "──────────────────────────────\n"
    "• S11 ≤ −15 dB  @ 2.45 GHz\n"
    "• VSWR ≈ 1.0 – 1.5\n"
    "• Kazanc ≈ 3 – 5 dBi  (FR-4 kayiplari dahil)\n"
    "• Yariм yonlu (broadside) isima deseni"
)
ax3.text(0, 1, info, va="top", ha="left", fontsize=8.4, family="monospace",
         linespacing=1.35)

fig.savefig("cst-antenna/antenna_layout.png", dpi=160,
            bbox_inches="tight", facecolor="white")
print("OK -> cst-antenna/antenna_layout.png")
