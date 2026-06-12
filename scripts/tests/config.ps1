# ESPN API Test Suite - Configuration
# Global settings and test data

# API Configuration
$Global:BaseURL = "https://site.api.espn.com/apis/site/v2/sports"
$Global:UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
$Global:TimeoutSeconds = 10

# Test Data
$Global:TestData = @{
    Sports = @(
        @{
            Name       = "World Cup"
            Sport      = "soccer"
            League     = "fifa.world"
            ShouldPass = $true
            LeagueSlug = "fifa.world"
        },
        @{
            Name       = "Premier League"
            Sport      = "soccer"
            League     = "eng.1"
            ShouldPass = $true
            LeagueSlug = "eng.1"
        },
        @{
            Name       = "La Liga"
            Sport      = "soccer"
            League     = "esp.1"
            ShouldPass = $true
            LeagueSlug = "esp.1"
        },
        @{
            Name       = "Serie A"
            Sport      = "soccer"
            League     = "ita.1"
            ShouldPass = $true
            LeagueSlug = "ita.1"
        },
        @{
            Name       = "MLS"
            Sport      = "soccer"
            League     = "usa.1"
            ShouldPass = $true
            LeagueSlug = "usa.1"
        },
        @{
            Name       = "NBA"
            Sport      = "basketball"
            League     = "nba"
            ShouldPass = $true
            LeagueSlug = "nba"
        },
        @{
            Name       = "NFL"
            Sport      = "football"
            League     = "nfl"
            ShouldPass = $true
            LeagueSlug = "nfl"
        }
    )

    InvalidSports = @(
        @{
            Name       = "Cricket (IPL)"
            Sport      = "cricket"
            League     = "ipl"
            ShouldPass = $false
        }
    )

    KnownEvents = @{
        "fifa.world" = @{
            EventID  = "760415"
            Name     = "South Africa vs Mexico"
            Date     = "2026-06-11"
            Status   = "post"
        }
    }

    TestDates = @(
        "20260611",
        "20260612"
    )
}

# Test Result Tracking
$Global:TestResults = @()
$Global:PassCount = 0
$Global:FailCount = 0

# Logging Configuration
$Global:LogLevel = "INFO"  # DEBUG, INFO, WARN, ERROR
$Global:Verbose = $false
