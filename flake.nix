{
  description = "Fudo Home Manager Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niten-doom-config = {
      url = "git+https://fudo.dev/niten/doom-emacs.git";
      flake = false;
    };
    fudo-pkgs = {
      url = "git+https://fudo.dev/nix/pkgs.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gnome-manager = {
      url = "github:fudoniten/gnome-manager?ref=hm-module";
      # url = "path:/state/gnome-manager";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    { self, nixpkgs, home-manager, fudo-pkgs, gnome-manager, ... }@inputs: {
      nixosModules = rec {
        default = fudo;

        fudo = {
          imports = [
            home-manager.nixosModules.home-manager
            gnome-manager.nixosModules.default
            (import ./fudo-module.nix inputs)
          ];
        };

        nonfudo = {
          imports = [
            home-manager.nixosModules.home-manager
            gnome-manager.nixosModules.default
            (import ./module.nix inputs)
          ];
        };

        live-disk = {
          imports = [
            home-manager.nixosModules.home-manager
            (import ./module.nix inputs)
          ];
        };
      };

      homeConfigurations.niten = let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ fudo-pkgs.overlays.default ];
        };
      in home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          gnome-manager.homeManagerModules.default
          (import ./users/niten.nix inputs {
            username = "niten";
            user-email = "niten@fudo.org";
            enable-gui = true;
            home-dir = "/home/niten";
            enable-kitty-term = false;
          })
        ];
      };

      mkModule = { username, user-email, enable-gui ? false, home-dir
        , enable-kitty-term ? false, ... }:
        import ./users/niten.nix inputs {
          inherit username user-email enable-gui home-dir enable-kitty-term;
        };
    };
}
