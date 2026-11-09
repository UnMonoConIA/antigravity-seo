<!--
  Antigravity SEO (antigravity-seo): free, open-source SEO audit plugin for
  Google Antigravity. Port of AgriciDaniel/claude-seo (MIT).
  Technical SEO, Core Web Vitals, E-E-A-T, Schema.org, AI search (GEO), local
  SEO, e-commerce and international SEO. 26 sub-skills and 19 specialist
  agents. MIT licensed.
-->

<h1 align="center">Antigravity SEO</h1>

<p align="center">
  <b>Free, open-source SEO audits inside <a href="https://antigravity.google/">Google Antigravity</a>.</b><br />
  Rank higher in Google and get cited by AI search.
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#commands">Commands</a> ·
  <a href="#how-an-audit-works">How it works</a> ·
  <a href="#extensions">Extensions</a> ·
  <a href="#faq">FAQ</a> ·
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  <a href="https://github.com/UnMonoConIA/antigravity-seo/actions/workflows/ci.yml"><img src="https://github.com/UnMonoConIA/antigravity-seo/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <img src="https://img.shields.io/badge/Google%20Antigravity-Plugin-blue" alt="Google Antigravity plugin" />
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT" /></a>
  <img src="https://img.shields.io/badge/Port%20of-claude--seo-8A2BE2" alt="Port of claude-seo" />
</p>

**Antigravity SEO is a free SEO plugin for
[Google Antigravity](https://antigravity.google/)**, Google's agentic AI
workspace with an agent chat. Give it any website you want to improve and it
runs a full SEO audit in 10 to 15 minutes, then hands you a
clear action plan, sorted by what matters most.

It checks everything a good SEO consultant would:

- **Technical SEO.** Crawlability, indexing, sitemaps, robots.txt, redirects,
  page speed and Core Web Vitals.
- **Content quality.** E-E-A-T (experience, expertise, authority and trust),
  thin pages and topic coverage.
- **Structured data.** Finds, validates and writes Schema.org markup for rich
  results.
- **AI search (GEO, Generative Engine Optimization).** How likely Google AI
  Overviews, AI Mode, ChatGPT,
  Perplexity and Gemini are to cite your pages.
- **Agent readiness.** Lighthouse Agentic Browsing, llms.txt (a proposed
  file that describes your site to AI models), Markdown delivery and WebMCP
  (a W3C Community Group draft for exposing site tools to agents): how well
  AI agents can use your site.
- **Local and e-commerce SEO.** Google Business Profile, reviews, map pack,
  product pages and international sites.

Antigravity SEO is built from **26 sub-skills and 19 specialist agents**, and
up to 17 agents work on your site at the same time. Every recommendation
explains why it matters and how you will know it worked.

> [!NOTE]
> This is the **Google Antigravity port** of
> [Claude SEO](https://github.com/AgriciDaniel/claude-seo) by
> [Agrici Daniel](https://agricidaniel.com): same engine, same methodology,
> same MIT license, native to Antigravity's plugin system (skills are
> instruction files the agent loads on demand, rules are always-on
> guidelines, hooks are scripts auto-triggered on tool events, and MCP is
> the Model Context Protocol, a standard for tool connectors). All credit
> for the SEO methodology and the original
> architecture goes to the upstream project and its contributors.

## Install

You need [Google Antigravity](https://antigravity.google/), Python 3.11 to
3.14, Node.js 18+ (for the schema-validation hook) and Git on your machine.

**Option 1 (clone and install, recommended):**

```bash
git clone https://github.com/UnMonoConIA/antigravity-seo.git
cd antigravity-seo
```

- **Windows (PowerShell):**

  ```powershell
  powershell -ExecutionPolicy Bypass -File install.ps1
  ```

- **macOS / Linux:**

  ```bash
  bash install.sh
  ```

This copies the plugin to Antigravity's global plugin directory
(`~/.gemini/config/plugins/antigravity-seo/`; Antigravity keeps its
configuration under `~/.gemini/`). Add `--workspace` (or
`-Workspace` on Windows) to install it into the current project's
`.agents/plugins/` instead.

**Option 2 (manual copy):**

```bash
mkdir -p ~/.gemini/config/plugins/antigravity-seo
tar --exclude='./.git' --exclude='./.github' -cf - . | tar -C ~/.gemini/config/plugins/antigravity-seo -xf -
```

Exclude `.git` (and `.github`) when you copy: Antigravity treats a directory
that still contains `.git` as a manual checkout, which changes where the
runtime stores its data. Windows commands and details live in
[docs/INSTALLATION.md](docs/INSTALLATION.md).

Then:

1. **Restart Google Antigravity** so the plugin is discovered.
2. In an Antigravity agent chat (not a terminal), ask: **`seo setup`**. This
   creates the plugin's isolated
   Python environment and a headless browser without touching the rest of
   your system.
3. Run your first audit in the same chat: **`seo audit https://example.com`**

`seo doctor` checks runtime readiness any time, without changing anything.

> [!TIP]
> Typing `/seo audit https://example.com` works too: Antigravity passes it to
> the agent as a message and the `seo` skill routes it. Any phrasing that
> mentions SEO, an audit, schema, sitemaps, Core Web Vitals, E-E-A-T or AI
> search triggers the right skill automatically.

## Commands

34 core and extension commands in six groups. The full reference with every
argument lives in [docs/COMMANDS.md](docs/COMMANDS.md).

<details open>
<summary><b>Audits and Planning</b> (5 commands)</summary>
<ul><li><code>seo setup</code>: Create or refresh the isolated Python runtime and Chromium</li><li><code>seo doctor</code>: Check runtime readiness without changing the system</li><li><code>seo audit &lt;url&gt;</code>: Full website audit with parallel agents</li><li><code>seo page &lt;url&gt;</code>: Deep single-page analysis</li><li><code>seo plan &lt;type&gt;</code>: Strategic SEO planning (saas, local, ecommerce, publisher, agency)</li></ul>
</details>
<details>
<summary><b>Technical SEO</b> (7 commands)</summary>
<ul><li><code>seo technical &lt;url&gt;</code>: Technical SEO audit across 9 categories</li><li><code>seo sitemap &lt;url | generate&gt;</code>: Analyze or generate XML sitemaps</li><li><code>seo images &lt;url&gt;</code>: Image optimization analysis</li><li><code>seo hreflang &lt;url&gt;</code>: Hreflang and i18n SEO audit and generation</li><li><code>seo programmatic &lt;url&gt;</code>: Programmatic SEO analysis and planning</li><li><code>seo google [command]</code>: Google SEO APIs: Search Console (GSC), PageSpeed, Chrome UX Report (CrUX), Indexing, GA4, PDF reports</li><li><code>seo drift baseline | compare | history &lt;url&gt;</code>: SEO drift monitoring with SQLite snapshots</li></ul>
</details>
<details>
<summary><b>Content and E-E-A-T</b> (6 commands)</summary>
<ul><li><code>seo content &lt;url&gt;</code>: E-E-A-T and content quality analysis</li><li><code>seo content-brief &lt;topic&gt;</code>: Content brief: target keywords, outline, internal links</li><li><code>seo cluster &lt;keyword&gt;</code>: SERP-based semantic clustering</li><li><code>seo sxo &lt;url&gt;</code>: Search Experience Optimization: page type, user stories, personas</li><li><code>seo flow [stage]</code>: FLOW framework prompts (CC BY 4.0, evidence-led)</li><li><code>seo competitor-pages &lt;url&gt;</code>: Competitor comparison page generation</li></ul>
</details>
<details>
<summary><b>Schema and AI Search</b> (3 commands)</summary>
<ul><li><code>seo schema &lt;url&gt;</code>: Detect, validate and generate Schema.org markup</li><li><code>seo geo &lt;url&gt;</code>: AI Overviews and Generative Engine Optimization</li><li><code>seo agentic &lt;url&gt;</code>: Agent readiness: Lighthouse Agentic Browsing X/N, AI agent access, llms.txt, Markdown, WebMCP</li></ul>
</details>
<details>
<summary><b>Local, Links, Commerce</b> (4 commands)</summary>
<ul><li><code>seo local &lt;url&gt;</code>: Local SEO: GBP, citations, reviews, map pack</li><li><code>seo maps [command]</code>: Maps intelligence: geo-grid, GBP audit, reviews, competitors</li><li><code>seo backlinks &lt;url&gt;</code>: Backlink profile analysis (Moz, Bing, Common Crawl)</li><li><code>seo ecommerce &lt;url&gt;</code>: E-commerce SEO and marketplace intelligence</li></ul>
</details>
<details>
<summary><b>Extensions</b> (9 commands)</summary>
<ul><li><code>seo image-gen [use-case]</code>: AI image generation for SEO assets</li><li><code>seo dataforseo [command]</code>: Live SERP, keyword and backlink data</li><li><code>seo firecrawl [command] &lt;url&gt;</code>: Full-site crawling and site mapping</li><li><code>seo ahrefs [command] &lt;url&gt;</code>: Backlinks and organic keyword data</li><li><code>seo seranking [command]</code>: AI Share-of-Voice across ChatGPT, Gemini, Perplexity, AI Overviews, AI Mode</li><li><code>seo profound [command]</code>: LLM citation tracking with time-series data</li><li><code>seo bing [command] &lt;url&gt;</code>: Bing Webmaster Tools + IndexNow URL submission</li><li><code>seo matomo [command] [args]</code>: Matomo analytics as a GA4 alternative or supplement</li><li><code>seo unlighthouse &lt;url&gt;</code>: Multi-page Lighthouse runner, runs locally</li></ul>
</details>

## How an audit works

1. **It learns your site.** Antigravity SEO detects the type of business
   (SaaS, local, e-commerce, publisher or agency) and adjusts its checks.
2. **The team fans out.** Up to 17 specialist agents audit the site in
   parallel: technical, content, schema, speed, AI search and more. Each agent
   is a subagent with its own context, spawned from the specifications in
   [`agents/`](agents/).
3. **You get a plan, not a pile of warnings.** Findings are scored and sorted
   into a prioritized action plan. Each recommendation says what it is based
   on, what it depends on and how you will know it worked.

Reports are saved as Markdown in a `{domain}-audit/` folder in your
workspace (for example `example.com-audit/`, with `FULL-AUDIT-REPORT.md`,
`ACTION-PLAN.md`, per-category `findings/` and `screenshots/`), and
`seo google report` turns them into a polished PDF.

A quality gate also runs automatically: every time the agent edits or writes
an HTML-like file, the bundled hook validates the JSON-LD schema in it and
flags placeholders, deprecated types and malformed blocks before they ship.

## Extensions

Optional add-ons that bring in more data. Antigravity SEO works fully
without them. Each extension installs its skill and registers its MCP server
in Antigravity's `~/.gemini/config/mcp_config.json`.

- **DataForSEO:** live SERP, keyword, backlink and local SEO data
- **Banana:** AI images for SEO via Gemini
- **Firecrawl:** full-site crawling and site mapping
- **Ahrefs:** backlinks and organic keyword data
- **SE Ranking:** your share of voice in AI answers
- **Profound:** tracks when AI models cite your site
- **Bing Webmaster:** Bing data plus instant IndexNow submission
- **Matomo:** self-hosted or cloud analytics, a GA4 alternative or supplement
- **Unlighthouse:** Lighthouse scores for every page of your site

Setup guides live in [`extensions/`](extensions/) and
[docs/MCP-INTEGRATION.md](docs/MCP-INTEGRATION.md).

## FAQ

<details>
<summary><b>What is Antigravity SEO?</b></summary>
<br />

A free, open-source SEO audit tool that runs inside Google Antigravity. It
checks technical SEO, Core Web Vitals, content quality, Schema.org structured
data, AI search readiness, local SEO, e-commerce and international SEO, then
gives you a prioritized action plan. It follows Google's own documentation,
including the
[AI Optimization Guide](https://developers.google.com/search/docs/fundamentals/ai-optimization-guide).

</details>

<details>
<summary><b>Is it really free?</b></summary>
<br />

Yes. It is MIT licensed, with no per-site pricing, no usage limits and no
tracking. You only need Google Antigravity. A few optional extensions connect
to paid services where you bring your own account, but everything works
without them.

</details>

<details>
<summary><b>Do I need API keys?</b></summary>
<br />

No. Antigravity SEO works out of the box. If you want real field data, you
can connect free Google APIs (PageSpeed Insights, Chrome UX Report, Search
Console and Google Analytics 4) with `seo google setup`. Your keys stay on
your machine.

</details>

<details>
<summary><b>How does it help with AI search like Google AI Overviews and ChatGPT?</b></summary>
<br />

Google says optimizing for AI search is still SEO, so Antigravity SEO starts
with the basics that AI answers rely on: being indexed, fast and clear. Then
`seo geo` scores how easy your pages are to quote, checks that AI crawlers
can reach them and looks at your brand's presence on Wikipedia, Reddit,
YouTube and LinkedIn. `seo agentic` checks how well AI agents can use your
site.

</details>

<details>
<summary><b>Does it work on JavaScript sites like Next.js, React or Vue?</b></summary>
<br />

Yes. When a page needs JavaScript to show its content, Antigravity SEO opens
it in a headless browser automatically, so single-page apps are audited as
visitors see them.

</details>

<details>
<summary><b>Does my data leave my computer?</b></summary>
<br />

Antigravity SEO runs inside Google Antigravity, so the pages and data it
analyzes are sent to the model powering Antigravity, the same as anything
else you work on there. Reports are saved as files on your machine. No SEO
service or other third party sees your data unless you connect an extension
or API yourself. Besides the site you audit, some checks read public sources
such as Wikipedia, Reddit and Common Crawl. See
[PRIVACY.md](PRIVACY.md) for the full list.

</details>

<details>
<summary><b>Good to know: requirements, limits and uninstall</b></summary>
<br />

**Requirements.** Google Antigravity, Python 3.11 to 3.14, Node.js 18+ and
Git. `seo setup`
installs the headless browser for you. The schema-validation hook needs
Node.js on PATH.

**Cost of a full audit.** A full `seo audit` fans out up to 17 subagents, so
it uses more of your Antigravity quota than a single-page check.

**Limits.** Without Google API keys, Core Web Vitals are lab estimates and
indexing is inferred from the page. Pages that load key content only after
scrolling or clicking can give noisy results.

**Uninstall.**

macOS / Linux:

```bash
git clone --depth 1 https://github.com/UnMonoConIA/antigravity-seo.git
cd antigravity-seo
bash uninstall.sh
```

Windows (PowerShell):

```powershell
git clone --depth 1 https://github.com/UnMonoConIA/antigravity-seo.git
cd antigravity-seo
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

</details>

## Contributing

Contributions are very welcome: this port exists so the community can
improve it together. Read [CONTRIBUTING.md](CONTRIBUTING.md) first and
mention the checks you ran in your pull request (`python scripts/portability_check.py --strict`,
`python scripts/consistency_check.py`, `python -m pytest tests/`).

Good first issues:

- More Antigravity-native polish (slash-command ergonomics, hook feedback)
- New extensions (Ahrefs MCP, DataForSEO MCP) and their installers
- Translations of skill descriptions
- More tests for the PowerShell launcher

## License and attribution

MIT License, see [LICENSE](LICENSE). This project is a derivative work of
[Claude SEO](https://github.com/AgriciDaniel/claude-seo) by
[Agrici Daniel](https://agricidaniel.com) and contributors, used under the
MIT license; the upstream changelog is preserved in
[docs/CHANGELOG-upstream.md](docs/CHANGELOG-upstream.md). The FLOW framework
prompts are CC BY 4.0.

**Docs:** [Installation](docs/INSTALLATION.md) · [Commands](docs/COMMANDS.md) ·
[Architecture](docs/ARCHITECTURE.md) · [Troubleshooting](docs/TROUBLESHOOTING.md) ·
[Extensions setup](docs/MCP-INTEGRATION.md) · [Security](SECURITY.md) ·
[Privacy](PRIVACY.md) · [Contributors](CONTRIBUTORS.md)
