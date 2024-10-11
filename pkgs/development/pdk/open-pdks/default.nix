{ stdenv
, lib
, fetchFromGitHub
, fetchgit
, bash
, git
, magic-vlsi
, python3
#, sky130a
, skywater-pdk-libs-sky130_fd_pr
, skywater-pdk-libs-sky130_fd_sc_hd
, sky130-variants ? "A"
, sky130-klayout-pdk
, sky130-pschulz-xx-hd
, tcsh
, tk
, xschem-sky130
}:

let python = python3.withPackages (ps: [
      # scripts/create_project.py
      ps.pyaml
      # scripts/cace_design_upload.py
      ps.requests
      # scripts/cace.py 
      ps.matplotlib
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
  
  configureFlags = [
    "--enable-sky130-pdk"
    "--with-sky130-variants=${sky130-variants}"
    "--enable-primitive-sky130=${skywater-pdk-libs-sky130_fd_pr}/share/pdk/skywater-pdk-libs-sky130_fd_pr/source"
    "--disable-io-sky130"
    "--disable-sc-hs-sky130"
    "--disable-sc-ms-sky130"
    "--disable-sc-ls-sky130"
    "--disable-sc-lp-sky130"
    "--enable-sc-hd-sky130=${skywater-pdk-libs-sky130_fd_sc_hd}/share/pdk/skywater-pdk-libs-sky130_fd_sc_hd/source"
    "--disable-sc-hdll-sky130"
    "--disable-sc-hvl-sky130"
    "--enable-alpha-sky130=${sky130-pschulz-xx-hd}/share/pdk/sky130-pschulz-xx-hd/source"
    "--enable-xschem-sky130=${xschem-sky130}/share/pdk/xschem-sky130/source"
    "--enable-klayout-sky130=${sky130-klayout-pdk}/share/pdk/sky130-klayout-pdk/source"
    "--disable-precheck-sky130"
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
