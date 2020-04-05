{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  # Note this matches how we would run `nix-build` manually. Refer to the
  # README.md for more details.
  backend = (import ./default.nix {}).ghc.backend;
  # Invoke the runtime built by the `backend`. When testing this image locally,
  # we run docker in host mode and access our local database instance. While we
  # could modify our database to allow access to the docker bridge interface,
  # this seems like more work than I care to do for quick testing.
  entrypoint = writeScript "entrypoint.sh" (''
    #!${stdenv.shell}
    #!/usr/bin/env bash
    #
    # This script is used to bootstrap our environment. We expect this to be run
    # from the docker image used to boot our backend up so that we are able to
    # establish a PostgreSQL database connection.
    #
    # This script assumes the appropriate environment variables are already set.
    # Refer to https://www.postgresql.org/docs/9.5/libpq-envars.html for more
    # information.
    psql postgres -c "CREATE DATABASE portfolio"
    psql portfolio <<EOF
    CREATE TABLE IF NOT EXISTS Post
    ( title VARCHAR(255) NOT NULL
    , slug VARCHAR(255) UNIQUE NOT NULL
    , published_at TIMESTAMP NOT NULL
    , updated_at TIMESTAMP NOT NULL
    , snippet TEXT NOT NULL
    );
    EOF
    ${backend}/bin/backend
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
    contents = [ backend postgresql ];
    config = {
      Entrypoint = [ entrypoint ];
      ExposedPorts = {
        "8000/tcp" = {};
      };
    };
  }
