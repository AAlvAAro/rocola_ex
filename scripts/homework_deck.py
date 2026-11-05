# /// script
# dependencies = ["python-pptx"]
# ///
"""Homework 1 deck: goal, CLAUDE.md, SKILL.md, guardrails. Code is read from the repo, so it can't drift.
Run from repo root:  uv run scripts/homework_deck.py   ->  docs/steps/rocola-homework-1.pptx
Style tokens come from the session-steps skill's build.py (derived from the sample deck).
"""
import re, sys
from pathlib import Path
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE

sys.path.insert(0, ".claude/skills/session-steps")
from build import INK, PAPER, ACCENT, MUTED, CARD_LINE, SANS, MONO  # noqa: E402

C = RGBColor.from_string
pr = Presentation(); pr.slide_width, pr.slide_height = Inches(13.333), Inches(7.5)


def slide(bg):
    s = pr.slides.add_slide(pr.slide_layouts[6])
    s.background.fill.solid(); s.background.fill.fore_color.rgb = C(bg); return s


def text(s, x, y, w, h, txt, size, color, font=SANS, bold=False):
    tb = s.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h)); tf = tb.text_frame; tf.word_wrap = True
    r = tf.paragraphs[0].add_run(); r.text = txt
    r.font.size, r.font.name, r.font.bold, r.font.color.rgb = Pt(size), font, bold, C(color)


def card(s, x, y, w, h, fill="FFFFFF", line=CARD_LINE):
    sh = s.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(x), Inches(y), Inches(w), Inches(h))
    sh.fill.solid(); sh.fill.fore_color.rgb = C(fill); sh.line.color.rgb = C(line); sh.shadow.inherit = False


def code(s, x, y, w, lines, size=10, color=INK):
    h = 0.3 + len(lines) * size * 1.25 / 72
    card(s, x, y, w, h)
    tb = s.shapes.add_textbox(Inches(x + 0.25), Inches(y + 0.15), Inches(w - 0.4), Inches(h)); tf = tb.text_frame
    tf.word_wrap = False
    for i, ln in enumerate(lines):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        r = p.add_run(); r.text = ln or " "
        r.font.size, r.font.name, r.font.color.rgb = Pt(size), MONO, C(color)
    return y + h


def content(eyebrow, headline):
    s = slide(PAPER)
    text(s, 0.9, 0.85, 8, 0.4, eyebrow, 11, MUTED, MONO)
    text(s, 0.9, 1.2, 11.5, 0.9, headline, 32, INK, bold=True)
    return s


def block(path, start, end=None, skip=0, n=None):
    """Lines of `path` from the line matching `start` up to (excluding) the one matching `end`."""
    ls = Path(path).read_text().splitlines()
    a = next(i for i, l in enumerate(ls) if re.search(start, l))
    b = next((i for i in range(a + 1, len(ls)) if end and re.search(end, ls[i])), len(ls))
    out = [l.rstrip() for l in ls[a + skip:b]]
    while out and not out[-1]: out.pop()
    return out[:n] if n else out


# 1. Title
s = slide(INK)
text(s, 0.9, 0.9, 11, 0.4, "HOMEWORK 1  ·  FOUNDATIONS OF AGENTIC DEVELOPMENT", 12, "A9ABB2", MONO)
text(s, 0.9, 2.7, 11.5, 1.3, "Rocola", 66, "F5F3EF", bold=True)
text(s, 0.9, 4.0, 10, 1, "A jukebox for get-togethers, built with a CLAUDE.md, a skill and a guardrail", 20, "A9ABB2")
text(s, 0.9, 6.5, 11, 0.4, "elixir + phoenix liveview + sqlite + spotify behaviour", 11, "A9ABB2", MONO)

# 2. Goal
s = content("THE PROJECT", "Guests pick the music from their phones")
for i, (t, d) in enumerate([("Scan, search, request", "Guests scan a QR code, search songs and add them to a shared queue."),
                            ("A Pi in charge", "A Raspberry Pi runs the app and controls a Spotify Connect device. It never plays audio."),
                            ("Personal use only", "Spotify's terms forbid public venues, so nothing here is built for commercial use.")]):
    x = 0.9 + i * 4.0; card(s, x, 2.5, 3.6, 2.5)
    text(s, x + 0.3, 2.7, 3, 0.4, str(i + 1), 11, ACCENT if i == 2 else MUTED, MONO)
    text(s, x + 0.3, 3.1, 3.1, 0.6, t, 18, INK, bold=True)
    text(s, x + 0.3, 3.7, 3.1, 1.3, d, 12, "3A3C42")
text(s, 0.9, 5.4, 11.5, 0.8, "Spotify sits behind a behaviour with a Fake adapter, so it runs and tests with no account or token.", 14, "3A3C42")

# 3. CLAUDE.md
s = content("1 · CLAUDE.MD", "Always-loaded rules keep the agent on track")
y = code(s, 0.9, 2.3, 11.5, block("CLAUDE.md", r"^## Rules", r"^## Tidewave", skip=1), size=9)
text(s, 0.9, y + 0.25, 11.5, 0.9, "Loaded into every session. Nine short, checkable rules: how to finish a task, "
     "where Spotify code goes, what must never be logged or edited.", 14, "3A3C42")

# 4. SKILL.md
s = content("2 · SKILL.MD", "A skill loads only when its description matches")
import textwrap
sk = Path(".claude/skills/spotify-web-api/SKILL.md")
front = block(sk, r"^---$", r"^# Spotify in Rocola")
front = [w for l in front for w in (textwrap.wrap(l, 135, subsequent_indent="  ") or [""])]
steps = block(sk, r"^## Recipe", r"^## Real API rules", n=7)
y = code(s, 0.9, 2.3, 11.5, front[:6] + steps, size=9)
text(s, 0.9, y + 0.25, 11.5, 1.0, "Only the name and one-line description sit in context. The body and reference file "
     "load when a prompt matches: \"Add a live now-playing banner\" triggers it, \"Rename AdminLive to HostLive\" doesn't.", 14, "3A3C42")

# 5. Guardrail hook
s = content("3 · GUARDRAIL", "A hook blocks dangerous calls before they run")
hook = block(".claude/hooks/protect.sh", r"^  Bash\)", r"^    ;;")
y = code(s, 0.9, 2.3, 11.5, [re.sub(r"(.{140}).+", r"\1…", l) for l in hook], size=9)
text(s, 0.9, y + 0.25, 11.5, 1.0, "A PreToolUse hook reads each tool call, and exit 2 blocks it and tells Claude why. "
     "It stops secret access, edits to existing migrations, force pushes and mix ecto.reset.", 14, "3A3C42")

# 6. Deny rules + holes
s = content("3 · GUARDRAIL", "Deny rules back it up, and red-teaming finds the holes")
deny = block(".claude/settings.json", r'"permissions"', skip=1)
y = code(s, 0.9, 2.3, 6.6, [l for l in deny if l.strip() not in ("}", "},")][:9], size=9)
card(s, 7.9, 2.3, 4.5, 3.0, INK, INK)
text(s, 8.2, 2.5, 4, 0.4, "KNOWN HOLES", 11, "A9ABB2", MONO)
for i, t in enumerate(["cat .e* passes: a wildcard hides the file name", "A python one-liner can append to a migration",
                       "False positive: text that mentions the secret file name is blocked"]):
    text(s, 8.2, 3.0 + i * 0.75, 3.9, 0.7, t, 13, "F5F3EF")
text(s, 0.9, 5.7, 11.5, 0.8, "Deny rules cover plain file access; the hook covers shell tricks. "
     "Next, a partner tries to bypass it and each fix goes in the log.", 14, "3A3C42")

# 7. Benchmark (rows come from docs/bench/results.csv; "with skill" shows pending until that run exists)
import csv
rows = {}
for r in csv.DictReader(open("docs/bench/results.csv")):
    rows.setdefault(r["prompt"], {})[r["label"]] = r
names = {"P1": "Live now-playing banner", "P2": "Vote to skip", "P3": "Admin device list"}


def cell(r):
    if not r: return "pending"
    score = sum(int(r[k]) for k in ("via_behaviour", "fake_updated", "no_net_tests", "add_only_queue"))
    return f"${float(r['cost_usd']):.2f} · {r['turns']} turns · {r['duration_s']}s · {score}/4"


s = content("MEASUREMENT", "Same three prompts, with and without the skill")
x0, cw = [0.9, 4.4, 8.4], [3.5, 4.0, 4.0]
card(s, 0.9, 2.3, 11.5, 0.55, "FFFFFF", CARD_LINE)
card(s, 8.4, 2.3, 4.0, 0.55 + 3 * 0.7, "F5E3E6", "F5E3E6")  # accent tint on the with-skill column
for x, t in zip(x0, ("PROMPT", "BASELINE (NO SKILL)", "WITH SKILL")):
    text(s, x + 0.15, 2.42, cw[0], 0.4, t, 10, ACCENT if t == "WITH SKILL" else MUTED, MONO)
for i, (k, v) in enumerate(sorted(rows.items())):
    y = 2.95 + i * 0.7
    card(s, 0.9, y, 7.5, 0.7); text(s, 1.05, y + 0.18, 3.3, 0.4, names.get(k, k), 14, INK)
    text(s, 4.55, y + 0.2, 3.8, 0.4, cell(v.get("baseline")), 11, INK, MONO)
    text(s, 8.55, y + 0.2, 3.8, 0.4, cell(v.get("with_skill")), 11, ACCENT, MONO)
text(s, 0.9, 5.4, 11.5, 0.9, "Checks (out of 4): went through the behaviour, updated the Fake, no network in tests, add-only queue. "
     "Every `mix precommit` passed.", 13, "3A3C42")

# Footer on every slide: the repo
for i, sl in enumerate(pr.slides):
    text(sl, 0.9, 6.95, 8, 0.3, "github.com/AAlvAAro/rocola_ex", 9, "A9ABB2" if i == 0 else MUTED, MONO)

out = Path("docs/steps/rocola-homework-1.pptx"); out.parent.mkdir(parents=True, exist_ok=True)
pr.save(out); print(out)
