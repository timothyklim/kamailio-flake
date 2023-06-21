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
          Lamailio package.
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
      services.kamailio = {
        description = "Kamailio";

        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        wants = [ "network.target" ];

        path = [ cfg.package ];

        serviceConfig = {
          ExecStart = "${cfg.package}/sbin/kamailio -f ${cfg.package}/etc/kamailio/kamailio.cfg";
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

          ReadWriteDirectories = [ cfg.persistedDir ];

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
