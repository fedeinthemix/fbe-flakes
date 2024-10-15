{ stdenv
, lib
, fetchFromGitHub
, fetchgit
, bash
, git
, magic-vlsi
, python3
, tcsh
, tk
# pdk selection
, pdk-code
, pdk-variant
, ef-style ? false
# libraries
, sky130-klayout-pdk
, sky130-pschulz-xx-hd
, xschem-sky130
, skywater-pdk-libs-sky130_fd_pr
, skywater-pdk-libs-sky130_fd_io
, skywater-pdk-libs-sky130_fd_sc_hd
, skywater-pdk-libs-sky130_fd_sc_hs
, skywater-pdk-libs-sky130_fd_sc_ms
, skywater-pdk-libs-sky130_fd_sc_ls
, skywater-pdk-libs-sky130_fd_sc_lp
, skywater-pdk-libs-sky130_fd_sc_hdll
, skywater-pdk-libs-sky130_fd_sc_hvl
, mpw_precheck
, sky130_sram_macros
, skywater-pdk-libs-sky130_fd_bd_sram
}:

let python = python3.withPackages (ps: [
      # scripts/create_project.py
      ps.pyaml
      # scripts/cace_design_upload.py
      ps.requests
      # scripts/cace.py 
      ps.matplotlib
    ]);

    sc-map = {
      "sky130_sram_macros" = "sram-sky130";
      "skywater-pdk-libs-sky130_fd_bd_sram" = "sram-space-sky130";
      "skywater-pdk-libs-sky130_fd_io" = "io-sky130";
      "skywater-pdk-libs-sky130_fd_sc_hs" = "sc-hs-sky130";
      "skywater-pdk-libs-sky130_fd_sc_ms" = "sc-ms-sky130";
      "skywater-pdk-libs-sky130_fd_sc_ls" = "sc-ls-sky130";
      "skywater-pdk-libs-sky130_fd_sc_lp" = "sc-lp-sky130";
      "skywater-pdk-libs-sky130_fd_sc_hd" = "sc-hd-sky130";
      "skywater-pdk-libs-sky130_fd_sc_hdll" = "sc-hdll-sky130";
      "skywater-pdk-libs-sky130_fd_sc_hvl" = "sc-hvl-sky130";
      "sky130-pschulz-xx-hd" = "alpha-sky130";
      "xschem-sky130" = "xschem-sky130";
      "sky130-klayout-pdk" = "klayout-sky130";
      "mpw_precheck" = "precheck-sky130";
    };

    enableLibrary = (drv:
      "--enable-${sc-map.${drv.pname}}=${drv}/share/pdk/${drv.pname}/source");

    disableLibrary = (drv:
      "--disable-${sc-map.${drv.pname}}");

    selectPDK = (pdk:
      if pdk == "gf180mcu"
      then [ "--enable-gf180mcu-pdk" ]
      else builtins.filter (s: s != "") [
        "--enable-sky130-pdk"
        "--with-sky130-variants=${pdk-variant}"
        "--enable-primitive-sky130=${skywater-pdk-libs-sky130_fd_pr}/share/pdk/skywater-pdk-libs-sky130_fd_pr/source"
        (lib.strings.optionalString ef-style "--with-ef-style")
      ]);

    allLibraries = [
      sky130-pschulz-xx-hd
      sky130-klayout-pdk
      xschem-sky130
      skywater-pdk-libs-sky130_fd_sc_hd
      skywater-pdk-libs-sky130_fd_io
      skywater-pdk-libs-sky130_fd_sc_hs
      skywater-pdk-libs-sky130_fd_sc_ms
      skywater-pdk-libs-sky130_fd_sc_ls
      skywater-pdk-libs-sky130_fd_sc_lp
      skywater-pdk-libs-sky130_fd_sc_hd
      skywater-pdk-libs-sky130_fd_sc_hdll
      skywater-pdk-libs-sky130_fd_sc_hvl
      sky130_sram_macros
      skywater-pdk-libs-sky130_fd_bd_sram
      mpw_precheck
    ];

    selectLibraries = libs:
      map (l: if lib.lists.elem l libs
              then enableLibrary l
              else disableLibrary l)
        allLibraries;

in stdenv.mkDerivation (finalAttrs: {
  pname = "open-pdks";
  version = "1.0.495";

  src = fetchFromGitHub {
    owner = "RTimothyEdwards";
    repo = "open_pdks";
    rev = "a918dc7c8e474a99b68c85eb3546b4ed91fe9e7b";
    hash = "sha256-LdwlebVdhJ50HhnMXX7/sNy2gwscY3qYXkWojVwfjwk=";
    leaveDotGit = true; # needed at installation
  };

  inherit pdk-code pdk-variant;

  buildInputs = [ git magic-vlsi python tcsh tk ];

  configureFlags =
    lib.concat (selectPDK pdk-code) [
      (enableLibrary sky130-pschulz-xx-hd)
      (enableLibrary xschem-sky130)
      (enableLibrary sky130-klayout-pdk)
      (enableLibrary skywater-pdk-libs-sky130_fd_io)
      (disableLibrary skywater-pdk-libs-sky130_fd_sc_hs)
      (disableLibrary skywater-pdk-libs-sky130_fd_sc_ms)
      (disableLibrary skywater-pdk-libs-sky130_fd_sc_ls)
      (disableLibrary skywater-pdk-libs-sky130_fd_sc_lp)
      (enableLibrary skywater-pdk-libs-sky130_fd_sc_hd)
      (disableLibrary skywater-pdk-libs-sky130_fd_sc_hdll)
      (disableLibrary skywater-pdk-libs-sky130_fd_sc_hvl)
      (disableLibrary mpw_precheck)
    ];

  patches = [
    ./sky130-rename_models-makeusereditable.patch
    ./sky130-rename_cells-makeuserwritable.patch
    ./sky130-inc_verilog-makeuserwritable.patch
    ./sky130-Makefile-in-xschem-staging-write.patch
    ./sky130-fix_io_lef-makeuserwritable.patch
    ./gf180mcu-inc_verilog-makeuserwritable.patch
    ./foundry_install-makeuserwritable.patch
  ];

  postPatch = ''
    substituteInPlace "scripts/configure" \
      --replace-quiet "python3" "${python}/bin/python"
    # don't use 'patchShebangs' as some are in code generating strings
    for fn in "common/*.py" \
              "sky130/irsim/*.py" \
              "sky130/custom/scripts/*.py" \
              "sky130/custom/scripts/seal_ring_generator/*.py" \
              "gf180mcu/custom/scripts/*.py" \
              "runtime/*.py"; do
      substituteInPlace $fn \
        --replace-quiet "#!/usr/bin/env python3" "#!${python}/bin/python" \
        --replace-quiet "#!/usr/bin/env wish" "#!${tk}/bin/wish" \
        --replace-quiet "#!/bin/tcsh" "#!${tcsh}/bin/tcsh"
    done
    for fn in "sky130/custom/sky130_fd_io/mag/*.sh" \
              "sky130/qflow/*.sh" \
              "gf180mcu/qflow/*.sh" \
              "scripts/*.sh" \
              "scripts/configure"; do
      substituteInPlace $fn \
        --replace-quiet "#!/bin/sh" "#!${bash}/bin/sh" \
        --replace-quiet "#! /bin/sh" "#!${bash}/bin/sh" \
        --replace-quiet "#!/bin/bash" "#!${bash}/bin/bash" \
        --replace-quiet "#!/bin/tcsh" "#!${tcsh}/bin/tcsh"
    done
    for fn in "common/*.py" \
              "sky130/irsim/*.py" \
              "sky130/custom/scripts/*.py" \
              "sky130/custom/scripts/seal_ring_generator/*.py" \
              "gf180mcu/custom/scripts/*.py" \
              "runtime/project_manager.py" \
              "runtime/netlist_to_layout.py" \
              "runtime/cace_launch.py" \
              "runtime/cace_gensim.py"; do
      substituteInPlace $fn \
        --replace-quiet "['magic'" "['${magic-vlsi}/bin/magic'"
    done
    '';

  preConfigure = ''
    export PYTHON=${python}/bin/python3
    export MAGIC=${magic-vlsi}/bin/magic
  '';

  preBuild = ''
    substituteInPlace "sky130/Makefile" \
      --replace-quiet "shell git" "shell ${git}/bin/git" \
      --replace-quiet "; git" "; ${git}/bin/git" \
      --replace-quiet "shell magic" "shell ${magic-vlsi}/bin/magic"
  '';

  passthru = {
    inherit allLibraries;
    passthru.finalAttrs = finalAttrs;
    withLibraries = libs:
      finalAttrs.finalPackage.overrideAttrs (self: super: {
        configureFlags =
          lib.concat (selectPDK pdk-code) (selectLibraries libs);
      }); 
  };

  meta = with lib; {
    description = "PDKs for open-source tools from foundry sources";
    homepage = "https://github.com/RTimothyEdwards/open_pdks";
    maintainers = [ maintainers.fbeffa ];
    license = licenses.asl20;
  };
})
