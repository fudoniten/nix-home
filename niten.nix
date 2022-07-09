{ doom-emacs-package, niten-doom-config, lib, pkgs, username, user-email
, home-dir, enable-gui ? false, localOverlays ? null, ... }@toplevel:

with lib;
let

  env-variables = {
    ALTERNATE_EDITOR = "";

    DOOM_EMACS_SITE_PATH = "${niten-doom-config}/site.d";

    HISTCONTROL = "ignoredups:ignorespace";

    EMACS_ORG_DIRECTORY = "~/Notes";

    XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.nix-profile/share/";
  };

  use-kitty-term = true;

  gui-packages = with pkgs;
    [
      abiword
      alacritty # terminal
      element-desktop # matrix client
      exodus # crypto wallet
      faudio # direct-x audio?
      gnome.gnome-tweaks
      google-chrome
      gparted
      helvum # pipeaudio switch panel
      imagemagick
      jq # command-line JSON parser
      kitty # terminal
      libreoffice
      mindustry
      minecraft
      mplayer
      mumble # game chat
      nyxt # browser
      openttd
      pidgin
      playerctl # media control cli
      signal-desktop
      spotify
      via # keyboard firmware tool
      xclip # copy and paste
    ] ++ [
      gnomeExtensions.espresso
      gnomeExtensions.focus
      gnomeExtensions.forge
      gnomeExtensions.mpris-indicator-button
      gnomeExtensions.tweaks-in-system-menu
      gnomeExtensions.vitals
    ];

  font-packages = with pkgs; [
    cantarell-fonts
    dejavu_fonts
    dina-font
    dosemu_fonts
    fira-code
    fira-code-symbols
    freefont_ttf
    liberation_ttf
    ## Not a valid package?
    # mplus-outline-fonts
    nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ## Errors building
    # proggyfonts
    terminus_font
    ubuntu_font_family
    ucs-fonts
    ultimate-oldschool-pc-font-pack
    unifont
    xorg.fontadobe100dpi
    xorg.fontadobe75dpi
    xorg.fontadobeutopia100dpi
    xorg.fontadobeutopia75dpi
    xorg.fontadobeutopiatype1
    xorg.fontarabicmisc
    xorg.fontbh100dpi
    xorg.fontbh75dpi
    xorg.fontbhlucidatypewriter100dpi
    xorg.fontbhlucidatypewriter75dpi
    xorg.fontbhttf
    xorg.fontbhtype1
    xorg.fontbitstream100dpi
    xorg.fontbitstream75dpi
    xorg.fontbitstreamtype1
    xorg.fontcronyxcyrillic
    xorg.fontcursormisc
    xorg.fontdaewoomisc
    xorg.fontdecmisc
    xorg.fontibmtype1
    xorg.fontisasmisc
    xorg.fontjismisc
    xorg.fontmicromisc
    xorg.fontmisccyrillic
    xorg.fontmiscethiopic
    xorg.fontmiscmeltho
    xorg.fontmiscmisc
    xorg.fontmuttmisc
    xorg.fontschumachermisc
    xorg.fontscreencyrillic
    xorg.fontsonymisc
    xorg.fontsunmisc
    xorg.fontwinitzkicyrillic
    xorg.fontxfree86type1
  ];

  common-packages = with pkgs; [
    ant
    asdf
    atop
    bind # for dig
    binutils
    btrfs-progs
    bundix # gemfile -> nix
    byobu
    cdrtools
    cargo # rust
    clj-kondo # Clojure linter
    clojure
    cmake
    curl
    doom-emacs-package
    duf # fancy df
    enca # encoding detector
    file
    fish
    fortune
    fzf
    gcc
    ghc # haskell
    git
    gnutls
    gnupg
    graphviz
    guile
    home-manager
    inetutils
    ipfs
    iptables
    jack2Full # audio daemon tools
    leiningen
    libisofs
    lispPackages.quicklisp
    lsof
    lshw
    manix # nixos doc searcher
    mkpasswd
    mtr # network diagnosis tool
    nixfmt # format nix files
    nix-index # search by executable
    nix-prefetch-git
    nix-prefetch-github
    nmap
    opencv-java # open computer vision
    openldap
    openssl
    openssl.out
    parted
    pciutils
    pv # dd with info
    pwgen
    python
    ruby
    rustc
    sbcl
    statix # nix linter
    stdenv
    supercollider # audio generation
    texlive.combined.scheme-basic
    tmux
    unzip
    usbutils
    wget
    winetricks
    # yubikey-manager
    # yubikey-personalization
    youtube-dl
    yq # yaml processor
  ];

  ensure-directories = [ ".emacs.d/.local/etc/eshell" ];

in {

  nixpkgs = {
    config.allowUnfree = true;
    overlays = mkIf (localOverlays != null) localOverlays;
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

    kitty = mkIf enable-gui {
      enable = use-kitty-term;
      settings = {
        copy_on_select = "clipboard";
        strip_trailing_spaces = "always";
        editor = "emacsclient -t";
        enable_audio_bell = false;
        scrollback_lines = 10000;
        # theme = "Obsidian";
        #font_features = "ShureTechMono Nerd Font -liga";
      };
      font = {
        package = pkgs.nerdfonts;
        name = "Terminess (TTF) Nerd Font Complete Mono";
        # name = "Shure Tech Mono Nerd Font Complete Mono";
        size = 14;
        #package = pkgs.inconsolata;
        #name = "Incosolata";
        #size = 10;
      };
      keybindings = let lead = "ctrl+super";
      in {
        "ctrl+shift+plus" = "no_op";
        "ctrl+shift+minus" = "no_op";
        "ctrl+shift+backspace" = "no_op";

        "${lead}+plus" = "change_font_size all +2.0";
        "${lead}+minus" = "change_font_size all -2.0";
        "${lead}+backspace" = "change_font_size all 0";

        "${lead}+left" = "previous_tab";
        "${lead}+right" = "next_tab";
        "${lead}+t" = "new_tab";
        "${lead}+alt+t" = "set_tab_title";
        "${lead}+x" = "detach_tab";
      };
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
      client.enable = true;
      defaultEditor = true;
    };

    gpg-agent.enable = true;

    gnome-keyring.enable = enable-gui;

    ## Using Gnome
    # gammastep = {
    #   enable = true;
    #   latitude = "47";
    #   longitude = "122";
    # };

    # supercollider = {
    #   enable = true;
    #   port = 30300;
    # };

    syncthing = {
      enable = true;
      extraOptions = [ ];
    };
  };

  home = {
    packages = if enable-gui then
      (common-packages ++ gui-packages ++ font-packages)
    else
      common-packages;

    # shellAliases = mkIf use-kitty-term { ssh = "kitty +kitten ssh"; };

    file = {
      ".local/share/openttd/baseset" =
        mkIf enable-gui { source = "${pkgs.openttd-data}/data"; };

      # For nixified emacs
      ".emacs.d/init.el".text = ''
        (setenv "XLIB_SKIP_ARGB_VISUALS" "1")
        (load "default.el")

        (setq package-archives nil)
        (package-initialize)
      '';

      ".xprofile" = mkIf enable-gui {
        executable = true;
        source = pkgs.writeShellScript "${username}-xsession" ''
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
    sessionVariables = env-variables;
  };

  systemd.user = {
    tmpfiles.rules = map (dir: "d ${home-dir}/${dir} 700 ${username} - - -")
      ensure-directories;

    sessionVariables = env-variables;
  };

  fonts.fontconfig.enable = enable-gui;
}
