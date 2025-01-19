BeforeAll {
    . $PSScriptRoot/../uninstall.ps1
}

Describe 'Windows Uninstall Script' {
    Context 'Package Uninstallation' {
        It 'Should uninstall all packages' {
            Mock Get-Content { return '{"winget":[{"name":"test","id":"test.app"}]}' }
            Mock ConvertFrom-Json { return @{ winget = @(@{ name = "test"; id = "test.app" }) } }
            Mock winget { return $true }
            # Add test implementation
        }
    }

    Context 'Cleanup' {
        It 'Should remove DevDrive' {
            Mock Get-VirtualDisk { return @{ FriendlyName = "DevDrive" } }
            Mock Remove-VirtualDisk { return $true }
            # Add test implementation
        }
    }
}
