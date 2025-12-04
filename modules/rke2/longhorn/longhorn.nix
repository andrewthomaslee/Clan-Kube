{
  lib,
  config,
  pkgs,
  ...
}: let
  motd = pkgs.writeShellApplication {
    name = "motd";
    runtimeInputs = with pkgs; [coreutils gawk procps];
    text = ''
      # --- Color Definitions ---
      RESET='\e[0m'
      BOLD='\e[1m'

      # Regular Colors
      GREEN='\e[0;32m'
      YELLOW='\e[0;33m'
      MAGENTA='\e[0;35m'
      CYAN='\e[0;36m'
      WHITE='\e[0;37m'

      # --- MOTD SCRIPT ---

      # Welcome message - using a Nix variable for the hostname
      echo -e "Welcome $BOLD$MAGENTA$USER$RESET to$BOLD$CYAN ${config.networking.hostName}$RESET 👋"
      echo

      # Header for system info
      echo -e "$BOLD$WHITE  #-- System Information --#  $RESET"

      # Use printf for nice alignment. The format string "%-18s: %s\n" means:
      # %-18s : Left-align the label in a field of 18 characters
      # :      : A literal colon for separation
      # %s     : The value string
      # \n     : A newline

      # System Load
      load=$(cut -d' ' -f1 /proc/loadavg)
      printf "%-18s: $BOLD$YELLOW%s$RESET\n" "System Load" "$load"

      # Disk Usage /
      disk_root_usage=$(df -h / | awk 'NR==2 {print $5 " of " $2}')
      printf "%-18s: $BOLD$GREEN%s$RESET\n" "/" "$disk_root_usage"

      # Disk Usage /boot
      disk_boot_usage=$(df -h /boot | awk 'NR==2 {print $5 " of " $2}')
      printf "%-18s: $BOLD$GREEN%s$RESET\n" "/boot" "$disk_boot_usage"

      # Disk Usage /mnt/local-storage
      disk_local_storage=$(df -h /mnt/local-storage | awk 'NR==2 {print $5 " of " $2}')
      printf "%-18s: $BOLD$GREEN%s$RESET\n" "/mnt/local-storage" "$disk_local_storage"

      # Disk Usage /mnt/longhorn-00
      disk_longhorn_00_usage=$(df -h /mnt/longhorn-00 | awk 'NR==2 {print $5 " of " $2}')
      printf "%-18s: $BOLD$GREEN%s$RESET\n" "/mnt/longhorn-00" "$disk_longhorn_00_usage"

      # Memory Usage
      mem_usage=$(free -m | awk 'NR==2 {printf "%.0f%%", $3*100/$2 }')
      printf "%-18s: $BOLD$CYAN%s$RESET\n" "Memory Usage" "$mem_usage"

      # Processes
      processes=$(ps -e --no-headers | wc -l)
      printf "%-18s: $BOLD$WHITE%s$RESET\n" "Processes" "$processes"

      # Logged in Users
      users_logged_in=$(who | wc -l)
      printf "%-18s: $BOLD$MAGENTA%s$RESET\n" "Users Logged In" "$users_logged_in"
    '';
  };
in {
  options.longhorn = {
    enable = lib.mkEnableOption "enable longhorn";
    disks = {
      longhorn-00.enable = lib.mkEnableOption "enable disk longhorn-00";
    };
  };

  config = lib.mkIf config.longhorn.enable {
    programs.bash.interactiveShellInit = ''
      ${motd}/bin/motd
    '';

    services.openiscsi = {
      enable = true;
      name = "iqn.2016-04.com.open-iscsi:${config.networking.hostName}";
    };
    environment.systemPackages = with pkgs; [
      cifs-utils
      nfs-utils
      nvme-cli
      smartmontools
    ];
    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
    ];

    services.rke2.nodeLabel = ["storage=longhorn"];
  };
}
