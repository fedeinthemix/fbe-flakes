{ stdenv,
  fetchFromGitHub,
  fetchgit,
  lib,
  # dependencies
  arpack-mpi,
  blas,
  cmake,
  eigen,
  fmt,
  gfortran,
  git,
  hypre,
  lapack,
  libunwind,
  libxsmm,
  # magma,
  metis,
  mumps_par,
  mpi,
  nlohmann_json,
  parmetis,
  # petsc,
  pkg-config,
  python3,
  scalapack,
  superlu,
  zlib,
}:
let palace_src = fetchgit {
      url = "https://github.com/awslabs/palace.git";
      rev = "v0.13.0";
      hash = "sha256-mEdmBv+Y6lQIMYiIcy/MnQI/wX8EKZFb79kjKQrzCo0=";
      name = "palace";
    };

    mfem_src = fetchgit {
      url = "https://github.com/mfem/mfem.git";
      # spedified in "cmake/ExternalGitTags.cmake"
      rev = "c444b17c973cc301590a6ac186fb33587b5881e6";
      hash = "sha256-phcpXYnCUH+DWh3FDqSiVAPJw5sNBe6yocRBgfHl6xo=";
      name = "mfem";
      leaveDotGit = true;
    };
    libceed_src = fetchgit {
      url = "https://github.com/CEED/libCEED.git";
      rev = "ef9a992f4cf09f2be4ec72f649495c67ec03f813";
      # hash = "sha256-+0xIXeDkMkW3H9nSDd3eO/Toj6iptgGidYrFuukVEJY=";
      hash = "sha256-Tu1913cWxATlMR7mztX2wIZ25legRqGI/0P+O4SzUKA=";
      name = "libCEED";
      leaveDotGit = true;
    };
    slepc_src = fetchgit {
      url = "https://gitlab.com/slepc/slepc.git";
      rev = "2c2766ada27519a79c9f9d9634b730afb4010d95";
      hash = "sha256-2UXswERhSHDHiA7/awMoJ+hgLQXlHBo9NYzwsa0A5Cg=";
      name = "slepc";
      leaveDotGit = true;
    };
    catch2_src = fetchgit {
      url = "https://github.com/catchorg/Catch2.git";
      rev = "v3.4.0";
      hash = "sha256-DqGGfNjKPW9HFJrX9arFHyNYjB61uoL6NabZatTWrr0=";
      name = "catch2";
    };
    gslib_src = fetchgit {
      url = "https://github.com/Nek5000/gslib.git";
      rev = "dbab7c6f14ec4b3f9a6f93b25fd72a6be0651f34";
      hash = "sha256-QxueFvfaPrqOifQjPAcZ5fRrhRDVhdqVcxBw40axloM=";
      name = "gslib";
    };

in stdenv.mkDerivation (finalAttrs: {

  pname = "palace";
  version = "0.13.0";

  srcs = [
    palace_src
    mfem_src
    libceed_src
    # slepc_src
    catch2_src
    gslib_src
  ];

  sourceRoot = palace_src.name;

  cmakeFlags = [
    "-DPALACE_WITH_OPENMP=ON"
    "-DPALACE_BUILD_EXTERNAL_DEPS=OFF"
    "-DPALACE_WITH_ARPACK=ON"
    "-DPALACE_WITH_GSLIB=ON"
    "-DPALACE_WITH_MUMPS=ON"
    "-DPALACE_WITH_SUPERLU=OFF"
    "-DPALACE_WITH_MAGMA=OFF"
    "-DPALACE_WITH_SLEPC=OFF"
    "-DPALACE_WITH_LIBXSMM=ON"
  ];

  nativeBuildInputs = [
    cmake
    gfortran
    git
    pkg-config
  ];

  buildInputs = [
    arpack-mpi
    blas
    eigen
    fmt
    hypre
    lapack
    libunwind
    libxsmm
    # magma
    metis
    mumps_par
    mpi
    nlohmann_json
    parmetis
    # petsc
    python3
    scalapack
    superlu
    zlib
  ];

  # patchShebangs ../${slepc_src.name}/configure
  preConfigure = ''
    for fn in ${libceed_src.name} ${mfem_src.name} ${gslib_src.name} ${catch2_src.name}; do
      chmod -R u+w ../$fn
    done
    substituteInPlace ./cmake/ExternalLibCEED.cmake \
      --replace-fail 'GIT_REPOSITORY    ''${EXTERN_LIBCEED_URL}' "" \
      --replace-fail 'GIT_TAG           ''${EXTERN_LIBCEED_GIT_TAG}' "" \
      --replace-fail "''${CMAKE_BINARY_DIR}/extern/libCEED" "/../../${libceed_src.name}"
    substituteInPlace ./cmake/ExternalMFEM.cmake \
      --replace-fail 'GIT_REPOSITORY    ''${EXTERN_MFEM_URL}' "" \
      --replace-fail 'GIT_TAG           ''${EXTERN_MFEM_GIT_TAG}' ""\
      --replace-fail "''${CMAKE_BINARY_DIR}/extern/mfem" "/../../${mfem_src.name}"
    # substituteInPlace ./cmake/ExternalSLEPc.cmake \
    #   --replace-fail 'GIT_REPOSITORY      ''${EXTERN_SLEPC_URL}' "" \
    #   --replace-fail 'GIT_TAG             ''${EXTERN_SLEPC_GIT_TAG}' ""\
    #   --replace-fail "''${CMAKE_BINARY_DIR}/extern/slepc" "/../../${slepc_src.name}"
    substituteInPlace ./cmake/ExternalGSLIB.cmake \
      --replace-fail 'GIT_REPOSITORY    ''${EXTERN_GSLIB_URL}' "" \
      --replace-fail 'GIT_TAG           ''${EXTERN_GSLIB_GIT_TAG}' ""\
      --replace-fail "''${CMAKE_BINARY_DIR}/extern/gslib" "/../../${gslib_src.name}"
    substituteInPlace ./test/unit/CMakeLists.txt \
      --replace-fail 'GIT_REPOSITORY https://github.com/catchorg/Catch2.git' "SOURCE_DIR /build/${catch2_src.name}" \
      --replace-fail 'GIT_TAG        ${catch2_src.rev}' ""
  '';

  # the rest is installed by cmake
  installPhase = ''
    runHook preInstall

    cp -r ../examples $out/share/${finalAttrs.pname}-${finalAttrs.version}/

    # fix launch script
    substituteInPlace $out/bin/palace \
      --replace-fail "mpirun" "${mpi}/bin/mpirun"

    runHook postInstall
  '';

  doCheck = true;

  checkTarget = "palace-tests";

  meta = with lib; {
    description = "3D Finite Element Solver for Computational Electromagnetics";
    homepage = "https://awslabs.github.io/palace";
    license = licenses.asl20;
    maintainers = with maintainers; [ fbeffa ];
  };

})
