#!/usr/bin/env bash
# Minimal NixOS Flakes Setup Script
# Can be run remotely to bootstrap a complete NixOS configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration variables
REPO_URL="https://github.com/AEduardo-dev/daily-nix.git"
BRANCH="minimal-flakes-setup"
CONFIG_DIR="/tmp/minimal-nixos-config"
TARGET_DIR="/etc/nixos"

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if running on NixOS
    if [ ! -f /etc/NIXOS ]; then
        log_error "This script must be run on NixOS"
        exit 1
    fi
    
    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
    
    # Check if flakes are enabled
    if ! nix flake --help >/dev/null 2>&1; then
        log_warning "Nix flakes are not enabled. Enabling temporarily..."
        export NIX_CONFIG="experimental-features = nix-command flakes"
    fi
    
    log_success "Prerequisites check passed"
}

# Function to gather user input
gather_user_input() {
    log_info "Gathering configuration information..."
    
    # Username
    while [ -z "$USERNAME" ]; do
        read -p "Enter desired username: " USERNAME
        if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            log_error "Invalid username. Use lowercase letters, numbers, underscores, and hyphens only."
            USERNAME=""
        fi
    done
    
    # Full name
    read -p "Enter full name [$USERNAME]: " FULLNAME
    FULLNAME=${FULLNAME:-$USERNAME}
    
    # Email
    read -p "Enter email address: " EMAIL
    while [[ ! "$EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; do
        log_error "Invalid email address format"
        read -p "Enter email address: " EMAIL
    done
    
    # Hostname
    CURRENT_HOSTNAME=$(hostname)
    read -p "Enter hostname [$CURRENT_HOSTNAME]: " HOSTNAME
    HOSTNAME=${HOSTNAME:-$CURRENT_HOSTNAME}
    
    # System type
    echo ""
    log_info "Select system type:"
    echo "1) Desktop with GNOME (default)"
    echo "2) Server/Headless"
    echo "3) Minimal desktop"
    read -p "Choice [1]: " SYSTEM_TYPE
    SYSTEM_TYPE=${SYSTEM_TYPE:-1}
    
    # Password
    echo ""
    log_info "Setting up user password..."
    while true; do
        read -s -p "Enter password for $USERNAME: " PASSWORD
        echo
        read -s -p "Confirm password: " PASSWORD_CONFIRM
        echo
        if [ "$PASSWORD" = "$PASSWORD_CONFIRM" ]; then
            break
        else
            log_error "Passwords do not match. Please try again."
        fi
    done
    
    log_success "Configuration information gathered"
}

# Function to clone or download configuration
setup_config() {
    log_info "Setting up configuration files..."
    
    # Clean up any existing config
    rm -rf "$CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
    
    # Clone repository
    if command -v git >/dev/null 2>&1; then
        log_info "Cloning configuration repository..."
        git clone -b "$BRANCH" "$REPO_URL" "$CONFIG_DIR"
    else
        log_info "Git not available, downloading archive..."
        # Fallback to wget/curl
        if command -v wget >/dev/null 2>&1; then
            wget -O "$CONFIG_DIR.zip" "https://github.com/AEduardo-dev/daily-nix/archive/$BRANCH.zip"
        elif command -v curl >/dev/null 2>&1; then
            curl -L -o "$CONFIG_DIR.zip" "https://github.com/AEduardo-dev/daily-nix/archive/$BRANCH.zip"
        else
            log_error "Neither git, wget, nor curl is available"
            exit 1
        fi
        
        # Extract archive
        unzip -q "$CONFIG_DIR.zip" -d "$(dirname "$CONFIG_DIR")"
        mv "$(dirname "$CONFIG_DIR")/daily-nix-$BRANCH" "$CONFIG_DIR"
        rm "$CONFIG_DIR.zip"
    fi
    
    log_success "Configuration files downloaded"
}

# Function to detect hardware configuration
detect_hardware() {
    log_info "Detecting hardware configuration..."
    
    # Generate hardware configuration
    nixos-generate-config --show-hardware-config > "$CONFIG_DIR/minimal-config/hardware.nix"
    
    log_success "Hardware configuration generated"
}

# Function to setup SSH keys for SOPS
setup_sops_ssh() {
    log_info "Setting up SOPS with SSH keys..."
    
    # Ensure SSH host key exists
    if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
        log_info "Generating SSH host key..."
        ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
    fi
    
    # Convert SSH key to age key for SOPS
    SSH_PUB_KEY=$(cat /etc/ssh/ssh_host_ed25519_key.pub)
    AGE_KEY=$(echo "$SSH_PUB_KEY" | ssh-to-age)
    
    log_info "SSH host key converted to age key: $AGE_KEY"
    
    # Update SOPS configuration
    sed -i "s/age1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklm/$AGE_KEY/g" \
        "$CONFIG_DIR/minimal-config/.sops.yaml"
    
    # Generate password hash
    PASSWORD_HASH=$(echo "$PASSWORD" | mkpasswd -m sha-512 -s)
    
    # Create temporary SOPS file with password
    cat > "$CONFIG_DIR/minimal-config/secrets-temp.yaml" << EOF
user-password: "$PASSWORD_HASH"
EOF
    
    # Encrypt the secrets file
    SOPS_AGE_RECIPIENTS="$AGE_KEY" sops -e "$CONFIG_DIR/minimal-config/secrets-temp.yaml" > "$CONFIG_DIR/minimal-config/secrets.yaml"
    rm "$CONFIG_DIR/minimal-config/secrets-temp.yaml"
    
    log_success "SOPS configuration completed with SSH keys"
}

# Function to customize configuration
customize_config() {
    log_info "Customizing configuration..."
    
    # Create custom flake.nix based on user input
    cat > "$CONFIG_DIR/flake.nix" << EOF
{
  description = "Custom NixOS Configuration for $HOSTNAME";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.\${system};
    in
    {
      nixosConfigurations.$HOSTNAME = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { hostname = "$HOSTNAME"; username = "$USERNAME"; };
        modules = [
          ./minimal-config/system.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.$USERNAME = import ./minimal-config/home.nix;
              extraSpecialArgs = { hostname = "$HOSTNAME"; username = "$USERNAME"; };
            };
          }
          ./minimal-config/hardware.nix
          {
            networking.hostName = "$HOSTNAME";
            users.users.$USERNAME = {
              isNormalUser = true;
              description = "$FULLNAME";
              extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
              hashedPasswordFile = "/run/secrets/user-password";
            };
          }
EOF

    # Add system-specific configuration
    case $SYSTEM_TYPE in
        2) # Server/Headless
            cat >> "$CONFIG_DIR/flake.nix" << EOF
          # Disable desktop environment for server
          {
            services.xserver.enable = false;
            services.xserver.displayManager.gdm.enable = false;
            services.xserver.desktopManager.gnome.enable = false;
          }
EOF
            ;;
        3) # Minimal desktop
            cat >> "$CONFIG_DIR/flake.nix" << EOF
          # Minimal desktop configuration
          {
            services.xserver.desktopManager.xfce.enable = true;
            services.xserver.displayManager.lightdm.enable = true;
            services.xserver.desktopManager.gnome.enable = false;
            services.displayManager.gdm.enable = false;
          }
EOF
            ;;
    esac

    cat >> "$CONFIG_DIR/flake.nix" << EOF
        ];
      };

      homeConfigurations."$USERNAME@$HOSTNAME" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { hostname = "$HOSTNAME"; username = "$USERNAME"; };
        modules = [ ./minimal-config/home.nix ];
      };
    };
}
EOF
    
    # Update home manager configuration with user details
    sed -i "s/userName = \"User\"/userName = \"$FULLNAME\"/" "$CONFIG_DIR/minimal-config/home.nix"
    sed -i "s/userEmail = \"user@example.com\"/userEmail = \"$EMAIL\"/" "$CONFIG_DIR/minimal-config/home.nix"
    
    log_success "Configuration customized for $USERNAME@$HOSTNAME"
}

# Function to install configuration
install_config() {
    log_info "Installing configuration..."
    
    # Backup existing configuration if it exists
    if [ -d "$TARGET_DIR" ] && [ "$(ls -A "$TARGET_DIR")" ]; then
        log_warning "Backing up existing configuration..."
        cp -r "$TARGET_DIR" "$TARGET_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copy new configuration
    cp -r "$CONFIG_DIR/." "$TARGET_DIR/"
    
    # Set proper permissions
    chmod 600 "$TARGET_DIR/minimal-config/secrets.yaml"
    
    log_success "Configuration installed to $TARGET_DIR"
}

# Function to apply configuration
apply_config() {
    log_info "Applying NixOS configuration..."
    
    # Build and switch to new configuration
    cd "$TARGET_DIR"
    
    # Check configuration first
    log_info "Validating configuration..."
    nix flake check
    
    # Apply the configuration
    log_info "Applying configuration (this may take a while)..."
    nixos-rebuild switch --flake ".#$HOSTNAME"
    
    log_success "NixOS configuration applied successfully!"
}

# Function to setup user environment
setup_user_environment() {
    log_info "Setting up user environment..."
    
    # Switch to user and apply home-manager configuration
    sudo -u "$USERNAME" bash -c "
        cd '$TARGET_DIR'
        nix run home-manager -- switch --flake '.#$USERNAME@$HOSTNAME'
    "
    
    log_success "User environment configured"
}

# Function to display final instructions
show_final_instructions() {
    echo ""
    log_success "🎉 Installation completed successfully!"
    echo ""
    echo "System Information:"
    echo "  Hostname: $HOSTNAME"
    echo "  Username: $USERNAME"
    echo "  Email: $EMAIL"
    echo ""
    echo "Next steps:"
    echo "1. Reboot the system: sudo reboot"
    echo "2. Log in as $USERNAME"
    echo "3. Your configuration is located at: $TARGET_DIR"
    echo ""
    echo "To modify the configuration:"
    echo "  cd $TARGET_DIR"
    echo "  sudo nano minimal-config/system.nix    # System configuration"
    echo "  nano minimal-config/home.nix           # User configuration"
    echo "  sudo nixos-rebuild switch --flake .#$HOSTNAME  # Apply changes"
    echo ""
    echo "To manage secrets:"
    echo "  sops minimal-config/secrets.yaml       # Edit encrypted secrets"
    echo ""
    echo "Configuration repository: $REPO_URL"
    echo "Branch: $BRANCH"
    echo ""
}

# Main execution
main() {
    echo ""
    log_info "🚀 Starting Minimal NixOS Flakes Setup"
    echo ""
    
    check_prerequisites
    gather_user_input
    setup_config
    detect_hardware
    setup_sops_ssh
    customize_config
    install_config
    apply_config
    setup_user_environment
    show_final_instructions
}

# Run main function
main "$@"