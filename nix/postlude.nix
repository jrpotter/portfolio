{ mkDerivation, base, bytestring, exceptions, fetchgit, free, hpack
, stdenv, text, transformers
}:
mkDerivation {
  pname = "postlude";
  version = "0.1.2.0";
  src = fetchgit {
    url = "https://github.com/jrpotter/postlude.git";
    sha256 = "1xw3jwlc0alby3cvldmhz04irjdb0s04c93nndsfcrx1vcppl0i2";
    rev = "55221d4ebee4692a0e283c10bbd6560b84eee8ad";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    base bytestring exceptions free text transformers
  ];
  libraryToolDepends = [ hpack ];
  prePatch = "hpack";
  homepage = "https://github.com/jrpotter/postlude#readme";
  license = stdenv.lib.licenses.bsd3;
}