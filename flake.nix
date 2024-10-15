{
  description = "FBE packages";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
    # use the same revision as the one on my NixOS system found with
    # nixos-version --hash
    # nixpkgs.url = github:NixOS/nixpkgs/944b2aea7f0a2d7c79f72468106bc5510cbf5101;
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

        netgen = pkgs.${system}.callPackage ./pkgs/applications/science/electronics/netgen { };

        scmutils = pkgs.${system}.callPackage ./pkgs/development/modules/mit-scheme-modules/scmutils { };

        ############################################################
        # Google/SkyWater FOSS 130nm Production PDK -- Packages

        sky130a = pkgs.${system}.callPackage ./pkgs/development/pdk/open-pdks
          { pdk-code = "sky130";
            pdk-variant = "A";
            inherit skywater-pdk-libs-sky130_fd_pr
              sky130-klayout-pdk
              sky130-pschulz-xx-hd
              xschem-sky130
              skywater-pdk-libs-sky130_fd_sc_hd
              skywater-pdk-libs-sky130_fd_io
              skywater-pdk-libs-sky130_fd_sc_hs
              skywater-pdk-libs-sky130_fd_sc_ms
              skywater-pdk-libs-sky130_fd_sc_ls
              skywater-pdk-libs-sky130_fd_sc_lp
              skywater-pdk-libs-sky130_fd_sc_hdll
              skywater-pdk-libs-sky130_fd_sc_hvl
              mpw_precheck
              sky130_sram_macros
              skywater-pdk-libs-sky130_fd_bd_sram;
          };

        sky130a-ef = pkgs.${system}.callPackage ./pkgs/development/pdk/open-pdks
          { pdk-code = "sky130";
            pdk-variant = "A";
            ef-style = true;
            inherit skywater-pdk-libs-sky130_fd_pr
              sky130-klayout-pdk
              sky130-pschulz-xx-hd
              xschem-sky130
              skywater-pdk-libs-sky130_fd_sc_hd
              skywater-pdk-libs-sky130_fd_io
              skywater-pdk-libs-sky130_fd_sc_hs
              skywater-pdk-libs-sky130_fd_sc_ms
              skywater-pdk-libs-sky130_fd_sc_ls
              skywater-pdk-libs-sky130_fd_sc_lp
              skywater-pdk-libs-sky130_fd_sc_hdll
              skywater-pdk-libs-sky130_fd_sc_hvl
              mpw_precheck
              sky130_sram_macros
              skywater-pdk-libs-sky130_fd_bd_sram;
          };

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

        skywater-pdk-libs-sky130_fd_sc_hs = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_sc_hs";
              rev = "9a855e97aa75f8a14be7eadc365c28d50045d5fc";
              hash = "sha256-EGi3NSHgha00SKbDZyT+yvTrpK1isXooAkTopKwFoxE=";
              version = "0.0.2-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        skywater-pdk-libs-sky130_fd_sc_ms = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_sc_ms";
              rev = "26d0047c0e2dbe28fe4950f171411f6e8b3d0564";
              hash = "sha256-uVdg0ko2UoqG54ZSlbmj3/ByPwJ5+DRoO9hxcOhtQ9w=";
              version = "0.0.2-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        skywater-pdk-libs-sky130_fd_sc_ls = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_sc_ls";
              rev = "8e7040bfc58a17386e3d900c0e3b9c9163545c4a";
              hash = "sha256-eI7f6CZQMzoS0gMfHxrJ+p6hMsGvmj8qwTwWb7G+yQM=";
              version = "0.1.1-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        skywater-pdk-libs-sky130_fd_sc_lp = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_sc_lp";
              rev = "b93a1a75fa1b864872ebb0b078f6a2dd6e318d7c";
              hash = "sha256-86J4nospyRcg4iL1NHuijXg6za6BlvrzbGwn47A07gQ=";
              version = "0.0.2-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        skywater-pdk-libs-sky130_fd_sc_hdll = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_sc_hdll";
              rev = "d48faa83ef2d8573d85384c4eb019ab78295db0b";
              hash = "sha256-lpChgbgNpwMkmnA2e+dyvotVcoFWiy5QdXqeuvyiBqQ=";
              version = "0.1.1-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        skywater-pdk-libs-sky130_fd_sc_hvl = pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "skywater-pdk-libs-sky130_fd_sc_hvl";
              rev = "5f544a6d5b9385ac563811e7a455b050eea5fb70";
              hash = "sha256-tmn6Z4FaSNeip9mitJ5bQn3LBx3QDIAzbIK9CLY99FY=";
              version = "0.0.3-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        mpw_precheck =  pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "mpw_precheck";
              rev = "0941bdc1b62b5c3f99c8683bd11199d330af2ef3";
              hash = "sha256-IhXUO9rcxyvOBwktpfkMVn5SmX2mCz5yOdjGmQrAqRE=";
              version = "0-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        sky130_sram_macros =  pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { repo = "sky130_sram_macros";
              rev = "7b40220ebd47b8c17d58a94abaa57f111a08987a";
              hash = "sha256-lg9Jmfepe41zCS8M7vUo2dJmJe7vja34ZprPnXRErA8=";
              version = "0-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        skywater-pdk-libs-sky130_fd_bd_sram =  pkgs.${system}.callPackage
          (import ./pkgs/development/pdk/sky130/sky130-lib-gen.nix
            { owner = "google";
              repo = "skywater-pdk-libs-sky130_fd_bd_sram";
              rev = "be33adbcf188fdeab5c061699847d9d440f7a084";
              hash = "sha256-dxKsYU7gW6snH3Yu74Ud/+yuVguRIxLNkinqfso78D0=";
              version = "0.0.0-unstable-2024-10-15";
              license = nixpkgs.lib.licenses.asl20;
            }) {};

        sky130-klayout-pdk = pkgs.${system}.callPackage ./pkgs/development/pdk/sky130-klayout-pdk { };

        sky130-pschulz-xx-hd = pkgs.${system}.callPackage ./pkgs/development/pdk/sky130-pschulz-xx-hd { };

        xschem = pkgs.${system}.callPackage ./pkgs/applications/science/electronics/xschem { };

        xschem-sky130 = pkgs.${system}.callPackage ./pkgs/development/pdk/xschem-sky130 { };
      });

      devShells = forAllSystems (system:

        ############################################################
        # Google/SkyWater FOSS 130nm Production PDK -- devShells

        let makeShell = (pdk: pkgs.${system}.mkShell {
              packages = [
                pdk
                self.packages.${system}.netgen
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
            export PDK_ROOT="${pdk}/share/pdk"
            export PDK=${nixpkgs.lib.strings.concatStrings [ pdk.pdk-code pdk.pdk-variant ]}
          '';
            });
        in rec {
          
          inherit makeShell;

          sky130a = makeShell self.packages.${system}.sky130a;

          sky130a-ef = makeShell self.packages.${system}.sky130a-ef;
        });
    };
}
