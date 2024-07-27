{ pkgs, lib, ... }:

{
  imports = [
    ./xbox360.nix
  ];
  boot = {
    consoleLogLevel = 16;
    loader = {
      grub.enable = false;
      kboot.enable = true;
    };
    kernelPackages = pkgs.linuxXenonPackages;
    kernelParams = [
      "coherent_pool=16M"
      "console=tty0"
      "console=ttyS0,115200"
      "nokaslr"
      "video=xenonfb"
    ];
    #supportedFilesystems = [ "zfs" ];
  };
  documentation.enable = false;
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
  hardware.graphics.enable = false;
  nixpkgs = {
    crossSystem = import ./cross.nix;
    overlays = [ (import ./overlay.nix) ];
  };
  networking = {
    defaultGateway = "10.0.0.1";
    firewall.enable = false;
    hostId = "aacc9931";
    interfaces.enp0s7 = {
      ipv4.addresses = [
        {
          address = "10.0.0.206";
          prefixLength = 24;
        }
      ];
    };
    nameservers = [ "75.75.75.75" ];
    wireless = {
      enable = true;
    };
  };
  services = {
    avahi = {
      enable = true;
      publish = {
        enable = true;
      };
    };
    nscd.enableNsncd = false;
    openssh = {
      enable = true;
    };
    speechd.enable = false;
    xserver = {
      enable = true;
      displayManager.xserverBin = lib.mkForce "${pkgs.xorg.xvfb}/bin/Xvfb";
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
