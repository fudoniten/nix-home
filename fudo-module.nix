inputs:

{ config, lib, pkgs, ... }:

with lib;
let
  user-map = {
    jasper = "jasper";
    niten = "niten";
    root = "root";
    viator = "niten";
    xiaoxuan = "xiaoxuan";
  };

in {
  config.home-manager = let
    local-users = intersectLists (attrNames config.instance.local-users)
      (attrNames user-map);
  in {
    useGlobalPkgs = true;

    users = (listToAttrs (map (username:
      let
        config-user = getAttr username user-map;
        config-file = "./users/${config-user}.nix";
        cfg = config.fudo.users."${username}";
        hostname = config.instance.hostname;
        enable-gui = config.fudo.hosts."${hostname}".enable-gui;
        local-domain = config.instance.local-domain;
        user-email = if (isNull cfg.email) then
          cfg.email
        else
          "${username}@${local-domain}";
        home-dir = config.users.users.${username}.home;
      in nameValuePair username (import config-file inputs {
        inherit username user-email home-dir enable-gui hostname;

        # AFAIK this always works on NixOS hosts
        enable-kitty-term = true;
      })) local-users)) // {
        root = {
          username = "root";
          user-email = "root@${config.instance.local-domain}";
          home-dir = "/root";
        };
      };
  };
}
