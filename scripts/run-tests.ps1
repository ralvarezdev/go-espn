# ESPN API Test Suite - Main Orchestrator
# Runs all modular test suites and generates report

param(
    [string]$OutputDir = ".\test-results",
    [switch]$Verbose = $false,
    [int]$TimeoutSeconds = 10,
    [string[]]$Tests = @()  # Specific tests to run (e.g., "01-endpoints", "02-scoreboard-structure")
)

# ============================================================================
# Setup
# ============================================================================

$Global:Verbose = $Verbose
$Global:TimeoutSeconds = $TimeoutSeconds

# Script root directory
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$TestsDir = Join-Path $ScriptRoot "tests"

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "
╔════════════════════════════════════════════════════════════════╗
║           ESPN API Test Suite - Starting                       ║
║  Test Directory: $TestsDir
║  Output Directory: $OutputDir
║  Timeout: ${TimeoutSeconds}s                                           ║
╚════════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

# ============================================================================
# Load Configuration and Helpers
# ============================================================================

Write-Host "Loading configuration..." -ForegroundColor Gray

$configFile = Join-Path $TestsDir "config.ps1"
if (-not (Test-Path $configFile)) {
    Write-Error "Configuration file not found: $configFile"
    exit 1
}
. $configFile

$helpersFile = Join-Path $TestsDir "test-helpers.ps1"
if (-not (Test-Path $helpersFile)) {
    Write-Error "Helpers file not found: $helpersFile"
    exit 1
}
. $helpersFile

Write-Host "✅ Configuration and helpers loaded" -ForegroundColor Green

# ============================================================================
# Discover Test Modules
# ============================================================================

Write-Host "Discovering test modules..." -ForegroundColor Gray

$testModules = @()

if ($Tests.Count -eq 0) {
    # Run all tests
    $testFiles = Get-ChildItem -Path $TestsDir -Filter "[0-9][0-9]-*.ps1" | Sort-Object Name
} else {
    # Run specific tests
    $testFiles = @()
    foreach ($testName in $Tests) {
        $testFile = Get-ChildItem -Path $TestsDir -Filter "$testName.ps1" -ErrorAction SilentlyContinue
        if ($testFile) {
            $testFiles += $testFile
        } else {
            Write-Host "⚠️  Test file not found: $testName" -ForegroundColor Yellow
        }
    }
}

Write-Host "Found $($testFiles.Count) test module(s):" -ForegroundColor Gray
foreach ($file in $testFiles) {
    Write-Host "  - $($file.Name)" -ForegroundColor Gray
}

# ============================================================================
# Execute Test Modules
# ============================================================================

Write-Host "`nExecuting tests...`n" -ForegroundColor Gray

$startTime = Get-Date

foreach ($testFile in $testFiles) {
    try {
        Write-Log "Running: $($testFile.Name)" -Level "INFO"
        & $testFile.FullName
    } catch {
        Write-Log "Error running $($testFile.Name): $($_.Exception.Message)" -Level "ERROR"
    }
}

$endTime = Get-Date
$totalDuration = ($endTime - $startTime).TotalSeconds

# ============================================================================
# Generate Report
# ============================================================================

$reportPath = Join-Path $OutputDir "test-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
$summaryPath = Join-Path $OutputDir "test-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

Write-TestSummary -ReportPath $reportPath

# ============================================================================
# Generate JSON Summary
# ============================================================================

$jsonSummary = @{
    ExecutionTime = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    DurationSeconds = $totalDuration
    TotalTests = $Global:PassCount + $Global:FailCount
    PassedTests = $Global:PassCount
    FailedTests = $Global:FailCount
    SuccessRate = if (($Global:PassCount + $Global:FailCount) -gt 0) {
        [math]::Round(($Global:PassCount / ($Global:PassCount + $Global:FailCount)) * 100, 1)
    } else {
        0
    }
    TestResults = @($Global:TestResults | ForEach-Object {
        @{
            TestName = $_.TestName
            Passed = $_.Passed
            Message = $_.Message
            Category = $_.Category
            Timestamp = $_.Timestamp
        }
    })
} | ConvertTo-Json

$jsonSummary | Out-File -FilePath $summaryPath -Encoding UTF8

Write-Host "JSON summary saved to: $summaryPath" -ForegroundColor Green

# ============================================================================
# Exit Code
# ============================================================================

if ($Global:FailCount -eq 0) {
    exit 0
} else {
    exit 1
}
