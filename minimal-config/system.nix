# Minimal NixOS System Configuration
{ config, lib, pkgs, hostname, username, ... }:

{
  # Basic system configuration
  system.stateVersion = "24.05";

  # Bootloader configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Enable Plymouth for better boot experience
    plymouth.enable = true;
  };

  # Networking
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    # Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # SSH
    };
  };

  # Time zone and locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Basic services
  services = {
    # SSH for remote access
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false; # Use keys only
        PermitRootLogin = "no";
      };
    };
    
    # NetworkManager for easy network management
    networkmanager.enable = true;
    
    # Enable sound
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Basic system packages
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim
    git
    curl
    wget
    htop
    tree
    
    # Network tools
    networkmanager
    
    # Text editors
    nano
    
    # System utilities
    pciutils
    usbutils
    
    # SOPS for secrets management
    sops
    age
    ssh-to-age
  ];

  # User configuration
  users = {
    mutableUsers = false; # Declarative user management
    users.${username} = {
      isNormalUser = true;
      description = "Primary user";
      extraGroups = [ 
        "wheel"         # sudo access
        "networkmanager" # network management
        "audio"         # audio devices
        "video"         # video devices
      ];
      # Password will be managed by SOPS
      hashedPasswordFile = "/run/secrets/user-password";
      
      # Allow SSH key authentication
      openssh.authorizedKeys.keyFiles = [
        "/etc/ssh/authorized_keys/${username}"
      ];
    };
    
    # Enable sudo for wheel group
    extraGroups.wheel = {};
  };

  # Security
  security = {
    sudo.wheelNeedsPassword = false; # Allow passwordless sudo for wheel group
    rtkit.enable = true; # Real-time kit for audio
  };

  # SOPS configuration for secrets management
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    
    # Use SSH host key for decryption (automated)
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    
    secrets = {
      # User password
      user-password = {
        neededForUsers = true;
      };
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
  ];

  # Hardware support
  hardware = {
    # Enable all firmware
    enableAllFirmware = true;
    
    # OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    
    # Bluetooth
    bluetooth.enable = true;
    
    # Audio
    pulseaudio.enable = false; # Using pipewire instead
  };

  # Optional: Basic desktop environment (can be disabled)
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    
    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Exclude some GNOME applications to keep it minimal
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    gnome-music
    epiphany # web browser
    geary # email reader
    gnome-characters
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  # System-wide environment variables
  environment.variables = {
    EDITOR = "vim";
  };
}