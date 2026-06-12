# ESPN API Test Suite - Phase 1: Endpoint Availability
# Tests basic connectivity and HTTP status codes

param(
    [switch]$Verbose = $false
)

$TestCategory = "Endpoint Availability"

function Test-EndpointAvailability {
    Start-TestCategory -CategoryName $TestCategory

    # Test all valid sports/leagues
    foreach ($sport in $Global:TestData.Sports) {
        $url = Build-ScoreboardUrl -Sport $sport.Sport -League $sport.League
        Test-Endpoint -Url $url -TestName "$($sport.Name) Scoreboard" -ExpectedStatus "200"
    }

    # Test invalid sports return 404
    foreach ($invalid in $Global:TestData.InvalidSports) {
        $url = Build-ScoreboardUrl -Sport $invalid.Sport -League $invalid.League
        Test-Endpoint -Url $url -TestName "$($invalid.Name) - Error Handling" -ExpectedStatus "404"
    }

    # Test Summary endpoint with known event
    $summaryUrl = Build-SummaryUrl -Sport "soccer" -League "fifa.world" `
        -EventID $Global:TestData.KnownEvents["fifa.world"].EventID
    Test-Endpoint -Url $summaryUrl -TestName "World Cup Summary Endpoint" -ExpectedStatus "200"

    End-TestCategory -CategoryName $TestCategory
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne ".") {
    Test-EndpointAvailability
}
