<#
.SYNOPSIS
    Universal Installer for Alex Santos (@alexlivre) AI Agent Skills.
    Supports Windows (PowerShell 5.1+ / PowerShell 7+).

.DESCRIPTION
    Installs skills to major AI coding agents & vibe-coding CLIs:
    - Universal Agent Skills specification (~/.agents/skills/)
    - Claude Code (~/.claude/skills/ and ~/.agents/skills/)
    - OpenCode (~/.opencode/skills/ and ~/.agents/skills/)
    - Antigravity CLI (~/.gemini/antigravity-cli/skills/)
    - Cursor (.cursor/rules/)
    - Roo Code / Cline (~/.roo/skills/)
    - Windsurf (.windsurfrules / memories)

.PARAMETER Global
    Install globally in user profile directories (default: $true).

.PARAMETER Project
    Install locally in the current working directory / project.

.PARAMETER Cli
    Target CLI or assistant: 'all' (default), 'agents', 'claude', 'opencode', 'antigravity', 'cursor', 'windsurf', 'roo'.

.PARAMETER Skill
    Specific skill name to install (default: 'all' to install all discovered skills).

.PARAMETER Uninstall
    Removes the specified skill(s) from target CLIs.

.PARAMETER List
    Lists available skills in this repository and supported CLIs.

.EXAMPLE
    # One-liner remote installation from GitHub
    irm https://raw.githubusercontent.com/alexlivre/skills-alexlivre/main/install.ps1 | iex

.EXAMPLE
    # Local install to all global CLIs
    .\install.ps1

.EXAMPLE
    # Local install to current project for Claude Code and OpenCode
    .\install.ps1 -Project -Cli claude,opencode
#>

[CmdletBinding()]
param(
    [switch]$Global = $true,
    [switch]$Project = $false,
    [string[]]$Cli = @("all"),
    [string[]]$Skill = @("all"),
    [switch]$Uninstall = $false,
    [switch]$List = $false,
    [switch]$Help = $false
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/alexlivre/skills-alexlivre"
$ZipUrl  = "https://github.com/alexlivre/skills-alexlivre/archive/refs/heads/main.zip"

function Show-Banner {
    Write-Host ""
    Write-Host " ========================================================= " -ForegroundColor Cyan
    Write-Host "   Alex Santos (@alexlivre) - AI Agent Skills Installer    " -ForegroundColor Green
    Write-Host " ========================================================= " -ForegroundColor Cyan
    Write-Host "   Repo: $RepoUrl" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-HelpMessage {
    Show-Banner
    Write-Host "Usage: .\install.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Global              Install globally to user profile directories (default)"
    Write-Host "  -Project             Install to current project directory instead of global"
    Write-Host "  -Cli <names>         Target CLIs comma-separated (all, agents, claude, opencode, antigravity, cursor, windsurf, roo)"
    Write-Host "  -Skill <names>       Target skill name(s) (default: all)"
    Write-Host "  -Uninstall           Remove specified skill(s) from targets"
    Write-Host "  -List                List available skills and supported CLIs"
    Write-Host "  -Help                Show this help message"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  irm https://raw.githubusercontent.com/alexlivre/skills-alexlivre/main/install.ps1 | iex" -ForegroundColor DarkCyan
    Write-Host "  .\install.ps1 -Project" -ForegroundColor DarkCyan
    Write-Host "  .\install.ps1 -Cli claude,antigravity -Skill pagespeed-optimizer-alexlivre" -ForegroundColor DarkCyan
    Write-Host ""
}

if ($Help) {
    Show-HelpMessage
    exit 0
}

# Resolve target mode
$InstallScope = "global"
if ($Project) {
    $InstallScope = "project"
}

# Determine source directory
$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    $ScriptDir = Get-Location
}

$IsLocalRepo = $false
$SkillsSourceDir = $ScriptDir

# Check if current directory or script directory has skills
$DetectedSkills = @()
if (Test-Path $ScriptDir) {
    $PotentialSkills = Get-ChildItem -Path $ScriptDir -Directory | Where-Object {
        Test-Path (Join-Path $_.FullName "SKILL.md")
    }
    if ($PotentialSkills.Count -gt 0) {
        $IsLocalRepo = $true
        $DetectedSkills = $PotentialSkills
    }
}

$TempDir = $null

if (-not $IsLocalRepo) {
    Write-Host " [i] Remote / Standalone mode detected. Fetching latest skills from GitHub..." -ForegroundColor Cyan
    $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("skills-alexlivre-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    $ZipPath = Join-Path $TempDir "repo.zip"

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13
        Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
        Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force
        
        $ExtractedRoot = Join-Path $TempDir "skills-alexlivre-main"
        if (Test-Path $ExtractedRoot) {
            $SkillsSourceDir = $ExtractedRoot
        } else {
            $SkillsSourceDir = $TempDir
        }

        $DetectedSkills = Get-ChildItem -Path $SkillsSourceDir -Directory | Where-Object {
            Test-Path (Join-Path $_.FullName "SKILL.md")
        }
    }
    catch {
        Write-Error "Failed to download repository: $_"
        if ($TempDir -and (Test-Path $TempDir)) {
            Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
        }
        exit 1
    }
}

if ($List) {
    Show-Banner
    Write-Host "Discovered Skills in Repository:" -ForegroundColor Green
    foreach ($sk in $DetectedSkills) {
        $skillMd = Join-Path $sk.FullName "SKILL.md"
        $desc = "AI Agent Skill"
        if (Test-Path $skillMd) {
            $content = Get-Content $skillMd -Raw
            if ($content -match "description:\s*(.+)") {
                $desc = $matches[1].Trim()
                if ($desc.Length -gt 80) { $desc = $desc.Substring(0, 77) + "..." }
            }
        }
        Write-Host "  - $($sk.Name)" -ForegroundColor Yellow -NoNewline
        Write-Host " : $desc" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "Supported CLIs and Vibe Coding Tools:" -ForegroundColor Green
    Write-Host "  - agents       Universal Agent Skills specification (~/.agents/skills/)"
    Write-Host "  - claude       Claude Code (~/.claude/skills/ and ~/.agents/skills/)"
    Write-Host "  - opencode     OpenCode (~/.opencode/skills/ and ~/.agents/skills/)"
    Write-Host "  - antigravity  Antigravity CLI (~/.gemini/antigravity-cli/skills/)"
    Write-Host "  - cursor       Cursor (.cursor/rules/*.mdc)"
    Write-Host "  - windsurf     Windsurf (.windsurfrules / memories)"
    Write-Host "  - roo          Roo Code / Cline (~/.roo/skills/)"
    Write-Host "  - all          All supported tools simultaneously (default)"
    Write-Host ""
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    }
    exit 0
}

# Flatten and trim CLI argument list
$FlattenedClis = @()
foreach ($c in $Cli) {
    if ($c -match ",") {
        $FlattenedClis += $c.Split(",") | ForEach-Object { $_.Trim().ToLower() }
    } else {
        $FlattenedClis += $c.Trim().ToLower()
    }
}

# Flatten and trim Skill argument list
$FlattenedSkills = @()
foreach ($s in $Skill) {
    if ($s -match ",") {
        $FlattenedSkills += $s.Split(",") | ForEach-Object { $_.Trim() }
    } else {
        $FlattenedSkills += $s.Trim()
    }
}

# Filter skills to install
$SkillsToInstall = @()
if ($FlattenedSkills -contains "all") {
    $SkillsToInstall = $DetectedSkills
} else {
    foreach ($sName in $FlattenedSkills) {
        $matched = $DetectedSkills | Where-Object { $_.Name -eq $sName }
        if ($matched) {
            $SkillsToInstall += $matched
        } else {
            Write-Warning "Skill '$sName' not found in repository. Skipping."
        }
    }
}

if ($SkillsToInstall.Count -eq 0) {
    Write-Error "No matching skills found to install."
    if ($TempDir -and (Test-Path $TempDir)) {
        Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    }
    exit 1
}

# Define target paths resolver
function Get-TargetDirectories {
    param(
        [string]$CliName,
        [string]$Scope,
        [string]$SkillName
    )

    $UserHome = [System.Environment]::GetFolderPath("UserProfile")
    $CurrentDir = Get-Location

    $paths = @()

    switch ($CliName.ToLower()) {
        "agents" {
            if ($Scope -eq "global") {
                $paths += (Join-Path $UserHome ".agents\skills\$SkillName")
            } else {
                $paths += (Join-Path $CurrentDir ".agents\skills\$SkillName")
            }
        }
        "claude" {
            if ($Scope -eq "global") {
                $paths += (Join-Path $UserHome ".claude\skills\$SkillName")
                $paths += (Join-Path $UserHome ".agents\skills\$SkillName")
            } else {
                $paths += (Join-Path $CurrentDir ".claude\skills\$SkillName")
                $paths += (Join-Path $CurrentDir ".agents\skills\$SkillName")
            }
        }
        "opencode" {
            if ($Scope -eq "global") {
                $paths += (Join-Path $UserHome ".opencode\skills\$SkillName")
                $paths += (Join-Path $UserHome ".agents\skills\$SkillName")
            } else {
                $paths += (Join-Path $CurrentDir ".opencode\skills\$SkillName")
                $paths += (Join-Path $CurrentDir ".agents\skills\$SkillName")
            }
        }
        "antigravity" {
            if ($Scope -eq "global") {
                $paths += (Join-Path $UserHome ".gemini\antigravity-cli\skills\$SkillName")
                $paths += (Join-Path $UserHome ".agents\skills\$SkillName")
            } else {
                $paths += (Join-Path $CurrentDir ".gemini\skills\$SkillName")
                $paths += (Join-Path $CurrentDir ".agents\skills\$SkillName")
            }
        }
        "roo" {
            if ($Scope -eq "global") {
                $paths += (Join-Path $UserHome ".roo\skills\$SkillName")
            } else {
                $paths += (Join-Path $CurrentDir ".roo\skills\$SkillName")
            }
        }
        "cursor" {
            # Cursor rules are handled separately
            if ($Scope -eq "global") {
                $paths += (Join-Path $UserHome ".cursor\rules")
            } else {
                $paths += (Join-Path $CurrentDir ".cursor\rules")
            }
        }
        "windsurf" {
            # Windsurf rules
            if ($Scope -eq "global") {
                $paths += (Join-Path $UserHome ".codeium\windsurf\memories")
            } else {
                $paths += (Join-Path $CurrentDir ".windsurf\rules")
            }
        }
    }

    return $paths | Select-Object -Unique
}

# Resolve list of CLIs
$SelectedClis = @()
$AllSupportedClis = @("agents", "claude", "opencode", "antigravity", "cursor", "windsurf", "roo")

if ($FlattenedClis -contains "all") {
    $SelectedClis = $AllSupportedClis
} else {
    foreach ($c in $FlattenedClis) {
        if ($AllSupportedClis -contains $c) {
            $SelectedClis += $c
        } else {
            Write-Warning "Unknown CLI '$c'. Skipping."
        }
    }
}

Show-Banner
Write-Host " Scope: " -NoNewline; Write-Host $InstallScope.ToUpper() -ForegroundColor Yellow
Write-Host " Selected CLIs: " -NoNewline; Write-Host ($SelectedClis -join ", ") -ForegroundColor Cyan
Write-Host " Skills to process: " -NoNewline; Write-Host (($SkillsToInstall | ForEach-Object { $_.Name }) -join ", ") -ForegroundColor Green
Write-Host ""

$SuccessCount = 0
$FailedCount = 0

foreach ($skillDir in $SkillsToInstall) {
    $skillName = $skillDir.Name
    Write-Host ">> Processing skill: $skillName" -ForegroundColor Cyan

    foreach ($cliName in $SelectedClis) {
        $targetPaths = Get-TargetDirectories -CliName $cliName -Scope $InstallScope -SkillName $skillName

        foreach ($dest in $targetPaths) {
            try {
                if ($Uninstall) {
                    if (Test-Path $dest) {
                        Remove-Item -Path $dest -Recurse -Force
                        Write-Host "   [-] Uninstalled from: $dest ($cliName)" -ForegroundColor DarkYellow
                        $SuccessCount++
                    }
                } else {
                    if ($cliName -eq "cursor") {
                        # Create Cursor .mdc rule
                        if (-not (Test-Path $dest)) {
                            New-Item -ItemType Directory -Path $dest -Force | Out-Null
                        }
                        $ruleFile = Join-Path $dest "$skillName.mdc"
                        $skillMdPath = Join-Path $skillDir.FullName "SKILL.md"
                        $skillContent = ""
                        if (Test-Path $skillMdPath) {
                            $skillContent = Get-Content $skillMdPath -Raw
                        }
                        $mdcContent = "---`ndescription: $skillName AI Agent Skill by @alexlivre`nglobs: *`nalwaysApply: false`n---`n`n$skillContent"
                        Set-Content -Path $ruleFile -Value $mdcContent -Encoding UTF8
                        Write-Host "   [+] Installed Cursor Rule: $ruleFile" -ForegroundColor Green
                        $SuccessCount++
                    }
                    elseif ($cliName -eq "windsurf") {
                        if (-not (Test-Path $dest)) {
                            New-Item -ItemType Directory -Path $dest -Force | Out-Null
                        }
                        $ruleFile = Join-Path $dest "$skillName.md"
                        $skillMdPath = Join-Path $skillDir.FullName "SKILL.md"
                        if (Test-Path $skillMdPath) {
                            Copy-Item -Path $skillMdPath -Destination $ruleFile -Force
                        }
                        Write-Host "   [+] Installed Windsurf Rule: $ruleFile" -ForegroundColor Green
                        $SuccessCount++
                    }
                    else {
                        # Standard skill directory copy
                        if (-not (Test-Path $dest)) {
                            New-Item -ItemType Directory -Path $dest -Force | Out-Null
                        }
                        Copy-Item -Path (Join-Path $skillDir.FullName "*") -Destination $dest -Recurse -Force
                        Write-Host "   [+] Installed for $cliName -> $dest" -ForegroundColor Green
                        $SuccessCount++
                    }
                }
            }
            catch {
                Write-Host "   [!] Error processing $dest for $cliName : $_" -ForegroundColor Red
                $FailedCount++
            }
        }
    }
}

if ($TempDir -and (Test-Path $TempDir)) {
    Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
if ($Uninstall) {
    Write-Host " Uninstall completed! ($SuccessCount locations updated, $FailedCount errors)" -ForegroundColor Green
} else {
    Write-Host " Installation completed successfully! ($SuccessCount locations configured, $FailedCount errors)" -ForegroundColor Green
    Write-Host ""
    Write-Host " How to verify/use:" -ForegroundColor White
    Write-Host "   * Claude Code: Run 'claude' - skills in ~/.claude/skills and ~/.agents/skills are active automatically."
    Write-Host "   * OpenCode: Run 'opencode' - detected from ~/.opencode/skills and ~/.agents/skills."
    Write-Host "   * Antigravity CLI: Run 'agy' - detected from ~/.gemini/antigravity-cli/skills/ and ~/.agents/skills/."
    Write-Host "   * Cursor: Automatically available in Cursor AI via .cursor/rules/."
    Write-Host "   * Vibe Coding: Ask your agent: 'Audit and optimize this site to 100/100 PageSpeed using the alexlivre skill'"
}
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""
