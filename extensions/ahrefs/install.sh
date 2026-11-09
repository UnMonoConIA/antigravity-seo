#!/usr/bin/env bash
# Antigravity SEO: Ahrefs extension installer.
#
# Wires the official @ahrefs/mcp server into ~/.gemini/config/mcp_config.json and
# copies the seo-ahrefs mirror skill into ~/.gemini/skills/.
#
# Prereq: an Ahrefs API token. Get one at https://ahrefs.com/api.
set -euo pipefail

main() {
    SKILL_DIR="${HOME}/.gemini/config/plugins/antigravity-seo/skills"
    # MCP servers live in ~/.gemini/config/mcp_config.json (Antigravity's global MCP config).
    MCP_CONFIG_JSON="${HOME}/.gemini/config/mcp_config.json"

    echo "════════════════════════════════════════"
    echo "║   Antigravity SEO: Ahrefs extension       ║"
    echo "════════════════════════════════════════"

    command -v python3 >/dev/null 2>&1 || {
        echo "✗ Python 3 required."; exit 1;
    }
    command -v npx >/dev/null 2>&1 || {
        echo "✗ Node 18+ / npx required."; exit 1;
    }

    if [ ! -d "${SKILL_DIR}/seo" ]; then
        echo "✗ antigravity-seo base plugin not installed."
        echo "  Install it first: curl -fsSL https://raw.githubusercontent.com/UnMonoConIA/antigravity-seo/main/install.sh | bash"
        exit 1
    fi

    # Locate this script's directory so the call works for both
    # `./install.sh` and `curl | bash` invocations.
    SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" >/dev/null 2>&1 && pwd)"

    read -rsp "Ahrefs API token: " AHREFS_TOKEN
    echo
    if [ -z "${AHREFS_TOKEN}" ]; then
        echo "✗ No token provided."; exit 1;
    fi

    # Pre-warm the package so the first MCP invocation isn't slow.
    echo "→ Pre-warming @ahrefs/mcp..."
    npx --yes --package=@ahrefs/mcp@0.0.11 mcp --help >/dev/null 2>&1 || true

    mkdir -p "${SKILL_DIR}/seo-ahrefs"
    cp "${SOURCE_DIR}/skills/seo-ahrefs/SKILL.md" "${SKILL_DIR}/seo-ahrefs/SKILL.md"
    echo "✓ Installed skill: ${SKILL_DIR}/seo-ahrefs/SKILL.md"

    # Merge MCP config into ~/.gemini/config/mcp_config.json atomically.
    mkdir -p "$(dirname "${MCP_CONFIG_JSON}")"
    AGY_SEO_SECRET="${AHREFS_TOKEN}" python3 - "${MCP_CONFIG_JSON}" <<'PY'
import json
import os
import sys
import tempfile

# The token arrives in the environment, not argv: argv is visible to other
# local users through ps, the environment is not.
path, token = sys.argv[1], os.environ["AGY_SEO_SECRET"]
data = {}
if os.path.exists(path):
    try:
        with open(path) as fh:
            data = json.load(fh)
    except json.JSONDecodeError:
        sys.exit(f"✗ {path} is not valid JSON. Nothing was changed; fix it and rerun.")
data.setdefault("mcpServers", {})["ahrefs"] = {
    "command": "npx",
    "args": ["--yes", "--package=@ahrefs/mcp@0.0.11", "mcp"],
    "env": {"AHREFS_API_TOKEN": token},
}
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path) or ".",
                          prefix=".settings.", suffix=".json")
try:
    with os.fdopen(fd, "w") as fh:
        json.dump(data, fh, indent=2)
    os.chmod(tmp, 0o600)
    os.replace(tmp, path)
except Exception:
    if os.path.exists(tmp):
        os.unlink(tmp)
    raise
print(f"✓ Wrote mcpServers.ahrefs to {path}")
PY

    echo
    echo "Done. Open a new Antigravity session and run:"
    echo "  /seo ahrefs metrics https://example.com"
    echo
    echo "Full docs: extensions/ahrefs/docs/AHREFS-SETUP.md"
}

main "$@"
