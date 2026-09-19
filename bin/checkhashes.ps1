. "$PSScriptRoot/utils.ps1"
$checkhashes = "$env:SCOOP_HOME/bin/checkhashes.ps1"
$dir = "$PSScriptRoot/../bucket" # checks the parent dir
& $checkhashes -Dir $dir @Args
