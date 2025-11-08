{
  config,
  pkgs,
  pkgs-unstable,
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
  imports = [
    ../../disko/worker.nix
  ];

  programs.bash.interactiveShellInit = ''
    ${motd}/bin/motd
  '';

  k3s.enable = true;

  # K3s
  services.k3s = {
    role = "agent";
    extraFlags = [
      "--node-label=role=worker"
    ];
  };
}
