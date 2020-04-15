{ miso ? import ./miso.nix, compiler ? "ghc865" }:
with miso.pkgs;
let
  # Reference to our library instances we may want to shell into.
  backend = (import ./default.nix { inherit miso compiler; }).backend.env;
  frontend = (import ./default.nix { inherit miso compiler; }).frontend.env;
  # Invoke the runtime built by the `backend`. When testing this image locally,
  # we usually run docker in host mode and set environment variables according
  # to https://www.postgresql.org/docs/9.5/libpq-envars.html.
  entrypoint = writeScript "entrypoint.sh" (''
    #!${stdenv.shell}
  '');
in
  dockerTools.buildImage {
    name = "backend";
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
  }
