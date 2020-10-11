{ pkgs ? import ./nixpkgs {} }:
let
  default = import ./default.nix { inherit pkgs; };
 in
  pkgs.mkShell {
    inputsFrom = [ default ];
    buildInputs = [ pkgs.sqlite ];
    shellHook = ''
    mkdir -p $out/bin
    ln -s "${default.ihaskell.out}/bin/ihaskell-lab" $out/bin
    PATH=$PATH:$out/bin
    '';
  }
