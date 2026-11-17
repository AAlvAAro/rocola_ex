---
name: Rocola
description: A home jukebox whose pages are printed as a cassette J-card lying on a cobalt cassette shell.
colors:
  tape-shell: "#2140C4"
  tape-shell-ink: "#C9D3FA"
  tape-card: "#F25430"
  tape-card-ink: "#B83214"
  tape-stripe: "#F6B827"
  tape-label: "#FBFCFE"
  tape-rule: "#BFD0F5"
  tape-ink: "#141414"
typography:
  display:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(2.25rem, 7.8cqi, 5.5rem)"
    fontWeight: 900
    lineHeight: 0.92
    letterSpacing: "-0.025em"
    fontVariation: "\"wdth\" 125"
  headline:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "3rem"
    fontWeight: 900
    lineHeight: 1
    letterSpacing: "-0.025em"
    fontVariation: "\"wdth\" 125"
  title:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "1.5rem"
    fontWeight: 800
    lineHeight: 1.33
    fontVariation: "\"wdth\" 100"
  body:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "1.125rem"
    fontWeight: 400
    lineHeight: 1.375
    fontVariation: "\"wdth\" 100"
  label:
    fontFamily: "Special Elite, ui-monospace, monospace"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: "0.15em"
  hand:
    fontFamily: "Permanent Marker, cursive"
    fontSize: "1.5rem"
    fontWeight: 400
    lineHeight: 1.33
  button:
    fontFamily: "Archivo, ui-sans-serif, system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 700
    lineHeight: 1.5
    letterSpacing: "0.025em"
rounded:
  label: "0.25rem"
  card: "0.375rem"
  window: "9999px"
spacing:
  gutter-sm: "16px"
  gutter: "32px"
  rule: "48px"
  section: "80px"
components:
  button-primary:
    backgroundColor: "{colors.tape-label}"
    textColor: "{colors.tape-ink}"
    typography: "{typography.button}"
    rounded: "{rounded.label}"
    padding: "0 24px"
    height: "48px"
  button-primary-hover:
    backgroundColor: "{colors.tape-stripe}"
    textColor: "{colors.tape-ink}"
  jcard-panel:
    backgroundColor: "{colors.tape-card}"
    textColor: "{colors.tape-ink}"
    rounded: "{rounded.card}"
  tracklist-label:
    backgroundColor: "{colors.tape-label}"
    textColor: "{colors.tape-ink}"
    typography: "{typography.hand}"
    rounded: "{rounded.label}"
    padding: "4px 20px 8px"
  liner-notes:
    backgroundColor: "{colors.tape-card}"
    textColor: "{colors.tape-ink}"
    rounded: "{rounded.label}"
    padding: "32px"
  cassette-window:
    backgroundColor: "{colors.tape-ink}"
    rounded: "{rounded.window}"
    padding: "6px 12px"
---

# Design System: Rocola

## Overview

**Creative North Star: "Tonight's Mix"**

Rocola is printed, not rendered. Every surface is a piece of cassette packaging: a tomato card-stock J-card lying on a cobalt cassette shell, with a chrome-tape stripe band, a cool-white ruled label written on in black marker, and typewriter captions. The queue is a mixtape the whole room writes, so the system's job is to make a shared list feel handmade and fair, not to look like a streaming app.

The palette is loud and warm-on-cool: two saturated grounds (cobalt and tomato) carry near-black ink, and a single mustard accent marks everything interactive. Depth is physical, the way paper sits on plastic: soft cast shadows under the card and labels, never glow. Three voices share the work: an extended heavy grotesk prints headings like a J-card title, a typewriter face does the small factual labels, and a marker hand fills in what guests wrote.

The world is a single fixed scheme. It does not change with the OS light/dark preference; cobalt, tomato and white are the same at midnight as at noon.

**Key Characteristics:**
- Cobalt shell ground, tomato card panels, white ruled labels, near-black ink.
- Mustard is the only interactive accent (focus ring, hover, selection, caret).
- Extended uppercase Archivo headings; Special Elite labels; Permanent Marker entries.
- Ruled 48px rows on labels; dashed fold and perforation lines.
- Soft cast shadows only; small 4–6px corners.
- Motion is mechanical and small: turning reels, a blinking caret, a key that presses down.

## Colors

A cassette's own materials: cobalt plastic, tomato card, chrome stripe, white label, black ink.

### Primary
- **Tomato Card Stock** (#F25430): the J-card panel and liner-notes cards. Ink sits on it directly (5.3:1). It is a ground, not a highlight: it covers whole panels.
- **Burnt Card Ink** (#B83214): the tomato's deep tone, used for side/track codes (B1, B2, B3) on white labels (5.8:1) and the full spool ring in the cassette window.

### Secondary
- **Chrome Mustard** (#F6B827): the stripe band's lead color and the system's only interactive accent: focus outline, button hover fill, text selection, caret, scrollbar thumb, form accent.

### Neutral
- **Cobalt Shell** (#2140C4): the page ground everything lies on.
- **Shell Frost** (#C9D3FA): small text set directly on the shell (header tagline, footer disclaimer), 5.5:1.
- **Label White** (#FBFCFE): tracklist labels, step lists, the primary key, the stripe band's lower band.
- **Ruled Blue** (#BFD0F5): ruled lines on labels and dividers between list rows.
- **Marker Ink** (#141414): all text on card and label, the stripe band's middle band, the key's bottom edge, the cassette window. Secondary copy uses it at 70–75% opacity, never a new grey.

### Named Rules
**The One Mustard Rule.** Mustard means "you can act here" (focus, hover, selection, caret) plus its native place in the stripe band. It never fills a panel or colors body text.

**The Ink-Not-Grey Rule.** Quiet text on card or label is Marker Ink at reduced opacity (70% for codes and captions, 75% for step descriptions), not a separate grey token.

## Typography

**Display Font:** Archivo (variable, wdth 100–125, wght 400–900; fallback ui-sans-serif, system-ui)
**Label Font:** Special Elite (fallback ui-monospace)
**Hand Font:** Permanent Marker (fallback cursive)

**Character:** A J-card title press, a typewriter, and a marker. Archivo stretched to 125 width and set at 900 reads like a printed cassette title; Special Elite reads like the label maker on the spine; Permanent Marker is the only thing that looks written by a person.

### Hierarchy
- **Display** (900, wdth 125, clamp(2.25rem, 7.8cqi, 5.5rem), line-height 0.92, uppercase, -0.025em, balanced wrap): the panel title, sized to the panel's container width, capped well under 6rem.
- **Headline** (900, wdth 125, 1.875rem mobile / 3rem from 640px, uppercase, -0.025em): section titles on card ("Side B: how it works", "House rules"). The wordmark uses the same voice at 1.5rem / 1.875rem.
- **Title** (800, wdth 100, 1.5rem): item titles inside label lists.
- **Body** (400, wdth 100, 1.125rem, line-height 1.375, max ~36rem): explanatory copy on card and label.
- **Label** (Special Elite, 0.75–1.125rem, uppercase with 0.15–0.2em tracking when it names a side or spine; sentence case for liner notes and captions): spine, side names, track numbers, step codes, house rules, tagline, footer.
- **Hand** (Permanent Marker, 1.125rem mobile / 1.5rem from 640px): tracklist entries and guest names only.

### Named Rules
**The Three Voices Rule.** Print (Archivo) explains, typewriter (Special Elite) labels and states facts, marker (Permanent Marker) is what guests wrote. Don't swap their jobs.

**The Wide Title Rule.** Only Display, Headline and the wordmark get wdth 125 and uppercase; body and titles stay at wdth 100 in sentence case.

## Layout

Content sits in a centered column of max 72rem with 16px side gutters (24px from 640px). Panels pad 16px on mobile and 32px from 640px; labels inside them inset 12–16px / 20–32px. Major blocks are separated by 80px of shell. The one breakpoint is 640px; the panel title also scales with a container query on the panel (cqi), so it fits whatever width the panel gets.

Lists on labels run on a 48px rule: each row is 48px tall and a 1px Ruled Blue line repeats every 48px behind it. Numbered rows reserve a narrow typewriter number column (16px, 24px from 640px); from 640px, step lists use a 4rem code column beside the content, and below it the code moves inline before the title.

## Elevation & Depth

Depth is paper on plastic: soft, downward cast shadows with negative spread, tinted by what they fall on. The J-card casts a large cobalt-tinted shadow onto the shell; labels cast a small neutral shadow onto the card. Nothing glows and nothing has a hard offset shadow. The liner-notes card lies flat.

### Shadow Vocabulary
- **Card on shell** (`box-shadow: 0 24px 48px -12px rgb(10 20 80 / 0.55)`): the main J-card panel lying on the cobalt ground.
- **Label on card** (`box-shadow: 0 6px 16px -6px rgb(20 20 20 / 0.45)`): white labels and step lists stuck onto tomato card.
- **Key raised** (`box-shadow: 0 8px 12px -6px rgb(0 0 0 / 0.5)`), **key pressed** (`0 2px 4px -2px rgb(0 0 0 / 0.5)`): the deck key's rest and pressed states.

### Named Rules
**The Paper-On-Plastic Rule.** A shadow only says one material lies on another. Card on shell gets the large tinted shadow, label on card gets the small one; never stack a third level.

## Shapes

Corners are barely softened, like die-cut card: 4px on labels, keys and liner notes, 6px on the main J-card. Only the cassette window and its reels are fully round. Folds and perforations are dashed lines in Marker Ink at 40–50% opacity: 1px for the spine edge, 2px for the fold before a back flap. Solid 2px ink rules separate a label's caption from its list. The stripe band is a 24px strip of mustard (40%), ink (20%) and white (40%) running edge to edge across a panel.

## Components

### Buttons
A cassette-deck key: raised, and it presses down.
- **Shape:** label corners (4px), at least 48px tall, 24px horizontal padding, optional 20px leading icon.
- **Primary:** Label White fill, Marker Ink text, Archivo 700 uppercase with 0.025em tracking, a 6px Marker Ink bottom edge as the key's body, plus the "key raised" shadow.
- **Hover:** fill turns Chrome Mustard (200ms ease-out).
- **Active:** the key travels down 4px, the bottom edge shrinks to 1px and the shadow tightens (120ms ease-out).
- **Focus:** 3px Chrome Mustard outline, 3px offset (shared by every focusable element in the world).

### Cards / Containers
- **J-card panel:** Tomato Card Stock, 6px corners, "card on shell" shadow, clips its children. May carry a spine (a narrow strip with vertical uppercase typewriter text, divided by a dashed 1px ink line) and a stripe band.
- **Tracklist label:** Label White, 4px corners, "label on card" shadow. A caption row (typewriter side name, 2px ink rule below) over a 48px ruled list written in marker. A small typewriter caption at the bottom right says what the list is (for example "sample tracklist").
- **Step list:** the same label material with Ruled Blue dividers, 24px vertical row padding, burnt-ink typewriter codes, Archivo titles and 75% ink body.
- **Liner notes:** Tomato Card Stock, 4px corners, no shadow, 32px padding; a headline over typewriter sentences at 1.125rem, relaxed leading.

### Cassette Window (signature)
A Marker Ink pill holding two 28px reels: one with a thick burnt-ink ring (the full spool), one bare (the empty one). Each holds a 16px dashed white hub that turns once every 4s, linear. Purely decorative and `aria-hidden`; it sits at the right end of a label's caption row.

### Write-in Caret (signature)
A 2px × 24px Marker Ink bar after an open marker entry ("~ you?"), blinking on a 1s stepped cycle. It invites a guest to add the next line.

## Do's and Don'ts

### Do:
- **Do** lay every surface on the Cobalt Shell and build panels from Tomato Card Stock and Label White.
- **Do** use Chrome Mustard for focus (3px outline, 3px offset), hover and selection, and nowhere else except the stripe band.
- **Do** set guest-written content in Permanent Marker on a ruled Label White surface with 48px rows.
- **Do** write labels, codes, captions and fine print in Special Elite.
- **Do** keep motion mechanical and small (reels at 4s linear, caret at 1s stepped, key press at 120ms ease-out), and switch all of it off under `prefers-reduced-motion`.
- **Do** label any example queue content as a sample, in a typewriter caption on the label.

### Don't:
- **Don't** re-skin the world for dark mode; the palette is fixed.
- **Don't** use Permanent Marker for headings, buttons or explanatory copy.
- **Don't** introduce greys; soften Marker Ink with opacity instead.
- **Don't** use unblurred offset box-shadows, glows or more than two shadow levels. (The deck key's 6px ink bottom edge is a border, the key's own body, and stays.)
- **Don't** round panels beyond 6px or make anything but the cassette window and its reels a pill or circle.
