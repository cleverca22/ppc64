{ pkgs, ... }:

{
  boot = {
    loader = {
      grub.enable = false;
    };
  };
  environment = {
    systemPackages = with pkgs; [
      dtc
      iperf3
      openssl
      pciutils
      pv
      screen
      usbutils
    ];
  };
  fileSystems = {
    "/" = {
      fsType = "ext4";
      label = "NIXOS_ROOT";
    };
  };
  users = {
    users = {
      vali = {
        extraGroups = [ "wheel" ];
        initialPassword = "hunter2";
        isNormalUser = true;
        uid = 1000;
      };
      root = {
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM3J+b+IoVRaM3Mr8M0iHPNTdLvBCKDJyt3zuiYVi1PoEKHuEd+BT7CDhdWS0BrvWoXNfa6vFNnniXQHY4euZPoyVHhVphJ508p+TfBReHgJ41+UHU6TOjam7+bIek5LN+qTi8s/CXsTsn2e6wAhgwmKPLEt2NBGgDvwVlivBfmgpcob+hOwOaFHpOEv+W1jmsJYdnRsX9K4jWEx6EEj+qxUa53ubwCwjtJ0o+s59wT2b+4M3qakpu1UZgmmchn8RWmf9OYPRaSyO1TEaGdLnDrhBezwVXKDgulZ8VKbAowpPCMjuqzR28XyNJDVQJHudy9Ir7k0HKQwTUYsqgcV/h root@nas"
        ];
      };
    };
  };
  services = {
    nscd.enableNsncd = false;
    openssh = {
      enable = true;
    };
  };
  systemd.shutdownRamfs.enable = false;
}
