. "$PSScriptRoot/utils.ps1"
$checkurls = "$env:SCOOP_HOME/bin/checkurls.ps1"
$dir = "$PSScriptRoot/../bucket" # checks the parent dir
& $checkurls -Dir $dir @Args
