# Installation Guide

## Prerequisites

- **Google Antigravity** installed and configured
- **Python 3.11 to 3.14** with pip. Python 3.10 reached end of life in October 2026, and 3.15 waits on the Google Ads client library
- **Node.js 18+** for the schema-validation hook and MCP extension servers
- **Git** for cloning the repository

Optional:
- **Playwright Chromium** - install.sh attempts this automatically; failure is non-fatal; needed only for SPA rendering and screenshots

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

Review-then-run alternative:

```bash
curl -fsSL https://raw.githubusercontent.com/UnMonoConIA/antigravity-seo/main/install.sh > install.sh
cat install.sh        # review
bash install.sh       # run when satisfied
rm install.sh
```

**Windows, PowerShell:**

```powershell
git clone --depth 1 https://github.com/UnMonoConIA/antigravity-seo.git
powershell -ExecutionPolicy Bypass -File antigravity-seo\install.ps1
```

The Windows path uses `git clone` rather than `irm | iex` so you can inspect
`install.ps1` before running anything from the network.

**Workspace-only install:** add `--workspace` (bash) or `-Workspace`
(PowerShell) to install into the current project's `.agents/plugins/`
directory instead of the global one.

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

```bash
mkdir -p ~/.gemini/config/plugins
cp -r . ~/.gemini/config/plugins/antigravity-seo
```

On Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.gemini\config\plugins" | Out-Null
Copy-Item -Recurse -Force . "$env:USERPROFILE\.gemini\config\plugins\antigravity-seo"
```

Exclude the `.git` and `.github` directories when copying manually.

3. **Restart Antigravity** so the plugin, its skills, and its rules are loaded.

4. **Provision the managed runtime**

Send `seo setup` in an Antigravity chat (or run the launcher directly):

```bash
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo setup
```

5. **Verify the managed runtime**

The installer delegates dependency and Chromium provisioning to the same runtime
used by every skill. It creates an isolated `.venv/` inside the plugin's data
directory and never falls back to global or user package installation.

```bash
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo doctor
```

If core setup failed, rerun the inspected installer. If only Chromium failed,
the installer reports a degraded result and raw-fetch analysis remains available.

## Installation Paths

The installer copies files to:

| Component | Path |
|-----------|------|
| Plugin root (skills, rules, hooks, scripts) | `~/.gemini/config/plugins/antigravity-seo/` |
| Sub-skills | `~/.gemini/config/plugins/antigravity-seo/skills/seo-*/` |
| Subagent specs | `~/.gemini/config/plugins/antigravity-seo/agents/` |
| Runtime launcher | `~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo` |
| Isolated Python | plugin data dir `.venv/` (see `seo doctor` for the exact path) |

## Verify Installation

1. Start Antigravity (or restart it if it was open).

2. Check that the skill is loaded by sending:

```
seo
```

You should see a help message or a prompt for a URL.

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

`uninstall.sh` removes the plugin directory, installed sub-skills, and the
plugin's MCP entries from `~/.gemini/config/mcp_config.json`. Do not maintain
a hand-coded `rm` list. The shipped uninstaller is the canonical source.

## Upgrading

To upgrade to the latest version:

Caution: Prefer downloading, inspecting, then running remote scripts; the pipe-to-shell form below is the less-safe convenience option.

```bash
# Uninstall current version
curl -fsSL https://raw.githubusercontent.com/UnMonoConIA/antigravity-seo/main/uninstall.sh | bash

# Install new version
curl -fsSL https://raw.githubusercontent.com/UnMonoConIA/antigravity-seo/main/install.sh | bash
```

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

### Playwright screenshot errors

Run the managed setup again and inspect the result:

```bash
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo setup
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo doctor
```

### Permission errors on Unix

Make sure scripts are executable:

```bash
chmod +x ~/.gemini/config/plugins/antigravity-seo/scripts/*.py
```
