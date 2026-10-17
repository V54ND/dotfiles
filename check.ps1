#Requires -Version 5.1

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$script:failedChecks = 0

function Invoke-Check {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    try {
        & $Action
        Write-Host "[ok] $Name" -ForegroundColor Green
    }
    catch {
        $script:failedChecks++
        Write-Host "[fail] $Name" -ForegroundColor Red
        Write-Host "       $($_.Exception.Message)" -ForegroundColor DarkRed
    }
}

function Invoke-Native {
    param(
        [Parameter(Mandatory = $true)][string]$Command,
        [Parameter()][string[]]$Arguments = @()
    )

    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "Command not found: $Command"
    }

    $output = & $Command @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed: $($output -join [Environment]::NewLine)"
    }
}

$relativeFiles = @(
    & git -C $root ls-files --cached --others --exclude-standard
)
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to enumerate repository files.'
}

$relativeFiles = @(
    $relativeFiles |
        Sort-Object -Unique |
        Where-Object { Test-Path -LiteralPath (Join-Path $root $_) -PathType Leaf }
)
$files = @($relativeFiles | ForEach-Object { Join-Path $root $_ })

$shellFiles = @(
    $relativeFiles |
        Where-Object {
            $_ -eq '.bash_profile' -or
            $_ -eq '.bashrc' -or
            $_ -eq '.local/bin/dotfiles-doctor' -or
            $_ -like '*.bash' -or
            $_ -like '*.sh'
        } |
        ForEach-Object { Join-Path $root $_ }
)

$textExtensions = @('.bash', '.sh', '.zsh', '.lua', '.toml', '.json', '.md', '.ps1')
$extensionlessTextFiles = @(
    '.bash_profile',
    '.bashrc',
    '.editorconfig',
    '.gitattributes',
    '.gitignore',
    '.local/bin/dotfiles-doctor',
    '.zshrc'
)

Invoke-Check 'tracked-file whitespace' {
    Invoke-Native git @('-C', $root, 'diff', 'HEAD', '--check')
}

Invoke-Check 'LF line endings' {
    $crlfFiles = [System.Collections.Generic.List[string]]::new()

    foreach ($relativeFile in $relativeFiles) {
        $extension = [IO.Path]::GetExtension($relativeFile).ToLowerInvariant()
        if ($textExtensions -notcontains $extension -and $extensionlessTextFiles -notcontains $relativeFile) {
            continue
        }

        $path = Join-Path $root $relativeFile
        $bytes = [IO.File]::ReadAllBytes($path)
        if ([Array]::IndexOf($bytes, [byte]13) -ge 0) {
            $crlfFiles.Add($relativeFile)
        }
    }

    if ($crlfFiles.Count -gt 0) {
        throw "CRLF found in: $($crlfFiles -join ', ')"
    }
}

Invoke-Check 'Bash syntax' {
    foreach ($shellFile in $shellFiles) {
        Invoke-Native bash @('-n', $shellFile)
    }
}

Invoke-Check 'ShellCheck errors' {
    Invoke-Native shellcheck (@('--severity=error', '--shell=bash') + $shellFiles)
}

Invoke-Check 'PowerShell syntax' {
    foreach ($path in ($files | Where-Object { [IO.Path]::GetExtension($_) -eq '.ps1' })) {
        $tokens = $null
        $errors = $null
        [Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors) | Out-Null
        if ($errors.Count -gt 0) {
            throw "$path`: $($errors.Message -join '; ')"
        }
    }
}

Invoke-Check 'JSON syntax' {
    foreach ($path in ($files | Where-Object { [IO.Path]::GetExtension($_) -eq '.json' })) {
        Get-Content -LiteralPath $path -Raw | ConvertFrom-Json | Out-Null
    }
}

Invoke-Check 'Scoop availability' {
    Invoke-Native scoop @('--version')
}

Invoke-Check 'Scoop health' {
    Invoke-Native scoop @('checkup')
}

Invoke-Check 'Scoop buckets' {
    $bucketOutput = @(scoop bucket list 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "scoop bucket list failed: $($bucketOutput -join [Environment]::NewLine)"
    }

    if (-not ($bucketOutput -match '\bmain\b')) {
        throw 'Scoop main bucket is not configured.'
    }
}

Invoke-Check 'CLI tool commands' {
    $commands = @(
        '7z', 'bat', 'eza', 'fd', 'fzf', 'gcc', 'git', 'glow', 'jq',
        'nvim', 'rg', 'starship', 'winfetch', 'yazi', 'zoxide', 'lazygit'
    )

    $missing = @($commands | Where-Object {
        -not (Get-Command $_ -ErrorAction SilentlyContinue)
    })

    if ($missing.Count -gt 0) {
        throw "Missing CLI commands: $($missing -join ', ')"
    }
}

Invoke-Check 'Lua syntax' {
    $luaFiles = @($files | Where-Object { [IO.Path]::GetExtension($_) -eq '.lua' })
    $quotedLuaFiles = @(
        $luaFiles | ForEach-Object {
            "'$($_.Replace('\', '/').Replace("'", "\'"))'"
        }
    )
    $expression = 'lua for _, path in ipairs({' + ($quotedLuaFiles -join ',') + '}) do assert(loadfile(path)) end'
    Invoke-Native nvim @('--clean', '--headless', '--cmd', 'set shadafile=NONE', '-c', $expression, '-c', 'qa!')
}

Invoke-Check 'Starship config' {
    $oldConfig = $env:STARSHIP_CONFIG
    $oldTerm = $env:TERM
    try {
        $env:STARSHIP_CONFIG = Join-Path $root '.config/starship.toml'
        $env:TERM = 'xterm-256color'
        Invoke-Native starship @('prompt', '--terminal-width', '100')
    }
    finally {
        if ($null -eq $oldConfig) {
            Remove-Item Env:STARSHIP_CONFIG -ErrorAction SilentlyContinue
        }
        else {
            $env:STARSHIP_CONFIG = $oldConfig
        }

        if ($null -eq $oldTerm) {
            Remove-Item Env:TERM -ErrorAction SilentlyContinue
        }
        else {
            $env:TERM = $oldTerm
        }
    }
}

Write-Host ''
if ($script:failedChecks -gt 0) {
    Write-Host "$script:failedChecks check(s) failed." -ForegroundColor Red
    exit 1
}

Write-Host 'All checks passed.' -ForegroundColor Green
