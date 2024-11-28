{
  lib,
  python3Packages,
  fetchFromGitHub,
  klayout,
  rectangle-packer,
  ruamel-yaml-string,
}:

python3Packages.buildPythonPackage rec {
  pname = "kfactory";
  version = "0.21.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gdsfactory";
    repo = "kfactory";
    rev = "v${version}";
    sha256 = "sha256-VLhAJ5rOBKEO1FDCnlaseA+SmrMSoyS+BaEzjdHm59Y=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    aenum
    cachetools
    gitpython
    klayout
    loguru
    numpy
    pydantic
    pydantic-settings
    rectangle-packer
    requests
    ruamel-yaml
    ruamel-yaml-string
    scipy
    tomli
    toolz
    typer
  ];

  pythonImportsCheck = [ "kfactory" ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  # https://github.com/gdsfactory/kfactory/issues/511
  disabledTestPaths = [
    "tests/test_pdk.py"
  ];

  meta = with lib; {
    description = "KLayout API implementation of gdsfactory";
    homepage = "https://github.com/gdsfactory/kfactory";
    license = licenses.mit;
    maintainers = with maintainers; [ fbeffa ];
  };
}
