# We need to define a dummy function so Mock can find it if it doesn't exist.
function global:scoop {}

Describe "bin/checkhashes.ps1" {
    BeforeAll {
        $script:checkhashesPath = "$PSScriptRoot/checkhashes.ps1"
        $script:tempDir = New-Item -ItemType Directory -Path "$PSScriptRoot/scoop-test-$(Get-Random)"
        $script:mockBinDir = New-Item -ItemType Directory -Path "$script:tempDir/bin"
        $script:mockScriptPath = "$script:mockBinDir/checkhashes.ps1"

        $mockScriptContent = @'
param($Dir)
$global:commandArgs = $Args
$global:commandDir = $Dir
'@
        Set-Content -Path $script:mockScriptPath -Value $mockScriptContent
        $global:tempDirFullName = $script:tempDir.FullName
    }

    AfterAll {
        Remove-Item -Path $script:tempDir -Recurse -Force
        Remove-Item Function:\global:scoop -ErrorAction SilentlyContinue
    }

    BeforeEach {
        $global:commandArgs = $null
        $global:commandDir = $null
        $global:scoopHomeBackup = $env:SCOOP_HOME
    }

    AfterEach {
        if ($global:scoopHomeBackup) {
            $env:SCOOP_HOME = $global:scoopHomeBackup
        } else {
            Remove-Item Env:\SCOOP_HOME -ErrorAction SilentlyContinue
        }
    }

    It "runs with correct dir and args" {
        $env:SCOOP_HOME = $global:tempDirFullName

        & $script:checkhashesPath "arg1" "arg2"

        $expectedDir = "$PSScriptRoot/../bucket"

        $global:commandDir | Should -Be $expectedDir
        $global:commandArgs | Should -Be "arg1", "arg2"
    }

    It "resolves scoop home if not set" {
        Remove-Item Env:\SCOOP_HOME -ErrorAction SilentlyContinue

        Mock scoop { return "C:\scoop\apps\scoop\current" }
        Mock Convert-Path { return $global:tempDirFullName }

        & $script:checkhashesPath

        $expectedDir = "$PSScriptRoot/../bucket"

        $global:commandDir | Should -Be $expectedDir
        $env:SCOOP_HOME | Should -Be $global:tempDirFullName
    }
}
