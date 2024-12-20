{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "rectangle-packer";
  version = "2.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Penlect";
    repo = "rectangle-packer";
    rev = version;
    hash = "sha256-YsMLB9jfAC5yB8TnlY9j6ybXM2ILireOgQ8m8wYo4ts=";
  };

  build-system = with python3Packages; [
    cython
    setuptools
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'Cython<3.0.0' 'Cython'
  '';

  pythonImportsCheck = [ "rpack" ];

  meta = with lib; {
    description = "Pack a set of rectangles into a bounding box with minimum area";
    homepage = "https://github.com/Penlect/rectangle-packer";
    license = licenses.mit;
    maintainers = with maintainers; [ fbeffa ];
  };
}
