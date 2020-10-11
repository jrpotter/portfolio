{ pkgs ? import ./nixpkgs {} }:
let
  default = import ./default.nix { inherit pkgs; };
 in
  pkgs.mkShell {
    inputsFrom = [ default ];
    buildInputs = [ pkgs.sqlite ];
  }
