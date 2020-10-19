{ pkgs ? import ./nixpkgs {} }:
let
  default = import ./default.nix { inherit pkgs; };
  # We pull in IHaskell manually since the version of nixpkgs we use has a
  # broken package.
  ihaskell = import ./ihaskell {
    compiler = "ghc884";
    nixpkgs = pkgs;
    packages = self: with self; [
      ihaskell-aeson
      ihaskell-blaze
      ihaskell-charts
      ihaskell-diagrams
      ihaskell-graphviz
    ];
    systemPackages = self: with self; [
      graphviz
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
