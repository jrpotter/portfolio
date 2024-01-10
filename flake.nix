{
  description = ''
    An opinionated jekyll flake.

    To generate a copy of this template elsewhere, install
    [bootstrap](https://github.com/jrpotter/bootstrap) and run:
    ```bash
    $ bootstrap jekyll
    ```
  '';

  inputs = {
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gems = pkgs.bundlerEnv {
          name = "portfolio-gems";
          gemdir = ./.;
          ruby = pkgs.ruby_3_2;
        };
      in
      {
        packages = {
          app = pkgs.stdenv.mkDerivation {
            name = "portfolio";
            buildInputs = [ gems gems.wrappedRuby ];
            src = ./.;
            version = "0.1.0";
            installPhase = "JEKYLL_ENV=production jekyll b -d $out";
          };

          default = self.packages.${system}.app;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bundix
            gems
            gems.wrappedRuby
          ];
        };
      }
    );
}
