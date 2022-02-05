{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "wolfram-for-jupyter-kernel";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "WolframResearch";
    repo = "WolframLanguageForJupyter";
    rev = "v${version}";
    sha256 = "19d9dvr0bv7iy0x8mk4f576ha7z7h7id39nyrggwf9cp7gymxf47";
  };

  dontConfigure = true;
  dontInstall = true;

  buildPhase = ''
    patchShebangs ./configure-jupyter.wls
    mkdir -p $out/share/Wolfram
    cp -r WolframLanguageForJupyter $out/share/Wolfram
    cp -r images $out/share/Wolfram
    cp -r extras $out/share/Wolfram
    cp LICENSE $out/share/Wolfram
  '';

  # no tests
  doCheck = false;

  meta = with lib; {
    description = "A Jupyter kernel for Wolfram Language.";
    homepage = "https://github.com/WolframResearch/WolframLanguageForJupyter";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
