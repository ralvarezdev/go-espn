# go-espn

Sport-agnostic Go client for ESPN's public scoreboard and site API. It wraps the `site.api.espn.com` scoreboard and event-summary endpoints with typed responses. Requires Go 1.26.

**Note:** This targets a public ESPN endpoint that is not an officially documented or supported API. Response shapes may change without notice.

## Installation

```bash
go get github.com/ralvarezdev/go-espn
```

## Usage

```go
c := espn.New() // defaults: base URL, user agent, 10s timeout
ctx := context.Background()

board, err := c.Scoreboard(ctx, espn.SportSoccer, espn.LeagueSlugFIFAWorld,
    espn.WithDate(time.Now()))

// Match detail by ESPN event id
summary, err := c.Summary(ctx, espn.SportSoccer, espn.LeagueSlugFIFAWorld, "<event-id>")
```

## API

- **`espn.New(opts ...Option)`** — client options `WithBaseURL`, `WithTimeout`, `WithHTTPClient`, `WithUserAgent`.
- **`Scoreboard(ctx, sport, league, ...ScoreboardOption)`** — returns `*ScoreboardResponse`; option `WithDate(time.Time)`.
- **`Summary(ctx, sport, league, eventID)`** — returns `*SummaryResponse`.
- **Constants** — `DefaultBaseURL`, `DefaultUserAgent`, `DefaultTimeout`; sports (`SportSoccer`, `SportBasketball`, `SportFootball`, `SportBaseball`, `SportHockey`, `SportGolf`); league slugs (`LeagueSlugFIFAWorld`, `LeagueSlugPremierLeague`, `LeagueSlugLaLiga`, `LeagueSlugSerieA`, `LeagueSlugBundesliga`, `LeagueSlugMLS`, `LeagueSlugNBA`, `LeagueSlugNFL`).
- **Errors** — `*APIError`; HTTP 404 maps to `espn.ErrNotFound`, so `errors.Is(err, espn.ErrNotFound)` works.
- **`ESPNTime`** — handles ESPN's timestamp layouts.

## Development

```bash
go build ./...
go test ./...
```

`Taskfile.yml` defines tasks (`test`, `test:quick`, `test:structure`) that call the PowerShell scripts `run-test.ps1` and `scripts/*.ps1`; see `docs/testing-guide.md`. Some tests may hit the live ESPN API. `docs/` also holds endpoint notes and data models.

## License

MIT License (see [LICENSE](LICENSE)).
