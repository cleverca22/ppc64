{ config, pkgs, ... }:

let
  kboot = pkgs.writeText "kboot.conf" ''
    speedup=1
    default=nixos
    timeout=10
    nixos="dvd0:/zImage.xenon ${builtins.unsafeDiscardStringContext (toString config.boot.kernelParams)}"
  '';
in
{
  config = {
    boot = {
      kernelParams = [
        "maxcpus=1"
      ];
    };
    system.build.isoImage = pkgs.callPackage "${pkgs.path}/nixos/lib/make-iso9660-image.nix" {
      contents = [
        { source = kboot; target = "/kboot.conf"; }
        {
          source = "${config.system.build.kernel}/zImage.xenon";
          target = "/zImage.xenon";
        }
      ];
      volumeID = "xbox-360";
    };
  };
}
