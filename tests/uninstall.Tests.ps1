BeforeAll {
    . $PSScriptRoot/../uninstall.ps1
}

Describe 'Windows Uninstall Script' -Tag 'Uninstall' {
    Context 'Package Uninstallation' {
        It 'Should uninstall all packages' {
            Mock Get-Content { return '{"winget":[{"name":"test","id":"test.app"}]}' }
            Mock ConvertFrom-Json { return @{ winget = @(@{ name = "test"; id = "test.app" }) } }
            Mock winget { return $true }
            
            # Test package uninstallation
            $packages = Get-Content -Raw -Path "$HOME\.dotfiles\packages.json" | ConvertFrom-Json
            foreach ($package in $packages.winget) {
                winget uninstall --id $package.id
            }
            Should -Invoke winget -Times 1 -ParameterFilter { $args -contains 'uninstall' }
        }
    }

    Context 'Cleanup' {
        It 'Should remove DevDrive' {
            Mock Get-VirtualDisk { return @{ FriendlyName = "DevDrive" } }
            Mock Remove-VirtualDisk { return $true }
            
            # Test DevDrive removal
            $devDrive = Get-VirtualDisk | Where-Object { $_.FriendlyName -eq "DevDrive" }
            $devDrive | Remove-VirtualDisk -Confirm:$false
            Should -Invoke Remove-VirtualDisk -Times 1
        }

        It 'Should remove Edge profiles' {
            Mock Get-ChildItem { 
                return @(
                    @{ Name = "Profile 1"; FullName = "C:\Users\test\AppData\Local\Microsoft\Edge\User Data\Profile 1" }
                )
            }
            Mock Remove-Item { return $true }
            
            # Test Edge profile removal
            $edgeProfilesPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
            Get-ChildItem $edgeProfilesPath -Directory | 
                Where-Object { $_.Name -ne "Default" } | 
                Remove-Item -Recurse -Force
            
            Should -Invoke Remove-Item -Times 1
        }
    }

    Context 'Windows Settings' {
        It 'Should revert file extensions setting' {
            Mock Set-ItemProperty { return $true }
            
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                -Name "HideFileExt" -Value 1
            Should -Invoke Set-ItemProperty -ParameterFilter { $Name -eq "HideFileExt" }
        }

        It 'Should revert hidden files setting' {
            Mock Set-ItemProperty { return $true }
            
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                -Name "Hidden" -Value 2
            Should -Invoke Set-ItemProperty -ParameterFilter { $Name -eq "Hidden" }
        }
    }

    Context 'Terminal Settings' {
        It 'Should remove Windows Terminal settings' {
            Mock Test-Path { return $true }
            Mock Remove-Item { return $true }
            
            Remove-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
            Should -Invoke Remove-Item -Times 1
        }
    }
}
