# Design research for a custom AI design skill (2026-11-05)

Background: the Rocola landing page was built twice from the same baseline, once with UI UX Pro Max ([PR #1](https://github.com/AAlvAAro/rocola_ex/pull/1)) and once with Impeccable ([PR #2](https://github.com/AAlvAAro/rocola_ex/pull/2), the cassette J-card). This doc collects three research passes for designing your own skill. All links were checked on 2026-11-05. † means a single source or self-reported, and ? means unverified.

---

## 1. AI design skills, plugins and MCPs

| # | Name | Type | What it does | Approach | Footprint | Worth borrowing |
|---|---|---|---|---|---|---|
| 1 | [Anthropic frontend-design](https://github.com/anthropics/skills) | skill | Distinctive frontends; Impeccable started from it | Bans with exact values; plan (4–6 hex colors, type roles, ASCII wireframe), check the plan against generic defaults, then build | markdown | "Spend boldness in one place"; "remove one element before finishing" |
| 2 | [Taste Skill](https://github.com/Leonxlnx/taste-skill) | skill | Anti-slop skill that randomizes part of the design | Classify the page kind; a script deals palette, fonts and one of 11 hero layouts; effects limited by page kind | Node 22+ and Chrome scripts | `consistency.mjs`: PASS/WARN/FAIL at 1440/1024/768/390 px |
| 3 | [ui-craft](https://github.com/educlopez/ui-craft) | skill + commands + agents + MCP | Design-engineering system | 32 reference files; fresh-context design and a11y reviewers; 43-rule detector; 0–100 score; locked style variants | markdown, Go CLI, Node, MCP | Severity-tagged findings with a score that gives the same result on rerun; an `evals/` folder |
| 4 | [OneRedOak design-review](https://github.com/OneRedOak/claude-code-workflows) | agent + command | `/design-review` of the git diff against the live UI | Playwright critic loop: interaction, responsive, polish, a11y, robustness | markdown + Playwright MCP | The reviewer opens the real page, not just the code |
| 5 | [Vercel Web Interface Guidelines](https://github.com/vercel-labs/web-interface-guidelines) | rules + skill | 100+ interaction, forms, motion, a11y and performance rules | The review skill downloads the latest rules each run and reports `file:line` | markdown, network | One remote rules file keeps every project on the same version |
| 6 | [Emil Kowalski skills](https://github.com/emilkowalski/skills) | 17 skills | Animation and design-engineering craft | Single-purpose skills: review-animations, remove-animations, break-ui, prototype | markdown | Small skills; a "remove" skill next to the "add" skill |
| 7 | [UI Skills](https://github.com/ibelick/ui-skills) | registry + MCP | Skills for design engineers | Serves a skill only when a task needs it (`list_skills`/`get_skill`) | npx, remote MCP | Load only what's needed (full list ?) |
| 8 | [Stitch skills](https://github.com/google-labs-code/stitch-skills) | skills for MCP | 15 skills around Google Stitch | `extract-design-md` builds DESIGN.md from code | markdown + Stitch MCP (credentials ?) | DESIGN.md as a portable design spec |
| 9 | [Figma MCP](https://developers.figma.com/docs/figma-mcp-server) | MCP | Figma variables, components and layout into the IDE | Figma bridge + Code Connect | desktop server needs a paid seat | Map design components to real components |
| 10 | [Framelink Figma MCP](https://github.com/GLips/Figma-Context-MCP) | MCP | Figma links to layout and style data | Trims the API response before the model sees it | `FIGMA_API_KEY` | Less context makes the model more accurate |
| 11 | [shadcn MCP](https://ui.shadcn.com/docs/mcp) | MCP | Browse and install registry components | Component catalog | React | A curated catalog instead of invented components |
| 12 | [21st.dev Magic](https://github.com/21st-dev/magic-mcp) | MCP | Search 10k+ components, `get_inspiration` | References before generation | API key, React | Show the agent references first |
| 13 | [Storybook MCP](https://github.com/storybookjs/mcp) | MCP | Component docs and story previews for agents | Grounding in your own components | now part of Storybook 10.6 | Check your component docs before writing UI |
| 14 | [Playwright MCP](https://github.com/microsoft/playwright-mcp) | MCP | Agent-driven browser | Accessibility snapshots + screenshots | npx | The "eyes" behind critic loops |
| 15 | [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) | MCP | Inspect live Chrome | Screenshots + performance traces | npx | A performance check as part of "finished" |
| 16 | [Penpot MCP](https://github.com/penpot/penpot-mcp) | MCP | LLM reads and creates Penpot elements | Open-source design-tool bridge | now in the main Penpot repo | Open alternative to Figma |
| 17 | [Superdesign](https://github.com/superdesigndev/superdesign) | extension | Many mockup options on a canvas | Fork and iterate | extension unmaintained; web app active | "Explore ten options, not one" |
| 18 | [awesome-cursorrules](https://github.com/PatrickJS/awesome-cursorrules) | rules | `.mdc` rule files | Plain conventions | markdown | Mostly framework rules, not taste. Useful as a contrast |

Rows 11–13 only help React projects. For Phoenix/HEEx, the useful parts are the bans with exact values, the plan check, DESIGN.md, a fresh-context Playwright reviewer, and a detector that runs on HEEx/CSS.

**Patterns worth stealing**
- **Bans with exact values** (specific hex, shadow and copy habits) instead of "avoid generic". Impeccable's craft floor is the best example.
- **Plan, check the plan against generic defaults, then build.**
- **Randomness to escape the average:** Taste's deal by page kind, Impeccable's seeded direction roll.
- **Knowledge on demand:** UI UX Pro Max's CSV + search, ui-craft's reference files, ui-skills' MCP.
- **A fresh-context reviewer looking at the real page,** returning severity-tagged findings.
- **Checks that give the same answer every time:** detector hooks, scores, multi-width checks.
- **A design spec in the repo:** PRODUCT.md / DESIGN.md / tokens.
- **Small single-purpose skills** that are easy to version and test.

---

## 2. Award-winning landing and marketing sites (2021–2026)

★ marks the "cultural world" concepts closest to the J-card direction.

| Site | Award | Studio | What's notable | Technique for the skill |
|---|---|---|---|---|
| [Igloo Inc](https://www.igloo.inc/) | [Awwwards SOTY 2024](https://www.awwwards.com/sites/igloo-inc), Webby 2026 | abeto, Bureaux | An icy 3D world in two slate tones | The page as one scene, scrolling as the camera path |
| [Lando Norris](https://landonorris.com/) | [SOTY 2025](https://www.awwwards.com/sites/lando-norris) † | OFF+BRAND | Acid lime `#D2FF00` on `#111112` | One fully saturated signature color on near-black |
| [Opal Tadpole](https://www.opalcamera.com/opal-tadpole) | [SOTD 2024, SOTY nominee](https://www.awwwards.com/sites/opal-tadpole) | Claudio Guglieri | Yellow `#FFDB01`, 3D product | The product as the hero object, one spec per section |
| [Lusion v3](https://lusion.co/) | [D&AD Wood Pencil 2024](https://dandad.org/awards/professional/2024/238109/lusionco), SOTD | Lusion | Electric blue `#1a2ffb` on off-white | One saturated color + a neutral, with motion carrying the page |
| ★ [Mana Yerba Mate](https://en.manayerbamate.com/) | [SOTY 2023 nominee](https://www.awwwards.com/sites/mana-yerba-mate) | Louis Paquet | Illustrated drink brand | Brand character in the footer, 404 and cart |
| [Prometheus Fuels](https://www.prometheusfuels.com/) | [SOTY 2021](https://www.awwwards.com/sites/prometheus-fuels) | Active Theory | Interactive "how it works" story | Explain the product as a story told through scrolling |
| ★ [KPR](https://kprverse.com/) | [SOTY 2022](https://www.awwwards.com/sites/kpr) | Resn | An invented world with lore | Give the brand its own world |
| [Pangram Pangram](https://pangrampangram.com/) | [SOTY 2021 nominee](https://www.awwwards.com/sites/pangram-pangram-foundry) | Locomotive | Black/grey/white foundry | Type specimens as the imagery |
| ★ [The Renaissance Edition](https://www.shopify.com/editions/winter2026) | [SOTM Feb 2026](https://www.awwwards.com/sites/the-renaissance-edition), Webby 2026 | Shopify | 150+ product updates staged in Renaissance paintings | Wrap a feature list in a world borrowed from art history |
| [Dropbox Brand](https://brand.dropbox.com/) | [CSSDA WOTY 2025](https://www.cssdesignawards.com/blog/2025-website-of-the-year-winners/430/) | Daybreak | Guidelines taught through play | Show each rule as something you can interact with |
| ★ [Exat Typeface](https://exat.hottype.co/) | [CSSDA WOTY 2025 Best UI](https://www.cssdesignawards.com/woty2025/sites/exat-typeface) | Studio Size | EXAT 51 modernist grid | Adopt a historical movement's grid and color rules |
| ★ [Slosh Seltzer](https://sloshseltzer.com/) | [SOTM Jun 2024](https://www.awwwards.com/sites/slosh-seltzer) | Buttermax | Maximalism on pink `#ffc1ff` | One dominant background holds the chaos together |
| [ATMOS Lamp](https://ayocin.com/) | [CSSDA WOTY 2024 Best UX](https://www.cssdesignawards.com/woty2024/sites/atmos-lamp-by-ayocin) | Obys | Single-product mood piece | A product page led by type |
| [Sculpting Harmony](https://gehry.getty.edu/) | [Webby 2024](https://winners.webbyawards.com/2024/websites-and-mobile-sites/features-design/best-visual-design-aesthetic/279895/sculpting-harmony) | Getty, Resn | Gehry archive experience | Let the archive material set the art direction |
| [Cowboy](https://cowboy.com/) | [Webby 2024 Function](https://winners.webbyawards.com/2024/websites-and-mobile-sites/features-design/best-visual-design-function/280677/cowboy) | In-house | E-bike commerce | Beautiful and still sells |
| [Terminal Industries](https://terminal-industries.com/) | [SOTM Sep 2025](https://www.awwwards.com/sites/terminal-industries) | REJOUICE | B2B logistics told through scrolling | B2B pages can carry a narrative |
| [Anime.js](https://animejs.com/) / [GSAP](https://gsap.com/) | SOTM May 2025 / Lovie 2024 † | Julian Garnier / ToyFight | Motion libraries that demo themselves | The page itself is the product demo |

**Recurring traits:** one concept per site; one saturated color plus a neutral; the product as hero or demo; scrolling that tells a story; craft in the edges (footer, 404, menus); type as imagery. WebGL is common, but the transferable part is the art direction. Few winners are SaaS pages.

**Where to keep finding them:**
- [Awwwards](https://www.awwwards.com/websites/sites_of_the_month/): tags, hex palettes and tech stack, so it's structured input for a skill.
- [Godly](https://godly.website/): motion.
- [Land-book](https://land-book.com/): section patterns.
- [Lapa Ninja](https://www.lapa.ninja/): by industry.
- [One Page Love](https://onepagelove.com/): single-page sites.
- [siteinspire](https://www.siteinspire.com/): editorial.
- [Httpster](https://httpster.net/): typographic and brutalist.

Cannes Digital Craft Grand Prix winners from 2024–26 weren't websites. The FWA site returned 404s.

---

## 3. The great ad agencies through the years

| Era | Agency | Known for | Landmark campaign |
|---|---|---|---|
| 1950s–60s | Ogilvy & Mather | Research-led long copy, "brand image" | Hathaway eye patch (1951) |
| | Leo Burnett | Warm archetypes and characters | Marlboro Man (1955); #LikeAGirl (2014) |
| | DDB | Creative Revolution, art director + copywriter teams, honesty | VW "Think Small" (1959); Avis "We Try Harder" (1962) |
| | BBDO | Emotional anthems | "Pepsi Generation" (1963) |
| 1970s–80s | Saatchi & Saatchi | Provocative posters | "Labour Isn't Working" (1978) |
| | BBH | Music-led film, "when the world zigs, zag" | Levi's "Launderette" (1985) |
| | AMV | Typographic poster systems | The Economist white-on-red (1988 onward) |
| | Chiat/Day / TBWA | Cinematic launches; "Disruption" | Apple "1984"; the Absolut bottle series; "Think Different" (1997) |
| | Wieden+Kennedy | Culture-first independent | Nike "Just Do It" (1988) |
| 2000s | Crispin Porter + Bogusky | Internet-native earned media | "Subservient Chicken" (2004) |
| | R/GA / AKQA | Product as advertising | Nike+ (2006); Fiat eco:Drive (2009, Cyber Grand Prix) |
| 2010s | Droga5 / Mother | Ideas that work in every medium; irreverence | Jay-Z "Decode" (2010); KFC "FCK" (2018) |

**Cannes Lions Agency of the Year:**
- 2017: Clemenger BBDO Melbourne
- 2018: adam&eveDDB
- 2019: Wieden+Kennedy Portland
- 2020/21: split by track, no single winner
- 2022: Dentsu Creative Bengaluru
- 2023: GUT Buenos Aires
- 2024: Publicis Conseil
- 2025: Publicis Conseil
- 2026: LePub Milan

**Network of the Year:** Ogilvy won 2016, 2022, 2024 and 2026. BBDO won 2017–18, McCann 2019, FCB 2020/21, and DDB 2023 and 2025.

**Ad Age Agency of the Year:**
- 2018–20: Wieden+Kennedy, a three-peat
- 2021: Droga5
- 2022: Mischief †
- 2023: The Martin Agency
- 2024: Mischief
- 2025: Tombras †
- 2026: Rethink

**The One Show Agency of the Year:** FCB New York in 2025, VML New York in 2026.

**WARC #1 network:** Ogilvy, five years running through 2025.

Rankings use different year conventions: Ad Age and WARC judge the previous year's work.

**Web-craft studios:**
- Active Theory: WebGL and XR
- Lusion: Three.js
- Resn: playful, experimental sites
- Locomotive: editorial layouts, smooth scroll
- Hello Monday: interactive storytelling, now part of DEPT
- BASIC/DEPT: brand-led digital
- Work & Co: digital product, now part of Accenture Song
- Instrument: brand systems and websites
- Buck: motion design
- Immersive Garden: cinematic 3D (?)

**Agency takeaways that can become skill rules:**
1. One idea per piece: state the proposition first and cut what doesn't serve it.
2. Build a system, not a one-off: one repeatable device (the Absolut bottle, the Economist red), then vary it.
3. Stay consistent for years: lock type, color, voice and grid; change the content.
4. Turn a weakness into a strength ("Think Small", "We Try Harder").
5. Make it useful: the interface is the ad (Nike+, eco:Drive).
6. Craft is the proof: micro-interactions, loading, scroll.
7. Restraint makes the idea louder.
8. A distinct voice: copy with attitude.

---

## 4. Starting sketch for your own skill

Combining the three sections:
- **Brief first** (Impeccable init + agencies #1): PRODUCT.md with audience, one proposition and "never invent" rules.
- **World selection** (award winners ★ + Impeccable new-work): derive 3 directions from the product's cultural world, plus an optional seeded roll (Taste/Impeccable).
- **A data lookup for safe choices** (UI UX Pro Max): palette, fonts and UX rules from a local CSV, which is quick and leaves an audit trail.
- **Craft floor with exact bans** (Anthropic, Impeccable, Vercel guidelines) + "one saturated color + neutral" + edge craft (404, footer, focus, selection).
- **System, not page** (agencies #2–3): DESIGN.md + tokens written from the built page.
- **Critic loop** (OneRedOak, ui-craft, Impeccable): a fresh-context reviewer with Playwright at 390/768/1440, a disposition vocabulary (fix/ship), at most two rounds.
- **Repeatable check** (Taste `consistency.mjs`, ui-craft detector): a script that runs in `mix precommit`.
