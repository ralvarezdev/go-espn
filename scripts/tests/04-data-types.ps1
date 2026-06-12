# ESPN API Test Suite - Phase 4: Data Types
# Validates field types and no unexpected conversions

param(
    [switch]$Verbose = $false
)

$TestCategory = "Data Types"

function Test-IDFieldTypes {
    Start-TestCategory -CategoryName "$TestCategory - IDs"

    Write-Log "Testing ID field types (should be strings)" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard -or $scoreboard.events.Count -eq 0) {
        return
    }

    # Event ID
    $event = $scoreboard.events[0]
    Test-IsString -Value $event.id -FieldName "Event.id" -TestName "Event ID type"

    # Competitor ID (Team ID)
    if ($event.competitions -and $event.competitions[0].competitors) {
        $competitor = $event.competitions[0].competitors[0]
        Test-IsString -Value $competitor.id -FieldName "Competitor.id" -TestName "Competitor ID type"

        # Team ID
        if ($competitor.team) {
            Test-IsString -Value $competitor.team.id -FieldName "Team.id" -TestName "Team ID type"
        }
    }

    End-TestCategory -CategoryName "$TestCategory - IDs"
}

function Test-ScoreFieldTypes {
    Start-TestCategory -CategoryName "$TestCategory - Scores"

    Write-Log "Testing score field types (should be strings)" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard -or $scoreboard.events.Count -eq 0) {
        return
    }

    $event = $scoreboard.events[0]

    if ($event.competitions -and $event.competitions[0].competitors) {
        foreach ($competitor in $event.competitions[0].competitors) {
            Test-IsString -Value $competitor.score -FieldName "Competitor.score" `
                -TestName "Score field type for $($competitor.team.abbreviation)"
        }
    }

    End-TestCategory -CategoryName "$TestCategory - Scores"
}

function Test-NumericFieldTypes {
    Start-TestCategory -CategoryName "$TestCategory - Numeric"

    Write-Log "Testing numeric field types" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard) {
        return
    }

    # Period should be numeric
    if ($scoreboard.events -and $scoreboard.events[0].competitions) {
        $comp = $scoreboard.events[0].competitions[0]

        if ($null -ne $comp.status -and $null -ne $comp.status.period) {
            Test-IsNumeric -Value $comp.status.period -FieldName "status.period" `
                -TestName "Period type"
        }

        # Clock should be numeric (when present)
        if ($null -ne $comp.status.clock) {
            Test-IsNumeric -Value $comp.status.clock -FieldName "status.clock" `
                -TestName "Clock type"
        }
    }

    # Attendance should be numeric (if present)
    if ($scoreboard.events -and $scoreboard.events[0].competitions) {
        $comp = $scoreboard.events[0].competitions[0]

        if ($null -ne $comp.attendance) {
            Test-IsNumeric -Value $comp.attendance -FieldName "Attendance" `
                -TestName "Attendance type"
        }
    }

    End-TestCategory -CategoryName "$TestCategory - Numeric"
}

function Test-DateFieldTypes {
    Start-TestCategory -CategoryName "$TestCategory - Dates"

    Write-Log "Testing date field types" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard) {
        return
    }

    # Event dates should be ISO 8601 strings
    if ($scoreboard.events -and $scoreboard.events.Count -gt 0) {
        $event = $scoreboard.events[0]

        if ($event.date -match '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$') {
            Write-TestResult -TestName "Event date ISO 8601 format" -Passed $true `
                -Message "Format: $($event.date)"
        } else {
            Write-TestResult -TestName "Event date ISO 8601 format" -Passed $false `
                -Message "Unexpected format: $($event.date)"
        }
    }

    End-TestCategory -CategoryName "$TestCategory - Dates"
}

function Test-BooleanFieldTypes {
    Start-TestCategory -CategoryName "$TestCategory - Booleans"

    Write-Log "Testing boolean field types" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard -or $scoreboard.events.Count -eq 0) {
        return
    }

    $comp = $scoreboard.events[0].competitions[0]

    # winner, advance should be booleans
    foreach ($competitor in $comp.competitors) {
        if ($null -ne $competitor.winner -and $competitor.winner -is [bool]) {
            Write-TestResult -TestName "Competitor.winner is boolean" -Passed $true
        }

        if ($null -ne $competitor.advance -and $competitor.advance -is [bool]) {
            Write-TestResult -TestName "Competitor.advance is boolean" -Passed $true
        }
    }

    End-TestCategory -CategoryName "$TestCategory - Booleans"
}

# Run all tests
function Run-DataTypeTests {
    Test-IDFieldTypes
    Test-ScoreFieldTypes
    Test-NumericFieldTypes
    Test-DateFieldTypes
    Test-BooleanFieldTypes
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne ".") {
    Run-DataTypeTests
}
