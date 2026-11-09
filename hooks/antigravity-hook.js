#!/usr/bin/env node
"use strict";

// Antigravity PostToolUse hook runner for Antigravity SEO.
//
// Antigravity delivers the hook event as JSON on stdin (camelCase keys):
//   { "toolCall": { "name": "edit_file", "args": { "Path": "..." } }, ... }
// This runner extracts the edited file path, then hands it to the bundled
// schema validator (hooks/validate-schema.py) through the same Python
// discovery chain as the upstream claude-seo hook (AGY_SEO_PYTHON override,
// py -3, python3, python), skipping the Microsoft Store stub.

const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

function stripWrappingQuotes(value) {
  return value.replace(/^["']|["']$/g, "");
}

function pythonCandidates() {
  const candidates = [];
  if (process.env.AGY_SEO_PYTHON) {
    candidates.push({
      label: "AGY_SEO_PYTHON",
      exe: stripWrappingQuotes(process.env.AGY_SEO_PYTHON),
      args: [],
    });
  } else if (process.env.CLAUDE_SEO_PYTHON) {
    candidates.push({
      label: "CLAUDE_SEO_PYTHON",
      exe: stripWrappingQuotes(process.env.CLAUDE_SEO_PYTHON),
      args: [],
    });
  }
  candidates.push(
    { label: "py -3", exe: "py", args: ["-3"] },
    { label: "python3", exe: "python3", args: [] },
    { label: "python", exe: "python", args: [] },
  );
  return candidates;
}

function isStoreStubOutput(text) {
  return /Microsoft Store|WindowsApps|App execution alias|was not found/i.test(text);
}

function probe(candidate) {
  const script = "import sys; print(sys.executable); print(sys.version.split()[0])";
  const result = spawnSync(candidate.exe, [...candidate.args, "-c", script], {
    encoding: "utf8",
  });
  const output = `${result.stdout || ""}\n${result.stderr || ""}`;
  return result.status === 0 && Boolean((result.stdout || "").trim()) && !isStoreStubOutput(output);
}

function resolveEditedPath() {
  // Antigravity contract: JSON event on stdin with camelCase keys.
  try {
    const raw = fs.readFileSync(0, "utf8"); // stdin
    if (raw && raw.trim()) {
      const event = JSON.parse(raw);
      const args = (event.toolCall && event.toolCall.args) || {};
      // Antigravity edit_file/write_file tools expose the target as "Path".
      const candidate = args.Path || args.path || args.file_path || args.filePath;
      if (candidate && fs.existsSync(candidate)) {
        return candidate;
      }
    }
  } catch (err) {
    // Malformed payload or no stdin: fall through to argv.
  }
  return process.argv[2] || null;
}

function main() {
  const hookDir = __dirname;
  const hookScript = path.join(hookDir, "validate-schema.py");
  const editedPath = resolveEditedPath();
  if (!editedPath) {
    // Antigravity expects a JSON object on stdout for PostToolUse.
    console.log("{}");
    process.exit(0);
  }

  for (const candidate of pythonCandidates()) {
    if (!probe(candidate)) {
      continue;
    }
    const result = spawnSync(
      candidate.exe,
      [...candidate.args, hookScript, "--harness", "antigravity", editedPath],
      { stdio: ["ignore", "inherit", "inherit"] },
    );
    if (result.error) {
      continue;
    }
    // validate-schema.py prints the Antigravity contract ("{}") on stdout;
    // the exit code carries severity (2 = blocking schema errors).
    process.exit(result.status === null ? 1 : result.status);
  }

  console.error(
    "Antigravity SEO hook could not find Python. Tried AGY_SEO_PYTHON, CLAUDE_SEO_PYTHON, py -3, python3, python.",
  );
  console.log("{}");
  process.exit(1);
}

main();
