let
  rev = "49550f29cd9d6ed27f4a76ba3c3fe30edf882eb7";
in
  (import (builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";
    sha256 = "003fpkrcc5mw33q670q4z865zpr430cllbxhyzj8k9p4hbc8yqda";
  }) {})
