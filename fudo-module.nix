inputs:

{ config, lib, pkgs, ... }:

with lib;
let
  userMap = {
    jasper = "jasper";
    niten = "niten";
    root = "root";
    viator = "niten";
    xiaoxuan = "xiaoxuan";
  };

  rootConfig = import ./users/root.nix inputs {
    inherit pkgs lib;
    username = "root";
    user-email = "root@${config.instance.local-domain}";
    home-dir = "/root";
  };

in {
  config.home-manager = let
    localUsers = intersectLists (attrNames config.instance.local-users)
      (attrNames user-map);
  in {
    useGlobalPkgs = true;

    users = (listToAttrs (map (username:
      if hasAttr username userMap then
        (let
          configFile = ./. + "/users/${getAttr username userMap}.nix";
          cfg = config.fudo.users."${username}";
          hostname = config.instance.hostname;
          enable-gui = config.fudo.hosts."${hostname}".enable-gui;
          localDomain = config.instance.localDomain;
          user-email = if isNull cfg.email then
            "${username}@${localDomain}"
          else
            cfg.email;
          home-dir = config.users.users."${username}".home;
        in nameValuePair username (import configFile inputs {
          inherit pkgs lib username user-email home-dir enable-gui hostname;
          # AFAIK this always works on NixOS hosts
          enable-kitty-term = true;
        }))
      else
        (nameValuePair username {
          home = {
            inherit username;
            stateVersion = 22.11;
          };
        })) localUsers)) // rootConfig;
  };
}
