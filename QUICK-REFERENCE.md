# Quick Reference - Minimal NixOS Configuration

## 🚀 Installation

### Remote One-Liner
```bash
curl -L https://raw.githubusercontent.com/AEduardo-dev/daily-nix/minimal-flakes-setup/web-install.sh | sudo bash
```

### Manual Installation
```bash
git clone -b minimal-flakes-setup https://github.com/AEduardo-dev/daily-nix.git
cd daily-nix
sudo ./setup-minimal.sh
```

## 🔧 System Management

### Rebuild System
```bash
sudo nixos-rebuild switch --flake .#hostname
```

### Rebuild with Trace (Debug)
```bash
sudo nixos-rebuild switch --flake .#hostname --show-trace
```

### Build Without Applying
```bash
sudo nixos-rebuild build --flake .#hostname
```

### Rollback to Previous Generation
```bash
sudo nixos-rebuild switch --rollback
```

## 🏠 Home Manager

### Apply Home Configuration
```bash
home-manager switch --flake .#user@hostname
```

### List Home Generations
```bash
home-manager generations
```

### Remove Old Generations
```bash
home-manager expire-generations "-7 days"
```

## 🔐 Secrets Management

### Edit Secrets
```bash
sops minimal-config/secrets.yaml
```

### Add New Secret
1. Edit secrets file: `sops minimal-config/secrets.yaml`
2. Add secret in editor: `new-secret: your-secret-value`
3. Update system config to use secret:
   ```nix
   sops.secrets.new-secret = {
     owner = config.users.users.username.name;
   };
   ```
4. Rebuild system

### Regenerate SSH Host Key (if needed)
```bash
sudo rm /etc/ssh/ssh_host_ed25519_key*
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
# Re-run setup script to update SOPS configuration
```

## 🛠️ Customization

### Edit System Configuration
```bash
sudo nano /etc/nixos/minimal-config/system.nix
sudo nixos-rebuild switch --flake .#hostname
```

### Edit User Configuration
```bash
nano /etc/nixos/minimal-config/home.nix
home-manager switch --flake .#user@hostname
```

### Add System Package
```nix
# In system.nix
environment.systemPackages = with pkgs; [
  # existing packages...
  neofetch
  htop
];
```

### Add User Package
```nix
# In home.nix
home.packages = with pkgs; [
  # existing packages...
  discord
  spotify
];
```

## 🧹 Maintenance

### Update System
```bash
nix flake update
sudo nixos-rebuild switch --flake .#hostname
```

### Garbage Collection
```bash
sudo nix-collect-garbage -d    # System
nix-collect-garbage -d         # User
```

### Optimize Store
```bash
nix-store --optimize
```

### Check Store Integrity
```bash
nix-store --verify --check-contents
```

## 📊 System Information

### List System Generations
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Current System Configuration
```bash
nixos-version
```

### Check Configuration
```bash
nix flake check
```

### Show System Configuration
```bash
nixos-option system.build.toplevel
```

## 🔍 Troubleshooting

### Check System Logs
```bash
journalctl -xe                 # Recent errors
journalctl -u nixos-rebuild    # Rebuild logs
journalctl -f                  # Follow logs
```

### Debug Build Issues
```bash
sudo nixos-rebuild switch --flake .#hostname --show-trace --verbose
```

### Check SOPS Status
```bash
systemctl status sops-nix      # SOPS service status
ls -la /run/secrets/           # Available secrets
```

### Validate Configuration
```bash
./validate-minimal.sh          # Custom validator
nix flake check                # Flake validation
```

## 📁 Important Paths

- Configuration: `/etc/nixos/`
- System profile: `/nix/var/nix/profiles/system`
- User profile: `~/.local/state/nix/profiles/home-manager`
- Secrets: `/run/secrets/`
- SSH host key: `/etc/ssh/ssh_host_ed25519_key`

## 🌐 Network Configuration

### Enable/Disable NetworkManager
```nix
# In system.nix
services.networkmanager.enable = true;  # or false
```

### Configure Static IP
```nix
# In system.nix
networking = {
  interfaces.eth0 = {
    ipv4.addresses = [{
      address = "192.168.1.100";
      prefixLength = 24;
    }];
  };
  defaultGateway = "192.168.1.1";
  nameservers = [ "8.8.8.8" "8.8.4.4" ];
};
```

## 🖥️ Desktop Environment

### Switch to Different Desktop
```nix
# In system.nix - XFCE instead of GNOME
services.xserver = {
  enable = true;
  displayManager.lightdm.enable = true;
  desktopManager.xfce.enable = true;
  # Disable GNOME
  displayManager.gdm.enable = false;
  desktopManager.gnome.enable = false;
};
```

### Disable Desktop (Server Mode)
```nix
# In system.nix
services.xserver.enable = false;
```

## 🔄 Multi-Host Setup

### Add New Host
```nix
# In flake.nix
nixosConfigurations = {
  desktop = mkHost { hostname = "desktop"; username = "user"; };
  laptop = mkHost { hostname = "laptop"; username = "user"; };  # Add this
};
```

### Deploy to Different Host
```bash
sudo nixos-rebuild switch --flake .#laptop
```

## ⚡ Quick Commands

```bash
# Rebuild system
sudo nixos-rebuild switch --flake .

# Rebuild home
home-manager switch --flake .

# Update everything
nix flake update && sudo nixos-rebuild switch --flake .

# Clean everything
sudo nix-collect-garbage -d && nix-collect-garbage -d && nix-store --optimize

# Edit secrets
sops minimal-config/secrets.yaml

# Validate config
nix flake check

# Emergency rollback
sudo nixos-rebuild switch --rollback
```

---

**Need Help?** Check the full documentation in `README-minimal.md` or the technical overview in `TECHNICAL-OVERVIEW.md`.