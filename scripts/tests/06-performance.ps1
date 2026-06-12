# ESPN API Test Suite - Phase 6: Performance
# Tests response times and performance characteristics

param(
    [switch]$Verbose = $false
)

$TestCategory = "Performance"

function Test-ScoreboardResponseTime {
    Start-TestCategory -CategoryName "$TestCategory - Scoreboard"

    Write-Log "Testing scoreboard response time" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-WebRequest -Uri $url -UserAgent $Global:UserAgent `
        -TimeoutSec $Global:TimeoutSeconds -ErrorAction Stop
    $stopwatch.Stop()

    $duration = $stopwatch.ElapsedMilliseconds

    if ($duration -lt 1000) {
        Write-TestResult -TestName "Scoreboard response time < 1s" -Passed $true `
            -Message "Duration: ${duration}ms"
    } else {
        Write-TestResult -TestName "Scoreboard response time < 1s" -Passed $false `
            -Message "Duration: ${duration}ms (warning: slow)"
    }

    End-TestCategory -CategoryName "$TestCategory - Scoreboard"
}

function Test-SummaryResponseTime {
    Start-TestCategory -CategoryName "$TestCategory - Summary"

    Write-Log "Testing summary response time" -Level "INFO"

    $url = Build-SummaryUrl -Sport "soccer" -League "fifa.world" `
        -EventID $Global:TestData.KnownEvents["fifa.world"].EventID

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-WebRequest -Uri $url -UserAgent $Global:UserAgent `
        -TimeoutSec $Global:TimeoutSeconds -ErrorAction Stop
    $stopwatch.Stop()

    $duration = $stopwatch.ElapsedMilliseconds

    if ($duration -lt 2000) {
        Write-TestResult -TestName "Summary response time < 2s" -Passed $true `
            -Message "Duration: ${duration}ms"
    } else {
        Write-TestResult -TestName "Summary response time < 2s" -Passed $false `
            -Message "Duration: ${duration}ms (warning: slow)"
    }

    End-TestCategory -CategoryName "$TestCategory - Summary"
}

function Test-ResponseSize {
    Start-TestCategory -CategoryName "$TestCategory - Size"

    Write-Log "Testing response sizes" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"

    try {
        $response = Invoke-WebRequest -Uri $url -UserAgent $Global:UserAgent `
            -TimeoutSec $Global:TimeoutSeconds -ErrorAction Stop

        $contentLength = $response.Content.Length
        $contentLengthKB = [math]::Round($contentLength / 1024, 2)

        if ($contentLength -lt 250000) {  # 250 KB
            Write-TestResult -TestName "Scoreboard response size < 250KB" -Passed $true `
                -Message "Size: ${contentLengthKB}KB"
        } else {
            Write-TestResult -TestName "Scoreboard response size < 250KB" -Passed $false `
                -Message "Size: ${contentLengthKB}KB"
        }
    } catch {
        Write-TestResult -TestName "Response size test" -Passed $false `
            -Message $_.Exception.Message
    }

    End-TestCategory -CategoryName "$TestCategory - Size"
}

function Test-CacheControl {
    Start-TestCategory -CategoryName "$TestCategory - Caching"

    Write-Log "Testing cache control headers" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"

    try {
        $response = Invoke-WebRequest -Uri $url -UserAgent $Global:UserAgent `
            -TimeoutSec $Global:TimeoutSeconds -ErrorAction Stop

        $headers = $response.Headers

        if ($headers.ContainsKey("Cache-Control")) {
            $cacheControl = $headers["Cache-Control"]

            if ($cacheControl -like "*max-age=4*") {
                Write-TestResult -TestName "Cache-Control max-age=4" -Passed $true `
                    -Message "Header: $cacheControl"
            } else {
                Write-TestResult -TestName "Cache-Control max-age=4" -Passed $false `
                    -Message "Header: $cacheControl"
            }
        } else {
            Write-TestResult -TestName "Cache-Control header present" -Passed $false
        }
    } catch {
        Write-TestResult -TestName "Cache control test" -Passed $false `
            -Message $_.Exception.Message
    }

    End-TestCategory -CategoryName "$TestCategory - Caching"
}

function Test-ConcurrentRequests {
    Start-TestCategory -CategoryName "$TestCategory - Concurrency"

    Write-Log "Testing concurrent requests" -Level "INFO"

    $url = Build-ScoreboardUrl -Sport "soccer" -League "fifa.world"
    $successCount = 0
    $failureCount = 0

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Make 5 concurrent requests
    1..5 | ForEach-Object -Parallel {
        try {
            $response = Invoke-WebRequest -Uri $using:url -UserAgent $using:Global:UserAgent `
                -TimeoutSec $using:Global:TimeoutSeconds -ErrorAction Stop

            if ($response.StatusCode -eq 200) {
                $script:successCount++
            }
        } catch {
            $script:failureCount++
        }
    } -ThrottleLimit 5

    $stopwatch.Stop()
    $duration = $stopwatch.ElapsedMilliseconds

    Write-TestResult -TestName "5 concurrent requests" -Passed ($failureCount -eq 0) `
        -Message "Success: $successCount, Failed: $failureCount, Duration: ${duration}ms"

    End-TestCategory -CategoryName "$TestCategory - Concurrency"
}

# Run all tests
function Run-PerformanceTests {
    Test-ScoreboardResponseTime
    Test-SummaryResponseTime
    Test-ResponseSize
    Test-CacheControl
    Test-ConcurrentRequests
}

# Execute if run directly
if ($MyInvocation.InvocationName -ne ".") {
    Run-PerformanceTests
}
