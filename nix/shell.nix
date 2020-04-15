{ miso ? import ./miso.nix, compiler ? "ghc865" }:
let
  link = "https://github.com/cachix/ghcide-nix/tarball/0ae8d9869ace81c4efaa279379c5a716280cb2b7";
  ghcide = (import (builtins.fetchTarball link) {}).ghcide-ghc865;
  # Reference to our library instances we may want to shell into.
  backend = (import ./default.nix { inherit miso compiler; }).backend.env;
  frontend = (import ./default.nix { inherit miso compiler; }).frontend.env;
  # Wrapper to inject our development fields into our nested environments.
  wrapper = env: env.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ ghcide ];
    # Hoogle by default will try to generate a database where it cannot.
    # Additionally, certain extensions of Visual Studio Code will assume the
    # hoogle database exists where it doesnt since this is running from nix.
    # Instead specify to a locally generated hoogle database created by running
    # `hoogle generate --database=hoogle/portfolio.hoo`.
    HIE_HOOGLE_DATABASE = ../hoogle/portfolio.hoo;
  });
in
  {
    backend = wrapper backend;
    frontend = wrapper frontend;
  }
