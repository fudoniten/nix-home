# Required packages
{ ... }:

# Local settings
{ username, user-email, enable-gui, home-dir, ... }:

{ pkgs, lib, ... }:

with lib;
if !enable-gui then
  { }
else {
  home = {
    inherit username;

    packages = with pkgs; [
      anki # flashcards
      gnome.gnome-tweaks
      google-chrome
      imagemagick
      jq
      minecraft
      mumble
      python3
      pv
      racket
      spotify
      xclip

      # Video editors
      libsForQt5.kdenlive
      openshot
      shotcut
    ];

    keyboard.layout = "us";
  };

  programs = {
    firefox.enable = true;
    obs-studio.enable = true;
  };

  services = { gnome-keyring.enable = true; };

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
