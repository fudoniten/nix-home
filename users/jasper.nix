# Required packages
{ ... }:

# Local settings
{ username, user-email, enable-gui, home-dir, ... }:

{ pkgs, lib, ... }:

with lib;
if !enable-gui then {
  home.stateVersion = "22.05";
} else {
  home = {
    inherit username;

    stateVersion = "22.05";

    packages = with pkgs; [
      anki # flashcards
      gnome.gnome-tweaks
      google-chrome
      imagemagick
      jq
      minecraft
      mumble
      pv
      spotify
      xclip
    ];

    keyboard.layout = "us";
  };

  programs.firefox.enable = true;

  services.gnome-keyring.enable = true;

  accounts.email.accounts = {
    Fudo = {
      primary = true;
      address = "jasper@fudo.org";
      aliases = [ "jasper@selby.ca" ];
      userName = "jasper";
      realName = "Jasper Selby";
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
      address = "jasperjselby@gmail.com";
      flavor = "gmail.com";
      realName = "Jasper Selby";
    };
  };
}
