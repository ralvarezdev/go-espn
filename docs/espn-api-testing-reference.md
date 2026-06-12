# ESPN API — Testing & Quick Reference

Quick curl examples and payloads for testing the ESPN API during development.

## Base URLs

```
Scoreboard: https://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/scoreboard
Summary:    https://site.api.espn.com/apis/site/v2/sports/{sport}/{league}/summary?event={id}
```

## Curl Examples

### Live Scoreboard Tests

**FIFA World Cup (soccer):**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq .
```

**Premier League (soccer):**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/eng.1/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq .
```

**NBA (basketball):**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq .
```

**NFL (american football):**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq .
```

### Specific Date Query

**World Cup matches on June 12, 2026:**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard?dates=20260612' \
  -H 'User-Agent: Mozilla/5.0' | jq .
```

### Summary/Details Endpoint

**Get details for specific match (event ID 760415):**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/summary?event=760415' \
  -H 'User-Agent: Mozilla/5.0' | jq .
```

### Extract Specific Data

**Just event IDs and names from scoreboard:**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq '.events[] | {id, name, shortName}'
```

**Just match scores:**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq '.events[] | {match: .shortName, status: .competitions[0].status.type.state, competitors: .competitions[0].competitors[] | {team: .team.abbreviation, score: .score}}'
```

**Just status and clock for live matches:**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq '.events[] | {match: .shortName, clock: .competitions[0].status.displayClock, state: .competitions[0].status.type.state}'
```

**Play-by-play details (goals, cards):**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq '.events[0].competitions[0].details[] | {minute: .clock.displayValue, type: .type.text, team: .team.id, scoring: .scoringPlay}'
```

## Response Structure Quick Reference

### Scoreboard Response (Top Level)

```
leagues[]
  - id, uid, name, slug
  - season: {year, startDate, endDate, displayName, type}
  - logos[]
  - calendar[] (phases or dates)

events[]
  - id, uid, date, name, shortName
  - season: {year, type, slug}
  - competitions[]
    - id, uid, date, status
    - status: {clock, displayClock, period, type}
    - type.state: "pre" | "in" | "post"
    - type.detail: "FT", "HT", "Live", etc.
    - competitors[]
      - id, type, order, homeAway, score
      - winner, advance, form
      - team: {id, abbreviation, displayName, logo}
      - statistics[]
    - details[] (play-by-play)
    - venue: {id, fullName, address}
```

### Summary Response (Top Level)

```
boxscore
  - form[] (home/away recent matches)
  - statistics[] (detailed team stats)

articles[]
  - headlines, descriptions, links

videos[]
  - highlights, replays

odds[]
  - betting odds
```

## League Slugs

### Soccer
- `fifa.world` — FIFA World Cup
- `eng.1` — English Premier League
- `esp.1` — Spanish La Liga
- `ita.1` — Italian Serie A
- `fra.1` — French Ligue 1 (likely)
- `deu.1` — German Bundesliga (likely)
- `usa.1` — MLS

### Basketball
- `nba` — NBA

### American Football
- `nfl` — NFL

## Status State Values

| State | Meaning | Clock | Notes |
|---|---|---|---|
| `pre` | Pre-match | Null/missing | Scheduled |
| `in` | In progress | Populated | Live or halftime |
| `post` | Post-match | Populated | Finished |

## Status Type Examples

| Type Name | Type ID | State | Detail | Period | Example |
|---|---|---|---|---|---|
| STATUS_SCHEDULED | 1 | pre | TBD | - | Pre-match |
| STATUS_IN_PROGRESS | 2 | in | Live | 1 | 1st half live |
| STATUS_IN_PROGRESS | 2 | in | Live | 2 | 2nd half live |
| STATUS_HALFTIME | 3 | in | HT | - | Halftime break |
| STATUS_FULL_TIME | 28 | post | FT | 2 | Full time |
| STATUS_EXTRA_TIME | ? | post | ET | 3+ | Extra time |
| STATUS_PENALTY | ? | post | PSO | - | Penalty shootout |

## Test Data

### Known Working Event IDs (FIFA WC 2026)
- `760415` — South Africa vs Mexico (completed, Jun 11)
- `760416` — (Jun 12, if exists)

### Known League Slugs to Test
- `soccer/fifa.world` ✅
- `soccer/eng.1` ✅
- `basketball/nba` ✅
- `football/nfl` ✅
- `cricket/ipl` ❌ (404 error)

## Performance Observations

| Test | Result |
|---|---|
| Response time (scoreboard) | 200–400ms |
| Response size (scoreboard) | 50–200 KB (gzip: ~15–40 KB) |
| Response time (summary) | 500–1000ms |
| Cache TTL | 4 seconds (max-age=4) |
| Concurrent requests | No observed limits |
| Rate limiting | None observed in headers |

## Debugging Tricks

**Pretty-print and save to file:**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq . > scoreboard.json
```

**Count matches in response:**
```bash
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' | jq '.events | length'
```

**Check HTTP headers (cache, CORS):**
```bash
curl -i 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' \
  -H 'User-Agent: Mozilla/5.0' 2>&1 | head -20
```

**Test with different dates:**
```bash
for date in 20260611 20260612 20260613; do
  echo "=== $date ==="
  curl -s "https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard?dates=$date" \
    -H 'User-Agent: Mozilla/5.0' | jq '.events | length'
done
```

## Common Errors & Solutions

| Error | Likely Cause | Solution |
|---|---|---|
| `{"code": 404, "message": "Failed to get events..."}` | Unsupported sport/league | Check league slug, use known slugs (fifa.world, eng.1, nba) |
| Empty `events[]` | No matches on that date | Try nearby dates or different league |
| `null` values in fields | Expected — some fields optional | Use safe navigation / null checks |
| 403 Forbidden | Rate limiting (if eventually hit) | Implement backoff, reduce request frequency |
| JSON parse error | Response is HTML (maintenance) | Check if ESPN site is up |

## Field Data Types (Go Implications)

| Field | Type | Notes |
|---|---|---|
| Event ID | String | Numeric but stored as string, use `string` not `int64` |
| Team ID | String | Variable length, use `string` |
| Clock | Float | Seconds as decimal (e.g., 513.0), use `float64` |
| Score | String | Not numeric (e.g., "2"), use `string` |
| Period | Int | 1-4 for soccer, 1-4 for football, convert to domain |
| Date | String (ISO 8601) | `2026-06-11T19:00Z`, parse as `time.Time` |

