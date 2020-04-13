{ reflex-platform ? import ./reflex-platform.nix {} , withHoogle ? false }:
# Additional documentation exists at:
# https://github.com/reflex-frp/reflex-platform/blob/5c8c380cd8978f21b6e199d6ee2f79fc4191346c/project/default.nix
reflex-platform.project ({ pkgs, ... }: {

  # :: { <package name> :: Path }
  #
  # An attribute set of local packages being developed. Keys are the
  # cabal package name and values are the path to the source
  # directory.
  packages = {
    common = ../common;
    backend = ../backend;
    frontend = ../frontend;
  };

  # :: PackageSet -> PackageSet -> { <package name> :: Derivation }
  # 
  # A function for overriding Haskell packages. You can use `callHackage` and
  # `callCabal2nix` to bump package versions or # build them from GitHub.
  overrides = self: super: {
    postlude = self.callPackage ./postlude.nix {};
  };

  # A function returning a record of tools to provide in the nix-shells.
  shellToolOverrides = ghc: super: {
    inherit (ghc) hpack;
  };

  # Tells reflex to use jsaddle-warp, an alternative JSaddle backend that uses a
  # local `warp` server and WebSockets to control a browser from a native
  # Haskell project. Note, JSaddle is a set of libraries that allow reflex to
  # swap out its JavaScript backend easily.
  useWarp = true;

  # Set to false to disable building the hoogle database when entering the
  # nix-shell.
  withHoogle = withHoogle;

  # :: { <platform name> :: [PackageName] }
  #
  # The `shells` field defines which platforms we'd like to develop for, and
  # which packages' dependencies we want available in the development sandbox
  # for that platform. Note in the example above that specifying `common` is
  # important; otherwise it will be treated as a dependency that needs to be
  # built by Nix for the sandbox. You can use these shells with `cabal.project`
  # files to build all three packages in a shared incremental environment, for
  # both GHC and GHCJS.
  shells = {
    ghc = ["common" "backend" "frontend"];
    ghcjs = ["common" "frontend"];
  };

})
