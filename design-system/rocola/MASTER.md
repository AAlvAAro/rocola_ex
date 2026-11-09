# Rocola design system (MASTER)

Derived from the `ui-ux-pro-max` skill data in `.claude/skills/ui-ux-pro-max/data/`.
Built by reading the CSVs directly. The skill's `search.py --design-system` wasn't run.
Page-specific overrides go in `pages/<page>.md`.

## Match
- Product: #45 **Music Streaming** (`products.csv`, `ui-reasoning.csv`)
- Pattern: **Hero + Features + CTA** (`landing.csv` #1)
- Style: **Dark Mode (OLED) + Vibrant & Block-based** (`styles.csv` #7, #6)
- Avoid (from reasoning): cluttered layout, light-mode-first, emoji icons, pricing/social proof (out of scope for Rocola)

## Color (`colors.csv` #45, daisyUI theme `rocola` in `assets/css/app.css`)
| Token | Hex | Use |
|---|---|---|
| base-100 | `#0F0F23` | page background |
| base-200 | `#1B1B30` | cards |
| base-300 | `#27273B` | muted surfaces, dividers |
| base-content | `#F8FAFC` | text (muted: `#94A3B8` ≈ `/60`–`/75`) |
| primary | `#22C55E` on `#0F172A` | "play green" CTA, highlights |
| secondary | `#4338CA` on `#FFFFFF` | indigo blocks |
| accent | `#1E1B4B` | deep indigo details |
| neutral | `#312E81` | borders |

## Type (`typography.csv` #7 "Bold Statement")
- Display: **Bebas Neue** (`font-display`), headings, step numbers
- Body: **Source Sans 3** 400/600/700 (`font-body`), 18px+ on the landing

## Effects
- Large blocks, 1rem–1.5rem radii, 48px+ section gaps
- Color-shift hovers at 200ms; equalizer bars (`animate-eq`) with `motion-reduce:animate-none`

## Rules checked (`ux-guidelines.csv` priorities 1–6)
- Text contrast ≥ 4.5:1 (green/navy ≈ 8:1, indigo/white ≈ 7:1)
- Touch targets ≥ 44px (`min-h-12` CTA)
- Visible focus rings, SVG icons only (heroicons), reduced motion respected
