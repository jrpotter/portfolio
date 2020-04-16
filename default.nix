{ miso ? import ./miso, compiler ? "ghc865" }:
with miso.pkgs;
let
  callPackage = haskell.packages.${compiler}.callPackage;
  # Common user-defined packages used across our backend and frontend.
  postlude = callPackage ./postlude {};
  common = callPackage ./common { inherit postlude; };
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
    backend = callPackage ./backend { inherit common postlude; };
    # Our GHCJS project. During development we stick with testing vis JSaddle.
    # During production we are expected to compile our Haskell into Javascript
    # and pass said files into the backend for serving.
    frontend = callPackage ./frontend { inherit common postlude; };
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
