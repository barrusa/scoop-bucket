. "$PSScriptRoot/utils.ps1"
$missing_checkver = "$env:SCOOP_HOME/bin/missing-checkver.ps1"
$dir = "$PSScriptRoot/../bucket" # checks the parent dir
& $missing_checkver -Dir $dir @Args
