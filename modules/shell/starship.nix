{
  lib,
  config,
  pkgs,
  ...
}: {
  options.starship = {
    enable = lib.mkEnableOption "starship prompt";
  };

  config = lib.mkIf config.starship.enable {
    programs.starship = {
      enable = true;
      settings = {
        aws.disabled = true;
        gcloud.disabled = true;
        kubernetes = {
          disabled = false;
          detect_env_vars = ["KUBECONFIG"];
        };
        git_branch.style = "242";
        directory.style = "bold blue";
        directory.truncate_to_repo = true;
        directory.truncation_length = 10;
        python.disabled = false;
        ruby.disabled = true;
        hostname.ssh_only = false;
        hostname.style = "bold green";
      };
    };
  };
}
