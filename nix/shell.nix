{ pkgs ? import <nixpkgs> {} }:
let
  # Include HIE support directly into our build inputs.
  hie-link = "https://github.com/infinisil/all-hies/tarball/master";
  all-hies = import (fetchTarball hie-link) {};
  hie = (all-hies.selection { selector = p: { inherit (p) ghc865; }; });
  # Stick to using ghc by default (instead of ghcjs) since it supports running
  # both our backend and frontend. This currently is also hardcoded to match the
  # same version of HIE above.
  ghc = (import ./default.nix { withHoogle = true; }).shells.ghc;
in
  ghc.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ hie ];
    # Hoogle by default will try to generate a database where it cannot.
    # Additionally, certain extensions of Visual Studio Code will assume the
    # hoogle database exists where it doesnt since this is running from nix.
    # Instead specify to a locally generated hoogle database created by running
    # `hoogle generate --database=hoogle/portfolio.hoo`.
    HIE_HOOGLE_DATABASE = ../hoogle/portfolio.hoo;
  })
