#!/usr/bin/env bash
# Antigravity SEO Uninstaller for macOS and Linux.
# Removes the plugin from Antigravity's global plugin directory.
# The managed Python runtime (venv, Chromium) lives outside the plugin
# directory and is removed as well.
set -euo pipefail

printf '%s\n' "========================================" \
  "|   Antigravity SEO - Uninstaller       |" \
  "========================================" ""

workspace=0
if [[ "${1:-}" == "--workspace" ]]; then
    workspace=1
    plugin_dir="$(pwd)/.agents/plugins/antigravity-seo"
else
    plugin_dir="${HOME}/.gemini/config/plugins/antigravity-seo"
fi

if [[ -d "${plugin_dir}" ]]; then
    rm -rf "${plugin_dir}"
    echo "[OK] Removed ${plugin_dir}"
else
    echo "[i] Plugin not found at ${plugin_dir}"
fi

# Managed runtime data (venv, Chromium, state) lives in the platform data
# directory when installed as a plugin.
if [[ "$(uname)" == "Darwin" ]]; then
    runtime_dir="${HOME}/Library/Application Support/antigravity-seo"
else
    runtime_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/antigravity-seo"
fi
if [[ -d "${runtime_dir}" ]]; then
    rm -rf "${runtime_dir}"
    echo "[OK] Removed runtime data ${runtime_dir}"
fi

# User configuration (API keys) is intentionally preserved:
#   ~/.config/antigravity-seo/
printf '\n%s\n%s\n' \
    "Uninstall complete. Restart Google Antigravity." \
    "Your API configuration (~/.config/antigravity-seo) was preserved."
