{
  description = "Fudo Home Manager Configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-21.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doom-emacs.url = "github:vlaci/nix-doom-emacs";
    niten-doom-config = {
      url = "git+https://git.fudo.org/niten/doom-emacs.git";
      flake = false;
    };
  };

  outputs = { self,
              home-manager,
              doom-emacs,
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
        configuration = { pkgs, lib, ... }: (import ./niten.nix {
          inherit system pkgs lib username doom-emacs niten-doom-config;

          user-email = "niten@fudo.org";
          home-dir = "/home/niten";
          enable-gui = true;
        });
      };
    };
  };
}
