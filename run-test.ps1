# Quick wrapper script to run tests
# Usage: .\run-test.ps1 [arguments]

param(
    [string[]]$Tests = @(),
    [switch]$Verbose = $false
)

$scriptsDir = Join-Path $PSScriptRoot "scripts"
$testScript = Join-Path $scriptsDir "run-tests.ps1"

if (-not (Test-Path $testScript)) {
    Write-Error "Test script not found: $testScript"
    exit 1
}

$params = @{}
if ($Tests.Count -gt 0) {
    $params['Tests'] = $Tests
}
if ($Verbose) {
    $params['Verbose'] = $true
}

& $testScript @params
