{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "sky130-klayout-pdk";
  version = "20241009";

  src = fetchFromGitHub {
    owner = "efabless";
    repo = "sky130_klayout_pdk";
    rev = "40d99b2830c3ccd02340e548a21a5ce3fd2b5942";
    hash = "sha256-wYCrHnqtPfy0bndJi7IG/ytyuATujprcbzrGwk2wIT4=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/pdk/sky130-klayout-pdk/source
    cp -r . $out/share/pdk/sky130-klayout-pdk/source/
  '';

  meta = with lib; {
    description = "Skywater 130nm Technology PDK for KLayout";
    homepage = "https://github.com/efabless/sky130_klayout_pdk";
    maintainers = [ maintainers.fbeffa ];
    license = licenses.asl20;
  };

}
