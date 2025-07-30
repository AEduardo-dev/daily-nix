{
  description = "Daily NixOS configuration with development and gaming setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # For neovim configuration
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, sops-nix, nixvim, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Helper to create nixos system
      mkSystem = hostname: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        # Desktop configuration - main development machine
        desktop = mkSystem "desktop";
        
        # You can add more hosts here (laptop, server, etc.)
        # laptop = mkSystem "laptop";
      };

      # Home manager configurations (for standalone usage)
      homeConfigurations = {
        "user@desktop" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./users/home.nix
            nixvim.homeManagerModules.nixvim
          ];
        };
      };

      # Development shell for working with this flake
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixd                    # Nix language server
          nixpkgs-fmt            # Nix formatter
          sops                   # For secrets management
          age                    # For encryption
          git                    # Version control
          alejandra              # Nix formatter alternative
        ];
        
        shellHook = ''
          echo "🚀 NixOS Configuration Development Environment"
          echo "Available tools: nixd, nixpkgs-fmt, sops, age, alejandra"
          echo ""
          echo "Useful commands:"
          echo "  nix flake check                 - Check flake validity"
          echo "  nixos-rebuild switch --flake .#desktop - Apply desktop config"
          echo "  home-manager switch --flake .#user@desktop - Apply home config"
          echo ""
        '';
      };

      # Formatter for 'nix fmt'
      formatter.${system} = pkgs.alejandra;
    };
}