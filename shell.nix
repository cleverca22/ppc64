with import <nixpkgs> {};

pkgsCross.ppc64.stdenv.mkDerivation {
  name = "kernel";
  ARCH = "powerpc";
  nativeBuildInputs = [ pkgs.stdenv.cc flex bison 
    bc
  ];
}
