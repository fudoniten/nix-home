inputs:

{ config, lib, pkgs, ... }@toplevel:

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

    local-domain = mkOption {
      type = str;
      description = "Domain of the local host.";
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
            default = toplevel.config.users.users."${name}".home;
          };
        };
      }));
      default = { };
    };
  };

  config.home-manager = let users = attrNames config.users.users;
  in {
    useGlobalPkgs = true;

    users = (genAttrs users (username:
      mkIf (hasAttr username user-map) (let
        userOpts = config.users.users."${username}";
        configUser = user-map."${username}";
        configFile = ./. + "/users/${configUser}.nix";
      in pkgs.callPackage config-file inputs {
        inherit lib pkgs;
        inherit (userOpts) username user-email home-dir;
        inherit (cfg) enable-gui enable-kitty-term;
      }))) // {
        root = import ./users/root.nix inputs {
          inherit pkgs lib;
          username = "root";
          user-email = "root@${cfg.local-domain}";
          home-dir = "/root";
        };
      };
  };
}
