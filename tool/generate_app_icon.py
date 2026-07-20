"""Generate the AURA app icon: gradient orb + spark on dark background.

Outputs (into assets/icon/):
  app_icon.png       — 1024x1024 full-bleed icon (iOS + Android legacy)
  adaptive_fg.png    — 1024x1024 transparent foreground (Android adaptive)
"""
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
PRIMARY = (0x5B, 0x8C, 0xFF)   # AppColors.primary
ACCENT = (0x6E, 0xE7, 0xF9)    # AppColors.accent
BG = (0x0D, 0x11, 0x17)        # AppColors.background

OUT_DIR = "/Users/cap/Project/aura/assets/icon"


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def diagonal_gradient(size):
    """Linear gradient from top-left (primary) to bottom-right (accent)."""
    small = 128
    img = Image.new("RGB", (small, small))
    px = img.load()
    for y in range(small):
        for x in range(small):
            t = (x + y) / (2 * (small - 1))
            px[x, y] = lerp(PRIMARY, ACCENT, t)
    return img.resize((size, size), Image.BICUBIC)


def circle_mask(size, diameter, center):
    mask = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(mask)
    r = diameter / 2
    d.ellipse([center[0] - r, center[1] - r, center[0] + r, center[1] + r], fill=255)
    return mask


def spark_points(cx, cy, r_outer, r_inner):
    """8-vertex four-point star, starting at the top, clockwise."""
    pts = []
    import math
    for i in range(8):
        r = r_outer if i % 2 == 0 else r_inner
        ang = -math.pi / 2 + i * math.pi / 4
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return pts


def draw_sparks(layer, cx, cy, scale=1.0):
    d = ImageDraw.Draw(layer)
    # Main spark (auto_awesome-style four-point star)
    d.polygon(spark_points(cx, cy, 150 * scale, 42 * scale), fill=(255, 255, 255, 255))
    # Small accent spark, upper right
    d.polygon(spark_points(cx + 150 * scale, cy - 150 * scale, 52 * scale, 16 * scale),
              fill=(255, 255, 255, 235))
    # Tiny spark, lower left
    d.polygon(spark_points(cx - 140 * scale, cy + 145 * scale, 34 * scale, 11 * scale),
              fill=(255, 255, 255, 220))


def orb_with_spark(canvas_size, orb_diameter):
    """Transparent layer: glow + gradient orb + white sparks."""
    layer = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    c = canvas_size // 2

    # Soft glow behind the orb (mirrors the AuraLogo box shadow)
    glow = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    r = orb_diameter / 2
    gd.ellipse([c - r, c - r, c + r, c + r], fill=PRIMARY + (90,))
    glow = glow.filter(ImageFilter.GaussianBlur(orb_diameter * 0.18))
    layer.alpha_composite(glow)

    # Gradient orb
    grad = diagonal_gradient(canvas_size).convert("RGBA")
    mask = circle_mask(canvas_size, orb_diameter, (c, c))
    layer.paste(grad, (0, 0), mask)

    # White sparks on top
    draw_sparks(layer, c, c, scale=orb_diameter / 640)
    return layer


def main():
    import os
    os.makedirs(OUT_DIR, exist_ok=True)

    # Full-bleed icon: dark background, orb ~62% of canvas
    icon = Image.new("RGBA", (SIZE, SIZE), BG + (255,))
    icon.alpha_composite(orb_with_spark(SIZE, 640))
    icon.convert("RGB").save(f"{OUT_DIR}/app_icon.png")

    # Android adaptive foreground: transparent, orb inside the 66% safe zone
    fg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    fg.alpha_composite(orb_with_spark(SIZE, 600))
    fg.save(f"{OUT_DIR}/adaptive_fg.png")

    print("wrote", f"{OUT_DIR}/app_icon.png", "and adaptive_fg.png")


if __name__ == "__main__":
    main()
