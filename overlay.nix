let
  fun = pkg:
  let
    x = builtins.parseDrvName pkg.name;
    blacklist = [
      #"mesa-powerpc64-unknown-linux-gnuabielfv2"
      "powerpc64-unknown-linux-gnuabielfv2-rustc-wrapper"
      #"libdrm-powerpc64-unknown-linux-gnuabielfv2"
      "mesa"
    ];
    hit = builtins.elem x.name blacklist;
  in if (pkg ? name) then !hit else true;
  fun2 = flag:
  let
    blacklist = [
      "-Dgallium-rusticl=true"
      "-Dinstall-intel-clc=true"
      "-Dgallium-opencl=icd"
      "-Dintel-clc=system"
    ];
  in !builtins.elem flag blacklist;
in

self: super: {
  #python3 = super.python3.overrideDerivation (old: {
  #  patches = [
  #    "${self.path}/pkgs/development/interpreters/python/cpython/3.12/0001-Fix-build-with-_PY_SHORT_FLOAT_REPR-0.patch"
  #  ] ++ old.patches;
  #});
  libressl = self.hello;
  netcat = self.hello;
  makeModulesClosure = attrs: super.makeModulesClosure (attrs // { allowMissing = true; });
  llvm_18 = null; # needed by rust, which fails to build
  xterm = super.xterm.overrideDerivation (old: {
    configureFlags = old.configureFlags ++ [ "--disable-wide-chars" ];
  });
  nix = super.nix.override { enableDocumentation = false; };
  oldmesa = super.stdenv.mkDerivation {
    name = "mesa";
  };
  mesa = (super.mesa.override {
    vulkanDrivers = [ "swrast" ];
    galliumDrivers = [ "swrast" "zink" ];
  }).overrideDerivation (old: {
    mesonFlags = (self.lib.filter fun2 old.mesonFlags) ++ [
      "-Dgallium-vdpau=disabled"
      "-Dgallium-va=disabled"
      "-Dgallium-xa=disabled"
      "-Dgallium-nine=false"
    ];
    nativeBuildInputs = builtins.filter fun old.nativeBuildInputs;
    outputs = builtins.filter (x: x!="spirv2dxil") old.outputs;
  });
}
