{ lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygmsh";
  version = "7.1.17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "nschloe";
    repo = "pygmsh";
    rev = "v${version}";
    hash = "sha256-INNkdDWrjtgP4zw7ZbZd8oF28/e4EmcVdGFaT5i41IU=";
  };

  build-system = with python3Packages; [ flit-core ];

  dependencies = with python3Packages; [
    gmsh
    meshio
    numpy
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  # tests write to $HOME/.config
  preCheck = ''
    mkdir -p tests/home
    export HOME=$(pwd)/tests/home
  '';

  pytestFlagsArray = with python3Packages; [
    "tests/"
  ];

  pythonImportsCheck = [ "pygmsh" ];

  meta = with lib; {
    description = "Python frontend for Gmsh";
    homepage = "https://github.com/nschloe/pygmsh";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ fbeffa ];
  };

}
