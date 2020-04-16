{ miso ? import ./miso, compiler ? "ghc865" }:
with miso.pkgs;
let
  shells = (import ./default.nix { inherit miso compiler; });
  # Reference to a version of ghcide that matches our compiler. Note the
  # latest version will have issues with mismatched GLIBC versions.
  rev = "0ae8d9869ace81c4efaa279379c5a716280cb2b7";
  link = "https://github.com/cachix/ghcide-nix/tarball/${rev}";
  ghcide = (import (builtins.fetchTarball link) {})."ghcide-${compiler}";
  # Wrapper to inject our development fields into our nested environments.
  wrapper = env: env.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ ghcide ];
    # Hoogle by default will try to generate a database where it cannot.
    # Additionally, certain extensions of Visual Studio Code will assume the
    # hoogle database exists where it doesnt since this is running from nix.
    # Instead specify to a locally generated hoogle database created by running
    # `hoogle generate --database=hoogle/portfolio.hoo`.
    HIE_HOOGLE_DATABASE = ./hoogle/portfolio.hoo;
  });
in
  {
    backend = wrapper shells.backend.env;
    frontend = wrapper shells.frontend.env;
  }
