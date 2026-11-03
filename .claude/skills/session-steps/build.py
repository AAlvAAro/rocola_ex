# /// script
# dependencies = ["python-docx", "python-pptx"]
# ///
"""Rebuild docs/steps/rocola-steps.docx (all entries) or a "what's new" deck (entries not yet in a deck).

Usage (from repo root):  uv run .claude/skills/session-steps/build.py docx|deck
Source of truth: docs/steps/steps.json (see SKILL.md for schema). The docx is always rebuilt
from the log, so it grows with every run and never drifts from it.
"""
import json, sys
from datetime import date
from pathlib import Path

DIR = Path("docs/steps")
LOG = DIR / "steps.json"
# Palette/fonts come from style.md (derived from the sample deck).
INK, PAPER, ACCENT, MUTED, CARD_LINE = "131418", "F5F3EF", "B5243E", "6B6E76", "E4E2DC"
SANS, MONO = "Helvetica Neue", "Menlo"
STATUS = {"done": ("Done", "2E7D4F"), "in_progress": ("In progress", "B7791F"), "todo": ("To do", "6B6E76")}


def rgb(h):
    from docx.shared import RGBColor
    return RGBColor.from_string(h)


def shade(cell, hex_):
    from docx.oxml import OxmlElement
    from docx.oxml.ns import qn
    tcPr = cell._tc.get_or_add_tcPr()
    el = OxmlElement("w:shd")
    el.set(qn("w:val"), "clear"); el.set(qn("w:fill"), hex_)
    tcPr.append(el)


def build_docx(log):
    from docx import Document
    from docx.shared import Pt, Cm

    d = Document()
    for s in d.sections:
        s.left_margin = s.right_margin = Cm(2.2)
    st = d.styles["Normal"]; st.font.name = SANS; st.font.size = Pt(10.5)
    for name, size, color in (("Title", 28, INK), ("Heading 1", 18, INK), ("Heading 2", 13, ACCENT)):
        h = d.styles[name]; h.font.name = SANS; h.font.size = Pt(size); h.font.bold = True
        h.font.color.rgb = rgb(color)

    d.add_paragraph("TECH LOG").runs[0].font.name = MONO
    d.add_heading("Rocola: build steps", 0)
    p = d.add_paragraph(f"Updated {date.today():%Y-%m-%d}. Grows with every session.")
    p.runs[0].font.color.rgb = rgb(MUTED)

    d.add_heading("Progress", 1)
    t = d.add_table(rows=1, cols=2); t.style = "Table Grid"
    for c, txt in zip(t.rows[0].cells, ("Topic", "Status")):
        c.text = ""; r = c.paragraphs[0].add_run(txt.upper()); r.font.name = MONO; r.font.size = Pt(9)
        r.bold = True; r.font.color.rgb = rgb("FFFFFF"); shade(c, INK)
    for tp in log["topics"]:
        label, color = STATUS[tp["status"]]
        row = t.add_row().cells
        row[0].text = tp["name"]
        row[1].text = ""; r = row[1].paragraphs[0].add_run(label); r.bold = True; r.font.color.rgb = rgb(color)

    for tp in log["topics"]:
        entries = [e for e in log["entries"] if e["topic"] == tp["name"]]
        if not entries:
            continue
        d.add_heading(tp["name"], 1)
        for e in entries:
            d.add_heading(f'{e["title"]}  ·  {e["date"]}', 2)
            if e.get("summary"):
                d.add_paragraph(e["summary"]).runs[0].italic = True
            for i, s in enumerate(e["steps"], 1):
                p = d.add_paragraph(); p.paragraph_format.space_before = Pt(8); p.paragraph_format.keep_with_next = True
                r = p.add_run(f"Step {i}  "); r.font.name = MONO; r.font.size = Pt(9); r.font.color.rgb = rgb(ACCENT)
                p.add_run(s["title"]).bold = True
                if s.get("detail"):
                    d.add_paragraph(s["detail"])
                if s.get("why"):
                    q = d.add_paragraph(); q.paragraph_format.left_indent = Cm(0.6)
                    q.add_run("Why: ").bold = True; q.add_run(s["why"])
                if s.get("how"):
                    q = d.add_paragraph(); q.paragraph_format.left_indent = Cm(0.6)
                    r = q.add_run(s["how"]); r.font.name = MONO; r.font.size = Pt(9)
    out = DIR / "rocola-steps.docx"
    d.save(out); return out


def build_deck(log):
    from pptx import Presentation
    from pptx.util import Inches, Pt
    from pptx.dml.color import RGBColor
    from pptx.enum.shapes import MSO_SHAPE

    new = [e for e in log["entries"] if not e.get("deck")]
    if not new:
        sys.exit("Nothing new since the last deck.")
    C = lambda h: RGBColor.from_string(h)
    pr = Presentation(); pr.slide_width, pr.slide_height = Inches(13.333), Inches(7.5)
    blank = pr.slide_layouts[6]

    def slide(bg):
        s = pr.slides.add_slide(blank)
        s.background.fill.solid(); s.background.fill.fore_color.rgb = C(bg); return s

    def text(s, x, y, w, h, txt, size, color, font=SANS, bold=False):
        tb = s.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h)); tf = tb.text_frame
        tf.word_wrap = True; r = tf.paragraphs[0].add_run(); r.text = txt
        r.font.size, r.font.name, r.font.bold, r.font.color.rgb = Pt(size), font, bold, C(color)

    def card(s, x, y, w, h, fill="FFFFFF", line=CARD_LINE):
        sh = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(x), Inches(y), Inches(w), Inches(h))
        sh.fill.solid(); sh.fill.fore_color.rgb = C(fill); sh.line.color.rgb = C(line); sh.shadow.inherit = False
        return sh

    s = slide(INK)
    text(s, 0.9, 0.9, 6, 0.4, "WHAT'S NEW", 12, "A9ABB2", MONO)
    text(s, 0.9, 2.7, 11.5, 1.3, "Rocola: " + ", ".join(sorted({e["topic"] for e in new})), 44, "F5F3EF", bold=True)
    text(s, 0.9, 5.2, 8, 0.4, f"{date.today():%Y-%m-%d}  ·  elixir + phoenix liveview + spotify web api", 11, "A9ABB2", MONO)

    for e in new:  # one summary slide per entry: headline + up to 3 takeaways, not the step-by-step
        s = slide(PAPER)
        text(s, 0.9, 0.85, 8, 0.4, e["topic"].upper(), 11, MUTED, MONO)
        text(s, 0.9, 1.2, 11.5, 0.9, e.get("headline", e["title"]), 32, INK, bold=True)
        pts = (e.get("takeaways") or [x["title"] for x in e["steps"]])[:3]
        w, gap = 3.55, 0.45
        for i, t in enumerate(pts):
            x = 0.9 + i * (w + gap)
            card(s, x, 2.6, w, 2.2)
            text(s, x + 0.3, 2.8, 3, 0.4, f"{i + 1}", 11, ACCENT if i == len(pts) - 1 else MUTED, MONO)
            text(s, x + 0.3, 3.3, 3, 1.4, t, 16, INK, bold=True)
        if e.get("summary"):
            text(s, 0.9, 5.2, 11.5, 0.9, e["summary"], 14, "3A3C42")

    s = slide(PAPER)
    text(s, 0.9, 0.85, 8, 0.4, "PROGRESS", 11, MUTED, MONO)
    text(s, 0.9, 1.2, 11.5, 0.9, "Where we are", 32, INK, bold=True)
    for i, tp in enumerate(log["topics"][:3]):
        label, color = STATUS[tp["status"]]; x = 0.9 + i * 3.9
        card(s, x, 2.6, 3.5, 2.0)
        text(s, x + 0.3, 2.85, 3, 0.4, label.upper(), 11, color, MONO, True)
        text(s, x + 0.3, 3.4, 3, 0.8, tp["name"], 22, INK, bold=True)

    for e in new:
        e["deck"] = True
    out = DIR / f"whats-new-{date.today():%Y%m%d}.pptx"
    pr.save(out); return out


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd not in ("docx", "deck"):
        sys.exit(__doc__)
    log = json.loads(LOG.read_text())
    out = (build_docx if cmd == "docx" else build_deck)(log)
    if cmd == "deck":
        LOG.write_text(json.dumps(log, indent=2, ensure_ascii=False))  # persist deck=true flags
    print(out)
