{ mkDerivation, aeson, base, hpack, postlude, stdenv, text, time }:
mkDerivation {
  pname = "common";
  version = "0.1.0.0";
  src = ../common;
  libraryHaskellDepends = [ aeson base postlude text time ];
  libraryToolDepends = [ hpack ];
  prePatch = "hpack";
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
