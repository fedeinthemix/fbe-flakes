{
  lib,
  python3Packages,
  fetchPypi,
  curl,
  expat,
  libpng,
}:

python3Packages.buildPythonPackage rec {
  pname = "klayout";
  version = "0.29.8";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-21EPhFb/JMZdyuHDXIxhnLTpHUPxKU24cnodH9oX2q8=";
  };

  build-system = with python3Packages; [
    cython
    setuptools
  ];

  buildInputs = with python3Packages; [
    curl
    expat
    libpng
  ];

  pythonImportsCheck = [ "klayout" ];

  meta = with lib; {
    description = "KLayout’s Python API";
    homepage = "https://github.com/KLayout/klayout";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ fbeffa ];
  };
}
