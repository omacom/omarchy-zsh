Omarchy shell configuration for Zsh shell.

## Architecture

Shared shell config (aliases, functions, environment, init) is pulled from [omadots](https://github.com/omacom-io/omadots) at package build time. This repo only contains the zsh-specific bits. Config is sourced directly from `/usr/share/` so package updates take effect immediately.

### Build

```mermaid
graph LR
    omadots[omadots] --> envs & aliases & functions & inits
    zsh_repo[omarchy-zsh] --> zoptions
    zsh_repo -->|templates| dotfiles["~/.zshrc, ~/.bashrc"]

    subgraph "/usr/share/omarchy-zsh/shell/"
        envs
        aliases
        functions
        inits
        zoptions
    end

    style omadots fill:#4a9,stroke:#333,color:#fff
    style zsh_repo fill:#68f,stroke:#333,color:#fff
    style zoptions fill:#68f,stroke:#333,color:#fff
    style envs fill:#4a9,stroke:#333,color:#fff
    style aliases fill:#4a9,stroke:#333,color:#fff
    style functions fill:#4a9,stroke:#333,color:#fff
    style inits fill:#4a9,stroke:#333,color:#fff
```

### Runtime

```mermaid
graph LR
    bashrc[~/.bashrc] -->|exec zsh| zshrc[~/.zshrc]
    zshrc --> zoptions & all
    all --> envs & aliases & functions & inits

    style zoptions fill:#68f,stroke:#333,color:#fff
    style envs fill:#4a9,stroke:#333,color:#fff
    style aliases fill:#4a9,stroke:#333,color:#fff
    style functions fill:#4a9,stroke:#333,color:#fff
    style inits fill:#4a9,stroke:#333,color:#fff
```

Green = shared (from omadots). Blue = zsh-specific (from this repo).

## Install

```bash
# Install the package
sudo pacman -S omarchy-zsh

# Setup zsh (installs ~/.zshrc, bash auto-launch, and chsh to zsh)
omarchy-setup-zsh
```

`omarchy-setup-zsh` changes your login shell with `chsh -s $(command -v zsh)`.
Log out/in once afterwards so `$SHELL` updates (new terminals auto-launch
zsh via `~/.bashrc` even before that). If `chsh` fails, run it manually:

```bash
chsh -s /usr/bin/zsh
```

## fzf Keybindings

- **Ctrl+Alt+F** - Search files/directories
- **Ctrl+Alt+L** - Search Git Log
- **Ctrl+R** - Search command history
- **Ctrl+T** - Search files in current directory
- **Ctrl+Alt+V** - Search Variables
- **Alt+C** - cd into selected directory

## Customization

To add your own configuration or override defaults:

```bash
# Edit your .zshrc
nvim ~/.zshrc

# Add customizations at the bottom after the omarchy-zsh loading
```

User customizations in `~/.zshrc` take precedence over system defaults.

## Uninstall

```bash
sudo pacman -R omarchy-zsh
```

To restore bash, copy a backup to `~/.bashrc` (backups are saved as `.bashrc.backup-*`).
