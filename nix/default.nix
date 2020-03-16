{ bootstrap ? import <nixpkgs> {}
, reflex-platform ? import ./reflex-platform.nix {}
}:
reflex-platform.project ({ pkgs, ... }: {
  packages = {
    common = ../common;
    backend = ../backend;
    frontend = ../frontend;
  };
  # Tells reflex to use jsaddle-warp, an alternative JSaddle backend that uses a
  # local `warp` server and WebSockets to control a browser from a native
  # Haskell project. Note, JSaddle is a set of libraries that allow reflex to
  # swap out its JavaScript backend easily.
  useWarp = true;
  # Defines which platforms we'd like to develop for, and which packages'
  # dependencies we want available in the development sandbox for that platform.
  shells = {
    ghc = ["common" "backend" "frontend"];
    ghcjs = ["common" "frontend"];
  };
})