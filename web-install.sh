#!/usr/bin/env bash
# Web installer for Minimal NixOS Configuration
# This script can be piped from curl to install the configuration remotely

set -e

# Repository information
REPO_URL="https://github.com/AEduardo-dev/daily-nix.git"
BRANCH="minimal-flakes-setup"
RAW_BASE="https://raw.githubusercontent.com/AEduardo-dev/daily-nix/$BRANCH"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

log_banner() {
    echo -e "${PURPLE}$1${NC}"
}

# Show banner
show_banner() {
    echo
    log_banner "╔══════════════════════════════════════════════════════════════╗"
    log_banner "║                 Minimal NixOS Web Installer                  ║"
    log_banner "║                                                              ║"
    log_banner "║  🚀 Remote NixOS Configuration Setup with Flakes & SOPS     ║"
    log_banner "║  🔐 SSH-based secrets management (automated)                ║"
    log_banner "║  🏠 Home Manager integration                                 ║"
    log_banner "║  ⚡ One-command installation                                 ║"
    log_banner "╟──────────────────────────────────────────────────────────────╢"
    log_banner "║  Repository: $REPO_URL  ║"
    log_banner "║  Branch: $BRANCH                           ║"
    log_banner "╚══════════════════════════════════════════════════════════════╝"
    echo
}

# Check if this is being piped from curl/wget
check_pipe_mode() {
    if [ -t 0 ]; then
        # Running interactively
        PIPE_MODE=false
    else
        # Being piped
        PIPE_MODE=true
        log_info "Running in pipe mode (input from curl/wget)"
    fi
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -q, --quiet         Quiet mode (less output)"
    echo "  -y, --yes           Auto-accept prompts where possible"
    echo "  --no-reboot         Don't prompt for reboot at the end"
    echo
    echo "Remote installation examples:"
    echo "  # Interactive installation"
    echo "  curl -L $RAW_BASE/web-install.sh | sudo bash"
    echo
    echo "  # Quiet installation"
    echo "  curl -L $RAW_BASE/web-install.sh | sudo bash -s -- -q"
    echo
    echo "  # Automated installation (still requires user input)"
    echo "  curl -L $RAW_BASE/web-install.sh | sudo bash -s -- -y --no-reboot"
    echo
}

# Parse command line arguments
parse_args() {
    QUIET=false
    AUTO_YES=false
    NO_REBOOT=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -y|--yes)
                AUTO_YES=true
                shift
                ;;
            --no-reboot)
                NO_REBOOT=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Download the main setup script
download_setup_script() {
    log_info "Downloading setup script..."
    
    local script_path="/tmp/setup-minimal.sh"
    
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$RAW_BASE/setup-minimal.sh" -o "$script_path"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$script_path" "$RAW_BASE/setup-minimal.sh"
    else
        log_error "Neither curl nor wget is available"
        exit 1
    fi
    
    chmod +x "$script_path"
    log_success "Setup script downloaded to $script_path"
    
    echo "$script_path"
}

# Main installation function
main() {
    show_banner
    check_pipe_mode
    parse_args "$@"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root or with sudo"
        echo
        echo "Try: curl -L $RAW_BASE/web-install.sh | sudo bash"
        exit 1
    fi
    
    # Check if on NixOS
    if [ ! -f /etc/NIXOS ]; then
        log_error "This installer must be run on NixOS"
        echo
        echo "Please install NixOS first, then run this installer."
        echo "Visit: https://nixos.org/download.html"
        exit 1
    fi
    
    log_success "NixOS detected, proceeding with installation..."
    echo
    
    # Download and execute the setup script
    local setup_script
    setup_script=$(download_setup_script)
    
    log_info "Starting NixOS configuration setup..."
    echo
    
    # Build command line arguments for setup script
    local setup_args=""
    if [ "$QUIET" = true ]; then
        setup_args="$setup_args -q"
    fi
    if [ "$AUTO_YES" = true ]; then
        setup_args="$setup_args -y"
    fi
    if [ "$NO_REBOOT" = true ]; then
        setup_args="$setup_args --no-reboot"
    fi
    
    # Execute the setup script
    exec "$setup_script" $setup_args
}

main "$@"