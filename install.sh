#!/usr/bin/env bash
# ==============================================================================
# Alex Santos (@alexlivre) - AI Agent Skills Universal Installer
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
TARBALL_URL="https://github.com/alexlivre/skills-alexlivre/archive/refs/heads/main.tar.gz"

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
  echo -e "${GREEN}${BOLD}   Alex Santos (@alexlivre) - AI Agent Skills Installer   ${NC}"
  echo -e "${CYAN}=========================================================${NC}"
  echo -e "   Repository: ${BLUE}${REPO_URL}${NC}"
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
  echo -e "  -s, --skill <name> Specific skill to install (default: all discovered)"
  echo -e "  -u, --uninstall    Uninstall specified skill(s) from target CLIs"
  echo -e "  -l, --list         List available skills and supported CLIs"
  echo -e "  -h, --help         Show this help message"
  echo -e ""
  echo -e "${BOLD}Examples:${NC}"
  echo -e "  curl -fsSL https://raw.githubusercontent.com/alexlivre/skills-alexlivre/main/install.sh | bash"
  echo -e "  ./install.sh --project --cli claude,opencode"
  echo -e "  ./install.sh --skill pagespeed-optimizer-alexlivre"
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

# Detect if running from local repo or standalone/piped
IS_LOCAL=0
SOURCE_DIR="$SCRIPT_DIR"

if ls "$SCRIPT_DIR"/*/SKILL.md >/dev/null 2>&1; then
  IS_LOCAL=1
fi

if [[ $IS_LOCAL -eq 0 ]]; then
  echo -e "${CYAN}[i] Fetching latest skills from GitHub...${NC}"
  TEMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'skills-alexlivre')"
  
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$TARBALL_URL" | tar -xz -C "$TEMP_DIR"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$TARBALL_URL" | tar -xz -C "$TEMP_DIR"
  elif command -v git >/dev/null 2>&1; then
    git clone --depth 1 "$REPO_URL.git" "$TEMP_DIR/skills-alexlivre-main"
  else
    echo -e "${RED}Error: curl, wget, or git required to download skills.${NC}"
    exit 1
  fi

  EXTRACTED_DIR="$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  SOURCE_DIR="${EXTRACTED_DIR:-$TEMP_DIR}"
fi

# Discover skills in source directory
DISCOVERED_SKILLS=()
for dir in "$SOURCE_DIR"/*/; do
  if [[ -f "${dir}SKILL.md" ]]; then
    skill_name="$(basename "$dir")"
    DISCOVERED_SKILLS+=("$skill_name")
  fi
done

if [[ ${#DISCOVERED_SKILLS[@]} -eq 0 ]]; then
  echo -e "${RED}Error: No skills found with a valid SKILL.md.${NC}"
  exit 1
fi

if [[ $DO_LIST -eq 1 ]]; then
  show_banner
  echo -e "${GREEN}${BOLD}Discovered Skills in Repository:${NC}"
  for sk in "${DISCOVERED_SKILLS[@]}"; do
    skill_md="$SOURCE_DIR/$sk/SKILL.md"
    desc="AI Agent Skill"
    if [[ -f "$skill_md" ]]; then
      extracted_desc="$(grep -m 1 '^description:' "$skill_md" | sed 's/^description:[[:space:]]*//' || true)"
      if [[ -n "$extracted_desc" ]]; then
        desc="${extracted_desc:0:80}"
      fi
    fi
    echo -e "  - ${YELLOW}${BOLD}$sk${NC} : $desc"
  done
  echo -e ""
  echo -e "${GREEN}${BOLD}Supported CLIs & Vibe Coding Tools:${NC}"
  echo -e "  - agents       Universal Agent Skills specification (~/.agents/skills/)"
  echo -e "  - claude       Claude Code (~/.claude/skills/ and ~/.agents/skills/)"
  echo -e "  - opencode     OpenCode (~/.opencode/skills/ and ~/.agents/skills/)"
  echo -e "  - antigravity  Antigravity CLI (~/.gemini/antigravity-cli/skills/)"
  echo -e "  - cursor       Cursor (.cursor/rules/*.mdc)"
  echo -e "  - windsurf     Windsurf (.windsurf/rules/ and ~/.codeium/windsurf/memories/)"
  echo -e "  - roo          Roo Code / Cline (~/.roo/skills/)"
  echo -e "  - all          Install to all supported tools simultaneously (default)"
  echo -e ""
  exit 0
fi

# Filter skills to install
SKILLS_TO_INSTALL=()
if [[ "$TARGET_SKILL" == "all" ]]; then
  SKILLS_TO_INSTALL=("${DISCOVERED_SKILLS[@]}")
else
  IFS=',' read -ra REQ_SKILLS <<< "$TARGET_SKILL"
  for req in "${REQ_SKILLS[@]}"; do
    req="$(echo "$req" | xargs)"
    found=0
    for disc in "${DISCOVERED_SKILLS[@]}"; do
      if [[ "$disc" == "$req" ]]; then
        SKILLS_TO_INSTALL+=("$disc")
        found=1
        break
      fi
    done
    if [[ $found -eq 0 ]]; then
      echo -e "${YELLOW}Warning: Skill '$req' not found in repository. Skipping.${NC}"
    fi
  done
fi

if [[ ${#SKILLS_TO_INSTALL[@]} -eq 0 ]]; then
  echo -e "${RED}Error: No matching skills found to install.${NC}"
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
  skill_src="$SOURCE_DIR/$skill"
  echo -e "${CYAN}>> Processing skill: ${BOLD}$skill${NC}"

  for cli in "${SELECTED_CLIS[@]}"; do
    mapfile -t TARGET_PATHS < <(get_target_dirs "$cli" "$SCOPE" "$skill" | sort -u)

    for dest in "${TARGET_PATHS[@]}"; do
      if [[ -z "$dest" ]]; then continue; fi

      if [[ $DO_UNINSTALL -eq 1 ]]; then
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
      else
        # Install
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
          # Standard Skill Directory
          mkdir -p "$dest"
          cp -R "$skill_src"/* "$dest/"
          echo -e "   ${GREEN}[+] Installed for $cli ->${NC} $dest"
          SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        fi
      fi
    done
  done
done

echo -e ""
echo -e "${CYAN}=========================================================${NC}"
if [[ $DO_UNINSTALL -eq 1 ]]; then
  echo -e "${GREEN}${BOLD}Uninstall completed! ($SUCCESS_COUNT locations updated, $FAILED_COUNT errors)${NC}"
else
  echo -e "${GREEN}${BOLD}Installation completed successfully! ($SUCCESS_COUNT locations configured, $FAILED_COUNT errors)${NC}"
  echo -e ""
  echo -e "${BOLD}How to verify and use:${NC}"
  echo -e "  * ${CYAN}Claude Code:${NC} Start 'claude' - skills in ~/.claude/skills and ~/.agents/skills are active automatically."
  echo -e "  * ${CYAN}OpenCode:${NC} Start 'opencode' - detected from ~/.opencode/skills and ~/.agents/skills."
  echo -e "  * ${CYAN}Antigravity CLI:${NC} Start 'agy' - detected from ~/.gemini/antigravity-cli/skills/ and ~/.agents/skills/."
  echo -e "  * ${CYAN}Cursor:${NC} Rules are loaded from .cursor/rules/ in your workspace."
  echo -e "  * ${CYAN}Vibe Coding:${NC} Prompt your agent: 'Audit and optimize this app to 100/100 PageSpeed using the alexlivre skill'"
fi
echo -e "${CYAN}=========================================================${NC}"
echo -e ""
