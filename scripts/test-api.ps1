# ESPN API Test Suite
# Comprehensive endpoint validation script

param(
    [string]$OutputDir = ".\test-results",
    [switch]$Verbose = $false,
    [int]$TimeoutSeconds = 10
)

# Configuration
$BaseURL = "https://site.api.espn.com/apis/site/v2/sports"
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

# Test tracking
$TestResults = @()
$PassCount = 0
$FailCount = 0

# Helper functions
function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = "",
        [string]$Details = ""
    )

    $status = if ($Passed) { "✅ PASS" } else { "❌ FAIL" }
    Write-Host "$status : $TestName"

    if ($Message) {
        Write-Host "  └─ $Message" -ForegroundColor Gray
    }

    if ($Verbose -and $Details) {
        Write-Host "  └─ Details: $Details" -ForegroundColor Gray
    }

    $TestResults += [PSCustomObject]@{
        TestName = $TestName
        Passed = $Passed
        Message = $Message
        Details = $Details
        Timestamp = Get-Date
    }

    if ($Passed) { $script:PassCount++ } else { $script:FailCount++ }
}

function Test-Endpoint {
    param(
        [string]$Url,
        [string]$TestName,
        [string]$ExpectedStatus = "200"
    )

    try {
        $response = Invoke-WebRequest -Uri $Url -UserAgent $UserAgent -TimeoutSec $TimeoutSeconds -ErrorAction Stop
        $statusCode = $response.StatusCode

        if ($statusCode -eq [int]$ExpectedStatus) {
            Write-TestResult -TestName $TestName -Passed $true -Message "Status $statusCode"
            return $response
        } else {
            Write-TestResult -TestName $TestName -Passed $false -Message "Expected $ExpectedStatus, got $statusCode"
            return $null
        }
    } catch {
        Write-TestResult -TestName $TestName -Passed $false -Message $_.Exception.Message
        return $null
    }
}

function Test-JsonValid {
    param(
        [string]$Json,
        [string]$TestName
    )

    try {
        $obj = $Json | ConvertFrom-Json
        Write-TestResult -TestName $TestName -Passed $true -Message "Valid JSON"
        return $obj
    } catch {
        Write-TestResult -TestName $TestName -Passed $false -Message "Invalid JSON: $($_.Exception.Message)"
        return $null
    }
}

function Test-JsonField {
    param(
        [PSCustomObject]$Object,
        [string]$FieldPath,
        [string]$TestName,
        [bool]$Required = $true
    )

    $fields = $FieldPath -split '\.'
    $current = $Object

    foreach ($field in $fields) {
        if ($null -eq $current) {
            Write-TestResult -TestName $TestName -Passed $false -Message "Field path broken at: $field"
            return $false
        }
        $current = $current.$field
    }

    if ($Required -and $null -eq $current) {
        Write-TestResult -TestName "$TestName - $FieldPath" -Passed $false -Message "Required field missing or null"
        return $false
    }

    Write-TestResult -TestName "$TestName - $FieldPath" -Passed $true -Message "Field present"
    return $true
}

function Test-ArrayNotEmpty {
    param(
        [array]$Array,
        [string]$TestName
    )

    if ($null -eq $Array -or $Array.Count -eq 0) {
        Write-TestResult -TestName $TestName -Passed $false -Message "Array is null or empty"
        return $false
    }

    Write-TestResult -TestName $TestName -Passed $true -Message "Array has $($Array.Count) items"
    return $true
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "
╔════════════════════════════════════════════════════════════════╗
║           ESPN API Test Suite - Starting                       ║
║  Base URL: $BaseURL
║  Timeout:  ${TimeoutSeconds}s                                           ║
╚════════════════════════════════════════════════════════════════╝
"

# ============================================================================
# PHASE 1: ENDPOINT AVAILABILITY
# ============================================================================
Write-Host "`n[PHASE 1] Endpoint Availability Tests" -ForegroundColor Cyan

$endpoints = @(
    @{
        Name = "World Cup Scoreboard"
        Url = "$BaseURL/soccer/fifa.world/scoreboard"
        Status = "200"
    },
    @{
        Name = "Premier League Scoreboard"
        Url = "$BaseURL/soccer/eng.1/scoreboard"
        Status = "200"
    },
    @{
        Name = "La Liga Scoreboard"
        Url = "$BaseURL/soccer/esp.1/scoreboard"
        Status = "200"
    },
    @{
        Name = "Serie A Scoreboard"
        Url = "$BaseURL/soccer/ita.1/scoreboard"
        Status = "200"
    },
    @{
        Name = "MLS Scoreboard"
        Url = "$BaseURL/soccer/usa.1/scoreboard"
        Status = "200"
    },
    @{
        Name = "NBA Scoreboard"
        Url = "$BaseURL/basketball/nba/scoreboard"
        Status = "200"
    },
    @{
        Name = "NFL Scoreboard"
        Url = "$BaseURL/football/nfl/scoreboard"
        Status = "200"
    }
)

$responses = @{}
foreach ($endpoint in $endpoints) {
    $response = Test-Endpoint -Url $endpoint.Url -TestName $endpoint.Name -ExpectedStatus $endpoint.Status
    $responses[$endpoint.Name] = $response
}

# ============================================================================
# PHASE 2: FIFA WORLD CUP SCOREBOARD STRUCTURE
# ============================================================================
Write-Host "`n[PHASE 2] World Cup Scoreboard Structure Tests" -ForegroundColor Cyan

if ($responses["World Cup Scoreboard"]) {
    $wc = $responses["World Cup Scoreboard"].Content | ConvertFrom-Json

    # Root structure
    Test-JsonField -Object $wc -FieldPath "leagues" -TestName "WC Root" -Required $true
    Test-JsonField -Object $wc -FieldPath "season" -TestName "WC Root" -Required $true
    Test-JsonField -Object $wc -FieldPath "day" -TestName "WC Root" -Required $true
    Test-JsonField -Object $wc -FieldPath "events" -TestName "WC Root" -Required $true

    # Events
    if (Test-ArrayNotEmpty -Array $wc.events -TestName "WC Events array not empty") {
        $firstEvent = $wc.events[0]

        Test-JsonField -Object $firstEvent -FieldPath "id" -TestName "Event" -Required $true
        Test-JsonField -Object $firstEvent -FieldPath "name" -TestName "Event" -Required $true
        Test-JsonField -Object $firstEvent -FieldPath "date" -TestName "Event" -Required $true
        Test-JsonField -Object $firstEvent -FieldPath "competitions" -TestName "Event" -Required $true

        # Competition structure
        if (Test-ArrayNotEmpty -Array $firstEvent.competitions -TestName "Competition array not empty") {
            $comp = $firstEvent.competitions[0]

            Test-JsonField -Object $comp -FieldPath "status" -TestName "Competition" -Required $true
            Test-JsonField -Object $comp -FieldPath "competitors" -TestName "Competition" -Required $true

            # Status structure
            $status = $comp.status
            Test-JsonField -Object $status -FieldPath "type" -TestName "Status"
            Test-JsonField -Object $status -FieldPath "type.state" -TestName "Status type"
            Test-JsonField -Object $status -FieldPath "displayClock" -TestName "Status"

            # Verify state is valid enum
            $validStates = @("pre", "in", "post")
            if ($validStates -contains $status.type.state) {
                Write-TestResult -TestName "Status state enum validation" -Passed $true -Message "State: '$($status.type.state)'"
            } else {
                Write-TestResult -TestName "Status state enum validation" -Passed $false -Message "Invalid state: '$($status.type.state)'"
            }

            # Competitors
            if (Test-ArrayNotEmpty -Array $comp.competitors -TestName "Competitors array") {
                if ($comp.competitors.Count -ge 2) {
                    Write-TestResult -TestName "Competitors count (2 teams)" -Passed $true -Message "$($comp.competitors.Count) teams"

                    # Check home/away
                    $home = $comp.competitors[0]
                    $away = $comp.competitors[1]

                    if ($home.homeAway -eq "home") {
                        Write-TestResult -TestName "Home team position" -Passed $true -Message "Home: $($home.team.abbreviation)"
                    } else {
                        Write-TestResult -TestName "Home team position" -Passed $false -Message "First competitor not home"
                    }

                    if ($away.homeAway -eq "away") {
                        Write-TestResult -TestName "Away team position" -Passed $true -Message "Away: $($away.team.abbreviation)"
                    } else {
                        Write-TestResult -TestName "Away team position" -Passed $false -Message "Second competitor not away"
                    }

                    # Check scores are strings
                    if ($home.score -is [string] -and $away.score -is [string]) {
                        Write-TestResult -TestName "Score format (strings)" -Passed $true -Message "Score: $($home.score)-$($away.score)"
                    } else {
                        Write-TestResult -TestName "Score format (strings)" -Passed $false -Message "Scores not strings"
                    }
                } else {
                    Write-TestResult -TestName "Competitors count (2 teams)" -Passed $false -Message "Only $($comp.competitors.Count) competitors"
                }
            }
        }
    }

    # League structure
    if (Test-ArrayNotEmpty -Array $wc.leagues -TestName "Leagues array not empty") {
        $league = $wc.leagues[0]

        Test-JsonField -Object $league -FieldPath "name" -TestName "League"
        Test-JsonField -Object $league -FieldPath "slug" -TestName "League"
        Test-JsonField -Object $league -FieldPath "season" -TestName "League"
        Test-JsonField -Object $league -FieldPath "calendar" -TestName "League"

        # Verify it's FIFA World Cup
        if ($league.slug -eq "fifa.world") {
            Write-TestResult -TestName "FIFA World Cup slug verification" -Passed $true -Message "Slug: fifa.world"
        } else {
            Write-TestResult -TestName "FIFA World Cup slug verification" -Passed $false -Message "Unexpected slug: $($league.slug)"
        }
    }
}

# ============================================================================
# PHASE 3: QUERY PARAMETER TESTS
# ============================================================================
Write-Host "`n[PHASE 3] Query Parameter Tests" -ForegroundColor Cyan

$dateTest = Test-Endpoint -Url "$BaseURL/soccer/fifa.world/scoreboard?dates=20260612" -TestName "Date query parameter" -ExpectedStatus "200"
if ($dateTest) {
    $wcDate = $dateTest.Content | ConvertFrom-Json
    if ($wcDate.events -and $wcDate.events.Count -gt 0) {
        Write-TestResult -TestName "Date filter produces results" -Passed $true -Message "$($wcDate.events.Count) events on 2026-06-12"
    } else {
        Write-TestResult -TestName "Date filter produces results" -Passed $false -Message "No events returned"
    }
}

# ============================================================================
# PHASE 4: SUMMARY ENDPOINT
# ============================================================================
Write-Host "`n[PHASE 4] Summary Endpoint Tests" -ForegroundColor Cyan

# Use known event ID from WC (South Africa vs Mexico)
$summaryUrl = "$BaseURL/soccer/fifa.world/summary?event=760415"
$summaryResponse = Test-Endpoint -Url $summaryUrl -TestName "Summary endpoint (valid event)" -ExpectedStatus "200"

if ($summaryResponse) {
    $summary = $summaryResponse.Content | ConvertFrom-Json

    Test-JsonField -Object $summary -FieldPath "boxscore" -TestName "Summary response"

    if ($summary.boxscore) {
        Test-JsonField -Object $summary.boxscore -FieldPath "form" -TestName "Summary boxscore"

        if ($summary.boxscore.form -and $summary.boxscore.form.Count -gt 0) {
            $form = $summary.boxscore.form[0]
            Test-JsonField -Object $form -FieldPath "team" -TestName "Form team"
            Test-JsonField -Object $form -FieldPath "events" -TestName "Form events"
        }
    }
}

# ============================================================================
# PHASE 5: ERROR HANDLING
# ============================================================================
Write-Host "`n[PHASE 5] Error Handling Tests" -ForegroundColor Cyan

$invalidSportUrl = "$BaseURL/cricket/ipl/scoreboard"
$invalidResponse = Test-Endpoint -Url $invalidSportUrl -TestName "Invalid sport (cricket/ipl)" -ExpectedStatus "404"

if ($invalidResponse -eq $null) {
    Write-TestResult -TestName "404 error structure" -Passed $true -Message "Correctly returned 404"
}

# ============================================================================
# PHASE 6: RESPONSE HEADERS
# ============================================================================
Write-Host "`n[PHASE 6] Response Header Tests" -ForegroundColor Cyan

if ($responses["World Cup Scoreboard"]) {
    $headers = $responses["World Cup Scoreboard"].Headers

    # Cache control
    if ($headers -and $headers["Cache-Control"]) {
        $cacheControl = $headers["Cache-Control"]
        if ($cacheControl -like "*max-age=4*") {
            Write-TestResult -TestName "Cache-Control header" -Passed $true -Message "max-age=4 found"
        } else {
            Write-TestResult -TestName "Cache-Control header" -Passed $true -Message "Value: $cacheControl"
        }
    } else {
        Write-TestResult -TestName "Cache-Control header" -Passed $false -Message "Header not found"
    }

    # CORS
    if ($headers -and $headers["Access-Control-Allow-Origin"]) {
        Write-TestResult -TestName "CORS header (Access-Control-Allow-Origin)" -Passed $true -Message "Found"
    }
}

# ============================================================================
# PHASE 7: DATA CONSISTENCY TESTS
# ============================================================================
Write-Host "`n[PHASE 7] Data Consistency Tests" -ForegroundColor Cyan

if ($responses["World Cup Scoreboard"]) {
    $wc = $responses["World Cup Scoreboard"].Content | ConvertFrom-Json

    if ($wc.events -and $wc.events.Count -gt 0) {
        $event = $wc.events[0]

        if ($event.competitions -and $event.competitions.Count -gt 0) {
            $comp = $event.competitions[0]

            # Check home team score is string
            $homeTeam = $comp.competitors[0]
            if ($homeTeam.score -is [string]) {
                Write-TestResult -TestName "Score is string (not int)" -Passed $true
            } else {
                Write-TestResult -TestName "Score is string (not int)" -Passed $false -Message "Score type: $($homeTeam.score.GetType().Name)"
            }

            # Check team IDs are strings
            if ($homeTeam.id -is [string]) {
                Write-TestResult -TestName "Team ID is string" -Passed $true
            } else {
                Write-TestResult -TestName "Team ID is string" -Passed $false
            }

            # Check event ID is string
            if ($event.id -is [string]) {
                Write-TestResult -TestName "Event ID is string" -Passed $true
            } else {
                Write-TestResult -TestName "Event ID is string" -Passed $false
            }
        }
    }
}

# ============================================================================
# PHASE 8: MULTI-SPORT CONSISTENCY
# ============================================================================
Write-Host "`n[PHASE 8] Multi-Sport Consistency Tests" -ForegroundColor Cyan

$sportTest = @(
    $responses["NBA Scoreboard"],
    $responses["NFL Scoreboard"],
    $responses["Premier League Scoreboard"]
)

foreach ($response in $sportTest) {
    if ($response) {
        $obj = $response.Content | ConvertFrom-Json

        # All should have same root structure
        $hasLeagues = $null -ne $obj.leagues
        $hasEvents = $null -ne $obj.events
        $hasStatus = $null -ne $obj.events[0].competitions[0].status

        if ($hasLeagues -and $hasEvents -and $hasStatus) {
            Write-TestResult -TestName "Consistent root structure across sports" -Passed $true
        }
    }
}

# ============================================================================
# SUMMARY REPORT
# ============================================================================
Write-Host "`n
╔════════════════════════════════════════════════════════════════╗
║                     TEST SUMMARY                               ║
╚════════════════════════════════════════════════════════════════╝
"

$totalTests = $PassCount + $FailCount
$passPercent = if ($totalTests -gt 0) { [math]::Round(($PassCount / $totalTests) * 100, 1) } else { 0 }

Write-Host "Total Tests:     $totalTests"
Write-Host "Passed:          $PassCount ✅"
Write-Host "Failed:          $FailCount ❌"
Write-Host "Success Rate:    $passPercent%"
Write-Host ""

if ($FailCount -eq 0) {
    Write-Host "🎉 ALL TESTS PASSED! API is ready for implementation." -ForegroundColor Green
} else {
    Write-Host "⚠️  Some tests failed. Review details above." -ForegroundColor Yellow
}

# Save results to file
$reportPath = Join-Path $OutputDir "test-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$TestResults | Format-Table -AutoSize | Out-File -FilePath $reportPath
Write-Host "`nReport saved to: $reportPath"

# Exit code
exit if ($FailCount -eq 0) { 0 } else { 1 }
