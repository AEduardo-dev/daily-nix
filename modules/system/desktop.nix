# GNOME Desktop Environment Configuration
{ config, lib, pkgs, ... }:

{
  # Enable X11 and GNOME
  services.xserver = {
    enable = true;
    
    # Display manager
    displayManager.gdm.enable = true;
    
    # Desktop environment
    desktopManager.gnome.enable = true;
    
    # Keyboard layout
    layout = "us";
    xkbVariant = "";
  };

  # GNOME services
  services = {
    # Evolution data server (for calendar, contacts, etc.)
    gnome.evolution-data-server.enable = true;
    
    # GNOME online accounts
    gnome.gnome-online-accounts.enable = true;
    
    # Tracker (file indexing)
    gnome.tracker-miners.enable = true;
    gnome.tracker.enable = true;
    
    # Location services
    geoclue2.enable = true;
  };

  # Enable touchpad support
  services.xserver.libinput.enable = true;

  # XDG portal for GNOME
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
    ];
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Meslo" ]; })
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrains Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # GNOME applications and extensions
  environment.systemPackages = with pkgs; [
    # Core GNOME apps
    gnome.gnome-tweaks
    gnome.dconf-editor
    
    # Additional GNOME apps
    gnome.gnome-calculator
    gnome.file-roller
    gnome.evince
    gnome.eog
    gnome.gnome-system-monitor
    
    # GNOME extensions
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.user-themes
    gnomeExtensions.vitals
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.workspace-indicator
    
    # Media and graphics
    vlc
    gimp
    inkscape
    
    # Communication
    discord
    telegram-desktop
    
    # Productivity
    libreoffice
    
    # Archive and file management
    p7zip
    unrar
    
    # System utilities
    gparted
    bleachbit
  ];

  # Remove some unwanted GNOME applications
  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    cheese # webcam tool
    gedit # text editor
  ]) ++ (with pkgs.gnome; [
    epiphany # web browser
    geary # email reader
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-weather
    simple-scan
    totem # video player
    yelp # help viewer
  ]);

  # Enable GDM auto-login (optional - can be configured per user)
  # services.xserver.displayManager.autoLogin = {
  #   enable = true;
  #   user = "your-username";
  # };

  # Disable the GNOME3/GDM auto-suspend (for development machines)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}