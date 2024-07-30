{ stdenv, fetchFromGitHub, lib }:

stdenv.mkDerivation {
  name = "fbdoom";
  src = fetchFromGitHub {
    owner = "Vali0004";
    repo = "fbDOOM_BE";
    rev = "db74b00e4fd2a25a202ddc5bbd47f0d3fd148648";
    hash = "sha256-KHt98U+6mTszh1cimM2tFyzfuWqE5cL7/6ARIicUaLw=";
  };
  patches = [ ./fbdoom.patch ];
  postUnpack = ''
    echo $sourceRoot
    pwd
    ls $sourceRoot
    export sourceRoot=$sourceRoot/fbdoom
    export CROSS_COMPILE=${stdenv.hostPlatform.config}-
    export NOSDL=1
  '';
  postPatch = ''
    sed -i 's/input_tty.o/input_evdev.o/' Makefile
    cp -v ${./fbdoom-overlay}/* .
  '';
  enableParallelBuilding = true;
  installPhase = ''
    ls -ltrh
    mkdir -p $out/bin/
    cp fbdoom $out/bin/
  '';
}
