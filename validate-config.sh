#!/usr/bin/env bash

# Configuration Validation Script for daily-nix
# This script helps validate that the configuration is set up correctly

set -e

echo "🔍 Validating daily-nix configuration..."
echo

# Check if configuration.nix exists
if [ ! -f "configuration.nix" ]; then
    echo "❌ configuration.nix not found!"
    echo "   Please copy configuration.example.nix to configuration.nix and customize it"
    exit 1
fi
echo "✅ configuration.nix found"

# Check if SOPS configuration exists
if [ ! -f "secrets/.sops.yaml" ]; then
    echo "❌ SOPS configuration not found at secrets/.sops.yaml"
    exit 1
fi
echo "✅ SOPS configuration found"

# Check if secrets.yaml exists
if [ ! -f "secrets/secrets.yaml" ]; then
    echo "❌ secrets.yaml not found!"
    echo "   Please create and encrypt your secrets file"
    exit 1
fi
echo "✅ secrets.yaml found"

# Check if hardware configuration exists
HOSTNAME=${1:-$(hostname)}
HARDWARE_CONFIG_PATH="hosts/$HOSTNAME/hardware-configuration.nix"
if [ ! -f "$HARDWARE_CONFIG_PATH" ]; then
    echo "❌ Hardware configuration not found at $HARDWARE_CONFIG_PATH!"
    echo "   Please run: sudo nixos-generate-config --show-hardware-config > $HARDWARE_CONFIG_PATH"
    exit 1
fi
echo "✅ Hardware configuration found at $HARDWARE_CONFIG_PATH"

# Check if age key directory exists (warn only)
if [ ! -d "$HOME/.config/sops/age" ]; then
    echo "⚠️  Age key directory not found at ~/.config/sops/age"
    echo "   You may need to run: mkdir -p ~/.config/sops/age && age-keygen -o ~/.config/sops/age/keys.txt"
else
    echo "✅ Age key directory found"
fi

# Check for required tools
echo
echo "🔧 Checking required tools..."

check_tool() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ $1 found"
    else
        echo "❌ $1 not found - install with: nix-shell -p $1"
    fi
}

check_tool "sops"
check_tool "age"
check_tool "git"

echo
echo "🎉 Configuration validation complete!"
echo
echo "Next steps:"
echo "1. Customize configuration.nix with your settings"
echo "2. Set up age key: age-keygen -o ~/.config/sops/age/keys.txt"
echo "3. Update .sops.yaml with your public key"
echo "4. Create encrypted secrets: sops secrets/secrets.yaml"
echo "5. Apply configuration: sudo nixos-rebuild switch --flake .#desktop"
echo