# Hardware Configuration Template
# This file will be auto-generated or can be customized per host
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # This is a template hardware configuration
  # Run 'nixos-generate-config' to generate proper hardware configuration
  # or the setup script will generate it automatically
  
  # Boot device - will be auto-detected or customized
  boot = {
    initrd = {
      availableKernelModules = [ 
        "xhci_pci" 
        "thunderbolt" 
        "nvme" 
        "usb_storage" 
        "sd_mod" 
        "rtsx_pci_sdmmc" 
      ];
      kernelModules = [ ];
    };
    
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  # File systems - these are templates, will be customized per system
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/REPLACE-WITH-ROOT-UUID";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/REPLACE-WITH-BOOT-UUID";
      fsType = "vfat";
    };
  };

  # Swap configuration
  swapDevices = [
    # { device = "/dev/disk/by-uuid/REPLACE-WITH-SWAP-UUID"; }
  ];

  # CPU and hardware detection
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # For AMD: hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Power management
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # Enable hardware acceleration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Network interface naming
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;
}