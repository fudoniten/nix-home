{ config, lib, pkgs, ... }: let

  doom-emacs-config = pkgs.fetchgit {
    url = "https://git.fudo.org/niten/doom-emacs.git";
    rev = "0ab1532c856ccdb6ce46c5948054279f439eb1f2";
    sha256 = "06mh74i5hmb15xid7w31wjc4v339cgddd667bpaphqnw666sm08h";
  };

  doom-emacs-pkg = pkgs.fetchgit {
    url = "https://github.com/vlaci/nix-doom-emacs.git";
    rev = "fee14d217b7a911aad507679dafbeaa8c1ebf5ff";
    sha256 = "1g0izscjh5nv4n0n1m58jc6z27i9pkbxs17mnb05a83ffdbmmva6";
  };

in pkgs.callPackage doom-emacs-pkg {
  doomPrivateDir = doom-emacs-config;
  extraPackages = with pkgs.emacsPackages; [
    elpher
    use-package
  ];
  emacsPackagesOverlay = final: prev: {
    irony = prev.irony.overrideAttrs (esuper: {
      buildInputs = esuper.buildInputs
                    ++ [ prev.cmake prev.libclang prev.clang ];
    });
    spinner = let version = "1.7.4";
              in prev.trivialBuild {
                inherit version;
                pname = "spinner";
                src = builtins.fetchTarball {
                  url = "https://elpa.gnu.org/packages/spinner-${version}.tar";
                  sha256 = "1jj40d68lmz91ynzwqg0jqdjpa9cn5md1hmvjfhy0cr3l16qpfw5";
                };
                buildPhase = ":";
              };
  };
}
