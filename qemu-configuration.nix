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
  services = {
    nscd.enableNsncd = false;
  };
  systemd.shutdownRamfs.enable = false;
}
