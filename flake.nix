{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/staging";
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
      crossSystem = import ./cross.nix;
      overlays = [ (import ./overlay.nix) ];
    };
  in {
    packages.powerpc64-linux = {
      inherit (p) debootstrap screen gnupg python3 nix systemd;
      linux = (p.buildLinux {
        src = linux;
        version = "6.5.0-xenon";
        enableCommonConfig = false;
      }).overrideDerivation (old: {
        installTargets = [ "install" "modules_install" ];
        postInstall = ''
          cp arch/powerpc/boot/zImage.xenon $out/
        '';
      });
      nixos = let
        eval = import (nixpkgs + "/nixos") {
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
        };
      in eval.system // { inherit eval; };
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
