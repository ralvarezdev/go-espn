package espn

import (
	"encoding/json"
	"testing"
)

// scoreboardFixture is a minimal but realistic ESPN scoreboard response that covers
// every field whose Go type is non-obvious or has previously caused a decode bug:
//   - leagues[].season.type  → object, not int  (SeasonType)
//   - all date fields        → seconds-less ESPN format  (ESPNTime)
//   - root season.type       → plain int  (ScoreboardSeason)
//   - events[].season.type   → plain int  (EventSeason)
//   - enum string fields     → RecordType, HeadlineType, StatusState, StatusDetail, …
const scoreboardFixture = `{
  "leagues": [{
    "id": "1",
    "uid": "s:600~l:1",
    "name": "FIFA World Cup",
    "abbreviation": "FIFA",
    "midsizeName": "World Cup",
    "slug": "fifa.world",
    "season": {
      "year": 2026,
      "startDate": "2026-06-11T04:00Z",
      "endDate": "2026-07-19T04:00Z",
      "displayName": "2026 FIFA World Cup",
      "type": {"id": "1", "type": 1, "abbreviation": "tour"}
    },
    "calendarType": "list",
    "calendarIsWhitelist": true,
    "calendarStartDate": "2026-06-11T04:00Z",
    "calendarEndDate": "2026-07-19T04:00Z",
    "logos": [{
      "href": "https://a.espncdn.com/logo.png",
      "width": 500,
      "height": 500,
      "alt": "",
      "rel": ["full", "default"],
      "lastUpdated": "2026-01-01T00:00Z"
    }],
    "calendar": [{
      "label": "Group Stage",
      "detail": "Jun 11 - Jul 3",
      "value": "1",
      "alternateLabel": "Groups",
      "startDate": "2026-06-11T04:00Z",
      "endDate": "2026-07-03T04:00Z",
      "entries": []
    }]
  }],
  "season": {"year": 2026, "type": 1},
  "day": {"date": "2026-06-12"},
  "events": [{
    "id": "760415",
    "uid": "s:600~l:1~e:760415",
    "date": "2026-06-11T19:00Z",
    "name": "Mexico vs South Africa",
    "shortName": "MEX vs RSA",
    "season": {"year": 2026, "type": 3, "slug": "group-stage"},
    "competitions": [{
      "id": "760415",
      "uid": "s:600~l:1~e:760415~c:760415",
      "date": "2026-06-11T19:00Z",
      "startDate": "2026-06-11T19:00Z",
      "timeValid": true,
      "recent": false,
      "attendance": 65000,
      "status": {
        "clock": null,
        "displayClock": "TBD",
        "period": 0,
        "type": {
          "id": "1",
          "name": "STATUS_SCHEDULED",
          "state": "pre",
          "completed": false,
          "description": "Scheduled",
          "detail": "TBD",
          "shortDetail": "TBD"
        }
      },
      "venue": {
        "id": "1",
        "fullName": "Estadio Banorte",
        "address": {"city": "Culiacan", "country": "Mexico", "state": "", "zip": ""}
      },
      "format": {"regulation": {"periods": 2}},
      "notes": [],
      "geoBroadcasts": [],
      "broadcasts": [{"market": "national", "names": ["FOX"]}],
      "competitors": [{
        "id": "203",
        "uid": "s:600~l:1~t:203",
        "type": "team",
        "order": 1,
        "homeAway": "home",
        "winner": false,
        "advance": false,
        "score": "0",
        "form": "WWWWD",
        "records": [{"name": "All Splits", "type": "total", "summary": "5-1-0", "abbreviation": "Game"}],
        "statistics": [{"name": "possessionPct", "abbreviation": "PP", "displayValue": "52.3"}],
        "players": [],
        "team": {
          "id": "203",
          "uid": "s:600~l:1~t:203",
          "abbreviation": "MEX",
          "displayName": "Mexico",
          "shortDisplayName": "Mexico",
          "name": "Mexico",
          "location": "Mexico",
          "color": "006847",
          "alternateColor": "ffffff",
          "isActive": true,
          "logo": "https://a.espncdn.com/logo.png",
          "links": []
        }
      }],
      "details": [{
        "type": {"id": "70", "text": "Goal"},
        "clock": {"value": 540.0, "displayValue": "9'"},
        "team": {"id": "203"},
        "scoreValue": 1,
        "scoringPlay": true,
        "redCard": false,
        "yellowCard": false,
        "penaltyKick": false,
        "ownGoal": false,
        "shootout": false,
        "athletesInvolved": []
      }],
      "headlines": [{"description": "Match Preview", "type": "Preview", "shortLinkText": "preview"}]
    }]
  }]
}`

// summaryFixture is a minimal ESPN summary response exercising FormEvent fields
// that have non-obvious types: ESPNTime, AtVsType, GameResultType.
const summaryFixture = `{
  "boxscore": {
    "form": [{
      "displayOrder": 1,
      "team": {
        "id": "203", "uid": "s:600~l:1~t:203",
        "abbreviation": "MEX", "displayName": "Mexico",
        "shortDisplayName": "Mexico", "name": "Mexico",
        "location": "Mexico", "color": "006847",
        "alternateColor": "ffffff", "isActive": true,
        "logo": "https://a.espncdn.com/logo.png", "links": []
      },
      "events": [{
        "id": "760000",
        "links": [],
        "atVs": "vs",
        "gameDate": "2026-06-05T19:00Z",
        "score": "3-1",
        "homeTeamId": "203",
        "awayTeamId": "301",
        "homeTeamScore": "3",
        "awayTeamScore": "1",
        "homeAggregateScore": "",
        "awayAggregateScore": "",
        "homeShootoutScore": "",
        "awayShootoutScore": "",
        "gameResult": "W",
        "competitionName": "Friendly",
        "leagueName": "International Friendlies",
        "leagueAbbreviation": "INT"
      }]
    }],
    "statistics": []
  },
  "articles": [],
  "videos": [],
  "odds": []
}`

// TestESPNTimeUnmarshal verifies that ESPNTime decodes both ESPN's seconds-less
// timestamp format and standard RFC3339, and tolerates null/empty values.
func TestESPNTimeUnmarshal(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		want    string // expected UTC value formatted as RFC3339, "" for zero
		wantErr bool
	}{
		{
			name:  "espn seconds-less format",
			input: `"2026-06-11T04:00Z"`,
			want:  "2026-06-11T04:00:00Z",
		},
		{
			name:  "full rfc3339 with seconds",
			input: `"2026-06-11T04:00:30Z"`,
			want:  "2026-06-11T04:00:30Z",
		},
		{
			name:  "seconds-less with offset",
			input: `"2026-06-11T04:00-05:00"`,
			want:  "2026-06-11T09:00:00Z",
		},
		{
			name:  "json null",
			input: `null`,
			want:  "",
		},
		{
			name:  "empty string",
			input: `""`,
			want:  "",
		},
		{
			name:    "unparseable",
			input:   `"not-a-date"`,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var got ESPNTime
			err := json.Unmarshal([]byte(tt.input), &got)
			if tt.wantErr {
				if err == nil {
					t.Fatalf("expected error, got nil (value %v)", got.Time)
				}
				return
			}
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if tt.want == "" {
				if !got.IsZero() {
					t.Fatalf("expected zero time, got %v", got.Time)
				}
				return
			}
			if g := got.UTC().Format("2006-01-02T15:04:05Z07:00"); g != tt.want {
				t.Fatalf("got %q, want %q", g, tt.want)
			}
		})
	}
}

// TestESPNTimeEmbeddedInEvent verifies the real-world failure case: decoding an
// Event whose date uses ESPN's seconds-less format, which broke standard
// time.Time unmarshaling on every request.
func TestESPNTimeEmbeddedInEvent(t *testing.T) {
	const raw = `{"date":"2026-06-11T04:00Z","id":"760415"}`

	var ev Event
	if err := json.Unmarshal([]byte(raw), &ev); err != nil {
		t.Fatalf("decode Event: %v", err)
	}
	if got := ev.Date.UTC().Format("2006-01-02T15:04:05Z07:00"); got != "2026-06-11T04:00:00Z" {
		t.Fatalf("Event.Date = %q, want 2026-06-11T04:00:00Z", got)
	}

	// Re-marshaling round-trips through the embedded time.Time (RFC3339 output).
	out, err := json.Marshal(ev.Date)
	if err != nil {
		t.Fatalf("marshal Event.Date: %v", err)
	}
	if string(out) != `"2026-06-11T04:00:00Z"` {
		t.Fatalf("marshaled Event.Date = %s, want \"2026-06-11T04:00:00Z\"", out)
	}
}

// TestSeasonTypeUnmarshal verifies that SeasonType correctly decodes ESPN's
// structured season descriptor with a quoted ID field.
func TestSeasonTypeUnmarshal(t *testing.T) {
	// ESPN returns season.type as an object with quoted id, not an integer.
	const raw = `{"id":"4","type":4,"abbreviation":"post"}`

	var st SeasonType
	if err := json.Unmarshal([]byte(raw), &st); err != nil {
		t.Fatalf("decode SeasonType: %v", err)
	}
	if st.ID != "4" {
		t.Fatalf("SeasonType.ID = %q, want \"4\"", st.ID)
	}
	if st.Type != 4 {
		t.Fatalf("SeasonType.Type = %d, want 4", st.Type)
	}
	if st.Abbreviation != "post" {
		t.Fatalf("SeasonType.Abbreviation = %q, want \"post\"", st.Abbreviation)
	}
}

// TestSeasonWithSeasonTypeUnmarshal verifies that Season (inside League) correctly
// decodes with SeasonType as a structured object.
func TestSeasonWithSeasonTypeUnmarshal(t *testing.T) {
	const raw = `{
		"year": 2026,
		"startDate": "2026-01-01T00:00Z",
		"endDate": "2026-12-31T23:59Z",
		"displayName": "2026 Season",
		"type": {"id":"1","type":1,"abbreviation":"reg"}
	}`

	var season Season
	if err := json.Unmarshal([]byte(raw), &season); err != nil {
		t.Fatalf("decode Season: %v", err)
	}
	if season.Year != 2026 {
		t.Fatalf("Season.Year = %d, want 2026", season.Year)
	}
	if season.Type.ID != "1" {
		t.Fatalf("Season.Type.ID = %q, want \"1\"", season.Type.ID)
	}
	if season.Type.Type != 1 {
		t.Fatalf("Season.Type.Type = %d, want 1", season.Type.Type)
	}
}

// TestScoreboardResponseDecode decodes a full realistic scoreboard response and
// asserts every field whose Go type is non-obvious. This is the primary regression
// guard against "wrong type" bugs (int vs string, time.Time vs ESPNTime, int vs struct).
func TestScoreboardResponseDecode(t *testing.T) {
	var resp ScoreboardResponse
	if err := json.Unmarshal([]byte(scoreboardFixture), &resp); err != nil {
		t.Fatalf("decode ScoreboardResponse: %v", err)
	}

	// Root-level season.type is a plain int (ScoreboardSeason).
	if resp.Season.Type != 1 {
		t.Errorf("ScoreboardSeason.Type = %d, want 1", resp.Season.Type)
	}
	if resp.Day.Date != "2026-06-12" {
		t.Errorf("DayInfo.Date = %q, want 2026-06-12", resp.Day.Date)
	}

	if len(resp.Leagues) == 0 {
		t.Fatal("Leagues is empty")
	}
	lg := resp.Leagues[0]

	// League.Season.Type must be a SeasonType struct with a string ID.
	if lg.Season.Type.ID != "1" {
		t.Errorf("League.Season.Type.ID = %q, want \"1\"", lg.Season.Type.ID)
	}
	if lg.Season.Type.Type != 1 {
		t.Errorf("League.Season.Type.Type = %d, want 1", lg.Season.Type.Type)
	}
	if lg.Season.Type.Abbreviation != "tour" {
		t.Errorf("League.Season.Type.Abbreviation = %q, want \"tour\"", lg.Season.Type.Abbreviation)
	}

	// League date fields use ESPN's seconds-less format (ESPNTime).
	checkTime := func(label, got, want string) {
		t.Helper()
		if got != want {
			t.Errorf("%s = %q, want %q", label, got, want)
		}
	}
	const fmt = "2006-01-02T15:04:05Z"
	checkTime("League.Season.StartDate", lg.Season.StartDate.UTC().Format(fmt), "2026-06-11T04:00:00Z")
	checkTime("League.Season.EndDate", lg.Season.EndDate.UTC().Format(fmt), "2026-07-19T04:00:00Z")
	checkTime("League.CalendarStartDate", lg.CalendarStartDate.UTC().Format(fmt), "2026-06-11T04:00:00Z")
	checkTime("League.CalendarEndDate", lg.CalendarEndDate.UTC().Format(fmt), "2026-07-19T04:00:00Z")

	// Logo.LastUpdated is *ESPNTime.
	if len(lg.Logos) == 0 || lg.Logos[0].LastUpdated == nil {
		t.Fatal("Logo.LastUpdated is nil")
	}
	checkTime("Logo.LastUpdated", lg.Logos[0].LastUpdated.UTC().Format(fmt), "2026-01-01T00:00:00Z")

	// CalendarEntry has pointer date fields (*ESPNTime).
	if len(lg.Calendar) == 0 || lg.Calendar[0].StartDate == nil {
		t.Fatal("CalendarEntry.StartDate is nil")
	}
	checkTime("CalendarEntry.StartDate", lg.Calendar[0].StartDate.UTC().Format(fmt), "2026-06-11T04:00:00Z")

	if len(resp.Events) == 0 {
		t.Fatal("Events is empty")
	}
	ev := resp.Events[0]

	// Event.Date (ESPNTime).
	checkTime("Event.Date", ev.Date.UTC().Format(fmt), "2026-06-11T19:00:00Z")

	// EventSeason.Type is a plain int (not SeasonType).
	if ev.Season.Type != 3 {
		t.Errorf("EventSeason.Type = %d, want 3", ev.Season.Type)
	}
	if ev.Season.Slug != "group-stage" {
		t.Errorf("EventSeason.Slug = %q, want group-stage", ev.Season.Slug)
	}

	if len(ev.Competitions) == 0 {
		t.Fatal("Competitions is empty")
	}
	comp := ev.Competitions[0]

	// Competition dates (ESPNTime).
	checkTime("Competition.Date", comp.Date.UTC().Format(fmt), "2026-06-11T19:00:00Z")
	checkTime("Competition.StartDate", comp.StartDate.UTC().Format(fmt), "2026-06-11T19:00:00Z")

	// Optional pointer fields.
	if comp.Attendance == nil || *comp.Attendance != 65000 {
		t.Errorf("Competition.Attendance = %v, want 65000", comp.Attendance)
	}
	if comp.Status.Clock != nil {
		t.Errorf("Status.Clock = %v, want nil for scheduled match", *comp.Status.Clock)
	}

	// Status enum fields.
	if comp.Status.Type.State != StatusStatePre {
		t.Errorf("Status.Type.State = %q, want %q", comp.Status.Type.State, StatusStatePre)
	}
	if comp.Status.Type.Detail != StatusDetailTBD {
		t.Errorf("Status.Type.Detail = %q, want %q", comp.Status.Type.Detail, StatusDetailTBD)
	}

	if len(comp.Competitors) == 0 {
		t.Fatal("Competitors is empty")
	}
	cmp := comp.Competitors[0]

	// Competitor enum fields.
	if cmp.HomeAway != HomeAwayHome {
		t.Errorf("Competitor.HomeAway = %q, want %q", cmp.HomeAway, HomeAwayHome)
	}
	if cmp.Type != CompetitorTypeTeam {
		t.Errorf("Competitor.Type = %q, want %q", cmp.Type, CompetitorTypeTeam)
	}

	// Record.Type is RecordType.
	if len(cmp.Records) == 0 || cmp.Records[0].Type != RecordTypeTotal {
		t.Errorf("Record.Type = %q, want %q", cmp.Records[0].Type, RecordTypeTotal)
	}

	// Statistic.Name is StatisticName.
	if len(cmp.Statistics) == 0 || cmp.Statistics[0].Name != StatNamePossessionPct {
		t.Errorf("Statistic.Name = %q, want %q", cmp.Statistics[0].Name, StatNamePossessionPct)
	}

	// Detail play-by-play enum fields.
	if len(comp.Details) == 0 {
		t.Fatal("Details is empty")
	}
	det := comp.Details[0]
	if det.Type.ID != EventTypeIDGoal {
		t.Errorf("Detail.Type.ID = %q, want %q", det.Type.ID, EventTypeIDGoal)
	}
	if det.Type.Text != EventTypeTextGoal {
		t.Errorf("Detail.Type.Text = %q, want %q", det.Type.Text, EventTypeTextGoal)
	}
	if det.Clock.DisplayValue != "9'" {
		t.Errorf("Detail.Clock.DisplayValue = %q, want \"9'\"", det.Clock.DisplayValue)
	}

	// Headline.Type is HeadlineType.
	if len(comp.Headlines) == 0 || comp.Headlines[0].Type != HeadlineTypePreview {
		t.Errorf("Headline.Type = %q, want %q", comp.Headlines[0].Type, HeadlineTypePreview)
	}
}

// TestSummaryResponseDecode decodes a full summary response and checks FormEvent
// fields with non-obvious types: ESPNTime, AtVsType, GameResultType.
func TestSummaryResponseDecode(t *testing.T) {
	var resp SummaryResponse
	if err := json.Unmarshal([]byte(summaryFixture), &resp); err != nil {
		t.Fatalf("decode SummaryResponse: %v", err)
	}

	if len(resp.Boxscore.Form) == 0 {
		t.Fatal("Form is empty")
	}
	form := resp.Boxscore.Form[0]
	if len(form.Events) == 0 {
		t.Fatal("Form.Events is empty")
	}
	ev := form.Events[0]

	// GameDate uses ESPN's seconds-less format (ESPNTime).
	if got := ev.GameDate.UTC().Format("2006-01-02T15:04:05Z"); got != "2026-06-05T19:00:00Z" {
		t.Errorf("FormEvent.GameDate = %q, want 2026-06-05T19:00:00Z", got)
	}

	// AtVs is AtVsType.
	if ev.AtVs != AtVsVs {
		t.Errorf("FormEvent.AtVs = %q, want %q", ev.AtVs, AtVsVs)
	}

	// GameResult is GameResultType.
	if ev.GameResult != GameResultWin {
		t.Errorf("FormEvent.GameResult = %q, want %q", ev.GameResult, GameResultWin)
	}

	if ev.HomeTeamScore != "3" || ev.AwayTeamScore != "1" {
		t.Errorf("scores = %q/%q, want 3/1", ev.HomeTeamScore, ev.AwayTeamScore)
	}
}
