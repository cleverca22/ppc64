let
  flake = builtins.getFlake (toString ./.);
in {
  network = {
    pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; crossSystem = import ./cross.nix; };
  };
  nixbox360 = {
    imports = [
      ./configuration.nix
    ];
    deployment.targetHost = "10.0.0.206";
    deployment.targetUser = "root";
    nixpkgs.overlays = [
      (self': super: {
        linux_xenon = flake.packages.powerpc64-linux.linux;
        linuxXenonPackages = self'.linuxPackagesFor self'.linux_xenon;
      })
    ];
  };
}
