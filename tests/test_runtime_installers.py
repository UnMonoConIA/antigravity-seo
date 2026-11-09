"""Static installer/runtime contract checks that do not mutate a real home."""

import os
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]


def test_unix_installer_copies_without_package_managers() -> None:
    text = (ROOT / "install.sh").read_text(encoding="utf-8")
    # The installer only copies files; `seo setup` provisions the runtime.
    assert "pip install" not in text
    assert "python3 -m venv" not in text
    assert "pip install --user" not in text
    # Repository-only directories never land inside the installed plugin.
    assert "--exclude='./.git'" in text
    assert "--exclude='./.github'" in text
    # The installer must refuse to run from outside a plugin checkout.
    assert "plugin.json" in text
    assert 'find "${HOME}/.claude/skills"' not in text


def test_windows_installer_copies_without_path_mutation() -> None:
    text = (ROOT / "install.ps1").read_text(encoding="utf-8")
    assert "pip" not in text.lower()
    assert "SetEnvironmentVariable('PATH'" not in text
    assert 'if (-not (Test-Path (Join-Path $SourceDir "plugin.json")))' in text
    assert '$exclude = @(".git", ".github")' in text
    assert "Remove-Item -Recurse -Force (Join-Path $Destination \".git\")" in text


@pytest.mark.skipif(
    os.name != "posix", reason="the executable bit is a POSIX mode bit; Windows has none"
)
def test_launcher_is_executable() -> None:
    assert (ROOT / "scripts" / "antigravity-seo").stat().st_mode & 0o100


def test_launcher_uses_safe_exec() -> None:
    text = (ROOT / "scripts" / "antigravity-seo").read_text(encoding="utf-8")
    assert 'exec "${AGY_SEO_PYTHON}" "${runtime}" "$@"' in text
    assert 'exec "$@" "${runtime}" "${script_args[@]+"${script_args[@]}"}"' in text
    assert "eval " not in text
