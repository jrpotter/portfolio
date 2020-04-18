with (import ../nixpkgs);
let
  backend = (import ../default.nix {}).ghc.backend;
  frontend = (import ../default.nix {}).ghcjs.frontend;
  # Invoke the runtime built by the `backend`. When testing this image locally,
  # we usually run docker in host mode and set environment variables according
  # to https://www.postgresql.org/docs/9.5/libpq-envars.html.
  entrypoint = writeScript "entrypoint.sh" (''
    #!${stdenv.shell}
    ${backend}/bin/backend
  '');
in
  dockerTools.buildImage {
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
      # Copy over the javascript we need to serve from the backend.
      mkdir -p /app/static
      cp ${frontend}/bin/frontend.jsexe/* /app/static/
    '';
    config = {
      Entrypoint = [ entrypoint ];
      ExposedPorts = {
        "8080/tcp" = {};
      };
      WorkingDir = "/app";
    };
  }