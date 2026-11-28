#!/usr/bin/env python3
"""WCAG contrast for the token pairs that carry text. Text >= 4.5, large text >= 3.0. Exit 1 on failure."""
import json, pathlib, sys

tok = json.loads((pathlib.Path(__file__).resolve().parent.parent / "tokens/tokens.json").read_text())["color"]

def lum(h):
    h = h.lstrip("#")
    r, g, b = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]
    f = lambda c: c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)

def ratio(a, b):
    la, lb = lum(tok[a]), lum(tok[b])
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)

# (foreground, background, minimum, note)
PAIRS = [
    ("ink900", "paper", 4.5, "body text"),
    ("ink900", "surface", 4.5, "body text on cards"),
    ("surface", "teal600", 4.5, "primary button"),
    ("ink900", "sun500", 4.5, "sun promo CTA / sun banner"),
    ("surface", "teal700", 4.5, "teal banner / pressed button"),
    ("muted", "paper", 4.5, "secondary text"),
    ("muted", "surface", 4.5, "secondary text on cards"),
    ("muted", "sunken", 4.5, "secondary text on sunken"),
    ("dangerText", "dangerBg", 4.5, "danger text on its tint"),
    ("successText", "successBg", 4.5, "success text on its tint"),
    ("danger", "surface", 4.5, "danger text on white"),
    ("success", "surface", 4.5, "success text on white"),
    ("sun700", "sun50", 4.5, "limited-stock tag"),
    ("teal700", "teal50", 4.5, "review pill"),
    ("teal600", "surface", 4.5, "links / active"),
    ("surface", "ink900", 4.5, "on-ink text"),
    ("onInkMuted", "ink900", 4.5, "muted on-ink text"),
    ("disabled", "surface", 1.0, "disabled (informational, exempt from 4.5)"),
]

fail = 0
print(f"{'pair':34}{'ratio':>8}  min  result")
for fg, bg, mn, note in PAIRS:
    r = ratio(fg, bg)
    ok = r >= mn
    fail += 0 if ok else 1
    print(f"{fg + ' on ' + bg:34}{r:8.2f}  {mn:<4} {'PASS' if ok else 'FAIL'}  {note}")
sys.exit(1 if fail else 0)
