{
  doom-emacs-package,
  niten-doom-config,
  lib,
  pkgs,
  username,
  user-email,
  home-dir,
  enable-gui ? false,
  localOverlays ? null,
  ...
}:

with lib;
let
  
  gui-packages = with pkgs; [
    element-desktop
    exodus
    faudio
    gnome.gnome-tweaks
    google-chrome
    imagemagick
    jq
    minecraft
    mplayer
    openttd
    pidgin
    pv
    redshift
    signal-desktop
    spotify
    nyxt
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
    cmake
    curl
    # doom-emacs-package
    duf
    enca
    file
    fortune
    git
    gnutls
    gnupg
    graphviz
    guile
    home-manager
    ipfs
    iptables
    jdk
    leiningen
    libisofs
    lispPackages.quicklisp
    lsof
    lshw
    manix
    mkpasswd
    mtr
    nixfmt
    nix-index
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
    winetricks
    yubikey-manager
    yubikey-personalization
    youtube-dl
    yq

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

  nixpkgs = mkIf (localOverlays != null) {
    config.allowUnfree = true;
    overlays = localOverlays;
  };
  
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

    firefox = {
      enable = enable-gui;
      ## Some perm change error?
      # package = (pkgs.firefox.override {
      #   cfg = {
      #     enableGnomeExtensions = true;
      #   };
      # });
    };
  };

  xresources.properties = mkIf enable-gui {
    "Xft.antialias" = 1;
    "Xft.autohint" = 0;
    # "Xft.dpi" = 192;
    "Xft.hinting" = 1;
    "Xft.hintstyle" = "hintfull";
    "Xft.lcdfilter" = "lcddefault";
  };

  services = {
    emacs = {
      enable = true;
      package = doom-emacs-package;
      client = {
        enable = true;
      };
    };

    gpg-agent.enable = true;

    gnome-keyring.enable = enable-gui;

    gammastep = {
      enable = true;
      latitude = "47";
      longitude = "122";
    };
  };

  home = {
    packages = if enable-gui then
      (common-packages ++ gui-packages) else
        common-packages;

    file = {
      ".local/share/openttd/baseset" =
        mkIf enable-gui { source = "${pkgs.openttd-data}/data"; };

      # For nixified emacs
      ".emacs.d/init.el".text = ''
        ;; No longer works?
        ;; (load "default.el")

        (setq package-archives nil)
        (package-initialize)
      '';

      ".xsessions" = mkIf enable-gui {
        executable = true;
        source = pkgs.writeShellScript "${username}-xsessions" ''
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
      ALTERNATE_EDITOR = "";

      DOOM_EMACS_SITE_PATH = "${niten-doom-config}/site.d";

      HISTCONTROL = "ignoredups:ignorespace";
    };
  };

  systemd.user.tmpfiles.rules =
    map (dir: "d ${home-dir}/${dir} 700 ${username} - - -") ensure-directories;
}
