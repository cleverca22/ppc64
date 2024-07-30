let
  fun = pkg:
  let
    x = builtins.parseDrvName pkg.name;
    blacklist = [
      "mesa-powerpc64-unknown-linux-gnuabielfv2"
      "libdrm-powerpc64-unknown-linux-gnuabielfv2"
    ];
  in !builtins.elem x.name blacklist;
in

self: super: {
  #util-linux = super.util-linux.override { systemdSupport = false; };
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
  xorg = super.xorg.overrideScope (xself: xsuper: {
    xorgserver = xsuper.xvfb;
    oldxorgserver = super.xorg.xorgserver.overrideAttrs (old: {
      buildInputs = builtins.filter fun old.buildInputs;
      configureFlags = old.configureFlags ++ [
        "--disable-glx"
        "--disable-dri"
        "--disable-dri2"
        "--disable-dri3"
      ];
    });
    xvfb = xsuper.xvfb.overrideAttrs (old: {
      #configureFlags = old.configureFlags ++ [ "--enable-xorg" ];
    });
    xf86inputevdev = super.hello;
  });
  #systemd = super.systemd.override { withIptables = false; };
}
