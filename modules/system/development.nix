# Development Tools and Environment Configuration
{ config, lib, pkgs, ... }:

{
  # Container and virtualization support
  virtualisation = {
    # Enable Podman
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    
    # Enable Docker (alternative to Podman)
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    
    # Enable libvirt for VMs
    libvirtd.enable = true;
  };

  # Programming languages and runtimes
  environment.systemPackages = with pkgs; [
    # Build essentials
    gcc
    gccStdenv
    clang
    llvm
    cmake
    gnumake
    autoconf
    automake
    libtool
    pkg-config
    meson
    ninja
    
    # Python ecosystem
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.setuptools
    python3Packages.wheel
    pipenv
    poetry
    
    # Node.js ecosystem
    nodejs_20
    npm
    yarn
    pnpm
    
    # Rust
    rustc
    cargo
    rustfmt
    rust-analyzer
    
    # Go
    go
    gopls
    
    # Java
    openjdk17
    maven
    gradle
    
    # .NET
    dotnet-sdk_8
    
    # Database tools
    postgresql
    sqlite
    redis
    mongodb-tools
    
    # Development tools
    git
    git-lfs
    lazygit
    delta
    difftastic
    
    # Text editors and IDEs
    vscode
    
    # Terminal tools
    tmux
    zellij
    alacritty
    kitty
    wezterm
    
    # Shell enhancements
    zsh
    oh-my-zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    starship
    
    # File and text processing
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    yq
    
    # Network tools
    curl
    wget
    httpie
    nmap
    wireshark
    
    # Monitoring and debugging
    htop
    btop
    iotop
    strace
    gdb
    valgrind
    
    # Cloud and DevOps tools
    kubectl
    terraform
    ansible
    vagrant
    
    # API development
    postman
    insomnia
    
    # Version control GUIs
    gitg
    github-desktop
    
    # Container tools
    dive
    docker-compose
    podman-compose
    skopeo
    buildah
    
    # Documentation
    mdbook
    pandoc
    
    # Image processing and graphics (for web dev)
    imagemagick
    graphicsmagick
    
    # Networking development
    mkcert
    ngrok
    
    # Performance tools
    hyperfine
    bandwhich
    
    # Modern alternatives to classic tools
    dust        # du replacement
    procs       # ps replacement
    tokei       # code statistics
    
    # LSP servers for various languages
    nil         # Nix LSP
    gopls       # Go LSP
    rust-analyzer # Rust LSP
    nodePackages.typescript-language-server
    nodePackages.pyright
    
    # Formatters
    nixpkgs-fmt
    alejandra
    black
    prettier
    rustfmt
    gofmt
  ];

  # Enable services needed for development
  services = {
    # PostgreSQL
    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres' CREATEDB;
        ALTER USER postgres CREATEDB;
      '';
    };
    
    # Redis
    redis.servers."" = {
      enable = true;
      port = 6379;
    };
    
    # Enable SSH
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  # Shell configuration
  programs = {
    zsh = {
      enable = true;
      ohMyZsh = {
        enable = true;
        plugins = [ "git" "docker" "kubectl" "rust" "python" ];
        theme = "robbyrussell";
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    
    # Enable direnv for automatic environment loading
    direnv.enable = true;
    
    # GPG for signing commits
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Environment variables for development
  environment.variables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "alacritty";
  };

  # Enable experimental features for package development
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "@wheel" ];
  };
}