#!/usr/bin/env bash
# Setup script for initial configuration

set -e

echo "🚀 Setting up NixOS Daily Driver Configuration"
echo

# Check if we're on NixOS
if [ ! -f /etc/NIXOS ]; then
    echo "❌ This script must be run on NixOS"
    exit 1
fi

# Check if flakes are enabled
if ! nix flake --help >/dev/null 2>&1; then
    echo "❌ Nix flakes are not enabled. Please enable them in your configuration."
    echo "Add this to your configuration.nix:"
    echo "nix.settings.experimental-features = [ \"nix-command\" \"flakes\" ];"
    exit 1
fi

echo "✅ NixOS detected"
echo "✅ Nix flakes available"
echo

# Function to prompt for user input
prompt_user() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    read -p "$prompt [$default]: " input
    eval "$var_name=\"${input:-$default}\""
}

# Get user information
echo "📝 User Configuration"
prompt_user "Enter your username" "user" USERNAME
prompt_user "Enter your full name" "Your Name" FULLNAME
prompt_user "Enter your email address" "your.email@example.com" EMAIL
prompt_user "Enter your hostname" "nixos-desktop" HOSTNAME

echo

# Update user configuration
echo "🔧 Updating user configuration..."
sed -i "s/username = \"user\"/username = \"$USERNAME\"/" users/default.nix
sed -i "s/homeDirectory = \"\/home\/user\"/homeDirectory = \"\/home\/$USERNAME\"/" users/default.nix
sed -i "s/userName = \"Your Name\"/userName = \"$FULLNAME\"/" users/default.nix
sed -i "s/userEmail = \"your.email@example.com\"/userEmail = \"$EMAIL\"/" users/default.nix

# Update home configuration
sed -i "s/username = \"user\"/username = \"$USERNAME\"/" users/home.nix
sed -i "s/homeDirectory = \"\/home\/user\"/homeDirectory = \"\/home\/$USERNAME\"/" users/home.nix
sed -i "s/userName = \"Your Name\"/userName = \"$FULLNAME\"/" users/home.nix
sed -i "s/userEmail = \"your.email@example.com\"/userEmail = \"$EMAIL\"/" users/home.nix

# Update hostname
sed -i "s/networking.hostName = \"nixos-desktop\"/networking.hostName = \"$HOSTNAME\"/" hosts/desktop/default.nix

# Update flake home configuration
sed -i "s/\"user@desktop\"/\"$USERNAME@$HOSTNAME\"/" flake.nix

echo "✅ Configuration updated"
echo

# Generate hardware configuration
echo "🖥️ Generating hardware configuration..."
if [ -f hosts/desktop/hardware-configuration.nix ]; then
    echo "⚠️  hardware-configuration.nix already exists. Backing up..."
    cp hosts/desktop/hardware-configuration.nix hosts/desktop/hardware-configuration.nix.backup
fi

sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix
echo "✅ Hardware configuration generated"
echo

# SOPS setup (optional)
echo "🔐 SOPS Setup (optional)"
read -p "Do you want to set up SOPS for secrets management? (y/N): " setup_sops

if [[ $setup_sops =~ ^[Yy]$ ]]; then
    echo "Setting up SOPS..."
    
    # Create age key if it doesn't exist
    if [ ! -f ~/.config/sops/age/keys.txt ]; then
        echo "Generating age key..."
        mkdir -p ~/.config/sops/age
        age-keygen -o ~/.config/sops/age/keys.txt
        echo "✅ Age key generated at ~/.config/sops/age/keys.txt"
    else
        echo "✅ Age key already exists"
    fi
    
    # Get public key
    PUBLIC_KEY=$(age-keygen -y ~/.config/sops/age/keys.txt)
    echo "Your public age key: $PUBLIC_KEY"
    
    # Update .sops.yaml with the actual key
    sed -i "s/age1hl7ldhs3tgk6j4y8rj9vd5j0yxlvgxb5jqrfj8l7z2kd0pv6q9s6e8r3n/$PUBLIC_KEY/" secrets/.sops.yaml
    
    echo "✅ SOPS configuration updated"
    echo "You can now edit secrets with: sops secrets/secrets.yaml"
else
    echo "⏭️  Skipping SOPS setup"
fi

echo
echo "🎉 Setup complete!"
echo
echo "Next steps:"
echo "1. Review and customize the configuration files as needed"
echo "2. Run: sudo nixos-rebuild switch --flake .#$HOSTNAME"
echo "3. After reboot, run: home-manager switch --flake .#$USERNAME@$HOSTNAME"
echo
echo "For more information, see the README.md file."