{
  description = "Fudo Home Manager Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niten-doom-config = {
      url = "git+https://git.fudo.org/niten/doom-emacs.git";
      flake = false;
    };
    fudo-pkgs.url = "git+https://git.fudo.org/fudo-nix/pkgs.git";
    doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosModules = {
      default = {
        imports = [
          home-manager.nixosModules.home-manager
          (import ./fudo-module.nix inputs)
        ];
      };

      live-disk = {
        imports = [
          home-manager.nixosModules.home-manager
          (import ./module.nix inputs)
        ];
      };

      homeConfigurations.niten = let system = "x86_64-linux";
      in home-manager.lib.homeManagerConfiguration {
        inherit system;
        username = "niten";
        homeDirectory = "/home/niten";
        configuration = { pkgs, lib, ... }:
          import ./users/niten.nix inputs {
            inherit pkgs lib;
            username = "niten";
            user-email = "niten@fudo.org";
            enable-gui = true;
            home-dir = "/home/niten";
            enable-kitty-term = false;
          };
      };
    };
  };
}
