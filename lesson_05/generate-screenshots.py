#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
LOG = ROOT / "_capture" / "terminal.log"
SHOTS = ROOT / "screenshots"
MAP = [
    ("01-process", "01-process.png"),
    ("02-tree", "02-tree.png"),
    ("03-states", "03-states.png"),
    ("04-jobs", "04-jobs.png"),
    ("05-signals", "05-signals.png"),
    ("06-exit", "06-exit.png"),
    ("07-lab-tree", "07-lab-tree.png"),
    ("08-lab-signals", "08-lab-signals.png"),
    ("09-lab-check", "09-lab-check.png"),
    ("10-graceful", "10-graceful.png"),
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
