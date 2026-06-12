# ESPN API Test Plan

Comprehensive test coverage for all endpoints, scenarios, and edge cases before Go implementation.

---

## Test Categories

### 1. Endpoint Availability Tests
- [ ] Scoreboard endpoint responds (all sports)
- [ ] Summary endpoint responds (all sports)
- [ ] Proper HTTP status codes (200, 404)
- [ ] Response headers present (Cache-Control, CORS)

### 2. Scoreboard Endpoint Tests

#### Basic Functionality
- [ ] FIFA World Cup scoreboard returns data
- [ ] Premier League scoreboard returns data
- [ ] La Liga scoreboard returns data
- [ ] Serie A scoreboard returns data
- [ ] MLS scoreboard returns data
- [ ] NBA scoreboard returns data
- [ ] NFL scoreboard returns data

#### Query Parameters
- [ ] Date parameter works: `?dates=20260612`
- [ ] Date parameter filters results correctly
- [ ] Invalid date format returns appropriate response
- [ ] Multiple dates parameter (if supported)
- [ ] No date parameter defaults to today

#### Response Structure
- [ ] Root object contains `leagues` array
- [ ] Root object contains `events` array
- [ ] Root object contains `season` object
- [ ] Root object contains `day` object
- [ ] Each league has required fields (id, name, slug)
- [ ] Each event has required fields (id, name, date)
- [ ] Each competition has required fields (status, competitors)

#### Data Completeness
- [ ] Events have at least 2 competitors (home/away)
- [ ] Competitors have scores (string format)
- [ ] Competitors have team info (abbreviation, displayName)
- [ ] Status object always present
- [ ] Status has state field (pre/in/post)
- [ ] Status has type object with name, description, detail

#### Clock/Minute Data
- [ ] Live matches have non-null clock value
- [ ] Finished matches have clock value (final time)
- [ ] Scheduled matches have null clock (or missing)
- [ ] displayClock is human-readable ("90'+8'", "2:45 2nd")
- [ ] period value present (1, 2, 3, 4, etc.)
- [ ] clock value is numeric (seconds)

#### Play-by-Play Data (Details)
- [ ] Goals appear in details array
- [ ] Yellow cards appear in details array
- [ ] Red cards appear in details array
- [ ] Details have clock (time of event)
- [ ] Details have type (with id and text)
- [ ] Details have athletesInvolved array (for goals/cards)
- [ ] scoringPlay flag correct (true for goals)
- [ ] Details array empty for matches without data

#### Status Variations
- [ ] Scheduled match: state="pre", clock=null
- [ ] Live match: state="in", clock=populated
- [ ] Halftime: displayClock="HT", status.detail="HT"
- [ ] Finished match: state="post", clock=final_time
- [ ] Extra time match: status shows ET or period=3+
- [ ] Penalty shootout: status shows PSO

#### Venue Data
- [ ] Venue present when available
- [ ] Venue has fullName
- [ ] Venue has address (city, country)
- [ ] Venue can be null for some matches

#### Calendar Data
- [ ] Tournament (World Cup): calendar has phases (Group, R32, QF, SF, Final)
- [ ] League (Premier League): calendar has individual dates
- [ ] calendarType="list" for tournaments
- [ ] calendarType="day" for leagues
- [ ] Calendar entries have startDate and endDate

#### Statistics
- [ ] Competitors have statistics array
- [ ] Statistics have name, abbreviation, displayValue
- [ ] Common stats present (shots, fouls, possession for soccer)
- [ ] Stats format varies by sport

#### Broadcasts
- [ ] geoBroadcasts present when available
- [ ] broadcasts present when available
- [ ] Broadcast types identified (TV, STREAMING)
- [ ] Media names present (FOX, Peacock, etc.)

#### Teams & Links
- [ ] Team has abbreviation (MEX, RSA, etc.)
- [ ] Team has displayName (Mexico, South Africa)
- [ ] Team has logo URL
- [ ] Team has links array
- [ ] Links have rel, href, text properties

### 3. Summary Endpoint Tests

#### Basic Functionality
- [ ] Summary endpoint returns 200 with valid event ID
- [ ] Summary endpoint returns valid JSON structure
- [ ] Summary works for completed matches
- [ ] Summary works for live matches (if available)

#### Event ID Variations
- [ ] Valid event ID returns data
- [ ] Invalid event ID returns 200 with minimal data
- [ ] Event ID format: numeric string

#### Response Structure
- [ ] Root contains boxscore object
- [ ] Boxscore contains form array
- [ ] Boxscore contains statistics
- [ ] Form has displayOrder, team, events

#### Team Form Data
- [ ] Form shows recent match history
- [ ] Each form event has score, date, result
- [ ] Result codes present (W, L, D)
- [ ] Opponent information included

#### Boxscore Statistics
- [ ] Team statistics present for each team
- [ ] Statistics have name and displayValue
- [ ] Player statistics available (if roster included)

#### Additional Data
- [ ] Articles/headlines field present (may be empty)
- [ ] Videos field present (may be empty)
- [ ] Odds field present (may be empty/null)

### 4. Error Handling Tests

#### Invalid Sport/League
- [ ] Unsupported sport (cricket): returns 404
- [ ] Unsupported league (cricket/ipl): returns 404
- [ ] Error response includes code and message fields
- [ ] Error message is descriptive

#### Invalid Query Parameters
- [ ] Malformed date parameter handling
- [ ] Invalid event ID for summary (returns empty or valid structure)

#### Network/Server Errors
- [ ] SSL/TLS connection works
- [ ] Server responds within timeout
- [ ] Partial responses handled gracefully

### 5. Data Type Tests

#### String Fields
- [ ] Event IDs are numeric strings ("760415")
- [ ] Team IDs are numeric strings ("203")
- [ ] Athlete IDs are numeric strings ("233075")
- [ ] Scores are string format ("2", "0")
- [ ] No integer overflow risk

#### Numeric Fields
- [ ] Clock values are float64 (513.0)
- [ ] Period values are integers (1, 2, 3, 4)
- [ ] Attendance is integer (80824)
- [ ] Jersey numbers are strings ("16")

#### Date/Time Fields
- [ ] All dates are ISO 8601 format
- [ ] Timestamps include Z (UTC indicator)
- [ ] Dates parse correctly
- [ ] Past dates don't cause issues

#### Null/Optional Fields
- [ ] Clock can be null for scheduled matches
- [ ] Venue can be null
- [ ] Attendance can be null
- [ ] Details array can be empty
- [ ] Headlines can be empty

#### Boolean Fields
- [ ] winner field: true/false
- [ ] advance field: true/false
- [ ] scoringPlay field: true/false
- [ ] redCard field: true/false
- [ ] yellowCard field: true/false

### 6. Data Consistency Tests

#### Competitor Order
- [ ] Home team always listed first in competitors array
- [ ] Away team always listed second
- [ ] homeAway field matches position

#### Score Format
- [ ] Score is string, not integer
- [ ] Score matches final game outcome
- [ ] Score consistent across response (competitors vs summary)

#### Team Information
- [ ] Team abbreviation consistent across response
- [ ] Team displayName consistent across response
- [ ] Team logo URL consistent

#### Status Mapping
- [ ] state="pre" maps to SCHEDULED
- [ ] state="in" maps to LIVE
- [ ] state="post" maps to FINISHED
- [ ] detail field aligns with state

### 7. Sport-Specific Tests

#### Soccer (World Cup, Leagues)
- [ ] Period = 1 or 2 (for regulation)
- [ ] displayClock format: "45'+2'" or "90'+8'"
- [ ] Status includes halftime
- [ ] Extra time shows period > 2

#### Basketball (NBA)
- [ ] Period = 1, 2, 3, 4 (quarters)
- [ ] displayClock format: "2:45 2nd" (min:sec quarter)
- [ ] OT shown in displayClock
- [ ] Statistics include field goals, 3-pointers

#### Football (NFL)
- [ ] Period = 1, 2, 3, 4 (quarters)
- [ ] displayClock format: "2:45 2nd" (min:sec quarter)
- [ ] Preseason/Regular/Playoffs shown in season
- [ ] Week information available

### 8. Performance Tests

#### Response Time
- [ ] Scoreboard response < 500ms
- [ ] Summary response < 1000ms
- [ ] Concurrent requests don't degrade performance

#### Response Size
- [ ] Scoreboard < 200KB (uncompressed)
- [ ] Summary < 300KB (uncompressed)
- [ ] Gzip compression working (response < 50KB)

#### Cache Behavior
- [ ] Cache-Control header present
- [ ] max-age=4 observed
- [ ] Rapid successive requests hit cache

#### Rate Limiting
- [ ] 100 requests in 1 minute succeeds
- [ ] No rate limit errors observed
- [ ] Polite backoff (5+ sec intervals) recommended

### 9. Coverage Tests

#### World Cup Completeness
- [ ] All tournament phases in calendar
- [ ] Group stage matches appear
- [ ] Round of 32 matches appear
- [ ] Later round matches appear
- [ ] At least 2 matches visible on Jun 11, 2026

#### League Coverage
- [ ] All top-tier leagues available
- [ ] Current season data available
- [ ] Historical data queryable by date

### 10. Integration Tests

#### Cross-Sport Compatibility
- [ ] Same client can query soccer, basketball, football
- [ ] Response structure consistent across sports
- [ ] Status mapping works for all sports
- [ ] Error handling consistent

#### Multi-League Support
- [ ] FIFA World Cup queries
- [ ] Premier League queries
- [ ] NBA queries
- [ ] NFL queries
- [ ] All succeed with same client

---

## Test Execution Plan

### Phase 1: Manual Testing (Smoke Tests)
Run basic curl commands to verify endpoints respond.

**Tools:** curl, jq  
**Time:** ~30 minutes  
**Coverage:** ~20% (basic endpoint health)

### Phase 2: Automated Validation (Script-based)
Run comprehensive validation script against all endpoints.

**Tools:** PowerShell/Bash script  
**Time:** ~1-2 hours  
**Coverage:** ~60% (structure, data types, basic logic)

### Phase 3: Detailed Testing (Test Suite)
Run detailed test suite covering edge cases and variations.

**Tools:** Go test suite (with table-driven tests)  
**Time:** ~3-4 hours  
**Coverage:** ~95% (comprehensive)

### Phase 4: Integration Testing
Test real-world scenarios and edge cases.

**Tools:** Go integration tests  
**Time:** Ongoing during development

---

## Test Data

### Known Good Responses

| Endpoint | Sport/League | Date | Event ID | Status |
|---|---|---|---|---|
| `/scoreboard` | soccer/fifa.world | 2026-06-11 | 760415 | Finished (FT) |
| `/scoreboard` | soccer/fifa.world | 2026-06-12 | ? | ? |
| `/summary` | soccer/fifa.world | - | 760415 | ✅ Works |
| `/scoreboard` | soccer/eng.1 | 2026-06-11 | - | ✅ Returns data |
| `/scoreboard` | basketball/nba | 2026-06-11 | - | ✅ Returns data |
| `/scoreboard` | football/nfl | 2026-06-11 | - | ✅ Returns data |

### Known Bad Responses

| Endpoint | Input | Expected Response |
|---|---|---|
| `/scoreboard` | cricket/ipl | 404 |
| `/summary` | soccer/fifa.world?event=invalid | 200 (empty) |
| `/scoreboard` | soccer/invalid-league | 404 |

---

## Acceptance Criteria

### All Tests Must Pass
- ✅ 100% of endpoint availability tests
- ✅ 95%+ of scoreboard structure tests
- ✅ 95%+ of summary structure tests
- ✅ 100% of error handling tests
- ✅ 100% of data type tests
- ✅ 90%+ of consistency tests
- ✅ 100% of sport-specific tests (covered sports)
- ✅ 90%+ of performance tests
- ✅ 100% of integration tests

### Documentation Requirements
- ✅ All test cases documented
- ✅ Test failures documented
- ✅ Workarounds noted for issues
- ✅ Edge cases identified

### Implementation Ready When
- ✅ All tests pass
- ✅ Response structures documented
- ✅ Error scenarios understood
- ✅ Edge cases identified
- ✅ Data type mappings confirmed
- ✅ No blocking issues discovered

