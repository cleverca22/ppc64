{
  config = "powerpc64-unknown-linux-gnuabielfv2";
  #config = "powerpc64-unknown-linux-gnu";
  linux-kernel = {
    name = "ppc xenon";
    target = "zImage.xenon";
    autoModules = true;
    baseConfig = "xenon_defconfig";
    extraConfig = ''
      RTC_DRV_XENON n
      SND_XENON n
    '';
  };
}
 
