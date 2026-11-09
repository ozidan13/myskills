<# :
@echo off
setlocal EnableExtensions
title Universal AI Agent Skills Installer
cd /d "%~dp0"
set "SKILLS_BUNDLE_ROOT=%~dp0"
set "INSTALL_BAT_SELF=%~f0"
set "INSTALL_ARG1=%~1"
set "INSTALL_ARG2=%~2"
set "PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS_EXE%" set "PS_EXE=powershell.exe"
"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -Command "$s = [IO.File]::ReadAllText($env:INSTALL_BAT_SELF, [Text.Encoding]::UTF8).TrimStart([char]0xFEFF); & ([ScriptBlock]::Create($s))"
set "EXIT_CODE=%ERRORLEVEL%"
if "%~1"=="" (
    echo.
    pause
)
exit /b %EXIT_CODE%
#>

param(
    [Parameter(Position = 0)]
    [ValidateSet(
        "Interactive",
        "AllGlobal",
        "Antigravity",
        "Global",
        "OpenCode",
        "ClaudeCode",
        "Cursor",
        "Codex",
        "Windsurf",
        "Hermes",
        "Agents",
        "OpenCodeWorkspace",
        "Workspace",
        "AllWorkspace",
        "Custom"
    )]
    [string]$Target = "Interactive",

    [Parameter(Position = 1)]
    [string]$CustomOrProjectPath = ""
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if ($Target -eq "Interactive" -and $env:INSTALL_ARG1) {
    $Target = $env:INSTALL_ARG1.Trim()
}
if (-not $CustomOrProjectPath -and $env:INSTALL_ARG2) {
    $CustomOrProjectPath = $env:INSTALL_ARG2.Trim()
}

function Write-Cyan($msg)   { Write-Host $msg -ForegroundColor Cyan }
function Write-Green($msg)  { Write-Host $msg -ForegroundColor Green }
function Write-Yellow($msg) { Write-Host $msg -ForegroundColor Yellow }
function Write-Red($msg)    { Write-Host $msg -ForegroundColor Red }
function Write-Gray($msg)   { Write-Host $msg -ForegroundColor DarkGray }

function Get-SkillMetadata([string]$skillMdPath, [string]$fallbackName) {
    $resolvedName = $fallbackName
    $resolvedDesc = ""

    if (Test-Path -LiteralPath $skillMdPath) {
        try {
            $raw = [IO.File]::ReadAllText($skillMdPath, [Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
            if ($raw -match "(?ms)^---\s*\r?\n(.*?)\r?\n---") {
                $fm = $Matches[1]
                if ($fm -match "(?m)^name:\s*['""]?([a-zA-Z0-9_\-\.]+)['""]?") {
                    $resolvedName = $Matches[1].Trim()
                }
                $lines = $fm -split "\r?\n"
                $inDesc = $false
                $descParts = @()
                foreach ($ln in $lines) {
                    if (-not $inDesc) {
                        if ($ln -match "^description:\s*(.*)$") {
                            $val = $Matches[1].Trim()
                            if ($val -eq "" -or $val -match "^[>|][-+]?$") {
                                $inDesc = $true
                            } else {
                                if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
                                    $val = $val.Substring(1, $val.Length - 2)
                                }
                                $descParts += $val
                                $inDesc = $true
                            }
                        }
                    } else {
                        if ($ln -match "^\s+\S") {
                            $descParts += $ln.Trim()
                        } elseif ($ln -match "^\s*$") {
                            continue
                        } else {
                            break
                        }
                    }
                }
                $resolvedDesc = (($descParts -join " ") -replace "\s+", " ").Trim()
            }
        } catch {}
    }

    if (-not $resolvedDesc) {
        $resolvedDesc = "Load and follow the $resolvedName skill instructions"
    }
    if ($resolvedDesc.Length -gt 220) {
        $resolvedDesc = $resolvedDesc.Substring(0, 217).TrimEnd() + "..."
    }

    return [PSCustomObject]@{
        Name        = $resolvedName
        Description = $resolvedDesc
    }
}

# Codex CLI hard-rejects SKILL.md YAML frontmatter descriptions > 1024 chars.
# Truncate only in Codex / .agents destination copies while preserving full text elsewhere.
function Normalize-CodexSkillMd([string]$skillMdPath) {
    if (-not (Test-Path -LiteralPath $skillMdPath)) { return }
    try {
        $raw = [IO.File]::ReadAllText($skillMdPath, [Text.Encoding]::UTF8)
        $lines = $raw -split "\n"
        $changed = $false
        $limit = 1000
        for ($i = 0; $i -lt [Math]::Min(14, $lines.Count); $i++) {
            $trimmedLine = $lines[$i].TrimEnd("`r")
            if ($trimmedLine -match "^description:\s*(.+)$") {
                $val = $Matches[1].Trim()
                if ($val -notmatch "^[>|][-+]?$") {
                    $inner = $val
                    if (($inner.StartsWith('"') -and $inner.EndsWith('"')) -or ($inner.StartsWith("'") -and $inner.EndsWith("'"))) {
                        $inner = $inner.Substring(1, $inner.Length - 2)
                    }
                    if ($inner.Length -gt $limit) {
                        $cut = $inner.Substring(0, $limit - 3)
                        $lastSpace = $cut.LastIndexOf(' ')
                        if ($lastSpace -gt 400) { $cut = $cut.Substring(0, $lastSpace) }
                        $cut = $cut.TrimEnd(' ', ',', ';', ':', '-', '_')
                        $escaped = $cut.Replace('\', '\\').Replace('"', '\"')
                        $lines[$i] = "description: `"$escaped...`""
                        $changed = $true
                    }
                }
            }
        }
        if ($changed) {
            [IO.File]::WriteAllText($skillMdPath, ($lines -join "`n"), $Utf8NoBom)
        }
    } catch {}
}

function Find-OpenCodeCli {
    foreach ($cmdName in @("opencode", "opencode-cli")) {
        $found = Get-Command $cmdName -ErrorAction SilentlyContinue
        if ($found -and $found.Source) { return $found.Source }
    }
    $binCache = Join-Path $env:USERPROFILE ".cache\opencode\bin\opencode.exe"
    if (Test-Path -LiteralPath $binCache) { return $binCache }

    $desktopCliRoot = Join-Path $env:APPDATA "ai.opencode.desktop\cli"
    if (Test-Path -LiteralPath $desktopCliRoot) {
        $foundExes = @(Get-ChildItem -LiteralPath $desktopCliRoot -Filter "opencode-cli.exe" -Recurse -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
        if ($foundExes.Count -gt 0) {
            return $foundExes[0].FullName
        }
    }
    return $null
}

# Resolve root folder where install.bat lives
$bundleRoot = $env:SKILLS_BUNDLE_ROOT
if (-not $bundleRoot) { $bundleRoot = $PSScriptRoot }
if (-not $bundleRoot) { $bundleRoot = (Get-Item ".").FullName }
$bundleRoot = $bundleRoot.TrimEnd('\', '/')
$bugHunterSuiteDir = Join-Path $bundleRoot "_bughunter-suite"

# Auto-discover ALL skills containing SKILL.md recursively
$skillFiles = @(
    Get-ChildItem -LiteralPath $bundleRoot -Filter "SKILL.md" -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch "[\\/](\.git|node_modules|_bughunter-suite)[\\/]"
    }
)

$discoveredSkills = @()
$seenNames = @{}

foreach ($sf in ($skillFiles | Sort-Object { $_.Directory.Name })) {
    $dir = $sf.Directory
    $meta = Get-SkillMetadata -skillMdPath $sf.FullName -fallbackName $dir.Name
    $resolvedName = $meta.Name

    if (-not $seenNames.ContainsKey($resolvedName)) {
        $seenNames[$resolvedName] = $true
        $discoveredSkills += [PSCustomObject]@{
            Index       = $discoveredSkills.Count + 1
            Name        = $resolvedName
            Description = $meta.Description
            FullPath    = $dir.FullName
        }
    }
}

if ($discoveredSkills.Count -eq 0) {
    Write-Red "[ERROR] No skills containing SKILL.md were found inside: $bundleRoot"
    exit 1
}

Write-Cyan "=============================================================================="
Write-Cyan "      UNIVERSAL AI AGENT SKILLS INSTALLER (ALL APPS + SLASH COMMANDS)         "
Write-Cyan "=============================================================================="
Write-Host "Bundle Path : " -NoNewline; Write-Yellow $bundleRoot
Write-Host "Auto-Found  : " -NoNewline; Write-Green "$($discoveredSkills.Count) skills ready to install!"
Write-Host ""

# Display discovered skills neatly in 3 columns
$cols = 3
for ($i = 0; $i -lt $discoveredSkills.Count; $i += $cols) {
    $line = "  "
    for ($c = 0; $c -lt $cols; $c++) {
        $idx = $i + $c
        if ($idx -lt $discoveredSkills.Count) {
            $item = $discoveredSkills[$idx]
            $label = ("[{0,3}] {1}" -f $item.Index, $item.Name)
            $line += $label.PadRight(33)
        }
    }
    Write-Host $line -ForegroundColor Gray
}
Write-Host ""

$selectedSkills = $discoveredSkills

# Detect installed AI coding apps on this PC
$hasAntigravity = Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".gemini")
$hasOpenCode    = (Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".config\opencode")) -or ($null -ne (Find-OpenCodeCli))
$hasClaude      = Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".claude")
$hasCursor      = Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".cursor")
$hasCodex       = Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".codex")
$hasWindsurf    = Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".codeium\windsurf")
$hasHermes      = Test-Path -LiteralPath (Join-Path $env:USERPROFILE ".hermes")

function Format-Badge([bool]$detected) {
    if ($detected) { return " [DETECTED]" }
    return ""
}

if ($Target -eq "Interactive") {
    Write-Cyan "Where do you want to install?"
    Write-Host "  [1] ALL Global AI Apps      (Antigravity + OpenCode + Claude + Cursor + Codex + Windsurf + Hermes) [DEFAULT]" -ForegroundColor Yellow
    Write-Host ("  [2] Antigravity Global      (~/.gemini/config/skills)" + (Format-Badge $hasAntigravity)) -ForegroundColor White
    Write-Host ("  [3] OpenCode Global         (~/.config/opencode/skills + /slash commands)" + (Format-Badge $hasOpenCode)) -ForegroundColor Green
    Write-Host ("  [4] Claude Code Global      (~/.claude/skills + commands + hunt.ps1)" + (Format-Badge $hasClaude)) -ForegroundColor White
    Write-Host ("  [5] Cursor IDE Global       (~/.cursor/skills)" + (Format-Badge $hasCursor)) -ForegroundColor White
    Write-Host ("  [6] OpenAI Codex Global     (~/.codex/skills)" + (Format-Badge $hasCodex)) -ForegroundColor White
    Write-Host ("  [7] Windsurf & .agents      (~/.codeium/windsurf/skills + ~/.agents/skills)" + (Format-Badge $hasWindsurf)) -ForegroundColor White
    Write-Host ("  [8] Hermes Agent Global     (~/.hermes/skills)" + (Format-Badge $hasHermes)) -ForegroundColor White
    Write-Host "  [9] OpenCode Project Folder (<project>/.opencode/skills + /slash commands)" -ForegroundColor Green
    Write-Host "  [W] Project Workspace (All) (<project>/.agents + .opencode + .claude + .cursor + .codex)" -ForegroundColor Cyan
    Write-Host "  [0] Custom Directory Path" -ForegroundColor White
    Write-Host "  [Q] Quit" -ForegroundColor DarkGray
    Write-Host ""
    $choice = (Read-Host "Select target [1-9, W=Workspace, 0=Custom, Enter=1 (ALL Global), Q=Quit]").Trim()
    if ($choice -eq "") { $choice = "1" }

    switch ($choice.ToUpper()) {
        "1" { $Target = "AllGlobal" }
        "2" { $Target = "Antigravity" }
        "3" { $Target = "OpenCode" }
        "4" { $Target = "ClaudeCode" }
        "5" { $Target = "Cursor" }
        "6" { $Target = "Codex" }
        "7" { $Target = "Windsurf" }
        "8" { $Target = "Hermes" }
        "9" {
            $Target = "OpenCodeWorkspace"
            $CustomOrProjectPath = (Read-Host "Enter project folder path (leave empty for current folder)").Trim().Trim('"')
        }
        "W" {
            $Target = "AllWorkspace"
            $CustomOrProjectPath = (Read-Host "Enter project folder path (leave empty for current folder)").Trim().Trim('"')
        }
        "0" {
            $Target = "Custom"
            $CustomOrProjectPath = (Read-Host "Enter full custom destination folder path").Trim().Trim('"')
        }
        "Q" {
            Write-Yellow "Installation cancelled."
            exit 0
        }
        default {
            Write-Red "Invalid selection: $choice"
            exit 1
        }
    }

    Write-Host ""
    $filterInput = (Read-Host "Press [Enter] to install ALL $($discoveredSkills.Count) skills, or type numbers/keywords (e.g. 1,5,hunt-ssrf)").Trim()
    if ($filterInput -ne "" -and $filterInput.ToUpper() -ne "ALL" -and $filterInput.ToUpper() -ne "A") {
        $tokens = $filterInput -split "[,\s]+" | Where-Object { $_ -ne "" }
        $filtered = @()
        foreach ($sk in $discoveredSkills) {
            $match = $false
            foreach ($tk in $tokens) {
                if ($tk -match "^\d+$" -and ([int]$tk -eq $sk.Index)) { $match = $true; break }
                if ($sk.Name -like "*$tk*") { $match = $true; break }
            }
            if ($match) { $filtered += $sk }
        }
        if ($filtered.Count -eq 0) {
            Write-Red "No skills matched filter '$filterInput'."
            exit 1
        }
        $selectedSkills = $filtered
    }
}

$projectBase = if ($CustomOrProjectPath) { $CustomOrProjectPath } else { (Get-Item ".").FullName }
$installJobs = New-Object System.Collections.Generic.List[object]

function Add-JobEntry(
    [string]$appLabel,
    [string]$skillsDir,
    [string]$commandsDir = "",
    [bool]$isOpenCode = $false,
    [bool]$isClaude = $false,
    [bool]$isCodexStrict = $false
) {
    $installJobs.Add([PSCustomObject]@{
        AppLabel      = $appLabel
        SkillsDir     = $skillsDir
        CommandsDir   = $commandsDir
        IsOpenCode    = $isOpenCode
        IsClaude      = $isClaude
        IsCodexStrict = $isCodexStrict
    })
}

switch ($Target) {
    "Antigravity" {
        Add-JobEntry "Antigravity Global" (Join-Path $env:USERPROFILE ".gemini\config\skills")
    }
    "Global" {
        Add-JobEntry "Antigravity Global" (Join-Path $env:USERPROFILE ".gemini\config\skills")
    }
    "OpenCode" {
        Add-JobEntry "OpenCode Global" `
            (Join-Path $env:USERPROFILE ".config\opencode\skills") `
            (Join-Path $env:USERPROFILE ".config\opencode\commands") `
            $true $false $false
    }
    "ClaudeCode" {
        Add-JobEntry "Claude Code Global" `
            (Join-Path $env:USERPROFILE ".claude\skills") `
            (Join-Path $env:USERPROFILE ".claude\commands") `
            $false $true $false
    }
    "Cursor" {
        Add-JobEntry "Cursor IDE Global" (Join-Path $env:USERPROFILE ".cursor\skills")
    }
    "Codex" {
        Add-JobEntry "OpenAI Codex Global" (Join-Path $env:USERPROFILE ".codex\skills") "" $false $false $true
    }
    "Windsurf" {
        Add-JobEntry "Windsurf Global" (Join-Path $env:USERPROFILE ".codeium\windsurf\skills")
        Add-JobEntry "Universal .agents Global" (Join-Path $env:USERPROFILE ".agents\skills") "" $false $false $true
    }
    "Hermes" {
        Add-JobEntry "Hermes Agent Global" (Join-Path $env:USERPROFILE ".hermes\skills")
    }
    "Agents" {
        Add-JobEntry "Universal .agents Global" (Join-Path $env:USERPROFILE ".agents\skills") "" $false $false $true
    }
    "AllGlobal" {
        Add-JobEntry "Antigravity Global" (Join-Path $env:USERPROFILE ".gemini\config\skills")
        Add-JobEntry "OpenCode Global" `
            (Join-Path $env:USERPROFILE ".config\opencode\skills") `
            (Join-Path $env:USERPROFILE ".config\opencode\commands") `
            $true $false $false
        Add-JobEntry "Claude Code Global" `
            (Join-Path $env:USERPROFILE ".claude\skills") `
            (Join-Path $env:USERPROFILE ".claude\commands") `
            $false $true $false
        Add-JobEntry "Cursor IDE Global" (Join-Path $env:USERPROFILE ".cursor\skills")
        Add-JobEntry "OpenAI Codex Global" (Join-Path $env:USERPROFILE ".codex\skills") "" $false $false $true
        Add-JobEntry "Windsurf Global" (Join-Path $env:USERPROFILE ".codeium\windsurf\skills")
        Add-JobEntry "Hermes Agent Global" (Join-Path $env:USERPROFILE ".hermes\skills")
        Add-JobEntry "Universal .agents Global" (Join-Path $env:USERPROFILE ".agents\skills") "" $false $false $true
    }
    "OpenCodeWorkspace" {
        Add-JobEntry "OpenCode Project Workspace" `
            (Join-Path $projectBase ".opencode\skills") `
            (Join-Path $projectBase ".opencode\commands") `
            $true $false $false
    }
    "Workspace" {
        Add-JobEntry "Project .agents Workspace" (Join-Path $projectBase ".agents\skills") "" $false $false $true
    }
    "AllWorkspace" {
        Add-JobEntry "Project .agents (Antigravity/Universal)" (Join-Path $projectBase ".agents\skills") "" $false $false $true
        Add-JobEntry "Project OpenCode" `
            (Join-Path $projectBase ".opencode\skills") `
            (Join-Path $projectBase ".opencode\commands") `
            $true $false $false
        Add-JobEntry "Project Claude Code" `
            (Join-Path $projectBase ".claude\skills") `
            (Join-Path $projectBase ".claude\commands") `
            $false $true $false
        Add-JobEntry "Project Cursor IDE" (Join-Path $projectBase ".cursor\skills")
        Add-JobEntry "Project OpenAI Codex" (Join-Path $projectBase ".codex\skills") "" $false $false $true
    }
    "Custom" {
        if (-not $CustomOrProjectPath) {
            Write-Red "[ERROR] Custom destination path is required when Target is 'Custom'."
            exit 1
        }
        $customNorm = $CustomOrProjectPath.TrimEnd('\', '/')
        $inferredCmdDir = ""
        $inferredOpenCode = $false
        if ($customNorm -match "(?i)[\\/]\.?opencode[\\/]skills$") {
            $parentOc = Split-Path -Parent $customNorm
            $inferredCmdDir = Join-Path $parentOc "commands"
            $inferredOpenCode = $true
        } elseif ($customNorm -match "(?i)[\\/]\.?opencode$") {
            $inferredCmdDir = Join-Path $customNorm "commands"
            $CustomOrProjectPath = Join-Path $customNorm "skills"
            $inferredOpenCode = $true
        }
        Add-JobEntry "Custom Destination" $CustomOrProjectPath $inferredCmdDir $inferredOpenCode $false $false
    }
}

$installedOpenCode = $false
$bhCommandsSrc = Join-Path $bugHunterSuiteDir "commands"
$bhHuntPs1Src  = Join-Path $bugHunterSuiteDir "scripts\hunt.ps1"
$jobIndex = 0

foreach ($job in $installJobs) {
    $jobIndex++
    Write-Cyan ("`n[{0}/{1}] {2}" -f $jobIndex, $installJobs.Count, $job.AppLabel)
    New-Item -ItemType Directory -Force -Path $job.SkillsDir | Out-Null

    $copiedCount = 0
    foreach ($skill in $selectedSkills) {
        $targetDir = Join-Path $job.SkillsDir $skill.Name
        $srcNorm = [IO.Path]::GetFullPath($skill.FullPath).TrimEnd('\', '/')
        $dstNorm = [IO.Path]::GetFullPath($targetDir).TrimEnd('\', '/')

        if ($srcNorm -ieq $dstNorm) {
            $copiedCount++
            continue
        }

        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        Get-ChildItem -LiteralPath $skill.FullPath -Force | Where-Object { $_.Name -ne ".git" } | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $targetDir -Recurse -Force
        }
        if ($job.IsCodexStrict) {
            Normalize-CodexSkillMd (Join-Path $targetDir "SKILL.md")
        }
        $copiedCount++
        if ($installJobs.Count -eq 1 -and $selectedSkills.Count -le 40) {
            Write-Green ("  [OK] ({0}/{1}) {2}" -f $copiedCount, $selectedSkills.Count, $skill.Name)
        }
    }

    Write-Green ("  [OK] Installed {0} skill folder(s)   -> {1}" -f $copiedCount, $job.SkillsDir)

    # OpenCode slash command generation + BugHunter workflow commands
    if ($job.IsOpenCode -and $job.CommandsDir) {
        New-Item -ItemType Directory -Force -Path $job.CommandsDir | Out-Null
        $cmdCount = 0
        foreach ($skill in $selectedSkills) {
            $safeDesc = $skill.Description.Replace('\', '\\').Replace('"', '\"')
            $cmdLines = @(
                "---",
                "description: `"$safeDesc`"",
                "---",
                "",
                "Use the ``skill`` tool to load the ``$($skill.Name)`` skill, then follow its instructions.",
                "",
                "`$ARGUMENTS"
            )
            $cmdText = ($cmdLines -join "`n") + "`n"
            $cmdFile = Join-Path $job.CommandsDir ($skill.Name + ".md")
            [IO.File]::WriteAllText($cmdFile, $cmdText, $Utf8NoBom)
            $cmdCount++
        }

        # Also wire Claude-BugHunter dedicated slash commands without colliding with existing skill names
        if (($selectedSkills.Count -eq $discoveredSkills.Count) -and (Test-Path -LiteralPath $bhCommandsSrc)) {
            foreach ($cf in (Get-ChildItem -LiteralPath $bhCommandsSrc -Filter "*.md" -File)) {
                $baseName = $cf.BaseName
                $outName = if ($baseName -eq "triage") { "bb-triage.md" } elseif ($baseName -eq "web3-audit") { "" } else { $cf.Name }
                if (-not $outName) { continue }
                $rawCmd = [IO.File]::ReadAllText($cf.FullName, [Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
                if ($rawCmd -notmatch '\$ARGUMENTS') {
                    $rawCmd = $rawCmd.TrimEnd() + "`n`n`$ARGUMENTS`n"
                }
                [IO.File]::WriteAllText((Join-Path $job.CommandsDir $outName), $rawCmd, $Utf8NoBom)
                $cmdCount++
            }
        }

        Write-Green ("  [OK] Generated {0} /slash command(s) -> {1}" -f $cmdCount, $job.CommandsDir)
        $installedOpenCode = $true
    }

    # Claude Code native commands + hunt.ps1 engagement scaffolder
    if ($job.IsClaude -and $job.CommandsDir -and ($selectedSkills.Count -eq $discoveredSkills.Count) -and (Test-Path -LiteralPath $bhCommandsSrc)) {
        New-Item -ItemType Directory -Force -Path $job.CommandsDir | Out-Null
        $claudeCmdCount = 0
        foreach ($cf in (Get-ChildItem -LiteralPath $bhCommandsSrc -Filter "*.md" -File)) {
            Copy-Item -LiteralPath $cf.FullName -Destination (Join-Path $job.CommandsDir $cf.Name) -Force
            $claudeCmdCount++
            if ($cf.BaseName -eq "triage") {
                Copy-Item -LiteralPath $cf.FullName -Destination (Join-Path $job.CommandsDir "bb-triage.md") -Force
                $claudeCmdCount++
            }
        }
        Write-Green ("  [OK] Installed {0} BugHunter /commands -> {1}" -f $claudeCmdCount, $job.CommandsDir)

        if (($job.AppLabel -eq "Claude Code Global") -and (Test-Path -LiteralPath $bhHuntPs1Src)) {
            $claudeScriptsDir = Join-Path $env:USERPROFILE ".claude\scripts"
            New-Item -ItemType Directory -Force -Path $claudeScriptsDir | Out-Null
            $huntDst = Join-Path $claudeScriptsDir "hunt.ps1"
            Copy-Item -LiteralPath $bhHuntPs1Src -Destination $huntDst -Force
            $huntCmd = Join-Path $claudeScriptsDir "hunt.cmd"
            $huntCmdBody = "@echo off`r`n`"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe`" -NoProfile -ExecutionPolicy Bypass -Command `". `"`$env:USERPROFILE\.claude\scripts\hunt.ps1`"; hunt %*`"`r`n"
            [IO.File]::WriteAllText($huntCmd, $huntCmdBody, $Utf8NoBom)
            Write-Green ("  [OK] Wired 'hunt' scaffolder         -> {0}" -f $huntCmd)
        }
    }
}

# Live Verification for OpenCode if background service is running
if ($installedOpenCode) {
    $ocCli = Find-OpenCodeCli
    if ($ocCli) {
        try {
            $svcState = (& $ocCli service status 2>$null | Out-String).Trim()
            if ($svcState -match "(?i)^running") {
                $cmdParsed = (& $ocCli api command.list 2>$null | Out-String | ConvertFrom-Json)
                if ($cmdParsed -and $cmdParsed.data -and $cmdParsed.data.Count -le 3) {
                    Start-Sleep -Milliseconds 1500
                    $cmdParsed = (& $ocCli api command.list 2>$null | Out-String | ConvertFrom-Json)
                }
                if ($cmdParsed -and $cmdParsed.data -and $cmdParsed.data.Count -gt 3) {
                    Write-Green "  [LIVE VERIFIED] OpenCode Server exposes $($cmdParsed.data.Count) /slash commands live!"
                }
            }
        } catch {}
    }
    Write-Yellow "  [READY] OpenCode auto-reloads ~/.config/opencode/commands live — type / in OpenCode right now!"
}

# Live Verification for Antigravity if running inside Antigravity
if ($env:ANTIGRAVITY_LS_ADDRESS -and $env:ANTIGRAVITY_CSRF_TOKEN) {
    try {
        $headers = @{
            "Content-Type" = "application/json"
            "x-codeium-csrf-token" = $env:ANTIGRAVITY_CSRF_TOKEN
        }
        $response = Invoke-RestMethod -Uri "http://$($env:ANTIGRAVITY_LS_ADDRESS)/exa.language_server_pb.LanguageServerService/GetAllSkills" -Method Post -Headers $headers -Body '{"workspaceUris":[]}' -ErrorAction SilentlyContinue
        if ($response -and $response.skills) {
            Write-Green "  [LIVE VERIFIED] Antigravity Language Server indexed $($response.skills.Count) active skills!"
        }
    } catch {}
}

Write-Cyan "`n=============================================================================="
Write-Green "  SUCCESS! Installed $($selectedSkills.Count) skill(s) across $($installJobs.Count) app target(s)."
Write-Cyan "=============================================================================="
