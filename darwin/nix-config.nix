{ ... }:
{
  nix.enable = false;

  launchd.daemons = {
    nix-gc.serviceConfig = {
      ProgramArguments = [
        "/nix/var/nix/profiles/default/bin/nix-collect-garbage"
        "--delete-older-than"
        "14d"
      ];
      StartCalendarInterval = {
        Weekday = 0;
        Hour = 3;
        Minute = 15;
      };
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };

    nix-store-optimise.serviceConfig = {
      ProgramArguments = [
        "/nix/var/nix/profiles/default/bin/nix"
        "store"
        "optimise"
      ];
      StartCalendarInterval = {
        Weekday = 0;
        Hour = 4;
        Minute = 15;
      };
      StandardOutPath = "/var/log/nix-store-optimise.log";
      StandardErrorPath = "/var/log/nix-store-optimise.log";
    };
  };

  determinateNix.customSettings = {
    eval-cores = 0;

    extra-experimental-features = [
      "build-time-fetch-tree"
      "parallel-eval"
    ];
  };
}
