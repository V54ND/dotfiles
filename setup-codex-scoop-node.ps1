# Run from a normal Windows PowerShell session (not the Codex sandbox).
# Makes Codex and regular Windows shells resolve Node through the same NVM junction.
# Does not need administrator rights or install another Node version.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$scoopRoot = Join-Path $env:USERPROFILE 'scoop'
$nvmExe = Join-Path $scoopRoot 'apps\nvm\current\nvm.exe'
$nvmData = Join-Path $scoopRoot 'persist\nvm'
$nodeLink = Join-Path $nvmData '.nodejs'

if (-not (Test-Path -LiteralPath $nvmExe -PathType Leaf)) {
    throw "Scoop NVM executable not found: $nvmExe"
}

Write-Host '1. Enable NVM link mode...'
& $nvmExe use link
if ($LASTEXITCODE -ne 0) { throw 'Could not enable NVM link mode.' }

# NVM may emit a non-fatal warning about replacing its old shim.
# The existing default version should be selected in link mode.
$nodeExe = Join-Path $nodeLink 'node.exe'
if (-not (Test-Path -LiteralPath $nodeExe -PathType Leaf)) {
    throw "Node executable not found through NVM link: $nodeExe. Run 'nvm use <installed-version>' in your normal PowerShell first."
}

$linkItem = Get-Item -LiteralPath $nodeLink -Force
if (-not $linkItem.LinkType) {
    throw "$nodeLink is not a filesystem link. Check 'nvm env' before changing PATH."
}
Write-Host "   Node link: $nodeLink ($($linkItem.LinkType))"

Write-Host '2. Update user PATH without replacing unrelated entries...'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$versionPathPattern = '^' + [regex]::Escape((Join-Path $nvmData 'nodejs')) + '\\v\d+(?:\.\d+){1,2}\\?$'

function Set-PreferredNodePath([string]$pathValue) {
    $entries = @($pathValue -split ';' | ForEach-Object { $_.Trim() } | Where-Object {
        $_ -and
        $_.TrimEnd('\') -ine $nodeLink.TrimEnd('\') -and
        $_ -notmatch $versionPathPattern
    })
    return (@($nodeLink) + $entries) -join ';'
}

$newUserPath = Set-PreferredNodePath $userPath
if ($newUserPath -cne $userPath) {
    [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
    Write-Host '   User PATH saved.'
} else {
    Write-Host '   User PATH already configured.'
}

# Also configure this PowerShell process for immediate verification.
$env:Path = Set-PreferredNodePath $env:Path

Write-Host '3. Verify Node resolves through the stable NVM junction...'
$resolvedNode = (Get-Command node -CommandType Application -ErrorAction Stop).Source
$version = (& node --version).Trim()
Write-Host "   Resolved node: $resolvedNode"
Write-Host "   Node version : $version"
if (-not $resolvedNode.StartsWith($nodeLink, [StringComparison]::OrdinalIgnoreCase)) {
    Write-Warning 'The effective PATH prefers a different node.exe. Check the PATH order.'
}

Write-Host ''
Write-Host 'Done. Remove any old [shell_environment_policy.set] Path/PATH override in ~/.codex/config.toml.'
Write-Host 'Then close all VS Code windows, reopen VS Code, and start a new Codex session.'
Write-Host 'Test by running node -v in Codex, then switching versions with nvm use in normal PowerShell.'
