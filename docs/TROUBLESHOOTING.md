# Troubleshooting

## Common Issues

### Skill Not Loading

**Symptom:** `seo` command not recognized

**Solutions:**

For plugin installs, verify the plugin directory and re-run the installer:

```bash
ls ~/.gemini/config/plugins/antigravity-seo/skills/seo/SKILL.md
```

1. Verify installation:
```bash
ls ~/.gemini/config/plugins/antigravity-seo/skills/seo/SKILL.md
```

2. Check SKILL.md has proper frontmatter:
```bash
head -5 ~/.gemini/config/plugins/antigravity-seo/skills/seo/SKILL.md
```
Should start with `---` followed by YAML.

3. Restart Antigravity so it rediscovers the plugin directory.

4. Re-run installer:

Caution: Prefer downloading, inspecting, then running remote scripts; the pipe-to-shell form below is the less-safe convenience option.

```bash
curl -fsSL https://raw.githubusercontent.com/UnMonoConIA/antigravity-seo/main/install.sh | bash
```

---

### Python Dependency Errors

**Symptom:** `ModuleNotFoundError: No module named 'requests'`

**Solution:**

Dependencies belong in the managed runtime. From an Antigravity chat, run:

```bash
seo doctor
seo setup
```

Or run the launcher directly:
```bash
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo doctor
~/.gemini/config/plugins/antigravity-seo/scripts/antigravity-seo setup
```

Do not install individual packages, use `pip --user`, or create a PATH shim.

### requirements.txt Not Found

**Symptom:** `No such file: requirements.txt` after install

**Solution:** Re-run the installer. requirements.txt is copied to the plugin directory:

```bash
ls ~/.gemini/config/plugins/antigravity-seo/requirements.txt
```

If missing, download it directly:
```bash
curl -fsSL https://raw.githubusercontent.com/UnMonoConIA/antigravity-seo/main/requirements.txt \
  -o ~/.gemini/config/plugins/antigravity-seo/requirements.txt
```

### Windows Python Detection Issues

**Symptom:** `python is not recognized` or `pip points to wrong Python`

**Solution (v1.2.0+):** The Windows installer now tries both `python` and `py -3`. If both fail:

1. Install Python from [python.org](https://python.org) and check "Add to PATH"
2. Rerun `install.ps1`. It uses `AGY_SEO_PYTHON` when set, otherwise the first of `py -3`, `python3` and `python` that is Python 3.11 to 3.14, otherwise the newest of `py -3.14` down to `py -3.11`
3. If `py -3` is a newer Python that Antigravity SEO does not support yet (such as 3.15), install 3.14 alongside it, or set `AGY_SEO_PYTHON` to a supported `python.exe`
4. Run `seo doctor` after installation

---

### Playwright Screenshot Errors

**Symptom:** `playwright._impl._errors.Error: Executable doesn't exist`

**Solution:** rerun managed setup so the browser is installed through the same
interpreter and persistent browser directory:
```bash
seo setup
seo doctor
```

---

### Permission Denied Errors

**Symptom:** `Permission denied` when running scripts

**Solution:**
```bash
chmod +x ~/.gemini/config/plugins/antigravity-seo/scripts/*.py
```

---

### Subagent Not Defined

**Symptom:** `Agent 'seo-technical' not found`

**Solution:**

Antigravity SEO subagents are defined at runtime from the specs shipped in the
plugin's `agents/` directory; there is no `~/.gemini/agents/` directory to
populate.

1. Verify the spec files exist:
```bash
ls ~/.gemini/config/plugins/antigravity-seo/agents/seo-*.md
```

2. Check the spec frontmatter:
```bash
head -5 ~/.gemini/config/plugins/antigravity-seo/agents/seo-technical.md
```

3. If files are missing, re-run the installer. If the orchestrator skill is
   not defining the subagents, send `seo` alone to reload the skill routing.

---

### Timeout Errors

**Symptom:** `Request timed out after 30 seconds`

**Solutions:**

1. The target site may be slow: try again
2. Increase timeout in script calls
3. Check your network connection
4. Some sites block automated requests

---

### Schema Validation False Positives

**Symptom:** Hook blocks valid schema

**Check:**

1. Ensure placeholders are replaced
2. Verify @context is `https://schema.org`
3. Check for deprecated/retired types: HowTo and SpecialAnnouncement, plus the June 2025 retirements (ClaimReview, VehicleListing, EstimatedSalary, LearningVideo, and the CourseInfo carousel)
4. FAQPage rich results were retired for all sites on 2026-05-07. The hook does not block it because it remains a valid Schema.org type, but no AI or ranking benefit is confirmed.
5. Validate at [Google's Rich Results Test](https://search.google.com/test/rich-results)

---

### Slow Audit Performance

**Symptom:** Full audit takes too long

**Solutions:**

1. Audit crawls up to 500 pages: large sites take time
2. Subagents run in parallel to speed up analysis
3. For faster checks, use `seo page` on specific URLs
4. Check if site has slow response times

---

## Getting Help

1. **Check the docs:** Review [COMMANDS.md](COMMANDS.md) and [ARCHITECTURE.md](ARCHITECTURE.md)

2. **GitHub Issues:** Report bugs at the repository

3. **Logs:** Check Antigravity's output for error details

## Debug Mode

To see detailed output, check Antigravity's session output or run scripts directly:

```bash
# Test fetch
python3 ~/.gemini/config/plugins/antigravity-seo/scripts/fetch_page.py https://example.com

# Test parse
python3 ~/.gemini/config/plugins/antigravity-seo/scripts/parse_html.py page.html --json

# Test screenshot
python3 ~/.gemini/config/plugins/antigravity-seo/scripts/capture_screenshot.py https://example.com
```
