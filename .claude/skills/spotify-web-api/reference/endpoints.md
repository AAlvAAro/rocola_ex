# Endpoints (Spotify Web API, base https://api.spotify.com/v1)

| Behaviour callback | Request | Notes |
|---|---|---|
| `search/1` | `GET /search?q=...&type=track&limit=20` | `tracks.items[]`: uri, name, artists[0].name, duration_ms |
| `devices/0` | `GET /me/player/devices` | `devices[]`: id, name, is_active, is_restricted. Only awake devices |
| `transfer_playback/1` | `PUT /me/player` body `{"device_ids":[id]}` | 204; fails on restricted device |
| `add_to_queue/1` | `POST /me/player/queue?uri=...` | 204, needs active device; add-only |
| `queue/0` | `GET /me/player/queue` | `currently_playing` + `queue[]` |
| `now_playing/0` | `GET /me/player/currently-playing` | 204 when nothing plays |
| skip (needs a new callback) | `POST /me/player/next` | 204; works on the active device only |

Errors: 401 refresh the token once; 403 restricted or not Premium; 404 no active device; 429 wait `Retry-After`.
