<#
.SYNOPSIS
    Installs an AI agent skill from a Git URL, GitHub link, direct web link, local directory, or ZIP archive
    across Antigravity, OpenCode (skills + /slash commands), Claude Code, Cursor, Codex, Windsurf, and Workspace.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Source,

    [Parameter(Position = 1)]
    [ValidateSet("Both", "AllGlobal", "Global", "Workspace", "OpenCode", "ClaudeCode", "Cursor", "Codex", "Windsurf")]
    [string]$Scope = "Both",

    [Parameter(Position = 2)]
    [string]$SkillName = "",

    [string]$WorkspaceDir = ""
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Info($msg)    { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Write-WarnMsg($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

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
        if ($foundExes.Count -gt 0) { return $foundExes[0].FullName }
    }
    return $null
}

function Parse-SkillMeta([string]$skillMdPath, [string]$fallbackName) {
    $resolvedName = $fallbackName
    $resolvedDesc = ""
    if (Test-Path -LiteralPath $skillMdPath) {
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
    }
    if (-not $resolvedDesc) {
        $resolvedDesc = "Load and follow the $resolvedName skill instructions"
    }
    if ($resolvedDesc.Length -gt 220) {
        $resolvedDesc = $resolvedDesc.Substring(0, 217).TrimEnd() + "..."
    }
    return [PSCustomObject]@{ Name = $resolvedName; Description = $resolvedDesc }
}

if (-not $WorkspaceDir) {
    if ($env:WORKSPACE_ROOT) {
        $WorkspaceDir = $env:WORKSPACE_ROOT
    } else {
        $WorkspaceDir = (Get-Item ".").FullName
    }
}

$tempWorkingDir = Join-Path $env:TEMP ("ai-skill-install-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tempWorkingDir | Out-Null

try {
    $skillDirsToInstall = New-Object System.Collections.Generic.List[object]
    $cleanSource = $Source.Trim().Trim('"').Trim("'")

    Write-Info "Processing source: $cleanSource"

    $isGitUrl = ($cleanSource -match "^https?://.+(\.git)?$" -and ($cleanSource -match "github\.com|gitlab\.com|bitbucket\.org|\.git$"))
    $isGitHubTree = ($cleanSource -match "^https?://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$")

    if ($isGitHubTree) {
        $owner = $Matches[1]
        $repo = $Matches[2]
        $branch = $Matches[3]
        $subPath = $Matches[4]
        $cloneUrl = "https://github.com/$owner/$repo.git"

        Write-Info "Detected GitHub tree URL. Cloning repo $cloneUrl (branch: $branch, subpath: $subPath)..."
        $cloneDir = Join-Path $tempWorkingDir "repo"
        cmd /c "git clone --depth 1 --branch `"$branch`" --quiet `"$cloneUrl`" `"$cloneDir`""
        if ($LASTEXITCODE -ne 0) { throw "Failed to clone repository: $cloneUrl" }

        $targetSubDir = Join-Path $cloneDir ($subPath.Replace("/", "\"))
        if (Test-Path -LiteralPath $targetSubDir) {
            $skillDirsToInstall.Add((Get-Item -LiteralPath $targetSubDir))
        } else {
            throw "Specified subpath '$subPath' not found in repository."
        }
    } elseif ($isGitUrl) {
        Write-Info "Cloning Git repository..."
        $cloneDir = Join-Path $tempWorkingDir "repo"
        cmd /c "git clone --depth 1 --quiet `"$cleanSource`" `"$cloneDir`""
        if ($LASTEXITCODE -ne 0) { throw "Failed to clone repository: $cleanSource" }

        $skillsFolder = Join-Path $cloneDir "skills"
        if (Test-Path -LiteralPath $skillsFolder) {
            foreach ($sf in @(Get-ChildItem -LiteralPath $skillsFolder -Filter "SKILL.md" -Recurse -File)) {
                $skillDirsToInstall.Add($sf.Directory)
            }
        }
        if ($skillDirsToInstall.Count -eq 0) {
            if (Test-Path -LiteralPath (Join-Path $cloneDir "SKILL.md")) {
                $skillDirsToInstall.Add((Get-Item -LiteralPath $cloneDir))
            } else {
                foreach ($sf in @(Get-ChildItem -LiteralPath $cloneDir -Filter "SKILL.md" -Recurse -File)) {
                    $skillDirsToInstall.Add($sf.Directory)
                }
            }
        }
        if ($skillDirsToInstall.Count -eq 0) {
            throw "No SKILL.md file found in repository $cleanSource."
        }
    } elseif ($cleanSource -match "^https?://") {
        if ($cleanSource -match "\.zip($|\?)") {
            Write-Info "Downloading ZIP archive..."
            $zipFile = Join-Path $tempWorkingDir "skill.zip"
            Invoke-WebRequest -Uri $cleanSource -OutFile $zipFile -UseBasicParsing
            $extractedDir = Join-Path $tempWorkingDir "extracted"
            Expand-Archive -Path $zipFile -DestinationPath $extractedDir -Force
            $skillFiles = @(Get-ChildItem -LiteralPath $extractedDir -Filter "SKILL.md" -Recurse -File)
            if ($skillFiles.Count -gt 0) {
                foreach ($sf in $skillFiles) { $skillDirsToInstall.Add($sf.Directory) }
            } else {
                $skillDirsToInstall.Add((Get-Item -LiteralPath $extractedDir))
            }
        } else {
            Write-Info "Downloading raw SKILL.md file..."
            $singleSkillDir = Join-Path $tempWorkingDir "custom-skill"
            New-Item -ItemType Directory -Force -Path $singleSkillDir | Out-Null
            $destFile = Join-Path $singleSkillDir "SKILL.md"
            Invoke-WebRequest -Uri $cleanSource -OutFile $destFile -UseBasicParsing
            $skillDirsToInstall.Add((Get-Item -LiteralPath $singleSkillDir))
        }
    } elseif (Test-Path -LiteralPath $cleanSource) {
        $item = Get-Item -LiteralPath $cleanSource
        if ($item.PSIsContainer) {
            if (Test-Path -LiteralPath (Join-Path $item.FullName "SKILL.md")) {
                $skillDirsToInstall.Add($item)
            } else {
                foreach ($sf in @(Get-ChildItem -LiteralPath $item.FullName -Filter "SKILL.md" -Recurse -File)) {
                    $skillDirsToInstall.Add($sf.Directory)
                }
            }
        } elseif ($item.Extension -eq ".zip") {
            Write-Info "Extracting local ZIP archive..."
            $extractedDir = Join-Path $tempWorkingDir "extracted"
            Expand-Archive -Path $item.FullName -DestinationPath $extractedDir -Force
            $skillFiles = @(Get-ChildItem -LiteralPath $extractedDir -Filter "SKILL.md" -Recurse -File)
            if ($skillFiles.Count -gt 0) {
                foreach ($sf in $skillFiles) { $skillDirsToInstall.Add($sf.Directory) }
            } else {
                $skillDirsToInstall.Add((Get-Item -LiteralPath $extractedDir))
            }
        } elseif ($item.Name -like "*.md") {
            $singleSkillDir = Join-Path $tempWorkingDir "custom-skill"
            New-Item -ItemType Directory -Force -Path $singleSkillDir | Out-Null
            Copy-Item -LiteralPath $item.FullName -Destination (Join-Path $singleSkillDir "SKILL.md") -Force
            $skillDirsToInstall.Add((Get-Item -LiteralPath $singleSkillDir))
        }
    } else {
        throw "Could not resolve source: '$cleanSource' is not a valid URL, Git repo, or local path."
    }

    if ($skillDirsToInstall.Count -eq 0) {
        throw "No installable skills found in source."
    }

    $installedSkills = New-Object System.Collections.Generic.List[object]
    $touchedOpenCode = $false

    foreach ($skillDir in $skillDirsToInstall) {
        $skillMdPath = Join-Path $skillDir.FullName "SKILL.md"
        $fallback = ($skillDir.Name.ToLower() -replace "[^a-z0-9_\-]", "-")
        $meta = Parse-SkillMeta -skillMdPath $skillMdPath -fallbackName $fallback
        $resolvedName = $meta.Name
        $resolvedDesc = $meta.Description

        if ($SkillName -and ($skillDirsToInstall.Count -eq 1)) {
            $resolvedName = $SkillName
        }

        if (Test-Path -LiteralPath $skillMdPath) {
            $content = [IO.File]::ReadAllText($skillMdPath, [Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
            if ($content -notmatch "^---") {
                Write-WarnMsg "Adding missing frontmatter to SKILL.md for $resolvedName..."
                $frontmatter = "---`nname: $resolvedName`ndescription: `"$resolvedName skill installed via install-skill.`"`n---`n`n"
                [IO.File]::WriteAllText($skillMdPath, ($frontmatter + $content), $Utf8NoBom)
            }
        }

        $targets = New-Object System.Collections.Generic.List[string]
        $openCodeCmdDirs = New-Object System.Collections.Generic.List[string]

        switch ($Scope) {
            "Both" {
                $targets.Add((Join-Path $env:USERPROFILE ".gemini\config\skills\$resolvedName"))
                $targets.Add((Join-Path $WorkspaceDir ".agents\skills\$resolvedName"))
            }
            "Global" {
                $targets.Add((Join-Path $env:USERPROFILE ".gemini\config\skills\$resolvedName"))
            }
            "Workspace" {
                $targets.Add((Join-Path $WorkspaceDir ".agents\skills\$resolvedName"))
            }
            "OpenCode" {
                $targets.Add((Join-Path $env:USERPROFILE ".config\opencode\skills\$resolvedName"))
                $openCodeCmdDirs.Add((Join-Path $env:USERPROFILE ".config\opencode\commands"))
            }
            "ClaudeCode" {
                $targets.Add((Join-Path $env:USERPROFILE ".claude\skills\$resolvedName"))
            }
            "Cursor" {
                $targets.Add((Join-Path $env:USERPROFILE ".cursor\skills\$resolvedName"))
            }
            "Codex" {
                $targets.Add((Join-Path $env:USERPROFILE ".codex\skills\$resolvedName"))
            }
            "Windsurf" {
                $targets.Add((Join-Path $env:USERPROFILE ".codeium\windsurf\skills\$resolvedName"))
                $targets.Add((Join-Path $env:USERPROFILE ".agents\skills\$resolvedName"))
            }
            "AllGlobal" {
                $targets.Add((Join-Path $env:USERPROFILE ".gemini\config\skills\$resolvedName"))
                $targets.Add((Join-Path $env:USERPROFILE ".config\opencode\skills\$resolvedName"))
                $targets.Add((Join-Path $env:USERPROFILE ".claude\skills\$resolvedName"))
                $targets.Add((Join-Path $env:USERPROFILE ".cursor\skills\$resolvedName"))
                $targets.Add((Join-Path $env:USERPROFILE ".codex\skills\$resolvedName"))
                $targets.Add((Join-Path $env:USERPROFILE ".codeium\windsurf\skills\$resolvedName"))
                $targets.Add((Join-Path $env:USERPROFILE ".agents\skills\$resolvedName"))
                $openCodeCmdDirs.Add((Join-Path $env:USERPROFILE ".config\opencode\commands"))
            }
        }

        foreach ($target in $targets) {
            New-Item -ItemType Directory -Force -Path $target | Out-Null
            Get-ChildItem -LiteralPath $skillDir.FullName -Force | Where-Object { $_.Name -ne ".git" } | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
            }
            Write-Success "Installed '$resolvedName' -> $target"
        }

        foreach ($cmdDir in $openCodeCmdDirs) {
            New-Item -ItemType Directory -Force -Path $cmdDir | Out-Null
            $safeDesc = $resolvedDesc.Replace('\', '\\').Replace('"', '\"')
            $cmdText = "---`ndescription: `"$safeDesc`"`n---`n`nUse the ``skill`` tool to load the ``$resolvedName`` skill, then follow its instructions.`n`n`$ARGUMENTS`n"
            $cmdFile = Join-Path $cmdDir ($resolvedName + ".md")
            [IO.File]::WriteAllText($cmdFile, $cmdText, $Utf8NoBom)
            Write-Success "Registered OpenCode slash command '/$resolvedName' -> $cmdFile"
            $touchedOpenCode = $true
        }

        $installedSkills.Add([PSCustomObject]@{
            Name    = $resolvedName
            Targets = $targets.ToArray()
        })
    }

    if ($touchedOpenCode) {
        Write-Info "OpenCode slash command(s) registered in ~/.config/opencode/commands (live-watched automatically)."
    }

    if ($env:ANTIGRAVITY_LS_ADDRESS -and $env:ANTIGRAVITY_CSRF_TOKEN) {
        try {
            $headers = @{
                "Content-Type" = "application/json"
                "x-codeium-csrf-token" = $env:ANTIGRAVITY_CSRF_TOKEN
            }
            $wsUri = "file:///" + $WorkspaceDir.Replace("\", "/")
            $body = (@{ workspaceUris = @($wsUri) } | ConvertTo-Json)
            $response = Invoke-RestMethod -Uri "http://$($env:ANTIGRAVITY_LS_ADDRESS)/exa.language_server_pb.LanguageServerService/GetAllSkills" -Method Post -Headers $headers -Body $body -ErrorAction SilentlyContinue
            if ($response -and $response.skills) {
                Write-Info "Antigravity Language Server active skills count: $($response.skills.Count)"
            }
        } catch {}
    }

    Write-Host "`nAll skills installed successfully!" -ForegroundColor Green
    return $installedSkills.ToArray()

} finally {
    if (Test-Path -LiteralPath $tempWorkingDir) {
        Remove-Item -LiteralPath $tempWorkingDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
