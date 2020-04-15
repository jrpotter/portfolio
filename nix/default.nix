{ miso ? import ./miso.nix, compiler ? "ghc865" }:
let
  callPackage = miso.pkgs.haskell.packages.${compiler}.callPackage;
  # Common packages used across our backend and frontend.
  postlude = callPackage ./postlude.nix {};
  common = callPackage ./common.nix { inherit postlude; };
  backend = callPackage ./backend.nix { inherit common postlude; };
  frontend = callPackage ./frontend.nix { inherit common postlude; };
in
  miso.pkgs.stdenv.mkDerivation {
    name = "portfolio";
    src = ./.;
    executableHaskellDepends = [ backend frontend ];
    prePatch = "hpack";
    license = "unknown";
    hydraPlatforms = miso.pkgs.stdenv.lib.platforms.none;
  }
