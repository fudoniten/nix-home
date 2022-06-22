{ doom-emacs, niten-doom-config, ... }:

{ config, lib, pkgs, ... }:

with lib;
let
  user-configs = {
    jasper = ./jasper.nix;
    niten = ./niten.nix;
    root = ./root.nix;
    viator = ./niten.nix;
    xiaoxuan = ./xiaoxuan.nix;
  };

  hostname = config.instance.hostname;
  enable-gui = config.fudo.hosts.${hostname}.enable-gui;

  local-users = let local-usernames = attrNames config.instance.local-users;
  in filterAttrs (username: userOpts: elem username local-usernames)
  user-configs;

in {
  config.home-manager = {
    useGlobalPkgs = true;

    users = let
      doom-emacs-package = pkgs.callPackage doom-emacs {
        doomPrivateDir = niten-doom-config;
        extraPackages = with pkgs.emacsPackages; [
          elpher
          use-package
          flycheck-clj-kondo
        ];
        # For https://github.com/vlaci/nix-doom-emacs/issues/401
        emacsPackagesOverlay = final: prev: {
          gitignore-mode = pkgs.emacsPackages.git-modes;
          gitconfig-mode = pkgs.emacsPackages.git-modes;
        };
      };

      generate-config = username: config-file:
        let
          user-cfg = config.fudo.users.${username};
          user-email = if (user-cfg.email != null) then
            user-cfg.email
          else
            "${username}@${config.instance.local-domain}";
          home-dir = config.users.users.${username}.home;
        in {
          imports = [ ./modules ];

          config = (import user-configs.${username} {
            inherit config lib pkgs doom-emacs-package niten-doom-config
              username user-email home-dir enable-gui;
          });
        };
    in (mapAttrs generate-config local-users) // {
      root = import user-configs.root {
        inherit config lib pkgs niten-doom-config doom-emacs-package;
        username = "root";
        user-email = "root@${config.instance.local-domain}";
        home-dir = "/root";
      };
    };
  };
}
