{
  config,
  osConfig,
  lib,
  ...
}: {
  #-- DONT TOUCH --#
  home.username = "netsa";
  home.homeDirectory = "/home/netsa";
  home.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;
  #-- DONT TOUCH --#
  # Bash
  programs.bash = {
    enable = true;
    shellAliases = {};
  };
}
