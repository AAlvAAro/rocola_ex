# Deck style (derived from "Semantic Search in Rails.pdf")

Editorial, quiet, lots of whitespace. Implemented in `build.py`; change tokens there.

| Token | Value | Use |
|---|---|---|
| ink | `#131418` | title-slide background, headlines, dark pills |
| paper | `#F5F3EF` | content-slide background |
| accent | `#B5243E` | one highlight per slide (last step, key number, cutoff line) |
| muted | `#6B6E76` | eyebrows, captions |
| card line | `#E4E2DC` | 1px border on white cards |
| sans | Helvetica Neue (sample uses a grotesque like Söhne) | headlines bold, body regular |
| mono | Menlo | eyebrows (UPPERCASE, small), numbers, code |

Layout: 16:9, 0.9in left margin. Every content slide = mono eyebrow (topic) + bold headline (a
claim, not a label) + white cards (max 3 takeaways in the deck, numbered, one line each; step detail belongs in the docx) + optional one-line caption.
Title slide is dark, eyebrow top-left, huge headline, mono tech-stack line bottom-left.
Never: gradients, shadows, stock icons, more than one accent per slide, bullet lists.
