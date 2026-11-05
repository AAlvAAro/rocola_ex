# /// script
# dependencies = ["python-pptx"]
# ///
"""Rebuild docs/steps/rocola-steps.pptx from docs/steps/steps.json (all entries, always in sync).

Usage (from repo root):  uv run .claude/skills/session-steps/build.py
Per entry: headline + general steps (step titles only) + a code example read from the repo.
Entry `code` is {"lines": [...]} or {"file", "start", "end"?, "skip"?, "n"?} (regexes; see block()).
"""
import json, re, sys
from datetime import date
from pathlib import Path

DIR = Path("docs/steps")
LOG = DIR / "steps.json"
# Tokens from style.md (derived from the sample deck).
INK, PAPER, ACCENT, MUTED, CARD_LINE = "131418", "F5F3EF", "B5243E", "6B6E76", "E4E2DC"
SANS, MONO = "Helvetica Neue", "Menlo"
STATUS = {"done": ("Done", "2E7D4F"), "in_progress": ("In progress", "B7791F"), "todo": ("To do", "6B6E76")}


def block(path, start, end=None, skip=0, n=None):
    """Lines of `path` from the line matching `start` up to (excluding) the one matching `end`."""
    ls = Path(path).read_text().splitlines()
    a = next(i for i, l in enumerate(ls) if re.search(start, l))
    b = next((i for i in range(a + 1, len(ls)) if end and re.search(end, ls[i])), len(ls))
    out = [l.rstrip() for l in ls[a + skip:b]]
    while out and not out[-1]:
        out.pop()
    return out[:n] if n else out


def code_lines(e):
    c = e.get("code") or {}
    if "lines" in c:
        return c["lines"]
    if "file" in c:
        return block(c["file"], c["start"], c.get("end"), c.get("skip", 0), c.get("n", 14))
    how = [s["how"] for s in e["steps"] if s.get("how")]
    return how[-1:] if how else []


def build_deck(log):
    from pptx import Presentation
    from pptx.util import Inches, Pt
    from pptx.dml.color import RGBColor
    from pptx.enum.shapes import MSO_SHAPE

    C = RGBColor.from_string
    pr = Presentation(); pr.slide_width, pr.slide_height = Inches(13.333), Inches(7.5)

    def slide(bg):
        s = pr.slides.add_slide(pr.slide_layouts[6])
        s.background.fill.solid(); s.background.fill.fore_color.rgb = C(bg); return s

    def text(s, x, y, w, h, txt, size, color, font=SANS, bold=False):
        tb = s.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h)); tf = tb.text_frame
        tf.word_wrap = True; r = tf.paragraphs[0].add_run(); r.text = txt
        r.font.size, r.font.name, r.font.bold, r.font.color.rgb = Pt(size), font, bold, C(color)

    def card(s, x, y, w, h, fill="FFFFFF", line=CARD_LINE):
        sh = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(x), Inches(y), Inches(w), Inches(h))
        sh.fill.solid(); sh.fill.fore_color.rgb = C(fill); sh.line.color.rgb = C(line); sh.shadow.inherit = False

    def code(s, x, y, w, lines, size=9):
        h = 0.3 + len(lines) * size * 1.25 / 72
        card(s, x, y, w, h)
        tf = s.shapes.add_textbox(Inches(x + 0.25), Inches(y + 0.15), Inches(w - 0.4), Inches(h)).text_frame
        tf.word_wrap = False
        for i, ln in enumerate(lines):
            p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
            r = p.add_run(); r.text = re.sub(r"(.{140}).+", r"\1…", ln) or " "
            r.font.size, r.font.name, r.font.color.rgb = Pt(size), MONO, C(INK)
        return y + h

    # Title
    s = slide(INK)
    text(s, 0.9, 0.9, 6, 0.4, "BUILD STEPS", 12, "A9ABB2", MONO)
    text(s, 0.9, 2.7, 11.5, 1.3, "Rocola: " + ", ".join(t["name"] for t in log["topics"]), 44, "F5F3EF", bold=True)
    text(s, 0.9, 5.2, 8, 0.4, f"{date.today():%Y-%m-%d}  ·  elixir + phoenix liveview + spotify web api", 11, "A9ABB2", MONO)

    # One slide per entry: headline, general steps (titles only), code example, one-line summary
    for e in log["entries"]:
        s = slide(PAPER)
        text(s, 0.9, 0.85, 8, 0.4, e["topic"].upper(), 11, MUTED, MONO)
        text(s, 0.9, 1.2, 11.5, 0.9, e.get("headline", e["title"]), 32, INK, bold=True)
        steps = e["steps"][:4]
        w, gap = (11.5 - 0.3 * (len(steps) - 1)) / len(steps), 0.3
        for i, st in enumerate(steps):
            x = 0.9 + i * (w + gap)
            card(s, x, 2.2, w, 0.9)
            text(s, x + 0.2, 2.3, 0.5, 0.3, str(i + 1), 10, ACCENT if i == len(steps) - 1 else MUTED, MONO)
            text(s, x + 0.2, 2.6, w - 0.3, 0.5, st["title"], 13, INK, bold=True)
        y = 3.4
        lines = code_lines(e)
        if lines:
            y = code(s, 0.9, 3.4, 11.5, lines) + 0.25
        if e.get("summary"):
            text(s, 0.9, y, 11.5, 0.9, e["summary"], 14, "3A3C42")

    # Progress
    s = slide(PAPER)
    text(s, 0.9, 0.85, 8, 0.4, "PROGRESS", 11, MUTED, MONO)
    text(s, 0.9, 1.2, 11.5, 0.9, "Where we are", 32, INK, bold=True)
    for i, tp in enumerate(log["topics"][:3]):
        label, color = STATUS[tp["status"]]; x = 0.9 + i * 3.9
        card(s, x, 2.6, 3.5, 2.0)
        text(s, x + 0.3, 2.85, 3, 0.4, label.upper(), 11, color, MONO, True)
        text(s, x + 0.3, 3.4, 3, 0.8, tp["name"], 22, INK, bold=True)

    out = DIR / "rocola-steps.pptx"
    pr.save(out); return out


if __name__ == "__main__":
    if len(sys.argv) > 1:
        sys.exit(__doc__)
    print(build_deck(json.loads(LOG.read_text())))
