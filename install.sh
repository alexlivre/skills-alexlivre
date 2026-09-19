#!/usr/bin/env bash
# ==============================================================================
# Alex Santos (@alexlivre) - AI Agent Skills Hub Universal Installer
# Compatible with Linux, macOS, WSL, and Git Bash
# ==============================================================================
# Installs skills to:
#   - Universal Agent Skills (~/.agents/skills/)
#   - Claude Code (~/.claude/skills/ and ~/.agents/skills/)
#   - OpenCode (~/.opencode/skills/ and ~/.agents/skills/)
#   - Antigravity CLI (~/.gemini/antigravity-cli/skills/)
#   - Cursor (.cursor/rules/)
#   - Windsurf (.windsurf/rules/ and ~/.codeium/windsurf/memories/)
#   - Roo Code / Cline (~/.roo/skills/)
# ==============================================================================

set -eo pipefail

REPO_URL="https://github.com/alexlivre/skills-alexlivre"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

show_banner() {
  echo -e ""
  echo -e "${CYAN}=========================================================${NC}"
  echo -e "${GREEN}${BOLD}   Alex Santos (@alexlivre) - AI Agent Skills Hub         ${NC}"
  echo -e "${CYAN}=========================================================${NC}"
  echo -e "   Central Hub: ${BLUE}${REPO_URL}${NC}"
  echo -e ""
}

show_help() {
  show_banner
  echo -e "${BOLD}Usage:${NC} $0 [options]"
  echo -e ""
  echo -e "${BOLD}Options:${NC}"
  echo -e "  -g, --global       Install globally in user home directories (default)"
  echo -e "  -p, --project      Install locally in current project directory"
  echo -e "  -c, --cli <name>   Target CLI (all, agents, claude, opencode, antigravity, cursor, windsurf, roo)"
  echo -e "  -s, --skill <name> Specific skill to install (default: all registered)"
  echo -e "  -u, --uninstall    Uninstall specified skill(s) from target CLIs"
  echo -e "  -l, --list         List available skills and supported CLIs"
  echo -e "  -h, --help         Show this help message"
  echo -e ""
  echo -e "${BOLD}Examples:${NC}"
  echo -e "  ./install.sh -l"
  echo -e "  ./install.sh -s pagespeed-optimizer-alexlivre"
  echo -e "  ./install.sh -p -c claude,opencode -s pagespeed-optimizer-alexlivre"
  echo -e ""
}

# Defaults
SCOPE="global"
TARGET_CLI="all"
TARGET_SKILL="all"
DO_UNINSTALL=0
DO_LIST=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--global)
      SCOPE="global"
      shift
      ;;
    -p|--project|--local)
      SCOPE="project"
      shift
      ;;
    -c|--cli)
      TARGET_CLI="$2"
      shift 2
      ;;
    -s|--skill)
      TARGET_SKILL="$2"
      shift 2
      ;;
    -u|--uninstall)
      DO_UNINSTALL=1
      shift
      ;;
    -l|--list)
      DO_LIST=1
      shift
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      show_help
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || pwd)"
TEMP_DIR=""

cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

# Default catalog skills
declare -A SKILL_REPOS
declare -A SKILL_DESCS
declare -A SKILL_CATS
declare -A SKILL_CMDS

# Register pagespeed-optimizer-alexlivre
SKILL_REPOS["pagespeed-optimizer-alexlivre"]="https://github.com/alexlivre/pagespeed-optimizer-alexlivre"
SKILL_DESCS["pagespeed-optimizer-alexlivre"]="Universal AI agent skill to optimize web applications to 100/100 on PageSpeed Insights & Lighthouse 13+."
SKILL_CATS["pagespeed-optimizer-alexlivre"]="Performance & SEO"
SKILL_CMDS["pagespeed-optimizer-alexlivre"]="npx skills add alexlivre/pagespeed-optimizer-alexlivre -g -y"

# If registry.json exists and node is available, enrich metadata (or fetch remotely if running via curl one-liner)
REGISTRY_FILE="$SCRIPT_DIR/registry.json"
CATALOG_SKILLS=("pagespeed-optimizer-alexlivre")

if [[ ! -f "$REGISTRY_FILE" ]]; then
  REMOTE_REG_URL="https://raw.githubusercontent.com/alexlivre/skills-alexlivre/main/registry.json"
  TEMP_REG="$(mktemp 2>/dev/null || mktemp -t "registry.json")"
  if curl -fsSL "$REMOTE_REG_URL" -o "$TEMP_REG" 2>/dev/null; then
    REGISTRY_FILE="$TEMP_REG"
  fi
fi

if [[ -f "$REGISTRY_FILE" && -x "$(command -v node 2>/dev/null)" ]]; then
  EXTRACTED_NAMES="$(node -e "
    try {
      const r = JSON.parse(require('fs').readFileSync('$REGISTRY_FILE', 'utf8'));
      if (Array.isArray(r.skills)) {
        console.log(r.skills.map(s => s.name).join(' '));
      }
    } catch {}
  " 2>/dev/null || true)"
  if [[ -n "$EXTRACTED_NAMES" ]]; then
    read -ra CATALOG_SKILLS <<< "$EXTRACTED_NAMES"
  fi
fi

if [[ $DO_LIST -eq 1 ]]; then
  show_banner
  echo -e "${GREEN}${BOLD}Centralized Skills in Ecosystem:${NC}\n"
  for sk in "${CATALOG_SKILLS[@]}"; do
    cat_tag="${SKILL_CATS[$sk]:-AI Agent Skill}"
    desc="${SKILL_DESCS[$sk]:-Universal AI Agent Skill by @alexlivre}"
    repo="${SKILL_REPOS[$sk]:-https://github.com/alexlivre/$sk}"
    cmd="${SKILL_CMDS[$sk]:-npx skills add alexlivre/$sk -g -y}"
    echo -e "  - ${YELLOW}${BOLD}$sk${NC} [${CYAN}$cat_tag${NC}]"
    echo -e "    ${desc}"
    echo -e "    Repository : ${CYAN}$repo${NC}"
    echo -e "    Quick Add  : ${GREEN}$cmd${NC}\n"
  done
  echo -e "${GREEN}${BOLD}Supported CLIs & Vibe Coding Tools:${NC}"
  echo -e "  - agents       Universal Agent Skills specification (~/.agents/skills/)"
  echo -e "  - claude       Claude Code (~/.claude/skills/ and ~/.agents/skills/)"
  echo -e "  - opencode     OpenCode (~/.opencode/skills/ and ~/.agents/skills/)"
  echo -e "  - antigravity  Antigravity CLI (~/.gemini/antigravity-cli/skills/)"
  echo -e "  - cursor       Cursor (.cursor/rules/*.mdc)"
  echo -e "  - windsurf     Windsurf (.windsurf/rules/ and ~/.codeium/windsurf/memories/)"
  echo -e "  - roo          Roo Code / Cline (~/.roo/skills/)"
  echo -e "  - all          Install to all supported tools simultaneously (default)\n"
  exit 0
fi

# Filter skills to install
SKILLS_TO_INSTALL=()
if [[ "$TARGET_SKILL" == "all" ]]; then
  SKILLS_TO_INSTALL=("${CATALOG_SKILLS[@]}")
else
  IFS=',' read -ra REQ_SKILLS <<< "$TARGET_SKILL"
  for req in "${REQ_SKILLS[@]}"; do
    req="$(echo "$req" | xargs)"
    found=0
    for cat_sk in "${CATALOG_SKILLS[@]}"; do
      if [[ "$cat_sk" == "$req" ]]; then
        SKILLS_TO_INSTALL+=("$cat_sk")
        found=1
        break
      fi
    done
    if [[ $found -eq 0 ]]; then
      echo -e "${YELLOW}Warning: Skill '$req' not found in registry. Skipping.${NC}"
    fi
  done
fi

if [[ ${#SKILLS_TO_INSTALL[@]} -eq 0 ]]; then
  echo -e "${RED}Error: No valid skills selected.${NC}"
  exit 1
fi

# Filter target CLIs
SUPPORTED_CLIS=("agents" "claude" "opencode" "antigravity" "cursor" "windsurf" "roo")
SELECTED_CLIS=()

if [[ "$TARGET_CLI" == "all" ]]; then
  SELECTED_CLIS=("${SUPPORTED_CLIS[@]}")
else
  IFS=',' read -ra REQ_CLIS <<< "$TARGET_CLI"
  for req in "${REQ_CLIS[@]}"; do
    req="$(echo "$req" | xargs | tr '[:upper:]' '[:lower:]')"
    found=0
    for supp in "${SUPPORTED_CLIS[@]}"; do
      if [[ "$supp" == "$req" ]]; then
        SELECTED_CLIS+=("$supp")
        found=1
        break
      fi
    done
    if [[ $found -eq 0 ]]; then
      echo -e "${YELLOW}Warning: Unknown CLI '$req'. Skipping.${NC}"
    fi
  done
fi

show_banner
echo -e " ${BOLD}Scope:${NC} ${YELLOW}$(echo "$SCOPE" | tr '[:lower:]' '[:upper:]')${NC}"
echo -e " ${BOLD}Selected CLIs:${NC} ${CYAN}${SELECTED_CLIS[*]}${NC}"
echo -e " ${BOLD}Skills:${NC} ${GREEN}${SKILLS_TO_INSTALL[*]}${NC}"
echo -e ""

USER_HOME="$HOME"
CURRENT_DIR="$(pwd)"
SUCCESS_COUNT=0
FAILED_COUNT=0

get_target_dirs() {
  local cli="$1"
  local scope="$2"
  local skill="$3"

  case "$cli" in
    agents)
      if [[ "$scope" == "global" ]]; then
        echo "$USER_HOME/.agents/skills/$skill"
      else
        echo "$CURRENT_DIR/.agents/skills/$skill"
      fi
      ;;
    claude)
      if [[ "$scope" == "global" ]]; then
        echo "$USER_HOME/.claude/skills/$skill"
        echo "$USER_HOME/.agents/skills/$skill"
      else
        echo "$CURRENT_DIR/.claude/skills/$skill"
        echo "$CURRENT_DIR/.agents/skills/$skill"
      fi
      ;;
    opencode)
      if [[ "$scope" == "global" ]]; then
        echo "$USER_HOME/.opencode/skills/$skill"
        echo "$USER_HOME/.agents/skills/$skill"
      else
        echo "$CURRENT_DIR/.opencode/skills/$skill"
        echo "$CURRENT_DIR/.agents/skills/$skill"
      fi
      ;;
    antigravity)
      if [[ "$scope" == "global" ]]; then
        echo "$USER_HOME/.gemini/antigravity-cli/skills/$skill"
        echo "$USER_HOME/.agents/skills/$skill"
      else
        echo "$CURRENT_DIR/.gemini/skills/$skill"
        echo "$CURRENT_DIR/.agents/skills/$skill"
      fi
      ;;
    cursor)
      if [[ "$scope" == "global" ]]; then
        echo "$USER_HOME/.cursor/rules"
      else
        echo "$CURRENT_DIR/.cursor/rules"
      fi
      ;;
    windsurf)
      if [[ "$scope" == "global" ]]; then
        echo "$USER_HOME/.codeium/windsurf/memories"
      else
        echo "$CURRENT_DIR/.windsurf/rules"
      fi
      ;;
    roo)
      if [[ "$scope" == "global" ]]; then
        echo "$USER_HOME/.roo/skills/$skill"
      else
        echo "$CURRENT_DIR/.roo/skills/$skill"
      fi
      ;;
  esac
}

for skill in "${SKILLS_TO_INSTALL[@]}"; do
  echo -e "${CYAN}>> Processing skill: ${BOLD}$skill${NC}"

  if [[ $DO_UNINSTALL -eq 1 ]]; then
    for cli in "${SELECTED_CLIS[@]}"; do
      mapfile -t TARGET_PATHS < <(get_target_dirs "$cli" "$SCOPE" "$skill" | sort -u)
      for dest in "${TARGET_PATHS[@]}"; do
        if [[ -z "$dest" ]]; then continue; fi
        if [[ "$cli" == "cursor" ]]; then
          target_file="$dest/$skill.mdc"
          if [[ -f "$target_file" ]]; then
            rm -f "$target_file"
            echo -e "   ${YELLOW}[-] Removed Cursor rule: $target_file${NC}"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
          fi
        elif [[ "$cli" == "windsurf" ]]; then
          target_file="$dest/$skill.md"
          if [[ -f "$target_file" ]]; then
            rm -f "$target_file"
            echo -e "   ${YELLOW}[-] Removed Windsurf rule: $target_file${NC}"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
          fi
        else
          if [[ -d "$dest" ]]; then
            rm -rf "$dest"
            echo -e "   ${YELLOW}[-] Removed skill directory: $dest ($cli)${NC}"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
          fi
        fi
      done
    done
    continue
  fi

  # Resolve source directory
  skill_src="$SCRIPT_DIR/$skill"
  if [[ ! -d "$skill_src" || ! -f "$skill_src/SKILL.md" ]]; then
    TEMP_SKILL_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t "skill-$skill")"
    repo_url="${SKILL_REPOS[$skill]:-https://github.com/alexlivre/$skill.git}"
    echo -e "   ${BLUE}[i] Fetching $skill from $repo_url...${NC}"
    if git clone --depth 1 "$repo_url" "$TEMP_SKILL_DIR" >/dev/null 2>&1; then
      skill_src="$TEMP_SKILL_DIR"
    else
      echo -e "   ${RED}[!] Failed to clone $repo_url${NC}"
      FAILED_COUNT=$((FAILED_COUNT + 1))
      rm -rf "$TEMP_SKILL_DIR"
      continue
    fi
  fi

  for cli in "${SELECTED_CLIS[@]}"; do
    mapfile -t TARGET_PATHS < <(get_target_dirs "$cli" "$SCOPE" "$skill" | sort -u)

    for dest in "${TARGET_PATHS[@]}"; do
      if [[ -z "$dest" ]]; then continue; fi
      if [[ "$cli" == "cursor" ]]; then
        mkdir -p "$dest"
        rule_file="$dest/$skill.mdc"
        skill_content=""
        if [[ -f "$skill_src/SKILL.md" ]]; then
          skill_content="$(cat "$skill_src/SKILL.md")"
        fi
        cat > "$rule_file" <<EOF
---
description: $skill AI Agent Skill by @alexlivre
globs: *
alwaysApply: false
---

$skill_content
EOF
        echo -e "   ${GREEN}[+] Installed Cursor Rule:${NC} $rule_file"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
      elif [[ "$cli" == "windsurf" ]]; then
        mkdir -p "$dest"
        rule_file="$dest/$skill.md"
        if [[ -f "$skill_src/SKILL.md" ]]; then
          cp -f "$skill_src/SKILL.md" "$rule_file"
          echo -e "   ${GREEN}[+] Installed Windsurf Rule:${NC} $rule_file"
          SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        fi
      else
        mkdir -p "$dest"
        cp -R "$skill_src/." "$dest/"
        echo -e "   ${GREEN}[+] Installed for $cli ->${NC} $dest"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
      fi
    done
  done
done

echo -e ""
echo -e "${CYAN}=========================================================${NC}"
if [[ $DO_UNINSTALL -eq 1 ]]; then
  echo -e "${GREEN}${BOLD}Uninstall completed! ($SUCCESS_COUNT locations updated, $FAILED_COUNT errors)${NC}"
else
  echo -e "${GREEN}${BOLD}Installation completed! ($SUCCESS_COUNT locations configured, $FAILED_COUNT errors)${NC}"
  echo -e ""
  echo -e "${BOLD}Direct package manager alternative:${NC}"
  echo -e "  ${CYAN}npx skills add alexlivre/pagespeed-optimizer-alexlivre -g -y${NC}"
fi
echo -e "${CYAN}=========================================================${NC}"
echo -e ""
