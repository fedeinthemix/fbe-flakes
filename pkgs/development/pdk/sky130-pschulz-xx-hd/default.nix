{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "sky130-pschulz-xx-hd";
  version = "20241009";

  src = fetchFromGitHub {
    owner = "PaulSchulz";
    repo = "sky130_pschulz_xx_hd";
    rev = "6eb3b0718552b034f1bf1870285ff135e3fb2dcb";
    hash = "sha256-+7DxRIZJM7rsMUcWA6DjVNMaPrhlY2CwdK8RhVNOuDA=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/pdk/sky130-pschulz-xx-hd/source
    cp -r . $out/share/pdk/sky130-pschulz-xx-hd/source/
  '';

  meta = with lib; {
    description = "SKY130 High Density Miscellanious Cells";
    homepage = "https://github.com/PaulSchulz/sky130_pschulz_xx_hd";
    maintainers = [ maintainers.fbeffa ];
    license = licenses.asl20;
  };

}
