#!/usr/bin/env bash
# Antigravity SEO Installer for macOS and Linux.
# Installs the plugin into Antigravity's global plugin directory:
#   ~/.gemini/config/plugins/antigravity-seo/
# Usage:
#   bash install.sh              (global install)
#   bash install.sh --workspace  (project .agents/plugins/)
set -euo pipefail

printf '%s\n' "========================================" \
  "|   Antigravity SEO - Installer         |" \
  "|   SEO Plugin for Google Antigravity    |" \
  "========================================" ""

# Supported range. scripts/runtime.py (MIN_PYTHON, MAX_PYTHON) is the source
# of truth; tests/test_python_range.py keeps every copy in step.
min_minor=11
max_minor=14
seen=""

probe_version() {
    local version
    version="$("$@" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null)" || return 1
    printf '%s' "${version%$'\r'}"
}

in_range() {
    [[ "$1" =~ ^3\.([0-9]+)$ ]] || return 1
    (( BASH_REMATCH[1] >= min_minor && BASH_REMATCH[1] <= max_minor ))
}

# AGY_SEO_PYTHON is canonical; CLAUDE_SEO_PYTHON is honored for users coming
# from the upstream claude-seo plugin.
override="${AGY_SEO_PYTHON:-${CLAUDE_SEO_PYTHON:-}}"
if [[ -n "${override}" ]]; then
    found="$(probe_version "${override}" || true)"
    if in_range "${found}"; then
        printf '%s\n' "[OK] Python ${found} detected"
    else
        echo "[x] AGY_SEO_PYTHON must be Python 3.${min_minor} to 3.${max_minor}. Found: ${found:-no usable Python}." >&2
        exit 1
    fi
else
    found=""
    for candidate in python3 python; do
        found="$(probe_version "${candidate}" || true)"
        if in_range "${found}"; then
            printf '%s\n' "[OK] Python ${found} detected"
            break
        fi
        [[ -n "${found}" ]] && seen="${seen}${seen:+, }${found} (${candidate})"
        found=""
    done
    if [[ -z "${found}" ]]; then
        echo "[x] Antigravity SEO needs Python 3.${min_minor} to 3.${max_minor}. Found: ${seen:-no Python}. Install Python 3.${max_minor} from python.org or set AGY_SEO_PYTHON." >&2
        exit 1
    fi
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
if [[ ! -f "${script_dir}/plugin.json" ]]; then
    echo "[x] plugin.json not found next to install.sh. Run this script from the repository root." >&2
    exit 1
fi

workspace=0
if [[ "${1:-}" == "--workspace" ]]; then
    workspace=1
    dest="$(pwd)/.agents/plugins/antigravity-seo"
else
    dest="${HOME}/.gemini/config/plugins/antigravity-seo"
fi

printf '\nInstalling to: %s\n' "${dest}"
mkdir -p "${dest}"

# Copy the plugin (excluding repo-only files). A plugin install must not be a
# git checkout so the managed runtime uses the platform data directory.
tar -C "${script_dir}" --exclude='./.git' --exclude='./.github' -cf - . | tar -C "${dest}" -xf -

printf '%s\n' "[OK] Plugin installed" "" "Next steps:" \
    "  1. Restart Google Antigravity so the plugin is discovered." \
    "  2. Ask: 'seo setup'" \
    "  3. Run your first audit: 'seo audit https://example.com'" \
    "" "Uninstall: bash uninstall.sh"
