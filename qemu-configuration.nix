{ ... }:

{
  boot = {
    loader = {
      grub.enable = false;
    };
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
    };
  };
  services = {
    nscd.enableNsncd = false;
  };
  systemd.shutdownRamfs.enable = false;
}
