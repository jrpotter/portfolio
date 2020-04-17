{ # The path to our Miso nix packages repository. We use the pinned nixpkgs
  # version miso provides since we know it to work.
  miso ? import ./miso
, # The compiler we should use for all but our GHCJS frontend.  
  ghc ? "ghc865"
, # The compiler we use for our GHCJS frontend.
  ghcjs ? "ghcjs86"
, # The miso specific compiler we want to use. This can be either `ghc`, `ghcjs`
  # or `jsaddle`. By default, we stick with GHCJS except during development.
  # Reference the nix shell file to see JSaddle specified there.
  js ? "ghcjs"
}:
with miso.pkgs;
let
  # Reference to our Postlude library, containing an alternative to the base
  # Prelude provided out of the box. This was generated using the `cabal2nix`
  # CLI tool as opposed to through `callCabal2nix` like our other packages.
  postlude = haskell.packages.${ghc}.callPackage ./postlude {};
  # Reference to common methods and data types to be shared between the backend
  # and frontend.
  common = haskell.packages.${ghc}.callCabal2nix "common" ./common {
    inherit postlude;
  };
  # Invoke the runtime built by the `backend`. When testing this image locally,
  # we usually run docker in host mode and set environment variables according
  # to https://www.postgresql.org/docs/9.5/libpq-envars.html.
  entrypoint = writeScript "entrypoint.sh" (''
    #!${stdenv.shell}
  '');
in
  rec {
    backend = haskell.packages.${ghc}.callCabal2nix "backend" ./backend {
      inherit common postlude;
    };
    frontend = haskell.packages.${ghcjs}.callCabal2nix "frontend" ./frontend {
      inherit common postlude;
      miso = miso."miso-${js}";
    };
    # A reference to the docker image containing our server (the backend API and
    # the compiled javascript files).
    server = dockerTools.buildImage {
      name = "server";
      runAsRoot = ''
        #!#{stdenv.shell}
        # This constant string is a helper for setting up the base files for
        # managing users and groups, only if such files don't exist already.
        # https://nixos.org/nixpkgs/manual/#ssec-pkgs-dockerTools-shadowSetup
        #
        # In particular, we need this so that our PostgreSQL dependency that
        # exists within our `backend` package can look up local user ids when
        # establishing database connections.
        ${dockerTools.shadowSetup}
      '';
      config = {
        Entrypoint = [ entrypoint ];
        ExposedPorts = {
          "8080/tcp" = {};
        };
        WorkingDir = "/app";
      };
    };
  }
