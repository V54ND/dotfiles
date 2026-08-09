#Requires -Version 5.1

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$WithOptional,
    [switch]$SkipWezTerm
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

$buckets = @(
    @{ Name = 'extras'; Url = 'https://github.com/ScoopInstaller/Extras' }
    @{ Name = 'nerd-fonts'; Url = 'https://github.com/matthewjberger/scoop-nerd-fonts' }
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
    'nerd-fonts/JetBrainsMono-NF'
    'nerd-fonts/Monaspace-NF-Mono'
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

if (-not $SkipWezTerm -and -not (Get-Command wezterm -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        $failures.Add('wez.wezterm (WinGet is unavailable)')
    }
    elseif ($PSCmdlet.ShouldProcess('wez.wezterm', 'winget install')) {
        & winget install --id wez.wezterm --exact --source winget --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            $failures.Add('wez.wezterm')
        }
    }
}
else {
    Write-Host '[skip] WezTerm'
}

if ($failures.Count -gt 0) {
    throw "Bootstrap failed for: $($failures -join ', ')"
}

Write-Host ''
Write-Host 'Bootstrap complete. Open a new Git Bash and run: dotfiles-doctor'
