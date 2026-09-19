Describe 'bin\checkurls.ps1' {
    BeforeAll {
        $script:OriginalScoopHome = $env:SCOOP_HOME
        $tempDir = [System.IO.Path]::GetTempPath()
        $script:TempPath = Join-Path $tempDir "scoop_test"
    }

    BeforeEach {
        $global:CheckUrlsArgs = $null
        $env:SCOOP_HOME = $script:TempPath
        if (!(Test-Path $script:TempPath)) {
            New-Item -ItemType Directory -Path $script:TempPath -Force | Out-Null
        }
        $binDir = Join-Path $script:TempPath "bin"
        if (!(Test-Path $binDir)) {
            New-Item -ItemType Directory -Path $binDir -Force | Out-Null
        }
        $scriptPath = Join-Path $binDir "checkurls.ps1"
        Set-Content -Path $scriptPath -Value '$global:CheckUrlsArgs = $args'
    }

    AfterEach {
        if (Test-Path $script:TempPath) {
            Remove-Item -Path $script:TempPath -Recurse -Force
        }
    }

    AfterAll {
        $env:SCOOP_HOME = $script:OriginalScoopHome
        Remove-Variable CheckUrlsArgs -Scope Global -ErrorAction SilentlyContinue
    }

    It 'Sets SCOOP_HOME if not defined' {
        $env:SCOOP_HOME = $null
        function scoop { return $script:TempPath }
        Mock Convert-Path { return $script:TempPath }
        . "$PSScriptRoot/checkurls.ps1"
        $env:SCOOP_HOME | Should -Be $script:TempPath
    }

    It 'Executes checkurls.ps1 with correct arguments' {
        . "$PSScriptRoot/checkurls.ps1" -Arg1 "Value1"
        $global:CheckUrlsArgs[0] | Should -Be "-Dir"
        $global:CheckUrlsArgs[1] | Should -Be "$PSScriptRoot/../bucket"
        $global:CheckUrlsArgs[2] | Should -Be "-Arg1"
        $global:CheckUrlsArgs[3] | Should -Be "Value1"
    }
}
