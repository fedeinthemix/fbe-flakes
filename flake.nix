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
    in
    {
      packages = forAllSystems (system: rec {

        scmutils =
          pkgs.${system}.callPackage ./pkgs/development/modules/mit-scheme-modules/scmutils { };

        # Julia
        wrapJulia = julia:
          pkgs.${system}.callPackage ./pkgs/development/compilers/julia/build-fhs-env.nix { inherit julia; };

        julia-lts = julia_16-bin;
        julia-stable = julia_19;
        julia = julia-stable;
        julia-lts-bin = julia_16-bin;
        julia-stable-bin = julia_19-bin;
        julia-bin = julia-stable-bin;

        julia_16-bin =  wrapJulia pkgs.${system}.julia_16-bin;
        julia_18-bin = wrapJulia pkgs.${system}.julia_18-bin;
        julia_19-bin = wrapJulia pkgs.${system}.julia_19-bin;

        julia_18 = wrapJulia pkgs.${system}.julia_18;
        julia_19 = wrapJulia pkgs.${system}.julia_19;
        
      });
    };

}
