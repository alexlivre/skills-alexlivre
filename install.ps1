<#
.SYNOPSIS
    Universal Installer & Registry Query for Alex Santos (@alexlivre) AI Agent Skills.
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
    Lists available skills in this registry and supported CLIs.

.EXAMPLE
    # One-liner remote installation from GitHub
    irm https://raw.githubusercontent.com/alexlivre/skills-alexlivre/main/install.ps1 | iex

.EXAMPLE
    # Local install to all global CLIs
    .\install.ps1

.EXAMPLE
    # List skills in central catalog
    .\install.ps1 -List
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

function Show-Banner {
    Write-Host ""
    Write-Host " ========================================================= " -ForegroundColor Cyan
    Write-Host "   Alex Santos (@alexlivre) - AI Agent Skills Hub          " -ForegroundColor Green
    Write-Host " ========================================================= " -ForegroundColor Cyan
    Write-Host "   Central Hub: $RepoUrl" -ForegroundColor DarkGray
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
    Write-Host "  .\install.ps1 -List" -ForegroundColor DarkCyan
    Write-Host "  .\install.ps1 -Skill pagespeed-optimizer-alexlivre" -ForegroundColor DarkCyan
    Write-Host "  .\install.ps1 -Project -Cli claude,antigravity" -ForegroundColor DarkCyan
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

# Load registry.json if available
$RegistryFile = Join-Path $ScriptDir "registry.json"
$RegistrySkills = @()
if (Test-Path $RegistryFile) {
    try {
        $RegData = Get-Content $RegistryFile -Raw | ConvertFrom-Json
        if ($RegData.skills) {
            $RegistrySkills = $RegData.skills
        }
    } catch {
        Write-Warning "Could not parse registry.json: $_"
    }
}

# Check for local skill directories
$DetectedSkills = @()
if (Test-Path $ScriptDir) {
    $PotentialSkills = Get-ChildItem -Path $ScriptDir -Directory | Where-Object {
        Test-Path (Join-Path $_.FullName "SKILL.md")
    }
    foreach ($ps in $PotentialSkills) {
        $DetectedSkills += [PSCustomObject]@{
            Name           = $ps.Name
            Description    = "Local AI Agent Skill"
            LocalPath      = $ps.FullName
            Repo           = $null
            InstallCommand = "npx skills add alexlivre/$($ps.Name) -g -y"
            Category       = "Local"
            ZipUrl         = $null
            GitUrl         = $null
        }
    }
}

# Merge registry skills
foreach ($reg in $RegistrySkills) {
    $existing = $DetectedSkills | Where-Object { $_.Name -eq $reg.name }
    if (-not $existing) {
        $DetectedSkills += [PSCustomObject]@{
            Name           = $reg.name
            Description    = $reg.description
            LocalPath      = $null
            Repo           = $reg.repo
            InstallCommand = $reg.installCommand
            Category       = $reg.category
            ZipUrl         = $reg.zipUrl
            GitUrl         = $reg.gitUrl
        }
    }
}

if ($DetectedSkills.Count -eq 0) {
    Write-Error "No skills found in registry or local directory."
    exit 1
}

if ($List) {
    Show-Banner
    Write-Host "Centralized Skills in Ecosystem:" -ForegroundColor Green
    Write-Host ""
    foreach ($sk in $DetectedSkills) {
        Write-Host "  - $($sk.Name)" -ForegroundColor Yellow -NoNewline
        if ($sk.Category) {
            Write-Host " [$($sk.Category)]" -ForegroundColor Cyan -NoNewline
        }
        Write-Host ""
        Write-Host "    $($sk.Description)" -ForegroundColor DarkGray
        if ($sk.Repo) {
            Write-Host "    Repository : $($sk.Repo)" -ForegroundColor Cyan
        }
        if ($sk.InstallCommand) {
            Write-Host "    Quick Add  : $($sk.InstallCommand)" -ForegroundColor Green
        }
        Write-Host ""
    }
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
            Write-Warning "Skill '$sName' not found in registry. Skipping."
        }
    }
}

if ($SkillsToInstall.Count -eq 0) {
    Write-Error "No matching skills found to process."
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
            if ($Scope -eq "global") {
                $paths += (Join-Path $UserHome ".cursor\rules")
            } else {
                $paths += (Join-Path $CurrentDir ".cursor\rules")
            }
        }
        "windsurf" {
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
Write-Host " Skills: " -NoNewline; Write-Host (($SkillsToInstall | ForEach-Object { $_.Name }) -join ", ") -ForegroundColor Green
Write-Host ""

$SuccessCount = 0
$FailedCount = 0
$TempDirsToClean = @()

try {
    foreach ($skItem in $SkillsToInstall) {
        $skillName = $skItem.Name
        Write-Host ">> Processing skill: $skillName" -ForegroundColor Cyan

        # If uninstalling
        if ($Uninstall) {
            foreach ($cliName in $SelectedClis) {
                $targetPaths = Get-TargetDirectories -CliName $cliName -Scope $InstallScope -SkillName $skillName
                foreach ($dest in $targetPaths) {
                    try {
                        if ($cliName -eq "cursor") {
                            $ruleFile = Join-Path $dest "$skillName.mdc"
                            if (Test-Path $ruleFile) {
                                Remove-Item -Path $ruleFile -Force
                                Write-Host "   [-] Removed Cursor rule: $ruleFile" -ForegroundColor DarkYellow
                                $SuccessCount++
                            }
                        } elseif ($cliName -eq "windsurf") {
                            $ruleFile = Join-Path $dest "$skillName.md"
                            if (Test-Path $ruleFile) {
                                Remove-Item -Path $ruleFile -Force
                                Write-Host "   [-] Removed Windsurf rule: $ruleFile" -ForegroundColor DarkYellow
                                $SuccessCount++
                            }
                        } else {
                            if (Test-Path $dest) {
                                Remove-Item -Path $dest -Recurse -Force
                                Write-Host "   [-] Uninstalled from: $dest ($cliName)" -ForegroundColor DarkYellow
                                $SuccessCount++
                            }
                        }
                    } catch {
                        Write-Host "   [!] Error removing $dest for $cliName : $_" -ForegroundColor Red
                        $FailedCount++
                    }
                }
            }
            continue
        }

        # Resolve skill source directory
        $resolvedSource = $skItem.LocalPath
        if (-not $resolvedSource -or -not (Test-Path $resolvedSource)) {
            if ($skItem.ZipUrl) {
                Write-Host "   [i] Fetching skill from GitHub: $($skItem.ZipUrl)" -ForegroundColor DarkGray
                $skillTemp = Join-Path ([System.IO.Path]::GetTempPath()) ("skill-" + $skillName + "-" + [System.Guid]::NewGuid().ToString("N"))
                New-Item -ItemType Directory -Path $skillTemp -Force | Out-Null
                $TempDirsToClean += $skillTemp
                $zipFile = Join-Path $skillTemp "skill.zip"
                
                try {
                    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13
                    Invoke-WebRequest -Uri $skItem.ZipUrl -OutFile $zipFile -UseBasicParsing
                    Expand-Archive -Path $zipFile -DestinationPath $skillTemp -Force
                    $extracted = Get-ChildItem -Path $skillTemp -Directory | Select-Object -First 1
                    if ($extracted) {
                        $resolvedSource = $extracted.FullName
                    } else {
                        $resolvedSource = $skillTemp
                    }
                } catch {
                    Write-Host "   [!] Failed to download skill: $_" -ForegroundColor Red
                    $FailedCount++
                    continue
                }
            } else {
                Write-Host "   [!] No local directory or remote URL found for $skillName" -ForegroundColor Red
                $FailedCount++
                continue
            }
        }

        foreach ($cliName in $SelectedClis) {
            $targetPaths = Get-TargetDirectories -CliName $cliName -Scope $InstallScope -SkillName $skillName

            foreach ($dest in $targetPaths) {
                try {
                    if ($cliName -eq "cursor") {
                        if (-not (Test-Path $dest)) {
                            New-Item -ItemType Directory -Path $dest -Force | Out-Null
                        }
                        $ruleFile = Join-Path $dest "$skillName.mdc"
                        $skillMdPath = Join-Path $resolvedSource "SKILL.md"
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
                        $skillMdPath = Join-Path $resolvedSource "SKILL.md"
                        if (Test-Path $skillMdPath) {
                            Copy-Item -Path $skillMdPath -Destination $ruleFile -Force
                        }
                        Write-Host "   [+] Installed Windsurf Rule: $ruleFile" -ForegroundColor Green
                        $SuccessCount++
                    }
                    else {
                        if (-not (Test-Path $dest)) {
                            New-Item -ItemType Directory -Path $dest -Force | Out-Null
                        }
                        Copy-Item -Path (Join-Path $resolvedSource "*") -Destination $dest -Recurse -Force
                        Write-Host "   [+] Installed for $cliName -> $dest" -ForegroundColor Green
                        $SuccessCount++
                    }
                }
                catch {
                    Write-Host "   [!] Error processing $dest for $cliName : $_" -ForegroundColor Red
                    $FailedCount++
                }
            }
        }
    }
}
finally {
    foreach ($td in $TempDirsToClean) {
        if (Test-Path $td) {
            Remove-Item -Recurse -Force $td -ErrorAction SilentlyContinue
        }
    }
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
if ($Uninstall) {
    Write-Host " Uninstall completed! ($SuccessCount locations updated, $FailedCount errors)" -ForegroundColor Green
} else {
    Write-Host " Installation completed successfully! ($SuccessCount locations configured, $FailedCount errors)" -ForegroundColor Green
    Write-Host ""
    Write-Host " Direct package manager alternative:" -ForegroundColor White
    Write-Host "   npx skills add alexlivre/pagespeed-optimizer-alexlivre -g -y" -ForegroundColor Cyan
}
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""
