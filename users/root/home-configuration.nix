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
    sessionVariables = {
      KUBECONFIG = lib.mkIf osConfig.rke2.manager "/etc/rancher/rke2/rke2.yaml";
    };
  };
  programs.k9s.enable = lib.mkIf osConfig.rke2.manager true;
}
