{ doom-emacs, niten-doom-config, config, lib, pkgs, ... }:

with lib;
let
  user-configs = {
    niten = ./niten.nix;
    root = ./niten.nix;
    viator = ./niten.nix;
    xiaoxuan = ./xiaoxuan.nix;
  };

  hostname = config.instance.hostname;
  enable-gui = config.fudo.hosts.${hostname}.enable-gui;
  
in {

  config.home-manager = {
    useGlobalPkgs = true;

    users = let
      generate-config = username: config-file: let
        user-cfg = config.fudo.users.${username};
        user-email = user-cfg.email;
        home-dir = user-cfg.home-directory;
      in import user-configs.${username}
        { inherit username user-email home-dir; };
    in mapAttrs generate-config {
      niten = ./niten.nix;
      # FIXME: Root shouldn't have all this stuff installed!
      root = ./niten.nix;
      viator = ./niten.nix;
      xiaoxuan = ./xiaoxuan.nix;
    };
  };
}
