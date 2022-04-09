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

    socket-activated = mkOption {
      type = bool;
      description =
        "Start the server on demand when a connection is attempted.";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.supercollider = {

      description = "SuperCollider Audio Synthesis Server.";
      restartIfChanged = false;

      serviceConfig = {
        ExecStart =
          "${pkgs.supercollider}/bin/scsynth -t ${cfg.port} -B ${cfg.listen-address}";
        Restart = "on-failure";
      };

      wantedBy = "default.target";
    };

    home.sessionVariables.SUPERCOLLIDER_PORT = cfg.port;
  };
}
