{
  description = "Blue: nix-darwin, Home Manager, and Determinate Nix";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    # Local tt fork: terminal rendering fixes are built from this checkout.
    tt-src = {
      url = "path:/Users/sreysus/workflow/tt";
      flake = false;
    };

    # Markdown language server for the notes vault, built from the local
    # repository's committed tree. Refresh: `nix flake update weft-src`.
    weft-src = {
      url = "git+file:///Users/sreysus/workflow/weft";
      flake = false;
    };

    # Terminal graph editor (Typst/Fletcher export). Keeps its own nixpkgs pin
    # so the build matches the editor's lock. Update: `nix flake update petersen`.
    petersen.url = "github:sreyassabbani/petersen";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      username = "sreysus";
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Modules live in `darwin/` and `home/`; every file there is imported.
      darwinConfigurations."${username}-${system}" = inputs.nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit self inputs username; };
        modules = [
          inputs.determinate.darwinModules.default
          inputs.nix-homebrew.darwinModules.nix-homebrew
          inputs.home-manager.darwinModules.home-manager
          ./darwin
        ];
      };

      packages.${system} = {
        tt = pkgs.callPackage ./pkgs/tt.nix { source = inputs.tt-src; };
        weft = pkgs.callPackage ./pkgs/weft.nix { source = inputs.weft-src; };
        mobile-development =
          (import ./pkgs/mobile-development.nix {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }).package;
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
