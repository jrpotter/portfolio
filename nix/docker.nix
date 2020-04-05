{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  # Note this matches how we would run `nix-build` manually. Refer to the
  # README.md for more details.
  backend = (import ./default.nix {}).ghc.backend;
  # Invoke the runtime built by the `backend`.
  entrypoint = writeScript "entrypoint.sh" ''
    #!${stdenv.shell}
    ${backend}/bin/backend
  '';
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
    contents = backend;
    config = {
      Entrypoint = [ entrypoint ];
      ExposedPorts = {
        "6379/tcp" = {};
      };
      WorkingDir = "/data";
      Volumes = {
        "/data" = {};
      };
    };
  }
