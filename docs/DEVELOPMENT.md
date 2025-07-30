# Development Environment

This NixOS configuration includes a comprehensive development environment with modern tools and editors.

## Included Tools

### Core Development Environment
- **Neovim** with LazyVim configuration and LSP support
- **Modern CLI Tools**: ripgrep, bat, eza, fzf, and more
- **Version Control**: Git with enhanced configuration, LazyGit, GitHub CLI
- **Container Technologies**: Docker and Podman with compose support
- **Cloud Tools**: kubectl, terraform, ansible, AWS CLI, etc.

### Neovim Configuration

The Neovim setup is based on LazyVim and includes:
- **LSP Support** for multiple languages
- **Syntax Highlighting** with Treesitter
- **Auto-completion** with nvim-cmp
- **File Explorer** with Neo-tree
- **Fuzzy Finding** with Telescope
- **Git Integration** with Gitsigns

### Terminal Setup
- **Alacritty** terminal with customization
- **Zsh** with Oh My Zsh and Starship prompt
- **Auto-suggestions** and **syntax highlighting**

### Database Development
- **PostgreSQL** and **Redis** for local development
- **SQLite** embedded support

## LazyVim Configuration

The LazyVim configuration can be extended by:
1. Adding a git repository containing LazyVim configurations
2. Using the built-in nixvim module for declarative configuration
3. Customizing through home-manager modules

For custom LazyVim configurations from git repositories, see the configuration modules.