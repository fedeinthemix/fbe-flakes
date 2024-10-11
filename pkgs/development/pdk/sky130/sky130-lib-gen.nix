{ owner ? "efabless"
, repo
, rev
, hash
, version
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
}
