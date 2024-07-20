{ pkgs, ... }:

{
  imports = [
    ./xbox360.nix
  ];
  boot = {
    loader = {
      kboot.enable = true;
      grub.enable = false;
    };
    kernelPackages = pkgs.linuxXenonPackages;
    kernelParams = [
    ];
  };
  environment.systemPackages = with pkgs; [
    (neofetch.override { x11Support = false; })
    pciutils
    screen
    usbutils
  ];
  fileSystems = {
    "/boot" = {
      device = "UUID=4AA3-EF9F";
    };
    "/" = {
      device = "UUID=387e8327-4894-4aa1-8a88-b3f3a663bac2";
      fsType = "ext4";
    };
  };
  nixpkgs = {
    overlays = [ (import ./overlay.nix) ];
    crossSystem = import ./cross.nix;
  };
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
    avahi = {
      enable = true;
      publish = {
        enable = true;
      };
    };
    openssh = {
      enable = true;
    };
    nscd.enableNsncd = false;
    xserver = {
      enable = false;
    };
  };
  systemd.shutdownRamfs.enable = false;
  users = {
    users = {
      vali = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [ "wheel" ];
      };
    };
  };
  #virtualisation.libvirtd.enable = false;
}
