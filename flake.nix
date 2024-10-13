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
      fakehash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
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

        sky130a = pkgs.${system}.callPackage ./pkgs/development/pdk/open-pdks
          { inherit skywater-pdk-libs-sky130_fd_pr
            skywater-pdk-libs-sky130_fd_sc_hd
            sky130-klayout-pdk
            xschem-sky130
            sky130-pschulz-xx-hd
            skywater-pdk-libs-sky130_fd_io; };

        skywater-pdk-libs-sky130_fd_pr = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_pr";
              rev = "afc63d29f811b65b9888b2133fd3348eefc92046";
              hash = "sha256-Jr9HkSjNC07KFr8TwVeMg9MsanCBT1AJscssg5sYjVI=";
              version = "0.20.1-unstable-2024-10-12";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        skywater-pdk-libs-sky130_fd_sc_hd = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_sc_hd";
              rev = "4dbe3954e308edb6d65a15d1683ddca6eabdc369";
              hash = "sha256-if9h/nTfeODuqvZB6LCv1Tde0Q21xG9Qn2HIWnwnOBU=";
              version = "0.0.2-unstable-2024-10-11";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        skywater-pdk-libs-sky130_fd_io = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_io";
              rev = "d3b662d017ce4fb5d4e3c3922ac81f744111e010";
              hash = "sha256-Agt6l16qutGrFNx6YDh4L+9WCErTIRSjX6YtevCPKP8=";
              version = "0.2.1-unstable-2024-10-11";
              license = nixpkgs.lib.licenses.asl20;
            }) {};
        
        sky130-klayout-pdk = pkgs.${system}.callPackage ./pkgs/development/pdk/sky130-klayout-pdk { };

        sky130-pschulz-xx-hd = pkgs.${system}.callPackage ./pkgs/development/pdk/sky130-pschulz-xx-hd { };

        xschem = pkgs.${system}.callPackage ./pkgs/applications/science/electronics/xschem { };

        xschem-sky130 = pkgs.${system}.callPackage ./pkgs/development/pdk/xschem-sky130 { };
      });

      devShells = forAllSystems (system: rec {
        sky130a = pkgs.${system}.mkShell {
          packages = [
            self.packages.${system}.sky130a
            pkgs.${system}.xschem
            pkgs.${system}.ngspice
            pkgs.${system}.xyce
            pkgs.${system}.verilog
            pkgs.${system}.magic-vlsi
            pkgs.${system}.klayout
            pkgs.${system}.gaw
            pkgs.${system}.verilator
          ];
          shellHook = ''
            export PDK_ROOT="${self.packages.${system}.sky130a}/share/pdk"
            export PDK="sky130A"
          '';
        };
      });
    };
}
