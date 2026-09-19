BeforeAll {
    $ScriptPath = "$PSScriptRoot/auto-pr.ps1"
}

Describe "auto-pr.ps1" {
    BeforeEach {
        $OriginalScoopHome = $env:SCOOP_HOME
        $env:SCOOP_HOME = $null
    }

    AfterEach {
        $env:SCOOP_HOME = $OriginalScoopHome
        Remove-Variable -Name TestArgs -Scope Global -ErrorAction SilentlyContinue
    }

    It "Sets SCOOP_HOME using scoop prefix if not set" {
        function scoop { return '/mock/scoop' }
        Mock -CommandName scoop -MockWith { return '/mock/scoop' }
        Mock -CommandName Convert-Path -MockWith { return "$TestDrive/scoop" }

        $dummyPath = "$TestDrive/scoop/bin"
        New-Item -ItemType Directory -Force -Path $dummyPath | Out-Null

        $testContent = 'param($Dir, $Upstream); $global:TestArgs = @{ Dir = $Dir; Upstream = $Upstream }'
        Set-Content -Path "$dummyPath/auto-pr.ps1" -Value $testContent

        . $ScriptPath -Upstream "test/upstream"

        Should -Invoke -CommandName scoop -Times 1 -Exactly
        $env:SCOOP_HOME | Should -Be "$TestDrive/scoop"

        $global:TestArgs.Dir | Should -Be "$PSScriptRoot/../bucket"
        $global:TestArgs.Upstream | Should -Be "test/upstream"
    }

    It "Uses existing SCOOP_HOME if set" {
        $env:SCOOP_HOME = "$TestDrive/custom_scoop"
        $dummyPath = "$TestDrive/custom_scoop/bin"
        New-Item -ItemType Directory -Force -Path $dummyPath | Out-Null

        $testContent = 'param($Dir, $Upstream); $global:TestArgs = @{ Dir = $Dir; Upstream = $Upstream }'
        Set-Content -Path "$dummyPath/auto-pr.ps1" -Value $testContent

        function scoop { return '/mock/scoop' }
        Mock -CommandName scoop -MockWith { return '/mock/scoop' }

        . $ScriptPath -Upstream "test/upstream2"

        Should -Invoke -CommandName scoop -Times 0 -Exactly
        $env:SCOOP_HOME | Should -Be "$TestDrive/custom_scoop"

        $global:TestArgs.Dir | Should -Be "$PSScriptRoot/../bucket"
        $global:TestArgs.Upstream | Should -Be "test/upstream2"
    }

    It "Passes default Upstream parameter if not specified" {
        $env:SCOOP_HOME = "$TestDrive/custom_scoop"
        $dummyPath = "$TestDrive/custom_scoop/bin"
        New-Item -ItemType Directory -Force -Path $dummyPath | Out-Null

        $testContent = 'param($Dir, $Upstream); $global:TestArgs = @{ Dir = $Dir; Upstream = $Upstream }'
        Set-Content -Path "$dummyPath/auto-pr.ps1" -Value $testContent

        . $ScriptPath

        $global:TestArgs.Upstream | Should -Be "barrusa/scoop-bucket:main"
    }
}
