# ESPN API Testing Guide

Complete testing strategy and execution instructions for validating the ESPN API before and during Go client implementation.

---

## Overview

The test suite is divided into **3 phases**:

1. **Phase 1: Manual Validation** (30 min)  
   Quick smoke tests using curl to verify basic endpoint health.

2. **Phase 2: Automated API Testing** (1-2 hours)  
   PowerShell script validates all endpoints, structures, and data types comprehensively.

3. **Phase 3: Go Integration Testing** (Ongoing)  
   Go test suite validates the client library implementation.

---

## Phase 1: Manual Validation (Smoke Tests)

### Quick Endpoint Health Check

```powershell
# Test if APIs are responding
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' | jq '.leagues[0].name'
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/summary?event=760415' | jq '.boxscore'
```

**Expected Output:**
```
"FIFA World Cup"
{"form": [...], "statistics": [...]}
```

### Verify Basic Structure

```powershell
# Check event count
curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' | jq '.events | length'

# Check response headers (Cache-Control, CORS)
curl -i 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' | head -20
```

**Expected Output:**
```
2
HTTP/2 200
cache-control: max-age=4
access-control-allow-origin: *
```

---

## Phase 2: Automated API Testing

### Prerequisites

- Windows 10+ (for PowerShell 7)
- `curl` command available
- `jq` (optional, for JSON parsing)

### Run Full Test Suite

```powershell
# Navigate to project root
cd D:\Dev\active\libraries\go-espn

# Run test script
.\scripts\test-api.ps1

# Run with verbose output
.\scripts\test-api.ps1 -Verbose

# Specify custom output directory
.\scripts\test-api.ps1 -OutputDir ".\my-test-results"
```

### Test Output

The script produces:
1. **Console output** — Real-time test results with status (✅/❌)
2. **Report file** — `.\test-results\test-report-YYYYMMDD-HHmmss.txt`

### Sample Output

```
╔════════════════════════════════════════════════════════════════╗
║           ESPN API Test Suite - Starting                       ║
║  Base URL: https://site.api.espn.com/apis/site/v2/sports
║  Timeout:  10s                                           ║
╚════════════════════════════════════════════════════════════════╝

[PHASE 1] Endpoint Availability Tests
✅ PASS : World Cup Scoreboard
  └─ Status 200
✅ PASS : Premier League Scoreboard
  └─ Status 200
...

[PHASE 2] World Cup Scoreboard Structure Tests
✅ PASS : WC Root
  └─ Field present
✅ PASS : Event - id
  └─ Field present
...

╔════════════════════════════════════════════════════════════════╗
║                     TEST SUMMARY                               ║
╚════════════════════════════════════════════════════════════════╝

Total Tests:     47
Passed:          45 ✅
Failed:          2 ❌
Success Rate:    95.7%

🎉 ALL TESTS PASSED! API is ready for implementation.
```

### Understanding Test Results

#### ✅ PASS Results
All assertions verified, no action needed.

#### ❌ FAIL Results
Check the message for details:

```
❌ FAIL : Invalid sport (cricket/ipl)
  └─ Expected 404, got 200
```

**What to do:**
1. Read the message
2. Check if it's expected (e.g., API returned different code)
3. Update docs or skip test if known issue

### Common Issues During Testing

| Issue | Cause | Solution |
|---|---|---|
| `ConnectTimeout` | Network blocked or DNS issue | Check internet connection, verify URL |
| `Invalid JSON` | API maintenance or endpoint changed | Wait or verify endpoint still exists |
| `Empty events[]` | No matches scheduled on that date | Try different date or league |
| `Rate limit reached` | Too many requests | Wait 1+ minute, retry |

---

## Phase 3: Go Integration Testing

### Test Structure

Tests are organized in `internal/tests/api_test_skeleton.go` with these categories:

```
├── Endpoint Tests
│   ├── All sports/leagues available
│   ├── Invalid sports return errors
│   └── Query parameters work
│
├── Structure Tests
│   ├── Root fields present
│   ├── Event fields present
│   ├── Competitor fields present
│   └── Status fields present
│
├── Data Tests
│   ├── Clock/minute data
│   ├── Play-by-play details
│   ├── Data type validation
│   └── Consistency checks
│
├── Functional Tests
│   ├── Summary endpoint
│   ├── Error handling
│   ├── Multi-sport consistency
│   └── Coverage checks
│
├── Performance Tests
│   ├── Response time
│   ├── Concurrent requests
│   └── Benchmarks
│
└── Integration Tests
    └── Real-world scenarios
```

### Running Go Tests

```bash
# Run all tests
go test ./internal/tests/... -v

# Run with coverage
go test ./internal/tests/... -v -cover

# Run specific test
go test ./internal/tests/... -v -run TestScoreboardResponseStructure

# Run benchmarks
go test ./internal/tests/... -bench=. -benchmem
```

### Implementing Tests

Tests are currently commented out in the skeleton. To implement:

1. **Build the client library first** (espn.New(), Scoreboard(), Summary())
2. **Uncomment test code** in the skeleton file
3. **Run `go test` to validate**

Example implementation:

```go
func TestScoreboardEndpoints(t *testing.T) {
    client := espn.New() // Create client once implemented
    ctx := context.Background()

    // Uncomment test case
    scoreboard, err := client.Scoreboard(ctx, "soccer", "fifa.world")
    if err != nil {
        t.Fatalf("expected success, got error: %v", err)
    }

    if scoreboard == nil || len(scoreboard.Events) == 0 {
        t.Fatal("expected events, got none")
    }
}
```

---

## Test Coverage Matrix

### Endpoint Coverage

| Endpoint | Sport | League | Tested |
|---|---|---|---|
| `/scoreboard` | soccer | fifa.world | ✅ Phase 2 |
| `/scoreboard` | soccer | eng.1 | ✅ Phase 2 |
| `/scoreboard` | soccer | esp.1 | ✅ Phase 2 |
| `/scoreboard` | soccer | ita.1 | ✅ Phase 2 |
| `/scoreboard` | soccer | usa.1 | ✅ Phase 2 |
| `/scoreboard` | basketball | nba | ✅ Phase 2 |
| `/scoreboard` | football | nfl | ✅ Phase 2 |
| `/summary` | soccer | fifa.world | ✅ Phase 2 |

### Feature Coverage

| Feature | Test Type | Phase |
|---|---|---|
| Endpoint availability | Automated | Phase 2 |
| Response structure | Automated | Phase 2 |
| Clock/minute data | Automated + Manual | Phase 2/3 |
| Play-by-play details | Automated | Phase 2/3 |
| Status mapping | Manual | Phase 2 |
| Error handling | Automated + Manual | Phase 2/3 |
| Concurrent requests | Performance | Phase 3 |
| Response time | Performance | Phase 2/3 |

---

## Test Data Reference

### Known Good Test Cases

These endpoints/events always return valid data:

```
Endpoint: /soccer/fifa.world/scoreboard
Date:     2026-06-11
Status:   ✅ Returns 2+ events
Event:    760415 (South Africa vs Mexico)

Endpoint: /soccer/fifa.world/summary?event=760415
Status:   ✅ Returns valid boxscore
Data:     Team form, statistics, rosters
```

### Known Edge Cases

Useful for testing error handling:

```
Unsupported Sport: /cricket/ipl/scoreboard
Expected: 404 error

Invalid Event ID: /soccer/fifa.world/summary?event=999999999
Expected: 200 with empty/minimal data

Scheduled Match: (any future match)
Expected: clock=null, status.state="pre"

Live Match: (during actual match time)
Expected: clock=populated, status.state="in"

Finished Match: 760415 (Jun 11 match)
Expected: clock=final_time, status.state="post"
```

---

## Continuous Testing Strategy

### Before Each Commit

```bash
# Run full test suite
.\scripts\test-api.ps1

# Verify no regressions
git diff --stat
```

### Weekly Testing

Run tests against multiple dates/leagues to catch API changes:

```powershell
# Test multiple dates
@("20260611", "20260612", "20260613") | ForEach-Object {
    Write-Host "Testing date: $_"
    curl -s "https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard?dates=$_" | jq '.events | length'
}

# Test all major leagues
@("fifa.world", "eng.1", "esp.1", "ita.1", "usa.1") | ForEach-Object {
    Write-Host "Testing league: $_"
    curl -s "https://site.api.espn.com/apis/site/v2/sports/soccer/$_/scoreboard" | jq '.leagues[0].slug'
}
```

### Monitoring

Set up alerts for:
- ❌ **404 errors** — API endpoint removed or changed
- ❌ **Invalid JSON** — Response format changed
- ⚠️ **Slow responses** (> 1 sec) — Performance degradation
- ⚠️ **Empty results** — Data availability issue

---

## Test Execution Checklist

### Pre-Testing
- [ ] Internet connection verified
- [ ] PowerShell 5.1+ or 7+ available
- [ ] curl command works
- [ ] Test script is readable (`.\scripts\test-api.ps1`)

### Running Tests
- [ ] Navigate to project root
- [ ] Execute: `.\scripts\test-api.ps1`
- [ ] Wait for "TEST SUMMARY" output
- [ ] Check success rate (aim for 100%, 95%+ acceptable)

### Post-Testing
- [ ] Review failed tests (if any)
- [ ] Check test report file in `.\test-results\`
- [ ] Document any failures in test notes
- [ ] If all pass, API is ready for implementation

### Implementation Phase
- [ ] Uncomment relevant tests in skeleton
- [ ] Implement client library methods
- [ ] Run `go test` to validate implementation
- [ ] Ensure 100% of Go tests pass before shipping

---

## Troubleshooting

### Tests Fail with Network Errors

```powershell
# Check connectivity
Test-NetConnection site.api.espn.com -Port 443

# Try direct curl
curl https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard
```

### Tests Timeout

```powershell
# Run with longer timeout
.\scripts\test-api.ps1 -TimeoutSeconds 30
```

### Specific Test Fails

1. Run that single endpoint manually:
   ```powershell
   curl -s 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard' | jq .
   ```

2. Compare response to documented structure in `API-DATA-MODELS.md`

3. Check if it's a known issue:
   - No events scheduled for that date
   - API maintenance in progress
   - Rate limiting triggered

### Tests Pass Inconsistently

This may indicate:
- Date-dependent tests (no events on that date)
- Timing-dependent tests (live matches changing state)
- Network latency issues

**Solution:** Run tests on known-good data (World Cup matches)

---

## Success Criteria

### Phase 1 Smoke Tests
- ✅ All endpoints respond with HTTP 200
- ✅ Responses contain valid JSON

### Phase 2 Automated Tests
- ✅ 95%+ test pass rate
- ✅ All critical endpoints verified
- ✅ Response structures validated
- ✅ Error handling confirmed
- ✅ No blocking issues found

### Phase 3 Go Tests
- ✅ All unit tests pass
- ✅ All integration tests pass
- ✅ Coverage > 80%
- ✅ Performance baseline established

**When all three phases pass:** API is production-ready for implementation.

