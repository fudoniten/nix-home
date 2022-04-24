{ config, lib, pkgs, username, user-email, home-dir, enable-gui, ... }:

with lib;
if !enable-gui then
  { }
else {
  home = {
    packages = with pkgs; [
      firefox
      gnome.gnome-tweaks
      google-chrome
      imagemagick
      jq
      minecraft
      pv
      spotify
      xclip
    ];

    keyboard = { layout = "us"; };

    username = username;
  };

  ## Sigh...have to wait for this
  # i18n.inputMethod = {
  #   enabled = "fcitx5";
  #   fcitx5.addons = [ pkgs.fcitx5-rime ];
  # };

  programs = { firefox.enable = true; };

  services = {
    # gammastep = {
    #   enable = true;
    #   latitude = 47;
    #   longitude = 122;
    # };

    gnome-keyring.enable = true;

    # redshift = {
    #   enable = true;
    #   latitude = "47";
    #   longitude = "122";
    # };
  };

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

  systemd.user.tmpfiles.rules = [
    "L+ /mnt/documents/${username} - - - - ${home-dir}/Documents"
    "L+ /mnt/downloads/${username} - - - - ${home-dir}/Downloads"
  ];
}
