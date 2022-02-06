{ stdenv
, fetchgit
, fetchurl
, lib
, autoconf
, automake
, bison
, blas
, flex
, fftw
, gfortran
, lapack
, libtool_2
, mpi
, suitesparse
, trilinos # if compiling with MPI so trilinos must be! Pass the correct one.
, withMPI ? false
  # for doc
, texlive
, pandoc
, enableDocs ? true
  # for tests
, bash
, bc
, openssh # required by MPI
, perl
, perlPackages
, python38
, enableTests ? true
}:

stdenv.mkDerivation rec {

  pname = "xyce";
  version = "7.4.0";
  twoLevelVersion = with builtins;
    concatStringsSep  "." (lib.lists.take 2 (splitVersion version));

  srcs = [
    # useing fetchurl or fetchFromGitHub doesn't include the manuals
    # due to .gitattributes files
    (fetchgit {
      url = "https://github.com/Xyce/Xyce.git";
      rev = "82f96bbe05bac5921cd6fa1e8bb6a2983a797bf8";
      sha256 = "sha256-sOHjQEo4FqlDseTtxFVdLa0SI/VAf2OkwQV7QSL7SNM=";
    })
    (fetchurl {
      url = "https://github.com/Xyce/Xyce_Regression/archive/refs/tags/Release-${version}.tar.gz";
      sha256 = "00wy2kyvbsyn6gfy42lrkzvgfq9k89hli3ryckywj6p1kcwnvdn9";
    })
  ];

  sourceRoot = with builtins; "./Xyce-${substring 0 7 (head srcs).rev}";

  preConfigure = "./bootstrap";

  configureFlags = [ "CXXFLAGS=-O3"
                     "--enable-xyce-shareable"
                     "--enable-shared"
                     "--enable-stokhos"
                     "--enable-amesos2"
                   ] ++ lib.optionals withMPI [
                     "--enable-mpi"
                     "CXX=mpicxx"
                     "CC=mpicc"
                     "F77=mpif77"
                   ];

  nativeBuildInputs = [ autoconf automake gfortran libtool_2
                      ] ++ lib.optionals enableDocs [
                        (texlive.combine {
                          inherit (texlive)
                            scheme-medium
                            koma-script
                            optional
                            framed
                            enumitem
                            multirow
                            preprint; })
                      ];

  buildInputs = [ bison blas flex fftw lapack suitesparse trilinos
                ] ++ lib.optionals withMPI [ mpi ];

  doCheck = enableTests;

  postPatch = ''
    pushd ../Xyce_Regression-Release-${version}
    find Netlists -type f -regex ".*\.sh\|.*\.pl" -exec chmod ugo+x {} \;
    patchShebangs Netlists/
    patchShebangs TestScripts/
    # patch script generating functions
    sed -i -E 's/\/usr\/bin\/env perl/${builtins.replaceStrings [ "." "/" "-" "!" ] [ "\\." "\\/" "\\-" "\\!" ] perl.outPath}\/bin\/perl/' TestScripts/XyceRegression/Testing/Netlists/RunOptions/runOptions.cir.sh
    sed -i -E 's/\/bin\/sh/${builtins.replaceStrings [ "." "/" "-" "!" ] [ "\\." "\\/" "\\-" "\\!" ] bash.outPath}\/bin\/sh/' TestScripts/XyceRegression/Testing/Netlists/RunOptions/runOptions.cir.sh
    popd
  '';

  checkInputs = [ bc
                  perl
                  perlPackages.DigestMD5
                  (python38.withPackages (ps: with ps; [ numpy scipy ]))
                ] ++ lib.optionals withMPI [ mpi openssh ];

  checkPhase = ''
    XYCE_BINARY="$(pwd)/src/Xyce"
    EXECSTRING="${if withMPI then "mpirun -np 2 " else ""}$XYCE_BINARY"
    TEST_ROOT="$(pwd)/../Xyce_Regression-Release-${version}"

    # Honor the TMP variable
    sed -i -E 's/\/tmp/\$TMP/' $TEST_ROOT/TestScripts/suggestXyceTagList.sh

    # This test makes Xyce access /sys/class/net when run with MPI
    EXLUDE_TESTS_FILE=$TMP/exclude_tests.$$
    echo "CommandLine/command_line.cir" > $EXLUDE_TESTS_FILE

    $TEST_ROOT/TestScripts/run_xyce_regression \
      --output="$(pwd)/Xyce_Test" \
      --xyce_test="''${TEST_ROOT}" \
      --taglist="$($TEST_ROOT/TestScripts/suggestXyceTagList.sh "$XYCE_BINARY" | sed -E -e 's/TAGLIST=([^ ]+).*/\1/' -e '2,$d')" \
      --resultfile="$(pwd)/test_results" \
      ${if withMPI then "--excludelist=$EXLUDE_TESTS_FILE" else ""} \
      "''${EXECSTRING}"
  '';

  outputs = [ "out" "doc" ];

  postInstall = if enableDocs then ''
    local docFiles=("doc/Users_Guide/Xyce_UG"
      "doc/Reference_Guide/Xyce_RG"
      "doc/Release_Notes/Release_Notes_${twoLevelVersion}/Release_Notes_${twoLevelVersion}")

    # Release notes refer to an image not in the repo.
    sed -i -E 's/\\includegraphics\[height=(0.5in)\]\{snllineblubrd\}/\\mbox\{\\rule\{0mm\}\{\1\}\}/' ''${docFiles[2]}.tex

    install -d $doc/share/doc/${pname}-${version}/
    for d in ''${docFiles[@]}; do
      # Use a public document class
      sed -i -E 's/\\documentclass\[11pt,report\]\{SANDreport\}/\\documentclass\[11pt,letterpaper\]\{scrreprt\}/' $d.tex
      sed -i -E 's/\\usepackage\[sand\]\{optional\}/\\usepackage\[report\]\{optional\}/' $d.tex
      pushd $(dirname $d)
      make
      install -t $doc/share/doc/${pname}-${version}/ $(basename $d.pdf)
      popd
    done
    '' else "";

  meta = with lib; {
    description = "High-performance analog circuit simulator";
    longDescription = ''
      Xyce is a SPICE-compatible, high-performance analog circuit simulator,
      capable of solving extremely large circuit problems by supporting
      large-scale parallel computing platforms.
    '';
    homepage = "https://xyce.sandia.gov";
    license = licenses.gpl3;
    maintainers = with maintainers; [ fbeffa ];
    platforms = platforms.all;
  };
}
