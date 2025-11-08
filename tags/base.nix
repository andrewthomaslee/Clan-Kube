{
  config,
  pkgs,
  lib,
  ...
}: {
  #-- Settings for all machines --#
  #-- Packages --#
  environment = {
    localBinInPath = true;
    systemPackages = with pkgs; [
      ncurses6
      vim
      git
      rsync
      tree
      htop
    ];
  };

  #-- DONT TOUCH --#
  clan.core.settings.state-version.enable = true;
  nixpkgs.config.allowUnfree = true;
  # Settings
  nix.settings = {
    trusted-users = ["root"];
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    download-buffer-size = 524288000; # 500MB
  };
  # SSH
  services.openssh = {
    enable = pkgs.lib.mkForce true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      LogLevel = "DEBUG";
    };
  };
  services.fail2ban.enable = lib.mkDefault true;
  # Networking
  networking.firewall = {
    enable = lib.mkDefault true;
    pingLimit = "--limit 1/minute --limit-burst 5";
  };
  services.cloud-init = {
    enable = true;
    network.enable = true;
  };
  systemd.network.wait-online.enable = lib.mkForce true;
  #-- DONT TOUCH --#
}
