#!/usr/bin/env python3
"""Generate the mod thumbnail (256x256, original artwork - no game or mod
assets, so no licensing questions). Dark slate background, a stylized gun
turret with an orange muzzle flash, and three range arcs: the buff in one
picture. Run from the repo root: python3 scripts/make_thumbnail.py
"""
import math

from PIL import Image, ImageDraw

W = H = 256
ORANGE = (255, 157, 0)
ORANGE_LIGHT = (255, 196, 77)

img = Image.new("RGBA", (W, H), (0, 0, 0, 0))

# background: vertical gradient dark slate, rounded square
bg = Image.new("RGBA", (W, H))
bgd = ImageDraw.Draw(bg)
for y in range(H):
    t = y / H
    bgd.line([(0, y), (W, y)],
             fill=(int(36 + 12 * t), int(40 + 10 * t), int(46 + 8 * t)))
mask = Image.new("L", (W, H), 0)
ImageDraw.Draw(mask).rounded_rectangle([4, 4, W - 5, H - 5], radius=30, fill=255)
img.paste(bg, (0, 0), mask)

d = ImageDraw.Draw(img, "RGBA")
CX, CY = 118, 152  # turret pivot

# range arcs sweeping up-right (the buff)
for r, width, alpha in ((64, 5, 80), (96, 7, 110), (128, 9, 140)):
    d.arc([CX - r, CY - r, CX + r, CY + r], start=215, end=85,
          fill=ORANGE + (alpha,), width=width)

# turret base: trapezoid
d.polygon([(CX - 56, 228), (CX + 56, 228), (CX + 36, 192), (CX - 36, 192)],
          fill=(62, 66, 72, 255), outline=(96, 102, 110, 255), width=2)

# turret body
d.rounded_rectangle([CX - 27, 148, CX + 27, 198], radius=9,
                    fill=(50, 54, 60, 255), outline=(104, 110, 118, 255), width=2)

# barrel, angled up-right
ang = math.radians(-36)
length, bw = 92, 15
x2, y2 = CX + length * math.cos(ang), CY + length * math.sin(ang)
px, py = -math.sin(ang), math.cos(ang)
near = [(CX + s * bw / 2 * px, CY + s * bw / 2 * py) for s in (-1, 1)]
far = [(x2 + s * bw / 2 * px, y2 + s * bw / 2 * py) for s in (-1, 1)]
d.polygon([near[0], far[0], far[1], near[1]],
          fill=(72, 77, 84, 255), outline=(122, 128, 136, 255))

# muzzle brake + flash
d.ellipse([x2 - 11, y2 - 11, x2 + 11, y2 + 11], fill=ORANGE + (255,))
for a in (ang - 0.45, ang, ang + 0.45):
    fx, fy = x2 + 30 * math.cos(a), y2 + 30 * math.sin(a)
    d.line([(x2 + 10 * math.cos(a), y2 + 10 * math.sin(a)), (fx, fy)],
           fill=ORANGE_LIGHT + (230,), width=5)

# turret eye / hub
d.ellipse([CX - 9, 156, CX + 9, 174], fill=ORANGE + (255,))
d.ellipse([CX - 4, 161, CX + 4, 169], fill=(60, 63, 68, 255))

# spent casings at the base, for flavor
for cx, cy, r in ((CX - 78, 214, 5), (CX - 68, 224, 4), (CX + 74, 218, 5)):
    d.ellipse([cx - r, cy - r, cx + r, cy + r],
              fill=(200, 160, 70, 255), outline=(150, 115, 40, 255))

img.save("thumbnail.png")
print("wrote thumbnail.png")
