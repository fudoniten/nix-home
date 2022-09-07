# Required packages
{ ... }:

# Local settings
{ username, user-email, enable-gui, home-dir, ... }:

# The module itself
{ config, lib, pkgs, ... }:

with lib;
if !enable-gui then
  { }
else {
  home = {
    inherit username;

    packages = with pkgs; [
      fcitx5-configtool
      fcitx5-gtk
      firefox
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

    keyboard.layout = "us";
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
