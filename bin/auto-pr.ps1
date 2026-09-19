param(
    # overwrite upstream param
    [String]$upstream = "barrusa/scoop-bucket:main"
)

. "$PSScriptRoot/utils.ps1"
$autopr = "$env:SCOOP_HOME/bin/auto-pr.ps1"
$dir = "$PSScriptRoot/../bucket" # checks the parent dir
& $autopr -Dir $dir -Upstream $Upstream @Args
