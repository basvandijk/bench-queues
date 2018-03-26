{ fetchFromGitHub, mkDerivation, array, base, stdenv }:
mkDerivation {
  pname = "stm";
  version = "2.4.5.0";
  src = fetchFromGitHub {
    owner  = "haskell";
    repo   = "stm";
    rev    = "622f386c79f2d09580a08ce145536b338dadac9b";
    sha256 = "0x18xskmr370b2acks6qhpma7ks8ck4g52k1y08x0d2xb3k385nk";
  };
  libraryHaskellDepends = [ array base ];
  homepage = "https://wiki.haskell.org/Software_transactional_memory";
  description = "Software Transactional Memory";
  license = stdenv.lib.licenses.bsd3;
}
