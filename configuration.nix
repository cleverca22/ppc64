{ pkgs, ... }:

{
  imports = [
    ./xbox360.nix
  ];
  boot.loader.kboot.enable = true;
  boot.loader.grub.enable = false;
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
  fileSystems = {
    "/boot" = {
      device = "UUID=4AA3-EF9F";
    };
    "/" = {
      device = "UUID=387e8327-4894-4aa1-8a88-b3f3a663bac2";
      fsType = "ext4";
    };
  };
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
  networking = {
    nameservers = [ "75.75.75.75" ];
    defaultGateway = "10.0.0.1";
    firewall.enable = false;
    interfaces.enp0s7 = {
      ipv4.addresses = [
        {
          address = "10.0.0.206";
          prefixLength = 24;
        }
      ];
    };
  };
  services = {
    openssh = {
      enable = true;
    };
  };
  users = {
    users = {
      vali = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "wheel" ];
      };
    };
  };
}
