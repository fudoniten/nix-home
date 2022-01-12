{
  description = "Fudo Home Manager Configuration";

  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs?rev=971b383a28f4baee8ea3931af4840fa221929fd6";
    nixpkgs.url = "nixpkgs/nixos-21.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      #inputs.nixpkgs.url = "github:NixOS/nixpkgs?rev=971b383a28f4baee8ea3931af4840fa221929fd6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niten-doom-config = {
      url = "git+https://git.fudo.org/niten/doom-emacs.git";
      flake = false;
    };
    fudo-pkgs.url = "git+https://git.fudo.org/fudo-nix/pkgs.git";
    # For https://github.com/vlaci/nix-doom-emacs/issues/401
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      flake = false;
    };
    doom-emacs = {
      url = "github:vlaci/nix-doom-emacs";
      # inputs.nixpkgs.url = "github:NixOS/nixpkgs?rev=971b383a28f4baee8ea3931af4840fa221929fd6";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.emacs-overlay.follows = "emacs-overlay";
    };
  };

  outputs = { self,
              nixpkgs,
              home-manager,
              doom-emacs,
              fudo-pkgs,
              niten-doom-config, ... }: {
    nixosModule = {
      imports = [
        home-manager.nixosModules.home-manager
        (import ./module.nix { inherit doom-emacs niten-doom-config; })
      ];
    };

    homeConfigurations = {
      niten = let
        username = "niten";
        system = "x86_64-linux";
      in home-manager.lib.homeManagerConfiguration {
        inherit system username;
        homeDirectory = "/home/niten";
        configuration = { pkgs, lib, ... }: let
          doom-emacs-package = pkgs.callPackage doom-emacs {
            doomPrivateDir = niten-doom-config;
            extraPackages = with pkgs.emacsPackages; [
              elpher
              use-package
            ];
            # For https://github.com/vlaci/nix-doom-emacs/issues/401
            emacsPackagesOverlay = final: prev: {
              gitignore-mode = pkgs.emacsPackages.git-modes;
              gitconfig-mode = pkgs.emacsPackages.git-modes;
            };
          };
        in (import ./niten.nix {
          inherit system pkgs lib username niten-doom-config doom-emacs-package;

          user-email = "niten@fudo.org";
          home-dir = "/home/niten";
          enable-gui = true;
          localOverlays = [ fudo-pkgs.overlay ];
        });
      };
    };
  };
}
