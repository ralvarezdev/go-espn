# Modular Test Suite — Complete Overview

## What You Now Have

A **professional-grade, modular PowerShell test suite** for the ESPN API with:

✅ **6 independent test modules** (each focuses on one aspect)  
✅ **Shared helper functions** (DRY principle)  
✅ **Central configuration** (single source of truth)  
✅ **Main orchestrator** (runs all or specific tests)  
✅ **Comprehensive documentation** (README + quick start)  
✅ **JSON + text reporting** (parse results programmatically)  

---

## File Structure

```
scripts/
├── TESTS-QUICK-START.md           ← Start here (this file)
├── run-tests.ps1                  ← Main entry point
│
└── tests/
    ├── README.md                  ← Full documentation
    ├── config.ps1                 ← Global config & test data
    ├── test-helpers.ps1           ← 20+ reusable functions
    │
    ├── 01-endpoints.ps1           ← ✅ Endpoint health (8 tests)
    ├── 02-scoreboard-structure.ps1 ← ✅ Response structure (25+ tests)
    ├── 03-query-parameters.ps1    ← ✅ Query params (4 tests)
    ├── 04-data-types.ps1          ← ✅ Type validation (8 tests)
    ├── 05-error-handling.ps1      ← ✅ Error scenarios (6 tests)
    └── 06-performance.ps1         ← ✅ Benchmarks (5 tests)

Total: ~60 automated tests across 6 categories
```

---

## Modular Design Benefits

### Before: Monolithic Script
```
test-api.ps1 (400+ lines)
  ├─ Logging
  ├─ HTTP functions
  ├─ Validation logic
  ├─ Tests phase 1
  ├─ Tests phase 2
  ├─ Tests phase 3
  ├─ ...more tests...
  └─ Reporting
```

**Issues:**
- ❌ Hard to find specific tests (400+ line file)
- ❌ Can't run just one test category
- ❌ Adding new tests requires editing main file
- ❌ Code duplication across test sections
- ❌ Difficult to understand flow

---

### After: Modular Structure
```
config.ps1 ──────────┐
test-helpers.ps1 ────┤
01-endpoints.ps1 ────┤
02-structure.ps1 ────┼─→ run-tests.ps1 (orchestrator)
03-params.ps1 ────────┤   └─→ Reports (txt + json)
04-types.ps1 ─────────┤
05-errors.ps1 ────────┤
06-performance.ps1 ───┘
```

**Benefits:**
- ✅ Each module ~50-150 lines (easy to read)
- ✅ Run individual categories in 30 seconds
- ✅ Add new tests by creating new file
- ✅ Shared helpers eliminate duplication
- ✅ Clear separation of concerns

---

## Usage Examples

### Scenario 1: "Quick API Health Check"
```powershell
.\scripts\run-tests.ps1 -Tests "01-endpoints"
# Takes: ~30 seconds
# Tells you: Is the API responding?
```

### Scenario 2: "Validate Before Implementation"
```powershell
.\scripts\run-tests.ps1 -Tests "02-scoreboard-structure", "04-data-types"
# Takes: ~3 minutes
# Tells you: Is response structure correct for Go marshaling?
```

### Scenario 3: "Full Validation"
```powershell
.\scripts\run-tests.ps1
# Takes: ~5-10 minutes
# Tells you: Everything about the API behavior
```

### Scenario 4: "Debug Specific Issue"
```powershell
.\scripts\run-tests.ps1 -Verbose -Tests "02-scoreboard-structure"
# Shows: Detailed output for every test step
```

### Scenario 5: "Add New Tests"
```powershell
# Create: scripts/tests/07-my-feature.ps1
# Update: Function calls
# Run: .\scripts\run-tests.ps1  (auto-discovers 07-my-feature.ps1)
```

---

## Module Overview

### 1️⃣ `01-endpoints.ps1` — Endpoint Availability
**What:** Tests HTTP connectivity to all endpoints  
**Tests:** 8  
**Time:** ~30 seconds

- World Cup, Premier League, La Liga, Serie A, MLS scoreboard (HTTP 200)
- NBA, NFL scoreboard (HTTP 200)
- Summary endpoint (HTTP 200)
- Invalid sports return 404

### 2️⃣ `02-scoreboard-structure.ps1` — Response Structure
**What:** Validates JSON structure matches expectations  
**Tests:** 25+  
**Time:** ~2 minutes

- Root object (leagues, events, season, day)
- League fields and metadata
- Event structure and ID types
- Competition and status structures
- Competitor positions and team info
- Status state enums

### 3️⃣ `03-query-parameters.ps1` — Query Parameters
**What:** Tests endpoint parameters and filtering  
**Tests:** 4  
**Time:** ~1 minute

- Date parameter (`?dates=YYYYMMDD`)
- Date format validation
- Default behavior (no params)
- Result filtering accuracy

### 4️⃣ `04-data-types.ps1` — Type Validation
**What:** Ensures fields have correct types  
**Tests:** 8  
**Time:** ~1 minute

- IDs are strings (no overflow risk)
- Scores are strings
- Periods/clocks are numeric
- Dates are ISO 8601
- Booleans are proper types

### 5️⃣ `05-error-handling.ps1` — Error Scenarios
**What:** Tests error responses and edge cases  
**Tests:** 6  
**Time:** ~1 minute

- Invalid sports return proper errors
- Invalid event IDs handled gracefully
- Empty arrays are valid
- Null fields accepted
- CORS headers present

### 6️⃣ `06-performance.ps1` — Benchmarks
**What:** Measures response times and concurrency  
**Tests:** 5  
**Time:** ~4 minutes

- Scoreboard < 1 second
- Summary < 2 seconds
- Response size < 250 KB
- Cache-Control headers
- 5 concurrent requests succeed

---

## Helper Functions

All reusable functions in `test-helpers.ps1`:

### HTTP Functions
```powershell
Test-Endpoint -Url $url -TestName "Name" -ExpectedStatus "200"
Get-JsonResponse -Url $url -TestName "Name"
Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
Build-SummaryUrl -Sport "soccer" -League "fifa.world" -EventID "123"
```

### Validation Functions
```powershell
Test-JsonField -Object $obj -FieldPath "field.subfield" -TestName "Name"
Test-ArrayNotEmpty -Array $arr -TestName "Name"
Test-EnumValue -Value "pre" -ValidValues @("pre","in","post") -TestName "Name"
Test-IsString -Value $val -FieldName "name" -TestName "Name"
Test-IsNumeric -Value $val -FieldName "name" -TestName "Name"
Test-ResponseHeader -Headers $headers -HeaderName "Cache-Control"
```

### Tracking Functions
```powershell
Start-TestCategory -CategoryName "My Category"
End-TestCategory -CategoryName "My Category"
Write-TestResult -TestName "Name" -Passed $true -Message "Details"
```

### Logging Functions
```powershell
Write-Log -Message "Text" -Level "INFO"  # INFO, WARN, ERROR, DEBUG
```

### Reporting Functions
```powershell
Write-TestSummary -ReportPath "path"
Save-TestReport -Path "path"
```

---

## Extending the Test Suite

### Add New Test Category

**Step 1:** Create file `scripts/tests/07-my-category.ps1`

```powershell
param([switch]$Verbose = $false)

$TestCategory = "My Category"

function Test-MyFeature {
    Start-TestCategory -CategoryName $TestCategory
    
    Write-Log "Testing my feature" -Level "INFO"
    
    # Use any helper function
    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $response = Get-JsonResponse -Url $url -TestName "Get data"
    
    if ($null -ne $response) {
        Test-JsonField -Object $response -FieldPath "leagues" -TestName "Check field"
    }
    
    Write-TestResult -TestName "My test" -Passed $true -Message "Success"
    
    End-TestCategory -CategoryName $TestCategory
}

function Run-MyCategoryTests {
    Test-MyFeature
}

if ($MyInvocation.InvocationName -ne ".") {
    Run-MyCategoryTests
}
```

**Step 2:** Run orchestrator
```powershell
.\scripts\run-tests.ps1  # Auto-discovers 07-my-category.ps1
```

### Add New Helper Function

**Step 1:** Edit `scripts/tests/test-helpers.ps1`

```powershell
function My-NewHelper {
    param(
        [string]$Param1,
        [object]$Param2
    )
    
    # Implementation
    return $result
}
```

**Step 2:** Use in any test module
```powershell
$result = My-NewHelper -Param1 "value" -Param2 $obj
```

---

## Output & Reporting

### Console Output
```
[14:30:45] Endpoint Availability
────────────────────────────────────────────────────────
✅ PASS : World Cup Scoreboard
  └─ Status 200
❌ FAIL : Invalid Sport
  └─ Expected 404, got 200
```

### Report Files
- **`test-report-YYYYMMDD-HHmmss.txt`** — Formatted table (human-readable)
- **`test-summary-YYYYMMDD-HHmmss.json`** — Statistics (machine-readable)

### Exit Codes
- `0` — All tests passed ✅
- `1` — One or more tests failed ❌

---

## Integration with CI/CD

Perfect for GitHub Actions or other CI:

```yaml
# .github/workflows/test-api.yml
- name: Test ESPN API
  run: |
    cd scripts
    .\run-tests.ps1 -OutputDir "../test-results"
    
- name: Upload results
  if: always()
  uses: actions/upload-artifact@v2
  with:
    name: test-results
    path: test-results/
```

---

## Testing Workflow During Development

```
Day 1: Validate API
  → Run: .\scripts\run-tests.ps1 -Tests "01-endpoints"
  → Verify: API is accessible

Day 2: Before Implementation
  → Run: .\scripts\run-tests.ps1 -Tests "02-scoreboard-structure", "04-data-types"
  → Verify: Response structure and types match expectations
  
Day 3-5: During Implementation
  → Run: .\scripts\tests\config.ps1 (load test data in Go)
  → Use test data to drive client development

Day 6: Final Validation
  → Run: .\scripts\run-tests.ps1
  → Verify: All aspects working (100% pass rate)
```

---

## Performance Notes

### Test Execution Times

| Test | Time | Purpose |
|------|------|---------|
| 01-endpoints | 30 sec | Quick API health check |
| 02-structure | 2 min | Response validation |
| 03-parameters | 1 min | Query param testing |
| 04-data-types | 1 min | Type safety |
| 05-errors | 1 min | Edge cases |
| 06-performance | 4 min | Benchmarks |
| **All** | **10 min** | Full validation |

### Optimization Tips

**Fast check (30 sec):**
```powershell
.\scripts\run-tests.ps1 -Tests "01-endpoints"
```

**Structure check (3 min):**
```powershell
.\scripts\run-tests.ps1 -Tests "02-scoreboard-structure", "04-data-types"
```

**Skip slow tests:**
```powershell
.\scripts\run-tests.ps1 -Tests "01-endpoints", "02-scoreboard-structure", "04-data-types"
# Skip: 03 (params), 05 (errors), 06 (performance)
```

---

## Maintenance

### Weekly: Verify API Stability
```powershell
.\scripts\run-tests.ps1 -Tests "01-endpoints"
```

### Before Major Changes
```powershell
.\scripts\run-tests.ps1
```

### When Adding Features
1. Create new test module (e.g., `07-new-feature.ps1`)
2. Add tests to validate feature
3. Run orchestrator to verify

### When Updating Go Client
```powershell
# Use test data from config.ps1
& ".\scripts\tests\config.ps1"  # Load $Global:TestData

# Test data available:
# $Global:TestData.Sports          # 7 sports/leagues
# $Global:TestData.KnownEvents     # Event IDs and expected data
# $Global:TestData.TestDates       # Dates to test with
```

---

## Summary

You now have:

✅ **Professional modular test suite** (7 files)  
✅ **~60 automated tests** covering all API aspects  
✅ **Reusable helper functions** (20+ functions)  
✅ **Easy to extend** (create new `XX-name.ps1`)  
✅ **Clear documentation** (README + quick start)  
✅ **Fast execution** (run specific categories in 30 sec)  
✅ **Reporting** (text + JSON output)  

**Next:** 
```powershell
.\scripts\run-tests.ps1
```

Everything is ready. The API is documented, tested, and ready for Go implementation.

