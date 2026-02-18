# Cross-platform dotfiles setup for Windows
# Creates directory junctions from stow packages to Windows config locations

#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

$links = @{
    'nvim'     = "$env:LOCALAPPDATA\nvim"
    'git'      = "$HOME\.config\git"
    'bat'      = "$env:APPDATA\bat"
    'lazygit'  = "$env:LOCALAPPDATA\lazygit"
    'starship' = "$HOME\.config\starship"
}

$stowDir = $PSScriptRoot

foreach ($pkg in $links.Keys) {
    $src = Join-Path $stowDir $pkg
    if (-not (Test-Path $src)) {
        Write-Warning "Package '$pkg' not found at $src, skipping"
        continue
    }

    $dest = $links[$pkg]
    $parent = Split-Path $dest -Parent

    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $dest) {
        $item = Get-Item $dest -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $item.Delete()
        } else {
            Write-Warning "$dest already exists and is not a junction, skipping"
            continue
        }
    }

    # Walk into the stow package to find the actual config directory
    # Stow packages mirror the home directory structure
    $configDir = $null
    $candidates = Get-ChildItem -Path $src -Recurse -Directory | Sort-Object { $_.FullName.Length } -Descending
    foreach ($dir in $candidates) {
        $hasFiles = (Get-ChildItem -Path $dir.FullName -File).Count -gt 0
        if ($hasFiles) {
            $configDir = $dir.FullName
            break
        }
    }

    if (-not $configDir) {
        # Fallback: use the package root itself
        $configDir = $src
    }

    New-Item -ItemType Junction -Path $dest -Target $configDir | Out-Null
    Write-Host "Linked $dest -> $configDir"
}

Write-Host "`nSetup complete."
