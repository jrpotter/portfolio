{ reflex-platform ? import ./reflex-platform.nix {} }:
reflex-platform.project ({ pkgs, ... }: {
  useWarp = true;
  packages = {
    common = ../common;
    backend = ../backend;
    frontend = ../frontend;
  };
  shells = {
    ghc = ["common" "backend" "frontend"];
    ghcjs = ["common" "frontend"];
  };
})
