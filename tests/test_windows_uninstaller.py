"""Static contracts for the Windows manual uninstaller.

Upstream claude-seo installs into a shared ~/.claude/skills tree, so its
uninstaller removes skill directories and agent files one by one and its
regression tests count per-item removals. The Antigravity port installs as a
self-contained plugin directory and the uninstaller removes that directory as
one unit; these contracts assert the port's behavior instead.
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_uninstaller_removes_the_whole_plugin_directory() -> None:
    """The plugin directory is removed as one unit, not per-skill."""
    text = (ROOT / "uninstall.ps1").read_text(encoding="utf-8")

    assert (
        'Join-Path $env:USERPROFILE ".gemini\\config\\plugins\\antigravity-seo"'
        in text
    )
    assert "Remove-Item -Recurse -Force $pluginDir" in text
    assert '"[OK] Removed $pluginDir"' in text


def test_uninstaller_handles_a_missing_plugin_gracefully() -> None:
    """A second run must report the missing plugin, not fail."""
    text = (ROOT / "uninstall.ps1").read_text(encoding="utf-8")

    assert "Test-Path $pluginDir" in text
    assert '"[i] Plugin not found at $pluginDir"' in text


def test_uninstaller_preserves_user_configuration() -> None:
    """API keys under ~/.config/antigravity-seo must survive the uninstall."""
    text = (ROOT / "uninstall.ps1").read_text(encoding="utf-8")

    assert "Your API configuration" in text
    for line in text.splitlines():
        if "Remove-Item" in line:
            assert ".config" not in line, (
                f"Remove-Item must never target the user configuration: {line!r}"
            )


def test_windows_smoke_checks_removal_preservation_and_idempotency() -> None:
    """The CI smoke must verify removal, config preservation, and reruns."""
    text = (ROOT / ".github/workflows/windows-smoke.yml").read_text(encoding="utf-8")

    assert '[regex]::Escape("Removed $pluginRoot")' in text
    assert "User configuration was not preserved" in text
    assert "Second uninstall did not report a missing plugin" in text
