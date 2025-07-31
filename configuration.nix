# Centralized NixOS Configuration
# This file serves as the main configuration hub for the daily-nix setup
{ config, lib, pkgs, inputs, ... }:

{
  # Import all necessary modules and configurations
  imports = [
    ./hosts/desktop  # Main desktop host configuration
  ];

  # Centralized configuration options
  options = {
    dailyNix = {
      # User configuration
      user = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "user";
          description = "Primary user name (change this to your desired username)";
          example = "your-username"; # Change this to your system username
        };
        
        realName = lib.mkOption {
          type = lib.types.str;
          default = "Main User";
          description = "Real name for git and other services (for git, etc.)";
          example = "Your Full Name";
        };
        
        email = lib.mkOption {
          type = lib.types.str;
          default = "your.email@example.com";
          description = "Email for git and other services (for git, etc.)";
          example = "your.email@example.com";
        };
      };

      # LazyVim configuration from git repository
      neovim = {
        lazyvimConfigRepo = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Git repository URL containing LazyVim configuration to clone (optional). Uncomment and set if you have a custom config.";
          example = "https://github.com/yourusername/lazyvim-config.git";
        };
      };

      # System features to enable
      features = {
        gaming = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable gaming applications (Steam, Discord, etc.). Set to false to disable gaming packages.";
        };
        
        development = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable development tools and databases. Set to false to disable development packages.";
        };
        
        desktop = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable GNOME desktop environment. Set to false for headless/server systems.";
        };
      };

      # Secrets configuration
      secrets = {
        useSOPS = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable SOPS for secrets management (REQUIRED FOR USER PASSWORD). Set to false if not using SOPS.";
        };
        
        ageKeyFile = lib.mkOption {
          type = lib.types.str;
          default = null; # Set dynamically in config to avoid circular dependency
          description = "Path to age key file for SOPS. Make sure this path matches your age key location. REQUIRED if useSOPS is true.";
          example = "/home/your-username/.config/sops/age/keys.txt";
        };
      };
    };
  };

  # Apply the configuration based on options
  config = {
    # Set default configuration values
    dailyNix = {
      # Set your user details below. These are used for system user, git, etc.
      user.name = lib.mkDefault "user";
      user.realName = lib.mkDefault "Main User";
      user.email = lib.mkDefault "your.email@example.com";
      # LazyVim config repo (optional)
      neovim.lazyvimConfigRepo = lib.mkDefault null;
      # Enable/disable system features
      features.gaming = lib.mkDefault true;
      features.development = lib.mkDefault true;
      features.desktop = lib.mkDefault true;
      # SOPS secrets management
      secrets.useSOPS = lib.mkDefault true;
      # Set ageKeyFile dynamically to avoid circular dependency in options
      secrets.ageKeyFile = lib.mkDefault "/home/${config.dailyNix.user.name}/.config/sops/age/keys.txt";
    };
    
    # Pass configuration to other modules
    home-manager.users.${config.dailyNix.user.name} = {
      programs.neovim-custom.lazyvimConfigRepo = config.dailyNix.neovim.lazyvimConfigRepo;
    };
    
    # Override SOPS age key file location
    sops.age.keyFile = config.dailyNix.secrets.ageKeyFile;
  };
}
