---
type: llm
---

PASS if the reply explains how the host Spotify login would work in Rocola: the host connects their Spotify account once from /admin through Spotify's OAuth login, the token is kept in memory (TokenServer) and refreshed before it expires, and guests never log in.
It may hedge on details. FAIL if it doesn't answer the question, says it started building the feature, or describes guests logging in to Spotify.
