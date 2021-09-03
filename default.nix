{ config, lib, pkgs, ... }:

{
  generate-config = pkgs.callPackage ./home.nix { };
}
