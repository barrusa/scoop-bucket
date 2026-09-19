. "$PSScriptRoot/utils.ps1"
$checkver = "$env:SCOOP_HOME/bin/checkver.ps1"
$dir = "$PSScriptRoot/../bucket" # checks the parent dir
& $checkver -Dir $dir @Args
