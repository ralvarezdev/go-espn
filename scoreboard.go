package espn

import (
	"context"
	"fmt"
	"net/url"
	"time"
)

type (
	// ScoreboardResponse is the root JSON object returned by the scoreboard endpoint.
	ScoreboardResponse struct {
		Leagues []League         `json:"leagues"`
		Events  []Event          `json:"events"`
		Season  ScoreboardSeason `json:"season"`
		Day     DayInfo          `json:"day"`
	}

	// ScoreboardOption configures a single Scoreboard request.
	ScoreboardOption func(*scoreboardConfig)

	scoreboardConfig struct {
		date *time.Time
	}
)

// WithDate restricts the scoreboard to a specific calendar date.
// The date is sent as YYYYMMDD in the request query string.
func WithDate(d time.Time) ScoreboardOption {
	return func(c *scoreboardConfig) { c.date = &d }
}

// Scoreboard returns live and scheduled matches for the given sport and league.
// Pass WithDate to query a specific date; the API defaults to the current day.
//
// sport and league must be valid ESPN path segments (e.g. SportSoccer, LeagueSlugFIFAWorld).
// An unsupported combination returns an *APIError with Code 404.
func (c *Client) Scoreboard(
	ctx context.Context,
	sport, league string,
	opts ...ScoreboardOption,
) (*ScoreboardResponse, error) {
	cfg := &scoreboardConfig{}
	for _, opt := range opts {
		opt(cfg)
	}

	u := fmt.Sprintf(
		"%s/%s/%s/scoreboard",
		c.baseURL,
		url.PathEscape(sport),
		url.PathEscape(league),
	)
	if cfg.date != nil {
		params := url.Values{}
		params.Set("dates", cfg.date.UTC().Format("20060102"))
		u += "?" + params.Encode()
	}

	var result ScoreboardResponse
	if err := c.get(ctx, u, &result); err != nil {
		return nil, fmt.Errorf(
			"espn: scoreboard %s/%s: %w",
			sport,
			league,
			err,
		)
	}
	return &result, nil
}
