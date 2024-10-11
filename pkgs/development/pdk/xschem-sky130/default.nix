{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "xschem-sky130";
  version = "20241009";

  src = fetchFromGitHub {
    owner = "StefanSchippers";
    repo = "xschem_sky130";
    rev = "cdb5dba83695057cbf2da63b6c41a2570d68d4af";
    hash = "sha256-wGguyCIpr7cyH2Ye/VzaxbR80MLU6yMnA4f704dSH60=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/pdk/xschem-sky130/source
    cp -r . $out/share/pdk/xschem-sky130/source/
  '';

  meta = with lib; {
    description = "SKY130 library for xscheme";
    homepage = "https://github.com/StefanSchippers/xschem_sky130";
    maintainers = [ maintainers.fbeffa ];
    license = licenses.asl20;
  };

}
