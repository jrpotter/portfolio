{ pkgs ? import <nixpkgs> {} }:
let
  default = import ./default.nix {};
in
  pkgs.mkShell {
    inputsFrom = [ default ];
    buildInputs = [ pkgs.sqlite ];
  }
