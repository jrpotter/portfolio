{ compiler ? "ghc865" }:
with (import ./nixpkgs);
let
  default = (import ./default.nix { development = true; });
  # Reference to a version of ghcide that matches our compiler. Note the
  # latest version will have issues with mismatched GLIBC versions.
  rev = "0ae8d9869ace81c4efaa279379c5a716280cb2b7";
  link = "https://github.com/cachix/ghcide-nix/tarball/${rev}";
  ghcide = (import (builtins.fetchTarball link) {})."ghcide-${compiler}";
  # Include `ghcid` so we can hot reload when our code changes. Makes iterating
  # on frontend changes in particular much faster.
  reload = writeScriptBin "reload" ''
    ${ghcid}/bin/ghcid \
      -c '${cabal-install}/bin/cabal new-repl' \
      -T "Main.main"
  '';
  reload-page = writeScriptBin "reload-page" ''
    ${ghcid}/bin/ghcid \
      -c "${cabal-install}/bin/cabal new-repl $1" \
      -T "Pages.$1.main"
  '';
in
  default.shells.ghc.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ ghcide reload reload-page ];
  })