{
  description = "Some packages not yet available in nixpkgs";

  inputs = {
    # nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;
    # nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    # use the same revision as the one on my NixOS system found with
    # nixos-version --hash
    nixpkgs.url = github:NixOS/nixpkgs/944b2aea7f0a2d7c79f72468106bc5510cbf5101;
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (system: rec {

        fasthenry-mit = pkgs.${system}.callPackage ./pkgs/applications/science/physics/fasthenry-mit { };

        fasthenry = pkgs.${system}.callPackage ./pkgs/applications/science/physics/fasthenry { };

        fastcap = pkgs.${system}.callPackage ./pkgs/applications/science/physics/fastcap {
            texlive = pkgs.${system}.texlive.combine { inherit (pkgs.${system}.texlive) scheme-medium; };
          };

        scmutils = pkgs.${system}.callPackage ./pkgs/development/modules/mit-scheme-modules/scmutils { };

        xschem = pkgs.${system}.callPackage ./pkgs/applications/science/electronics/xschem { };
        
      });
    };
}
