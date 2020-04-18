{ development ? false, reflex-platform ? import ./reflex-platform }:
reflex-platform.project ({ pkgs, ... }: {
  # An attribute set of local packages being developed. Keys are the cabal
  # package name and values are the path to the source directory. Note we do not
  # use a cabal project file like the `reflex-platform` recommends since ghcide
  # does not understand that from the shell.
  packages = {
    backend = ./backend;
    frontend = ./frontend;
  };
  # A function for overriding Haskell packages. You can use `callHackage` and
  # `callCabal2nix` to bump package versions or build them from GitHub.
  overrides = self: super: {
    postlude = self.callCabal2nix "postlude" (pkgs.fetchFromGitHub {
      owner = "jrpotter";
      repo = "postlude";
      rev = "2ad6b67069dcf1d0e1624a505278eef0626e966e";
      sha256 = "1nvxkcqlwy8cqcgdlxj5gwlk0wbhnl32k690ynrzp6apnna6pw78";
    }) {};
    common = self.callCabal2nix "common" ./common {};
  };
  # A function returning a record of tools to provide in the nix-shells.
  shellToolOverrides = ghc: super: {
    inherit (ghc) hpack;
  };
  # Tells reflex to use jsaddle-warp, an alternative JSaddle backend that uses a
  # local `warp` server and WebSockets to control a browser from a native
  # Haskell project.
  useWarp = development;
  # Set to false to disable building the hoogle database when entering the
  # nix-shell.
  withHoogle = development;
  # The `shells` field defines which platforms we'd like to develop for, and
  # which packages' dependencies we want available in the development sandbox
  # for that platform. Note in the example above that specifying `common` is
  # important; otherwise it will be treated as a dependency that needs to be
  # built by Nix for the sandbox. You can use these shells with `cabal.project`
  # files to build all three packages in a shared incremental environment, for
  # both GHC and GHCJS.
  shells = {
    ghc = ["backend" "frontend"];
    ghcjs = ["frontend"];
  };
})
