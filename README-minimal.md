# Minimal NixOS Flakes Configuration

A minimal, generic NixOS configuration using flakes and home-manager with automated SOPS secrets management using SSH keys.

## ✨ Features

- **🔧 Minimal & Generic**: Clean, simple configuration that works on any hardware
- **🏠 Home Manager Integration**: Declarative user environment management
- **🔐 SOPS with SSH Keys**: Automated secrets management using SSH host keys
- **🌐 Remote Setup**: Can be deployed remotely without cloning repository first
- **🖥️ Flexible Desktop**: Optional GNOME desktop, server, or minimal desktop modes
- **📦 Flakes**: Modern Nix flakes for reproducible builds
- **🎯 Auto-Detection**: Automatic hardware configuration detection
- **🚀 One-Command Setup**: Complete system setup with a single script

## 🚀 Quick Start

### Remote Installation (Recommended)

You can set up this configuration on any NixOS system without cloning the repository:

```bash
# Download and run the setup script
curl -L https://raw.githubusercontent.com/AEduardo-dev/daily-nix/minimal-flakes-setup/setup-minimal.sh | sudo bash
```

Or if you prefer to inspect the script first:

```bash
# Download the script
curl -L -o setup-minimal.sh https://raw.githubusercontent.com/AEduardo-dev/daily-nix/minimal-flakes-setup/setup-minimal.sh
chmod +x setup-minimal.sh

# Review the script
cat setup-minimal.sh

# Run the setup
sudo ./setup-minimal.sh
```

### Manual Installation

1. **Clone the repository**:
   ```bash
   git clone -b minimal-flakes-setup https://github.com/AEduardo-dev/daily-nix.git
   cd daily-nix
   ```

2. **Run the setup script**:
   ```bash
   sudo ./setup-minimal.sh
   ```

3. **Follow the interactive prompts** to configure:
   - Username and full name
   - Email address
   - Hostname
   - System type (desktop/server/minimal)
   - User password

4. **Reboot and enjoy your new NixOS system!**

## 📋 What the Setup Does

The setup script automatically:

1. ✅ **Validates Prerequisites**: Checks for NixOS and flakes support
2. 🖥️ **Hardware Detection**: Generates hardware configuration for your system
3. 🔐 **SSH-based SOPS**: Sets up secrets management using SSH host keys
4. ⚙️ **System Configuration**: Creates customized system configuration
5. 🏠 **User Environment**: Configures home-manager for your user
6. 🚀 **Applies Changes**: Builds and activates the new configuration

## 🏗️ Configuration Structure

```
├── flake.nix                 # Generated flake configuration
├── minimal-config/
│   ├── system.nix           # System-level configuration
│   ├── home.nix             # User environment configuration
│   ├── hardware.nix         # Auto-generated hardware config
│   ├── .sops.yaml           # SOPS configuration with SSH keys
│   └── secrets.yaml         # Encrypted secrets (user password)
└── setup-minimal.sh         # Setup script
```

## 🎨 Customization Guide

### System Configuration

Edit `/etc/nixos/minimal-config/system.nix` to customize:

- **Services**: Enable/disable services like SSH, desktop environment
- **Packages**: Add or remove system-wide packages
- **Security**: Modify firewall rules, user permissions
- **Hardware**: Graphics drivers, audio configuration

Example customizations:

```nix
# Enable additional services
services.docker.enable = true;
services.postgresql.enable = true;

# Add system packages
environment.systemPackages = with pkgs; [
  docker-compose
  nodejs
  python3
];

# Enable NVIDIA graphics
hardware.nvidia.modesetting.enable = true;
services.xserver.videoDrivers = [ "nvidia" ];
```

### User Environment

Edit `/etc/nixos/minimal-config/home.nix` to customize:

- **Applications**: Add or remove user applications
- **Shell Configuration**: Customize bash, aliases, prompt
- **Git Settings**: Update git configuration
- **Desktop Theme**: Modify GTK themes, fonts

Example customizations:

```nix
# Add development tools
home.packages = with pkgs; [
  vscode
  docker
  nodejs
  python3
  # ... existing packages
];

# Customize git
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
  extraConfig = {
    init.defaultBranch = "main";
    core.editor = "code";
  };
};
```

### Adding Secrets

To add new secrets:

1. **Edit the secrets file**:
   ```bash
   cd /etc/nixos
   sops minimal-config/secrets.yaml
   ```

2. **Add your secret** in the editor:
   ```yaml
   user-password: existing_encrypted_password
   api-key: your-secret-api-key
   database-password: your-db-password
   ```

3. **Update system configuration** to use the secret:
   ```nix
   # In system.nix
   sops.secrets.api-key = {
     owner = config.users.users.youruser.name;
     group = config.users.users.youruser.group;
   };
   ```

### System Types

The setup script offers three system types:

#### 1. Desktop with GNOME (Default)
- Full GNOME desktop environment
- GDM display manager
- Complete desktop applications

#### 2. Server/Headless
- No desktop environment
- SSH access only
- Minimal system packages

#### 3. Minimal Desktop
- Lightweight XFCE desktop
- LightDM display manager
- Essential desktop applications only

### Hardware Customization

The hardware configuration is auto-generated, but you can customize it:

```nix
# Enable specific kernel modules
boot.kernelModules = [ "kvm-intel" "vfio-pci" ];

# Add additional file systems
fileSystems."/mnt/data" = {
  device = "/dev/disk/by-uuid/your-uuid";
  fsType = "ext4";
};

# Configure swap
swapDevices = [
  { device = "/dev/disk/by-uuid/swap-uuid"; }
];
```

## 🔐 SOPS Secrets Management

This configuration uses SOPS with SSH keys for automated secrets management.

### How It Works

1. **SSH Host Key**: The system's SSH host key (`/etc/ssh/ssh_host_ed25519_key`) is used
2. **Age Conversion**: SSH key is converted to age format for SOPS
3. **Automatic Decryption**: Secrets are decrypted at boot using the host key
4. **No Manual Key Management**: No need to manually manage age keys

### Managing Secrets

```bash
# Edit secrets (will open your default editor)
sops minimal-config/secrets.yaml

# View encrypted secrets
cat minimal-config/secrets.yaml

# Check SOPS configuration
cat minimal-config/.sops.yaml
```

### Adding New Secrets

1. Edit the secrets file: `sops minimal-config/secrets.yaml`
2. Add your secret in the editor
3. Update system configuration to use the secret
4. Rebuild: `sudo nixos-rebuild switch --flake .#yourhostname`

## 🔧 Management Commands

### System Management

```bash
# Rebuild system configuration
sudo nixos-rebuild switch --flake .#yourhostname

# Check configuration before applying
sudo nixos-rebuild build --flake .#yourhostname

# Show system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

### Home Manager

```bash
# Apply home configuration
home-manager switch --flake .#youruser@yourhostname

# List home generations
home-manager generations

# Remove old generations
home-manager expire-generations "-7 days"
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
```

## 🌐 Remote Deployment

This configuration is designed for easy remote deployment:

### Via curl (One-liner)
```bash
curl -L https://raw.githubusercontent.com/AEduardo-dev/daily-nix/minimal-flakes-setup/setup-minimal.sh | sudo bash
```

### Via wget
```bash
wget -O - https://raw.githubusercontent.com/AEduardo-dev/daily-nix/minimal-flakes-setup/setup-minimal.sh | sudo bash
```

### For Multiple Hosts

You can customize the script for automated deployment:

```bash
# Set environment variables for automated setup
export USERNAME="myuser"
export FULLNAME="My Full Name"
export EMAIL="my.email@example.com"
export HOSTNAME="myhost"
export SYSTEM_TYPE="1"  # 1=Desktop, 2=Server, 3=Minimal
export PASSWORD="mypassword"

# Run automated setup
curl -L https://raw.githubusercontent.com/AEduardo-dev/daily-nix/minimal-flakes-setup/setup-minimal.sh | sudo bash
```

## 🚨 Troubleshooting

### Common Issues

1. **Flakes not enabled**:
   ```bash
   # Add to /etc/nixos/configuration.nix temporarily
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   sudo nixos-rebuild switch
   ```

2. **SSH key issues**:
   ```bash
   # Regenerate SSH host key
   sudo rm /etc/ssh/ssh_host_ed25519_key*
   sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
   # Re-run setup script
   ```

3. **SOPS decryption fails**:
   ```bash
   # Check if age key matches
   ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
   # Compare with key in .sops.yaml
   ```

4. **Build errors**:
   ```bash
   # Check flake syntax
   nix flake check
   
   # Show detailed error trace
   sudo nixos-rebuild switch --flake .#hostname --show-trace
   ```

### Getting Help

- Check the [NixOS manual](https://nixos.org/manual/nixos/stable/)
- Visit [NixOS Discourse](https://discourse.nixos.org/)
- Review configuration files in `/etc/nixos/minimal-config/`

## 📝 Advanced Usage

### Creating Custom Hosts

You can create additional host configurations:

```nix
# In flake.nix
nixosConfigurations = {
  desktop = nixpkgs.lib.nixosSystem { /* ... */ };
  laptop = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Custom laptop configuration
      ./hosts/laptop.nix
      # ... other modules
    ];
  };
};
```

### Multi-User Setup

Add additional users by extending the configuration:

```nix
# In system.nix
users.users = {
  user1 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/run/secrets/user1-password";
  };
  user2 = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
    hashedPasswordFile = "/run/secrets/user2-password";
  };
};
```

### Development Environment

The configuration includes a development shell:

```bash
# Enter development environment
nix develop

# Available tools: sops, ssh-to-age, git, nix
```

## 📄 License

This configuration is provided under the MIT License. See LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Happy NixOS configuration! 🎉**