{ doom-emacs, niten-doom-config, ... }:

{ config, lib, pkgs, ... }:

with lib;
let
  user-configs = {
    niten = ./niten.nix;
    root = ./root.nix;
    viator = ./niten.nix;
    xiaoxuan = ./xiaoxuan.nix;
  };

  hostname = config.instance.hostname;
  enable-gui = config.fudo.hosts.${hostname}.enable-gui;

  local-users = let
    local-usernames = attrNames config.instance.local-users;
  in filterAttrs
    (username: userOpts: elem username local-usernames)
    user-configs;

in {
  config.home-manager = {
    useGlobalPkgs = true;

    users = let
      generate-config = username: config-file: let
        user-cfg = config.fudo.users.${username};
        user-email = if (user-cfg.email != null) then
          user-cfg.email else "${username}@${config.instance.local-domain}";
        home-dir = config.users.users.${username}.home;
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
    in (mapAttrs generate-config local-users) // {
      root = import user-configs.root {
        inherit
          config
          lib
          pkgs
          doom-emacs
          niten-doom-config;
        username = "root";
        user-email = "root@${config.instance.local-domain}";
        home-dir = "/root";
      };
    };
  };
}
