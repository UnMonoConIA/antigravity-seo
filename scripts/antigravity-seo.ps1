# Antigravity SEO launcher for Windows (PowerShell).
# Stable entry point for bundled Python tools, sibling of runtime.py.
#
# Skills and agents invoke it as:
#   & "<PLUGIN_ROOT>\scripts\antigravity-seo.ps1" run <script.py> [args...]
# On macOS/Linux the bash twin "scripts/antigravity-seo" is used instead.
#
# The launcher uses only shell built-ins until a usable Python 3 interpreter
# has been identified, then executes runtime.py with all remaining arguments.

$ErrorActionPreference = "Stop"

$LauncherDir = $PSScriptRoot
if (-not $LauncherDir) {
    $LauncherDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}
$Runtime = Join-Path $LauncherDir "runtime.py"

if (-not (Test-Path -LiteralPath $Runtime)) {
    [Console]::Error.WriteLine("Antigravity SEO runtime is missing. Reinstall Antigravity SEO.")
    exit 2
}

# Supported range. runtime.py (MIN_PYTHON, MAX_PYTHON) is the source of truth.
$MinMinor = 11
$MaxMinor = 14

# AGY_SEO_PYTHON is canonical; CLAUDE_SEO_PYTHON is honored for users coming
# from the upstream claude-seo plugin. An override is an executable path.
if (-not $env:AGY_SEO_PYTHON -and $env:CLAUDE_SEO_PYTHON) {
    $env:AGY_SEO_PYTHON = $env:CLAUDE_SEO_PYTHON
}

function Get-PythonVersion {
    param([string]$Exe, [string[]]$ExeArgs = @())

    $command = Get-Command -Name $Exe -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        return $null
    }
    try {
        $output = & $Exe @ExeArgs -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null
    } catch {
        return $null
    }
    if ($LASTEXITCODE -ne 0 -or -not $output) {
        return $null
    }
    # Guard against the Microsoft Store python.exe alias stub.
    $text = ($output | Out-String)
    if ($text -match 'Microsoft Store|WindowsApps|App execution alias|was not found') {
        return $null
    }
    return (@($output)[0]).ToString().Trim()
}

function Test-VersionInRange {
    param([string]$Version)
    if ($Version -match '^3\.(\d+)$') {
        $minor = [int]$Matches[1]
        return ($minor -ge $MinMinor -and $minor -le $MaxMinor)
    }
    return $false
}

$Selected = $null

if ($env:AGY_SEO_PYTHON) {
    $found = Get-PythonVersion -Exe $env:AGY_SEO_PYTHON
    if ($found -and (Test-VersionInRange $found)) {
        $Selected = @{ Exe = $env:AGY_SEO_PYTHON; Args = @() }
    } else {
        $foundText = if ($found) { $found } else { "no usable Python" }
        [Console]::Error.WriteLine("AGY_SEO_PYTHON must be Python 3.$MinMinor to 3.$MaxMinor. Found: $foundText at $($env:AGY_SEO_PYTHON).")
        exit 2
    }
}

if ($null -eq $Selected) {
    # Prefer the default interpreter when it is supported, so an existing
    # runtime keeps the Python it was built with. Otherwise take the newest
    # supported versioned one. The choice must be stable: runtime.py rebuilds
    # when it changes.
    $candidates = @(
        @{ Exe = 'py'; Args = @('-3') },
        @{ Exe = 'python3'; Args = @() },
        @{ Exe = 'python'; Args = @() }
    )
    for ($minor = $MaxMinor; $minor -ge $MinMinor; $minor--) {
        $candidates += @{ Exe = 'py'; Args = @("-3.$minor") }
        $candidates += @{ Exe = "python3.$minor"; Args = @() }
    }
    $seen = @()
    foreach ($candidate in $candidates) {
        $found = Get-PythonVersion -Exe $candidate.Exe -ExeArgs $candidate.Args
        if ($found -and (Test-VersionInRange $found)) {
            $Selected = $candidate
            break
        }
        if ($found) {
            $seen += "$found ($($candidate.Exe) $($candidate.Args -join ' '))"
        }
    }
    if ($null -eq $Selected) {
        $seenText = if ($seen.Count -gt 0) { $seen -join ', ' } else { 'no Python' }
        [Console]::Error.WriteLine("Antigravity SEO needs Python 3.$MinMinor to 3.$MaxMinor. Found: $seenText. Install Python 3.$MaxMinor from python.org or set AGY_SEO_PYTHON to a supported interpreter.")
        exit 2
    }
}

# Execute runtime.py with the remaining arguments, preserving the exit code.
& $Selected.Exe @($Selected.Args + @($Runtime) + $args)
exit $LASTEXITCODE
