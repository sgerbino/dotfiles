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

    # Stow packages mirror the home directory structure (e.g. nvim/.config/nvim/).
    # The junction target is the innermost directory matching the package name.
    $configDir = Join-Path $src ".config" $pkg
    if (-not (Test-Path $configDir)) {
        $configDir = $src
    }

    New-Item -ItemType Junction -Path $dest -Target $configDir | Out-Null
    Write-Host "Linked $dest -> $configDir"
}

Write-Host "`nSetup complete."
