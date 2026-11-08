<# :
@echo off
setlocal
title Universal AI Skills Installer (Antigravity / OpenCode / Claude / Workspace)
cd /d "%~dp0"
set "SKILLS_BUNDLE_ROOT=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s = Get-Content -LiteralPath '%~f0' -Raw -Encoding UTF8; & ([ScriptBlock]::Create($s)) @args" %*
set "EXIT_CODE=%ERRORLEVEL%"
if "%~1"=="" (
    echo.
    pause
)
exit /b %EXIT_CODE%
#>

param(
    [Parameter(Position = 0)]
    [ValidateSet("Interactive", "Global", "OpenCode", "OpenCodeWorkspace", "ClaudeCode", "Workspace", "AllGlobal", "Custom")]
    [string]$Target = "Interactive",

    [Parameter(Position = 1)]
    [string]$CustomOrProjectPath = ""
)

$ErrorActionPreference = "Stop"

function Write-Cyan($msg)   { Write-Host $msg -ForegroundColor Cyan }
function Write-Green($msg)  { Write-Host $msg -ForegroundColor Green }
function Write-Yellow($msg) { Write-Host $msg -ForegroundColor Yellow }
function Write-Red($msg)    { Write-Host $msg -ForegroundColor Red }
function Write-Gray($msg)   { Write-Host $msg -ForegroundColor DarkGray }

# Resolve root folder where install.bat lives
$bundleRoot = $env:SKILLS_BUNDLE_ROOT
if (-not $bundleRoot) { $bundleRoot = $PSScriptRoot }
if (-not $bundleRoot) { $bundleRoot = (Get-Item ".").FullName }
$bundleRoot = $bundleRoot.TrimEnd('\', '/')

# Automatically discover ALL skills (flat or nested) containing SKILL.md, skipping .git / node_modules
$skillFiles = @(
    Get-ChildItem -Path $bundleRoot -Filter "SKILL.md" -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch "[\\/](\.git|node_modules)[\\/]"
    }
)

$discoveredSkills = @()
$seenNames = @{}

foreach ($sf in ($skillFiles | Sort-Object { $_.Directory.Name })) {
    $dir = $sf.Directory
    $resolvedName = $dir.Name
    try {
        $raw = Get-Content -LiteralPath $sf.FullName -Raw -Encoding UTF8
        if ($raw -match "(?ms)^---\s*\r?\n(.*?)\r?\n---") {
            $fm = $Matches[1]
            if ($fm -match "(?m)^name:\s*['""]?([a-zA-Z0-9_\-\.]+)['""]?") {
                $resolvedName = $Matches[1].Trim()
            }
        }
    } catch {}

    if (-not $seenNames.ContainsKey($resolvedName)) {
        $seenNames[$resolvedName] = $true
        $discoveredSkills += [PSCustomObject]@{
            Index    = $discoveredSkills.Count + 1
            Name     = $resolvedName
            FullPath = $dir.FullName
        }
    }
}

if ($discoveredSkills.Count -eq 0) {
    Write-Red "[ERROR] No skills containing SKILL.md were found inside: $bundleRoot"
    exit 1
}

Write-Cyan "=========================================================================="
Write-Cyan "        UNIVERSAL AI AGENT SKILLS INSTALLER (AUTO-DISCOVERY .BAT)         "
Write-Cyan "=========================================================================="
Write-Host "Bundle Path : " -NoNewline; Write-Yellow $bundleRoot
Write-Host "Auto-Found  : " -NoNewline; Write-Green "$($discoveredSkills.Count) skills ready to install!"
Write-Host ""

# Display discovered skills neatly in 2 wide columns
$cols = 2
for ($i = 0; $i -lt $discoveredSkills.Count; $i += $cols) {
    $line = "  "
    for ($c = 0; $c -lt $cols; $c++) {
        $idx = $i + $c
        if ($idx -lt $discoveredSkills.Count) {
            $item = $discoveredSkills[$idx]
            $label = ("[{0,2}] {1}" -f $item.Index, $item.Name)
            $line += $label.PadRight(38)
        }
    }
    Write-Host $line -ForegroundColor Gray
}
Write-Host ""

$selectedSkills = $discoveredSkills

if ($Target -eq "Interactive") {
    Write-Cyan "Where do you want to install?"
    Write-Host "  1) Antigravity Global      (~/.gemini/config/skills)" -ForegroundColor White
    Write-Host "  2) OpenCode Global         (~/.config/opencode/skills)" -ForegroundColor Green
    Write-Host "  3) OpenCode Project Folder (<project>/.opencode/skills)" -ForegroundColor Green
    Write-Host "  4) Claude Code Global      (~/.claude/skills)" -ForegroundColor White
    Write-Host "  5) Project Workspace       (<project>/.agents/skills - Cursor/Windsurf/Antigravity)" -ForegroundColor White
    Write-Host "  6) ALL Global Apps         (Antigravity + OpenCode + Claude Code at once!)" -ForegroundColor Yellow
    Write-Host "  7) Custom Directory Path" -ForegroundColor White
    Write-Host "  Q) Quit" -ForegroundColor DarkGray
    Write-Host ""
    $choice = (Read-Host "Select target [1-7, default=6 (ALL Global), Q=Quit]").Trim()
    if ($choice -eq "") { $choice = "6" }

    switch ($choice.ToUpper()) {
        "1" { $Target = "Global" }
        "2" { $Target = "OpenCode" }
        "3" {
            $Target = "OpenCodeWorkspace"
            $CustomOrProjectPath = (Read-Host "Enter project folder path (leave empty for current folder)").Trim().Trim('"')
        }
        "4" { $Target = "ClaudeCode" }
        "5" {
            $Target = "Workspace"
            $CustomOrProjectPath = (Read-Host "Enter project folder path (leave empty for current folder)").Trim().Trim('"')
        }
        "6" { $Target = "AllGlobal" }
        "7" {
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
    $filterInput = (Read-Host "Press [Enter] to install ALL $($discoveredSkills.Count) skills, or type numbers/keywords (e.g. 1,5,tdd)").Trim()
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
$destinations = @()

switch ($Target) {
    "Global" {
        $destinations += (Join-Path $env:USERPROFILE ".gemini\config\skills")
    }
    "OpenCode" {
        $destinations += (Join-Path $env:USERPROFILE ".config\opencode\skills")
    }
    "OpenCodeWorkspace" {
        $destinations += (Join-Path $projectBase ".opencode\skills")
    }
    "ClaudeCode" {
        $destinations += (Join-Path $env:USERPROFILE ".claude\skills")
    }
    "Workspace" {
        $destinations += (Join-Path $projectBase ".agents\skills")
    }
    "AllGlobal" {
        $destinations += (Join-Path $env:USERPROFILE ".gemini\config\skills")
        $destinations += (Join-Path $env:USERPROFILE ".config\opencode\skills")
        $destinations += (Join-Path $env:USERPROFILE ".claude\skills")
    }
    "Custom" {
        if (-not $CustomOrProjectPath) {
            Write-Red "[ERROR] Custom destination path is required when Target is 'Custom'."
            exit 1
        }
        $destinations += $CustomOrProjectPath
    }
}

foreach ($destBase in $destinations) {
    Write-Cyan "`n>>> Installing $($selectedSkills.Count) skill(s) to: $destBase"
    New-Item -ItemType Directory -Force -Path $destBase | Out-Null

    $installedCount = 0
    foreach ($skill in $selectedSkills) {
        $targetDir = Join-Path $destBase $skill.Name
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        Get-ChildItem -LiteralPath $skill.FullPath -Force | Where-Object { $_.Name -ne ".git" } | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $targetDir -Recurse -Force
        }
        $installedCount++
        Write-Green ("  [OK] ({0}/{1}) {2}" -f $installedCount, $selectedSkills.Count, $skill.Name)
    }
}

# Verify Antigravity live indexing if running inside Antigravity
if ($env:ANTIGRAVITY_LS_ADDRESS -and $env:ANTIGRAVITY_CSRF_TOKEN) {
    try {
        $headers = @{
            "Content-Type" = "application/json"
            "x-codeium-csrf-token" = $env:ANTIGRAVITY_CSRF_TOKEN
        }
        $response = Invoke-RestMethod -Uri "http://$($env:ANTIGRAVITY_LS_ADDRESS)/exa.language_server_pb.LanguageServerService/GetAllSkills" -Method Post -Headers $headers -Body '{"workspaceUris":[]}' -ErrorAction SilentlyContinue
        if ($response -and $response.skills) {
            Write-Cyan "`nLive Antigravity Language Server Check: $($response.skills.Count) total active skills indexed."
        }
    } catch {}
}

Write-Cyan "`n=========================================================================="
Write-Green "  SUCCESS! Installed $($selectedSkills.Count) skill(s) to $($destinations.Count) destination(s)."
Write-Cyan "=========================================================================="
