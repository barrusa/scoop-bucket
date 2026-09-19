if (!$env:SCOOP_HOME) {
    if ($env:SCOOP -and (Test-Path "$env:SCOOP/apps/scoop/current")) { $env:SCOOP_HOME = "$env:SCOOP/apps/scoop/current" }
    elseif (Test-Path "$env:USERPROFILE/scoop/apps/scoop/current") { $env:SCOOP_HOME = "$env:USERPROFILE/scoop/apps/scoop/current" }
    elseif (Test-Path "$env:ProgramData/scoop/apps/scoop/current") { $env:SCOOP_HOME = "$env:ProgramData/scoop/apps/scoop/current" }
    else { $env:SCOOP_HOME = Resolve-Path (scoop prefix scoop) }
}
. "$env:SCOOP_HOME\test\Import-Bucket-Tests.ps1"
