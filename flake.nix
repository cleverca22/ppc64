{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/48acb2ac49c9b9bdca050625be528f2efc4f123c";
    linux = {
      url = "github:rwf93/linux/xenon-6.5";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, linux }:
  let
    host = import nixpkgs { system = "x86_64-linux"; };
    p = import nixpkgs {
      system = "x86_64-linux";
      crossSystem = {
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
      };
      overlays = [ (self: super: {
        # systemd = null;
        util-linux = super.util-linux.override { systemdSupport = false; };
        python3 = super.python3.overrideDerivation (old: {
          #patches = [ ./c3677befbecbd7fa94cde8c1fecaa4cc18e6aa2b.patch ] ++ old.patches;
          patches =
            [
              "${nixpkgs}/pkgs/development/interpreters/python/cpython/3.12/0001-Fix-build-with-_PY_SHORT_FLOAT_REPR-0.patch"
            ]
            ++ old.patches;
        });
      }) ];
    };
  in {
    packages.powerpc64-linux = {
      inherit (p) debootstrap screen gnupg python3 nix;
      linux = (p.buildLinux {
        src = linux;
        version = "6.5.0-xenon";
      }).overrideDerivation (old: {
        installTargets = [ "install" "modules_install" ];
        postInstall = ''
          pwd
          ls -l
          cp arch/powerpc/boot/zImage.xenon $out/
        '';
      });
      nixos = (import (nixpkgs + "/nixos") {
        system = "x86_64-linux";
        configuration = {
          imports = [ ./configuration.nix ];
          nixpkgs.overlays = [
            (self': super: {
              linux_xenon = self.packages.powerpc64-linux.linux;
              linuxXenonPackages = self'.linuxPackagesFor self'.linux_xenon;
            })
          ];
        };
      }).system;
      nixos_tar = host.callPackage (nixpkgs + "/nixos/lib/make-system-tarball.nix") {
        fileName = "nixos_tar";
        storeContents = [
          {
            object = self.packages.powerpc64-linux.nixos;
            symlink = "/nixos";
          }
        ];
        contents = [];
      };
    };
  };
}
