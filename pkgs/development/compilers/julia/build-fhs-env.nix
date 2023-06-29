{ buildFHSEnv, julia }:

let julia-env =  buildFHSEnv {
      name = "julia";

      targetPkgs = pkgs: (with pkgs; [ julia ]);

      # FONTCONFIG_FILE is needed to make Julia's fontconfig artifact
      # find the system fonts.
      #
      # On Wayland, without setting GDK_BACKEND to X11, we get
      # "Gdk-CRITICAL" messages.  We may remove it in the future. The
      # '*' means that if X11 is not available, it will try other
      # backends.
      profile = ''
        export FONTCONFIG_FILE=/etc/fonts/fonts.conf
        export GDK_BACKEND="x11,*"
      '';

      runScript = "${julia}/bin/julia";

      passthru = {
        julia-unwrapped = julia;
        inherit (julia) meta version system;
      };

    };
in julia-env
