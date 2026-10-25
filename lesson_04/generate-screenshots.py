#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
SHOTS = ROOT / "screenshots"
LOG = ROOT / "_capture" / "terminal.log"
SECTIONS = [
    ("01-ls-l", "01-ls-l.png"),
    ("02-dir-rx", "02-dir-rx.png"),
    ("03-dir-w", "03-dir-w.png"),
    ("04-chmod", "04-chmod.png"),
    ("05-chown", "05-chown.png"),
    ("06-umask", "06-umask.png"),
    ("07-shop-dirs", "07-shop-dirs.png"),
    ("08-shop-access", "08-shop-access.png"),
    ("09-shop-check", "09-shop-check.png"),
]


def font(sz):
    for n in ("DejaVuSansMono.ttf", "Consolas.ttf", "cour.ttf"):
        try:
            return ImageFont.truetype(n, sz)
        except OSError:
            pass
    return ImageFont.load_default()


def render(text, out):
    f = font(14)
    lines = text.rstrip().split("\n")[:200]
    w = min(max(len(l) for l in lines) * 9 + 24, 1000)
    h = len(lines) * 20 + 24
    img = Image.new("RGB", (w, min(h, 4500)), (28, 28, 28))
    d = ImageDraw.Draw(img)
    y = 12
    for line in lines:
        d.text((12, y), line[:220], fill=(230, 230, 230), font=f)
        y += 20
    SHOTS.mkdir(parents=True, exist_ok=True)
    img.save(out)


def main():
    raw = LOG.read_text(encoding="utf-8", errors="replace")
    for tag, name in SECTIONS:
        mark = f"=== {tag} ==="
        if mark not in raw:
            print("skip", tag)
            continue
        chunk = raw.split(mark, 1)[1]
        n = chunk.find("\n=== ")
        render((chunk[:n] if n != -1 else chunk).strip(), SHOTS / name)
        print("wrote", name)


if __name__ == "__main__":
    main()
