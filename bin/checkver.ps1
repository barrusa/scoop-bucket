if (!$env:SCOOP_HOME) {
    if ($env:SCOOP -and (Test-Path "$env:SCOOP/apps/scoop/current")) { $env:SCOOP_HOME = "$env:SCOOP/apps/scoop/current" }
    elseif (Test-Path "$env:USERPROFILE/scoop/apps/scoop/current") { $env:SCOOP_HOME = "$env:USERPROFILE/scoop/apps/scoop/current" }
    elseif (Test-Path "$env:ProgramData/scoop/apps/scoop/current") { $env:SCOOP_HOME = "$env:ProgramData/scoop/apps/scoop/current" }
    else { $env:SCOOP_HOME = Convert-Path (scoop prefix scoop) }
}
$checkver = "$env:SCOOP_HOME/bin/checkver.ps1"
$dir = "$PSScriptRoot/../bucket" # checks the parent dir
& $checkver -Dir $dir @Args
