{
  description = "A flake template for nix-darwin and Determinate Nix";

  ########################################
  # Flake Inputs
  ########################################
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  ########################################
  # Flake Outputs
  ########################################
  outputs =
    { self, ... }@inputs:
    let
      username = "sreysus";
      system = "aarch64-darwin";
      vscodeExtensionsOverlay = inputs.nix-vscode-extensions.overlays.default;
      openclawOverlay = inputs.nix-openclaw.overlays.default;
    in
    {
      ########################################
      # System Configuration (nix-darwin)
      ########################################
      darwinConfigurations."${username}-${system}" = inputs.nix-darwin.lib.darwinSystem {
        inherit system;

        modules = [
          ########################################
          # Determinate Nix
          ########################################
          inputs.determinate.darwinModules.default

          ########################################
          # nix-homebrew
          ########################################
          inputs.nix-homebrew.darwinModules.nix-homebrew
          self.darwinModules.homebrew

          ########################################
          # Base nix-darwin Config
          ########################################
          self.darwinModules.base

          ########################################
          # Determinate Nix Config
          ########################################
          self.darwinModules.nixConfig

          ########################################
          # Overlays
          ########################################
          self.darwinModules.overlays

          ########################################
          # Home Manager
          ########################################
          inputs.home-manager.darwinModules.home-manager
          self.darwinModules.homeManager
        ];
      };

      ########################################
      # nix-darwin Modules
      ########################################
      darwinModules = {
        base = import ./darwin/base.nix { inherit self username; };
        homebrew = import ./darwin/homebrew.nix;
        homeManager = import ./darwin/home-manager.nix {
          inherit username;
          openclawHomeManagerModule = inputs.nix-openclaw.homeManagerModules.openclaw;
        };
        nixConfig = import ./darwin/nix-config.nix;
        overlays = import ./darwin/overlays.nix {
          inherit
            vscodeExtensionsOverlay
            openclawOverlay
            ;
        };
      };

      ########################################
      # DevShell
      ########################################
      devShells.${system}.default =
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        pkgs.mkShellNoCC {
          packages = with pkgs; [
            (writeShellApplication {
              name = "apply-nix-darwin-configuration";
              runtimeInputs = [
                inputs.nix-darwin.packages.${system}.darwin-rebuild
              ];
              text = ''
                echo "> Applying nix-darwin configuration..."
                echo "> Running darwin-rebuild switch as root..."
                sudo darwin-rebuild switch --flake .#"${username}-${system}"
                echo "> darwin-rebuild switch was successful ✅"
                echo "> macOS config was successfully applied 🚀"
              '';
            })

            self.formatter.${system}
          ];
        };

      ########################################
      # Formatter
      ########################################
      formatter.${system} = inputs.nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
