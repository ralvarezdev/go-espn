package espn

import (
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

// Time handling

// ESPNTime wraps time.Time to handle ESPN's non-standard timestamp format.
//
// ESPN returns timestamps without seconds (e.g. "2026-06-11T04:00Z"), which the
// standard encoding/json cannot unmarshal into a time.Time because it requires
// full RFC3339 with seconds. ESPNTime accepts both layouts on decode and, by
// embedding time.Time, forwards all time.Time methods (UTC, Sub, Format, …) and
// inherits its RFC3339 MarshalJSON, so call sites need no changes.
type ESPNTime struct {
	time.Time
}

// espnTimeLayouts are tried in order when decoding an ESPNTime. RFC3339 (with
// seconds) is first because that is the canonical form; the seconds-less variant
// is the shape ESPN actually emits.
var espnTimeLayouts = []string{
	time.RFC3339,
	"2006-01-02T15:04Z07:00",
}

// UnmarshalJSON decodes an ESPN timestamp, tolerating the missing-seconds format.
// A JSON null or empty string leaves the zero value in place.
func (t *ESPNTime) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), `"`)
	if s == "" || s == "null" {
		return nil
	}
	for _, layout := range espnTimeLayouts {
		if parsed, err := time.Parse(layout, s); err == nil {
			t.Time = parsed
			return nil
		}
	}
	return fmt.Errorf("espn: cannot parse time %q", s)
}

// Status and match state enums

type (
	// StatusState is the coarse lifecycle of a match.
	StatusState string
	// StatusDetail is the human-readable status code returned by ESPN (e.g. "FT", "HT").
	StatusDetail string
	// HomeAway indicates whether a competitor is the home or away side.
	HomeAway string
	// CompetitorType distinguishes team events from individual-athlete sports.
	CompetitorType string
	// CalendarType describes how the league calendar is organized.
	CalendarType string
	// EventTypeID is the numeric string identifier for a play-by-play event.
	EventTypeID string
	// EventTypeText is the human-readable label for a play-by-play event.
	EventTypeText string
	// StatisticName is the canonical key for a per-competitor statistic.
	StatisticName string
	// StatisticAbbreviation is the short display code for a statistic.
	StatisticAbbreviation string
	// LinkRelation describes the semantic purpose of a hyperlink.
	LinkRelation string
)

// StatusState values — maps to the pool domain SCHEDULED / LIVE / FINISHED.
const (
	StatusStatePre  StatusState = "pre"
	StatusStateIn   StatusState = "in"
	StatusStatePost StatusState = "post"
)

// StatusDetail values observed in ESPN responses.
const (
	StatusDetailTBD       StatusDetail = "TBD"
	StatusDetailLive      StatusDetail = "Live"
	StatusDetailHalftime  StatusDetail = "HT"
	StatusDetailFullTime  StatusDetail = "FT"
	StatusDetailExtraTime StatusDetail = "ET"
	StatusDetailPenalty   StatusDetail = "PSO"
	StatusDetailSuspended StatusDetail = "SUS"
	StatusDetailAbandoned StatusDetail = "ABD"
	StatusDetailPostgame  StatusDetail = "POST"
)

const (
	HomeAwayHome HomeAway = "home"
	HomeAwayAway HomeAway = "away"
)

const (
	CompetitorTypeTeam   CompetitorType = "team"
	CompetitorTypePerson CompetitorType = "person"
)

const (
	CalendarTypeList CalendarType = "list" // tournament phases (e.g. World Cup)
	CalendarTypeDay  CalendarType = "day"  // individual dates (e.g. Premier League)
)

// Play-by-play event type IDs (JSON string values).
const (
	EventTypeIDGoal          EventTypeID = "70"
	EventTypeIDOwnGoal       EventTypeID = "71"
	EventTypeIDPenaltyGoal   EventTypeID = "72"
	EventTypeIDMissedPenalty EventTypeID = "73"
	EventTypeIDYellowCard    EventTypeID = "94"
	EventTypeIDRedCard       EventTypeID = "95"
	EventTypeIDSubstitution  EventTypeID = "96"
)

const (
	EventTypeTextGoal          EventTypeText = "Goal"
	EventTypeTextOwnGoal       EventTypeText = "Own Goal"
	EventTypeTextPenaltyGoal   EventTypeText = "Penalty Goal"
	EventTypeTextMissedPenalty EventTypeText = "Missed Penalty"
	EventTypeTextYellowCard    EventTypeText = "Yellow Card"
	EventTypeTextRedCard       EventTypeText = "Red Card"
	EventTypeTextSubstitution  EventTypeText = "Substitution"
)

// Soccer statistic names.
const (
	StatNameAppearances    StatisticName = "appearances"
	StatNameFoulsCommitted StatisticName = "foulsCommitted"
	StatNameWonCorners     StatisticName = "wonCorners"
	StatNameGoalAssists    StatisticName = "goalAssists"
	StatNamePossessionPct  StatisticName = "possessionPct"
	StatNameShotsOnTarget  StatisticName = "shotsOnTarget"
	StatNameTotalGoals     StatisticName = "totalGoals"
	StatNameTotalShots     StatisticName = "totalShots"
	StatNamePassCompletion StatisticName = "passCompletionPct"
	StatNameClearances     StatisticName = "clearances"
	StatNameSaves          StatisticName = "saves"
)

// Soccer statistic abbreviations.
const (
	StatAbbrAppearances    StatisticAbbreviation = "APP"
	StatAbbrFoulsCommitted StatisticAbbreviation = "FC"
	StatAbbrWonCorners     StatisticAbbreviation = "CW"
	StatAbbrGoalAssists    StatisticAbbreviation = "A"
	StatAbbrPossessionPct  StatisticAbbreviation = "PP"
	StatAbbrShotsOnTarget  StatisticAbbreviation = "SOG"
	StatAbbrTotalGoals     StatisticAbbreviation = "G"
	StatAbbrTotalShots     StatisticAbbreviation = "SHOT"
)

const (
	LinkRelClubhouse  LinkRelation = "clubhouse"
	LinkRelDesktop    LinkRelation = "desktop"
	LinkRelMobile     LinkRelation = "mobile"
	LinkRelStats      LinkRelation = "stats"
	LinkRelSchedule   LinkRelation = "schedule"
	LinkRelSquad      LinkRelation = "squad"
	LinkRelPlayerCard LinkRelation = "playercard"
	LinkRelAthlete    LinkRelation = "athlete"
	LinkRelFull       LinkRelation = "full"
	LinkRelDark       LinkRelation = "dark"
	LinkRelDefault    LinkRelation = "default"
	LinkRelTeam       LinkRelation = "team"
	LinkRelExternal   LinkRelation = "external"
	LinkRelPremium    LinkRelation = "premium"
	LinkRelHidden     LinkRelation = "hidden"
)

// Record types (team/competitor record classification).
type (
	RecordType string
)

const (
	RecordTypeTotal      RecordType = "total"
	RecordTypeHome       RecordType = "home"
	RecordTypeAway       RecordType = "away"
	RecordTypeConference RecordType = "conference"
	RecordTypeDivision   RecordType = "division"
)

// Headline classification.
type (
	HeadlineType string
)

const (
	HeadlineTypeRecap    HeadlineType = "Recap"
	HeadlineTypePreview  HeadlineType = "Preview"
	HeadlineTypeNews     HeadlineType = "News"
	HeadlineTypeAnalysis HeadlineType = "Analysis"
)

// Sport path-segment constants for use in Scoreboard and Summary calls.
const (
	SportSoccer     = "soccer"
	SportBasketball = "basketball"
	SportFootball   = "football"
	SportBaseball   = "baseball"
	SportHockey     = "hockey"
	SportGolf       = "golf"
)

// Known league slug constants.
const (
	LeagueSlugFIFAWorld     = "fifa.world"
	LeagueSlugPremierLeague = "eng.1"
	LeagueSlugLaLiga        = "esp.1"
	LeagueSlugSerieA        = "ita.1"
	LeagueSlugLigue1        = "fra.1"
	LeagueSlugBundesliga    = "deu.1"
	LeagueSlugMLS           = "usa.1"
	LeagueSlugNBA           = "nba"
	LeagueSlugNFL           = "nfl"
)

// Period constants for Status.Period.
const (
	PeriodFirstHalf  = 1
	PeriodSecondHalf = 2
	PeriodFirstOT    = 3
	PeriodSecondOT   = 4
	PeriodShootout   = 5
)

// Domain types

type (
	// SeasonType is the structured season-type descriptor returned inside League.Season.
	// ESPN returns this as an object with id, type, and abbreviation fields.
	SeasonType struct {
		ID           string `json:"id"`
		Type         string `json:"type"`
		Abbreviation string `json:"abbreviation"`
	}

	// Season holds league-level season metadata returned inside a League.
	Season struct {
		StartDate   ESPNTime   `json:"startDate"`
		EndDate     ESPNTime   `json:"endDate"`
		DisplayName string     `json:"displayName"`
		Year        int        `json:"year"`
		Type        SeasonType `json:"type"`
	}

	// EventSeason is the lightweight season descriptor attached to individual events.
	EventSeason struct {
		Slug string `json:"slug"` // e.g. "group-stage"
		Year int    `json:"year"`
		Type int    `json:"type"`
	}

	// ScoreboardSeason is the root-level season object in a scoreboard response.
	ScoreboardSeason struct {
		Year int `json:"year"`
		Type int `json:"type"`
	}

	// DayInfo carries the calendar date from the root scoreboard response.
	DayInfo struct {
		Date string `json:"date"` // YYYY-MM-DD
	}

	// CalendarEntry is one entry in a league calendar (a tournament phase or a date).
	// StartDate and EndDate are optional — some entries (e.g. future knockout rounds) omit them.
	CalendarEntry struct {
		Entries        []CalendarEntry `json:"entries"`
		StartDate      *ESPNTime       `json:"startDate"`
		EndDate        *ESPNTime       `json:"endDate"`
		Label          string          `json:"label"`
		Detail         string          `json:"detail"`
		Value          string          `json:"value"`
		AlternateLabel string          `json:"alternateLabel"`
	}

	// Logo is a single league or team logo asset.
	Logo struct {
		Rel         []string  `json:"rel"` // e.g. ["full", "default"]
		LastUpdated *ESPNTime `json:"lastUpdated"`
		Href        string    `json:"href"`
		Alt         string    `json:"alt"`
		Width       int       `json:"width"`
		Height      int       `json:"height"`
	}

	// League carries metadata about a sport league returned alongside scoreboard events.
	League struct {
		Logos               []Logo          `json:"logos"`
		Calendar            []CalendarEntry `json:"calendar"`
		Season              Season          `json:"season"`
		CalendarStartDate   ESPNTime        `json:"calendarStartDate"`
		CalendarEndDate     ESPNTime        `json:"calendarEndDate"`
		UID                 string          `json:"uid"`
		ID                  string          `json:"id"`
		Name                string          `json:"name"`
		Abbreviation        string          `json:"abbreviation"`
		MidsizeName         string          `json:"midsizeName"`
		Slug                string          `json:"slug"`
		CalendarType        CalendarType    `json:"calendarType"`
		CalendarIsWhitelist bool            `json:"calendarIsWhitelist"`
	}

	// Event is a single match returned in the scoreboard.
	Event struct {
		Competitions []Competition `json:"competitions"`
		Date         ESPNTime      `json:"date"`
		Season       EventSeason   `json:"season"`
		UID          string        `json:"uid"`
		ID           string        `json:"id"` // numeric string; kept as string to avoid overflow
		Name         string        `json:"name"`
		ShortName    string        `json:"shortName"`
	}

	// Status holds the live state, clock, and period for a competition.
	Status struct {
		Type         StatusType `json:"type"`
		Clock        *float64   `json:"clock"`        // seconds elapsed; null for scheduled matches
		DisplayClock string     `json:"displayClock"` // e.g. "90'+8'", "HT", "TBD"
		Period       int        `json:"period"`       // 1 = first half, 2 = second half, etc.
	}

	// StatusType is the structured status descriptor returned by ESPN.
	StatusType struct {
		Name        string       `json:"name"`        // e.g. "STATUS_FULL_TIME"
		Description string       `json:"description"` // e.g. "Full Time"
		Detail      StatusDetail `json:"detail"`
		ShortDetail StatusDetail `json:"shortDetail"`
		State       StatusState  `json:"state"`
		ID          string       `json:"id"`
		Completed   bool         `json:"completed"`
	}

	// Venue is the physical location of a competition.
	Venue struct {
		Address  Address `json:"address"`
		FullName string  `json:"fullName"`
		ID       string  `json:"id"`
	}

	// Address is a postal address attached to a Venue.
	Address struct {
		City    string `json:"city"`
		Country string `json:"country"`
		State   string `json:"state"`
		Zip     string `json:"zip"`
	}

	// Format describes the structure of a competition (e.g. number of periods).
	Format struct {
		Regulation Regulation `json:"regulation"`
	}

	// Regulation holds the number of regulation periods for a sport.
	Regulation struct {
		Periods int `json:"periods"` // 2 for soccer, 4 for basketball/football
	}

	// Competition is the core match record nested inside an Event.
	// GeoBroadcasts uses json.RawMessage because its structure varies across sports.
	Competition struct {
		Competitors   []Competitor      `json:"competitors"`
		Details       []Detail          `json:"details"`
		Headlines     []Headline        `json:"headlines"`
		Broadcasts    []Broadcast       `json:"broadcasts"`
		GeoBroadcasts []json.RawMessage `json:"geoBroadcasts"`
		Notes         []json.RawMessage `json:"notes"`
		Date          ESPNTime          `json:"date"`
		StartDate     ESPNTime          `json:"startDate"`
		Status        Status            `json:"status"`
		Format        Format            `json:"format"`
		Venue         *Venue            `json:"venue"`
		Attendance    *int              `json:"attendance"`
		UID           string            `json:"uid"`
		ID            string            `json:"id"`
		TimeValid     bool              `json:"timeValid"`
		Recent        bool              `json:"recent"`
	}

	// Competitor is one side of a competition (typically a team).
	// Score is a string because ESPN represents it as a quoted number in JSON.
	Competitor struct {
		Records    []Record       `json:"records"`
		Statistics []Statistic    `json:"statistics"`
		Players    []Athlete      `json:"players"` // populated in Summary responses only
		Team       Team           `json:"team"`
		UID        string         `json:"uid"`
		ID         string         `json:"id"`
		Form       string         `json:"form"`  // recent results, e.g. "WWWWD"
		Score      string         `json:"score"` // quoted integer string
		Type       CompetitorType `json:"type"`
		HomeAway   HomeAway       `json:"homeAway"`
		Order      int            `json:"order"`
		Winner     bool           `json:"winner"`
		Advance    bool           `json:"advance"`
	}

	// Team is a sport team entity.
	// Color and AlternateColor are hex strings without a leading '#'.
	Team struct {
		Links            []Link `json:"links"`
		Venue            *Venue `json:"venue"`
		UID              string `json:"uid"`
		ID               string `json:"id"`
		Abbreviation     string `json:"abbreviation"`
		DisplayName      string `json:"displayName"`
		ShortDisplayName string `json:"shortDisplayName"`
		Name             string `json:"name"`
		Location         string `json:"location"`
		Color            string `json:"color"`
		AlternateColor   string `json:"alternateColor"`
		Logo             string `json:"logo"` // URL
		IsActive         bool   `json:"isActive"`
	}

	// Record is a win-draw-loss summary string for a competitor.
	Record struct {
		Name         string     `json:"name"`
		Type         RecordType `json:"type"`
		Summary      string     `json:"summary"` // e.g. "1-0-0" (W-D-L)
		Abbreviation string     `json:"abbreviation"`
	}

	// Statistic is a single named metric for a competitor.
	Statistic struct {
		Name         StatisticName         `json:"name"`
		Abbreviation StatisticAbbreviation `json:"abbreviation"`
		DisplayValue string                `json:"displayValue"`
	}

	// Detail is one entry in the play-by-play timeline of a competition.
	Detail struct {
		AthletesInvolved []Athlete  `json:"athletesInvolved"`
		Clock            Clock      `json:"clock"`
		Type             DetailType `json:"type"`
		Team             TeamRef    `json:"team"`
		ScoreValue       int        `json:"scoreValue"`
		ScoringPlay      bool       `json:"scoringPlay"`
		RedCard          bool       `json:"redCard"`
		YellowCard       bool       `json:"yellowCard"`
		PenaltyKick      bool       `json:"penaltyKick"`
		OwnGoal          bool       `json:"ownGoal"`
		Shootout         bool       `json:"shootout"`
	}

	// DetailType classifies a play-by-play event by ID and text label.
	DetailType struct {
		Text EventTypeText `json:"text"`
		ID   EventTypeID   `json:"id"`
	}

	// Clock represents a point-in-time within a match.
	Clock struct {
		DisplayValue string  `json:"displayValue"` // e.g. "9'", "45'+2'"
		Value        float64 `json:"value"`        // seconds from match start
	}

	// TeamRef is a lightweight team reference used in play-by-play Detail entries.
	TeamRef struct {
		ID string `json:"id"`
	}

	// Athlete is a player entity used in play-by-play events and Summary rosters.
	Athlete struct {
		Links       []Link  `json:"links"`
		Team        TeamRef `json:"team"`
		ID          string  `json:"id"`
		DisplayName string  `json:"displayName"`
		ShortName   string  `json:"shortName"`
		FullName    string  `json:"fullName"`
		Jersey      string  `json:"jersey"` // jersey number as a string
		Position    string  `json:"position"`
		Headshot    string  `json:"headshot"` // URL
	}

	// Broadcast describes a single TV or streaming broadcast for a competition.
	// This covers the simple scoreboard format {"market":"national","names":["FOX"]}.
	Broadcast struct {
		Names  []string `json:"names"`
		Market string   `json:"market"`
	}

	// Headline is a short editorial text associated with a competition.
	Headline struct {
		Description   string       `json:"description"`
		Type          HeadlineType `json:"type"`
		ShortLinkText string       `json:"shortLinkText"`
	}

	// Link is a hyperlink with semantic relationship metadata.
	Link struct {
		Rel        []string `json:"rel"`
		Href       string   `json:"href"`
		Text       string   `json:"text"`
		IsExternal bool     `json:"isExternal"`
		IsPremium  bool     `json:"isPremium"`
		IsHidden   bool     `json:"isHidden"`
	}
)
