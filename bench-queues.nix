{ mkDerivation, lib, base, containers, stdenv, stm, criterion, time }:
mkDerivation rec {
  pname = "bench-queues";
  version = "0.0.0.0";
  src = lib.sourceByRegex ./. [
    "^${pname}.cabal$"
    ".*\.hs"
    "LICENSE"
    "^src$" "^src/.*"
  ];
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base containers stm criterion time ];
  license = stdenv.lib.licenses.bsd3;
}
