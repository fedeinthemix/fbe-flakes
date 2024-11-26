{ lib,
  fetchFromGitHub,
  gdstk,
  python3Packages,
  gdsfactory,
  pygmsh,
  meshwell,
  # # for klayout
  klayout,
}:

python3Packages.buildPythonPackage rec {
  pname = "gplugins";
  version = "1.1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gdsfactory";
    repo = "gplugins";
    rev = "v${version}";
    hash = "sha256-6+/G6mFpXcQJmpLA9VvRwycilYtDyq1d+9beBuIiwDw=";
  };

  pipInstallFlags = [
    "gplugins[gmsh,klayout,palace,vlsir]"
  ];

  build-system = with python3Packages; [ flit-core ];

  dependencies = with python3Packages; [
    gdsfactory
    pint
    gdstk
    tqdm
    numpy
    # for gmsh
    gmsh
    h5py
    mapbox-earcut
    meshio
    pygmsh
    pyvista
    trimesh
    shapely
    meshwell
    # # for klayou
    klayout
    pyvis
    # vlsir # not in nixpkgs
    # vlsirtools  # not in nixpkgs
  ];

  preCheck = ''
    # tests write .config to home
    export HOME=$(pwd)/home
  '';

  # most plugins do make use of libraries not yet added
  doCheck = false;

  pythonImportsCheck = [
    "gplugins"
    "gplugins.common"
    "gplugins.gmsh"
    "gplugins.klayout"
    "gplugins.materials"
    "gplugins.palace"
    "gplugins.spice"
    # "gplugins.vlsir"
  ];

  meta = with lib; {
    description = "gdsfactory plugins";
    homepage = "https://github.com/gdsfactory/gplugins";
    license = licenses.mit;
    maintainers = with maintainers; [ fbeffa ];
  };

}
