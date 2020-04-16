{ mkDerivation, base, bytestring, exceptions, fetchgit, free, hpack
, stdenv, text, transformers
}:
mkDerivation {
  pname = "postlude";
  version = "0.1.2.0";
  src = fetchgit {
    url = "https://www.github.com/jrpotter/postlude.git";
    sha256 = "1nvxkcqlwy8cqcgdlxj5gwlk0wbhnl32k690ynrzp6apnna6pw78";
    rev = "2ad6b67069dcf1d0e1624a505278eef0626e966e";
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
