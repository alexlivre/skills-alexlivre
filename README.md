# Alex Santos Agent Skills (`skills-alexlivre`)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-Alex_Santos-orange.svg)](https://alexlivre.dev/)
[![GitHub](https://img.shields.io/badge/GitHub-@alexlivre-black.svg)](https://github.com/alexlivre)

A curated collection of production-grade, battle-tested **AI Agent Skills** designed for modern agentic coding workflows, including **Antigravity CLI**, **Claude Code**, **OpenCode**, **Cursor**, and custom LLM agents.

Conceived and maintained by **[Alex Santos (alexlivre)](https://alexlivre.dev/)**.

---

## 🧭 Overview

AI coding agents are only as capable as the domain expertise and deterministic guardrails provided to them. This repository provides modular, high-impact skills that empower AI agents with:

- **Deep Domain Playbooks**: Step-by-step methodologies that replace superficial code generation with senior-engineer-level solutions.
- **Deterministic Gates & Linters**: Custom validation scripts that enforce strict compliance before concluding tasks, preventing AI hallucination or skipped requirements.
- **Progressive Disclosure**: Lightweight orchestration entrypoints (`SKILL.md`) backed by modular references and production-hardened templates (`references/`, `recipes/`, `templates/`).

---

## 📦 Available Skills

| Skill | Description | Status |
| :--- | :--- | :---: |
| **[`pagespeed-optimizer-alexlivre`](./pagespeed-optimizer-alexlivre)** | Universal agent skill to analyze, audit, and optimize web applications to **100/100** on PageSpeed Insights & Google Lighthouse 13+ across Performance, Accessibility (WCAG 2.2 AA), Best Practices, SEO, and GEO (Generative Engine Optimization). | Available |

---

### Spotlight: `pagespeed-optimizer-alexlivre`

A comprehensive skill calibrated for **Lighthouse 13+**, **Core Web Vitals** (LCP, INP, CLS, FCP, TTFB), **WCAG 2.2 AA**, and **GEO (Generative Engine Optimization)** for modern AI search engines (Perplexity, ChatGPT Search, Gemini, Google AI Overviews, Claude).

**Highlights:**
- **Automated Verification**: Ships with `verify-rules.mjs` to deterministically lint HTML and JavaScript before running dual Lighthouse CLI runs.
- **Production Recipes**: Out-of-the-box configurations for Nginx (Brotli + 1-year immutable caching), Apache, Next.js 15/16 App Router, and Astro 5.
- **GEO & AI Search Ready**: Includes standard `llms.txt`, `llms-full.txt`, and 3-profile `robots.txt` templates.
- **Working Reference Benchmark**: Contains a complete `demo-page` scoring 100/100 on all categories.

👉 Read full documentation in the [pagespeed-optimizer-alexlivre README](./pagespeed-optimizer-alexlivre/README.md).

---

## 🚀 How to Install & Use

### ⚡ One-Liner Quick Install (Recommended)

Choose your operating system or preferred shell to install all skills globally to your vibe coding CLIs (**Claude Code**, **OpenCode**, **Antigravity CLI**, **Cursor**, **Windsurf**, and **Roo Code**):

#### Linux / macOS / WSL
```bash
curl -fsSL https://raw.githubusercontent.com/alexlivre/skills-alexlivre/main/install.sh | bash
```

#### Windows PowerShell
```powershell
irm https://raw.githubusercontent.com/alexlivre/skills-alexlivre/main/install.ps1 | iex
```

---

### 🎛️ Advanced & Targeted Installation

Clone the repository to customize your installation targets, install locally to a specific project, or select specific CLIs:

```bash
git clone https://github.com/alexlivre/skills-alexlivre.git
cd skills-alexlivre
```

#### Windows (PowerShell)
```powershell
# Install only for Claude Code & OpenCode
.\install.ps1 -Cli claude,opencode

# Install into current project repository only (.claude/skills, .agents/skills)
.\install.ps1 -Project

# Install only for Cursor (.cursor/rules/*.mdc)
.\install.ps1 -Cli cursor

# List discovered skills and supported CLIs
.\install.ps1 -List

# Uninstall from targets
.\install.ps1 -Uninstall
```

#### Linux / macOS (Bash)
```bash
# Make executable
chmod +x install.sh

# Install only for Claude Code & Antigravity
./install.sh -c claude,antigravity

# Install into current project directory only
./install.sh -p

# List available skills and supported tools
./install.sh -l

# Uninstall from targets
./install.sh -u
```

#### Cross-Platform (Node.js)
```bash
# Works identically across Windows, macOS, and Linux
node install.mjs
node install.mjs --project --cli claude,opencode
node install.mjs --list
```

---

### 🌐 Open Agent Skills Package Manager (`skills.sh`)

If you use the `skills` CLI, install directly via `npx`:

```bash
# Install globally
npx skills add alexlivre/skills-alexlivre@pagespeed-optimizer-alexlivre -g -y

# Install locally to project
npx skills add alexlivre/skills-alexlivre@pagespeed-optimizer-alexlivre -y
```

---

## 📁 Repository Structure

```
skills-alexlivre/
├── pagespeed-optimizer-alexlivre/    # PageSpeed Insights & GEO Optimizer
│   ├── SKILL.md                      # Agent entrypoint and operational playbook
│   ├── README.md                     # Skill documentation and usage guide
│   ├── demo-page/                    # 100/100 reference benchmark application
│   ├── recipes/                      # Server configs (Nginx, Apache, Next.js, Astro)
│   ├── references/                   # Deep reference manuals (performance, a11y, GEO, SEO)
│   ├── scripts/                      # Verification gates and audit scripts
│   └── templates/                    # GEO, robots.txt, and manifests
├── install.sh                        # Universal Bash installer (Linux / macOS / WSL)
├── install.ps1                       # Universal PowerShell installer (Windows)
├── install.mjs                       # Universal Node.js installer (Cross-platform)
├── test-automation/                  # Verification and test execution logs
├── .gitignore
├── LICENSE                           # MIT License
└── README.md                         # Repository documentation (this file)
```

---

## 🛠️ Design Philosophy & Quality Standards

Every skill in this repository adheres to three foundational rules:

1. **Intention + Guardrails > Generic Defaults**: Skills reject generic "AI slop" or superficial advice in favor of concrete, verifiable code and configs.
2. **Business Protection First**: Optimizations must never break conversion tracking, event attribution, or legal compliance.
3. **Deterministic Gatekeeping**: Where possible, skills provide automated scripts (`verify-rules.mjs`, linters, tests) that agents run to objectively prove compliance.

---

## 🤝 Contributing

Contributions, feedback, and suggestions from the community are warmly welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/new-skill`)
3. Commit your changes (`git commit -m 'feat: add new skill'`)
4. Push to the branch (`git push origin feature/new-skill`)
5. Open a Pull Request

Please ensure any contributed skill includes a clear `SKILL.md`, documentation, and validation mechanisms.

---

## 📄 License

This repository is licensed under the [MIT License](LICENSE).

---

## 👤 Author

**Alex Santos (alexlivre)**
- Website: [https://alexlivre.dev](https://alexlivre.dev/)
- GitHub: [@alexlivre](https://github.com/alexlivre)
- Email: [alexbreno2005@gmail.com](mailto:alexbreno2005@gmail.com)
