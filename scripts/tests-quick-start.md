# Modular Test Suite - Quick Start

## What Changed

**Before:** Single monolithic `test-api.ps1` script (400+ lines)

**After:** Modular structure with:
- ✅ Reusable helper functions (`test-helpers.ps1`)
- ✅ Separate test modules (6 files)
- ✅ Central configuration (`config.ps1`)
- ✅ Main orchestrator (`run-tests.ps1`)

**Benefits:**
- 🎯 Run specific test categories
- 🔧 Easy to add new tests
- 📦 Clean code organization
- 🚀 Fast execution (only run what you need)

---

## Directory Structure

```
scripts/
├── run-tests.ps1                    ← Run this to execute all tests
└── tests/
    ├── README.md                    ← Full documentation
    ├── config.ps1                   ← Test data & global config
    ├── test-helpers.ps1             ← Reusable functions
    ├── 01-endpoints.ps1             ← Endpoint availability tests
    ├── 02-scoreboard-structure.ps1  ← Response structure tests
    ├── 03-query-parameters.ps1      ← Query parameter tests
    ├── 04-data-types.ps1            ← Data type validation tests
    ├── 05-error-handling.ps1        ← Error handling tests
    └── 06-performance.ps1           ← Performance benchmark tests
```

---

## Quick Commands

### Run All Tests (5-10 minutes)
```powershell
cd D:\Dev\active\libraries\go-espn
.\scripts\run-tests.ps1
```

### Run Single Test Category
```powershell
# Just endpoint availability
.\scripts\run-tests.ps1 -Tests "01-endpoints"

# Just structure validation
.\scripts\run-tests.ps1 -Tests "02-scoreboard-structure"

# Just performance tests
.\scripts\run-tests.ps1 -Tests "06-performance"
```

### Run Multiple Specific Tests
```powershell
.\scripts\run-tests.ps1 -Tests "01-endpoints", "02-scoreboard-structure", "04-data-types"
```

### Verbose Output (see all details)
```powershell
.\scripts\run-tests.ps1 -Verbose
```

### Custom Timeout (for slow networks)
```powershell
.\scripts\run-tests.ps1 -TimeoutSeconds 30
```

### Run Test Directly (skip orchestrator)
```powershell
# Load dependencies first
& ".\scripts\tests\config.ps1"
& ".\scripts\tests\test-helpers.ps1"

# Run specific test module
& ".\scripts\tests\02-scoreboard-structure.ps1"
```

---

## Test Categories

| # | File | Purpose | Tests |
|---|------|---------|-------|
| 1 | `01-endpoints.ps1` | Basic connectivity | 8 |
| 2 | `02-scoreboard-structure.ps1` | Response structure | 25+ |
| 3 | `03-query-parameters.ps1` | Query parameters | 4 |
| 4 | `04-data-types.ps1` | Type validation | 8 |
| 5 | `05-error-handling.ps1` | Error scenarios | 6 |
| 6 | `06-performance.ps1` | Performance metrics | 5 |
| **Total** | **6 modules** | **All aspects** | **~60 tests** |

---

## Output

### Console
```
✅ PASS : World Cup Scoreboard
  └─ Status 200
❌ FAIL : Invalid field
  └─ Expected value, got different value
```

### Reports (in `.\test-results\`)
- `test-report-YYYYMMDD-HHmmss.txt` — Full results table
- `test-summary-YYYYMMDD-HHmmss.json` — Statistics in JSON

---

## Common Use Cases

### "I just want to verify the API is up"
```powershell
.\scripts\run-tests.ps1 -Tests "01-endpoints"
# Takes ~30 seconds
```

### "I want to check response structure"
```powershell
.\scripts\run-tests.ps1 -Tests "02-scoreboard-structure"
# Takes ~2 minutes
```

### "I want to validate data types before implementing Go code"
```powershell
.\scripts\run-tests.ps1 -Tests "04-data-types"
# Takes ~1 minute
```

### "I need a full validation before committing"
```powershell
.\scripts\run-tests.ps1
# Takes ~5-10 minutes
```

### "I'm debugging a specific issue"
```powershell
.\scripts\run-tests.ps1 -Verbose -Tests "02-scoreboard-structure"
# Shows detailed output for each step
```

---

## Adding Your Own Tests

1. **Create new file** (e.g., `07-my-tests.ps1`)
2. **Use template:**
   ```powershell
   param([switch]$Verbose = $false)
   
   $TestCategory = "My Tests"
   
   function Test-MyFeature {
       Start-TestCategory -CategoryName $TestCategory
       
       Write-Log "Testing..." -Level "INFO"
       Write-TestResult -TestName "Test 1" -Passed $true
       
       End-TestCategory -CategoryName $TestCategory
   }
   
   function Run-MyTests {
       Test-MyFeature
   }
   
   if ($MyInvocation.InvocationName -ne ".") {
       Run-MyTests
   }
   ```

3. **Orchestrator auto-discovers it** (naming: `[0-9][0-9]-*.ps1`)

4. **Run:** `.\scripts\run-tests.ps1`

---

## Helper Functions Available

**HTTP/API:**
- `Test-Endpoint()` — Validate status code
- `Get-JsonResponse()` — Fetch and parse JSON
- `Build-ScoreboardUrl()` / `Build-SummaryUrl()` — URL builders

**Validation:**
- `Test-JsonField()` — Check field exists
- `Test-ArrayNotEmpty()` — Verify array has items
- `Test-EnumValue()` — Validate enum
- `Test-IsString()` / `Test-IsNumeric()` — Type checks
- `Test-ResponseHeader()` — Check headers

**Tracking:**
- `Start-TestCategory()` / `End-TestCategory()` — Category management
- `Write-TestResult()` — Record result

**Reporting:**
- `Write-Log()` — Logging
- `Write-TestSummary()` — Final report
- `Save-TestReport()` — Export results

See `scripts/tests/test-helpers.ps1` for full API.

---

## Expected Output

```
╔════════════════════════════════════════════════════════════════╗
║           ESPN API Test Suite - Starting                       ║
║  Test Directory: D:\Dev\active\libraries\go-espn\scripts\tests
║  Output Directory: .\test-results
║  Timeout: 10s                                           ║
╚════════════════════════════════════════════════════════════════╝

Loading configuration...
✅ Configuration and helpers loaded

Discovering test modules...
Found 6 test module(s):
  - 01-endpoints.ps1
  - 02-scoreboard-structure.ps1
  - 03-query-parameters.ps1
  - 04-data-types.ps1
  - 05-error-handling.ps1
  - 06-performance.ps1

Executing tests...

[14:30:45] Endpoint Availability
────────────────────────────────────────────────────────
✅ PASS : World Cup Scoreboard
  └─ Status 200
✅ PASS : Premier League Scoreboard
  └─ Status 200
...

╔════════════════════════════════════════════════════════════════╗
║                     TEST SUMMARY                               ║
╚════════════════════════════════════════════════════════════════╝

Total Tests:     60
Passed:          58 ✅
Failed:          2 ❌
Success Rate:    96.7%

🎉 ALL TESTS PASSED! API is ready for implementation.

Report saved to: .\test-results\test-report-20260611-143045.txt
JSON summary saved to: .\test-results\test-summary-20260611-143045.json
```

---

## Key Differences from Monolithic Script

| Aspect | Before | After |
|--------|--------|-------|
| File size | 400+ lines | 6 files × 50-150 lines each |
| Running specific tests | Not possible | `run-tests.ps1 -Tests "01-endpoints"` |
| Adding new tests | Edit monolithic file | Create new `07-*.ps1` file |
| Code reuse | Duplicated in main script | Shared helpers |
| Readability | Hard to follow | Clear by category |
| Testing during dev | Run everything (5-10 min) | Run just what you need (30 sec) |

---

## Next Steps

1. ✅ Run full test suite: `.\scripts\run-tests.ps1`
2. ✅ Verify all tests pass
3. ✅ Check output reports in `.\test-results\`
4. ✅ Read `scripts/tests/README.md` for detailed documentation
5. ✅ Start implementing Go client with confidence

---

## Troubleshooting

### "Test file not found"
```powershell
# Verify path
Test-Path ".\scripts\tests\02-scoreboard-structure.ps1"

# Should be in scripts/tests directory (note: not tests/scripts)
```

### "Helpers not loaded"
```powershell
# The orchestrator loads them automatically
# If running module directly, load manually:
& ".\scripts\tests\config.ps1"
& ".\scripts\tests\test-helpers.ps1"
```

### "Need more details about a failure"
```powershell
# Use verbose mode
.\scripts\run-tests.ps1 -Verbose
```

### "Want to see code for a test"
```powershell
# Open the test file
code .\scripts\tests\02-scoreboard-structure.ps1

# Or view in any editor
notepad .\scripts\tests\02-scoreboard-structure.ps1
```

---

## Performance Tips

**Full suite:** ~10 minutes
- Endpoint checks: 30 sec
- Structure validation: 2 min
- Query parameters: 1 min
- Data types: 1 min
- Error handling: 1 min
- Performance tests: 4 min

**To speed up:** Run only needed categories
```powershell
# 30 seconds - just check if API is up
.\scripts\run-tests.ps1 -Tests "01-endpoints"

# 3 minutes - verify structure before coding
.\scripts\run-tests.ps1 -Tests "02-scoreboard-structure", "04-data-types"
```

---

**Everything is ready. Run:** 
```powershell
.\scripts\run-tests.ps1
```

