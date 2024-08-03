{
  config = "powerpc64-unknown-linux-gnuabielfv2";
  rust = {
    rustcTargetSpec = "powerpc64-unknown-linux-gnu";
  };
  #config = "powerpc64-unknown-linux-gnu";
  linux-kernel = {
    name = "ppc xenon";
    target = "zImage.xenon";
    autoModules = false;
    baseConfig = "xenon_defconfig";
    extraConfig = ''
      CFG80211 y
      FAT_FS y
      FW_LOADER_COMPRESS y
      FW_LOADER_COMPRESS_ZSTD y
      INPUT_EVDEV y
      LEDS_CLASS y
      MAC80211 y
      RTL8XXXU y
      USB y
      TUN y
      VFAT_FS y
      WIRELESS y
      WLAN y
      WLAN_VENDOR_REALTEK y
    '';
  };
}
