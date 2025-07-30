# Home Manager Desktop Configuration
{ config, lib, pkgs, ... }:

{
  # Desktop applications
  home.packages = with pkgs; [
    # Browsers
    brave
    firefox
    chromium
    
    # Communication
    discord
    telegram-desktop
    slack
    zoom-us
    
    # Media
    vlc
    mpv
    spotify
    
    # Graphics and design
    gimp
    inkscape
    krita
    blender
    
    # Office and productivity
    libreoffice
    obsidian
    notion-app-enhanced
    
    # File management
    nautilus
    ranger
    
    # Archive management
    file-roller
    p7zip
    unrar
    
    # System utilities
    gnome.gnome-tweaks
    gnome.dconf-editor
    gparted
    bleachbit
    
    # Screenshots and screen recording
    flameshot
    obs-studio
    peek
    
    # Password management
    keepassxc
    bitwarden
    
    # Note taking and documentation
    typora
    marktext
    joplin-desktop
    
    # Development IDEs and editors
    vscode
    
    # Image viewers
    feh
    eog
    
    # Video editing
    kdenlive
    
    # Audio editing
    audacity
    
    # System monitoring
    gnome.gnome-system-monitor
    btop
    
    # Network tools
    wireshark
    
    # Remote desktop
    remmina
    
    # Virtualization
    virt-manager
    
    # Gaming utilities
    lutris
    steam
    
    # Cloud storage
    nextcloud-client
    
    # Email
    thunderbird
    
    # PDF tools
    evince
    qpdfview
    
    # Text editors
    gnome.gedit
    
    # Calculator
    gnome.gnome-calculator
    
    # Weather
    gnome.gnome-weather
    
    # Maps
    gnome.gnome-maps
    
    # Clock
    gnome.gnome-clocks
  ];

  # GTK configuration
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
      size = 24;
    };
    
    font = {
      name = "Noto Sans";
      size = 11;
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-button-images = true;
      gtk-menu-images = true;
      gtk-enable-event-sounds = false;
      gtk-enable-input-feedback-sounds = false;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-xft-rgba = "rgb";
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qt configuration
  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "adwaita-dark";
  };

  # Fonts configuration
  fonts.fontconfig.enable = true;

  # XDG MIME applications
  xdg.mimeApps = {
    enable = true;
    
    defaultApplications = {
      # Web browsers
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
      
      # Documents
      "application/pdf" = "org.gnome.Evince.desktop";
      "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
      "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
      "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
      "application/msword" = "libreoffice-writer.desktop";
      "application/vnd.ms-excel" = "libreoffice-calc.desktop";
      "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
      
      # Images
      "image/jpeg" = "org.gnome.eog.desktop";
      "image/png" = "org.gnome.eog.desktop";
      "image/gif" = "org.gnome.eog.desktop";
      "image/bmp" = "org.gnome.eog.desktop";
      "image/svg+xml" = "org.gnome.eog.desktop";
      
      # Videos
      "video/mp4" = "vlc.desktop";
      "video/x-msvideo" = "vlc.desktop";
      "video/quicktime" = "vlc.desktop";
      "video/x-matroska" = "vlc.desktop";
      "video/webm" = "vlc.desktop";
      
      # Audio
      "audio/mpeg" = "vlc.desktop";
      "audio/x-vorbis+ogg" = "vlc.desktop";
      "audio/x-flac" = "vlc.desktop";
      "audio/mp4" = "vlc.desktop";
      
      # Archives
      "application/zip" = "org.gnome.FileRoller.desktop";
      "application/x-tar" = "org.gnome.FileRoller.desktop";
      "application/x-gzip" = "org.gnome.FileRoller.desktop";
      "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
      "application/x-rar" = "org.gnome.FileRoller.desktop";
      
      # Text files
      "text/plain" = "nvim.desktop";
      "text/x-python" = "nvim.desktop";
      "text/x-shellscript" = "nvim.desktop";
      "application/json" = "nvim.desktop";
      "application/xml" = "nvim.desktop";
      
      # Development files
      "text/x-csrc" = "nvim.desktop";
      "text/x-c++src" = "nvim.desktop";
      "text/x-java" = "nvim.desktop";
      "text/x-javascript" = "nvim.desktop";
      "text/css" = "nvim.desktop";
      
      # File manager
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
    
    associations.added = {
      "application/pdf" = "org.gnome.Evince.desktop";
      "text/html" = "brave-browser.desktop";
      "image/jpeg" = "org.gnome.eog.desktop";
      "image/png" = "org.gnome.eog.desktop";
      "video/mp4" = "vlc.desktop";
      "audio/mpeg" = "vlc.desktop";
    };
  };

  # Desktop services
  services = {
    # Notification daemon
    dunst = {
      enable = true;
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          transparency = 10;
          frame_color = "#89b4fa";
          font = "Noto Sans 10";
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = false;
          show_indicators = "yes";
          sticky_history = "yes";
          history_length = 20;
          browser = "brave";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 10;
          ignore_dbusclose = false;
          force_xinerama = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };
        
        experimental = {
          per_monitor_dpi = false;
        };
        
        urgency_low = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          timeout = 10;
        };
        
        urgency_normal = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          timeout = 10;
        };
        
        urgency_critical = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
          frame_color = "#fab387";
          timeout = 0;
        };
      };
    };
    
    # Screen locker
    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.gnome.gnome-screensaver}/bin/gnome-screensaver-command --lock";
      inactiveInterval = 10;
    };
  };

  # Desktop environment variables
  home.sessionVariables = {
    BROWSER = "brave";
    TERMINAL = "alacritty";
  };

  # Desktop configuration files
  home.file = {
    # Wallpapers directory
    ".local/share/wallpapers/.keep".text = "";
    
    # Applications directory
    ".local/share/applications/.keep".text = "";
    
    # Desktop entries for custom applications
    ".local/share/applications/nvim.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Neovim
      Comment=Edit text files
      Icon=nvim
      Exec=alacritty -e nvim %F
      Categories=Utility;TextEditor;Development;
      StartupNotify=false
      MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;text/x-python;
    '';
  };

  # GNOME dconf settings
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Numix-Cursor";
      font-name = "Noto Sans 11";
      document-font-name = "Noto Sans 11";
      monospace-font-name = "JetBrains Mono 10";
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      show-battery-percentage = true;
    };
    
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Noto Sans Bold 11";
      button-layout = "appmenu:minimize,maximize,close";
    };
    
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      primary-color = "#1e1e2e";
      secondary-color = "#1e1e2e";
    };
    
    "org/gnome/desktop/screensaver" = {
      picture-options = "zoom";
      primary-color = "#1e1e2e";
      secondary-color = "#1e1e2e";
    };
    
    "org/gnome/shell" = {
      favorite-apps = [
        "brave-browser.desktop"
        "org.gnome.Nautilus.desktop"
        "alacritty.desktop"
        "code.desktop"
        "discord.desktop"
        "org.gnome.Settings.desktop"
      ];
      
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "dash-to-dock@micxgx.gmail.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "Vitals@CoreCoding.com"
        "clipboard-indicator@tudmotu.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
      ];
    };
    
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dock-fixed = false;
      extend-height = false;
      height-fraction = 0.9;
      show-apps-at-top = true;
      show-mounts = false;
      show-trash = false;
      transparency-mode = "DYNAMIC";
    };
    
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
      natural-scroll = true;
    };
    
    "org/gnome/desktop/input-sources" = {
      sources = [ [ "xkb" "us" ] ];
      xkb-options = [ "caps:escape" ];
    };
    
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "alacritty";
      name = "Terminal";
    };
    
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-fullscreen = [ "<Super>f" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
    };
    
    "org/gnome/mutter" = {
      workspaces-only-on-primary = true;
      dynamic-workspaces = false;
    };
    
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
    };
  };
}