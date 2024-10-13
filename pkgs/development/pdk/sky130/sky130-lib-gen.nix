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

  src = fetchFromGitHub {
    inherit owner repo rev hash;
    leaveDotGit = true; # needed at installation
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/pdk/${repo}/source
    cp -r . $out/share/pdk/${repo}/source/
  '';

  meta = with lib; { inherit license; };
}
