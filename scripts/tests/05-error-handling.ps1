# ESPN API Test Suite - Phase 5: Error Handling
# Tests error responses and edge cases

param(
    [switch]$Verbose = $false
)

$TestCategory = "Error Handling"

function Test-InvalidSportErrors {
    Start-TestCategory -CategoryName $TestCategory

    Write-Log "Testing unsupported sport/league combinations" -Level "INFO"

    $invalidCombos = @(
        @{ Sport = "cricket"; League = "ipl"; Name = "Cricket (IPL)" },
        @{ Sport = "cricket"; League = "bbl"; Name = "Cricket (BBL)" },
        @{ Sport = "invalid"; League = "test"; Name = "Invalid sport" }
    )

    foreach ($combo in $invalidCombos) {
        $url = Build-ScoreboardUrl -Sport $combo.Sport -League $combo.League
        $response = Test-Endpoint -Url $url -TestName "$($combo.Name) error response" `
            -ExpectedStatus "404"
    }

    End-TestCategory -CategoryName $TestCategory
}

function Test-InvalidEventIDs {
    Start-TestCategory -CategoryName "$TestCategory - Invalid Event IDs"

    Write-Log "Testing invalid event ID handling" -Level "INFO"

    $invalidIDs = @(
        "invalid-id",
        "999999999",
        ""
    )

    foreach ($id in $invalidIDs) {
        if ($id) {
            $url = Build-SummaryUrl -Sport "soccer" -League "fifa.world" -EventID $id
            # Should return 200 with empty/minimal data rather than error
            $response = Test-Endpoint -Url $url -TestName "Summary with invalid ID: $id" `
                -ExpectedStatus "200"
        }
    }

    End-TestCategory -CategoryName "$TestCategory - Invalid Event IDs"
}

function Test-EmptyArrayHandling {
    Start-TestCategory -CategoryName "$TestCategory - Empty Arrays"

    Write-Log "Testing handling of empty arrays/null values" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard) {
        Write-Log "Failed to get scoreboard" -Level "ERROR"
        return
    }

    # Events array should always exist (may be empty)
    if ($scoreboard.events -is [array]) {
        Write-TestResult -TestName "Events is always an array" -Passed $true `
            -Message "Events count: $($scoreboard.events.Count)"
    } else {
        Write-TestResult -TestName "Events is always an array" -Passed $false
    }

    # Details array should always exist (may be empty)
    if ($scoreboard.events -and $scoreboard.events[0].competitions) {
        $details = $scoreboard.events[0].competitions[0].details

        if ($details -is [array] -or $null -eq $details) {
            Write-TestResult -TestName "Details is array or null" -Passed $true
        } else {
            Write-TestResult -TestName "Details is array or null" -Passed $false
        }
    }

    End-TestCategory -CategoryName "$TestCategory - Empty Arrays"
}

function Test-NullFieldHandling {
    Start-TestCategory -CategoryName "$TestCategory - Null Fields"

    Write-Log "Testing null field handling" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard) {
        return
    }

    # Clock can be null for scheduled matches
    if ($scoreboard.events -and $scoreboard.events[0].competitions) {
        $status = $scoreboard.events[0].competitions[0].status

        if ($status.type.state -eq "pre") {
            Write-TestResult -TestName "Scheduled match clock is null/absent" `
                -Passed ($null -eq $status.clock -or -not $status.PSObject.Properties.Name.Contains("clock")) `
                -Message "Clock present: $($null -ne $status.clock)"
        }
    }

    # Venue can be null
    if ($scoreboard.events -and $scoreboard.events[0].competitions) {
        $comp = $scoreboard.events[0].competitions[0]

        if ($null -eq $comp.venue -or $comp.venue -is [PSCustomObject]) {
            Write-TestResult -TestName "Venue can be null or object" -Passed $true
        }
    }

    End-TestCategory -CategoryName "$TestCategory - Null Fields"
}

function Test-ResponseHeaderErrors {
    Start-TestCategory -CategoryName "$TestCategory - Headers"

    Write-Log "Testing response headers" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"

    try {
        $response = Invoke-WebRequest -Uri $url -UserAgent $Global:UserAgent `
            -TimeoutSec $Global:TimeoutSeconds -ErrorAction Stop

        $headers = $response.Headers

        # Should have CORS headers
        if ($headers.ContainsKey("Access-Control-Allow-Origin")) {
            Write-TestResult -TestName "CORS header present" -Passed $true
        } else {
            Write-TestResult -TestName "CORS header present" -Passed $false
        }

        # Should have cache control
        if ($headers.ContainsKey("Cache-Control")) {
            Write-TestResult -TestName "Cache-Control header present" -Passed $true `
                -Message $headers["Cache-Control"]
        }
    } catch {
        Write-TestResult -TestName "Response headers test" -Passed $false `
            -Message $_.Exception.Message
    }

    End-TestCategory -CategoryName "$TestCategory - Headers"
}

# Run all tests
function Run-ErrorHandlingTests {
    Test-InvalidSportErrors
    Test-InvalidEventIDs
    Test-EmptyArrayHandling
    Test-NullFieldHandling
    Test-ResponseHeaderErrors
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne ".") {
    Run-ErrorHandlingTests
}
