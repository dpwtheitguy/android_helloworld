<#
Windows 11 Dev Setup for Python + Android (BeeWare)

- Installs: Java 17 (Temurin), Python 3.12, pipx, Android Studio
- Sets user JAVA_HOME and updates PATH (user scope)
- Installs Briefcase via pipx

Run:
  powershell -ExecutionPolicy Bypass -File scripts/windows/setup-dev.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Info { param([string]$m) Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-OK   { param([string]$m) Write-Host "[ OK ] $m" -ForegroundColor Green }
function Write-Warn { param([string]$m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err  { param([string]$m) Write-Host "[FAIL] $m" -ForegroundColor Red }

function Test-Command {
    param([Parameter(Mandatory)][string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-Winget {
    if (-not (Test-Command winget)) {
        Write-Err "winget not found. Install latest App Installer from Microsoft Store, then re-run."
        throw "winget missing"
    }
    Write-OK "winget available"
}

function Is-InstalledViaWinget {
    param(
        [Parameter(Mandatory)][string]$Id
    )
    $out = winget list --id $Id --exact 2>$null | Out-String
    return ($out -match $Id) -and (-not ($out -match 'No installed package'))
}

function Install-WithWinget {
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Display
    )
    if (-not $Display -or $Display -eq '') { $Display = $Id }
    if (Is-InstalledViaWinget -Id $Id) {
        Write-OK "$Display already installed"
        return
    }
    Write-Info "Installing $Display via winget..."
    winget install --id $Id --exact --accept-source-agreements --accept-package-agreements --silent | Out-Null
    Start-Sleep -Seconds 3
    if (Is-InstalledViaWinget -Id $Id) { Write-OK "$Display installed" } else { Write-Err "Failed to install $Display"; throw }
}

function Ensure-Python312 {
    $desired = '3.12'
    $pythonOk = $false
    if (Test-Command python) {
        try {
            $ver = (& python --version) 2>&1
            if ($ver -match $desired) { $pythonOk = $true }
        } catch {}
    }
    if (-not $pythonOk -and (Test-Command -Name py)) {
        try {
            $ver = (& py -$desired -V) 2>&1
            if ($LASTEXITCODE -eq 0) { $pythonOk = $true }
        } catch {}
    }
    if (-not $pythonOk) {
        Install-WithWinget -Id 'Python.Python.3.12' -Display 'Python 3.12'
    } else {
        Write-OK "Python $desired detected"
    }
}

function Ensure-Java17 {
    $ok = $false
    if (Test-Command java) {
        try {
            $v = (& java -version) 2>&1 | Select-Object -First 1
            if ($v -match '"17') { $ok = $true }
        } catch {}
    }
    if (-not $ok) {
        Install-WithWinget -Id 'EclipseAdoptium.Temurin.17.JDK' -Display 'Temurin JDK 17'
    } else {
        Write-OK "Java 17 detected"
    }

    # Try to set JAVA_HOME to a Temurin 17 install
    try {
        $candidates = @(
            'C:\Program Files\Eclipse Adoptium',
            'C:\Program Files\Java',
            'C:\Program Files (x86)\Eclipse Adoptium'
        ) | Where-Object { Test-Path $_ }

        $jdkPath = $null
        foreach ($root in $candidates) {
            $dirs = Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'jdk-17' }
            foreach ($d in $dirs) {
                if (Test-Path (Join-Path $d.FullName 'bin\java.exe')) { $jdkPath = $d.FullName }
            }
        }
        if ($null -ne $jdkPath) {
            [Environment]::SetEnvironmentVariable('JAVA_HOME', $jdkPath, 'User')
            Write-OK "JAVA_HOME set to $jdkPath (User)"
            $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
            $bin = Join-Path $jdkPath 'bin'
            if ($userPath -notmatch [regex]::Escape($bin)) {
                [Environment]::SetEnvironmentVariable('Path', "$userPath;$bin", 'User')
                Write-OK "Appended JDK bin to User PATH"
            }
        } else {
            Write-Warn "Could not auto-detect JDK 17 path for JAVA_HOME. You can set it manually later."
        }
    } catch {
        Write-Warn "Skipping JAVA_HOME configuration: $($_.Exception.Message)"
    }
}

function Ensure-Pipx-And-Briefcase {
    Write-Info "Upgrading pip and installing pipx (per-user)..."
    & python -m pip install --user --upgrade pip | Out-Null
    & python -m pip install --user pipx | Out-Null
    Write-OK "pipx installed (user)"

    Write-Info "Ensuring pipx adds its paths to your User PATH..."
    & python -m pipx ensurepath | Out-Null
    Write-OK "pipx ensurepath complete (restart terminal may be required)"

    Write-Info "Installing Briefcase via pipx..."
    & python -m pipx install briefcase | Out-Null
    Write-OK "Briefcase installed"
}

function Ensure-AndroidStudio {
    Install-WithWinget -Id 'Google.AndroidStudio' -Display 'Android Studio'
}

Write-Info "Validating prerequisites and installing missing tools..."
Ensure-Winget
Ensure-Python312
Ensure-Java17
Ensure-AndroidStudio
Ensure-Pipx-And-Briefcase

Write-Host ""; Write-OK "All done!"
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1) Close and reopen your terminal to refresh PATH." -ForegroundColor Gray
Write-Host "  2) Open Android Studio once to finish setup (SDK & emulator)." -ForegroundColor Gray
Write-Host "  3) From this repo: run 'briefcase dev' to test desktop." -ForegroundColor Gray
Write-Host "  4) Start an emulator in Android Studio, then 'briefcase run android'." -ForegroundColor Gray
