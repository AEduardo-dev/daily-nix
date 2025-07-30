# NixOS Daily Driver Configuration

A comprehensive NixOS configuration for development workstations with GNOME desktop environment, featuring development tools, gaming support, and secure secrets management.

## Features

### 🖥️ Desktop Environment
- **GNOME Desktop** with dark theme and custom extensions
- **Brave Browser** as default browser
- **Alacritty** terminal with customized configuration
- **Popular applications**: Discord, Telegram, Spotify, LibreOffice, etc.

### 🛠️ Development Environment
- **Neovim with LazyVim**: Fully configured with LSP, syntax highlighting, and modern plugins
- **Programming Languages**: Python, Rust, Go, Node.js, Java, .NET, C/C++
- **Containerization**: Docker and Podman with rootless support
- **Database Tools**: PostgreSQL, Redis, MongoDB tools
- **Cloud Tools**: kubectl, terraform, ansible, AWS CLI, etc.
- **Modern CLI Tools**: ripgrep, bat, eza, fzf, and more

### 🎮 Gaming Support
- **Steam** with Proton compatibility
- **Heroic Games Launcher** for Epic Games and GOG
- **Lutris** and Wine for Windows games
- **Emulation**: RetroArch, Dolphin, PCSX2, RPCS3
- **Performance Tools**: GameMode, MangoHUD

### 🔐 Security & Secrets
- **SOPS** for encrypted secrets management
- **GPG** integration for commit signing
- **Firewall** configuration with security hardening
- **AppArmor** for application sandboxing

### 🏠 Home Manager Integration
- Declarative user environment configuration
- Application theming and desktop customization
- Development tool configurations

## Quick Start

### Prerequisites

1. **NixOS Installation**: Ensure you have NixOS installed with flakes enabled
2. **Hardware Configuration**: Generate your hardware configuration
3. **Age Key**: Generate an age key for SOPS (optional)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/AEduardo-dev/daily-nix.git
   cd daily-nix
   ```

2. **Generate hardware configuration**:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix
   ```

3. **Customize user settings**:
   Edit `users/default.nix` and update:
   - Username (change from "user" to your desired username)
   - Git configuration (name, email)
   - SSH keys
   - Initial password

4. **Update flake inputs** (optional):
   ```bash
   nix flake update
   ```

5. **Apply the configuration**:
   ```bash
   sudo nixos-rebuild switch --flake .#desktop
   ```

6. **Apply home-manager configuration** (after reboot):
   ```bash
   home-manager switch --flake .#user@desktop
   ```

## Configuration Structure

```
├── flake.nix                 # Main flake configuration
├── hosts/
│   └── desktop/
│       ├── default.nix       # Desktop host configuration
│       └── hardware-configuration.nix
├── modules/
│   ├── system/
│   │   ├── desktop.nix       # GNOME desktop environment
│   │   ├── development.nix   # Development tools and services
│   │   ├── gaming.nix        # Gaming applications and optimizations
│   │   └── security.nix      # Security hardening and SOPS
│   └── home/
│       ├── neovim.nix        # Neovim with LazyVim configuration
│       ├── development.nix   # Development tools for home-manager
│       └── desktop.nix       # Desktop applications and theming
├── users/
│   ├── default.nix           # User configuration
│   └── home.nix              # Standalone home-manager config
└── secrets/
    ├── .sops.yaml            # SOPS configuration
    └── secrets.yaml          # Encrypted secrets (example)
```

## Customization Guide

### Adding a New Host

1. Create a new directory in `hosts/`:
   ```bash
   mkdir hosts/laptop
   cp hosts/desktop/default.nix hosts/laptop/
   ```

2. Update the configuration for your new host

3. Add it to `flake.nix`:
   ```nix
   nixosConfigurations = {
     desktop = mkSystem "desktop";
     laptop = mkSystem "laptop";  # Add this line
   };
   ```

### Modifying Development Tools

Edit `modules/system/development.nix` or `modules/home/development.nix` to:
- Add new programming languages
- Install additional development tools
- Configure language-specific tools

### Gaming Configuration

Modify `modules/system/gaming.nix` to:
- Add new gaming platforms
- Configure graphics drivers (NVIDIA/AMD)
- Adjust performance settings

### Desktop Customization

Edit `modules/home/desktop.nix` to:
- Change GTK/Qt themes
- Modify GNOME settings
- Add new desktop applications

## SOPS Secrets Management

### Setup

1. **Generate an age key**:
   ```bash
   mkdir -p ~/.config/sops/age
   age-keygen -o ~/.config/sops/age/keys.txt
   ```

2. **Update `.sops.yaml`** with your public key

3. **Create/edit secrets**:
   ```bash
   sops secrets/secrets.yaml
   ```

### Using Secrets

Reference secrets in your configuration:
```nix
sops.secrets."user-password" = {
  neededForUsers = true;
};

users.users.user = {
  hashedPasswordFile = config.sops.secrets."user-password".path;
};
```

## Troubleshooting

### Common Issues

1. **Hardware configuration mismatch**:
   - Regenerate: `sudo nixos-generate-config --show-hardware-config`
   - Update UUIDs in `hardware-configuration.nix`

2. **Graphics issues**:
   - Uncomment appropriate driver in `modules/system/gaming.nix`
   - For NVIDIA: Enable nvidia settings
   - For AMD: Usually works out of the box

3. **Build errors**:
   - Check flake syntax: `nix flake check`
   - Update inputs: `nix flake update`
   - Clean build: `sudo nix-collect-garbage -d`

4. **Home-manager conflicts**:
   - Remove existing home-manager: `home-manager uninstall`
   - Apply configuration: `home-manager switch --flake .#user@desktop`

### Performance Optimization

1. **Enable garbage collection**:
   ```bash
   sudo nix-collect-garbage -d
   nix-store --optimize
   ```

2. **Gaming performance**:
   - Set CPU governor to performance in `modules/system/gaming.nix`
   - Enable GameMode for supported games
   - Use MangoHUD for performance monitoring

## Development Workflow

### Using the Development Shell

```bash
nix develop
```

This provides tools for working with the configuration:
- nixd (language server)
- nixpkgs-fmt / alejandra (formatters)
- sops (secrets management)

### Testing Changes

1. **Check configuration**:
   ```bash
   nix flake check
   ```

2. **Test build without applying**:
   ```bash
   nixos-rebuild build --flake .#desktop
   ```

3. **Apply changes**:
   ```bash
   sudo nixos-rebuild switch --flake .#desktop
   ```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Useful Commands

### NixOS Operations
```bash
# Rebuild system
sudo nixos-rebuild switch --flake .#desktop

# Rebuild and show trace on error
sudo nixos-rebuild switch --flake .#desktop --show-trace

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

### Home Manager Operations
```bash
# Apply home configuration
home-manager switch --flake .#user@desktop

# List home generations
home-manager generations

# Remove result links
rm result*
```

### Maintenance
```bash
# Update flake inputs
nix flake update

# Garbage collection
sudo nix-collect-garbage -d
nix-collect-garbage -d

# Optimize store
nix-store --optimize

# Check store consistency
nix-store --verify --check-contents
```

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review NixOS documentation
3. Open an issue on the repository
4. Join NixOS community forums

## License

This configuration is provided under the MIT License. See LICENSE file for details.
