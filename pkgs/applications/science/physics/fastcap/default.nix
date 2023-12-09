{ stdenv
, fetchurl
, ghostscript
, lib
, texlive
}:

stdenv.mkDerivation rec {
  pname = "fastcap";
  version = "2.0-18Sep92";

  src = fetchurl {
    url = "http://www.rle.mit.edu/cpg/codes/${pname}-${version}.tgz";
    sha256 = "0x37vfp6k0d2z3gnig0hbicvi0jp8v267xjnn3z8jdllpiaa6p3k";
  };

  patches = [
    ./patches/fastcap-mulGlobal.patch
    ./patches/fastcap-mulSetup.patch
  ];

  buildInputs = [ ghostscript texlive ];

  sourceRoot = ".";

  preUnpack = ''
    mkdir source
    cd source
  '';

  postPatch = ''
    substituteInPlace ./doc/Makefile \
      --replace '/bin/rm' 'rm'

    for f in "doc/*.tex" ; do
      sed -i -E 's/\\special\{psfile=([^,]*),.*scale=([#0-9.]*).*\}/\\includegraphics[scale=\2]{\1}/' $f
      sed -i -E 's/\\psfig\{figure=([^,]*),.*width=([#0-9.]*in).*\}/\\includegraphics[width=\2]{\1}/' $f
      sed -i -E 's/\\psfig\{figure=([^,]*),.*height=([#0-9.]*in).*\}/\\includegraphics[height=\2]{\1}/' $f
      sed -i -E 's/\\psfig\{figure=([^,]*)\}/\\includegraphics{\1}/' $f
    done

    for f in "doc/mtt.tex" "doc/tcad.tex" "doc/ug.tex"; do
      sed -i -E 's/^\\documentstyle\[(.*)\]\{(.*)\}/\\documentclass[\1]{\2}\n\\usepackage{graphicx}\n\\usepackage{robinspace}/' $f
      sed -i -E 's/\\setlength\{\\footheight\}\{.*\}/%/' $f
      sed -i -E 's/\\setstretch\{.*\}/%/' $f
    done
  '';

  dontConfigure = true;

  makeFlags = [
    "CC=gcc"
    "RM=rm"
    "SHELL=sh"
    "all"
  ];

  postBuild = ''
    make manual
    pushd doc
    for f in *.dvi ; do
      dvipdf $f
    done
    popd
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin/* $out/bin/
    rm $out/bin/README
    mkdir -p $out/share/doc/${pname}-${version}/examples
    cp -r examples/* $out/share/doc/${pname}-${version}/examples
    for f in doc/*.pdf ; do
      cp $f $out/share/doc/${pname}-${version}
    done
  '';

  meta = with lib; {
    description = "Multipole-accelerated capacitance extraction program";
    longDescription = ''
      Fastcap is a capacitance extraction program based on a
      multipole-accelerated algorithm.'';
    homepage = "https://www.rle.mit.edu/cpg/research_codes.htm";
    license = licenses.mit; # see "src/fastcap.c"
    maintainers = with maintainers; [ fbeffa ];
    platforms = platforms.all;
  };
}
