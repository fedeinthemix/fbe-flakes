{ stdenv
, fetchFromGitHub
, lib
, libX11
, python3
, tcl
, tk
}:

stdenv.mkDerivation rec {
  pname = "netgen";
  version = "1.5.282";

  src = fetchFromGitHub {
    owner = "RTimothyEdwards";
    repo = "netgen";
    rev = version;
    hash = "sha256-VXb3S3kheOM//yhxwIpBB8jOJEt2CYD/52ESnxr/jII=";
  };

  buildInputs = [ libX11 python3 tcl tk ];

  configureFlags = [
    "--with-tcl=${tcl}/lib"
    "--with-tk=${tk}/lib"
  ];

  meta = with lib; {
    description = "Netlist comparison and format manipulation";
    longDescription = ''
      Netgen is a tool for comparing netlists, a process known as LVS,
      which stands for "Layout vs. Schematic".
    '';
    homepage = "http://opencircuitdesign.com/netgen";
    license = licenses.gpl1Plus;
    maintainers = with maintainers; [ fbeffa ];
  };
}
