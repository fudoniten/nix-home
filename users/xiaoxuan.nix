# Required packages
{ ... }:

# Local settings
{ pkgs, lib, username, user-email, enable-gui, home-dir, ... }:

with lib;
if !enable-gui then {
  home.stateVersion = "22.05";
} else {
  home = {
    inherit username;

    stateVersion = "22.05";

    packages = with pkgs; [
      abiword
      anki # flashcards
      #fcitx5
      #fcitx5-configtool
      #fcitx5-gtk
      gnome.gnome-tweaks
      google-chrome
      imagemagick
      jq
      minecraft
      mumble
      pv
      redshift
      spotify
      xclip
    ];

    keyboard = {
      layout = "us";
      options = "";
    };

    file = {
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

          export XMODIFIERS="@im=fcitx5"
          export XMODIFIER="@im=fcitx5"
          export GTK_IM_MODULE="fcitx5"
          export QT_IM_MODULE="fcitx5"
        '';
      };
    };
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pgks; [ fcitx5-chinese-addons fcitx5-gtk fcitx5-rime ];
  };

  programs.firefox.enable = true;

  services = { gnome-keyring.enable = true; };

  accounts.email.accounts = {
    Fudo = {
      primary = true;
      address = "xiaoxuan@fudo.org";
      aliases = [ "xiaoxuan@selby.ca" ];
      userName = "xiaoxuan";
      realName = "Xiaoxuan Jin";
      imap = {
        host = "mail.fudo.org";
        tls.enable = true;
        port = 993;
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
      address = "clairejin1223@gmail.com";
      flavor = "gmail.com";
      realName = "Xiaoxuan Jin";
    };
  };
}
