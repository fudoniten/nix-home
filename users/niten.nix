# Required packages
{ doom-emacs, niten-doom-config, ... }:

# Local settings
{ username, user-email, enable-gui, home-dir, enable-kitty-term ? true, ... }:

{ config, pkgs, ... }:

with pkgs.lib;
let

  inherit (pkgs.stdenv) isLinux isDarwin;

  env-variables = {
    ALTERNATE_EDITOR = "";

    DOOM_EMACS_SITE_PATH = "${config.xdg.configHome}/doom-emacs/site.d";

    HISTCONTROL = "ignoredups:ignorespace";

    EMACS_ORG_DIRECTORY = "~/Notes";

    XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.nix-profile/share/";

    # DOOMDIR = "${config.xdg.configHome}/doom";
    # DOOMLOCALDIR = "${config.xdg.configHome}/doom.local";
  };

  pythonWithPackages = pkgs.python311.withPackages (pyPkgs:
    with pyPkgs; [
      ratelimit
      requests
      prettytable
      pylint
      python-lsp-server
    ]);

  emacsDependencies = with pkgs; [
    python311Packages.pylint
    python311Packages.python-lsp-server
    pythonWithPackages
  ];

  emacsPackages = with pkgs.emacsPackages; [
    chatgpt-shell
    elpher
    flycheck-clj-kondo
    md4rd
    ox-gemini
    pylint
    spotify
    use-package
  ];

  gui-packages = with pkgs;
    [
      # exodus # crypto wallet -- not found?
      spotify

      # Matrix clients
      element-desktop # matrix client
      #nheko
      #fractal
      #quaternion
    ] ++ (optionals isLinux [
      gnomeExtensions.espresso
      gnomeExtensions.focus
      gnomeExtensions.forge
      gnomeExtensions.avatar
      gnomeExtensions.vitals

      abiword
      alacritty # terminal
      anki # flashcards
      faudio # direct-x audio?
      gnome.dconf-editor # for gnome dconf config
      gnome.gnome-tweaks
      google-chrome
      gparted
      helvum # pipeaudio switch panel
      imagemagick
      kitty # terminal
      libreoffice
      xorg.libXxf86vm
      xorg.libXxf86vm.dev
      mattermost-desktop
      mindustry
      minecraft
      mplayer
      mumble
      nyxt # browser
      openal
      openttd
      playerctl
      rhythmbox
      signal-desktop
      spotify-player
      spotify-qt
      spotify-tui
      via # keyboard firmware tool
      vial # another keyboard firmware tool
      xclip
    ]);

  font-packages = optionals isLinux (with pkgs; [
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
  ]);

  common-packages = with pkgs;
    [
      ant
      asdf
      bind # for dig
      bundix # gemfile -> nix
      byobu
      cdrtools
      cargo # rust
      clj-kondo # Clojure linter
      clojure
      cmake
      curl
      # doom-emacs-package
      duf # fancy df
      enca # encoding detector
      file
      fish
      fortune
      fzf
      gcc
      git
      gnutls
      gnupg
      go
      graphviz
      guile
      home-manager
      inetutils
      ipfs
      jdk
      jq # command-line JSON parser
      leiningen
      lsof
      manix # nixos doc searcher
      mkpasswd
      mosh
      mtr # network diagnosis tool
      mqttui # CLI MQTT client
      nil # nix lsp server
      nixfmt # format nix files
      nix-index # search by executable
      nix-prefetch-git
      nix-prefetch-github
      openldap
      openssl
      openssl.out
      pciutils
      pv # dd with info
      pwgen
      pythonWithPackages
      ruby
      rustc
      statix # nix linter
      stdenv
      texlive.combined.scheme-basic
      tio # Serial IO
      tmux
      unzip
      wget
      # yubikey-manager
      # yubikey-personalization
      youtube-dl
      yq # yaml processor
    ] ++ (optionals isLinux [
      atop
      binutils
      btrfs-progs
      google-photos-uploader
      iptables
      jack2Full # audio daemon tools
      jami-client-qt # GNU chat app & voip client
      libisofs
      linphone # VoIP client
      lispPackages.quicklisp
      lshw
      # lz4json # For decompressing Mozilla sessions # Umm...missing?
      nmap
      parted
      sbcl
      supercollider # audio generation
      usbutils
      winetricks
    ]) ++ (optionals isDarwin [ bash ]);

  # doom-emacs-package = pkgs.callPackage doom-emacs {
  #   doomPrivateDir = niten-doom-config;
  #   extraPackages = emacs-packages;
  #   emacsPackagesOverlay = final: prev: {
  #     gitignore-mode = pkgs.emacsPackages.git-modes;
  #     gitconfig-mode = pkgs.emacsPackages.git-modes;
  #   };
  # };

in {

  imports = [ ../modules doom-emacs.hmModule ];

  config = {
    ## Necessary?
    # nixpkgs = {
    #   config.allowUnfree = true;
    #   overlays = mkIf (localOverlays != null) localOverlays;
    # };

    # gnome-manager.background = ./static/k3gy64wu8i5a1.png;

    programs = {
      bash = {
        enable = true;
        enableVteIntegration = true;
      };

      doom-emacs = {
        enable = true;
        doomPrivateDir = niten-doom-config;
        extraPackages = emacsPackages;
        emacsPackagesOverlay = final: prev: {
          gitignore-mode = pkgs.emacsPackages.git-modes;
          gitconfig-mode = pkgs.emacsPackages.git-modes;
        };
        extraConfig = let binPath = strings.makeBinPath emacsDependencies;
        in ''
          (setenv "XLIB_SKIP_ARGB_VISUALS" "1")
          (let ((inserted-paths (split-string "${binPath}" path-separator)))
            (setq exec-path (append exec-path inserted-paths)))

          (after! pylint
            (setq pylint-command "${pkgs.pylint}/bin/pylint"))

          ;;;; TODO: check if this is actually needed
          ;; (setq package-archives nil)
          ;; (package-initialize)
        '';
      };

      git = {
        enable = true;
        userName = username;
        userEmail = user-email;
        ignores = [ "*~" ".DS_Store" ];
        extraConfig.pull.rebase = false;
      };

      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
        settings = {
          editor = "emacsclient";
          git_protocol = "ssh";
        };
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      kitty = mkIf (isLinux && enable-gui) {
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

      firefox = mkIf isLinux {
        enable = enable-gui;
        ## Some perm change error?
        # package = (pkgs.firefox.override {
        #   cfg = {
        #     enableGnomeExtensions = true;
        #   };
        # });
      };
    };

    xresources.properties = mkIf (isLinux && enable-gui) {
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
        client.enable = true;
        defaultEditor = true;
      };

      gpg-agent.enable = true;

      gnome-keyring.enable = enable-gui;

      supercollider = mkIf isLinux {
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

      packages = if enable-gui then
        (common-packages ++ gui-packages ++ font-packages)
      else
        common-packages;

      # shellAliases = {
      #   ssh = mkIf (enable-gui && enable-kitty-term) "kitty +kitten ssh";
      # };

      file = {
        ".local/share/openttd/baseset" = mkIf (enable-gui && isLinux) {
          source = "${pkgs.openttd-data}/data";
        };

        "${config.xdg.configHome}/doom-emacs/site.d" = {
          recursive = true;
          source = "${niten-doom-config}/site.d";
        };

        # # For nixified emacs
        # # OBSOLETED by doom-emacs hmModule
        # ".emacs.d/init.el".text = ''
        #   (setenv "XLIB_SKIP_ARGB_VISUALS" "1")
        #   (load "default.el")

        #   (setq package-archives nil)
        #   (package-initialize)
        # '';

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
