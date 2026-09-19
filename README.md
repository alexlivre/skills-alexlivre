# Alex Santos AI Agent Skills Hub (`skills-alexlivre`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-Alex_Santos-orange.svg)](https://alexlivre.dev/)
[![GitHub](https://img.shields.io/badge/GitHub-@alexlivre-black.svg)](https://github.com/alexlivre)
[![Skills](https://img.shields.io/badge/Skills-Centralized_Hub-emerald.svg)](https://github.com/alexlivre/skills-alexlivre)

A centralized hub, directory, and registry of production-grade, battle-tested **AI Agent Skills** designed for modern agentic coding workflows, including **Antigravity CLI**, **Claude Code**, **OpenCode**, **Cursor**, **Windsurf**, and custom LLM agents.

Conceived and maintained by **[Alex Santos (alexlivre)](https://alexlivre.dev/)**.

---

## 🧭 Overview & Architecture

AI coding agents are only as reliable as the deterministic domain playbooks and automated verification gates provided to them. 

To ensure maximum modularity, seamless versioning, and direct compatibility with the open **Agent Skills** ecosystem (`skills.sh` / `npx skills add`), each skill in the Alex Santos portfolio is developed in its own dedicated, standalone repository. 

**`skills-alexlivre` serves as the official central hub**:
- 📌 **Centralized Catalog**: Single point of discovery for all production-grade skills by `@alexlivre`.
- 🔗 **Direct Links & Documentation**: Fast access to repositories, architecture manuals, and release notes.
- ⚡ **Unified Installation**: Standardized installation commands via `npx skills add`, cross-platform installers, or manual CLI setups.
- 📋 **Machine-Readable Registry**: Ships with [`registry.json`](./registry.json) for programmatic tooling, agents, and automated aggregators.

---

## 📦 Skills Directory & Catalog

| Skill | Repository | Description | Category | Status |
| :--- | :--- | :--- | :---: | :---: |
| **[`pagespeed-optimizer-alexlivre`](https://github.com/alexlivre/pagespeed-optimizer-alexlivre)** | [alexlivre/pagespeed-optimizer-alexlivre](https://github.com/alexlivre/pagespeed-optimizer-alexlivre) | Universal AI agent skill to analyze, audit, and optimize web applications to **100/100** on PageSpeed Insights & Google Lighthouse 13+ across Performance, Accessibility (WCAG 2.2 AA), Best Practices, SEO, and GEO (Generative Engine Optimization). | Performance & SEO | 🟢 Active |

---

### 🌟 Featured Skill: [`pagespeed-optimizer-alexlivre`](https://github.com/alexlivre/pagespeed-optimizer-alexlivre)

A comprehensive, deterministic optimization engine calibrated for **Lighthouse 13+**, **Core Web Vitals** (LCP, INP, CLS, FCP, TTFB), **WCAG 2.2 AA**, and **GEO (Generative Engine Optimization)** for modern AI search engines (Perplexity, ChatGPT Search, Gemini, Google AI Overviews, Claude).

- **Dedicated Repository**: [https://github.com/alexlivre/pagespeed-optimizer-alexlivre](https://github.com/alexlivre/pagespeed-optimizer-alexlivre)
- **Direct Installation**:
  ```bash
  npx skills add alexlivre/pagespeed-optimizer-alexlivre -g -y
  ```
- **Key Features**:
  - **Automated Verification**: Deterministic static checks via `verify-rules.mjs` before running Lighthouse CLI.
  - **Production Server Recipes**: Zero-guess configs for Nginx (Brotli + immutable caching), Apache, Next.js 15/16 App Router, and Astro 5.
  - **GEO & AI Search Ready**: Ready-to-deploy `llms.txt`, `llms-full.txt`, and 3-profile `robots.txt` templates.
  - **100/100 Reference Benchmark**: Fully functioning demo page scoring 100 on all categories.

👉 Read complete guide, benchmarks, and recipes at the [pagespeed-optimizer-alexlivre repository](https://github.com/alexlivre/pagespeed-optimizer-alexlivre).

---

## 🚀 How to Install Skills

Each skill can be installed individually into your preferred vibe coding environment using the standard package manager or native CLI integration.

### Method 1: `skills.sh` Package Manager (Recommended)

Install directly using `npx`:

```bash
# Global install (available across all projects)
npx skills add alexlivre/pagespeed-optimizer-alexlivre -g -y

# Local install (current project directory only)
npx skills add alexlivre/pagespeed-optimizer-alexlivre -y
```

---

### Method 2: Universal Hub Installers

Clone this hub repository to query the registry and install skills across multiple AI coding CLIs (**Claude Code**, **Antigravity CLI**, **OpenCode**, **Cursor**, **Windsurf**, **Roo Code**):

```bash
git clone https://github.com/alexlivre/skills-alexlivre.git
cd skills-alexlivre
```

#### Node.js (Cross-Platform)
```bash
# List all registered skills and supported environments
node install.mjs --list

# Install specific skill globally
node install.mjs --skill pagespeed-optimizer-alexlivre

# Install for specific CLIs in the current project
node install.mjs --project --cli claude,antigravity --skill pagespeed-optimizer-alexlivre
```

#### Windows PowerShell
```powershell
# List registered skills
.\install.ps1 -List

# Install skill globally
.\install.ps1 -Skill pagespeed-optimizer-alexlivre

# Install locally for Cursor & Claude Code
.\install.ps1 -Project -Cli cursor,claude -Skill pagespeed-optimizer-alexlivre
```

#### Linux / macOS (Bash)
```bash
# List registered skills
./install.sh -l

# Install skill globally
./install.sh -s pagespeed-optimizer-alexlivre
```

---

### Method 3: Direct Git Integration

To install manually to specific agent directories:

```bash
# Claude Code / OpenCode / Universal Agents
git clone https://github.com/alexlivre/pagespeed-optimizer-alexlivre.git ~/.agents/skills/pagespeed-optimizer-alexlivre

# Antigravity CLI
git clone https://github.com/alexlivre/pagespeed-optimizer-alexlivre.git ~/.gemini/antigravity-cli/skills/pagespeed-optimizer-alexlivre

# Claude Code (~/.claude)
git clone https://github.com/alexlivre/pagespeed-optimizer-alexlivre.git ~/.claude/skills/pagespeed-optimizer-alexlivre
```

---

## 🛠️ Hub Repository Structure

```
skills-alexlivre/
├── registry.json             # Machine-readable registry of skills and metadata
├── install.mjs               # Universal Node.js installer & registry query tool
├── install.ps1               # Windows PowerShell installer & registry query tool
├── install.sh                # Linux / macOS Bash installer & registry query tool
├── test-automation/          # Registry and installer validation tests & logs
├── .gitignore
├── LICENSE                   # MIT License
└── README.md                 # Central hub documentation (this file)
```

---

## 🎯 Design Standards & Philosophy

Every skill cataloged in this hub adheres to three non-negotiable principles:

1. **Intention + Guardrails > Generic Defaults**: Every skill provides concrete, verifiable code and operational playbooks rather than superficial or generic AI output.
2. **Business Protection First**: Optimizations and scripts never break analytics, conversion tracking, or legal compliance.
3. **Deterministic Gates**: Automated verification scripts (linters, pre-audit checks, tests) allow agents to verify their own output before closing tasks.

---

## 🤝 Contributing

Have an idea for a skill or want to suggest an improvement?

1. For issues or feature requests with a specific skill, please open an issue in that skill's dedicated repository (e.g., [pagespeed-optimizer-alexlivre](https://github.com/alexlivre/pagespeed-optimizer-alexlivre/issues)).
2. For hub improvements, new skill submissions, or installer updates, open a PR in this repository.

---

## 📄 License

This repository is licensed under the [MIT License](LICENSE). Each skill repository maintains its own MIT License.

---

## 👤 Author

**Alex Santos (alexlivre)**
- Website: [https://alexlivre.dev](https://alexlivre.dev/)
- GitHub: [@alexlivre](https://github.com/alexlivre)
- Email: [alexbreno2005@gmail.com](mailto:alexbreno2005@gmail.com)
