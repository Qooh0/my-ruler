# Windows で Make をインストールするスクリプト
# Usage: .\scripts\install-make.ps1
#
# 3つの方法から選択:
#   1. Scoop (推奨 - 管理者権限不要)
#   2. Chocolatey (管理者権限必要)
#   3. Winget (Windows 10/11 標準)

param(
    [ValidateSet("scoop", "choco", "winget", "auto")]
    [string]$Method = "auto"
)

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-WithScoop {
    Write-Host "[Scoop] Installing make..." -ForegroundColor Cyan

    if (-not (Test-CommandExists "scoop")) {
        Write-Host "[Scoop] Scoop not found. Installing Scoop first..." -ForegroundColor Yellow
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }

    scoop install make
    Write-Host "[OK] make installed via Scoop" -ForegroundColor Green
}

function Install-WithChocolatey {
    Write-Host "[Chocolatey] Installing make..." -ForegroundColor Cyan

    if (-not (Test-CommandExists "choco")) {
        Write-Host "[ERROR] Chocolatey not found." -ForegroundColor Red
        Write-Host "Install Chocolatey first: https://chocolatey.org/install" -ForegroundColor Yellow
        Write-Host "Or use: winget install Chocolatey.Chocolatey" -ForegroundColor Yellow
        exit 1
    }

    # Chocolatey requires admin
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "[ERROR] Chocolatey requires administrator privileges." -ForegroundColor Red
        Write-Host "Run PowerShell as Administrator and try again." -ForegroundColor Yellow
        exit 1
    }

    choco install make -y
    Write-Host "[OK] make installed via Chocolatey" -ForegroundColor Green
}

function Install-WithWinget {
    Write-Host "[Winget] Installing make..." -ForegroundColor Cyan

    if (-not (Test-CommandExists "winget")) {
        Write-Host "[ERROR] Winget not found. Windows 10 (1809+) or Windows 11 required." -ForegroundColor Red
        exit 1
    }

    winget install GnuWin32.Make --accept-source-agreements --accept-package-agreements

    # PATH warning
    Write-Host ""
    Write-Host "[WARN] You may need to add Make to your PATH manually." -ForegroundColor Yellow
    Write-Host "Default location: C:\Program Files (x86)\GnuWin32\bin" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To add to PATH:" -ForegroundColor Cyan
    Write-Host '  1. Press Win + R, type "systempropertiesadvanced"' -ForegroundColor White
    Write-Host '  2. Click "Environment Variables"' -ForegroundColor White
    Write-Host '  3. Edit "Path" and add: C:\Program Files (x86)\GnuWin32\bin' -ForegroundColor White
    Write-Host ""
    Write-Host "[OK] make installed via Winget" -ForegroundColor Green
}

# Main
Write-Host "=== Windows Make Installer ===" -ForegroundColor Cyan
Write-Host ""

# Check if make already exists
if (Test-CommandExists "make") {
    $makeVersion = (make --version 2>&1 | Select-Object -First 1)
    Write-Host "[OK] make is already installed: $makeVersion" -ForegroundColor Green
    exit 0
}

# Auto-detect best method
if ($Method -eq "auto") {
    if (Test-CommandExists "scoop") {
        $Method = "scoop"
    } elseif (Test-CommandExists "choco") {
        $Method = "choco"
    } elseif (Test-CommandExists "winget") {
        $Method = "winget"
    } else {
        # Default to Scoop (will install it)
        $Method = "scoop"
    }
    Write-Host "Auto-detected method: $Method" -ForegroundColor Cyan
}

switch ($Method) {
    "scoop"  { Install-WithScoop }
    "choco"  { Install-WithChocolatey }
    "winget" { Install-WithWinget }
}

Write-Host ""
Write-Host "Restart your terminal, then verify with: make --version" -ForegroundColor Cyan
