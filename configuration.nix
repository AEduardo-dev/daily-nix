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
          description = "Primary user name";
        };
        
        realName = lib.mkOption {
          type = lib.types.str;
          default = "Main User";
          description = "Real name for git and other services";
        };
        
        email = lib.mkOption {
          type = lib.types.str;
          default = "your.email@example.com";
          description = "Email for git and other services";
        };
      };

      # LazyVim configuration from git repository
      neovim = {
        lazyvimConfigRepo = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Git repository URL containing LazyVim configuration to clone";
          example = "https://github.com/username/lazyvim-config.git";
        };
      };

      # System features to enable
      features = {
        gaming = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable gaming configuration";
        };
        
        development = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable development environment";
        };
        
        desktop = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable GNOME desktop environment";
        };
      };

      # Secrets configuration
      secrets = {
        useSOPS = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable SOPS for secrets management";
        };
        
        ageKeyFile = lib.mkOption {
          type = lib.types.str;
          default = "/home/${config.dailyNix.user.name}/.config/sops/age/keys.txt";
          description = "Path to age key file for SOPS";
        };
      };
    };
  };

  # Apply the configuration based on options
  config = {
    # Set default configuration values
    dailyNix = {
      user.name = lib.mkDefault "user";
      user.realName = lib.mkDefault "Main User";
      user.email = lib.mkDefault "your.email@example.com";
      neovim.lazyvimConfigRepo = lib.mkDefault null;
      features.gaming = lib.mkDefault true;
      features.development = lib.mkDefault true;
      features.desktop = lib.mkDefault true;
      secrets.useSOPS = lib.mkDefault true;
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