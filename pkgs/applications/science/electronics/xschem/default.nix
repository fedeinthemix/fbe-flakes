{ stdenv
, fetchurl
, lib
, bison
, cairo
, flex
, libX11
, libXpm
, pkg-config
, tcl
, tk
}:

stdenv.mkDerivation rec {

  pname = "xschem";
  version = "3.0.0";

  src = fetchurl {
    url = "https://github.com/StefanSchippers/xschem/archive/refs/tags/${version}.tar.gz";
    sha256 = "0hzh9bdlx96p4v9vgsg29w1zyly5p39g7zy12c4apqgdc9mcrlcr";
  };

  nativeBuildInputs = [ bison flex pkg-config ];

  buildInputs = [ cairo libX11 libXpm tcl tk ];

  hardeningDisable = [ "format" ];

  meta = with lib; {
    description = "Schematic capture and netlisting EDA tool";
    longDescription = ''
      Xschem is a schematic capture program, it allows creation of
      hierarchical representation of circuits with a top down approach.
      By focusing on interfaces, hierarchy and instance properties a
      complex system can be described in terms of simpler building
      blocks. A VHDL or Verilog or Spice netlist can be generated from
      the drawn schematic, allowing the simulation of the circuit.
    '';
    homepage = "https://xschem.sourceforge.io/stefan/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ fbeffa ];
    platforms = platforms.all;
  };
}
