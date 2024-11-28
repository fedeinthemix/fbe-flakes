{ lib,
  fetchFromGitHub,
  gdstk,
  python3Packages,
  version ? "1.3.7",
  hash ? "sha256-OUPDz/PK5eX+xFMT6MQB0eMXbAcLmuJxz/BWOOIuicg=",
}:

python3Packages.buildPythonPackage {
  pname = "meshwell";
  version = version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simbilod";
    repo = "meshwell";
    rev = "v${version}";
    hash = hash;
  };

  build-system = with python3Packages; [ flit-core ];

  dependencies = with python3Packages; [
    shapely
    gmsh
    meshio
    tqdm
    pydantic
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

  pythonImportsCheck = [ "meshwell" ];

  meta = with lib; {
    description = "High level Gmsh abstraction library";
    homepage = "https://github.com/simbilod/meshwell";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ fbeffa ];
  };

}
