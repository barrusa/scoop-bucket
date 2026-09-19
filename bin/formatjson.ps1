. "$PSScriptRoot/utils.ps1"
$formatjson = "$env:SCOOP_HOME/bin/formatjson.ps1"
$path = "$PSScriptRoot/../bucket" # checks the parent dir
& $formatjson -Dir $path @Args
