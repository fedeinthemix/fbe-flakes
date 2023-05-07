{
  description = "Some packages not yet available in nixpkgs";

  inputs = {
    # nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    # use the same revision as the one on my NixOS system found with
    # nixos-version --hash
    nixpkgs.url = github:NixOS/nixpkgs/f6ddd55d5f9d5eca08df138c248008c1ba73ecec;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:

    nixpkgs.lib.recursiveUpdate

      (let
        callPackageUnfree = pkg:
          with import "${nixpkgs}" {
            system = "x86_64-linux";
            config.allowUnfree = true;
          }; callPackage pkg;
      in rec {

        packages.x86_64-linux.wolfram-engine =
          callPackageUnfree ./pkgs/applications/science/math/wolfram-engine { };

        wolfram-for-jupyter-kernel =
          callPackageUnfree ./pkgs/applications/editors/jupyter-kernels/wolfram/default.nix { wolfram-engine = packages.x86_64-linux.wolfram-engine; };

        packages.x86_64-linux.wolfram-notebook =
          callPackageUnfree ./pkgs/applications/science/math/wolfram-engine/notebook.nix { inherit wolfram-for-jupyter-kernel; };

      })

      (flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in rec {

          packages.trilinos =
            pkgs.callPackage ./pkgs/development/libraries/science/math/trilinos { };

          packages.trilinos-mpi =
            pkgs.callPackage ./pkgs/development/libraries/science/math/trilinos { withMPI = true; };

          packages.xschem =
            pkgs.callPackage ./pkgs/applications/science/electronics/xschem { };

          packages.xyce =
            pkgs.callPackage ./pkgs/applications/science/electronics/xyce { trilinos = packages.trilinos; };

          packages.xyce-parallel =
            pkgs.callPackage ./pkgs/applications/science/electronics/xyce { withMPI = true; trilinos = packages.trilinos-mpi; };

        }));

}
