{ stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  python3Packages,
  qhull,
  zlib,
}:

python3Packages.buildPythonPackage rec {
  pname = "gdstk";
  version = "0.9.57";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "heitzmann";
    repo = "gdstk";
    rev = "v${version}";
    hash = "sha256-vKey5cgFlszzNnoiOBm82+x/8KTQWUCT6U6eEU4AfHA=";
  };

  build-system = with python3Packages; [
    cmake
    ninja
    scikit-build-core
  ];

  buildInputs = [
    qhull
    zlib
  ];

  dependencies = with python3Packages; [
    numpy # convert to numpy_2 in due time
    typing-extensions
  ];

  # using 'numpy_2' causes conflicts when combining with other packages
  preConfigure = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'numpy >= 2.0' 'numpy'
  '';

  # cmake builds in the 'build' dir.
  postConfigure = ''
    cd ..
  '';

  pythonImportCheck = [
    "gdstk"
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  preCheck = ''
    # local gdstk dir doesn't inlcude _gdstk*.so file
    rm -r gdstk
    ln -s $out/${python3Packages.python.sitePackages} gdstk
  '';

  pytestFlagsArray = with python3Packages; [
    "tests/"
  ];

  meta = with lib; {
    description = "Library for manipulation of GDSII and OASIS files.";
    homepage = "https://github.com/heitzmann/gdstk";
    license = licenses.boost;
    maintainers = with maintainers; [ fbeffa ];
  };

}
  
