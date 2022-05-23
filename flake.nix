{
  description = "Text replacement utility";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    flake-utils.url = "github:numtide/flake-utils";

    rpl-src.url = "https://downloads.sourceforge.net/project/rpl/rpl/rpl-1.5.5/rpl-1.5.5.tar.gz";
    rpl-src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, rpl-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {
          rpl = pkgs.python2Packages.buildPythonPackage rec {
            pname = "rpl";
            version = "1.5.5";
            src = rpl-src;
            postInstall = ''
              install -D rpl.1 $out/share/man/man1/rpl.1
            '';
          };
        };
        defaultPackage = packages.rpl;
      }
    );
}
