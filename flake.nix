{
  description = "Text replacement utility";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";

    rpl-src.url = "github:rrthomas/rpl";
    rpl-src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, rpl-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonPackages = pkgs.python311Packages;
      in {
        packages = rec {
          default = rpl;

          chainstream = pythonPackages.buildPythonPackage rec {
            pname = "chainstream";
            version = "1.0.1";

            src = pythonPackages.fetchPypi {
              inherit pname version;
              sha256 = "sha256-302P1BixEmkODm+qTLZwaWLktrlf9cEziQ/TIVfI07c=";
            };

            patchPhase = ''
              echo -e "#!/usr/bin/env python\nimport setuptools\nsetuptools.setup()\n" > setup.py
            '';
          };

          argparse-manpage = pythonPackages.buildPythonPackage rec {
            pname = "argparse-manpage";
            version = "4.3";

            src = pythonPackages.fetchPypi {
              inherit pname version;
              sha256 = "sha256-lNJRkxohJbQzWGuqbqrMBrwaKB6mFuZB2DCyBAB+ODk=";
            };

            doCheck = false;

            propagatedBuildInputs = with pythonPackages; [
              tomli
            ];
          };

          rpl = pythonPackages.buildPythonPackage rec {
            pname = "rpl";
            version = "1.15.5";

            src = rpl-src;

            doCheck = false;

            # FIXME: overriding setup.py as argparse-manpage doesn't function properly
            patchPhase = ''
              echo -e "#!/usr/bin/env python\nimport setuptools\nsetuptools.setup()\n" > setup.py
            '';

            nativeBuildInputs = [
              argparse-manpage
            ];

            propagatedBuildInputs = with pythonPackages; [
              regex
              chardet
            ] ++ [
              chainstream
            ];
          };
        };
      }
    );
}
