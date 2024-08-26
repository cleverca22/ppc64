{
  inputs = {
    nixpkgs.url = "github:cleverca22/nixpkgs/ugly-test";
    nixpkgs2.url = "github:nixos/nixpkgs/nixos-unstable";
    linux = {
      url = "github:rwf93/linux/xenon-6.5";
      flake = false;
    };
    xell.url = "github:cleverca22/xell-reloaded";
    xell.flake = false;
    libxenon.url = "github:cleverca22/libxenon";
    libxenon.flake = false;
    libfat.url = "github:cleverca22/libfat";
    libfat.flake = false;
  };
  nixConfig = {
    extra-substituters = [ "https://hydra.angeldsis.com/" ];
    extra-trusted-public-keys = [ "hydra.angeldsis.com-1:7s6tP5et6L8Y6sX7XGIwzX5bnLp00MtUQ/1C9t1IBGE=" ];
  };
  outputs = { self, nixpkgs, linux, xell, libxenon, libfat, nixpkgs2 }:
  let
    host = import nixpkgs { system = "x86_64-linux"; };
    p = import nixpkgs {
      system = "x86_64-linux";
      crossSystem = import ./cross.nix;
      overlays = [ (import ./overlay.nix) ];
    };
    overlay32 = self: super: {
      libxenon = self.callPackage libxenon {};
      fat = self.callPackage libfat {};
      xell2 = p.callPackage xell {
        inherit (self) fat libxenon;
        stdenv32 = self.stdenv;
        stage = 2;
      };
      xell1 = p.callPackage xell {
        inherit (self) fat xell2 libxenon;
        stdenv32 = self.stdenv;
        stage = 1;
      };
    };
    pkgs32 = import nixpkgs {
      system = "x86_64-linux";
      crossSystem = {
        config = "powerpc-none-eabi";
        libc = "newlib";
      };
      overlays = [ overlay32 ];
    };
  in {
    legacyPackages.powerpc64-linux = import nixpkgs { system = "powerpc64-linux"; overlays = [ (import ./overlay.nix) ]; };
    packages = {
      powerpc-none-eabi = {
        inherit (pkgs32) libxenon fat xell1 xell2;
      };
    };
    packages.powerpc64-linux = {
      gccgo = p.buildPackages.gccgo.cc.overrideAttrs (old: {
        #outputs = [ "out" "man" "info" "lib" ];
        preInstall = "";
      });
      inherit (p) debootstrap screen gnupg python3 nix systemd xterm mesa;
      utils = p.callPackage ./utils.nix {};
      inherit (p.xorg) xorgserver xvfb;
      linux = (p.buildLinux {
        src = linux;
        version = "6.5.0-xenon";
        enableCommonConfig = false;
        # TODO, kernelInstallTarget
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
    packages.x86_64-linux = let
      pkgs = import nixpkgs {
        overlays = [ (import ./overlay.nix) ];
        system = "x86_64-linux";
      };
      pkgs2 = import nixpkgs2 {
        system = "x86_64-linux";
      };
      qemuCrossSystem = {
        config = "powerpc64-unknown-linux-gnuabielfv2";
        linux-kernel = {
          name = "g5-linux";
          baseConfig = "g5_defconfig";
          target = "vmlinux";
          autoModules = false;
          kernelInstallTarget = "install";
        };
        kernelInstallTarget = "install";
      };
      p3 = import nixpkgs {
        crossSystem = qemuCrossSystem;
        system = "x86_64-linux";
      };
      g5linux = p3.linux.overrideDerivation (old: {
        installTargets = [ "install" "modules_install" ];
      });
      g5linuxPackages = p3.linuxPackagesFor g5linux;
      qemu-eval = import (nixpkgs + "/nixos") {
        system = "x86_64-linux";
        configuration = {
          imports = [ ./qemu-configuration.nix ];
          boot.kernelPackages = g5linuxPackages;
          nixpkgs.crossSystem = qemuCrossSystem;
          nixpkgs.overlays = [ (self: super: {
            makeModulesClosure = attrs: super.makeModulesClosure (attrs // { allowMissing = true; });
          }) ];
        };
      };
      ext4image = pkgs2.callPackage "${nixpkgs}/nixos/lib/make-disk-image.nix" {
        bootSize = 1024;
        diskSize = 64 * 1024;
        installBootLoader = false;
        label = "NIXOS_ROOT";
        copyChannel = false;
        config = qemu-eval.config;
        format = "qcow2";
      };
    in {
      inherit (pkgs.xorg) xorgserver;
      start-vm = pkgs.writeShellScriptBin "start-vm" ''
        export PATH=${pkgs.lib.makeBinPath (with pkgs2; [ qemu ])}:$PATH
        echo ${ext4image}
        ls -lh ${ext4image}
        ls -lh ${qemu-eval.system}
        if ! test -e test.qcow2; then
          qemu-img create -f qcow2 -b ${ext4image}/nixos.qcow2 -F qcow2 test.qcow2
          nix-store -r ${ext4image} --add-root rootfs.root --indirect
        fi
        qemu-system-ppc64 -kernel ${qemu-eval.system}/kernel -initrd ${qemu-eval.system}/initrd -serial stdio -M mac99,via=pmu -m 2g -net user -device virtio-net \
          -drive index=0,id=drive1,file=test.qcow2,cache=writeback,werror=report \
          -append "init=${qemu-eval.system}/init $(cat ${qemu-eval.system}/kernel-params)"
      '';
    };
    hydraJobs = {
      powerpc64-linux = {
        inherit (self.packages.powerpc64-linux) nixos xterm xorgserver xvfb mesa;
        inherit (p) lightdm sx sddm i3 toxvpn;
        qemu-user = p.qemu.override {
          alsaSupport = false;
          canokeySupport = false;
          capstoneSupport = false;
          enableDocs = false;
          gtkSupport = false;
          hostCpuTargets = [ "x86_64-linux-user" "i386-softmmu" "x86_64-softmmu" ];
          jackSupport = false;
          openGLSupport = false;
          pipewireSupport = false;
          pulseSupport = false;
          sdlSupport = false;
          seccompSupport = false;
          smartcardSupport = false;
          smbdSupport = false;
          spiceSupport = false;
          tpmSupport = false;
          virglSupport = false;
          vncSupport = true;
        };
        inherit (p.gnome) gdm;
      };
      powerpc-none-eabi = {
        inherit (pkgs32) libxenon fat xell1 xell2;
      };
      x86_64-linux = {
        start-vm = self.packages.x86_64-linux.start-vm;
      };
    };
  };
}
