{
  description = "Some packages not yet available in nixpkgs";

  inputs = {
    # nixpkgs.url = github:NixOS/nixpkgs/nixos-21.11;
    # use the same revision as the one on my NixOS system found with
    # nixos-version --hash
    nixpkgs.url = github:NixOS/nixpkgs/15b75800dce80225b44f067c9012b09de37dfad2;
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (system: {

        scmutils =
          pkgs.${system}.callPackage ./pkgs/development/modules/mit-scheme-modules/scmutils { };

      });
    };

}
