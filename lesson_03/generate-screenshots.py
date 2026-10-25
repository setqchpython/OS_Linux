#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
SHOTS = ROOT / "screenshots"
LOG = ROOT / "_capture" / "terminal.log"
SECTIONS = [
    ("01-id", "01-id.png"),
    ("02-shadow", "02-shadow.png"),
    ("03-groups", "03-groups.png"),
    ("04-sudo", "04-sudo.png"),
    ("05-team", "05-team.png"),
    ("06-dirs", "06-dirs.png"),
    ("07-access", "07-access.png"),
    ("08-check", "08-check.png"),
    ("09-denied", "09-denied.png"),
    ("10-setup-team", "10-setup-team.png"),
]


def load_font(size: int):
    for name in ("DejaVuSansMono.ttf", "Consolas.ttf", "cour.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


def render(text: str, out: Path):
    font = load_font(14)
    lines = text.rstrip("\n").split("\n")
    lh = 20
    pad = 12
    w = min(max(len(l) for l in lines) * 9 + pad * 2, 800)
    h = len(lines) * lh + pad * 2
    img = Image.new("RGB", (w, min(h, 4000)), (28, 28, 28))
    draw = ImageDraw.Draw(img)
    y = pad
    for line in lines[:180]:
        draw.text((pad, y), line[:200], fill=(230, 230, 230), font=font)
        y += lh
    SHOTS.mkdir(parents=True, exist_ok=True)
    img.save(out)


def main():
    raw = LOG.read_text(encoding="utf-8", errors="replace")
    for marker, fname in SECTIONS:
        tag = f"=== {marker} ==="
        if tag not in raw:
            print("skip", marker)
            continue
        chunk = raw.split(tag, 1)[1]
        nxt = chunk.find("\n=== ")
        body = chunk[:nxt] if nxt != -1 else chunk
        render(body.strip(), SHOTS / fname)
        print("wrote", fname)


if __name__ == "__main__":
    main()
