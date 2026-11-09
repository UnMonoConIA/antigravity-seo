# Installation Guide

## Prerequisites

- **Google Antigravity** installed ([antigravity.google](https://antigravity.google))
- **Python 3.11 to 3.14** with pip ([python.org/downloads](https://www.python.org/downloads/)). Python 3.10 reached end of life in October 2026, and 3.15 is excluded because the Google Ads client library used by `seo google keywords` does not support it yet
- **Node.js 18+** ([nodejs.org](https://nodejs.org/)) for the schema-validation hook and MCP extension servers. If Node is missing, the schema-validation hook cannot run; audits and every other feature keep working. Extensions need Node 20+ (their installers enforce it)
- **Git** ([git-scm.com/downloads](https://git-scm.com/downloads)) for cloning the repository

Optional:

- **Playwright Chromium** - a headless browser used to render JavaScript-heavy pages and take screenshots. `seo setup` attempts to install it automatically; failure is non-fatal (setup exits with code 10 and audits without JavaScript rendering keep working)

## Quick Install

### Installer (recommended)

The installer copies the plugin to Antigravity's global plugin directory
(`~/.gemini/config/plugins/antigravity-seo/`), where Antigravity discovers it
automatically on the next session start.

**Unix, macOS, Linux:**

```bash
git clone --depth 1 https://github.com/UnMonoConIA/antigravity-seo.git
bash antigravity-seo/install.sh
```

Review-then-run alternative. The installer must run from a clone: it copies
the whole plugin tree that sits next to `install.sh`, so a standalone
download cannot install the plugin:

```bash
git clone --depth 1 https://github.com/UnMonoConIA/antigravity-seo.git
cat antigravity-seo/install.sh   # review
bash antigravity-seo/install.sh  # run when satisfied
rm -rf antigravity-seo
```

**Windows, PowerShell:**

```powershell
git clone --depth 1 https://github.com/UnMonoConIA/antigravity-seo.git
powershell -ExecutionPolicy Bypass -File antigravity-seo\install.ps1
```

The Windows path uses `git clone` rather than `irm | iex` so you can inspect
`install.ps1` before running anything from the network.

**Workspace-only install:** add `--workspace` (bash) or `-Workspace`
(PowerShell) to install into the `.agents/plugins/` directory of the project
root you run the installer from, instead of the global one. Note: the optional
extension installers (`extensions/<name>/install.sh` / `install.ps1`) always
target the global plugin directory and report "not installed" when only a
workspace install exists.

The installer does not run package managers. `seo setup` is an explicit,
one-time provisioning step that writes the virtual environment and browser only
to the plugin's persistent data directory. Use `seo doctor` for a read-only
check.

### Manual Install

1. **Clone the repository**

```bash
git clone https://github.com/UnMonoConIA/antigravity-seo.git
cd antigravity-seo
```

2. **Copy the plugin into Antigravity's plugin directory**

The copy must exclude `.git` (and `.github`): Antigravity treats a directory
that still contains `.git` as a manual checkout, which changes where the
runtime stores its data.

```bash
mkdir -p ~/.gemini/config/plugins/antigravity-seo
tar --exclude='./.git' --exclude='./.github' -cf - . | tar -C ~/.gemini/config/plugins/antigravity-seo -xf -
```

On Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.gemini\config\plugins\antigravity-seo" | Out-Null
Get-ChildItem -Force . | Where-Object { $_.Name -notin '.git','.github' } |
  Copy-Item -Destination "$env:USERPROFILE\.gemini\config\plugins\antigravity-seo" -Recurse -Force
```

3. **Restart Antigravity** so the plugin, its skills, and its rules are loaded.

4. **Provision the managed runtime**

Send `seo setup` in an Antigravity chat (or run the launcher directly):

```bash
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo setup
```

On Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\config\plugins\antigravity-seo\scripts\antigravity-seo.ps1" setup
```

5. **Verify the managed runtime**

`seo setup` provisions an isolated `.venv/` inside the plugin's data
directory and never falls back to global or user package installation.

```bash
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo doctor
```

On Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\config\plugins\antigravity-seo\scripts\antigravity-seo.ps1" doctor
```

If core setup failed, run `seo setup` again and read the failing stage in the
error (virtual environment creation, pip bootstrap, dependency installation,
Chromium installation, or runtime import validation). If only Chromium failed,
setup reports a degraded result and audits without JavaScript rendering keep
working.

## Installation Paths

The installer copies files to:

| Component | Path |
|-----------|------|
| Plugin root (skills, rules, hooks, scripts) | `~/.gemini/config/plugins/antigravity-seo/` |
| Sub-skills | `~/.gemini/config/plugins/antigravity-seo/skills/seo-*/` |
| Subagent specs | `~/.gemini/config/plugins/antigravity-seo/agents/` |
| Runtime launcher (bash) | `~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo` |
| Runtime launcher (Windows) | `~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo.ps1` |
| Isolated Python `.venv/` | Windows: `%LOCALAPPDATA%\antigravity-seo\.venv\` - macOS: `~/Library/Application Support/antigravity-seo/.venv/` - Linux: `${XDG_DATA_HOME:-~/.local/share}/antigravity-seo/.venv/` |

## Verify Installation

1. Start Antigravity (or restart it if it was open).

2. Check that the skill is loaded by sending:

```
seo
```

You should see the skill's command list.

## Uninstallation

Run the uninstaller from a fresh clone:

```bash
git clone --depth 1 https://github.com/UnMonoConIA/antigravity-seo.git
bash antigravity-seo/uninstall.sh
```

On Windows:

```powershell
powershell -ExecutionPolicy Bypass -File antigravity-seo\uninstall.ps1
```

The core uninstaller removes the plugin directory and the managed runtime
data, and preserves `~/.config/antigravity-seo/` (your saved API keys and
configuration). If you installed extensions, run each extension's own
uninstaller first (`bash antigravity-seo/extensions/<name>/uninstall.sh`) so
their MCP entries are removed from `~/.gemini/config/mcp_config.json`.

## Upgrading

To upgrade to the latest version:

```bash
# Uninstall the current version, then install the new one from the same clone
git clone --depth 1 https://github.com/UnMonoConIA/antigravity-seo.git
bash antigravity-seo/uninstall.sh
bash antigravity-seo/install.sh
```

On Windows, run `uninstall.ps1` and `install.ps1` the same way. Afterwards,
run `seo setup` again (the runtime compares the installed requirements hash
and reports "not ready" after an upgrade until you do) and restart
Antigravity.

## Troubleshooting

### "Skill not found" error

Ensure the plugin is installed in the correct location:

```bash
ls ~/.gemini/config/plugins/antigravity-seo/skills/seo/SKILL.md
```

If the file doesn't exist, re-run the installer.

### Python dependency errors

Run the managed setup again:

```bash
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo setup
```

On Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\config\plugins\antigravity-seo\scripts\antigravity-seo.ps1" setup
```

### Playwright screenshot errors

Run the managed setup again and inspect the result:

```bash
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo setup
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo doctor
```

On Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\config\plugins\antigravity-seo\scripts\antigravity-seo.ps1" setup
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\config\plugins\antigravity-seo\scripts\antigravity-seo.ps1" doctor
```

### Permission errors on Unix

Make sure the launcher is executable (the skills and agents invoke it
directly; the Python scripts are run by the launcher's interpreter and need
no exec bit):

```bash
chmod +x ~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo
```
