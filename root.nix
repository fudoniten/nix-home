{
  doom-emacs,
  niten-doom-config,
  config,
  lib,
  pkgs,
  username,
  user-email,
  home-dir,
  ...
}:

with lib;
let
  doom-emacs-package = pkgs.callPackage doom-emacs {
    doomPrivateDir = niten-doom-config;
    extraPackages = with pkgs.emacsPackages; [
      elpher
      use-package
    ];
    emacsPackagesOverlay = final: prev: {
      irony = prev.irony.overrideAttrs (esuper: {
        buildInputs = with pkgs;
          esuper.buildInputs ++
          [ cmake libclang clang ];
      });
    };
  };

  common-packages = with pkgs; [
    atop
    btrfs-progs
    cdrtools
    curl
    doom-emacs-package
    file
    git
    gnutls
    gnupg
    guile
    iptables
    lsof
    lshw
    mtr
    nix-prefetch-git
    nmap
    pciutils
    pwgen
    tmux
    unzip
  ];

  ensure-directories = [ ".emacs.d/.local/etc/eshell" ];

in {

  programs = {
    bash = {
      enable = true;
      enableVteIntegration = true;
    };

    git = {
      enable = true;
      userName = username;
      userEmail = user-email;
      ignores = [ "*~" ];
      extraConfig.pull.rebase = false;
    };
  };

  services = {
    emacs = {
      enable = true;
      package = doom-emacs-package;
      client = {
        enable = true;
      };
    };
  };

  home = {
    packages = common-packages;

    file = {
      # For nixified emacs
      ".emacs.d/init.el".text = ''
        (load "default.el")

        (setq package-archives nil)
        (package-initialize)
      '';
    };

    sessionVariables = {
      # EDITOR = "${doom-emacs}/bin/emacsclient -t";
      ALTERNATE_EDITOR = "";

      DOOM_EMACS_SITE_PATH = "${niten-doom-config}/site.d";

      HISTCONTROL = "ignoredups:ignorespace";
    };
  };

  systemd.user.tmpfiles.rules =
    map (dir: "d ${home-dir}/${dir} 700 root - - -") ensure-directories;
}
