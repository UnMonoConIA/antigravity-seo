# Antigravity SEO Installer for Windows (PowerShell)
# Installs the plugin into Antigravity's global plugin directory:
#   ~\.gemini\config\plugins\antigravity-seo\
# Usage:
#   powershell -ExecutionPolicy Bypass -File install.ps1            (global install)
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Workspace (project .agents\plugins\)

param(
    [switch]$Workspace,
    [string]$Destination = ""
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "|   Antigravity SEO - Installer         |" -ForegroundColor Cyan
Write-Host "|   SEO Plugin for Google Antigravity    |" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Supported range. scripts/runtime.py (MIN_PYTHON, MAX_PYTHON) is the source
# of truth; tests/test_python_range.py keeps every copy in step.
$MinMinor = 11
$MaxMinor = 14
$script:SeenPython = @()

function Invoke-External {
    param(
        [Parameter(Mandatory = $true)][string]$Exe,
        [Parameter(Mandatory = $true)][string[]]$Args,
        [switch]$Quiet
    )
    $previousErrorActionPreference = $ErrorActionPreference
    $hasNativePreference = $null -ne (Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue)
    if ($hasNativePreference) { $previousNativePreference = $PSNativeCommandUseErrorActionPreference }
    try {
        $ErrorActionPreference = 'Continue'
        if ($hasNativePreference) { $PSNativeCommandUseErrorActionPreference = $false }
        $output = & $Exe @Args 2>&1 | ForEach-Object { $_.ToString() }
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
        if ($hasNativePreference) { $PSNativeCommandUseErrorActionPreference = $previousNativePreference }
    }
    if (-not $Quiet -and $null -ne $output -and $output.Count -gt 0) {
        $output | ForEach-Object { Write-Host $_ }
    }
    return @{ ExitCode = $exitCode; Output = $output }
}

function Test-PythonCandidate {
    param(
        [Parameter(Mandatory = $true)][string]$Exe,
        [string[]]$Args = @()
    )
    $pythonCmd = Get-Command -Name $Exe -ErrorAction SilentlyContinue
    if ($null -eq $pythonCmd) { return $null }

    $probeCode = "import sys; print(sys.executable); print(sys.version.split()[0]); raise SystemExit(0 if (3, $MinMinor) <= sys.version_info[:2] <= (3, $MaxMinor) else 1)"
    $probe = Invoke-External -Exe $Exe -Args @($Args + @('-c', $probeCode)) -Quiet
    $probeText = ($probe.Output -join "`n")

    if ($probeText -match 'Microsoft Store|WindowsApps|App execution alias|was not found') {
        return $null
    }
    if ($probe.ExitCode -ne 0) {
        if ($probe.ExitCode -eq 1 -and $probe.Output.Count -ge 2 -and "$($probe.Output[1])" -match '^\d+\.\d+') {
            $script:SeenPython += "$($probe.Output[1]) ($(@($Exe) + $Args -join ' '))"
        }
        return $null
    }
    return @{ Exe = $Exe; Args = $Args }
}

function Resolve-Python {
    # AGY_SEO_PYTHON is canonical; CLAUDE_SEO_PYTHON is honored for users
    # coming from the upstream claude-seo plugin. An override must be
    # supported; it is never silently replaced.
    $override = if ($env:AGY_SEO_PYTHON) { $env:AGY_SEO_PYTHON } else { $env:CLAUDE_SEO_PYTHON }
    if ($override) {
        return Test-PythonCandidate -Exe $override -Args @()
    }
    $candidates = @(
        @{ Exe = 'py'; Args = @('-3') },
        @{ Exe = 'python3'; Args = @() },
        @{ Exe = 'python'; Args = @() }
    )
    for ($minor = $MaxMinor; $minor -ge $MinMinor; $minor--) {
        $candidates += @{ Exe = 'py'; Args = @("-3.$minor") }
        $candidates += @{ Exe = "python3.$minor"; Args = @() }
    }
    foreach ($candidate in $candidates) {
        $resolved = Test-PythonCandidate -Exe $candidate.Exe -Args $candidate.Args
        if ($null -ne $resolved) { return $resolved }
    }
    return $null
}

# ---- Check prerequisites ----
$python = Resolve-Python
if ($null -eq $python) {
    $found = 'no Python'
    if ($script:SeenPython.Count -gt 0) { $found = $script:SeenPython -join ', ' }
    Write-Host "[x] Antigravity SEO needs Python 3.$MinMinor to 3.$MaxMinor. Found: $found. Install Python 3.$MaxMinor from python.org or set AGY_SEO_PYTHON." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Python detected" -ForegroundColor Green

# ---- Resolve source and destination ----
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path (Join-Path $SourceDir "plugin.json"))) {
    Write-Host "[x] plugin.json not found next to install.ps1. Run this script from the repository root." -ForegroundColor Red
    exit 1
}

if ($Destination -eq "") {
    if ($Workspace) {
        $Destination = Join-Path (Get-Location) ".agents\plugins\antigravity-seo"
    } else {
        $Destination = Join-Path $env:USERPROFILE ".gemini\config\plugins\antigravity-seo"
    }
}

Write-Host ""
Write-Host "Installing to: $Destination" -ForegroundColor Yellow

# ---- Copy the plugin ----
New-Item -ItemType Directory -Path $Destination -Force | Out-Null
$exclude = @(".git", ".github")
Get-ChildItem -Force $SourceDir | Where-Object { $exclude -notcontains $_.Name } | ForEach-Object {
    Copy-Item $_.FullName -Destination $Destination -Recurse -Force
}
# A plugin install must look like a plugin (not a git checkout) so the
# managed runtime uses the platform data directory.
Remove-Item -Recurse -Force (Join-Path $Destination ".git") -ErrorAction SilentlyContinue

Write-Host "[OK] Plugin installed" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart Google Antigravity so the plugin is discovered."
if ($Workspace) {
    Write-Host "  2. Open this project in Antigravity and ask: `"seo setup`""
} else {
    Write-Host "  2. Open any workspace in Antigravity and ask: `"seo setup`""
}
Write-Host "  3. Run your first audit: `"seo audit https://example.com`""
Write-Host ""
Write-Host "Uninstall: powershell -ExecutionPolicy Bypass -File uninstall.ps1"
