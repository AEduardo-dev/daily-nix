# Example Configuration Template
# Copy this to configuration.nix and customize for your setup

{ config, lib, pkgs, inputs, ... }:

{
  # Import all necessary modules and configurations
  imports = [
    ./hosts/desktop  # Main desktop host configuration
  ];

  # Centralized configuration options
  dailyNix = {
    # User configuration - CUSTOMIZE THESE VALUES
    user = {
      name = "your-username";                    # Change this to your desired username
      realName = "Your Full Name";               # Your real name for git/services
      email = "your.email@example.com";         # Your email for git/services
    };

    # LazyVim configuration from git repository (optional)
    neovim = {
      # Uncomment and set to your LazyVim config repository
      # lazyvimConfigRepo = "https://github.com/yourusername/lazyvim-config.git";
      lazyvimConfigRepo = null;
    };

    # System features to enable/disable
    features = {
      gaming = true;       # Enable gaming applications (Steam, Discord, etc.)
      development = true;  # Enable development tools and databases
      desktop = true;      # Enable GNOME desktop environment
    };

    # Secrets configuration - REQUIRED FOR USER PASSWORD
    secrets = {
      useSOPS = true;      # Enable SOPS for secrets management
      # Make sure this path matches your age key location
      ageKeyFile = "/home/your-username/.config/sops/age/keys.txt";
    };
  };
}