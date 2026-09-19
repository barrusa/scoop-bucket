Import-Module Pester

Describe "checkver.ps1" {
    BeforeAll {
        $ScriptPath = "$PSScriptRoot/checkver.ps1"
        $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) "ScoopTest_$(New-Guid)"
        New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
        $MockScoopHome = Join-Path $TempDir "scoop_home"
        New-Item -ItemType Directory -Path "$MockScoopHome/bin" -Force | Out-Null
        $MockCheckver = "$MockScoopHome/bin/checkver.ps1"
        # The script we are testing wraps the global checkver and passes -Dir and @Args
        Set-Content -Path $MockCheckver -Value "param(`$Dir) Write-Output `"CALLED:`$Dir`$(`$args -join ',')`""
    }

    AfterAll {
        Remove-Item -Path $TempDir -Recurse -Force
    }

    Context "When SCOOP_HOME is already set" {
        BeforeEach {
            $env:SCOOP_HOME = $MockScoopHome
        }
        AfterEach {
            $env:SCOOP_HOME = $null
        }

        It "calls the global checkver script with correct bucket directory" {
            $output = & $ScriptPath *>&1
            $output | Should -Match "CALLED:.*bucket"
        }

        It "passes additional arguments to the global checkver script" {
            $output = & $ScriptPath "arg1" "arg2" *>&1
            $output | Should -Match "CALLED:.*bucketarg1,arg2"
        }
    }

    Context "When SCOOP_HOME is not set" {
        BeforeEach {
            $env:SCOOP_HOME = $null
            function global:scoop { Write-Output $MockScoopHome }
        }
        AfterEach {
            $env:SCOOP_HOME = $null
            Remove-Item -Path Function:\scoop -ErrorAction Ignore
        }

        It "uses 'scoop prefix scoop' to find SCOOP_HOME" {
            Mock -CommandName scoop -MockWith { return $MockScoopHome }

            $output = & $ScriptPath *>&1
            $output | Should -Match "CALLED:.*bucket"

            Should -Invoke -CommandName scoop -Times 1 -ParameterFilter { $args[0] -eq 'prefix' -and $args[1] -eq 'scoop' }
        }
    }
}
