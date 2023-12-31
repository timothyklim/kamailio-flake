{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.kamailio;
in
{
  options = {
    services.kamailio = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      package = mkOption {
        type = types.package;
        description = ''
          Kamailio package.
        '';
      };

      config = mkOption {
        default = null;
        type = lib.types.nullOr types.path;
        description = ''
          Kamailio kamailio.cfg file.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.kamailio = {
      isSystemUser = true;
      createHome = false;
      group = "kamailio";
      uid = 8771;
    };

    users.groups.kamailio.gid = 8771;

    systemd = {
      tmpfiles.rules = [
        "d /run/kamailio 0775 kamailio kamailio - -"
      ];
      services.kamailio = {
        description = "Kamailio";

        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        wants = [ "network.target" ];

        path = [ cfg.package ];

        serviceConfig = {
          ExecStart =
            let
              config = if cfg.config != null then (toString cfg.config) else "${cfg.package}/etc/kamailio/kamailio.cfg";
            in
            "${cfg.package}/sbin/kamailio -f ${config}";
          User = "kamailio";
          Group = "kamailio";
          WorkingDirectory = cfg.package;
          Type = "simple";
          NotifyAccess = "all";
          StandardOutput = "journal";
          StandardError = "journal";
          Restart = "always";
          RestartSec = 1;

          LimitNOFILE = mkDefault 1048576;

          ReadWriteDirectories = [ "/var/run/kamailio" ];

          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];

          NoNewPrivileges = true;
          ProtectHome = "yes";
          ProtectSystem = "strict";
          ProtectProc = "invisible";
          ProtectKernelTunables = true;
          ProtectControlGroups = true;
          ProtectKernelModules = true;
          PrivateDevices = true;
          SystemCallArchitectures = "native";
        };
        unitConfig = {
          StartLimitIntervalSec = 3;
          StartLimitBurst = 0;
        };
      };
    };
  };
}
