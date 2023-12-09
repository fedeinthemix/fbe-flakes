{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  pname = "fasthenry";
  version = "3.0-12Nov96";

  src = fetchurl {
    url = "http://www.rle.mit.edu/cpg/codes/${pname}-${version}.tar.z";
    sha256 = "1a06xyyd40zhknrkz17xppl2zd5ig4w9g1grc8qrs0zqqcl5hpzi";
  };

  patches = [
    ./patches/fasthenry-spAllocate.patch
    ./patches/fasthenry-spBuild.patch
    ./patches/fasthenry-spFactor.patch
    ./patches/fasthenry-spSolve.patch
    ./patches/fasthenry-spUtils.patch
  ];

  postPatch = ''
    substituteInPlace ./config \
      --replace '/bin/cp' 'cp'
  '';

  configurePhase = ''
    ./config default
  '';

  makeFlags = [
    "CFLAGS=-fcommon"
    "CC=gcc"
    "RM=rm"
    "SHELL=sh"
    "all"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r bin/* $out/bin/
    mkdir -p $out/share/doc/${pname}-${version}
    cp -r doc/* $out/share/doc/${pname}-${version}
    mkdir -p $out/share/doc/${pname}-${version}/examples
    cp -r examples/* $out/share/doc/${pname}-${version}/examples
  '';

  meta = with lib; {
    description = "Multipole-accelerated inductance analysis program";
    longDescription = ''
       Fasthenry is an inductance extraction program based on a
       multipole-accelerated algorithm.    '';
    homepage = "https://www.rle.mit.edu/cpg/research_codes.htm";
    license = licenses.mit; # see "src/fasthenry/induct.c"
    maintainers = with maintainers; [ fbeffa ];
    platforms = platforms.all;
  };
}
