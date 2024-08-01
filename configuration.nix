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
    plymouth.enable = false;
  };
  documentation.enable = false;
  environment.systemPackages = with pkgs; [
    (neofetch.override { x11Support = false; })
    pciutils
    screen
    usbutils
    evtest
    #gdb
    (pkgs.callPackage ./fbdoom.nix {})
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
  fonts = {
    enableDefaultPackages = false;
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
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.204";
          prefixLength = 24;
        }
      ];
    };
    nameservers = [ "75.75.75.75" ];
    wireless = {
      enable = true;
    };
  };
  programs.ssh.enableAskPassword = false;
  #security.polkit.enable = false;
  services = {
    avahi = {
      enable = true;
      publish = {
        enable = true;
      };
    };
    libinput.enable = false;
    nscd.enableNsncd = false;
    openssh = {
      enable = true;
    };
    speechd.enable = false;
    xserver = {
      enable = true;
      desktopManager.xfce.enable = false;
      displayManager = {
        lightdm.enable = false;
        startx.enable = true;
      };
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
