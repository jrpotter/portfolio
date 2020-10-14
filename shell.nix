{ pkgs ? import ./nixpkgs {} }:
let
  default = import ./default.nix { inherit pkgs; };
  # We pull in IHaskell manually to ensure compiler matching. We don't bother
  # including in our portfolio package - we'll be using an iframe with the
  # nbviewer utility provided by Jupyter to load in any notebooks on a post.
  ihaskell = import ./ihaskell {
    compiler = "ghc884";
    nixpkgs = pkgs;
    packages = self: with self; [
      ihaskell-aeson
      ihaskell-blaze
      ihaskell-charts
      ihaskell-diagrams
    ];
  };
 in
  pkgs.mkShell {
    inputsFrom = [ default ];
    buildInputs = [ pkgs.sqlite ];
    shellHook = ''
    mkdir -p $out/bin
    ln -sf "${ihaskell.out}/bin/ihaskell-lab" $out/bin
    ln -sf "${ihaskell.out}/bin/ihaskell-nbconvert" $out/bin
    PATH=$PATH:$out/bin
    '';
  }
