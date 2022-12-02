# Required packages
{ doom-emacs, niten-doom-config, ... }:

# Local settings
{ pkgs, lib, username, user-email, home-dir, ... }:

with lib;
let
  common-packages = with pkgs; [
    atop
    btrfs-progs
    cdrtools
    curl
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

  emacs-packages = with pkgs.emacsPackages; [
    elpher
    use-package
    flycheck-clj-kondo
  ];

  doom-emacs-package = pkgs.callPackage doom-emacs {
    doomPrivateDir = niten-doom-config;
    extraPackages = emacs-packages;
    emacsPackagesOverlay = final: prev: {
      gitignore-mode = pkgs.emacsPackages.git-modes;
      gitconfig-mode = pkgs.emacsPackages.git-modes;
    };
  };

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
      client.enable = true;
    };
  };

  home = {
    stateVersion = "22.05";

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
      ALTERNATE_EDITOR = "";

      DOOM_EMACS_SITE_PATH = "${niten-doom-config}/site.d";

      HISTCONTROL = "ignoredups:ignorespace";
    };
  };

  systemd.user.tmpfiles.rules =
    [ "d ${home-dir}/.emacs.d/.local/etc/eshell 700 root - - -" ];

}
