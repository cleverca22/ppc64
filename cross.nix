{
  config = "powerpc64-unknown-linux-gnuabielfv2";
  #config = "powerpc64-unknown-linux-gnu";
  linux-kernel = {
    name = "ppc xenon";
    target = "zImage.xenon";
    autoModules = false;
    baseConfig = "xenon_defconfig";
    extraConfig = ''
      FAT_FS y
      VFAT_FS y
    '';
  };
}
