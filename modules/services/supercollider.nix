{ config, lib, pkgs, ... }:

with lib;
let cfg = config.services.supercollider;

in {
  options.services.supercollider = with types; {
    enable = mkEnableOption "Enable SuperCollider audio synthesis server.";

    port = mkOption {
      type = port;
      description = "Port on which to listen of TCP connections.";
    };

    listen-address = mkOption {
      type = str;
      description =
        "IP address on which to listen for connections. 0.0.0.0 for all addresses.";
      default = "127.0.0.1";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.supercollider = {

      Unit = {
        Description = "SuperCollider Audio Synthesis Server.";
        RestartIfChanged = false;
        WantedBy = "default.target";
      };

      Service = {
        ExecStart =
          "${pkgs.supercollider}/bin/scsynth -t ${cfg.port} -B ${cfg.listen-address}";
        Restart = "on-failure";
      };
    };

    home.sessionVariables = {
      SUPERCOLLIDER_HOST = cfg.listen-address;
      SUPERCOLLIDER_PORT = cfg.port;
    };
  };
}
