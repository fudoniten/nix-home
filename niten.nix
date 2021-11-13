{
  doom-emacs,
  niten-doom-config,
  config,
  lib,
  pkgs,
  username,
  user-email,
  home-dir,
  enable-gui,
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
  
  gui-packages = with pkgs; [
      exodus
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
    doom-emacs-package
    element-desktop
    enca
    faudio
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
      enable = true;
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

    gnome-keyring.enable = true;

    # redshift = {
    #   enable = true;
    #   latitude = "47";
    #   longitude = "122";
    # };

    gammastep = {
      enable = true;
      latitude = "47";
      longitude = "122";
    };
  };

  accounts.email.accounts = {
    Fudo = {
      primary = true;
      address = "niten@fudo.org";
      aliases = [ "peter@selby.ca" ];
      userName = "niten";
      realName = "Niten";
      imap = {
        host = "mail.fudo.org";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "mail.fudo.org";
        port = 587;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };
    };

    GMail = {
      address = "pselby@gmail.com";
      flavor = "gmail.com";
      realName = "Peter Selby";
    };
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

      DOOM_EMACS_SITE_PATH = "${niten-doom-config}/site.d";

      HISTCONTROL = "ignoredups:ignorespace";
    };
  };

  systemd.user.tmpfiles.rules =
    map (dir: "d ${home-dir}/${dir} 700 niten - - -") ensure-directories;
}
