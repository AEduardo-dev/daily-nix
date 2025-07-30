# User Configuration
{ config, lib, pkgs, inputs, ... }:

{
  # Define users
  users.users.user = {
    isNormalUser = true;
    description = "Main User";
    shell = pkgs.zsh;
    
    # Add user to important groups
    extraGroups = [
      "wheel"          # sudo access
      "networkmanager" # network management
      "audio"          # audio devices
      "video"          # video devices
      "docker"         # docker daemon
      "podman"         # podman
      "libvirtd"       # virtual machines
      "adbusers"       # android debugging
      "dialout"        # serial devices
      "plugdev"        # removable devices
      "input"          # input devices
    ];
    
    # Set user password (use sops for production)
    # hashedPassword = config.sops.secrets.user-password.path;
    
    # For initial setup, you can set a temporary password
    initialPassword = "changeme";
    
    # SSH keys (replace with your actual public keys)
    openssh.authorizedKeys.keys = [
      # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... your-key-here"
    ];
  };

  # Home Manager configuration for the user
  home-manager.users.user = { pkgs, ... }: {
    imports = [
      ../../modules/home/neovim.nix
      ../../modules/home/development.nix
      ../../modules/home/desktop.nix
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

    # Basic user packages
    home.packages = with pkgs; [
      # Browsers
      brave
      firefox
      chromium
      
      # Communication
      slack
      zoom-us
      
      # Media
      spotify
      
      # Productivity
      obsidian
      notion-app-enhanced
      
      # Development tools
      gh # GitHub CLI
      
      # Terminal emulators
      alacritty
      kitty
      
      # File managers
      nautilus
      ranger
      
      # System utilities
      btop
      neofetch
      
      # Text editors
      typora
      
      # Image viewers and editors
      feh
      shotwell
    ];

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

    # Zsh configuration
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "docker"
          "kubectl"
          "rust"
          "python"
          "node"
          "npm"
          "yarn"
        ];
        theme = "robbyrussell";
      };
      
      shellAliases = {
        ll = "ls -l";
        la = "ls -la";
        l = "ls -CF";
        
        # Modern alternatives
        ls = "eza";
        cat = "bat";
        grep = "rg";
        find = "fd";
        top = "btop";
        
        # Git shortcuts
        g = "git";
        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";
        gl = "git pull";
        
        # NixOS specific
        nrs = "sudo nixos-rebuild switch --flake .#desktop";
        hms = "home-manager switch --flake .#user@desktop";
        nfu = "nix flake update";
        
        # Development shortcuts
        dc = "docker-compose";
        pc = "podman-compose";
        k = "kubectl";
      };
      
      initExtra = ''
        # Custom functions
        mkcd() {
          mkdir -p "$1" && cd "$1"
        }
        
        # Nix shell with auto-direnv
        ns() {
          nix-shell -p "$@"
        }
        
        # Quick edit of flake
        edit-flake() {
          $EDITOR ~/nixos-config/flake.nix
        }
      '';
    };

    # Starship prompt
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        format = "$all$character";
        
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
        
        git_branch = {
          format = "[$symbol$branch]($style) ";
          symbol = "🌱 ";
        };
        
        nix_shell = {
          format = "[$symbol$state]($style) ";
          symbol = "❄️ ";
        };
      };
    };

    # Direnv for automatic environment loading
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # GPG configuration
    programs.gpg = {
      enable = true;
      settings = {
        default-key = "your-gpg-key-id";
      };
    };

    # Services
    services = {
      # GPG agent
      gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentryFlavor = "gtk2";
        defaultCacheTtl = 7200;
        maxCacheTtl = 86400;
      };
    };

    # XDG configuration
    xdg = {
      enable = true;
      
      # Set default applications
      mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "brave-browser.desktop";
          "x-scheme-handler/http" = "brave-browser.desktop";
          "x-scheme-handler/https" = "brave-browser.desktop";
          "x-scheme-handler/about" = "brave-browser.desktop";
          "x-scheme-handler/unknown" = "brave-browser.desktop";
          "application/pdf" = "org.gnome.Evince.desktop";
          "image/jpeg" = "org.gnome.eog.desktop";
          "image/png" = "org.gnome.eog.desktop";
        };
      };
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Program configurations
    programs.home-manager.enable = true;
  };
}