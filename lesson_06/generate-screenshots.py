#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
LOG = ROOT / "_capture" / "terminal.log"
SHOTS = ROOT / "screenshots"
MAP = [
    ("01-load", "01-load.png"),
    ("02-top", "02-top.png"),
    ("03-htop", "03-htop.png"),
    ("04-find", "04-find.png"),
    ("05-nice", "05-nice.png"),
    ("06-time", "06-time.png"),
    ("07-memory", "07-memory.png"),
    ("08-lab-find", "08-lab-find.png"),
    ("09-lab-fix", "09-lab-fix.png"),
    ("10-lab-check", "10-lab-check.png"),
]


def font(sz):
    for n in ("DejaVuSansMono.ttf", "Consolas.ttf"):
        try:
            return ImageFont.truetype(n, sz)
        except OSError:
            pass
    return ImageFont.load_default()


def render(text, out):
    f = font(13)
    lines = text.rstrip().split("\n")[:220]
    w = min(max(len(l) for l in lines) * 8 + 20, 950)
    h = len(lines) * 18 + 20
    img = Image.new("RGB", (w, min(h, 5000)), (25, 25, 25))
    d = ImageDraw.Draw(img)
    y = 10
    for line in lines:
        d.text((10, y), line[:240], fill=(220, 220, 220), font=f)
        y += 18
    SHOTS.mkdir(parents=True, exist_ok=True)
    img.save(out)


def main():
    raw = LOG.read_text(encoding="utf-8", errors="replace")
    for tag, name in MAP:
        m = f"=== {tag} ==="
        if m not in raw:
            print("skip", tag)
            continue
        chunk = raw.split(m, 1)[1]
        n = chunk.find("\n=== ")
        render((chunk[:n] if n != -1 else chunk).strip(), SHOTS / name)
        print("wrote", name)


if __name__ == "__main__":
    main()
