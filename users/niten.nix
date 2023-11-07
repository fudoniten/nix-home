# Required packages
{ doom-emacs, niten-doom-config, ... }:

# Local settings
{ username, user-email, enable-gui, home-dir
, enable-kitty-term ? true, ... }:

{ pkgs, ... }:

with pkgs.lib;
let

  inherit (pkgs.stdenv) isLinux;

  env-variables = {
    ALTERNATE_EDITOR = "";

    DOOM_EMACS_SITE_PATH = "${niten-doom-config}/site.d";

    HISTCONTROL = "ignoredups:ignorespace";

    EMACS_ORG_DIRECTORY = "~/Notes";

    XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.nix-profile/share/";
  };

  python-with-packages = pkgs.python3.withPackages
    (pyPkgs: with pyPkgs; [ fastapi opencv4 python-multipart torch ]);

  emacs-packages = with pkgs.emacsPackages; [
    elpher
    flycheck-clj-kondo
    spotify
    use-package
  ];

  gui-packages = with pkgs;
    [
      alacritty # terminal
      anki # flashcards
      # exodus # crypto wallet -- not found?
      faudio # direct-x audio?
      helvum # pipeaudio switch panel
      imagemagick
      jq # command-line JSON parser
      kitty # terminal
      libreoffice
      mattermost-desktop
      mosh
      mindustry
      minecraft
      nyxt # browser
      openttd
      pidgin
      signal-desktop
      spotify
      spotify-player
      spotify-qt
      spotify-tui
      via # keyboard firmware tool

      # Matrix clients
      element-desktop # matrix client
      nheko
      fractal
      quaternion
    ] ++ (optionals isLinux ([
      gnomeExtensions.espresso
      gnomeExtensions.focus
      gnomeExtensions.forge
      gnomeExtensions.mpris-indicator-button
      gnomeExtensions.tweaks-in-system-menu
      gnomeExtensions.vitals
    ] ++ [
      abiword
      faudio
      gnome.dconf-editor # for gnome dconf config
      gnome.gnome-tweaks
      google-chrome
      gparted
      mplayer
      mumble
      playerctl
      rhythmbox
      xclip
    ]));

  font-packages = with pkgs; [
    cantarell-fonts
    dejavu_fonts
    fira-code
    fira-code-symbols
    liberation_ttf
    nerdfonts
    proggyfonts
    terminus_font
    ubuntu_font_family
    ultimate-oldschool-pc-font-pack
    unifont
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
    # cinny-desktop # matrix client -- obsolete SSL
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
    # ghc # haskell # too fuckin big
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
    jami-client-qt # GNU chat app & voip client
    leiningen
    libisofs
    linphone # VoIP client
    lispPackages.quicklisp
    lsof
    lshw
    lz4json # For decompressing Mozilla sessions
    manix # nixos doc searcher
    mkpasswd
    mtr # network diagnosis tool
    mqttui # CLI MQTT client
    nil # nix lsp server
    nixfmt # format nix files
    nix-index # search by executable
    nix-prefetch-git
    nix-prefetch-github
    nmap
    openldap
    openssl
    openssl.out
    parted
    pciutils
    pv # dd with info
    pwgen
    python-with-packages
    ruby
    rustc
    sbcl
    statix # nix linter
    stdenv
    supercollider # audio generation
    texlive.combined.scheme-basic
    tio # Serial IO
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

  doom-emacs-package = pkgs.callPackage doom-emacs {
    doomPrivateDir = niten-doom-config;
    extraPackages = emacs-packages;
    emacsPackagesOverlay = final: prev: {
      gitignore-mode = pkgs.emacsPackages.git-modes;
      gitconfig-mode = pkgs.emacsPackages.git-modes;
    };
  };

in {

  imports = [ ../modules ];

  config = {
    ## Necessary?
    # nixpkgs = {
    #   config.allowUnfree = true;
    #   overlays = mkIf (localOverlays != null) localOverlays;
    # };

    gnome-manager.background = ./static/k3gy64wu8i5a1.png;

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

      gh = {
        enable = true;
        enableGitCredentialHelper = true;
        settings = {
          editor = "emacsclient";
          git_protocol = "ssh";
        };
      };

      kitty = mkIf enable-gui {
        enable = enable-kitty-term;
        settings = {
          copy_on_select = "clipboard";
          strip_trailing_spaces = "always";
          editor = "emacsclient -t";
          enable_audio_bell = false;
          scrollback_lines = 10000;
          # theme = "Obsidian";
          # font_features = "ShureTechMono Nerd Font -liga";
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

    services = mkIf isLinux {
      emacs = {
        enable = true;
        package = doom-emacs-package;
        client.enable = true;
        defaultEditor = true;
      };

      gpg-agent.enable = true;

      gnome-keyring.enable = enable-gui;

      supercollider = {
        enable = true;
        port = 30300;
        memory = 4096;
      };

      syncthing = {
        enable = true;
        extraOptions = [ ];
      };
    };

    home = {
      inherit username;
      homeDirectory = home-dir;
      stateVersion = "22.05";

      packages = if enable-gui then
        (common-packages ++ gui-packages ++ font-packages)
      else
        common-packages;

      # shellAliases = {
      #   ssh = mkIf (enable-gui && enable-kitty-term) "kitty +kitten ssh";
      # };

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

    systemd.user = mkIf isLinux {
      tmpfiles.rules =
        [ "d ${home-dir}/.emacs.d/.local/etc/eshell 700 ${username} - - -" ];

      sessionVariables = env-variables;
    };
  };
}
