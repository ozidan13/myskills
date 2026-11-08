<#
.SYNOPSIS
    Installs an Antigravity skill from a Git URL, GitHub link, direct web link, local directory, or ZIP archive.

.PARAMETER Source
    The source repository URL, direct file link, local folder, or ZIP archive.

.PARAMETER Scope
    Where to install: "Global" (~/.gemini/config/skills), "Workspace" (.agents/skills), or "Both" (default).

.PARAMETER SkillName
    Optional override for the skill name. If omitted, the name is extracted from SKILL.md frontmatter.

.PARAMETER WorkspaceDir
    Optional workspace directory. Defaults to current directory or active Antigravity workspace.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Source,

    [Parameter(Position = 1)]
    [ValidateSet("Global", "Workspace", "Both", "OpenCode", "ClaudeCode")]
    [string]$Scope = "Both",

    [Parameter(Position = 2)]
    [string]$SkillName = "",

    [string]$WorkspaceDir = ""
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[SUCCESS] $msg" -ForegroundColor Green }
function Write-WarnMsg($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-ErrMsg($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Determine workspace root
if (-not $WorkspaceDir) {
    if ($env:WORKSPACE_ROOT) {
        $WorkspaceDir = $env:WORKSPACE_ROOT
    } elseif ((Test-Path ".\.agents") -or (Test-Path ".\.git")) {
        $WorkspaceDir = (Get-Item ".").FullName
    } else {
        $WorkspaceDir = (Get-Item ".").FullName
    }
}

$globalSkillsBase = Join-Path $env:USERPROFILE ".gemini\config\skills"
$wsSkillsBase = Join-Path $WorkspaceDir ".agents\skills"

$tempWorkingDir = Join-Path $env:TEMP ("antigravity-skill-install-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Force -Path $tempWorkingDir | Out-Null

try {
    $skillDirsToInstall = @()
    $cleanSource = $Source.Trim().Trim('"').Trim("'")

    Write-Info "Processing source: $cleanSource"

    # Check if Git URL or GitHub URL
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
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to clone repository: $cloneUrl"
        }

        $targetSubDir = Join-Path $cloneDir ($subPath.Replace("/", "\"))
        if (Test-Path $targetSubDir) {
            $skillDirsToInstall += (Get-Item $targetSubDir)
        } else {
            throw "Specified subpath '$subPath' not found in repository."
        }
    } elseif ($isGitUrl) {
        Write-Info "Cloning Git repository..."
        $cloneDir = Join-Path $tempWorkingDir "repo"
        cmd /c "git clone --depth 1 --quiet `"$cleanSource`" `"$cloneDir`""
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to clone repository: $cleanSource"
        }

        # Look for skills directory (supports both flat skills/<name> and categorized skills/<cat>/<name>)
        $skillsFolder = Join-Path $cloneDir "skills"
        if (Test-Path $skillsFolder) {
            $nestedSkillFiles = @(Get-ChildItem -Path $skillsFolder -Filter "SKILL.md" -Recurse)
            foreach ($sf in $nestedSkillFiles) {
                $skillDirsToInstall += $sf.Directory
            }
        }

        # If no skills in skills/, check root
        if ($skillDirsToInstall.Count -eq 0) {
            if (Test-Path (Join-Path $cloneDir "SKILL.md")) {
                $skillDirsToInstall += (Get-Item $cloneDir)
            } else {
                # Look recursively for any SKILL.md
                $allSkillFiles = Get-ChildItem -Path $cloneDir -Filter "SKILL.md" -Recurse
                foreach ($sf in $allSkillFiles) {
                    $skillDirsToInstall += $sf.Directory
                }
            }
        }

        if ($skillDirsToInstall.Count -eq 0) {
            throw "No SKILL.md file found in repository $cleanSource."
        }
    } elseif ($cleanSource -match "^https?://") {
        # Direct URL (could be raw SKILL.md or .zip archive)
        if ($cleanSource -match "\.zip($|\?)") {
            Write-Info "Downloading ZIP archive..."
            $zipFile = Join-Path $tempWorkingDir "skill.zip"
            Invoke-WebRequest -Uri $cleanSource -OutFile $zipFile -UseBasicParsing
            $extractedDir = Join-Path $tempWorkingDir "extracted"
            Expand-Archive -Path $zipFile -DestinationPath $extractedDir -Force
            $skillFiles = Get-ChildItem -Path $extractedDir -Filter "SKILL.md" -Recurse
            if ($skillFiles.Count -gt 0) {
                foreach ($sf in $skillFiles) { $skillDirsToInstall += $sf.Directory }
            } else {
                $skillDirsToInstall += (Get-Item $extractedDir)
            }
        } else {
            # Single raw markdown / SKILL.md file
            Write-Info "Downloading raw SKILL.md file..."
            $singleSkillDir = Join-Path $tempWorkingDir "custom-skill"
            New-Item -ItemType Directory -Force -Path $singleSkillDir | Out-Null
            $destFile = Join-Path $singleSkillDir "SKILL.md"
            Invoke-WebRequest -Uri $cleanSource -OutFile $destFile -UseBasicParsing
            $skillDirsToInstall += (Get-Item $singleSkillDir)
        }
    } elseif (Test-Path $cleanSource) {
        # Local path
        $item = Get-Item $cleanSource
        if ($item.PSIsContainer) {
            if (Test-Path (Join-Path $item.FullName "SKILL.md")) {
                $skillDirsToInstall += $item
            } else {
                $skillsFolder = Join-Path $item.FullName "skills"
                if (Test-Path $skillsFolder) {
                    $childSkills = Get-ChildItem -Path $skillsFolder -Directory
                    foreach ($dir in $childSkills) {
                        if (Test-Path (Join-Path $dir.FullName "SKILL.md")) {
                            $skillDirsToInstall += $dir
                        }
                    }
                } else {
                    $found = Get-ChildItem -Path $item.FullName -Filter "SKILL.md" -Recurse
                    foreach ($sf in $found) { $skillDirsToInstall += $sf.Directory }
                }
            }
        } elseif ($item.Extension -eq ".zip") {
            Write-Info "Extracting local ZIP archive..."
            $extractedDir = Join-Path $tempWorkingDir "extracted"
            Expand-Archive -Path $item.FullName -DestinationPath $extractedDir -Force
            $skillFiles = Get-ChildItem -Path $extractedDir -Filter "SKILL.md" -Recurse
            if ($skillFiles.Count -gt 0) {
                foreach ($sf in $skillFiles) { $skillDirsToInstall += $sf.Directory }
            } else {
                $skillDirsToInstall += (Get-Item $extractedDir)
            }
        } elseif ($item.Name -like "*.md") {
            $singleSkillDir = Join-Path $tempWorkingDir "custom-skill"
            New-Item -ItemType Directory -Force -Path $singleSkillDir | Out-Null
            Copy-Item -Path $item.FullName -Destination (Join-Path $singleSkillDir "SKILL.md") -Force
            $skillDirsToInstall += (Get-Item $singleSkillDir)
        }
    } else {
        throw "Could not resolve source: '$cleanSource' is not a valid URL, Git repo, or local path."
    }

    if ($skillDirsToInstall.Count -eq 0) {
        throw "No installable skills found in source."
    }

    $installedSkills = @()

    foreach ($skillDir in $skillDirsToInstall) {
        $skillMdPath = Join-Path $skillDir.FullName "SKILL.md"
        $resolvedName = ""
        $resolvedDesc = ""

        if (Test-Path $skillMdPath) {
            $content = Get-Content -Path $skillMdPath -Raw -Encoding utf8
            if ($content -match "(?m)^name:\s*['""]?([a-zA-Z0-9_\-\.]+)['""]?") {
                $resolvedName = $Matches[1].Trim()
            }
            if ($content -match "(?ms)^description:\s*>-?\s*(.*?)(^---|\Z)") {
                $resolvedDesc = $Matches[1].Trim()
            }
        }

        # Override name if explicitly passed for single-skill install
        if ($SkillName -and ($skillDirsToInstall.Count -eq 1)) {
            $resolvedName = $SkillName
        }

        if (-not $resolvedName) {
            $resolvedName = $skillDir.Name.ToLower() -replace "[^a-z0-9_\-]", "-"
        }

        # Ensure SKILL.md has valid frontmatter
        if (Test-Path $skillMdPath) {
            $content = Get-Content -Path $skillMdPath -Raw -Encoding utf8
            if ($content -notmatch "^---") {
                Write-WarnMsg "Adding missing frontmatter to SKILL.md for $resolvedName..."
                $frontmatter = "---`nname: $resolvedName`ndescription: $resolvedName skill installed via install-skill.`n---`n`n"
                Set-Content -Path $skillMdPath -Value ($frontmatter + $content) -Encoding utf8
            }
        }

        $targets = @()
        if ($Scope -eq "Global" -or $Scope -eq "Both") {
            $targets += (Join-Path $globalSkillsBase $resolvedName)
        }
        if ($Scope -eq "Workspace" -or $Scope -eq "Both") {
            $targets += (Join-Path $wsSkillsBase $resolvedName)
        }
        if ($Scope -eq "OpenCode") {
            $targets += (Join-Path $env:USERPROFILE ".config\opencode\skills\$resolvedName")
        }
        if ($Scope -eq "ClaudeCode") {
            $targets += (Join-Path $env:USERPROFILE ".claude\skills\$resolvedName")
        }

        foreach ($target in $targets) {
            New-Item -ItemType Directory -Force -Path $target | Out-Null
            
            # Copy all files from skill directory, excluding .git
            Get-ChildItem -Path $skillDir.FullName | Where-Object { $_.Name -ne ".git" } | ForEach-Object {
                Copy-Item -Path $_.FullName -Destination $target -Recurse -Force
            }
            Write-Success "Installed '$resolvedName' -> $target"
        }

        $installedSkills += [PSCustomObject]@{
            Name = $resolvedName
            Targets = $targets
        }
    }

    # Verify discovery via Language Server if active
    if ($env:ANTIGRAVITY_LS_ADDRESS -and $env:ANTIGRAVITY_CSRF_TOKEN) {
        try {
            $headers = @{
                "Content-Type" = "application/json"
                "x-codeium-csrf-token" = $env:ANTIGRAVITY_CSRF_TOKEN
            }
            $wsUri = "file:///" + $WorkspaceDir.Replace("\", "/")
            $body = (@{ workspaceUris = @($wsUri) } | ConvertTo-Json)
            $response = Invoke-RestMethod -Uri "http://$($env:ANTIGRAVITY_LS_ADDRESS)/exa.language_server_pb.LanguageServerService/GetAllSkills" -Method Post -Headers $headers -Body $body -ErrorAction SilentlyContinue
            
            Write-Host "`nLive verification with Language Server:" -ForegroundColor Cyan
            foreach ($s in $installedSkills) {
                $found = $response.skills | Where-Object { $_.name -eq $s.Name }
                if ($found) {
                    Write-Success "  [OK] $($s.Name) is actively indexed and ready to use via /"
                } else {
                    Write-WarnMsg "  [PENDING] $($s.Name) installed; will be loaded on next prompt."
                }
            }
        } catch {
            # Non-fatal if LS ping fails
        }
    }

    Write-Host "`nAll skills installed successfully!" -ForegroundColor Green
    return $installedSkills

} finally {
    if (Test-Path $tempWorkingDir) {
        Remove-Item -Path $tempWorkingDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
