<#
.SYNOPSIS
    Delegates to the unified self-contained install.bat script.
#>
$batPath = Join-Path $PSScriptRoot "install.bat"
$env:SKILLS_BUNDLE_ROOT = $PSScriptRoot
$scriptText = Get-Content -LiteralPath $batPath -Raw -Encoding UTF8
& ([ScriptBlock]::Create($scriptText)) @args
