# Home Manager Development Tools Configuration
{ config, lib, pkgs, ... }:

{
  # Terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        dynamic_title = true;
        opacity = 0.95;
      };
      
      font = {
        normal = {
          family = "JetBrains Mono";
          style = "Regular";
        };
        bold = {
          family = "JetBrains Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono";
          style = "Italic";
        };
        size = 12;
      };
      
      colors = {
        primary = {
          background = "#1E1E2E";
          foreground = "#CDD6F4";
        };
        normal = {
          black = "#45475A";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#BAC2DE";
        };
        bright = {
          black = "#585B70";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#A6ADC8";
        };
      };
      
      key_bindings = [
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "Plus"; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
        { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
      ];
    };
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 100000;
    keyMode = "vi";
    mouse = true;
    
    extraConfig = ''
      # True color support
      set -ga terminal-overrides ",*256col*:Tc"
      
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Renumber windows when a window is closed
      set -g renumber-windows on
      
      # Increase tmux messages display duration from 750ms to 4s
      set -g display-time 4000
      
      # Refresh 'status-left' and 'status-right' more often, from every 15s to 5s
      set -g status-interval 5
      
      # Upgrade $TERM
      set -g default-terminal "screen-256color"
      
      # Emacs key bindings in tmux command prompt (prefix + :)
      set -g status-keys emacs
      
      # Focus events enabled for terminals that support them
      set -g focus-events on
      
      # Super useful when using "grouped sessions" and multi-monitor setup
      setw -g aggressive-resize on
      
      # Easier and faster switching between next/prev window
      bind C-p previous-window
      bind C-n next-window
      
      # Source .tmux.conf as suggested in `man tmux`
      bind R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
      
      # Vim-like pane switching
      bind -r ^ last-window
      bind -r k select-pane -U
      bind -r j select-pane -D
      bind -r h select-pane -L
      bind -r l select-pane -R
      
      # Status bar
      set -g status-position bottom
      set -g status-bg colour234
      set -g status-fg colour137
      set -g status-left ""
      set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
      set -g status-right-length 50
      set -g status-left-length 20
      
      setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
    '';
  };

  # Bat (better cat)
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin-mocha";
      pager = "less -FR";
    };
  };

  # Eza (better ls)
  programs.eza = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
  };

  # Ripgrep configuration
  home.file.".config/ripgrep/ripgreprc".text = ''
    # Don't let ripgrep vomit really long lines to my terminal
    --max-columns=150
    
    # Add my 'web' type.
    --type-add=web:*.{html,css,js}*
    
    # Using glob patterns to include/exclude files or folders
    --glob=!.git/*
    --glob=!node_modules/*
    --glob=!target/*
    --glob=!.next/*
    --glob=!dist/*
    --glob=!build/*
    
    # Search hidden files and directories
    --hidden
    
    # Follow symbolic links
    --follow
    
    # Set the colors.
    --colors=line:none
    --colors=line:style:bold
    --colors=path:fg:green
    --colors=path:style:bold
    --colors=match:fg:black
    --colors=match:bg:yellow
    --colors=match:style:nobold
  '';

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--border"
      "--layout=reverse"
      "--info=inline"
      "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions = [
      "--preview 'bat --style=numbers --color=always --line-range :500 {}'"
    ];
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions = [
      "--preview 'tree -C {} | head -200'"
    ];
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };

  # Development environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "alacritty";
    PAGER = "bat";
    MANPAGER = "bat";
  };

  # Development scripts and tools
  home.packages = with pkgs; [
    # Database management
    dbeaver
    pgadmin4
    
    # API testing
    postman
    insomnia
    
    # Cloud tools
    awscli2
    azure-cli
    google-cloud-sdk
    
    # Kubernetes tools
    kubectl
    kubectx
    k9s
    helm
    minikube
    
    # Container tools
    docker-compose
    podman-compose
    lazydocker
    ctop
    
    # Infrastructure as Code
    terraform
    packer
    ansible
    
    # Monitoring and observability
    prometheus
    grafana
    
    # Network tools
    nmap
    tcpdump
    wireshark
    mtr
    iperf3
    
    # File synchronization
    rsync
    rclone
    
    # Compression tools
    p7zip
    unrar
    zip
    unzip
    
    # System monitoring
    lsof
    ncdu
    iotop
    nethogs
    
    # Development databases (for local development)
    sqlite
    
    # Version control extras
    gitui
    lazygit
    gh
    gitlab-runner
    
    # Language-specific tools
    python3Packages.black
    python3Packages.flake8
    python3Packages.mypy
    nodePackages.eslint
    nodePackages.prettier
    rustfmt
    
    # Build tools
    just
    gnumake
    cmake
    meson
    ninja
    
    # Documentation tools
    mdbook
    hugo
    
    # Productivity
    jq
    yq
    xmlstarlet
    
    # Image tools
    imagemagick
    
    # Network development
    mkcert
    caddy
    
    # Text processing
    pandoc
    
    # File management
    ranger
    nnn
    
    # System info
    neofetch
    screenfetch
    
    # Performance testing
    hyperfine
    
    # Security tools
    nmap
    masscan
    
    # Modern terminal tools
    du-dust
    procs
    tokei
    bandwhich
    
    # Search tools
    fd
    ripgrep
    
    # HTTP tools
    httpie
    curlie
  ];

  # XDG directories for development
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
    
    # Additional development directories
    extraConfig = {
      XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
      XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/Workspace";
    };
  };

  # Create development directories
  home.file."Projects/.keep".text = "";
  home.file."Workspace/.keep".text = "";
  home.file.".local/bin/.keep".text = "";

  # SSH configuration
  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/master-%r@%n:%p";
    controlPersist = "10m";
    
    extraConfig = ''
      # Security settings
      HostKeyAlgorithms +ssh-rsa
      PubkeyAcceptedKeyTypes +ssh-rsa
      
      # Performance settings
      Compression yes
      ServerAliveInterval 60
      ServerAliveCountMax 3
      
      # User experience
      AddKeysToAgent yes
      UseKeychain yes
    '';
  };

  # Environment setup for development
  home.file.".profile".text = ''
    # Add local bin to PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Rust
    export CARGO_HOME="$HOME/.cargo"
    export PATH="$CARGO_HOME/bin:$PATH"
    
    # Go
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
    
    # Node.js
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
    
    # Python
    export PYTHONPATH="$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH"
    export PATH="$HOME/.local/bin:$PATH"
    
    # Development environment
    export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgreprc"
  '';
}