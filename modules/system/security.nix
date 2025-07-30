# Security Configuration with SOPS
{ config, lib, pkgs, inputs, ... }:

{
  # SOPS configuration
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    # Age key configuration
    age.keyFile = "/home/user/.config/sops/age/keys.txt";
    
    # Example secrets - uncomment and configure as needed
    # secrets = {
    #   "user-password" = {
    #     neededForUsers = true;
    #   };
    #   "wifi-password" = {};
    #   "github-token" = {
    #     owner = config.users.users.user.name;
    #   };
    # };
  };

  # Security packages
  environment.systemPackages = with pkgs; [
    # SOPS and Age for secret management
    sops
    age
    ssh-to-age
    
    # Security tools
    gnupg
    pinentry-gtk2
    
    # Network security
    nmap
    wireshark
    tcpdump
    
    # System security
    rkhunter
    chkrootkit
    lynis
    
    # Firewall management
    ufw
    gufw
    
    # Password management
    keepassxc
    bitwarden
    
    # VPN clients
    openvpn
    wireguard-tools
    
    # Encryption tools
    cryptsetup
    veracrypt
  ];

  # Security services
  services = {
    # Fail2ban for intrusion prevention
    fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "10m";
    };
    
    # Enable automatic security updates
    unattended-upgrades = {
      enable = true;
    };
    
    # ClamAV antivirus
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
  };

  # Security-focused kernel parameters
  boot.kernel.sysctl = {
    # Disable magic SysRq key
    "kernel.sysrq" = 0;
    
    # Ignore ICMP redirects
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    
    # Ignore send redirects
    "net.ipv4.conf.all.send_redirects" = 0;
    
    # Disable source packet routing
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    
    # Log Martians
    "net.ipv4.conf.all.log_martians" = 1;
    
    # Ignore ICMP ping requests
    "net.ipv4.icmp_echo_ignore_all" = 1;
    
    # Ignore broadcast ping requests
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    
    # Disable IPv6 if not needed
    # "net.ipv6.conf.all.disable_ipv6" = 1;
    
    # TCP hardening
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;
    
    # Address Space Layout Randomization (ASLR)
    "kernel.randomize_va_space" = 2;
    
    # Restrict access to kernel logs
    "kernel.dmesg_restrict" = 1;
    
    # Restrict access to kernel pointers
    "kernel.kptr_restrict" = 2;
    
    # Disable kexec (which can be used to load a malicious kernel)
    "kernel.kexec_load_disabled" = 1;
    
    # Disable user namespaces (if not needed for containers)
    # "user.max_user_namespaces" = 0;
  };

  # Security programs
  programs = {
    # Enable GPG agent
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gtk2";
    };
    
    # Enable firewall
    firewall = {
      enable = true;
      allowPing = false;
    };
  };

  # Harden the system
  security = {
    # Sudo configuration
    sudo = {
      enable = true;
      execWheelOnly = true;
      requireAuthentication = true;
    };
    
    # Polkit for privilege escalation
    polkit.enable = true;
    
    # Enable AppArmor (alternative to SELinux)
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    
    # Enable audit framework
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
    
    # Protect kernel modules
    protectKernelImage = true;
    
    # Lock kernel modules
    lockKernelModules = false; # Set to true if you don't need to load kernel modules
    
    # Enable real-time kit
    rtkit.enable = true;
  };

  # User security settings
  users = {
    # Disable mutable users (forces declarative user management)
    mutableUsers = false;
    
    # Set default user shell
    defaultUserShell = pkgs.zsh;
  };

  # Systemd security settings
  systemd = {
    # Coredump configuration
    coredump.extraConfig = ''
      Storage=none
      ProcessSizeMax=0
    '';
    
    # Journal configuration for security
    services."systemd-journald".serviceConfig = {
      SystemMaxUse = "50M";
      RuntimeMaxUse = "10M";
    };
  };

  # Environment variables for security tools
  environment.variables = {
    EDITOR = "nvim";
    # Ensure GPG uses the correct TTY
    GPG_TTY = "$TTY";
  };
}