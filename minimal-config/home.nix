# Minimal Home Manager Configuration
{ config, lib, pkgs, hostname, username, ... }:

{
  # Home Manager version
  home.stateVersion = "24.05";
  
  # User information
  home = {
    username = username;
    homeDirectory = "/home/${username}";
  };

  # Basic user packages
  home.packages = with pkgs; [
    # Browsers
    firefox
    
    # Terminal applications
    alacritty
    
    # Development tools
    git
    vim
    
    # File management
    nautilus
    
    # Utilities
    htop
    tree
    curl
    wget
    
    # Text editor with GUI
    gedit
    
    # Archive tools
    unzip
    zip
    
    # Media
    vlc
    
    # Office (basic)
    libreoffice-fresh
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "User";  # Will be customized by setup script
    userEmail = "user@example.com";  # Will be customized by setup script
    
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "vim";
      pull.rebase = false;
    };
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    enableCompletion = true;
    
    bashrcExtra = ''
      # Custom prompt
      export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      
      # Aliases
      alias ll='ls -alF'
      alias la='ls -A'
      alias l='ls -CF'
      alias grep='grep --color=auto'
      alias fgrep='fgrep --color=auto'
      alias egrep='egrep --color=auto'
      
      # History
      export HISTSIZE=10000
      export HISTFILESIZE=20000
      export HISTCONTROL=ignoreboth
      
      # Editor
      export EDITOR=vim
    '';
    
    historySize = 10000;
    historyFileSize = 20000;
  };

  # Terminal configuration (Alacritty)
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.95;
        padding = {
          x = 10;
          y = 10;
        };
      };
      
      font = {
        normal = {
          family = "Fira Code";
          style = "Regular";
        };
        size = 12.0;
      };
      
      colors = {
        primary = {
          background = "#1e1e1e";
          foreground = "#d4d4d4";
        };
        normal = {
          black = "#1e1e1e";
          red = "#f44747";
          green = "#608b4e";
          yellow = "#dcdcaa";
          blue = "#569cd6";
          magenta = "#c678dd";
          cyan = "#56b6c2";
          white = "#d4d4d4";
        };
      };
    };
  };

  # Firefox configuration
  programs.firefox = {
    enable = true;
    profiles.default = {
      name = "Default";
      isDefault = true;
      
      settings = {
        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "dom.security.https_only_mode" = true;
        
        # Disable telemetry
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.server" = "";
        
        # Performance
        "layers.acceleration.force-enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };
    };
  };

  # Vim configuration
  programs.vim = {
    enable = true;
    defaultEditor = true;
    
    settings = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
    };
    
    extraConfig = ''
      " Basic settings
      set nocompatible
      set encoding=utf-8
      set mouse=a
      set clipboard=unnamedplus
      
      " Search settings
      set hlsearch
      set incsearch
      set ignorecase
      set smartcase
      
      " Visual settings
      syntax on
      set background=dark
      colorscheme default
      
      " Indentation
      set autoindent
      set smartindent
      
      " File handling
      set autoread
      set nobackup
      set noswapfile
      
      " Statusline
      set laststatus=2
      set statusline=%F%m%r%h%w\ [%l,%c]\ [%p%%]
    '';
  };

  # GTK theme configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # XDG configuration
  xdg = {
    enable = true;
    
    userDirs = {
      enable = true;
      createDirectories = true;
      
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
    };
  };

  # Services
  services = {
    # GPG agent for SSH keys
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 1800;
      maxCacheTtl = 7200;
    };
  };

  # Font configuration
  fonts.fontconfig.enable = true;

  # Session variables
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };

  # Allow unfree packages for home-manager
  nixpkgs.config.allowUnfree = true;
}