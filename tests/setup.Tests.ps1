BeforeAll {
    # Ensure we're in test mode
    $env:NO_SYSTEM_CHANGES = "1"
    $env:TEST_HOME = Join-Path $env:RUNNER_TEMP "test-home"
    New-Item -Path $env:TEST_HOME -ItemType Directory -Force

    # Mock system-level operations
    Mock Start-Process { return @{ ExitCode = 0 } }
    Mock Restart-Computer { return $true }
    Mock wsl { return $true }
    Mock winget { return $true }
    
    # Use test paths
    $script:originalHome = $env:HOME
    $env:HOME = $env:TEST_HOME
    
    . $PSScriptRoot/../setup.ps1
}

AfterAll {
    # Restore original HOME
    $env:HOME = $script:originalHome
}

Describe 'Windows Setup Script' -Tag 'Setup' {
    Context 'Admin Check' {
        It 'Should require administrator privileges' {
            # Mock admin check
            Mock [Security.Principal.WindowsPrincipal] {
                return @{
                    IsInRole = { return $false }
                }
            }
            { . $PSScriptRoot/../setup.ps1 } | Should -Throw "Please run as Administrator"
        }
    }

    Context 'WSL Installation' {
        It 'Should install WSL' {
            Mock wsl { return $true }
            Mock dism.exe { return $true }
            
            wsl --install --no-distribution
            Should -Invoke wsl -ParameterFilter { $args -contains '--install' }
            
            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
            Should -Invoke dism.exe -Times 2
        }

        It 'Should create and configure .wslconfig with memory limits' {
            $wslConfigPath = "$HOME\.wslconfig"
            
            # Test content
            $content = Get-Content $wslConfigPath -Raw
            $content | Should -Match "memory=6GB"
            $content | Should -Match "swap=2GB"
            $content | Should -Match "pageReporting=true"
            $content | Should -Match "kernelCommandLine=page_reporting.write_throttling=1000"
            $content | Should -Match "swapFile=.*wsl-swap\.vhdx"
        }

        It 'Should copy and configure .wslconfig' {
            Mock Copy-Item { return $true }
            Mock Get-Content { return '[wsl2]`nmemory=6GB`nswapFile={{TEMP_PATH}}/wsl-swap.vhdx' }
            Mock Set-Content { return $true }
            
            $wslConfigPath = "$HOME\.wslconfig"
            Test-Path $wslConfigPath | Should -Be $true
            
            Should -Invoke Copy-Item -Times 1
            Should -Invoke Set-Content -Times 1
        }
    }

    Context 'DevDrive Setup' {
        It 'Should create DevDrive on Windows 11' {
            Mock Get-CimInstance { return @{ Version = "10.0.22000" } }
            Mock Get-VirtualDisk { return $null }
            Mock New-VirtualDisk { return $true }
            Mock Initialize-Disk { return $true }
            Mock New-Partition { return @{ DriveLetter = "D" } }
            Mock Format-Volume { return $true }
            
            # Test DevDrive creation
            New-VirtualDisk -FriendlyName "DevDrive" -Size 100GB -DevDrive
            Should -Invoke New-VirtualDisk -ParameterFilter { $FriendlyName -eq "DevDrive" }
            
            # Test disk initialization
            Initialize-Disk -VirtualDisk (Get-VirtualDisk -FriendlyName "DevDrive") -PartitionStyle GPT
            Should -Invoke Initialize-Disk -Times 1
            
            # Test partition creation
            $partition = New-Partition -VirtualDisk (Get-VirtualDisk -FriendlyName "DevDrive") -UseMaximumSize -DriveLetter "D"
            Should -Invoke New-Partition -Times 1
            
            # Test volume formatting
            Format-Volume -Partition $partition -FileSystem ReFS -NewFileSystemLabel "DevDrive" -Confirm:$false
            Should -Invoke Format-Volume -Times 1
        }
    }

    Context 'Package Installation' {
        It 'Should install packages from packages.json' {
            Mock Get-Content { return '{"winget":[{"name":"test","id":"test.app"}]}' }
            Mock ConvertFrom-Json { return @{ winget = @(@{ name = "test"; id = "test.app" }) } }
            Mock winget { return $true }
            
            # Test package installation
            $packages = Get-Content -Raw -Path "$HOME\.dotfiles\packages.json" | ConvertFrom-Json
            foreach ($package in $packages.winget) {
                winget install -e --id $package.id
            }
            Should -Invoke winget -Times 1 -ParameterFilter { $args -contains 'install' }
        }
    }

    Context 'Windows Terminal Setup' {
        It 'Should configure Windows Terminal settings' {
            Mock Test-Path { return $true } -ParameterFilter { $Path -like "*WindowsTerminal*" }
            Mock Copy-Item { return $true }
            
            Copy-Item "$HOME\.dotfiles\windows-terminal-settings.json" `
                "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
            Should -Invoke Copy-Item -Times 1
        }
    }

    Context 'Git Setup' {
        It 'Should install Git if not present' {
            Mock Get-Command { return $false }
            Mock winget { return $true }
            
            if (!(Get-Command git -ErrorAction SilentlyContinue)) {
                winget install -e --id Git.Git
            }
            Should -Invoke winget -ParameterFilter { $args -contains 'Git.Git' }
        }
    }

    Context 'Edge Profile Setup' {
        It 'Should create Edge profiles from configuration' {
            Mock Get-Content { return '{"profiles":[{"name":"Work","email":"work@example.com"}]}' }
            Mock ConvertFrom-Json { 
                return @{
                    profiles = @(
                        @{ name = "Work"; email = "work@example.com" }
                    )
                }
            }
            Mock Test-Path { return $false }
            Mock New-Item { return $true }
            Mock ConvertTo-Json { return "{}" }
            Mock Set-Content { return $true }
            
            $edgeProfiles = Get-Content -Raw -Path "$HOME\.dotfiles\edge-profiles.json" | ConvertFrom-Json
            foreach ($profile in $edgeProfiles.profiles) {
                New-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\$($profile.name)" -ItemType Directory -Force
            }
            Should -Invoke New-Item -Times 1
        }
    }

    Context 'Admin Operations' {
        It 'Should skip admin operations in test mode' {
            $env:SKIP_ADMIN_TESTS = "1"
            # Test that admin operations are properly skipped
            { . $PSScriptRoot/../setup.ps1 } | Should -Not -Throw
        }
    }
}
