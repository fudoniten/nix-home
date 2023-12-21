# Required packages
{ ... }:

# Local settings
{ username, user-email, enable-gui, home-dir, ... }:

{ pkgs, lib, ... }:

with lib; {
  config = {
    home = {
      inherit username;
      homeDirectory = home-dir;

      packages = with pkgs; [
        atop
        bind # for dig
        binutils
        btrfs-progs
        byobu
        curl
        file
        git
        inetutils
        iptables
        lshw
        lsof
        mkpasswd
        mosh
        mtr
        nmap
        parted
        pv
        pwgen
        stdenv
        tmux
        unzip
        usbutils
        vim
        wget
      ];
    };

    programs = {
      bash = {
        enable = true;
        enableVteIntegration = true;
      };

      git = {
        enable = true;
        userName = username;
        userEmail = user-email;
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
      };
    };
  };
}
