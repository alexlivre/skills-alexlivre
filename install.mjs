#!/usr/bin/env node

/**
 * Universal AI Agent Skills Cross-Platform Installer
 * Created for Alex Santos (@alexlivre) AI Agent Skills.
 * Works on Windows, macOS, and Linux without any external dependencies.
 *
 * Supports:
 *   - Universal Agent Skills specification (~/.agents/skills/)
 *   - Claude Code (~/.claude/skills/ and ~/.agents/skills/)
 *   - OpenCode (~/.opencode/skills/ and ~/.agents/skills/)
 *   - Antigravity CLI (~/.gemini/antigravity-cli/skills/)
 *   - Cursor (.cursor/rules/*.mdc)
 *   - Windsurf (.windsurf/rules/ and ~/.codeium/windsurf/memories/)
 *   - Roo Code / Cline (~/.roo/skills/)
 */

import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const REPO_URL = 'https://github.com/alexlivre/skills-alexlivre';

// CLI styling colors
const c = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  gray: '\x1b[90m',
};

function showBanner() {
  console.log(`\n${c.cyan}=========================================================${c.reset}`);
  console.log(`${c.green}${c.bold}   Alex Santos (@alexlivre) - AI Agent Skills Installer   ${c.reset}`);
  console.log(`${c.cyan}=========================================================${c.reset}`);
  console.log(`   Repository: ${c.gray}${REPO_URL}${c.reset}\n`);
}

function showHelp() {
  showBanner();
  console.log(`${c.bold}Usage:${c.reset} node install.mjs [options]\n`);
  console.log(`${c.bold}Options:${c.reset}`);
  console.log(`  -g, --global       Install globally in user home directories (default)`);
  console.log(`  -p, --project      Install locally in current working project`);
  console.log(`  -c, --cli <name>   Target CLI (all, agents, claude, opencode, antigravity, cursor, windsurf, roo)`);
  console.log(`  -s, --skill <name> Specific skill to install (default: all discovered)`);
  console.log(`  -u, --uninstall    Uninstall specified skill(s) from target CLIs`);
  console.log(`  -l, --list         List available skills and supported CLIs`);
  console.log(`  -h, --help         Show this help message\n`);
  console.log(`${c.bold}Examples:${c.reset}`);
  console.log(`  ${c.cyan}node install.mjs${c.reset}`);
  console.log(`  ${c.cyan}node install.mjs --project --cli claude,opencode${c.reset}`);
  console.log(`  ${c.cyan}node install.mjs --skill pagespeed-optimizer-alexlivre${c.reset}\n`);
}

// Parse command line arguments
const args = process.argv.slice(2);
let scope = 'global';
let targetCli = 'all';
let targetSkill = 'all';
let doUninstall = false;
let doList = false;

for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  if (arg === '-g' || arg === '--global') {
    scope = 'global';
  } else if (arg === '-p' || arg === '--project' || arg === '--local') {
    scope = 'project';
  } else if (arg === '-c' || arg === '--cli') {
    targetCli = args[++i] || 'all';
  } else if (arg === '-s' || arg === '--skill') {
    targetSkill = args[++i] || 'all';
  } else if (arg === '-u' || arg === '--uninstall') {
    doUninstall = true;
  } else if (arg === '-l' || arg === '--list') {
    doList = true;
  } else if (arg === '-h' || arg === '--help') {
    showHelp();
    process.exit(0);
  } else {
    console.error(`${c.red}Unknown option: ${arg}${c.reset}`);
    showHelp();
    process.exit(1);
  }
}

const sourceDir = __dirname;
const discoveredSkills = [];

// Discover skills
try {
  const entries = fs.readdirSync(sourceDir, { withFileTypes: true });
  for (const entry of entries) {
    if (entry.isDirectory()) {
      const skillMd = path.join(sourceDir, entry.name, 'SKILL.md');
      if (fs.existsSync(skillMd)) {
        discoveredSkills.push(entry.name);
      }
    }
  }
} catch (err) {
  console.error(`${c.red}Failed to read source directory: ${err.message}${c.reset}`);
  process.exit(1);
}

if (discoveredSkills.length === 0) {
  console.error(`${c.red}Error: No skills found with SKILL.md in ${sourceDir}${c.reset}`);
  process.exit(1);
}

if (doList) {
  showBanner();
  console.log(`${c.green}${c.bold}Discovered Skills in Repository:${c.reset}`);
  for (const sk of discoveredSkills) {
    let desc = 'AI Agent Skill';
    const skillMd = path.join(sourceDir, sk, 'SKILL.md');
    try {
      const content = fs.readFileSync(skillMd, 'utf8');
      const m = content.match(/description:\s*(.+)/);
      if (m) {
        desc = m[1].replace(/["']/g, '').trim();
        if (desc.length > 80) desc = desc.slice(0, 77) + '...';
      }
    } catch {}
    console.log(`  - ${c.yellow}${c.bold}${sk}${c.reset} : ${c.gray}${desc}${c.reset}`);
  }
  console.log(`\n${c.green}${c.bold}Supported CLIs & Vibe Coding Tools:${c.reset}`);
  console.log(`  - agents       Universal Agent Skills specification (~/.agents/skills/)`);
  console.log(`  - claude       Claude Code (~/.claude/skills/ and ~/.agents/skills/)`);
  console.log(`  - opencode     OpenCode (~/.opencode/skills/ and ~/.agents/skills/)`);
  console.log(`  - antigravity  Antigravity CLI (~/.gemini/antigravity-cli/skills/)`);
  console.log(`  - cursor       Cursor (.cursor/rules/*.mdc)`);
  console.log(`  - windsurf     Windsurf (.windsurf/rules/ and ~/.codeium/windsurf/memories/)`);
  console.log(`  - roo          Roo Code / Cline (~/.roo/skills/)`);
  console.log(`  - all          Install to all supported tools simultaneously (default)\n`);
  process.exit(0);
}

// Filter skills
let skillsToInstall = [];
if (targetSkill === 'all') {
  skillsToInstall = discoveredSkills;
} else {
  const requested = targetSkill.split(',').map((s) => s.trim());
  for (const r of requested) {
    if (discoveredSkills.includes(r)) {
      skillsToInstall.push(r);
    } else {
      console.warn(`${c.yellow}Warning: Skill '${r}' not found. Skipping.${c.reset}`);
    }
  }
}

if (skillsToInstall.length === 0) {
  console.error(`${c.red}Error: No valid skills selected.${c.reset}`);
  process.exit(1);
}

// Filter CLIs
const supportedClis = ['agents', 'claude', 'opencode', 'antigravity', 'cursor', 'windsurf', 'roo'];
let selectedClis = [];

if (targetCli === 'all') {
  selectedClis = supportedClis;
} else {
  const requested = targetCli.split(',').map((cl) => cl.trim().toLowerCase());
  for (const r of requested) {
    if (supportedClis.includes(r)) {
      selectedClis.push(r);
    } else {
      console.warn(`${c.yellow}Warning: Unknown CLI '${r}'. Skipping.${c.reset}`);
    }
  }
}

showBanner();
console.log(` ${c.bold}Scope:${c.reset} ${c.yellow}${scope.toUpperCase()}${c.reset}`);
console.log(` ${c.bold}Selected CLIs:${c.reset} ${c.cyan}${selectedClis.join(', ')}${c.reset}`);
console.log(` ${c.bold}Skills:${c.reset} ${c.green}${skillsToInstall.join(', ')}${c.reset}\n`);

const homeDir = os.homedir();
const currentDir = process.cwd();

function getTargetDirs(cli, scopeMode, skill) {
  const isGlobal = scopeMode === 'global';
  const baseUser = homeDir;
  const baseLocal = currentDir;

  switch (cli) {
    case 'agents':
      return [
        isGlobal
          ? path.join(baseUser, '.agents', 'skills', skill)
          : path.join(baseLocal, '.agents', 'skills', skill),
      ];
    case 'claude':
      return [
        isGlobal
          ? path.join(baseUser, '.claude', 'skills', skill)
          : path.join(baseLocal, '.claude', 'skills', skill),
        isGlobal
          ? path.join(baseUser, '.agents', 'skills', skill)
          : path.join(baseLocal, '.agents', 'skills', skill),
      ];
    case 'opencode':
      return [
        isGlobal
          ? path.join(baseUser, '.opencode', 'skills', skill)
          : path.join(baseLocal, '.opencode', 'skills', skill),
        isGlobal
          ? path.join(baseUser, '.agents', 'skills', skill)
          : path.join(baseLocal, '.agents', 'skills', skill),
      ];
    case 'antigravity':
      return [
        isGlobal
          ? path.join(baseUser, '.gemini', 'antigravity-cli', 'skills', skill)
          : path.join(baseLocal, '.gemini', 'skills', skill),
        isGlobal
          ? path.join(baseUser, '.agents', 'skills', skill)
          : path.join(baseLocal, '.agents', 'skills', skill),
      ];
    case 'cursor':
      return [
        isGlobal
          ? path.join(baseUser, '.cursor', 'rules')
          : path.join(baseLocal, '.cursor', 'rules'),
      ];
    case 'windsurf':
      return [
        isGlobal
          ? path.join(baseUser, '.codeium', 'windsurf', 'memories')
          : path.join(baseLocal, '.windsurf', 'rules'),
      ];
    case 'roo':
      return [
        isGlobal
          ? path.join(baseUser, '.roo', 'skills', skill)
          : path.join(baseLocal, '.roo', 'skills', skill),
      ];
    default:
      return [];
  }
}

let successCount = 0;
let errorCount = 0;

for (const skill of skillsToInstall) {
  const skillSrcDir = path.join(sourceDir, skill);
  console.log(`${c.cyan}>> Processing skill: ${c.bold}${skill}${c.reset}`);

  for (const cli of selectedClis) {
    const rawPaths = getTargetDirs(cli, scope, skill);
    const uniquePaths = [...new Set(rawPaths)];

    for (const dest of uniquePaths) {
      try {
        if (doUninstall) {
          if (cli === 'cursor') {
            const ruleFile = path.join(dest, `${skill}.mdc`);
            if (fs.existsSync(ruleFile)) {
              fs.unlinkSync(ruleFile);
              console.log(`   ${c.yellow}[-] Removed Cursor rule: ${ruleFile}${c.reset}`);
              successCount++;
            }
          } else if (cli === 'windsurf') {
            const ruleFile = path.join(dest, `${skill}.md`);
            if (fs.existsSync(ruleFile)) {
              fs.unlinkSync(ruleFile);
              console.log(`   ${c.yellow}[-] Removed Windsurf rule: ${ruleFile}${c.reset}`);
              successCount++;
            }
          } else {
            if (fs.existsSync(dest)) {
              fs.rmSync(dest, { recursive: true, force: true });
              console.log(`   ${c.yellow}[-] Removed skill directory: ${dest} (${cli})${c.reset}`);
              successCount++;
            }
          }
        } else {
          // Install
          if (cli === 'cursor') {
            fs.mkdirSync(dest, { recursive: true });
            const ruleFile = path.join(dest, `${skill}.mdc`);
            const skillMd = path.join(skillSrcDir, 'SKILL.md');
            const content = fs.existsSync(skillMd) ? fs.readFileSync(skillMd, 'utf8') : '';
            const mdc = `---\ndescription: ${skill} AI Agent Skill by @alexlivre\nglobs: *\nalwaysApply: false\n---\n\n${content}`;
            fs.writeFileSync(ruleFile, mdc, 'utf8');
            console.log(`   ${c.green}[+] Installed Cursor Rule:${c.reset} ${ruleFile}`);
            successCount++;
          } else if (cli === 'windsurf') {
            fs.mkdirSync(dest, { recursive: true });
            const ruleFile = path.join(dest, `${skill}.md`);
            const skillMd = path.join(skillSrcDir, 'SKILL.md');
            if (fs.existsSync(skillMd)) {
              fs.copyFileSync(skillMd, ruleFile);
              console.log(`   ${c.green}[+] Installed Windsurf Rule:${c.reset} ${ruleFile}`);
              successCount++;
            }
          } else {
            fs.mkdirSync(dest, { recursive: true });
            fs.cpSync(skillSrcDir, dest, { recursive: true });
            console.log(`   ${c.green}[+] Installed for ${cli} ->${c.reset} ${dest}`);
            successCount++;
          }
        }
      } catch (err) {
        console.error(`   ${c.red}[!] Error on ${dest} (${cli}): ${err.message}${c.reset}`);
        errorCount++;
      }
    }
  }
}

console.log(`\n${c.cyan}=========================================================${c.reset}`);
if (doUninstall) {
  console.log(`${c.green}${c.bold}Uninstall completed! (${successCount} locations updated, ${errorCount} errors)${c.reset}`);
} else {
  console.log(`${c.green}${c.bold}Installation completed successfully! (${successCount} locations configured, ${errorCount} errors)${c.reset}\n`);
  console.log(`${c.bold}How to verify and use:${c.reset}`);
  console.log(`  * ${c.cyan}Claude Code:${c.reset} Run 'claude' - active automatically from ~/.claude/skills and ~/.agents/skills.`);
  console.log(`  * ${c.cyan}OpenCode:${c.reset} Run 'opencode' - detected from ~/.opencode/skills and ~/.agents/skills.`);
  console.log(`  * ${c.cyan}Antigravity CLI:${c.reset} Run 'agy' - detected from ~/.gemini/antigravity-cli/skills/ and ~/.agents/skills/.`);
  console.log(`  * ${c.cyan}Cursor:${c.reset} Rules active via .cursor/rules/.`);
  console.log(`  * ${c.cyan}Vibe Coding:${c.reset} Prompt: "Audit and optimize this website to 100/100 PageSpeed using the alexlivre skill"`);
}
console.log(`${c.cyan}=========================================================${c.reset}\n`);
