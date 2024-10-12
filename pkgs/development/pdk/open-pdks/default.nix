{ stdenv
, lib
, fetchFromGitHub
, fetchgit
, bash
, git
, magic-vlsi
, mpw_precheck ? { pname = "mpw_precheck";}
, pdk ? "sky130"
, python3
, sky130-variants ? "A"
, sky130_sram_macros ? { pname = "sky130_sram_macros";}
, sky130_fd_bd_sram ? { pname = "sky130_fd_bd_sram";}
, sky130-pschulz-xx-hd ? { pname = "sky130-pschulz-xx-hd";}
, sky130-klayout-pdk ? { pname = "sky130-klayout-pdk";}
, skywater-pdk-libs-sky130_fd_pr
, skywater-pdk-libs-sky130_fd_io ? { pname = "skywater-pdk-libs-sky130_fd_io";}
, skywater-pdk-libs-sky130_fd_sc_hs ? { pname = "skywater-pdk-libs-sky130_fd_sc_hs";}
, skywater-pdk-libs-sky130_fd_sc_ms ? { pname = "skywater-pdk-libs-sky130_fd_sc_ms";}
, skywater-pdk-libs-sky130_fd_sc_ls ? { pname = "skywater-pdk-libs-sky130_fd_sc_ls";}
, skywater-pdk-libs-sky130_fd_sc_lp ? { pname = "skywater-pdk-libs-sky130_fd_sc_lp";}
, skywater-pdk-libs-sky130_fd_sc_hd ? { pname = "skywater-pdk-libs-sky130_fd_sc_hd";}
, skywater-pdk-libs-sky130_fd_sc_hdll ? { pname = "skywater-pdk-libs-sky130_fd_sc_hdll";}
, skywater-pdk-libs-sky130_fd_sc_hvl ? { pname = "skywater-pdk-libs-sky130_fd_sc_hvl";}
, tcsh
, tk
, xschem-sky130 ? { pname = "xschem-sky130";}
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
      "sky130_fd_bd_sram" = "sram-space-sky130";
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
    maybeEnable = (drv:
      if (lib.isDerivation drv)
      then "--enable-${sc-map.${drv.pname}}=${drv}/share/pdk/${drv.pname}/source"
      else "--disable-${sc-map.${drv.pname}}");
    selectPDK = (pdk:
      if pdk == "gf180mcu"
      then [ "--enable-gf180mcu-pdk" ]
      else [
        "--enable-sky130-pdk"
        "--with-sky130-variants=${sky130-variants}"
        "--enable-primitive-sky130=${skywater-pdk-libs-sky130_fd_pr}/share/pdk/skywater-pdk-libs-sky130_fd_pr/source"
      ]);
in
stdenv.mkDerivation rec {
  pname = "open-pdks";
  version = "1.0.495";

  src = fetchgit {
    url = "https://github.com/RTimothyEdwards/open_pdks.git";
    rev = "a918dc7c8e474a99b68c85eb3546b4ed91fe9e7b";
    sha256 = "sha256-LdwlebVdhJ50HhnMXX7/sNy2gwscY3qYXkWojVwfjwk=";
    leaveDotGit = true; # needed at installation
  };
  
  configureFlags =
    lib.concat (selectPDK pdk) [
    (maybeEnable skywater-pdk-libs-sky130_fd_io)
    (maybeEnable skywater-pdk-libs-sky130_fd_sc_hs)
    (maybeEnable skywater-pdk-libs-sky130_fd_sc_ms)
    (maybeEnable skywater-pdk-libs-sky130_fd_sc_ls)
    (maybeEnable skywater-pdk-libs-sky130_fd_sc_lp)
    (maybeEnable skywater-pdk-libs-sky130_fd_sc_hd)
    (maybeEnable skywater-pdk-libs-sky130_fd_sc_hdll)
    (maybeEnable skywater-pdk-libs-sky130_fd_sc_hvl)
    (maybeEnable sky130-pschulz-xx-hd)
    (maybeEnable xschem-sky130)
    (maybeEnable sky130-klayout-pdk)
    (maybeEnable mpw_precheck)
  ];

  # patches = [
  #   ./rename_models-makeusereditable.patch
  # ];

  postPatch = ''
    patch -p0 < ${./sky130-rename_models-makeusereditable.patch}
    patch -p0 < ${./sky130-rename_cells-makeuserwritable.patch}
    patch -p0 < ${./sky130-inc_verilog-makeuserwritable.patch}
    patch -p0 < ${./sky130-Makefile-in-xschem-staging-write.patch}
    patch -p0 < ${./gf180mcu-inc_verilog-makeuserwritable.patch}
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
  
  meta = with lib; {
    description = "PDKs for open-source tools from foundry sources";
    homepage = "https://github.com/RTimothyEdwards/open_pdks";
    maintainers = [ maintainers.fbeffa ];
    license = licenses.asl20;
  };

}
