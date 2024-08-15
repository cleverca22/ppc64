{
  inputs = {
    nixpkgs.url = "github:cleverca22/nixpkgs/ugly-test";
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
  outputs = { self, nixpkgs, linux, xell, libxenon, libfat }:
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
    in {
      inherit (pkgs.xorg) xorgserver;
    };
    hydraJobs = {
      powerpc64-linux = {
        inherit (self.packages.powerpc64-linux) nixos xterm xorgserver xvfb mesa;
        inherit (p) lightdm sx sddm i3 toxvpn;
        inherit (p.gnome) gdm;
      };
      powerpc-none-eabi = {
        inherit (pkgs32) libxenon fat xell1 xell2;
      };
    };
  };
}
