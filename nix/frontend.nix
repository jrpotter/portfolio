{ mkDerivation, base, common, hpack, postlude, stdenv, text }:
mkDerivation {
  pname = "frontend";
  version = "0.1.0.0";
  src = ../frontend;
  isLibrary = false;
  isExecutable = true;
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [ base common postlude text ];
  prePatch = "hpack";
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
