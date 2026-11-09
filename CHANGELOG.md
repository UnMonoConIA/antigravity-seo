# Changelog

All notable changes to **Antigravity SEO** are documented here. This project
is the Google Antigravity port of
[AgriciDaniel/claude-seo](https://github.com/AgriciDaniel/claude-seo); the
upstream changelog is preserved at
[docs/CHANGELOG-upstream.md](docs/CHANGELOG-upstream.md).

## [1.0.0] - 2026-11-09

Initial port of claude-seo v2.5.0 to a native Google Antigravity plugin.

### Added
- Native Antigravity plugin manifest (`plugin.json` at the plugin root).
- `rules/AGENTS.md` plugin rules: plugin-root resolution, runtime contract,
  subagent delegation pattern, and security rules, active whenever the plugin
  is enabled.
- `hooks.json` at the plugin root using the Antigravity named-hook format
  (`PostToolUse` on `edit_file|write_file`), with a new
  `hooks/antigravity-hook.js` runner that reads the Antigravity hook payload
  (camelCase `toolCall.args.Path`) and dispatches the bundled JSON-LD
  validator. `hooks/validate-schema.py` now speaks both the Antigravity and
  Claude Code hook contracts (`--harness`).
- `scripts/antigravity-seo.ps1`: PowerShell launcher for Windows, sibling of
  the bash launcher, with the same Python 3.11–3.14 discovery chain
  (including the Microsoft Store stub guard).
- Installers for Antigravity: `install.ps1` / `install.sh` and
  `uninstall.ps1` / `uninstall.sh` targeting
  `~/.gemini/config/plugins/antigravity-seo/` (global) or
  `.agents/plugins/antigravity-seo/` (workspace, `--workspace`).
- Extension installers now register MCP servers in Antigravity's
  `~/.gemini/config/mcp_config.json`.
- `docs/INSTALLATION.md`, `docs/TROUBLESHOOTING.md`, `docs/COMMANDS.md` and
  `docs/ARCHITECTURE.md` rewritten for the Antigravity plugin layout and
  install flows.

### Removed
- `docs/WORKFLOW-public-private.md` and
  `docs/FINAL-VERIFICATION-v2.2.5-2026-08-26.md`: upstream-maintainer-only
  documents (private marketplace sync, point-in-time verification snapshot)
  that do not apply to this repository. Upstream history remains in
  [docs/CHANGELOG-upstream.md](docs/CHANGELOG-upstream.md).
- Unreferenced `assets/` marketing artwork that carried upstream branding and
  the Claude Code marketplace install flow. `assets/framework.svg` stays: the
  hash-locked FLOW framework reference cites it.

### Changed
- `${CLAUDE_PLUGIN_ROOT}` replaced by a self-relative `<PLUGIN_ROOT>` token:
  the parent of the `skills/` directory containing each skill. No host
  variable expansion is required.
- Environment variables renamed with backwards-compatible fallbacks:
  `AGY_SEO_PYTHON` (← `CLAUDE_SEO_PYTHON`), `AGY_SEO_DATA_DIR`
  (← `CLAUDE_SEO_DATA_DIR`), `AGY_SEO_PLUGIN_DATA` (← `CLAUDE_PLUGIN_DATA`),
  `AGY_SEO_LOCAL_TARGETS` (← `CLAUDE_SEO_LOCAL_TARGETS`) and the rest of the
  `AGY_SEO_*` family.
- Managed runtime data directory: `antigravity-seo` under the platform data
  location (was `claude-seo`).
- Agent specs map to Antigravity subagent mechanics: `model: sonnet` →
  `model: inherit`, `model: opus` → `model: pro`, and Claude Code tool names
  map to Antigravity equivalents (`read_file`, `run_command`, `write_file`,
  `edit_file`, `web_fetch`, `search_web`, `search_files`).
- User-Agent product token: `AntigravitySEO/…` (was `ClaudeSEO/…`).
- HTTP fetch User-Agent and all branding now say Antigravity SEO.

### Unchanged (from upstream v2.5.0)
- All 26 skills, 19 agent specifications, 60+ Python scripts, the managed
  runtime (`scripts/runtime.py`), the schema templates, the Google updates
  ledger, the SSRF/DNS-rebinding safe fetchers, and the full test suite.

### Attribution
Port of [claude-seo](https://github.com/AgriciDaniel/claude-seo) by
[Agrici Daniel](https://agricidaniel.com), MIT licensed. The 10-principle
synthesis framework, quality gates, and all SEO methodology are his work and
the community's, used under the MIT license.
