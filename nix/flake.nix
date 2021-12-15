{
  description = "A flake for SolTracker.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs?ref=master;
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: 
    let
    pkgsForSystem = system: import nixpkgs {
        overlays = [ overlay ];
        inherit system;
      };

    overlay = final: prev: rec {

      soltracker = with final;
        let
          beamPackages = beam.packagesWith beam.interpreters.erlangR24; 
          mixNixDeps = import ./deps.nix { inherit lib beamPackages; }; 
        in beamPackages.mixRelease {
          inherit mixNixDeps;
          pname = "soltracker";
          src = ../.;
          version = "0.0.0";
          RELEASE_DISTRIBUTION = "none";
          nativeBuildInputs = [ rustc cargo ];
         };
    };
    in utils.lib.eachDefaultSystem (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) soltracker;
      };
      defaultPackage = packages.soltracker;
      devShell = self.devShells.${system}.dev;
      devShells = {
        dev = import ./shell.nix {
          pkgs = legacyPackages;
          db_name = "db_dev";
          MIX_ENV = "dev";
        };
        test = import ./shell.nix {
          pkgs = legacyPackages;
          db_name = "db_test";
          MIX_ENV = "test";
        };
          prod = import ./shell.nix {
          pkgs = legacyPackages;
          db_name = "db_prod";
          MIX_ENV = "prod";
        };
      };
      apps.soltracker = utils.lib.mkApp { drv = packages.soltracker; };
      hydraJobs = { inherit (legacyPackages) soltracker; };
      checks = { inherit (legacyPackages) soltracker; };
    }) // { overlay = overlay ;};
}
