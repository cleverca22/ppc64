{ config, pkgs, lib, ... }:

{
  options = {
    boot.loader.kboot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
  config = lib.mkIf config.boot.loader.kboot.enable {
    system.boot.loader.id = "kboot";
    system.build.installBootLoader = pkgs.substituteAll {
      src = ./update-kboot.sh;
      name = "update-kboot.sh";
      isExecutable = true;
      crossShell = pkgs.runtimeShell;
      kbootTemplate = ./kboot.conf;
    };
  };
}
