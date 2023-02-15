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
      fcitx5-configtool
      fcitx5-gtk
      gnome.gnome-tweaks
      google-chrome
      imagemagick
      jq
      minecraft
      pv
      redshift
      spotify
      xclip
    ];

    keyboard = {
      layout = "us";
      options = "";
    };
  };

  ## Sigh...have to wait for this
  # i18n.inputMethod = {
  #   enabled = "fcitx5";
  #   fcitx5.addons = [ pkgs.fcitx5-rime ];
  # };

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
