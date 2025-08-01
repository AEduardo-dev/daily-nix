#!/usr/bin/env bash
# Validation script for minimal NixOS configuration
# This script performs basic syntax and structure validation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

CONFIG_DIR="."
ERRORS=0

# Check if required files exist
check_file_exists() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        log_success "$description exists: $file"
    else
        log_error "$description missing: $file"
        ERRORS=$((ERRORS + 1))
    fi
}

# Check if directory exists
check_dir_exists() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        log_success "$description exists: $dir"
    else
        log_error "$description missing: $dir"
        ERRORS=$((ERRORS + 1))
    fi
}

# Basic syntax check for Nix files
check_nix_syntax() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        return
    fi
    
    # Basic checks for common syntax issues
    if grep -q "^[[:space:]]*{[[:space:]]*$" "$file" && 
       grep -q "^[[:space:]]*}[[:space:]]*$" "$file"; then
        log_success "Basic syntax check passed: $file"
    else
        log_warning "Potential syntax issues in: $file"
    fi
}

log_info "🔍 Validating Minimal NixOS Configuration"
echo

# Check main configuration files
log_info "Checking main configuration files..."
check_file_exists "flake.nix" "Main flake configuration"
check_file_exists "setup-minimal.sh" "Setup script"
check_file_exists "README-minimal.md" "Documentation"

echo

# Check minimal-config directory
log_info "Checking minimal-config directory..."
check_dir_exists "minimal-config" "Minimal configuration directory"
check_file_exists "minimal-config/system.nix" "System configuration"
check_file_exists "minimal-config/home.nix" "Home manager configuration"
check_file_exists "minimal-config/hardware.nix" "Hardware configuration template"
check_file_exists "minimal-config/.sops.yaml" "SOPS configuration"
check_file_exists "minimal-config/secrets.yaml" "Secrets template"

echo

# Basic syntax validation
log_info "Performing basic syntax checks..."
check_nix_syntax "flake.nix"
check_nix_syntax "minimal-config/system.nix"
check_nix_syntax "minimal-config/home.nix"
check_nix_syntax "minimal-config/hardware.nix"

echo

# Check script permissions
log_info "Checking script permissions..."
if [ -x "setup-minimal.sh" ]; then
    log_success "Setup script is executable"
else
    log_warning "Setup script is not executable (will fix automatically)"
    chmod +x setup-minimal.sh
fi

echo

# Check for placeholder values that need to be replaced
log_info "Checking for placeholder values..."
if grep -q "REPLACE-WITH-" minimal-config/hardware.nix; then
    log_info "Hardware configuration contains placeholders (will be replaced during setup)"
fi

if grep -q "age1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklm" minimal-config/.sops.yaml; then
    log_info "SOPS configuration contains placeholder key (will be replaced during setup)"
fi

echo

# Validate structure
log_info "Validating configuration structure..."

# Check if flake.nix has required sections
if grep -q "nixosConfigurations" flake.nix; then
    log_success "Flake contains nixosConfigurations"
else
    log_error "Flake missing nixosConfigurations"
    ERRORS=$((ERRORS + 1))
fi

if grep -q "homeConfigurations" flake.nix; then
    log_success "Flake contains homeConfigurations"
else
    log_error "Flake missing homeConfigurations"
    ERRORS=$((ERRORS + 1))
fi

# Check if system.nix has required sections
if grep -q "sops.*=" minimal-config/system.nix; then
    log_success "System configuration includes SOPS setup"
else
    log_warning "System configuration may be missing SOPS setup"
fi

echo

# Final validation result
if [ $ERRORS -eq 0 ]; then
    log_success "🎉 Configuration validation passed!"
    echo
    echo "Next steps:"
    echo "1. Run the setup script: sudo ./setup-minimal.sh"
    echo "2. Or test with Nix if available: nix flake check"
    echo
else
    log_error "❌ Configuration validation failed with $ERRORS errors"
    echo
    echo "Please fix the errors above before proceeding."
    exit 1
fi