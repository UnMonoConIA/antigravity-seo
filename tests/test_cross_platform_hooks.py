"""Cross-platform hook configuration regressions."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
HOOKS_JSON = REPO_ROOT / "hooks.json"
HOOK_LAUNCHER = REPO_ROOT / "hooks" / "antigravity-hook.js"
INSTALL_PS1 = REPO_ROOT / "install.ps1"


def _post_tool_entry() -> dict:
    config = json.loads(HOOKS_JSON.read_text(encoding="utf-8"))
    return config["schema-validation"]["PostToolUse"][0]


def test_hook_config_uses_antigravity_named_hook_format() -> None:
    entry = _post_tool_entry()
    handler = entry["hooks"][0]

    # Antigravity's named-hook format: the hook name is the top-level key,
    # the matcher filters by tool name, and the command runs with the
    # hooks.json directory as its working directory.
    assert "schema-validation" in json.loads(HOOKS_JSON.read_text(encoding="utf-8"))
    assert entry["matcher"] == "edit_file|write_file"
    assert handler["type"] == "command"
    assert handler["command"] == "node hooks/antigravity-hook.js"
    # Seconds. The hook runs one local Python validator; a hung interpreter
    # probe must not stall every edit_file or write_file call.
    assert handler["timeout"] == 30
    assert "$" not in handler["command"]


def test_hook_runner_documents_python_probe_order() -> None:
    text = HOOK_LAUNCHER.read_text(encoding="utf-8")
    for marker in ("AGY_SEO_PYTHON", "py", "-3", "python3", "python"):
        assert marker in text


def test_hook_runner_preserves_blocking_exit_code_two(tmp_path: Path) -> None:
    node = shutil.which("node")
    if not node:
        pytest.skip("node is not available in this test environment")

    # A page with a placeholder in its JSON-LD block is a critical error:
    # the validator exits 2 and the runner must forward that exit code
    # while keeping the Antigravity stdout contract ("{}").
    page = tmp_path / "page.html"
    page.write_text(
        '<html><head><script type="application/ld+json">'
        '{"@context":"https://schema.org","@type":"LocalBusiness","name":"[Business Name]"}'
        "</script></head></html>",
        encoding="utf-8",
    )
    event = json.dumps(
        {"toolCall": {"name": "edit_file", "args": {"Path": str(page)}}}
    )
    env = os.environ.copy()
    env["AGY_SEO_PYTHON"] = sys.executable

    proc = subprocess.run(
        [node, str(HOOK_LAUNCHER)],
        input=event,
        env=env,
        capture_output=True,
        text=True,
        timeout=30,
    )

    assert proc.returncode == 2
    assert "[Business Name]" in proc.stderr
    assert proc.stdout.strip() == "{}"


def test_hook_runner_outputs_empty_object_without_payload() -> None:
    node = shutil.which("node")
    if not node:
        pytest.skip("node is not available in this test environment")

    proc = subprocess.run(
        [node, str(HOOK_LAUNCHER)],
        input="",
        capture_output=True,
        text=True,
        timeout=30,
    )

    # No path resolves: the runner still answers the PostToolUse contract.
    assert proc.returncode == 0
    assert proc.stdout.strip() == "{}"


def _blocking_page(tmp_path: Path) -> Path:
    page = tmp_path / "page.html"
    page.write_text(
        '<html><head><script type="application/ld+json">'
        '{"@context":"https://schema.org","@type":"LocalBusiness","name":"[Business Name]"}'
        "</script></head></html>",
        encoding="utf-8",
    )
    return page


def test_hook_runner_accepts_snake_case_tool_call(tmp_path: Path) -> None:
    node = shutil.which("node")
    if not node:
        pytest.skip("node is not available in this test environment")

    # camelCase is the documented contract; a snake_case twin must not
    # silently disable schema validation.
    page = _blocking_page(tmp_path)
    event = json.dumps(
        {"tool_call": {"name": "edit_file", "args": {"Path": str(page)}}}
    )
    env = os.environ.copy()
    env["AGY_SEO_PYTHON"] = sys.executable

    proc = subprocess.run(
        [node, str(HOOK_LAUNCHER)],
        input=event,
        env=env,
        capture_output=True,
        text=True,
        timeout=30,
    )

    assert proc.returncode == 2
    assert "[Business Name]" in proc.stderr
    assert proc.stdout.strip() == "{}"


def test_hook_runner_resolves_workspace_relative_paths(tmp_path: Path) -> None:
    node = shutil.which("node")
    if not node:
        pytest.skip("node is not available in this test environment")

    # Hook commands run with cwd = plugin root, so a workspace-relative
    # "Path" must be resolved against the payload's workspacePaths entries.
    page = _blocking_page(tmp_path)
    event = json.dumps(
        {
            "toolCall": {"name": "edit_file", "args": {"Path": "page.html"}},
            "workspacePaths": [str(tmp_path)],
        }
    )
    env = os.environ.copy()
    env["AGY_SEO_PYTHON"] = sys.executable

    proc = subprocess.run(
        [node, str(HOOK_LAUNCHER)],
        input=event,
        env=env,
        capture_output=True,
        text=True,
        timeout=30,
    )

    assert proc.returncode == 2
    assert "[Business Name]" in proc.stderr
    assert proc.stdout.strip() == "{}"


def test_windows_installer_prefers_py_launcher_and_rejects_store_stubs() -> None:
    text = INSTALL_PS1.read_text(encoding="utf-8")
    py_pos = text.index("Exe = 'py'; Args = @('-3')")
    python3_pos = text.index("Exe = 'python3'; Args = @()")
    python_pos = text.index("Exe = 'python'; Args = @()")

    assert py_pos < python3_pos < python_pos
    assert "Microsoft Store|WindowsApps|App execution alias|was not found" in text
