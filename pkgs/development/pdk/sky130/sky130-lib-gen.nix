{ owner ? "efabless"
, repo
, rev
, hash
, version
, license
}:

{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = repo;
  version = version;

  src = fetchFromGitHub { inherit owner repo rev hash; };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/pdk/${repo}/source
    cp -r . $out/share/pdk/${repo}/source/
  '';

  meta = with lib; { inherit license; };
}
