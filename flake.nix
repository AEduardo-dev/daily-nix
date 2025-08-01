{
  description = "Minimal NixOS Flakes Configuration with Home Manager and SOPS";

  inputs = {
    # Main nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager for user environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # SOPS for secrets management with SSH keys
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Generic host configuration helper
      mkHost = { hostname, username, system ? "x86_64-linux" }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit hostname username; };
        modules = [
          # Import our basic system configuration
          ./minimal-config/system.nix
          
          # SOPS configuration
          sops-nix.nixosModules.sops
          
          # Home Manager integration
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./minimal-config/home.nix;
              extraSpecialArgs = { inherit hostname username; };
            };
          }
          
          # Hardware configuration (will be generated or detected)
          ./minimal-config/hardware.nix
          
          # Host-specific configuration
          {
            networking.hostName = hostname;
            users.users.${username} = {
              isNormalUser = true;
              extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
              # Password will be set via SOPS
              hashedPasswordFile = "/run/secrets/user-password";
            };
          }
        ];
      };
    in
    {
      # Default system configuration for generic host
      nixosConfigurations = {
        # Generic host - can be customized
        nixos = mkHost {
          hostname = "nixos";
          username = "user";
        };
      };

      # Standalone Home Manager configuration
      homeConfigurations = {
        "user@nixos" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { hostname = "nixos"; username = "user"; };
          modules = [ ./minimal-config/home.nix ];
        };
      };

      # Development shell for configuration management
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          sops
          ssh-to-age  # Convert SSH keys to age keys for SOPS
          git
          nix
        ];
        
        shellHook = ''
          echo "🔧 Minimal NixOS Configuration Development Shell"
          echo "Available tools: sops, ssh-to-age, git, nix"
          echo ""
          echo "Quick commands:"
          echo "  ./setup.sh                      - Run interactive setup"
          echo "  nix flake check                 - Validate configuration"
          echo "  sudo nixos-rebuild switch --flake .#nixos - Apply config"
          echo ""
        '';
      };

      # Helper for creating custom host configurations
      lib = {
        mkHost = mkHost;
        
        # Helper to create a new host configuration
        mkCustomHost = { hostname, username, extraModules ? [] }: mkHost {
          inherit hostname username;
        } // {
          modules = mkHost { inherit hostname username; }.modules ++ extraModules;
        };
      };
    };
}