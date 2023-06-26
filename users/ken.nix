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
  };

  programs.firefox.enable = true;

  services = { gnome-keyring.enable = true; };

  accounts.email.accounts = {
    Fudo = {
      primary = true;
      address = "ken@selby.ca";
      userName = "ken";
      realName = "Ken Selby";
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
  };
}
