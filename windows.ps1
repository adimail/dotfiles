$adminCheck = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = $adminCheck.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script must be run as Administrator. Please right-click and 'Run as Administrator'."
    exit
}

function Check-Tool {
    param (
        [string]$toolName,
        [string]$installCommand
    )
    $toolExists = Get-Command $toolName -ErrorAction SilentlyContinue

    if ($toolExists) {
        Write-Host "$toolName is already installed."
    } else {
        Write-Host "$toolName is not installed. Installing..."
        Invoke-Expression $installCommand
    }
}

Check-Tool 'choco' 'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))'
Check-Tool 'git' 'choco install git -y'
Check-Tool 'PSReadLine' 'Install-Module -Name PSReadLine -Force -SkipPublisherCheck'
Check-Tool 'python' 'choco install python -y'
Check-Tool 'g++' 'choco install mingw -y'
Check-Tool 'nvim' 'choco install neovim -y'

Write-Host "Setup is complete! Git, Chocolatey, PSReadLine, Python, g++ compiler, and Neovim are now installed."
