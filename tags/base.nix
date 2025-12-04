#-- Settings for all machines --#
{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.hostPlatform = "x86_64-linux";
  environment = {
    enableAllTerminfo = true;
    localBinInPath = true;
    #-- Packages --#
    systemPackages = with pkgs; [
      git
      rsync
      tree
      htop
      httpie
      wireguard-tools
    ];
  };
  # -- Programs --#
  programs = {
    mosh.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
  };

  # ---- Nix Settings ---- #
  clan.core.settings.state-version.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    trusted-users = ["root"];
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    download-buffer-size = 524288000; # 500MB
  };
  # ------ SSH ------- #
  services.openssh = {
    enable = pkgs.lib.mkForce true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      LogLevel = "DEBUG";
    };
  };
  # ------ Logging ------- #
  services.below = {
    enable = true;
    compression.enable = true;
    retention = {
      size = 32212254720;
      time = 5256000;
    };
    dirs = {
      log = "/var/log/below";
      store = "/var/lib/below";
    };
    collect = {
      ioStats = true;
      diskStats = true;
      exitStats = true;
    };
  };
  # ------ nix.conf ------- #
  clan.core.vars.generators.nix = {
    share = true;
    prompts = {
      "nix.conf" = {
        persist = true;
        type = "line";
        description = ''
          nix.conf file
        '';
        display.group = "nix";
      };
    };
    files = {"nix.conf" = {mode = "0440";};};
  };
  # move github access token secret file to nix.conf
  systemd.services."nix.conf" = {
    enable = true;
    wantedBy = ["multi-user.target"];
    before = ["home-manager-netsa.service"];
    requiredBy = ["home-manager-netsa.service"];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      ${pkgs.coreutils}/bin/mkdir -p /root/.config/nix
      ${pkgs.coreutils}/bin/install -m 0600 -o root -g root ${config.clan.core.vars.generators.nix.files."nix.conf".path} /root/.config/nix/nix.conf
      ${pkgs.coreutils}/bin/mkdir -p /home/netsa/.config/nix
      ${pkgs.coreutils}/bin/chown -R netsa:users /home/netsa/.config
      ${pkgs.coreutils}/bin/install -m 0600 -o netsa -g users ${config.clan.core.vars.generators.nix.files."nix.conf".path} /home/netsa/.config/nix/nix.conf
    '';
  };
}
