{
  description = "Fudo Home Manager Configuration";

  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-21.05";
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
  };
}