Describe 'missing-checkver.ps1' {
    BeforeAll {
        $scriptPath = "$PSScriptRoot/missing-checkver.ps1"
        $global:OriginalScoopHome = $env:SCOOP_HOME

        # Cross platform safe temp
        $global:MockRoot = Join-Path ([System.IO.Path]::GetTempPath()) "ScoopTest_$([Guid]::NewGuid())"
        New-Item -Path $global:MockRoot -ItemType Directory -Force | Out-Null
    }

    AfterAll {
        $env:SCOOP_HOME = $global:OriginalScoopHome
        Remove-Item -Path $global:MockRoot -Recurse -Force
        Remove-Item Function:\global:scoop -ErrorAction Ignore
    }

    Context 'When SCOOP_HOME is not set' {
        BeforeEach {
            $env:SCOOP_HOME = $null

            # Create a mock wrapper for scoop to satisfy Pester since scoop isn't installed
            function global:scoop { return 'mock_prefix' }

            Mock scoop { return 'mock_prefix' } -ParameterFilter { $args[0] -eq 'prefix' -and $args[1] -eq 'scoop' }
            Mock Convert-Path { return (Join-Path $global:MockRoot 'Scoop1') }
        }

        It 'should resolve SCOOP_HOME using scoop prefix scoop' {
            $mockScoopHome = Join-Path $global:MockRoot 'Scoop1'
            $mockScriptDir = Join-Path $mockScoopHome 'bin'
            New-Item -Path $mockScriptDir -ItemType Directory -Force | Out-Null
            $mockScriptPath = Join-Path $mockScriptDir 'missing-checkver.ps1'
            New-Item -Path $mockScriptPath -ItemType File -Force | Out-Null

            Set-Content -Path $mockScriptPath -Value '$global:MockTargetInvoked = $true'
            $global:MockTargetInvoked = $false

            . $scriptPath

            $env:SCOOP_HOME | Should -Be $mockScoopHome
            $global:MockTargetInvoked | Should -Be $true
        }
    }

    Context 'When SCOOP_HOME is already set' {
        BeforeEach {
            $env:SCOOP_HOME = Join-Path $global:MockRoot 'Scoop2'

            # Create a mock wrapper for scoop to satisfy Pester
            function global:scoop { return 'mock_prefix' }

            Mock scoop { return 'mock_prefix' }
            Mock Convert-Path { return (Join-Path $global:MockRoot 'Scoop2') }
        }

        It 'should use the existing SCOOP_HOME and not call scoop prefix' {
            $mockScoopHome = Join-Path $global:MockRoot 'Scoop2'
            $mockScriptDir = Join-Path $mockScoopHome 'bin'
            New-Item -Path $mockScriptDir -ItemType Directory -Force | Out-Null
            $mockScriptPath = Join-Path $mockScriptDir 'missing-checkver.ps1'
            New-Item -Path $mockScriptPath -ItemType File -Force | Out-Null

            Set-Content -Path $mockScriptPath -Value '$global:MockTargetInvoked = $true'
            $global:MockTargetInvoked = $false

            . $scriptPath

            $env:SCOOP_HOME | Should -Be $mockScoopHome
            Should -Invoke -CommandName scoop -Times 0 -Exactly
            $global:MockTargetInvoked | Should -Be $true
        }
    }

    Context 'Argument Passing' {
        BeforeEach {
            $env:SCOOP_HOME = Join-Path $global:MockRoot 'Scoop3'
        }

        It 'should pass arguments to the missing-checkver script' {
            $mockScoopHome = Join-Path $global:MockRoot 'Scoop3'
            $mockScriptDir = Join-Path $mockScoopHome 'bin'
            New-Item -Path $mockScriptDir -ItemType Directory -Force | Out-Null
            $mockScriptPath = Join-Path $mockScriptDir 'missing-checkver.ps1'
            New-Item -Path $mockScriptPath -ItemType File -Force | Out-Null

            # To test arguments, we can have the mock script write them to a global variable
            Set-Content -Path $mockScriptPath -Value 'param($Dir, $TestArg); $global:MockTargetArgs = @{Dir=$Dir; TestArg=$TestArg}'
            $global:MockTargetArgs = $null

            & $scriptPath -TestArg 'TestValue'

            $global:MockTargetArgs.Dir | Should -Be "$PSScriptRoot/../bucket"
            $global:MockTargetArgs.TestArg | Should -Be 'TestValue'
        }
    }
}
