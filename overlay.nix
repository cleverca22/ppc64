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
}
