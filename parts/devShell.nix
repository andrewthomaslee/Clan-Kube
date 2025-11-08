{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    devShells = let
      bash_aliases = pkgs.writeText "bash_aliases" ''
        alias kd="kubectl --kubeconfig ~/.kube/dev"
        alias kp="kubectl --kubeconfig ~/.kube/prod"

        alias k9d="k9s --kubeconfig ~/.kube/dev"
        alias k9p="k9s --kubeconfig ~/.kube/prod"

        alias hd="helm --kubeconfig ~/.kube/dev"
        alias hp="helm --kubeconfig ~/.kube/prod"

        alias ld="longhornctl --kubeconfig=$HOME/.kube/dev"
        alias lp="longhornctl --kubeconfig=$HOME/.kube/prod"

        alias kd-network-tools="kd run -it --rm --image jonlabelle/network-tools network-tools"
        alias kp-network-tools="kp run -it --rm --image jonlabelle/network-tools network-tools"
      '';
      k9s_config = pkgs.writeText "config.yaml" ''
        k9s:
          liveViewAutoRefresh: false
          gpuVendors: {}
          screenDumpDir: /tmp/k9s/screen-dumps
          refreshRate: 2
          apiServerTimeout: 45s
          maxConnRetry: 5
          readOnly: false
          noExitOnCtrlC: false
          portForwardAddress: localhost
          ui:
            enableMouse: true
            headless: true
            logoless: false
            crumbsless: false
            splashless: true
            reactive: false
            noIcons: false
            defaultsToFullScreen: false
            useFullGVRTitle: false
          skipLatestRevCheck: false
          disablePodCounting: false
          shellPod:
            image: busybox:1.35.0
            namespace: default
            limits:
              cpu: 100m
              memory: 100Mi
          imageScans:
            enable: false
            exclusions:
              namespaces: []
              labels: {}
          logger:
            tail: 100
            buffer: 5000
            sinceSeconds: -1
            textWrap: false
            disableAutoscroll: false
            showTime: false
          thresholds:
            cpu:
              critical: 90
              warn: 70
            memory:
              critical: 90
              warn: 70
          defaultView: ""
      '';
      complete_alias = builtins.fetchGit {
        url = "https://github.com/cykerway/complete-alias.git";
        ref = "master";
        rev = "7f2555c2fe7a1f248ed2d4301e46c8eebcbbc4e2";
      };
      hcloud-ip = pkgs.stdenv.mkDerivation {
        name = "hcloud-ip-linux64";
        src = pkgs.fetchurl {
          url = "https://github.com/FootprintDev/hcloud-ip/releases/download/v0.0.1/hcloud-ip-linux64";
          sha256 = "0dvl3qp4cvx994b5jkl7x99fpn5b1vh1gpbja7cdsixmgjyrgc2r";
        };
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/hcloud-ip
          chmod +x $out/bin/hcloud-ip
        '';
      };
      longhornctl = pkgs.stdenv.mkDerivation {
        name = "longhornctl";
        src = pkgs.fetchurl {
          url = "https://github.com/longhorn/cli/releases/download/v1.10.0/longhornctl-linux-amd64";
          sha256 = "0jdcfys7hxzshnsf36hzab4sqmly8n6fkqw1w64651nd19hd3fxn";
        };
        unpackPhase = "true";
        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/longhornctl
          chmod +x $out/bin/longhornctl
        '';
      };
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [bash];
        packages = with pkgs;
          [
            hcloud-ip
            longhornctl
            inputs.clan-core.packages.${system}.clan-cli
            tmux
            rsync
            vim
            openiscsi
          ]
          ++ (with inputs.nixpkgs-unstable.legacyPackages.${system}; [
            tailscale
            k3s
            k9s
            kubernetes-helm
            kompose
            argocd
          ]);
        shellHook = ''
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          export CLAN_DIR=$REPO_ROOT
          export SHELL=$(which bash)
          if [ -f $REPO_ROOT/.env ]; then
            source $REPO_ROOT/.env
          fi

          source ${bash_aliases}
          source ${complete_alias}/complete_alias
          complete -F _complete_alias hd
          complete -F _complete_alias hp
          complete -F _complete_alias kd
          complete -F _complete_alias kp

          # k9s config setup
          export EDITOR=vim
          mkdir -p ~/.config/k9s
          rsync -a ${k9s_config} ~/.config/k9s/config.yaml
        '';
      };
    };
  };
}
