# ESPN API Test Suite - Modular Structure

## Overview

The test suite is organized into **modular, independent test files** that can be run individually or together via a main orchestrator script.

## Directory Structure

```
scripts/
├── run-tests.ps1              # Main orchestrator (runs all tests)
└── tests/
    ├── README.md              # This file
    ├── config.ps1             # Global configuration & test data
    ├── test-helpers.ps1       # Reusable helper functions
    ├── 01-endpoints.ps1       # Endpoint availability tests
    ├── 02-scoreboard-structure.ps1  # Response structure validation
    ├── 03-query-parameters.ps1      # Query parameter tests
    ├── 04-data-types.ps1            # Data type validation
    ├── 05-error-handling.ps1        # Error scenarios
    └── 06-performance.ps1           # Performance benchmarks
```

## Module Descriptions

### `config.ps1`
**Global configuration and test data**

- Base URL, User-Agent, timeout settings
- Test data (sports, leagues, event IDs)
- Test tracking variables

**Usage:** Auto-loaded by orchestrator

---

### `test-helpers.ps1`
**Reusable testing utilities**

**Functions:**
- `Write-Log()` — Logging with levels (DEBUG, INFO, WARN, ERROR)
- `Write-TestResult()` — Record test results
- `Test-Endpoint()` — HTTP request with status validation
- `Get-JsonResponse()` — Fetch and parse JSON
- `Test-JsonField()` — Validate field existence
- `Test-ArrayNotEmpty()` — Check array has items
- `Test-EnumValue()` — Validate enum values
- `Test-IsString()` / `Test-IsNumeric()` — Type validation
- `Test-ResponseHeader()` — Validate response headers
- `Build-ScoreboardUrl()` / `Build-SummaryUrl()` — URL builders
- `Start-TestCategory()` / `End-TestCategory()` — Category tracking
- `Write-TestSummary()` / `Save-TestReport()` — Reporting

**Usage:** Auto-loaded by orchestrator and individual test modules

---

### `01-endpoints.ps1`
**Endpoint Availability Tests**

**What it tests:**
- All 7 valid sports/leagues respond with HTTP 200
- Invalid sports return HTTP 404
- Summary endpoint with valid event ID works
- Basic HTTP connectivity

**Run directly:**
```powershell
& ".\tests\01-endpoints.ps1"
```

**Functions:**
- `Test-EndpointAvailability()` — Tests all endpoints

---

### `02-scoreboard-structure.ps1`
**Scoreboard Response Structure Validation**

**What it tests:**
- Root object structure (leagues, events, season, day)
- League fields and metadata
- Event fields and ID types
- Competition and status structures
- Competitor positions (home/away order)
- Team information consistency
- Status state enums ("pre", "in", "post")

**Run directly:**
```powershell
& ".\tests\02-scoreboard-structure.ps1"
```

**Functions:**
- `Test-ScoreboardRootStructure()`
- `Test-LeagueStructure()`
- `Test-EventStructure()`
- `Test-CompetitionStructure()`
- `Test-StatusStructure()`
- `Test-CompetitorStructure()`
- `Run-ScoreboardStructureTests()` — Runs all above

---

### `03-query-parameters.ps1`
**Query Parameter Tests**

**What it tests:**
- Date query parameter (`?dates=YYYYMMDD`)
- Date format validation
- Default behavior (no parameters)
- Result filtering by date

**Run directly:**
```powershell
& ".\tests\03-query-parameters.ps1"
```

**Functions:**
- `Test-DateParameter()`
- `Test-DateParameterFormat()`
- `Test-DefaultBehavior()`
- `Run-QueryParameterTests()` — Runs all above

---

### `04-data-types.ps1`
**Data Type Validation**

**What it tests:**
- IDs are strings (event, competitor, team)
- Scores are strings
- Periods and clocks are numeric
- Dates are ISO 8601 format
- Booleans are proper boolean type
- No unexpected type conversions

**Run directly:**
```powershell
& ".\tests\04-data-types.ps1"
```

**Functions:**
- `Test-IDFieldTypes()`
- `Test-ScoreFieldTypes()`
- `Test-NumericFieldTypes()`
- `Test-DateFieldTypes()`
- `Test-BooleanFieldTypes()`
- `Run-DataTypeTests()` — Runs all above

---

### `05-error-handling.ps1`
**Error Handling and Edge Cases**

**What it tests:**
- Invalid sport/league combinations return 404
- Invalid event IDs handled gracefully
- Empty arrays are valid
- Null fields handled correctly
- Response headers on errors
- CORS headers present

**Run directly:**
```powershell
& ".\tests\05-error-handling.ps1"
```

**Functions:**
- `Test-InvalidSportErrors()`
- `Test-InvalidEventIDs()`
- `Test-EmptyArrayHandling()`
- `Test-NullFieldHandling()`
- `Test-ResponseHeaderErrors()`
- `Run-ErrorHandlingTests()` — Runs all above

---

### `06-performance.ps1`
**Performance Benchmarks**

**What it tests:**
- Scoreboard response time < 1 second
- Summary response time < 2 seconds
- Response size < 250 KB
- Cache-Control headers present
- 5 concurrent requests succeed

**Run directly:**
```powershell
& ".\tests\06-performance.ps1"
```

**Functions:**
- `Test-ScoreboardResponseTime()`
- `Test-SummaryResponseTime()`
- `Test-ResponseSize()`
- `Test-CacheControl()`
- `Test-ConcurrentRequests()`
- `Run-PerformanceTests()` — Runs all above

---

## Usage

### Run All Tests

```powershell
cd D:\Dev\active\libraries\go-espn
.\scripts\run-tests.ps1
```

### Run Specific Test Module

```powershell
.\scripts\run-tests.ps1 -Tests "01-endpoints"
```

### Run Multiple Specific Tests

```powershell
.\scripts\run-tests.ps1 -Tests "01-endpoints", "02-scoreboard-structure", "04-data-types"
```

### Verbose Output

```powershell
.\scripts\run-tests.ps1 -Verbose
```

### Custom Output Directory

```powershell
.\scripts\run-tests.ps1 -OutputDir "D:\my-test-results"
```

### Run Individual Test File

```powershell
# Must load config and helpers first
& ".\tests\config.ps1"
& ".\tests\test-helpers.ps1"

# Then run test
& ".\tests\02-scoreboard-structure.ps1"
```

### Longer Timeout (for slow networks)

```powershell
.\scripts\run-tests.ps1 -TimeoutSeconds 30
```

## Test Execution Order

The orchestrator runs tests in numeric order:

1. `01-endpoints.ps1` — Basic connectivity
2. `02-scoreboard-structure.ps1` — Response structure
3. `03-query-parameters.ps1` — Parameter handling
4. `04-data-types.ps1` — Type validation
5. `05-error-handling.ps1` — Error scenarios
6. `06-performance.ps1` — Performance metrics

## Output

### Console Output
```
[HH:MM:SS] Test Category Name
────────────────────────────────────────────────────────
✅ PASS : Test name
  └─ Additional message
❌ FAIL : Test name
  └─ Failure reason
```

### Reports Generated

1. **test-report-YYYYMMDD-HHmmss.txt** — Formatted table of all results
2. **test-summary-YYYYMMDD-HHmmss.json** — JSON summary with statistics

### Summary Output

```
╔════════════════════════════════════════════════════════════════╗
║                     TEST SUMMARY                               ║
╚════════════════════════════════════════════════════════════════╝

Total Tests:     60
Passed:          58 ✅
Failed:          2 ❌
Success Rate:    96.7%

🎉 ALL TESTS PASSED! API is ready for implementation.
```

## Adding New Tests

### Create New Test Module

**File:** `scripts/tests/07-new-feature.ps1`

```powershell
# Template
param(
    [switch]$Verbose = $false
)

$TestCategory = "New Feature"

function Test-NewFeature {
    Start-TestCategory -CategoryName $TestCategory

    Write-Log "Testing new feature" -Level "INFO"

    # Your tests here
    Write-TestResult -TestName "Test name" -Passed $true

    End-TestCategory -CategoryName $TestCategory
}

function Run-NewFeatureTests {
    Test-NewFeature
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne ".") {
    Run-NewFeatureTests
}
```

### Update Orchestrator

The orchestrator automatically discovers files matching `[0-9][0-9]-*.ps1` pattern, so just save your new file with proper naming.

## Extending Helpers

Add new helper functions to `test-helpers.ps1`:

```powershell
function My-NewHelper {
    param(
        [parameter]$value
    )

    # Implementation
}
```

Use in any test module:

```powershell
My-NewHelper -value $someValue
```

## Best Practices

### Modular Test Design
- ✅ Each module tests one area
- ✅ Functions can run independently
- ✅ Reusable via orchestrator
- ❌ Don't create dependencies between modules

### Using Helpers
- ✅ Use `Write-TestResult()` for consistency
- ✅ Use `Test-JsonField()` for validation
- ✅ Use `Build-*Url()` for URLs
- ❌ Don't parse URLs manually

### Test Data
- ✅ Store in `config.ps1`
- ✅ Reference via `$Global:TestData`
- ✅ Keep test data separate from code
- ❌ Don't hardcode values in tests

### Error Handling
- ✅ Catch expected errors gracefully
- ✅ Log failures with context
- ✅ Continue to next test on failure
- ❌ Don't exit on first error

## Troubleshooting

### Test Won't Run

```powershell
# Check if file exists
Test-Path ".\tests\02-scoreboard-structure.ps1"

# Check for syntax errors
& ".\tests\02-scoreboard-structure.ps1" -Verbose
```

### Helper Function Not Found

```powershell
# Make sure helpers are loaded
& ".\tests\config.ps1"
& ".\tests\test-helpers.ps1"

# Then run test
& ".\tests\02-scoreboard-structure.ps1"
```

### Tests Fail with Network Error

```powershell
# Check connectivity
Test-NetConnection site.api.espn.com -Port 443

# Try with longer timeout
.\scripts\run-tests.ps1 -TimeoutSeconds 30
```

## Performance Tips

### Run Only Needed Tests
```powershell
# Skip performance tests if just checking structure
.\scripts\run-tests.ps1 -Tests "01-endpoints", "02-scoreboard-structure"
```

### Parallel Execution (Within a Module)
Test modules run sequentially, but long-running operations can use `-Parallel`:

```powershell
1..10 | ForEach-Object -Parallel {
    # Operation
} -ThrottleLimit 5
```

## Summary

**Modular benefits:**
- 🎯 Run specific test categories
- 📦 Easy to add new tests
- 🔧 Shared helper functions
- 📊 Consistent reporting
- 🚀 Faster development

Start with:
```powershell
.\scripts\run-tests.ps1
```

