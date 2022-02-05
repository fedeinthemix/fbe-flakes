{ lib, stdenv
, autoPatchelfHook
, coreutils
, patchelf
, requireFile
, callPackage
, makeWrapper
, alsa-lib
, dbus
, fontconfig
, freetype
, gcc
, glib
, libssh2
, ncurses
, opencv4
, openssl
, unixODBC
, xkeyboard_config
, xorg
, zlib
, libxml2
, libuuid
, lang ? "en"
, libGL
, libGLU
}:

let
  l10n = import ./l10ns.nix {
             lib = lib;
             inherit requireFile lang;
           };
  dirName = "WolframEngine";
in
stdenv.mkDerivation rec {
  inherit (l10n) version name src;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    coreutils
    patchelf
    makeWrapper
    alsa-lib
    coreutils
    dbus
    fontconfig
    freetype
    gcc.cc
    gcc.libc
    glib
    libssh2
    ncurses
    opencv4
    openssl
    stdenv.cc.cc.lib
    unixODBC
    xkeyboard_config
    libxml2
    libuuid
    zlib
    libGL
    libGLU
  ] ++ (with xorg; [
    libX11
    libXext
    libXtst
    libXi
    libXmu
    libXrender
    libxcb
    libXcursor
    libXfixes
    libXrandr
    libICE
    libSM
  ]);

  # some bundled libs are found through LD_LIBRARY_PATH
  autoPatchelfIgnoreMissingDeps = true;

  ldpath = lib.makeLibraryPath buildInputs
    + lib.optionalString (stdenv.hostPlatform.system == "x86_64-linux")
      (":" + lib.makeSearchPathOutput "lib" "lib64" buildInputs);

  unpackPhase = ''
    echo "=== Extracting makeself archive ==="
    # find offset from file
    offset=$(${stdenv.shell} -c "$(grep -axm1 -e 'offset=.*' $src); echo \$offset" $src)
    dd if="$src" ibs=$offset skip=1 | tar -xf -
    cd Unix
  '';

  installPhase = ''
    cd Installer
    # don't restrict PATH, that has already been done
    sed -i -e 's/^PATH=/# PATH=/' MathInstaller
    # don't try to set owner and group to root
    sed -i -e 's/chgrp/# chgrp/' MathInstaller
    sed -i -e 's/chown/: # chown/' MathInstaller
    sed -i -e 's/=`id -[ug]`/=0/' MathInstaller

    # Installer wants to write default config in HOME
    HOME=$TMP

    # Fix the installation script as follows:
    # 1. Adjust the shebang
    # 2. Don't store the hostname
    substituteInPlace MathInstaller \
      --replace "/bin/bash" "/bin/sh" \
      --replace "`hostname`" ""

    # Install the desktop items
    export XDG_DATA_HOME="$out/share"

    echo "=== Running MathInstaller ==="
    ./MathInstaller -auto -createdir=y -execdir=$out/bin -targetdir=$out/libexec/${dirName} -silent

    # Fix library paths
    cd $out/libexec/${dirName}/Executables
    for path in MathKernel WolframKernel WolframPlayer math mcc wolfram wolframplayer; do
      sed -i -e "2iexport LD_LIBRARY_PATH=${zlib}/lib:${stdenv.cc.cc.lib}/lib:${libssh2}/lib:\''${LD_LIBRARY_PATH}\n" $path
    done

    # Fix xkeyboard config path for Qt
    for path in WolframPlayer wolframplayer; do
      sed -i -e "2iexport QT_XKB_CONFIG_ROOT=\"${xkeyboard_config}/share/X11/xkb\"\n" $path
    done

    # Link executables to $out/bin
    ln -s $out/libexec/${dirName}/SystemFiles/Kernel/Binaries/Linux-x86-64/wolframscript $out/bin/wolframscript
    for path in MathKernel WolframPlayer math mcc wolfram wolframplayer; do
      ln -s $out/libexec/${dirName}/Executables/$path $out/bin/$path
    done

    # Install man pages
    mkdir -p $out/share/man/man1/
    for mp in math.1 mcc.1 wolframscript.1; do
      ln -s $out/libexec/${dirName}/SystemFiles/SystemDocumentation/Unix/$mp $out/share/man/man1/$mp
    done
  '';

  dontBuild = true;

  # This is primarily an IO bound build; there's little benefit to building remotely.
  preferLocalBuild = true;

  # all binaries are already stripped
  dontStrip = true;

  # we did this in prefixup already
  dontPatchELF = true;

  meta = with lib; {
    description = "Wolfram Engine computational software system";
    homepage = "https://www.wolfram.com/engine/";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
