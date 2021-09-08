{ config, lib, pkgs, username, user-email, home-dir, enable-gui, ... }:

with lib; if !enable-gui then {} else {
  home = {
    programs = with pkgs; [
      fcitx5-configtool
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

    keyboard = {
      layout = "us";
    };

    username = username;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-rime ];
  };

  programs = {
    firefox.enable = true;
  };

  services = {
    # gammastep = {
    #   enable = true;
    #   latitude = 47;
    #   longitude = 122;
    # };

    gnome-keyring.enable = true;

    redshift = {
      enable = true;
      latitude = 47;
      longitude = 122;
    };
  };

  accounts.email.accounts = {
    Fudo = {
      primary = true;
      address = "xiaoxuan@fudo.org";
      aliases = [ "xiaoxuan@selby.ca" ];
      userName = "xiaoxuan";
      realName = "Xiaoxuan Jin";
      imap = {
        host = "mail.fudo.org";
        tls = {
          enable = true;
          port = 993;
        };
      };
      smtp = {
        host = "mail.fudo.org";
        tls = {
          enable = true;
          useStartTls = true;
          port = 587;
        };
      };
    };

    GMail = {
      address = "clairejin1223@gmail.com";
      flavor = "gmail.com";
      realName = "Xiaoxuan Jin";
    };
  };

  systemd.user.tmpfiles.rules = [
    "L+ /mnt/documents/${username} - - - - ${home-dir}/Documents"
    "L+ /mnt/downloads/${username} - - - - ${home-dir}/Downloads"
  ];
}
