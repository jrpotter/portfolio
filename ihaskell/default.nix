import ((builtins.fetchGit {
  url = "https://github.com/gibiansky/ihaskell.git";
  rev = "ef698157f44960566687a308e3455b5ba031eb43";
  ref = "master";
}) + "/release.nix")
