{ stdenv, lib, fetchurl, mitschemeX11, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "scmutils";
  version = "20230125";

  # source URL
  # http://groups.csail.mit.edu/mac/users/gjs/6946/scmutils-tarballs/
  src = fetchurl {
    url = "https://groups.csail.mit.edu/mac/users/gjs/6946/scmutils-${version}.tar.gz";
    sha256 = "0xzy7gddxbdja66nmm9qzsnfdzni7a0p1339aabchwbldy7vlv8s"; # lib.fakeSha256;
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    for SRC in $(find * -type f -name '*.bci'); do
        install -d "$out/lib/mit-scheme/scmutils/$(dirname $SRC)"
        cp -a "$SRC" "$out/lib/mit-scheme/scmutils/$SRC"
    done
    cp -a mechanics.com $out/lib/mit-scheme/scmutils/
  '';

  postFixup =  ''
      makeWrapper "${mitschemeX11}/bin/mit-scheme" $out/bin/mechanics \
        --set MITSCHEME_HEAP_SIZE 100000 \
        --add-flags "--band $out/lib/mit-scheme/scmutils/mechanics.com"
  '';

  meta = with lib; {
    description = "MIT Scheme Scmutils library";
    homepage = "http://groups.csail.mit.edu/mac/users/gjs/6946/installation.html";
    maintainers = [ maintainers.fbeffa ];
    license = licenses.gpl2Plus;
  };

}
