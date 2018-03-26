let
  overlay = final : previous :
    let
      haskellOverrides = {
        overrides = self: super: {
          stm = self.callPackage (import ./stm.nix) {};

          hastache = final.haskell.lib.overrideCabal super.hastache (drv: {
            doCheck = false;
            postInstall = "rm -r $out/bin";
          });

          bench-queues = self.callPackage (import ./bench-queues.nix) {};
        };
      };
    in  {
      haskellPackages = previous.haskellPackages.override haskellOverrides;
      haskell = previous.haskell // {
        packages = previous.haskell.packages // {
          ghcjsHEAD = previous.haskell.packages.ghcjsHEAD.override haskellOverrides;
        };
      };
    };
in import <nixpkgs> {
  overlays = [ overlay ];
}
