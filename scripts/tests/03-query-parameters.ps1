# ESPN API Test Suite - Phase 3: Query Parameters
# Tests query parameter support and filtering

param(
    [switch]$Verbose = $false
)

$TestCategory = "Query Parameters"

function Test-DateParameter {
    Start-TestCategory -CategoryName $TestCategory

    Write-Log "Testing date query parameter" -Level "INFO"

    foreach ($date in $Global:TestData.TestDates) {
        $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world" -Date $date
        $response = Get-JsonResponse -Url $url -TestName "Date parameter: $date"

        if ($null -ne $response -and $null -ne $response.day) {
            Write-TestResult -TestName "Date filtering produces results" -Passed $true `
                -Message "Date: $date, Events: $($response.events.Count)"
        }
    }

    End-TestCategory -CategoryName $TestCategory
}

function Test-DateParameterFormat {
    Start-TestCategory -CategoryName "$TestCategory - Format"

    Write-Log "Testing date parameter format validation" -Level "INFO"

    # Valid format: YYYYMMDD
    $validDates = @(
        "20260611",
        "20260612",
        "20261231"
    )

    foreach ($date in $validDates) {
        $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world" -Date $date
        $response = Test-Endpoint -Url $url -TestName "Valid date format: $date" -ExpectedStatus "200"
    }

    End-TestCategory -CategoryName "$TestCategory - Format"
}

function Test-DefaultBehavior {
    Start-TestCategory -CategoryName "$TestCategory - Default"

    Write-Log "Testing default behavior without parameters" -Level "INFO"

    # No date parameter should work (default to today)
    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $response = Get-JsonResponse -Url $url -TestName "No date parameter (default)"

    if ($null -ne $response) {
        if ($null -ne $response.day) {
            Write-TestResult -TestName "Default behavior sets day" -Passed $true `
                -Message "Day: $($response.day.date)"
        }
    }

    End-TestCategory -CategoryName "$TestCategory - Default"
}

# Run all tests
function Run-QueryParameterTests {
    Test-DateParameter
    Test-DateParameterFormat
    Test-DefaultBehavior
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne ".") {
    Run-QueryParameterTests
}
