# ESPN API Test Suite - Phase 2: Scoreboard Structure
# Validates response structure and required fields

param(
    [switch]$Verbose = $false
)

$TestCategory = "Scoreboard Structure"

function Test-ScoreboardRootStructure {
    Start-TestCategory -CategoryName $TestCategory

    Write-Log "Testing Scoreboard root structure" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard) {
        Write-Log "Failed to get scoreboard response" -Level "ERROR"
        return
    }

    # Root fields
    Test-JsonField -Object $scoreboard -FieldPath "leagues" -TestName "Root" -Required $true
    Test-JsonField -Object $scoreboard -FieldPath "season" -TestName "Root" -Required $true
    Test-JsonField -Object $scoreboard -FieldPath "day" -TestName "Root" -Required $true
    Test-JsonField -Object $scoreboard -FieldPath "events" -TestName "Root" -Required $true

    End-TestCategory -CategoryName $TestCategory
}

function Test-LeagueStructure {
    Start-TestCategory -CategoryName "$TestCategory - League"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard) {
        Write-Log "Failed to get scoreboard response" -Level "ERROR"
        return
    }

    if (-not (Test-ArrayNotEmpty -Array $scoreboard.leagues -TestName "Leagues array")) {
        return
    }

    $league = $scoreboard.leagues[0]

    # League fields
    Test-JsonField -Object $league -FieldPath "id" -TestName "League"
    Test-JsonField -Object $league -FieldPath "name" -TestName "League"
    Test-JsonField -Object $league -FieldPath "slug" -TestName "League"
    Test-JsonField -Object $league -FieldPath "season" -TestName "League"
    Test-JsonField -Object $league -FieldPath "calendar" -TestName "League"

    # Verify FIFA World Cup
    if ($league.slug -eq "fifa.world") {
        Write-TestResult -TestName "FIFA World Cup slug verification" -Passed $true
    } else {
        Write-TestResult -TestName "FIFA World Cup slug verification" -Passed $false `
            -Message "Expected 'fifa.world', got '$($league.slug)'"
    }

    # Check calendar type
    $validCalendarTypes = @("list", "day")
    Test-EnumValue -Value $league.calendarType -ValidValues $validCalendarTypes `
        -TestName "Calendar type enum"

    End-TestCategory -CategoryName "$TestCategory - League"
}

function Test-EventStructure {
    Start-TestCategory -CategoryName "$TestCategory - Event"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard) {
        return
    }

    if (-not (Test-ArrayNotEmpty -Array $scoreboard.events -TestName "Events array")) {
        return
    }

    $event = $scoreboard.events[0]

    # Event fields
    Test-JsonField -Object $event -FieldPath "id" -TestName "Event"
    Test-JsonField -Object $event -FieldPath "name" -TestName "Event"
    Test-JsonField -Object $event -FieldPath "date" -TestName "Event"
    Test-JsonField -Object $event -FieldPath "competitions" -TestName "Event"

    # Event IDs should be strings
    Test-IsString -Value $event.id -FieldName "id" -TestName "Event ID type"

    End-TestCategory -CategoryName "$TestCategory - Event"
}

function Test-CompetitionStructure {
    Start-TestCategory -CategoryName "$TestCategory - Competition"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard -or $scoreboard.events.Count -eq 0) {
        return
    }

    $event = $scoreboard.events[0]

    if (-not (Test-ArrayNotEmpty -Array $event.competitions -TestName "Competitions array")) {
        return
    }

    $comp = $event.competitions[0]

    # Competition fields
    Test-JsonField -Object $comp -FieldPath "status" -TestName "Competition"
    Test-JsonField -Object $comp -FieldPath "competitors" -TestName "Competition"

    End-TestCategory -CategoryName "$TestCategory - Competition"
}

function Test-StatusStructure {
    Start-TestCategory -CategoryName "$TestCategory - Status"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard -or $scoreboard.events.Count -eq 0) {
        return
    }

    $comp = $scoreboard.events[0].competitions[0]

    if ($null -eq $comp.status) {
        Write-TestResult -TestName "Status object" -Passed $false -Message "Status is null"
        return
    }

    # Status fields
    Test-JsonField -Object $comp.status -FieldPath "type" -TestName "Status"
    Test-JsonField -Object $comp.status -FieldPath "displayClock" -TestName "Status"

    # Status type fields
    if ($null -ne $comp.status.type) {
        Test-JsonField -Object $comp.status.type -FieldPath "state" -TestName "Status type"

        # Validate state enum
        $validStates = @("pre", "in", "post")
        Test-EnumValue -Value $comp.status.type.state -ValidValues $validStates `
            -TestName "Status state enum"
    }

    End-TestCategory -CategoryName "$TestCategory - Status"
}

function Test-CompetitorStructure {
    Start-TestCategory -CategoryName "$TestCategory - Competitor"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $scoreboard = Get-JsonResponse -Url $url -TestName "FIFA WC Scoreboard"

    if ($null -eq $scoreboard -or $scoreboard.events.Count -eq 0) {
        return
    }

    $comp = $scoreboard.events[0].competitions[0]

    if (-not (Test-ArrayNotEmpty -Array $comp.competitors -TestName "Competitors array")) {
        return
    }

    # Should have at least 2 competitors (home and away)
    if ($comp.competitors.Count -lt 2) {
        Write-TestResult -TestName "Competitor count (minimum 2)" -Passed $false `
            -Message "Expected at least 2, got $($comp.competitors.Count)"
    } else {
        Write-TestResult -TestName "Competitor count (minimum 2)" -Passed $true `
            -Message "$($comp.competitors.Count) competitors"
    }

    $home = $comp.competitors[0]
    $away = $comp.competitors[1]

    # Home/away positions
    if ($home.homeAway -eq "home") {
        Write-TestResult -TestName "Home competitor position" -Passed $true
    } else {
        Write-TestResult -TestName "Home competitor position" -Passed $false `
            -Message "First competitor homeAway is '$($home.homeAway)', expected 'home'"
    }

    if ($away.homeAway -eq "away") {
        Write-TestResult -TestName "Away competitor position" -Passed $true
    } else {
        Write-TestResult -TestName "Away competitor position" -Passed $false `
            -Message "Second competitor homeAway is '$($away.homeAway)', expected 'away'"
    }

    # Scores are strings
    Test-IsString -Value $home.score -FieldName "score" -TestName "Home team score type"
    Test-IsString -Value $away.score -FieldName "score" -TestName "Away team score type"

    # Team info
    Test-JsonField -Object $home -FieldPath "team" -TestName "Home competitor team"
    Test-JsonField -Object $away -FieldPath "team" -TestName "Away competitor team"

    if ($null -ne $home.team) {
        Test-JsonField -Object $home.team -FieldPath "abbreviation" -TestName "Home team"
        Test-JsonField -Object $home.team -FieldPath "displayName" -TestName "Home team"
    }

    End-TestCategory -CategoryName "$TestCategory - Competitor"
}

# Run all tests
function Run-ScoreboardStructureTests {
    Test-ScoreboardRootStructure
    Test-LeagueStructure
    Test-EventStructure
    Test-CompetitionStructure
    Test-StatusStructure
    Test-CompetitorStructure
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne ".") {
    Run-ScoreboardStructureTests
}
