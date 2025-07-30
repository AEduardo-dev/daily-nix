# Standalone Home Manager Configuration
{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./modules/home/neovim.nix
    ./modules/home/development.nix
    ./modules/home/desktop.nix
  ];

  # Home Manager settings
  home = {
    username = "user";
    homeDirectory = "/home/user";
    stateVersion = "23.11";
  };

  # Enable the Nix flake functionality for the user
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      
      # Sign commits with GPG
      commit.gpgSign = true;
      tag.gpgSign = true;
      
      # Better diff output
      diff.algorithm = "patience";
      
      # Reuse recorded resolution of conflicted merges
      rerere.enabled = true;
    };
    
    # Git aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      df = "diff";
      lg = "log --oneline --graph --decorate --all";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Programs
  programs.home-manager.enable = true;
}