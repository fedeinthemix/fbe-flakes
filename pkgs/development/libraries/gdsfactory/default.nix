{
  lib,
  python3Packages,
  fetchFromGitHub,
  rectpack,
  kfactory,
}:
python3Packages.buildPythonPackage rec {
  pname = "gdsfactory";
  version = "8.18.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gdsfactory";
    repo = "gdsfactory";
    rev = "v${version}";
    hash = "sha256-wDz8QpRgu40FB8+otnGsHVn2e6/SWXIZgA1aeMqMhPQ=";
  };

  build-system = with python3Packages; [ flit-core ];

  dependencies = with python3Packages; [
    jinja2
    loguru
    matplotlib
    numpy
    orjson
    pandas
    pydantic
    pydantic-settings
    pydantic-extra-types
    pyyaml
    qrcode
    rectpack
    rich
    scipy
    shapely
    toolz
    types-pyyaml
    typer
    kfactory
    watchdog
    freetype-py
    mapbox-earcut
    networkx
    scikit-image
    trimesh
    ipykernel
    attrs
    graphviz
  ];

  nativeCheckInputs = with python3Packages; [
    jsondiff
    jsonschema
    pytestCheckHook
    pytest-regressions
  ];

  # tests require >32GB of RAM
  doCheck = false;

  pythonImportsCheck = [ "gdsfactory" ];

  meta = with lib; {
    description = "python library to generate GDS layouts";
    homepage = "https://github.com/gdsfactory/gdsfactory";
    license = licenses.mit;
    maintainers = with maintainers; [ fbeffa ];
  };
}
