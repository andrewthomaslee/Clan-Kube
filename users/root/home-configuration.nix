{
  config,
  osConfig,
  lib,
  ...
}: {
  #-- DONT TOUCH --#
  home.username = "root";
  home.homeDirectory = "/root";
  home.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;
  #-- DONT TOUCH --#
  # Bash
  programs.bash = {
    enable = true;
    shellAliases = {};
  };
  # CLI
  programs = {
    yazi.enable = true;
    tmux.enable = true;
  };
}
