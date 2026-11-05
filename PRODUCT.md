# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users
- **Hosts:** the person who runs Rocola at home. They pick the speaker and share the QR.
- **Guests:** friends at a get-together. They scan the QR on their phone and request songs. They don't sign in or install anything.
- **The landing page (`/`) is for friends and hosts who are curious about Rocola** (confirmed). Guests will request songs on a separate page.

## Product Purpose
A jukebox for home and get-togethers. Guests scan a QR code, search Spotify and add songs to the queue. Success: the music at a party belongs to everyone in the room, and nobody has to hand their phone to the host.

## Positioning
A Raspberry Pi controls playback on a Spotify Connect speaker the host already owns (Sonos, phone, smart speaker). The Pi never plays audio itself. Fair-play rules are built in.

## Operating Context
Living rooms and small get-togethers, usually in the evening. Guests use their phones. The host sets things up once on a laptop or phone.

## Capabilities and Constraints
- Search the Spotify catalog and add songs to the queue. The queue is add-only, per the Spotify API.
- Guests can queue at most 3 songs per session every 30 minutes. A song already in the queue is rejected.
- Devices marked restricted are shown as unavailable.
- **Personal, non-commercial use only.** No payments, tips, venues, multi-tenant setups or ads (Spotify terms).
- Undecided: the guest request page doesn't exist yet. The real Spotify adapter is a stub, and the Fake adapter is used in development.

## Brand Commitments
- Name: **Rocola**, the Latin-American word for jukebox.
- Copy in English (confirmed).
- Always state: not affiliated with or endorsed by Spotify.

## Evidence on Hand
None: no users, testimonials, photos or usage numbers. Never invent them. Any sample queue content must be labeled as a sample.

## Product Principles
1. Everyone gets a turn: fairness rules over first-come floods.
2. Zero friction for guests: a camera and a search box, nothing else.
3. Use what the host already has: their speaker and their Spotify account.
4. Personal by design: no commercial angle.
