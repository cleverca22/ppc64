{ pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxXenonPackages;
  nixpkgs.crossSystem = {
    config = "powerpc64-unknown-linux-gnuabielfv2";
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
  };
  fileSystems."/" = {
    device = "UUID=2a7306b2-2a16-4894-b4c9-7649bf598754";
    fsType = "ext4";
  };
  boot.loader.grub.enable = false;
  nixpkgs.overlays = [
    (self: super: {
      python3 = super.python3.overrideDerivation (old: {
        patches =
          [
            # "${pkgs.path}/pkgs/development/interpreters/python/cpython/3.12/0001-Fix-build-with-_PY_SHORT_FLOAT_REPR-0.patch"
          ]
          ++ old.patches;
      });
      libressl = self.hello;
      netcat = self.hello;
    })
  ];
  systemd.shutdownRamfs.enable = false;
  services.nscd.enableNsncd = false;
  virtualisation.libvirtd.enable = false;
}
