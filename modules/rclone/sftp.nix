{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.sftp;
in {
  options.sftp = {
    enable = lib.mkEnableOption "sftp mount";
    user = lib.mkOption {
      type = lib.types.str;
      description = "Hetzner Storagebox User";
    };
    name = lib.mkOption {
      type = lib.types.str;
      description = "Hetzner Storagebox Name";
      default = "storagebox";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fuse.userAllowOther = true;
    environment.systemPackages = [pkgs.rclone pkgs.fuse3];
    systemd.tmpfiles.rules = [
      "d /var/cache/rclone/${cfg.name} 0750 root root -"
      "f /var/log/rclone-${cfg.name}.log 0640 root root -"
      "d /var/lib/rclone 0750 root root -"
    ];
    systemd.services."rclone-${cfg.name}" = let
      rcloneConfig = pkgs.writeText "rclone.conf" ''
        [${cfg.name}]
        type = sftp
        host = ${cfg.user}.your-storagebox.de
        user = ${cfg.user}
        port = 23
        key_file = ${config.clan.core.vars.generators.openssh.files."ssh.id_ed25519".path}
        shell = unix
      '';
      # To add SSH keys to storagebox use the below command, this will ask for the storagebox password
      # clan vars get [MACHINE] openssh/ssh.id_ed25519.pub | ssh -p23 [USER]@[USER].your-storagebox.de install-ssh-key
    in {
      description = "Rclone mount for Hetzner Storage Box";
      after = ["network-online.target"];
      requires = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
        Restart = "on-failure";
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p /mnt/${cfg.name}"
          "${pkgs.coreutils}/bin/cp ${rcloneConfig} /var/lib/rclone/rclone-${cfg.name}.conf"
        ];
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount ${cfg.name}: /mnt/${cfg.name} \
          --config=/var/lib/rclone/rclone-${cfg.name}.conf \
          --allow-other \
          --log-level=NOTICE \
          --log-file=/var/log/rclone-${cfg.name}.log \
          --buffer-size=512M \
          --checkers=1 \
          --transfers=1 \
          --ftp-concurrency=1 \
          --cache-dir=/var/cache/rclone/${cfg.name} \
          --vfs-cache-mode=full \
          --vfs-cache-max-size=10G \
          --vfs-refresh \
          --daemon
        '';
        ExecStop = "/run/wrappers/bin/fusermount -u /mnt/${cfg.name}";
      };
    };
  };
}
