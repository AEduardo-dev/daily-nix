# Gaming Setup Guide

This document provides detailed instructions for the gaming setup included in this NixOS configuration.

## Included Gaming Software

### Game Launchers and Platforms

- **Steam** with Proton compatibility for Windows games
- **Heroic Games Launcher** for Epic Games Store and GOG
- **Lutris** for various game sources and Wine management
- **Bottles** for Wine prefix management

### Emulation

- **RetroArch** for classic console emulation
- **Dolphin** for GameCube and Wii emulation
- **PCSX2** for PlayStation 2 emulation
- **RPCS3** for PlayStation 3 emulation

### Performance and Utilities

- **GameMode** for system optimization during gaming
- **MangoHUD** for performance overlay
- **Gamescope** for Steam Deck-like experience

### Communication

- **Discord** for gaming communication
- **TeamSpeak** client
- **Mumble** for low-latency voice chat

## Initial Setup

### 1. Graphics Drivers

The configuration includes comments for both NVIDIA and AMD setups. Uncomment the appropriate section in `modules/system/gaming.nix`:

#### For NVIDIA users:
```nix
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = false;
  powerManagement.finegrained = false;
  open = false;
  nvidiaSettings = true;
  package = config.boot.kernelPackages.nvidiaPackages.stable;
};
```

#### For AMD users:
```nix
services.xserver.videoDrivers = [ "amdgpu" ];
```

Intel integrated graphics work out of the box with no additional configuration.

### 2. Steam Setup

Steam is automatically installed and configured. On first launch:

1. Sign in to your Steam account
2. Enable Steam Play for all titles:
   - Go to Steam → Settings → Steam Play
   - Check "Enable Steam Play for all other titles"
   - Select the latest Proton version

### 3. Heroic Games Launcher

Heroic is pre-installed for Epic Games Store and GOG games:

1. Launch Heroic from the applications menu
2. Sign in to your Epic Games and/or GOG accounts
3. Install and play your games

## Game-Specific Optimizations

### Steam Games

#### Proton Compatibility

Most Windows games work through Proton. For problematic games:

1. Check [ProtonDB](https://www.protondb.com/) for compatibility reports
2. Try different Proton versions
3. Add launch options if needed

#### Common Launch Options

- For games with launcher issues: `PROTON_NO_ESYNC=1 %command%`
- For older games: `PROTON_USE_WINED3D=1 %command%`
- Force Proton version: `PROTON_VERSION=proton70 %command%`

### Epic Games Store

Use Heroic Games Launcher for Epic games:

1. Install the game through Heroic
2. Configure Wine version and settings per game
3. Use built-in optimization tools

### GOG Games

Install through Heroic or use native Linux versions when available:

1. Download from GOG directly for Linux games
2. Use Heroic for Windows games
3. Lutris as an alternative for complex setups

## Performance Optimization

### System-Level Optimizations

The configuration includes several optimizations:

- **CPU Governor**: Set to performance mode for gaming
- **Swappiness**: Reduced to 10 for better memory management
- **File Descriptors**: Increased limits for games that need them

### GameMode

GameMode automatically optimizes your system when games are detected:

```bash
# Check if GameMode is working
gamemoded -s

# Manually run a game with GameMode
gamemoderun ./mygame
```

### MangoHUD

Display performance metrics in games:

```bash
# Enable for all games (already set in config)
export MANGOHUD=1

# Configure MangoHUD
mangohud --dlsym
```

Custom MangoHUD configuration in `~/.config/MangoHud/MangoHud.conf`:

```ini
fps
frametime
cpu_stats
gpu_stats
ram
vram
```

## Emulation Setup

### RetroArch

RetroArch provides a unified interface for multiple emulators:

1. Launch RetroArch
2. Go to Main Menu → Online Updater → Core Downloader
3. Download cores for your desired systems
4. Load content and select appropriate core

Popular cores:
- **Snes9x** for Super Nintendo
- **Genesis Plus GX** for Sega Genesis
- **Mupen64Plus-Next** for Nintendo 64
- **PCSX ReARMed** for PlayStation 1

### Dolphin (GameCube/Wii)

1. Configure graphics backend (Vulkan recommended)
2. Set up Wii Remote emulation if needed
3. Import your legally dumped games

### PCSX2 (PlayStation 2)

1. Configure graphics plugin
2. Set up controller mapping
3. Apply game-specific patches if needed

### RPCS3 (PlayStation 3)

1. Install PS3 firmware (required)
2. Configure CPU and GPU settings
3. Check game compatibility list

## Wine and Windows Games

### Lutris Setup

Lutris manages Wine prefixes for various games:

1. Install games through Lutris installers
2. Configure Wine versions per game
3. Apply DXVK/VKD3D for better performance

### Bottles

Alternative Wine prefix manager:

1. Create new bottles for different games
2. Install required dependencies
3. Configure per-game settings

### Common Wine Issues

#### Missing DLLs
```bash
# Install common libraries
winetricks vcrun2019 d3dx9 d3dcompiler_47
```

#### Audio Issues
```bash
# Configure audio system
winecfg
# Select PulseAudio driver
```

#### Graphics Issues
```bash
# Install DXVK for DirectX support
winetricks dxvk
```

## Controller Support

### Xbox Controllers

Xbox controllers work out of the box with xpadneo driver (included).

### PlayStation Controllers

For PS4/PS5 controllers:

```bash
# Connect via Bluetooth
bluetoothctl
> scan on
> pair [MAC_ADDRESS]
> connect [MAC_ADDRESS]
```

### Generic Controllers

Use `jstest-gtk` to test controller functionality:

```bash
jstest-gtk
```

Configure button mapping with `antimicrox`.

## Troubleshooting

### Steam Issues

#### Steam won't start
```bash
# Clear Steam cache
rm -rf ~/.steam/steam/logs
rm -rf ~/.steam/steam/dumps
```

#### Games won't launch
```bash
# Check Proton logs
tail -f ~/.steam/steam/logs/content_log.txt
```

### Graphics Issues

#### Low performance
1. Check graphics driver installation
2. Verify Vulkan support: `vulkan-info`
3. Test OpenGL: `glxinfo | grep "direct rendering"`

#### Screen tearing
Enable VSync in game settings or force it:
```bash
# For NVIDIA
nvidia-settings
# Enable "Force Full Composition Pipeline"
```

### Audio Issues

#### No sound in games
```bash
# Check audio system
pactl list sinks
pavucontrol
```

#### Audio crackling
```bash
# Adjust buffer size
echo "default-sample-rate = 48000" >> ~/.config/pulse/daemon.conf
pulseaudio -k && pulseaudio --start
```

### Network Issues

#### High ping in online games
```bash
# Check network interface
ip addr show

# Test connection
ping -c 4 8.8.8.8

# Monitor network usage
nethogs
```

## Game Library Organization

### Steam

Organize games using Steam categories:
1. Right-click game → Set Categories
2. Create categories like "Native", "Proton", "Verified"

### Heroic

Use library filters and tags to organize Epic and GOG games.

### Lutris

Create categories and use filtering options to manage your library.

## Backup and Sync

### Save Games

Common save game locations:
- **Steam**: `~/.steam/steam/userdata/[USER_ID]/`
- **Native games**: `~/.local/share/` or `~/.config/`
- **Wine games**: `~/.wine/drive_c/users/[USER]/Documents/`

### Cloud Sync

Enable cloud sync in:
- Steam (automatic for supported games)
- Epic Games Store (through Heroic settings)
- GOG Galaxy (if using GOG Galaxy through Wine)

## Performance Monitoring

### System Resources

Monitor performance during gaming:

```bash
# CPU and GPU usage
btop

# Network usage
bandwhich

# Disk I/O
iotop
```

### Game-Specific

Use MangoHUD for in-game monitoring:
- FPS counter
- Frame timing
- CPU/GPU usage
- RAM/VRAM usage
- Temperature monitoring

## Advanced Configuration

### Custom Wine Builds

For specific games that need custom Wine versions:

```bash
# Install wine-staging
# Add to configuration.nix:
environment.systemPackages = [ pkgs.wine-staging ];
```

### GPU Passthrough

For advanced users wanting GPU passthrough to Windows VMs:

1. Enable IOMMU in BIOS
2. Configure VFIO
3. Set up Looking Glass for seamless experience

This is advanced and requires additional configuration not covered here.

## Useful Resources

- [ProtonDB](https://www.protondb.com/) - Steam game compatibility
- [Lutris Database](https://lutris.net/games/) - Game installers
- [PCGW](https://www.pcgamingwiki.com/) - Game fixes and tweaks
- [Wine Application Database](https://appdb.winehq.org/) - Wine compatibility
- [RetroArch Documentation](https://docs.libretro.com/) - Emulation guides