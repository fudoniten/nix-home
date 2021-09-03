{ config, lib, pkgs, ... }:
{ username, user-email, home-dir }:
{ enable-gui ? true, ... }:

with lib;
let
  
  gui-packages = with pkgs;
    let
      steam-with-pipewire =
        (steam.override { extraLibraries = pkgs: [ pkgs.pipewire ]; });
    in [
      exodus
      firefox
      gnome.gnome-tweaks
      google-chrome
      imagemagick
      jq
      minecraft
      mplayer
      nyxt
      openttd
      pv
      redshift
      signal-desktop
      spotify
      # steam-with-pipewire
      # steam-with-pipewire.run
      # steamPackages.steamcmd
      # steamPackages.steam-fonts
      # steamPackages.steam-runtime
      xclip
    ];

  common-packages = with pkgs; [
    ant
    asdf
    atop
    binutils
    btrfs-progs
    bundix
    byobu
    cdrtools
    cargo
    clojure
    clj2nix
    cmake
    curl
    user-doom-emacs
    enca
    file
    fortune
    git
    gnutls
    gnupg
    guile
    ipfs
    iptables
    jdk
    leiningen
    libisofs
    lispPackages.quicklisp
    lsof
    lshw
    mkpasswd
    mtr
    nixfmt
    nix-index
    nixops
    nix-prefetch-git
    nmap
    opencv-java
    openldap
    openssl
    pciutils
    pwgen
    python
    ruby
    rustc
    sbcl
    stdenv
    telnet
    texlive.combined.scheme-basic
    tmux
    unzip
    yubikey-manager
    yubikey-personalization
    youtube-dl

    # Check and pick a favorite
    molly-brown
    ncgopher
    amfora
    asuka
    kristall
    castor
  ];

  ensure-directories = [ ".emacs.d/.local/etc/eshell" ];

in {

  nixpkgs.overlays = [
    (pkgs.callPackage ./package-overlay.nix {})
  ];
  
  programs = {
    bash.enable = true;
    git = {
      enable = true;
      userName = username;
      userEmail = user-email;
      ignores = [ "*~" ];
      extraConfig.pull.rebase = false;
    };
  };

  xresources.properties = mkIf enable-gui {
    "Xft.antialias" = 1;
    "Xft.autohint" = 0;
    "Xft.dpi" = 192;
    "Xft.hinting" = 1;
    "Xft.hintstyle" = "hintfull";
    "Xft.lcdfilter" = "lcddefault";
  };

  services = {
    emacs = {
      enable = true;
      package = doom-emacs;
      client = {
        enable = true;
        arguments = [ "-t" ];
      };
    };

    gpg-agent.enable = true;
  };

  home = {
    packages = if enable-gui then (common-packages ++ gui-packages)
               else
                 common-packages;

    file = {
      ".local/share/openttd/baseset" =
        mkIf enable-gui { source = "${pkgs.openttd-data}/data"; };

      # For nixified emacs
      ".emacs.d/init.el".text = ''
        (load "default.el")

        (setq package-archives nil)
        ;; (add-to-list 'package-directory-list "~/.nix-profile/share/emacs/site-lisp/elpa")
        (package-initialize)
      '';

      ".xsessions" = mkIf enable-gui {
        executable = true;
        text = ''
          # -*-bash-*-
          gdmauth=$XAUTHORITY
          unset  XAUTHORITY
          export XAUTHORITY
          xauth merge "$gdmauth"

          if [ -f $HOME/.xinitrc ]; then
            bash --login -i $HOME/.xinitrc
          fi
        '';
      };
    };

    sessionVariables = {
      # EDITOR = "${doom-emacs}/bin/emacsclient -t";
      ALTERNATE_EDITOR = "";

      DOOM_EMACS_SITE_PATH = "${doom-emacs-config}/site.d";

      HISTCONTROL = "ignoredups:ignorespace";
    };
  };

  systemd.user.tmpfiles.rules =
    map (dir: "d ${homedir}/${dir} 700 niten - - -") ensure-directories;
}
