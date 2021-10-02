{ doom-emacs, niten-doom-config, ... }:

{ config, lib, pkgs, ... }:

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

  user-config-map = {
    niten = ./niten.nix;
    # FIXME: Root shouldn't have all this stuff installed!
    root = ./niten.nix;
    viator = ./niten.nix;
    xiaoxuan = ./xiaoxuan.nix;
  };

  local-users = let
    local-usernames = attrNames config.instance.local-users;
  in filterAttrs
    (username: userOpts: elem username local-usernames)
    user-config-map;

in {

  config.home-manager = {
    useGlobalPkgs = true;

    users = let
      generate-config = username: config-file: let
        user-cfg = config.fudo.users.${username};
        user-email = user-cfg.email;
        home-dir = user-cfg.home-directory;
      in (import user-configs.${username} {
        inherit
          config
          lib
          pkgs
          doom-emacs
          niten-doom-config
          username
          user-email
          home-dir
          enable-gui;
      });
    in mapAttrs generate-config local-users;
  };
}
