# fbe-flakes

This is a [nixpkgs](https://github.com/NixOS/nixpkgs) flake.  On the
on one hand it contains some programs that are not yet available
upstream.  The objective is, at some point, to add them to 'nixpkgs'.
Once a package will be available in the main repository, it will be
removed from this flake.

On the other hand it includes packages that are not of interest to the
was majority of `nixpkgs` users, such as open PDKs to design ICs.

# Google/SkyWaters FOSS 130nm Production PDK

The flake includes 'sky130a' and 'sky130a-ef'. The latter is in
(efabless)[https://efabless.com] style, while the formed in the default
(open_pdk)[http://opencircuitdesign.com/open_pdks/] one. Both
include `skywater-pdk-libs-sky130_fd_sc_hd`, 
`skywater-pdk-libs-sky130_fd_io`, `sky130-pschulz-xx-hd`, 
`xschem-sky130` and `sky130-klayout-pdk`. To include the desired 
libraries create a flake in the project root similar to the following one
```nix
{
  description = "Install Sky130 PDK for project";

  inputs = {
    fbe-flakes.url = github:fedeinthemix/fbe-flakes;
  };

  outputs = { self, fbe-flakes }:
    with fbe-flakes.packages.x86_64-linux; {

      defaultPackage.x86_64-linux = sky130a.withLibraries [
        xschem-sky130
        sky130-klayout-pdk
        sky130-pschulz-xx-hd
        skywater-pdk-libs-sky130_fd_sc_hd
      ];

      devShell.x86_64-linux = fbe-flakes.devShells.x86_64-linux.makeShell
        self.defaultPackage.x86_64-linux;

    };
}
```
The attribute `allLibraries` includes all the available libraries.

The flake provides `devShell`s with the same names as the PKSs plus the suffix `-dev` that installs common tools and set the environment variables `PDK_ROOT` and `PDK` as expected by `open_pdk`s.
