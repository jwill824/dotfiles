BeforeAll {
    . $PSScriptRoot/../setup.ps1
}

Describe 'Windows Setup Script' {
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
            # Add test implementation
        }
    }

    Context 'DevDrive Setup' {
        It 'Should create DevDrive on Windows 11' {
            Mock Get-CimInstance { return @{ Version = "10.0.22000" } }
            Mock Get-VirtualDisk { return $null }
            Mock New-VirtualDisk { return $true }
            # Add test implementation
        }
    }

    Context 'Package Installation' {
        It 'Should install packages from packages.json' {
            Mock Get-Content { return '{"winget":[{"name":"test","id":"test.app"}]}' }
            Mock ConvertFrom-Json { return @{ winget = @(@{ name = "test"; id = "test.app" }) } }
            Mock winget { return $true }
            # Add test implementation
        }
    }
}
