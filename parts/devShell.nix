{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    devShells = let
      bash_aliases = pkgs.writeText "bash_aliases" ''
        alias k="kubectl "

        alias k-network-tools="kubectl run -n kube-system -it --rm --image jonlabelle/network-tools network-tools"

        alias fetch-token-and-kubeconfig="nix run .#get-kube-config && nix run .#get-rke2-token && clan vars generate hel-m-0 --generator rke2 --regenerate"

        alias install-hel-m-0="clan machines install hel-m-0 --target-host root@$HEL_M_0 --yes"
        alias install-hel-m-1="clan machines install hel-m-1 --target-host root@$HEL_M_1 --yes"
        alias install-hel-m-2="clan machines install hel-m-2 --target-host root@$HEL_M_2 --yes"
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
        packages =
          [
            longhornctl
            inputs.clan-core.packages.${system}.clan-cli
            inputs.tailscale.packages.${system}.tailscale
          ]
          ++ (with pkgs; [
            tmux
            rsync
            vim
            httpie
            k3s
            rke2_1_34
            cilium-cli
            k9s
            kubernetes-helm
            kompose
            argocd
          ]);
        shellHook = ''
          export REPO_ROOT=$(git rev-parse --show-toplevel)
          export CLAN_DIR=$REPO_ROOT
          export KUBECONFIG=$HOME/.kube/config
          export SHELL=$(which bash)
          if [ -f $REPO_ROOT/.env ]; then
            source $REPO_ROOT/.env
          fi

          source ${bash_aliases}
          source ${complete_alias}/complete_alias
          complete -F _complete_alias k

          # k9s config setup
          export EDITOR=vim
          mkdir -p ~/.config/k9s
          rsync -a ${k9s_config} ~/.config/k9s/config.yaml
        '';
      };
    };
  };
}
