#!/usr/bin/env python3
"""Render terminal-style PNGs for lesson_02 report (from captured log)."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
SHOTS = ROOT / "screenshots"
LOG = ROOT / "_capture" / "terminal.log"

# Map section markers in log to output files
SECTIONS = [
    ("01-site-tree", "01-site-tree.png"),
    ("02-inbox", "02-inbox.png"),
    ("03-cp-i", "03-cp-i.png"),
    ("04-rmdir", "04-rmdir.png"),
    ("05-masks", "05-masks.png"),
    ("06-find", "06-find.png"),
    ("07-locate", "07-locate.png"),
    ("08-man", "08-man.png"),
    ("09-sorted", "09-sorted.png"),
    ("10-check", "10-check.png"),
]


def load_font(size: int):
    for name in ("Consolas.ttf", "cour.ttf", "lucon.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


def render_block(text: str, out: Path):
    font = load_font(16)
    lines = text.rstrip("\n").split("\n")
    line_h = 22
    pad = 16
    w = min(max((len(l) for l in lines), default=40) * 10 + pad * 2, 900)
    h = len(lines) * line_h + pad * 2
    img = Image.new("RGB", (w, h), (30, 30, 30))
    draw = ImageDraw.Draw(img)
    y = pad
    for line in lines:
        draw.text((pad, y), line, fill=(220, 220, 220), font=font)
        y += line_h
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)


def main():
    if not LOG.exists():
        print("Missing", LOG)
        return 1
    raw = LOG.read_text(encoding="utf-8", errors="replace")
    for marker, fname in SECTIONS:
        start = f"=== {marker} ==="
        if start not in raw:
            print("skip", marker)
            continue
        chunk = raw.split(start, 1)[1]
        end = chunk.find("\n=== ")
        body = chunk[:end] if end != -1 else chunk
        render_block(body.strip(), SHOTS / fname)
        print("wrote", fname)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
