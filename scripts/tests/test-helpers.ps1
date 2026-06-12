# ESPN API Test Suite - Helper Functions
# Reusable testing utilities

# ============================================================================
# Logging Functions
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = @{
        "DEBUG" = "Gray"
        "INFO"  = "White"
        "WARN"  = "Yellow"
        "ERROR" = "Red"
    }

    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color[$Level]
}

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

    if ($Global:Verbose -and $Details) {
        Write-Host "  └─ Details: $Details" -ForegroundColor Gray
    }

    $Global:TestResults += [PSCustomObject]@{
        TestName = $TestName
        Passed = $Passed
        Message = $Message
        Details = $Details
        Timestamp = Get-Date
        Category = $TestCategory
    }

    if ($Passed) {
        $Global:PassCount++
    } else {
        $Global:FailCount++
    }
}

# ============================================================================
# HTTP Request Functions
# ============================================================================

function Test-Endpoint {
    param(
        [string]$Url,
        [string]$TestName,
        [string]$ExpectedStatus = "200"
    )

    try {
        $response = Invoke-WebRequest -Uri $Url -UserAgent $Global:UserAgent `
            -TimeoutSec $Global:TimeoutSeconds -ErrorAction Stop

        $statusCode = $response.StatusCode

        if ($statusCode -eq [int]$ExpectedStatus) {
            Write-TestResult -TestName $TestName -Passed $true -Message "Status $statusCode"
            return $response
        } else {
            Write-TestResult -TestName $TestName -Passed $false `
                -Message "Expected $ExpectedStatus, got $statusCode"
            return $null
        }
    } catch {
        Write-TestResult -TestName $TestName -Passed $false `
            -Message $_.Exception.Message
        return $null
    }
}

function Get-JsonResponse {
    param(
        [string]$Url,
        [string]$TestName
    )

    try {
        $response = Invoke-WebRequest -Uri $Url -UserAgent $Global:UserAgent `
            -TimeoutSec $Global:TimeoutSeconds -ErrorAction Stop

        $json = $response.Content | ConvertFrom-Json
        Write-TestResult -TestName "$TestName - JSON Parse" -Passed $true
        return $json
    } catch {
        Write-TestResult -TestName "$TestName - JSON Parse" -Passed $false `
            -Message $_.Exception.Message
        return $null
    }
}

# ============================================================================
# JSON Validation Functions
# ============================================================================

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
            Write-TestResult -TestName "$TestName - $FieldPath" -Passed $false `
                -Message "Field path broken at: $field"
            return $false
        }
        $current = $current.$field
    }

    if ($Required -and $null -eq $current) {
        Write-TestResult -TestName "$TestName - $FieldPath" -Passed $false `
            -Message "Required field missing or null"
        return $false
    }

    Write-TestResult -TestName "$TestName - $FieldPath" -Passed $true `
        -Message "Field present"
    return $true
}

function Test-ArrayNotEmpty {
    param(
        [array]$Array,
        [string]$TestName
    )

    if ($null -eq $Array -or $Array.Count -eq 0) {
        Write-TestResult -TestName $TestName -Passed $false `
            -Message "Array is null or empty"
        return $false
    }

    Write-TestResult -TestName $TestName -Passed $true `
        -Message "Array has $($Array.Count) items"
    return $true
}

function Test-EnumValue {
    param(
        [string]$Value,
        [array]$ValidValues,
        [string]$TestName
    )

    if ($ValidValues -contains $Value) {
        Write-TestResult -TestName $TestName -Passed $true `
            -Message "Value: '$Value'"
        return $true
    } else {
        Write-TestResult -TestName $TestName -Passed $false `
            -Message "Invalid value: '$Value'. Expected one of: $($ValidValues -join ', ')"
        return $false
    }
}

# ============================================================================
# Data Type Validation Functions
# ============================================================================

function Test-IsString {
    param(
        [object]$Value,
        [string]$FieldName,
        [string]$TestName
    )

    if ($Value -is [string]) {
        Write-TestResult -TestName "$TestName - $FieldName" -Passed $true
        return $true
    } else {
        $actualType = $Value.GetType().Name
        Write-TestResult -TestName "$TestName - $FieldName" -Passed $false `
            -Message "Expected string, got $actualType"
        return $false
    }
}

function Test-IsNumeric {
    param(
        [object]$Value,
        [string]$FieldName,
        [string]$TestName
    )

    if ($Value -is [int] -or $Value -is [double] -or $Value -is [float]) {
        Write-TestResult -TestName "$TestName - $FieldName" -Passed $true
        return $true
    } else {
        Write-TestResult -TestName "$TestName - $FieldName" -Passed $false `
            -Message "Expected numeric, got $($Value.GetType().Name)"
        return $false
    }
}

# ============================================================================
# Response Header Validation
# ============================================================================

function Test-ResponseHeader {
    param(
        [hashtable]$Headers,
        [string]$HeaderName,
        [string]$TestName,
        [string]$ExpectedValue = ""
    )

    if ($null -eq $Headers) {
        Write-TestResult -TestName "$TestName - $HeaderName" -Passed $false `
            -Message "Headers object is null"
        return $false
    }

    if ($Headers.ContainsKey($HeaderName)) {
        $value = $Headers[$HeaderName]

        if ($ExpectedValue -and $value -notlike "*$ExpectedValue*") {
            Write-TestResult -TestName "$TestName - $HeaderName" -Passed $false `
                -Message "Expected '$ExpectedValue', got '$value'"
            return $false
        }

        Write-TestResult -TestName "$TestName - $HeaderName" -Passed $true `
            -Message "Value: $value"
        return $true
    } else {
        Write-TestResult -TestName "$TestName - $HeaderName" -Passed $false `
            -Message "Header not found"
        return $false
    }
}

# ============================================================================
# Report Generation Functions
# ============================================================================

function Write-TestSummary {
    param(
        [string]$ReportPath = ""
    )

    Write-Host "`n" -NoNewline
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                     TEST SUMMARY                               ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

    $totalTests = $Global:PassCount + $Global:FailCount
    $passPercent = if ($totalTests -gt 0) {
        [math]::Round(($Global:PassCount / $totalTests) * 100, 1)
    } else {
        0
    }

    Write-Host ""
    Write-Host "Total Tests:     $totalTests"
    Write-Host "Passed:          $Global:PassCount ✅"
    Write-Host "Failed:          $Global:FailCount ❌"
    Write-Host "Success Rate:    $passPercent%"
    Write-Host ""

    if ($Global:FailCount -eq 0) {
        Write-Host "🎉 ALL TESTS PASSED! API is ready for implementation." -ForegroundColor Green
    } else {
        Write-Host "⚠️  Some tests failed. Review details above." -ForegroundColor Yellow
    }

    if ($ReportPath) {
        Save-TestReport -Path $ReportPath
    }
}

function Save-TestReport {
    param(
        [string]$Path
    )

    $report = $Global:TestResults | Format-Table -AutoSize | Out-String
    $report | Out-File -FilePath $Path -Encoding UTF8

    Write-Host ""
    Write-Host "Report saved to: $Path" -ForegroundColor Green
}

# ============================================================================
# Test Category Functions
# ============================================================================

function Start-TestCategory {
    param(
        [string]$CategoryName
    )

    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] $CategoryName" -ForegroundColor Cyan
    Write-Host ("─" * 60) -ForegroundColor Cyan
}

function End-TestCategory {
    param(
        [string]$CategoryName
    )

    $categoryTests = @($Global:TestResults | Where-Object { $_.Category -eq $CategoryName })
    $categoryPassed = @($categoryTests | Where-Object { $_.Passed -eq $true }).Count
    $categoryTotal = $categoryTests.Count

    if ($categoryTotal -gt 0) {
        $percent = [math]::Round(($categoryPassed / $categoryTotal) * 100, 0)
        Write-Host "Category Result: $categoryPassed/$categoryTotal passed ($percent%)" `
            -ForegroundColor Gray
    }
}

# ============================================================================
# URL Builder Functions
# ============================================================================

function Build-ScoreboardUrl {
    param(
        [string]$Sport,
        [string]$League,
        [string]$Date = ""
    )

    $url = "$($Global:BaseURL)/$Sport/$League/scoreboard"

    if ($Date) {
        $url += "?dates=$Date"
    }

    return $url
}

function Build-SummaryUrl {
    param(
        [string]$Sport,
        [string]$League,
        [string]$EventID
    )

    return "$($Global:BaseURL)/$Sport/$League/summary?event=$EventID"
}

# ============================================================================
# Assertion Functions
# ============================================================================

function Assert-Equal {
    param(
        [object]$Expected,
        [object]$Actual,
        [string]$Message = ""
    )

    if ($Expected -eq $Actual) {
        return $true
    } else {
        if ($Message) {
            Write-Log "Assertion failed: $Message. Expected: $Expected, Got: $Actual" -Level "ERROR"
        }
        return $false
    }
}

function Assert-NotNull {
    param(
        [object]$Value,
        [string]$Message = ""
    )

    if ($null -ne $Value) {
        return $true
    } else {
        if ($Message) {
            Write-Log "Assertion failed: $Message (value is null)" -Level "ERROR"
        }
        return $false
    }
}

function Assert-NotEmpty {
    param(
        [array]$Array,
        [string]$Message = ""
    )

    if ($null -ne $Array -and $Array.Count -gt 0) {
        return $true
    } else {
        if ($Message) {
            Write-Log "Assertion failed: $Message (array is empty)" -Level "ERROR"
        }
        return $false
    }
}
