# Desktop Host Configuration
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    
    # System modules
    ../../modules/system/desktop.nix
    ../../modules/system/development.nix
    ../../modules/system/gaming.nix
    ../../modules/system/security.nix
    
    # User configuration
    ../../users
  ];

  # System configuration
  system.stateVersion = "23.11";
  
  # Hostname
  networking.hostName = "nixos-desktop";
  
  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    
    # Latest kernel for better hardware support
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Enable support for NTFS (for dual boot scenarios)
    supportedFilesystems = [ "ntfs" ];
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    
    # Enable firewall
    firewall = {
      enable = true;
      # Allow common development ports
      allowedTCPPorts = [ 3000 8000 8080 8443 9000 ];
    };
  };

  # Timezone and locale
  time.timeZone = "Europe/Berlin"; # Adjust as needed
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable zsh globally
  programs.zsh.enable = true;

  # Allow unfree packages (needed for gaming and some development tools)
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Essential tools
    curl
    wget
    git
    vim
    htop
    tree
    unzip
    zip
    
    # Network tools
    networkmanagerapplet
    
    # File management
    file
    which
    
    # System monitoring
    lshw
    pciutils
    usbutils
  ];
}