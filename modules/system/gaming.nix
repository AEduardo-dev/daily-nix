# Gaming Configuration
{ config, lib, pkgs, ... }:

{
  # Enable 32-bit OpenGL support (required for many games)
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Steam
    steam
    steam-run
    steamcmd
    
    # Heroic Games Launcher (Epic Games, GOG)
    heroic
    
    # PortProton (Wine-based tool for Windows games)
    # Note: PortProton might need to be installed manually or through Flatpak
    # Adding wine and related tools for now
    wine
    wine64
    winetricks
    lutris
    
    # Game launchers and tools
    bottles          # Wine prefix manager
    gamemode         # Optimize system for gaming
    gamescope        # SteamOS session compositing window manager
    mangohud         # Performance overlay
    goverlay         # GUI for MangoHud
    
    # Emulation
    retroarch
    dolphin-emu
    pcsx2
    rpcs3
    
    # Game development tools
    godot_4
    blender
    
    # Communication for gaming
    discord
    
    # Game recording and streaming
    obs-studio
    obs-studio-plugins.wlrobs
    obs-studio-plugins.obs-backgroundremoval
    
    # Performance monitoring
    glxinfo
    vulkan-tools
    mesa-demos
    
    # Audio tools for gaming
    easyeffects
    pavucontrol
    
    # Gamepad support
    jstest-gtk
    antimicrox
  ];

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable GameMode
  programs.gamemode.enable = true;

  # Gamepad support
  hardware.xpadneo.enable = true;
  
  # Enable udev rules for various gaming peripherals
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];

  # Graphics drivers (adjust based on your graphics card)
  # For NVIDIA users:
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   powerManagement.finegrained = false;
  #   open = false;
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

  # For AMD users (open source drivers are usually fine):
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # Vulkan support
  hardware.opengl.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
  ];

  # 32-bit Vulkan support
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
    vulkan-loader
  ];

  # Audio optimizations for gaming
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Performance optimizations
  boot.kernel.sysctl = {
    # Reduce swappiness for better gaming performance
    "vm.swappiness" = 10;
    
    # Increase file descriptor limits
    "fs.file-max" = 2097152;
  };

  # CPU frequency scaling for performance
  powerManagement.cpuFreqGovernor = "performance";

  # Enable Flatpak for additional gaming applications
  services.flatpak.enable = true;
  
  # XDG Desktop Portal for Flatpak
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Environment variables for gaming
  environment.variables = {
    # Enable MangoHud by default
    MANGOHUD = "1";
    
    # Wine/Proton optimizations
    WINE_CPU_TOPOLOGY = "4:2";
    
    # Steam optimizations
    STEAM_FORCE_DESKTOPUI_SCALING = "1";
  };

  # Gaming-specific firewall rules
  networking.firewall = {
    allowedTCPPorts = [
      # Steam
      27036 27037
      # Sunshine (game streaming)
      47984 47989 47990 48010
    ];
    allowedUDPPorts = [
      # Steam
      27031 27036
      # Sunshine
      47998 47999 48000 48002 48010
    ];
  };

  # Enable locate for faster file searching (useful for game files)
  services.locate.enable = true;
  
  # Increase open file limits for gaming
  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';
}