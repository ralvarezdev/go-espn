# ESPN API Integration — Goals & Design

Written 2026-06-11. Follow-on to [`data-source-strategy.md`](./data-source-strategy.md),
which concluded that scraping the *hidden JSON endpoints* behind sports sites is the
only scraping technique worth considering for live scores. Of those, **ESPN's public
site API is the most stable and API-like** target. This document captures what we want
to build against it and how it fits the pool.

## Goal in one line

Build a small, reusable **Go client for ESPN's public sports API** (`go-espn`) and wire
a **football-only adapter** into the pool as an alternative/fallback live-score source to
football-data.org — without giving up the admin override path.

## Why ESPN

From the data-source survey, ESPN scored best on the "scrapable in real time" axis:

- **Plain JSON**, not obfuscated payloads (unlike FlashScore/LiveScore).
- **No headless browser** needed — it's a normal HTTP GET returning structured JSON.
- **No API key** for the public scoreboard endpoints.
- **~30–60s live latency** — fast enough for in-match grading.
- **Uniform across sports**, so the client is sport-agnostic for free.

Caveats carried over from the strategy doc — these do not change:

- **Undocumented / public, not official.** ESPN can change or block it without notice.
- **ToS-grey, no SLA.** Belongs as a reconciliation/fallback source, not sole truth.
- The pool's **admin approve/override panel (Option A) remains the correctness backstop.**

## Scope decision: football-only product, sport-agnostic client

Agreed split (see also the package-naming rationale):

- **`go-espn` client is sport-agnostic.** ESPN's endpoint takes `{sport}` and `{league}`
  as path params, so a generic `Scoreboard(ctx, sport, league)` costs nothing extra and
  keeps the package reusable beyond this pool.
- **The pool's adapter is football/World-Cup-only.** It hardcodes `soccer/fifa.world`
  and maps ESPN responses into the existing `domain.Match`. We do **not** model other
  sports anywhere in the pool's domain — that would be a different product (YAGNI).

```
go-espn (generic)            pool adapter (football-only)
espn.Scoreboard(sport,league) ──▶ map ESPN ──▶ domain.Match ──▶ scoring/DB
                                  (hardcodes soccer/fifa.world)
```

## The package — `go-espn`

- **Module:** `github.com/ralvarezdev/go-espn`
- **Package:** `espn`
- **Style:** matches the existing `go-football-data-v4` — standalone repo, `go-` prefix on
  the module path only, no external deps beyond the standard library if avoidable.

Sketch of the surface (to be firmed up by the spike):

```go
client := espn.New()                                  // sane defaults, optional opts
board, err := client.Scoreboard(ctx, "soccer", "fifa.world")
match, err := client.Summary(ctx, "soccer", "fifa.world", eventID)
```

Design intents:

- `espn.New(opts ...Option)` — configurable `http.Client`, base URL, User-Agent, timeout.
- Sport/league as **parameters**, never hardcoded in the client.
- Typed domain structs for the bits we use (events, competitors, score, status, clock),
  tolerant of unknown/extra fields.
- Built-in **timeout + sane User-Agent**; caller owns rate limiting and caching.
- No key handling — these endpoints are unauthenticated.

## Endpoints we expect to use

> Exact paths and field shapes to be **verified in the spike** — ESPN is undocumented.

| Purpose | Endpoint (shape) |
|---|---|
| Live + day scoreboard | `site.api.espn.com/apis/site/v2/sports/{sport}/{league}/scoreboard` |
| Single match detail | `site.api.espn.com/apis/site/v2/sports/{sport}/{league}/summary?event={id}` |
| Deeper/core data (maybe) | `sports.core.api.espn.com/...` |

For the World Cup: `{sport}=soccer`, `{league}=fifa.world` (slug to be confirmed against a
known-live match in the spike).

Fields we care about for grading and the live UI: event ID, kickoff time, competitors
(home/away + IDs), current score, status/state (pre/in/post), and the match clock/period
for the live minute display.

## How it fits the pool

- New adapter behind the existing `provider.FootballDataProvider` interface — **config swap
  only**; scoring and DB are untouched, exactly like the football-data.org adapter.
- The adapter maps ESPN status → our `SCHEDULED` / `LIVE` / `FINISHED` domain states and
  feeds the same `NinetyMinute()`-style score logic used for grading.
- The **status-downgrade protection** already in `UpsertMatch` applies unchanged.
- **Admin override stays authoritative** — ESPN is advisory/auto-sync, a human can always
  correct a result.

## Open questions for the spike

1. Confirm the WC 2026 league slug (`fifa.world` vs alternative) against a live match.
2. Observe **actual live latency** end-to-end during a match — is it really ~30–60s?
3. Map ESPN's status/state values to our domain (`SCHEDULED`/`LIVE`/`FINISHED`), incl.
   half-time and knockout extra-time/penalties.
4. Does the scoreboard expose a usable **match minute/clock** (something football-data.org
   does *not*), which would let us drop the `useLiveMinute` estimation hook?
5. Rate-limit / anti-bot behavior: required headers, Cloudflare, polite request cadence.
6. Coverage check: does the feed carry all 104 WC matches and group metadata?

## Next step

Write the spike: `go-espn` with `espn.New()` + `Scoreboard(ctx, sport, league)` and a small
`main` that hits `soccer/fifa.world`, prints the live JSON, and answers the open questions
above before we commit to wiring an adapter.
