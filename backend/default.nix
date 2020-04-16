{ mkDerivation, base, common, hpack, lucid, opaleye
, postgresql-simple, postlude, product-profunctors, servant-lucid
, servant-server, stdenv, text, wai-cors, warp
}:
mkDerivation {
  pname = "backend";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base common lucid opaleye postgresql-simple postlude
    product-profunctors servant-lucid servant-server text wai-cors warp
  ];
  prePatch = "hpack";
  license = "unknown";
  hydraPlatforms = stdenv.lib.platforms.none;
}
