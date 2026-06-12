# ESPN API — Data Models, Enums & Constants

Comprehensive breakdown of all types, enums, constants, and reusable structures found in the ESPN API responses.

---

## Enums

### Status State
**Field:** `status.type.state`  
**Values:** Represents the overall match state

```
"pre"   → Scheduled (not started)
"in"    → In progress (live or halftime)
"post"  → Post-match (finished)
```

**Go Definition:**
```go
type StatusState string

const (
    StatusStatePre  StatusState = "pre"
    StatusStateIn   StatusState = "in"
    StatusStatePost StatusState = "post"
)
```

---

### Status Detail
**Field:** `status.type.detail`  
**Values:** Human-readable status detail

```
"TBD"   → To Be Determined (scheduled, time not set)
"Live"  → Currently playing
"HT"    → Halftime
"FT"    → Full Time
"ET"    → Extra Time
"PSO"   → Penalty Shootout
"SUS"   → Suspended
"ABD"   → Abandoned
"POST"  → Postgame
```

**Go Definition:**
```go
type StatusDetail string

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
```

---

### Home/Away Position
**Field:** `competitor.homeAway`  
**Values:** Team position relative to match

```
"home"  → Home team (plays at their venue)
"away"  → Away team (plays at opponent's venue)
```

**Go Definition:**
```go
type HomeAway string

const (
    HomeAwayHome HomeAway = "home"
    HomeAwayAway HomeAway = "away"
)
```

---

### Competitor Type
**Field:** `competitor.type`  
**Values:** Type of competitor entity

```
"team"   → Team (most common)
"person" → Individual (rare in soccer, more in golf/tennis)
```

**Go Definition:**
```go
type CompetitorType string

const (
    CompetitorTypeTeam   CompetitorType = "team"
    CompetitorTypePerson CompetitorType = "person"
)
```

---

### Play-by-Play Event Type IDs
**Field:** `details[].type.id` / `details[].type.text`  
**Values:** Event types in match timeline

| ID | Text | Category | Fields |
|---|---|---|---|
| 70 | Goal | Scoring | scoringPlay: true, athletesInvolved |
| 71 | Own Goal | Scoring | scoringPlay: true, ownGoal: true |
| 72 | Penalty Goal | Scoring | scoringPlay: true, penaltyKick: true |
| 73 | Missed Penalty | Play | penaltyKick: true |
| 94 | Yellow Card | Discipline | yellowCard: true |
| 95 | Red Card | Discipline | redCard: true |
| 96 | Substitution | Roster | athletesInvolved[0] out, [1] in |
| ? | Foul | Play | (likely type) |
| ? | Offside | Play | (likely type) |
| ? | Corner Kick | Play | (likely type) |
| ? | Free Kick | Play | (likely type) |

**Go Definition:**
```go
type EventTypeID int

const (
    EventTypeGoal            EventTypeID = 70
    EventTypeOwnGoal         EventTypeID = 71
    EventTypePenaltyGoal     EventTypeID = 72
    EventTypeMissedPenalty   EventTypeID = 73
    EventTypeYellowCard      EventTypeID = 94
    EventTypeRedCard         EventTypeID = 95
    EventTypeSubstitution    EventTypeID = 96
)

type EventTypeText string

const (
    EventTypeTextGoal           EventTypeText = "Goal"
    EventTypeTextOwnGoal        EventTypeText = "Own Goal"
    EventTypeTextPenaltyGoal    EventTypeText = "Penalty Goal"
    EventTypeTextMissedPenalty  EventTypeText = "Missed Penalty"
    EventTypeTextYellowCard     EventTypeText = "Yellow Card"
    EventTypeTextRedCard        EventTypeText = "Red Card"
    EventTypeTextSubstitution   EventTypeText = "Substitution"
)
```

---

### Calendar Type
**Field:** `league.calendarType`  
**Values:** How matches are organized in calendar

```
"list"  → Calendar entries are tournament phases/weeks (e.g., World Cup)
"day"   → Calendar entries are individual dates (e.g., Premier League)
```

**Go Definition:**
```go
type CalendarType string

const (
    CalendarTypeList CalendarType = "list"
    CalendarTypeDay  CalendarType = "day"
)
```

---

### Statistic Names (Common)
**Field:** `competitor.statistics[].name` / `abbreviation`  
**Values:** Standardized stat names (common across sports)

**Soccer/Football:**
```
appearances (APP)
foulsCommitted (FC)
wonCorners (CW)
goalAssists (A)
possessionPct (PP)
shotsOnTarget (SOG)
totalGoals (G)
totalShots (SHOT)
passCompletionPct (PC)
clearances (CLR)
saves (SAV)
```

**Basketball:**
```
fieldGoalsPct (FG%)
threePointersPct (3P%)
rebounds (REB)
assists (AST)
steals (STL)
blocks (BLK)
turnovers (TO)
points (PTS)
```

**Football (American):**
```
passingYards (PASS YD)
passingTouchdowns (PASS TD)
interceptions (INT)
rushingYards (RUSH YD)
rushingTouchdowns (RUSH TD)
receivingYards (REC YD)
receivingTouchdowns (REC TD)
```

**Go Definition:**
```go
type StatisticName string

const (
    // Soccer
    StatisticNameAppearances       StatisticName = "appearances"
    StatisticNameFoulsCommitted    StatisticName = "foulsCommitted"
    StatisticNameWonCorners        StatisticName = "wonCorners"
    StatisticNameGoalAssists       StatisticName = "goalAssists"
    StatisticNamePossessionPct     StatisticName = "possessionPct"
    StatisticNameShotsOnTarget     StatisticName = "shotsOnTarget"
    StatisticNameTotalGoals        StatisticName = "totalGoals"
    StatisticNameTotalShots        StatisticName = "totalShots"
    // ... add more as needed
)

type StatisticAbbreviation string

const (
    StatisticAbbrevAppearances       StatisticAbbreviation = "APP"
    StatisticAbbrevFoulsCommitted    StatisticAbbreviation = "FC"
    StatisticAbbrevWonCorners        StatisticAbbreviation = "CW"
    StatisticAbbrevGoalAssists       StatisticAbbreviation = "A"
    StatisticAbbrevPossessionPct     StatisticAbbreviation = "PP"
    StatisticAbbrevShotsOnTarget     StatisticAbbreviation = "SOG"
    StatisticAbbrevTotalGoals        StatisticAbbreviation = "G"
    StatisticAbbrevTotalShots        StatisticAbbreviation = "SHOT"
)
```

---

### Link Relationship Types
**Field:** `*.links[].rel[]`  
**Values:** Semantic meaning of URL link

```
"clubhouse"  → Team homepage
"desktop"    → Desktop view indicator
"mobile"     → Mobile view indicator
"stats"      → Statistics page
"schedule"   → Schedule/fixtures page
"squad"      → Team roster/squad page
"playercard" → Individual player card
"athlete"    → Athlete profile
"full"       → Full-size logo
"dark"       → Dark theme variant of logo
"default"    → Default theme of logo
"team"       → Team page
"external"   → External link
"premium"    → Premium content
"hidden"     → Hidden from normal UI
```

**Go Definition:**
```go
type LinkRelation string

const (
    LinkRelationClubhouse   LinkRelation = "clubhouse"
    LinkRelationDesktop     LinkRelation = "desktop"
    LinkRelationMobile      LinkRelation = "mobile"
    LinkRelationStats       LinkRelation = "stats"
    LinkRelationSchedule    LinkRelation = "schedule"
    LinkRelationSquad       LinkRelation = "squad"
    LinkRelationPlayerCard  LinkRelation = "playercard"
    LinkRelationAthlete     LinkRelation = "athlete"
    LinkRelationFull        LinkRelation = "full"
    LinkRelationDark        LinkRelation = "dark"
    LinkRelationDefault     LinkRelation = "default"
    LinkRelationTeam        LinkRelation = "team"
    LinkRelationExternal    LinkRelation = "external"
    LinkRelationPremium     LinkRelation = "premium"
    LinkRelationHidden      LinkRelation = "hidden"
)
```

---

### League Slugs (Constants)
**Field:** `league.slug`  
**Values:** Unique identifier for each league

**Soccer:**
```go
const (
    LeagueSlugFIFAWorld    = "fifa.world"
    LeagueSlugPremierLeague = "eng.1"
    LeagueSlugLaLiga        = "esp.1"
    LeagueSlugSerieA        = "ita.1"
    LeagueSlugLigue1        = "fra.1"
    LeagueSlugBundesliga    = "deu.1"
    LeagueSlugMLS           = "usa.1"
)
```

**Basketball:**
```go
const (
    LeagueSlugNBA = "nba"
)
```

**Football:**
```go
const (
    LeagueSlugNFL = "nfl"
)
```

---

### Sport Codes (Constants)
**Field:** URL path `{sport}` segment  
**Values:** Sport identifier in API path

```go
const (
    SportSoccer     = "soccer"
    SportBasketball = "basketball"
    SportFootball   = "football"
    SportBaseball   = "baseball"
    SportHockey     = "hockey"
    SportGolf       = "golf"
)
```

---

## Core Models/Structures

### Scoreboard Response (Root)

```go
type Scoreboard struct {
    Leagues []League  `json:"leagues"`
    Season  Season    `json:"season"`
    Day     DayInfo   `json:"day"`
    Events  []Event   `json:"events"`
}
```

---

### League

```go
type League struct {
    ID                    string           `json:"id"`
    UID                   string           `json:"uid"`
    Name                  string           `json:"name"`
    Abbreviation          string           `json:"abbreviation"`
    MidsizeName           string           `json:"midsizeName"`
    Slug                  string           `json:"slug"`
    Season                Season           `json:"season"`
    Logos                 []Logo           `json:"logos"`
    CalendarType          CalendarType     `json:"calendarType"`
    CalendarIsWhitelist   bool             `json:"calendarIsWhitelist"`
    CalendarStartDate     time.Time        `json:"calendarStartDate"`
    CalendarEndDate       time.Time        `json:"calendarEndDate"`
    Calendar              []CalendarEntry  `json:"calendar"`
}
```

**Notes:**
- `CalendarType` determines if `Calendar` contains phases (tournament) or dates (league)
- `CalendarIsWhitelist` indicates if calendar is exhaustive or partial

---

### Season

```go
type Season struct {
    Year        int          `json:"year"`
    StartDate   time.Time    `json:"startDate"`
    EndDate     time.Time    `json:"endDate"`
    DisplayName string       `json:"displayName"`
    Type        SeasonType   `json:"type"`
}
```

---

### SeasonType

```go
type SeasonType struct {
    ID           string `json:"id"`
    Type         int    `json:"type"` // Type code (13802 for World Cup, 3 for NBA Postseason, etc.)
    Name         string `json:"name"` // "Group Stage", "Postseason", "Regular Season", etc.
    Abbreviation string `json:"abbreviation"`
}
```

---

### DayInfo

```go
type DayInfo struct {
    Date string `json:"date"` // YYYY-MM-DD format
}
```

---

### CalendarEntry

```go
type CalendarEntry struct {
    Label          string             `json:"label"`          // "Group", "Round of 32", "Week 1"
    Detail         string             `json:"detail"`         // "Jun 11-27", "Sep 9-15"
    Value          string             `json:"value"`          // "1", "2", etc.
    StartDate      time.Time          `json:"startDate"`
    EndDate        time.Time          `json:"endDate"`
    AlternateLabel string             `json:"alternateLabel"` // Optional
    Entries        []CalendarEntry    `json:"entries"`        // Nested entries for hierarchical calendars
}
```

---

### Event

```go
type Event struct {
    ID            string          `json:"id"`
    UID           string          `json:"uid"`
    Date          time.Time       `json:"date"`
    Name          string          `json:"name"` // "South Africa at Mexico"
    ShortName     string          `json:"shortName"` // "RSA @ MEX"
    Season        EventSeason     `json:"season"`
    Competitions  []Competition   `json:"competitions"`
}
```

---

### EventSeason

```go
type EventSeason struct {
    Year  int    `json:"year"`
    Type  int    `json:"type"`
    Slug  string `json:"slug"` // "group-stage"
}
```

---

### Competition

```go
type Competition struct {
    ID              string         `json:"id"`
    UID             string         `json:"uid"`
    Date            time.Time      `json:"date"`
    StartDate       time.Time      `json:"startDate"`
    Attendance      *int           `json:"attendance"`
    TimeValid       bool           `json:"timeValid"`
    Recent          bool           `json:"recent"`
    Status          Status         `json:"status"`
    Venue           *Venue         `json:"venue"`
    Format          Format         `json:"format"`
    Notes           []interface{}  `json:"notes"`
    GeoBroadcasts   []Broadcast    `json:"geoBroadcasts"`
    Broadcasts      []Broadcast    `json:"broadcasts"`
    Competitors     []Competitor   `json:"competitors"`
    Details         []Detail       `json:"details"`
    Headlines       []Headline     `json:"headlines"`
}
```

---

### Status

```go
type Status struct {
    Clock       *float64   `json:"clock"`       // Seconds elapsed (null for scheduled)
    DisplayClock string    `json:"displayClock"` // "90'+8'", "2:45 2nd", "HT", "TBD"
    Period      int        `json:"period"`       // 1 (1st half), 2 (2nd half), 3 (OT), etc.
    Type        StatusType `json:"type"`
}
```

---

### StatusType

```go
type StatusType struct {
    ID          string       `json:"id"`
    Name        string       `json:"name"`          // "STATUS_FULL_TIME", "STATUS_IN_PROGRESS"
    State       StatusState  `json:"state"`         // "pre", "in", "post"
    Completed   bool         `json:"completed"`
    Description string       `json:"description"`  // "Full Time", "In Progress"
    Detail      StatusDetail `json:"detail"`       // "FT", "Live", "HT"
    ShortDetail StatusDetail `json:"shortDetail"`  // "FT", "Live"
}
```

---

### Venue

```go
type Venue struct {
    ID       string  `json:"id"`
    FullName string  `json:"fullName"` // "Estadio Banorte"
    Address  Address `json:"address"`
}
```

---

### Address

```go
type Address struct {
    City    string `json:"city"`
    Country string `json:"country"`
    State   string `json:"state"`    // Optional
    Zip     string `json:"zip"`      // Optional
}
```

---

### Format

```go
type Format struct {
    Regulation Regulation `json:"regulation"`
}

type Regulation struct {
    Periods int `json:"periods"` // 2 for soccer, 4 for basketball/football
}
```

---

### Competitor

```go
type Competitor struct {
    ID         string         `json:"id"`
    UID        string         `json:"uid"`
    Type       CompetitorType `json:"type"` // "team"
    Order      int            `json:"order"`
    HomeAway   HomeAway       `json:"homeAway"`
    Winner     bool           `json:"winner"`
    Advance    bool           `json:"advance"`
    Form       string         `json:"form"` // "WWWWD" (recent results)
    Score      string         `json:"score"`
    Records    []Record       `json:"records"`
    Team       Team           `json:"team"`
    Statistics []Statistic    `json:"statistics"`
    Players    []Athlete      `json:"players"` // Optional, in summary
}
```

---

### Team

```go
type Team struct {
    ID              string   `json:"id"`
    UID             string   `json:"uid"`
    Abbreviation    string   `json:"abbreviation"` // "MEX", "RSA"
    DisplayName     string   `json:"displayName"` // "Mexico"
    ShortDisplayName string  `json:"shortDisplayName"`
    Name            string   `json:"name"`
    Location        string   `json:"location"`
    Color           string   `json:"color"` // Hex color code (no #)
    AlternateColor  string   `json:"alternateColor"`
    IsActive        bool     `json:"isActive"`
    Logo            string   `json:"logo"` // URL
    Links           []Link   `json:"links"`
    Venue           *Venue   `json:"venue"` // Optional
}
```

---

### Record

```go
type Record struct {
    Name           string `json:"name"` // "All Splits"
    Type           string `json:"type"` // "total"
    Summary        string `json:"summary"` // "1-0-0" (W-D-L)
    Abbreviation   string `json:"abbreviation"`
}
```

---

### Statistic

```go
type Statistic struct {
    Name         StatisticName   `json:"name"`
    Abbreviation StatisticAbbreviation `json:"abbreviation"`
    DisplayValue string          `json:"displayValue"` // "12", "50.5%"
}
```

---

### Detail (Play-by-Play)

```go
type Detail struct {
    Type              DetailType      `json:"type"`
    Clock             Clock           `json:"clock"`
    Team              TeamRef         `json:"team"`
    ScoreValue        int             `json:"scoreValue"`
    ScoringPlay       bool            `json:"scoringPlay"`
    RedCard           bool            `json:"redCard"`
    YellowCard        bool            `json:"yellowCard"`
    PenaltyKick       bool            `json:"penaltyKick"`
    OwnGoal           bool            `json:"ownGoal"`
    Shootout          bool            `json:"shootout"`
    AthletesInvolved  []Athlete       `json:"athletesInvolved"`
}
```

---

### DetailType

```go
type DetailType struct {
    ID   EventTypeID   `json:"id"`
    Text EventTypeText `json:"text"`
}
```

---

### Clock

```go
type Clock struct {
    Value        float64 `json:"value"`        // Seconds
    DisplayValue string  `json:"displayValue"` // "9'", "45'+2'"
}
```

---

### TeamRef (Lightweight Team Reference)

```go
type TeamRef struct {
    ID string `json:"id"`
}
```

---

### Athlete

```go
type Athlete struct {
    ID          string   `json:"id"`
    DisplayName string   `json:"displayName"`
    ShortName   string   `json:"shortName"`
    FullName    string   `json:"fullName"`
    Jersey      string   `json:"jersey"` // Jersey number
    Team        TeamRef  `json:"team"`
    Links       []Link   `json:"links"`
    Position    string   `json:"position"` // "LM", "CB", "GK"
    Headshot    string   `json:"headshot"` // Profile photo URL
}
```

---

### Logo

```go
type Logo struct {
    Href        string   `json:"href"` // URL
    Width       int      `json:"width"`
    Height      int      `json:"height"`
    Alt         string   `json:"alt"`
    Rel         []string `json:"rel"` // ["full", "default"]
    LastUpdated time.Time `json:"lastUpdated"`
}
```

---

### Broadcast

```go
type Broadcast struct {
    Type   *BroadcastType `json:"type"`
    Market *Market        `json:"market"`
    Media  *MediaInfo     `json:"media"`
    Lang   string         `json:"lang"`
    Region string         `json:"region"`
}

type BroadcastType struct {
    ID        string `json:"id"`
    ShortName string `json:"shortName"` // "TV", "STREAMING"
}

type Market struct {
    ID   string `json:"id"`
    Type string `json:"type"` // "National", "Regional"
}

type MediaInfo struct {
    ShortName string `json:"shortName"` // "FOX", "Peacock"
}
```

---

### Headline

```go
type Headline struct {
    Description   string `json:"description"`
    Type          string `json:"type"` // "Recap", "Preview"
    ShortLinkText string `json:"shortLinkText"`
}
```

---

### Link

```go
type Link struct {
    Rel        []string `json:"rel"`
    Href       string   `json:"href"`
    Text       string   `json:"text"`
    IsExternal bool     `json:"isExternal"`
    IsPremium  bool     `json:"isPremium"`
    IsHidden   bool     `json:"isHidden"`
}
```

---

## Summary Endpoint Models

### SummaryResponse (Root)

```go
type SummaryResponse struct {
    Boxscore BoxScore    `json:"boxscore"`
    Articles []Article   `json:"articles"`
    Videos   []Video     `json:"videos"`
    Odds     []Odd       `json:"odds"`
}
```

---

### BoxScore

```go
type BoxScore struct {
    Form       []Form           `json:"form"`
    Statistics []CompetitorStat `json:"statistics"`
}

type Form struct {
    DisplayOrder int        `json:"displayOrder"`
    Team         Team       `json:"team"`
    Events       []FormEvent `json:"events"`
}

type FormEvent struct {
    ID                    string `json:"id"`
    Links                 []Link `json:"links"`
    AtVs                  string `json:"atVs"` // "vs", "at"
    GameDate              time.Time `json:"gameDate"`
    Score                 string `json:"score"` // "5-1"
    HomeTeamID            string `json:"homeTeamId"`
    AwayTeamID            string `json:"awayTeamId"`
    HomeTeamScore         string `json:"homeTeamScore"`
    AwayTeamScore         string `json:"awayTeamScore"`
    HomeAggregateScore    string `json:"homeAggregateScore"`
    AwayAggregateScore    string `json:"awayAggregateScore"`
    HomeShootoutScore     string `json:"homeShootoutScore"`
    AwayShootoutScore     string `json:"awayShootoutScore"`
    GameResult            string `json:"gameResult"` // "W", "L", "D"
    CompetitionName       string `json:"competitionName"`
    LeagueName            string `json:"leagueName"`
    LeagueAbbreviation    string `json:"leagueAbbreviation"`
}
```

---

### Article

```go
type Article struct {
    ID          string   `json:"id"`
    Description string   `json:"description"`
    Type        string   `json:"type"`
    Links       []Link   `json:"links"`
}
```

---

### Video

```go
type Video struct {
    ID          string   `json:"id"`
    Description string   `json:"description"`
    Type        string   `json:"type"`
    Links       []Link   `json:"links"`
}
```

---

### Odd

```go
type Odd struct {
    Provider    string `json:"provider"`
    DisplayName string `json:"displayName"`
    // Varies by provider
}
```

---

## Reusable Type Patterns

### Optional Fields

Fields that are frequently null should use pointers:

```go
type Competition struct {
    Attendance      *int       `json:"attendance"`     // May be null
    Venue           *Venue     `json:"venue"`          // May be null
}

type Event struct {
    // Clock is null for scheduled matches
    Clock           *float64   `json:"clock"`
}
```

---

### String Enums

For enum-like strings, use `string` type with const values:

```go
type StatusState string

const (
    StatusStatePre  StatusState = "pre"
    StatusStateIn   StatusState = "in"
    StatusStatePost StatusState = "post"
)

// Useful helper function
func (s StatusState) IsLive() bool {
    return s == StatusStateIn
}
```

---

### ID Handling

IDs should always be strings to avoid overflow:

```go
type Event struct {
    ID   string `json:"id"`   // "760415"
}

type Team struct {
    ID   string `json:"id"`   // "203"
}

type Athlete struct {
    ID   string `json:"id"`   // "233075"
}
```

Never parse IDs to `int64` — keep them as strings.

---

## Duplicate/Reusable Structures

### Team
**Appears in:**
- `Competitor.Team`
- `Venue.Team` (optional)
- `BoxScore.Form.Team`

**Reuse:** Single `Team` type across all uses

---

### Athlete
**Appears in:**
- `Detail.AthletesInvolved[]`
- `Competitor.Players[]` (summary only)

**Reuse:** Single `Athlete` type

---

### Link
**Appears in:**
- `League.Logos` (no, that's Logo)
- `Team.Links[]`
- `Athlete.Links[]`
- `Article.Links[]`
- `Broadcast` (no direct links)

**Reuse:** Single `Link` type

---

### Logo
**Appears in:**
- `League.Logos[]`
- `Team.Logo` (string, not array)

**Note:** Team.Logo is a single URL string, not full Logo structure

---

### Statistic
**Appears in:**
- `Competitor.Statistics[]` (scoreboard)
- `BoxScore.Statistics[]` (summary)

**Reuse:** Single `Statistic` type

---

### Address
**Appears in:**
- `Venue.Address`

**Reuse:** Single `Address` type (could be extracted if used elsewhere)

---

## Constants Worth Defining

### Sport Codes
```go
const (
    SportSoccer     = "soccer"
    SportBasketball = "basketball"
    SportFootball   = "football"
)
```

### Known League Slugs
```go
const (
    LeagueSlugFIFAWorld       = "fifa.world"
    LeagueSlugPremierLeague   = "eng.1"
    LeagueSlugLaLiga          = "esp.1"
    LeagueSlugSerieA          = "ita.1"
    LeagueSlugMLS             = "usa.1"
    LeagueSlugNBA             = "nba"
    LeagueSlugNFL             = "nfl"
)
```

### Default Values
```go
const (
    DefaultUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    DefaultBaseURL   = "https://site.api.espn.com/apis/site/v2/sports"
    DefaultTimeout   = 10 * time.Second
)
```

### Period Constants
```go
const (
    PeriodFirstHalf        = 1
    PeriodSecondHalf       = 2
    PeriodFirstOT          = 3
    PeriodSecondOT         = 4
    PeriodShootout         = 5
)
```

---

## Validation Rules

### Required vs Optional

| Field | Type | Required | Notes |
|---|---|---|---|
| Event.ID | string | ✅ | Always present |
| Event.Name | string | ✅ | Always present |
| Competitor.Score | string | ✅ | Even if null in API, always present in competitors |
| Status.Clock | *float64 | ❌ | Null for scheduled matches |
| Venue | *Venue | ❌ | Some matches may not have venue data |
| Attendance | *int | ❌ | Not all competitions include attendance |
| Details | []Detail | ✅ | Always array, may be empty |

---

## Go Code Template

```go
package espn

// Status states
type StatusState string

const (
    StatusStatePre  StatusState = "pre"
    StatusStateIn   StatusState = "in"
    StatusStatePost StatusState = "post"
)

// Status details
type StatusDetail string

const (
    StatusDetailLive      StatusDetail = "Live"
    StatusDetailFullTime  StatusDetail = "FT"
    StatusDetailHalftime  StatusDetail = "HT"
    // ... more
)

// Home/Away
type HomeAway string

const (
    HomeAwayHome HomeAway = "home"
    HomeAwayAway HomeAway = "away"
)

// Scoreboard is the root response
type Scoreboard struct {
    Leagues []League  `json:"leagues"`
    Season  Season    `json:"season"`
    Day     DayInfo   `json:"day"`
    Events  []Event   `json:"events"`
}

// ... (all other type definitions)
```

