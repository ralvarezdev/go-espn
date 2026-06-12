package espn

import (
	"context"
	"fmt"
	"net/url"
)

// Form event enums

type (
	// AtVsType indicates whether a team played at home or away.
	AtVsType string
	// GameResultType is the outcome of a match for a team.
	GameResultType string
)

const (
	AtVsAt AtVsType = "at"
	AtVsVs AtVsType = "vs"
)

const (
	GameResultWin  GameResultType = "W"
	GameResultLoss GameResultType = "L"
	GameResultDraw GameResultType = "D"
)

type (
	// SummaryResponse is the root JSON object returned by the summary endpoint.
	SummaryResponse struct {
		Articles []Article `json:"articles"`
		Videos   []Video   `json:"videos"`
		Odds     []Odd     `json:"odds"`
		Boxscore BoxScore  `json:"boxscore"`
	}

	// BoxScore holds per-competitor aggregate statistics and recent form for a match.
	BoxScore struct {
		Statistics []CompetitorStat `json:"statistics"`
		Form       []Form           `json:"form"`
	}

	// CompetitorStat groups team-level statistics for one side of a match.
	CompetitorStat struct {
		Statistics []Statistic `json:"statistics"`
		Team       Team        `json:"team"`
	}

	// Form holds a team's recent match history returned alongside a summary.
	Form struct {
		Events       []FormEvent `json:"events"`
		Team         Team        `json:"team"`
		DisplayOrder int         `json:"displayOrder"`
	}

	// FormEvent is a single entry in a team's recent match history.
	FormEvent struct {
		Links              []Link         `json:"links"`
		GameDate           ESPNTime       `json:"gameDate"`
		ID                 string         `json:"id"`
		AtVs               AtVsType       `json:"atVs"`
		Score              string         `json:"score"`
		HomeTeamID         string         `json:"homeTeamId"`
		AwayTeamID         string         `json:"awayTeamId"`
		HomeTeamScore      string         `json:"homeTeamScore"`
		AwayTeamScore      string         `json:"awayTeamScore"`
		HomeAggregateScore string         `json:"homeAggregateScore"`
		AwayAggregateScore string         `json:"awayAggregateScore"`
		HomeShootoutScore  string         `json:"homeShootoutScore"`
		AwayShootoutScore  string         `json:"awayShootoutScore"`
		GameResult         GameResultType `json:"gameResult"`
		CompetitionName    string         `json:"competitionName"`
		LeagueName         string         `json:"leagueName"`
		LeagueAbbreviation string         `json:"leagueAbbreviation"`
	}

	// Article is editorial content associated with a match.
	Article struct {
		Links       []Link `json:"links"`
		Description string `json:"description"`
		ID          string `json:"id"`
		Type        string `json:"type"`
	}

	// Video is a video asset associated with a match.
	Video struct {
		Links       []Link `json:"links"`
		Description string `json:"description"`
		ID          string `json:"id"`
		Type        string `json:"type"`
	}

	// Odd is a single betting odds entry for a match.
	Odd struct {
		Provider    string `json:"provider"`
		DisplayName string `json:"displayName"`
	}
)

// Summary returns detailed match information for a single event, including team
// statistics, recent form, and extended metadata.
//
// eventID must be a valid ESPN event identifier (e.g. "760415"). An invalid ID may
// return a 404 *APIError or a response with empty boxscore fields.
func (c *Client) Summary(
	ctx context.Context,
	sport, league, eventID string,
) (*SummaryResponse, error) {
	params := url.Values{}
	params.Set("event", eventID)
	u := fmt.Sprintf(
		"%s/%s/%s/summary?%s",
		c.baseURL,
		url.PathEscape(sport),
		url.PathEscape(league),
		params.Encode(),
	)

	var result SummaryResponse
	if err := c.get(ctx, u, &result); err != nil {
		return nil, fmt.Errorf(
			"espn: summary %s/%s event %s: %w",
			sport,
			league,
			eventID,
			err,
		)
	}
	return &result, nil
}
