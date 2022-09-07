inputs:

{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.fudo.home-manager;

  user-map = {
    jasper = "jasper";
    niten = "niten";
    root = "root";
    viator = "niten";
    xiaoxuan = "xiaoxuan";
  };
in {
  options.fudo.home-manager = with types; {
    enable-gui = mkOption {
      type = bool;
      description = "Enable GUI-dependent options on this host.";
      default = false;
    };

    enable-kitty-term = mkOption {
      type = bool;
      description = "Enable Kitty terminal.";
      default = false;
    };

    users = mkOption {
      type = attrsOf (submodule ({ name, ... }: {
        options = {
          username = mkOption {
            type = str;
            default = name;
          };

          user-email = mkOption { type = str; };

          home-dir = mkOption {
            type = str;
            default = "/home/${name}";
          };
        };
      }));
      default = { };
    };
  };

  config.home-manager = {
    useGlobalPkgs = true;

    users = mapAttrs (_: userOpts:
      let
        config-user = user-map."${userOpts.username}";
        config-file = ./. + "/users/${config-user}.nix";
      in pkgs.callPackage config-file inputs {
        inherit (userOpts) username user-email home-dir;
        inherit (cfg) enable-gui enable-kitty-term;
      }) cfg.users;
  };
}
