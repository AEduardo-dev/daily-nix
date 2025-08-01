# Minimal NixOS Configuration - Technical Overview

This document provides a technical overview of the minimal NixOS flakes configuration created for the daily-nix repository.

## Architecture Overview

The configuration is designed around these core principles:
- **Minimal**: Only essential packages and services
- **Generic**: Works on any hardware with auto-detection
- **Remote**: Can be deployed without cloning the repository
- **Automated**: SSH-based SOPS requires no manual key management
- **Modular**: Clear separation between system and user configuration

## Component Breakdown

### 1. Flake Configuration (`flake.nix`)

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager = { ... };
  sops-nix = { ... };
};
```

**Key Features:**
- Uses nixpkgs unstable for latest packages
- Integrates home-manager for user environment
- Includes sops-nix for secrets management
- Provides helper functions for creating custom hosts

### 2. System Configuration (`minimal-config/system.nix`)

**Core Services:**
- SSH with key-only authentication
- NetworkManager for networking
- PipeWire for audio
- Basic GNOME desktop (optional)

**Security:**
- Firewall enabled (SSH port only)
- Immutable users (declarative management)
- SOPS integration for secrets
- AppArmor support

**Hardware Support:**
- All firmware enabled
- OpenGL with 32-bit support
- Bluetooth enabled
- Modern audio stack (PipeWire)

### 3. Home Manager Configuration (`minimal-config/home.nix`)

**Essential Applications:**
- Firefox browser
- Alacritty terminal
- LibreOffice suite
- Basic development tools

**Development Environment:**
- Git with sensible defaults
- Vim with syntax highlighting
- Bash with enhanced completion
- Modern CLI tools

**Desktop Integration:**
- Dark theme preference
- XDG directory structure
- GTK theme configuration
- Font management

### 4. SOPS Integration (SSH-based)

**How It Works:**
1. Uses SSH host key (`/etc/ssh/ssh_host_ed25519_key`)
2. Converts SSH key to age format using `ssh-to-age`
3. Configures SOPS to use the converted key
4. Automatically decrypts secrets at boot

**Benefits:**
- No manual key generation required
- Automatic key rotation with host key regeneration
- Secure by design (host key permissions)
- Works out of the box on any NixOS system

### 5. Hardware Auto-Detection

The setup script automatically:
- Generates hardware configuration with `nixos-generate-config`
- Detects CPU type (Intel/AMD) for microcode updates
- Configures appropriate kernel modules
- Sets up file system mounts and swap

## Installation Flow

### Remote Installation Process

1. **Download**: Web installer downloads setup script
2. **Validation**: Checks NixOS and prerequisites
3. **Input**: Interactive prompts for user configuration
4. **Hardware**: Auto-detects and generates hardware config
5. **SOPS**: Sets up SSH-based secrets management
6. **Customization**: Creates personalized flake configuration
7. **Installation**: Copies config to `/etc/nixos`
8. **Application**: Builds and switches to new configuration

### Security Considerations

**SSH Key Management:**
- Uses system SSH host key (managed by NixOS)
- Key rotation handled by standard SSH key management
- No user key management required

**Secret Storage:**
- All secrets encrypted with SOPS
- User password stored as hashed value
- Secrets decrypted at boot time only

**System Hardening:**
- Firewall enabled by default
- SSH password authentication disabled
- Immutable user configuration
- Minimal attack surface

## Customization Points

### System Level (`system.nix`)
- Services configuration
- Package installation
- Security settings
- Hardware drivers

### User Level (`home.nix`)
- Application preferences
- Shell configuration
- Desktop themes
- Development tools

### Secrets Management
- Add new secrets to `secrets.yaml`
- Configure secret usage in system configuration
- Automatic decryption and permission management

## Directory Structure

```
├── flake.nix                    # Main flake configuration
├── minimal-config/
│   ├── system.nix              # System configuration
│   ├── home.nix                # User environment
│   ├── hardware.nix            # Hardware configuration
│   ├── .sops.yaml              # SOPS configuration
│   └── secrets.yaml            # Encrypted secrets
├── setup-minimal.sh            # Interactive setup script
├── web-install.sh              # Remote web installer
├── validate-minimal.sh         # Configuration validator
└── README-minimal.md           # User documentation
```

## Deployment Options

### 1. One-Command Remote Installation
```bash
curl -L https://raw.githubusercontent.com/AEduardo-dev/daily-nix/minimal-flakes-setup/web-install.sh | sudo bash
```

### 2. Manual Installation
```bash
git clone -b minimal-flakes-setup https://github.com/AEduardo-dev/daily-nix.git
cd daily-nix
sudo ./setup-minimal.sh
```

### 3. Custom Host Configuration
```nix
# Create custom host in flake.nix
nixosConfigurations.mylaptop = nixpkgs.lib.nixosSystem {
  # ... custom configuration
};
```

## System Types

### Desktop (Default)
- Full GNOME desktop environment
- GDM display manager
- Complete multimedia support
- Development tools included

### Server/Headless
- No desktop environment
- SSH access only
- Minimal package set
- System services only

### Minimal Desktop
- Lightweight XFCE desktop
- LightDM display manager
- Essential applications only
- Lower resource usage

## Advanced Features

### Multi-Host Support
The flake can be extended to support multiple hosts:
```nix
nixosConfigurations = {
  desktop = mkHost { hostname = "desktop"; username = "user"; };
  laptop = mkHost { hostname = "laptop"; username = "user"; };
  server = mkHost { hostname = "server"; username = "admin"; };
};
```

### Custom Modules
Additional functionality can be added through custom modules:
```nix
modules = [
  ./minimal-config/system.nix
  ./custom-modules/development.nix
  ./custom-modules/gaming.nix
];
```

### Environment-Specific Secrets
Different environments can use different secret files:
```yaml
# .sops.yaml
creation_rules:
  - path_regex: secrets/production/.*\.yaml$
    key_groups: [...]
  - path_regex: secrets/development/.*\.yaml$
    key_groups: [...]
```

## Maintenance

### Updates
```bash
# Update flake inputs
nix flake update

# Apply system updates
sudo nixos-rebuild switch --flake .#hostname
```

### Garbage Collection
```bash
# Clean old generations
sudo nix-collect-garbage -d
nix-collect-garbage -d

# Optimize store
nix-store --optimize
```

### Secret Management
```bash
# Edit secrets
sops minimal-config/secrets.yaml

# Add new secrets
sops -e -i minimal-config/secrets.yaml
```

## Integration with Original Repository

This minimal configuration can coexist with the original daily-nix configuration:
- Uses separate branch (`minimal-flakes-setup`)
- Independent flake configuration
- Can be merged or used as alternative
- Maintains same SOPS and Home Manager patterns

The minimal configuration provides a foundation that can be extended with additional modules from the main repository as needed.

## Conclusion

This minimal NixOS configuration provides a solid foundation for NixOS deployments with:
- Modern flakes-based configuration
- Automated secrets management
- Remote deployment capability
- Comprehensive documentation
- Easy customization paths

It serves as both a production-ready configuration and a learning resource for NixOS flakes and modern configuration management practices.