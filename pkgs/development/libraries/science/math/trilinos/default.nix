{ stdenv
, fetchurl
, fetchgit
, lib
, blas
, boost
, cmake
, gfortran
, lapack
, mpi
, suitesparse
, swig
, withMPI ? false
}:

# NOTE: Not all packages are enabled.  We specifically enable the ones
# required to build Xyce.  If the need comes, we can enable more of them.

let flagsBase = ''
        -G "Unix Makefiles"
        -DBUILD_SHARED_LIBS=ON
        -DCMAKE_CXX_FLAGS="-O3 -fPIC"
        -DCMAKE_C_FLAGS="-O3 -fPIC"
        -DCMAKE_Fortran_FLAGS="-O3 -fPIC"
        -DTrilinos_ENABLE_NOX=ON
        -DNOX_ENABLE_LOCA=ON
        -DTrilinos_ENABLE_EpetraExt=ON
        -DEpetraExt_BUILD_BTF=ON
        -DEpetraExt_BUILD_EXPERIMENTAL=ON
        -DEpetraExt_BUILD_GRAPH_REORDERINGS=ON
        -DTrilinos_ENABLE_TrilinosCouplings=ON
        -DTrilinos_ENABLE_Ifpack=ON
        -DTrilinos_ENABLE_AztecOO=ON
        -DTrilinos_ENABLE_Belos=ON
        -DTrilinos_ENABLE_Teuchos=ON
        -DTeuchos_ENABLE_COMPLEX=ON
        -DTrilinos_ENABLE_Amesos=ON
        -DAmesos_ENABLE_KLU=ON
        -DTrilinos_ENABLE_Amesos2=ON
        -DAmesos2_ENABLE_KLU2=ON
        -DAmesos2_ENABLE_Basker=ON
        -DTrilinos_ENABLE_Sacado=ON
        -DTrilinos_ENABLE_Stokhos=ON
        -DTrilinos_ENABLE_Kokkos=ON
        -DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF
        -DTrilinos_ENABLE_CXX11=ON
        -DTPL_ENABLE_AMD=ON
        -DTPL_ENABLE_BLAS=ON
        -DTPL_ENABLE_LAPACK=ON
    '';
    flagsParallel = ''
        -DCMAKE_C_COMPILER=mpicc
        -DCMAKE_CXX_COMPILER=mpic++
        -DCMAKE_Fortran_COMPILER=mpif77
        -DTrilinos_ENABLE_Isorropia=ON
        -DTrilinos_ENABLE_Zoltan=ON
        -DTPL_ENABLE_MPI=ON
      '';

in stdenv.mkDerivation rec {

  pname = "trilinos";
  version = "12.12.1"; # Xyce 7.4 requires version 12.12.1

  src = fetchurl {
    url = "https://github.com/trilinos/Trilinos/archive/refs/tags/${pname}-release-"
          + builtins.replaceStrings [ "." ] [ "-" ] version
          + ".tar.gz";
    sha256 = "064ynimvsj17pvif8n990jr2al451mpwy9hpgr5242b3khrcax2l";
  };

  nativeBuildInputs = [ cmake gfortran swig ];

  buildInputs = [ blas boost lapack suitesparse ] ++ lib.optionals withMPI [ mpi ];

  preConfigure = if withMPI then
                   ''cmakeFlagsArray+=(${flagsBase} ${flagsParallel})''
                 else
                   ''cmakeFlagsArray+=(${flagsBase})'';

  meta = with lib; {
    description = "Engineering and scientific problems algorithms";
    longDescription = ''
      The Trilinos Project is an effort to develop algorithms and enabling
      technologies within an object-oriented software framework for the
      solution of large-scale, complex multi-physics engineering and scientific
      problems.
    '';
    homepage = "https://trilinos.org";
    license = licenses.bsd3;
    maintainers = with maintainers; [ fbeffa ];
    platforms = platforms.all;
  };
}
