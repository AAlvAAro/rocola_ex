# Rocola roadmap

Tickets the `/ship` workflow picks from. Highest priority first: P1 > P2 > P3, then lowest ID.
Status: `open` -> `tdd` -> `approved` -> `in-review` -> `done` (or `rejected`).
Add tickets with `/roadmap-add`. Only the orchestrator changes `Status`.

| ID | Priority | Status | Title | User story |
|---|---|---|---|---|
| ROC-001 | P1 | done | Admin device picker | As the host, I open /admin, see my Spotify Connect devices, pick one to play on, and refresh the list; restricted devices show as unavailable. |
| ROC-002 | P1 | open | Host Spotify login | As the host, I connect my Spotify account once from /admin and stay connected: the server keeps the token in memory (`TokenServer`), refreshes it before it expires, and never logs, renders or stores it anywhere else. Guests never log in to Spotify. |
| ROC-003 | P1 | open | Real Spotify client | As the host, Rocola controls my real speakers: `Rocola.Spotify.Web` implements every behaviour callback against the Spotify Web API (handling 429 `Retry-After`, 204 no-body responses and devices that disappear when asleep), and switching between Fake and Web is one config line. |
| ROC-004 | P1 | open | Join with QR + nickname | As a guest, I scan the QR code, type a nickname and I'm in, with no account. |
| ROC-005 | P1 | open | Search and request a song | As a guest, I search a song and add it to the shared queue, limited to 3 songs per 30 min and no duplicates. |
| ROC-006 | P1 | open | Live queue | As a guest, I see the upcoming songs and who requested each one, updated live. |
| ROC-007 | P1 | open | Now playing | As a guest, I see the song playing right now with artist, album art and progress, updated live. |
| ROC-008 | P2 | open | TV screen | As the host, I open /tv on a TV or laptop and it shows now playing, the next 5 songs and the QR code to join, full screen. |
| ROC-009 | P2 | open | Host controls | As the host, I can pause, resume, skip and remove a song from the queue. |
| ROC-010 | P2 | open | Fallback playlist | As the host, I pick a playlist that plays when the queue is empty, so the music never stops. |
| ROC-011 | P2 | open | Explicit filter | As the host, I turn on a filter and guests can't request explicit songs. |
| ROC-012 | P2 | open | Party PIN | As the host, joining requires the 4-digit PIN shown on the TV screen, so people outside the party can't add songs. |
| ROC-013 | P2 | open | Fair queue | As a guest, requests take turns between guests, so one person can't line up several songs in a row. |
| ROC-014 | P2 | open | No repeats | As the host, a song played in the last 2 hours can't be requested again. |
| ROC-015 | P3 | open | Upvotes | As a guest, I upvote songs in the queue and the most voted move up. |
| ROC-016 | P3 | open | Vote to skip | As a guest, I vote to skip the current song; it's skipped when more than half of the active guests vote. |
| ROC-017 | P3 | open | Party recap | As the host, when the party ends I see what played and who requested it, and can save it as a Spotify playlist. |
| ROC-018 | P3 | open | Deploy to Raspberry Pi | As the host, Rocola runs on my Raspberry Pi as a `mix release` for aarch64 under systemd and starts on boot. |
