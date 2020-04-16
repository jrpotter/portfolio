{ miso ? import ./miso, compiler ? "ghc865" }:
with miso.pkgs;
let
  callPackage = haskell.packages.${compiler}.callPackage;
  callCabal2nix = haskell.packages.${compiler}.callCabal2nix;
  # Reference to our Postlude library, containing an alternative to the base
  # Prelude provided out of the box. This was generated using the `cabal2nix`
  # CLI tool as opposed to through `callCabal2nix` like our other packages.
  postlude = callPackage ./postlude {};
  # Reference to common methods and data types to be shared between the backend
  # and frontend.
  common = callCabal2nix "common" ./common { inherit postlude; };
  # Invoke the runtime built by the `backend`. When testing this image locally,
  # we usually run docker in host mode and set environment variables according
  # to https://www.postgresql.org/docs/9.5/libpq-envars.html.
  entrypoint = writeScript "entrypoint.sh" (''
    #!${stdenv.shell}
  '');
in
  rec {
    # Reference to our servant backend used to serve the initial HTML pages and
    # return any XHR responses requested by the frontend.
    backend = callCabal2nix "backend" ./backend { inherit common postlude; };
    # Reference to our miso frontend used for generating dynamic webpages in an
    # Elm like fashion.
    frontend = callCabal2nix "frontend" ./frontend {
      inherit common postlude;
      miso = miso.miso-jsaddle;
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
