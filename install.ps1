<#
.SYNOPSIS
    Delegates to the unified self-contained install.bat script.
#>
$batPath = Join-Path $PSScriptRoot "install.bat"
$env:SKILLS_BUNDLE_ROOT = $PSScriptRoot
$scriptText = [IO.File]::ReadAllText($batPath, [Text.Encoding]::UTF8).TrimStart([char]0xFEFF)
& ([ScriptBlock]::Create($scriptText)) @args
