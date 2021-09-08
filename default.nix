{ config, lib, pkgs, ... }:

let
  user-configs = {
    niten = ./niten.nix;
    root = ./niten.nix;
    viator = ./niten.nix;
    xiaoxuan = ./xiaoxuan.nix;
  };
  
in {
  generate-config = { username, user-email, home-dir }:
    { enable-gui ? false, ... }: pkgs.callPackage user-configs.${username} {
      inherit username user-email home-dir enable-gui;
    };
}
