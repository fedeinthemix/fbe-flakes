{ lib,
  fetchFromGitHub,
  gdstk,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "meshwell";
  version = "1.3.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simbilod";
    repo = "meshwell";
    rev = "v${version}";
    # sha256 = lib.fakeSha256;
    hash = "sha256-OUPDz/PK5eX+xFMT6MQB0eMXbAcLmuJxz/BWOOIuicg=";
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
