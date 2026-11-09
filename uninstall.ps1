# Antigravity SEO Uninstaller for Windows (PowerShell)
# Removes the plugin from Antigravity's global plugin directory.
# The managed Python runtime (venv, Chromium) lives outside the plugin
# directory and is removed as well.

param(
    [switch]$Workspace,
    [string]$Target = ""
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "|   Antigravity SEO - Uninstaller       |" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($Target -eq "") {
    if ($Workspace) {
        $Target = Join-Path (Get-Location) ".agents\plugins\antigravity-seo"
    } else {
        $Target = Join-Path $env:USERPROFILE ".gemini\config\plugins\antigravity-seo"
    }
}

$pluginDir = $Target
if (Test-Path $pluginDir) {
    Remove-Item -Recurse -Force $pluginDir
    Write-Host "[OK] Removed $pluginDir" -ForegroundColor Green
} else {
    Write-Host "[i] Plugin not found at $pluginDir" -ForegroundColor Yellow
}

# Managed runtime data (venv, Chromium, state) lives in the platform data
# directory when installed as a plugin.
$runtimeDir = Join-Path $env:LOCALAPPDATA "antigravity-seo"
if (Test-Path $runtimeDir) {
    Remove-Item -Recurse -Force $runtimeDir
    Write-Host "[OK] Removed runtime data $runtimeDir" -ForegroundColor Green
}

# User configuration (API keys) is intentionally preserved:
#   ~\.config\antigravity-seo\
Write-Host ""
Write-Host "Uninstall complete. Restart Google Antigravity." -ForegroundColor Cyan
Write-Host "Your API configuration (~\.config\antigravity-seo) was preserved." -ForegroundColor DarkGray
