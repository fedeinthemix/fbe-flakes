{
  description = "Some packages not yet available in nixpkgs";

  inputs = {
    # nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    # use the same revision as the one on my NixOS system found with
    # nixos-version --hash
    # nixpkgs.url = github:NixOS/nixpkgs/15b75800dce80225b44f067c9012b09de37dfad2;
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
      wrapJulia = system: julia:
          pkgs.${system}.callPackage ./pkgs/development/compilers/julia/build-fhs-env.nix { inherit julia; };
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
        
        # Julia
        julia-lts = julia_16-bin;
        julia-stable = julia_19;
        julia = julia-stable;
        julia-lts-bin = julia_16-bin;
        julia-stable-bin = julia_19-bin;
        julia-bin = julia-stable-bin;

        julia_16-bin =  wrapJulia system pkgs.${system}.julia_16-bin;
        julia_18-bin = wrapJulia system pkgs.${system}.julia_18-bin;
        julia_19-bin = wrapJulia system pkgs.${system}.julia_19-bin;

        julia_18 = wrapJulia system pkgs.${system}.julia_18;
        julia_19 = wrapJulia system pkgs.${system}.julia_19;

      });
    };
}
