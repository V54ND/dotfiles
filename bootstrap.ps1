#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$WithOptional
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ScoopRoot {
    if (-not [string]::IsNullOrWhiteSpace($env:SCOOP)) {
        return $env:SCOOP
    }

    return (Join-Path $HOME 'scoop')
}

function Get-AppName {
    param([Parameter(Mandatory = $true)][string]$Package)

    return ($Package -split '/')[-1]
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    throw 'Scoop is required. Install it from https://scoop.sh and run bootstrap.ps1 again.'
}

$scoopRoot = Get-ScoopRoot
$bucketRoot = Join-Path $scoopRoot 'buckets'
$failures = [System.Collections.Generic.List[string]]::new()

# Scoop is intentionally limited to CLI tools. UI applications are managed separately.
$buckets = @(
    @{ Name = 'extras'; Url = 'https://github.com/ScoopInstaller/Extras' }
)

foreach ($bucket in $buckets) {
    $bucketPath = Join-Path $bucketRoot $bucket.Name
    if (Test-Path -LiteralPath $bucketPath) {
        Write-Host "[skip] Scoop bucket $($bucket.Name)"
        continue
    }

    if ($PSCmdlet.ShouldProcess($bucket.Name, 'scoop bucket add')) {
        & scoop bucket add $bucket.Name $bucket.Url
        if ($LASTEXITCODE -ne 0) {
            $failures.Add("bucket:$($bucket.Name)")
        }
    }
}

$coreApps = @(
    'main/7zip'
    'main/bat'
    'main/delta'
    'main/eza'
    'main/fd'
    'main/ffmpeg'
    'main/fzf'
    'main/gawk'
    'main/gcc'
    'main/git'
    'main/glow'
    'main/imagemagick'
    'main/jq'
    'main/make'
    'main/neovim'
    'main/ripgrep'
    'main/shellcheck'
    'main/starship'
    'main/tree-sitter'
    'main/winfetch'
    'main/yazi'
    'main/yt-dlp'
    'main/zoxide'
    'extras/lazygit'
)

$optionalApps = @(
    'main/dust'
    'main/procs'
    'main/btop'
    'main/bottom'
    'main/hyperfine'
    'main/tokei'
    'main/doggo'
    'main/gping'
)

$apps = @($coreApps)
if ($WithOptional) {
    $apps += $optionalApps
}

foreach ($app in $apps) {
    $appName = Get-AppName -Package $app
    $appPath = Join-Path (Join-Path $scoopRoot 'apps') $appName

    if (Test-Path -LiteralPath $appPath) {
        Write-Host "[skip] $appName"
        continue
    }

    if ($PSCmdlet.ShouldProcess($app, 'scoop install')) {
        & scoop install $app
        if ($LASTEXITCODE -ne 0) {
            $failures.Add($app)
        }
    }
}

if ($failures.Count -gt 0) {
    throw "Bootstrap failed for: $($failures -join ', ')"
}

Write-Host ''
Write-Host 'Bootstrap complete. Scoop installed CLI tools only.'
Write-Host 'UI applications are intentionally not installed by this script.'
