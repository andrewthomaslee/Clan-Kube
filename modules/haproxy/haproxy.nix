{
  config,
  lib,
  pkgs,
  ...
}: let
  dhparam = pkgs.fetchurl {
    url = "https://ssl-config.mozilla.org/ffdhe2048.txt";
    sha256 = "08dpmhxn8bmmhv7lyd7fxgih2xv4j4xanf5w3pfd0nhqcf2pbxrf";
  };
  cloudflare-ca = pkgs.fetchurl {
    url = "https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem";
    sha256 = "0hxqszqfzsbmgksfm6k0gp0hsx9k1gqx24gakxqv0391wl6fsky1";
  };
in {
  options.haproxy = {
    enable = lib.mkEnableOption "haproxy";
  };

  config = lib.mkIf config.haproxy.enable {
    clan.core.vars.generators."haproxy" = {
      share = true;

      prompts = {
        # netsam.dev is the default cert
        "0.netsam.dev.pem" = {
          persist = true;
          type = "multiline";
          description = ''
            Cert & Key
          '';
          display.group = "haproxy";
        };
        "ai-providers.net.pem" = {
          persist = true;
          type = "multiline";
          description = ''
            Cert & Key
          '';
          display.group = "haproxy";
        };
        "frfropen.ai.pem" = {
          persist = true;
          type = "multiline";
          description = ''
            Cert & Key
          '';
          display.group = "haproxy";
        };
        "andrewlee.cloud.pem" = {
          persist = true;
          type = "multiline";
          description = ''
            Cert & Key
          '';
          display.group = "haproxy";
        };
        "andrewlee.fun.pem" = {
          persist = true;
          type = "multiline";
          description = ''
            Cert & Key
          '';
          display.group = "haproxy";
        };
      };
      files = {
        "0.netsam.dev.pem" = {
          owner = "haproxy";
          group = "haproxy";
        };
        "ai-providers.net.pem" = {
          owner = "haproxy";
          group = "haproxy";
        };
        "frfropen.ai.pem" = {
          owner = "haproxy";
          group = "haproxy";
        };
        "andrewlee.cloud.pem" = {
          owner = "haproxy";
          group = "haproxy";
        };
        "andrewlee.fun.pem" = {
          owner = "haproxy";
          group = "haproxy";
        };
      };
    };

    systemd.services.haproxy = {
      serviceConfig = {
        LimitNOFILE = 2005000;
        PermissionsStartOnly = true;
        ExecStartPre = let
          haproxy-prestart = pkgs.writeShellApplication {
            name = "haproxy-prestart";
            runtimeInputs = [pkgs.rsync pkgs.coreutils];
            text = ''
              # sync certs
              mkdir -p /etc/certs
              rsync -a --delete --exclude haproxy.env /var/run/secrets/vars/haproxy/ /etc/certs/
              chown -R haproxy:haproxy /etc/certs
              chmod 700 /etc/certs
              chmod 400 /etc/certs/*
            '';
          };
        in
          lib.mkBefore [
            "${haproxy-prestart}/bin/haproxy-prestart"
          ];
      };
    };
    services.haproxy = {
      enable = true;
      package = pkgs.haproxy;
      config = ''
        global
            ssl-default-bind-curves X25519:prime256v1:secp384r1
            ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305
            ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
            ssl-default-bind-options prefer-client-ciphers ssl-min-ver TLSv1.2 no-tls-tickets

            ssl-default-server-curves X25519:prime256v1:secp384r1
            ssl-default-server-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305
            ssl-default-server-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
            ssl-default-server-options ssl-min-ver TLSv1.2 no-tls-tickets

            ssl-dh-param-file ${dhparam}

            log /dev/log local0 debug
            maxconn 100000
            stats timeout 30s
            ssl-server-verify none
            ssl-load-extra-del-ext

        defaults
            log global
            timeout client 5s
            timeout connect 5s
            timeout server 5s

        userlist auth_users
            user netsa password $6$7Nnk6dLquD4GZN0B$eOW24Zpo.Tool3tQNN/MYr1PQRxqjMqzsuKpf40OqIKvNqUTMv/V.WXvbWIoPjB8C9vbeogQpFkleoewlzM3e/

        userlist auth_robot
            user robot password $6$Tor5eKF03nDeKSXr$ASpZjNnVbeSeDqw0VLWsvp6f.b9Ql4dHfIsw5C07mv98QP6yWV/ek/jwjEi1nmV21U4vFAEXf.zMtpxEghQlJ.

        cache mycache
            total-max-size 4095
            max-object-size 2047500000
            max-age 3600
            process-vary on
            max-secondary-entries 20

        frontend stats
            mode http
            bind *:8040
            stats enable
            stats refresh 10s
            stats uri /stats
            stats show-modules

        frontend haproxy

            # SSL/TLS
            bind :::80 v4v6 accept-proxy
            bind :::443 v4v6 accept-proxy ssl crt /etc/certs/ verify required ca-file ${cloudflare-ca} alpn h2,http/1.1

            # Middleware & Authentication
            acl is_valid_domain hdr(host) -i netsam.dev
            acl is_valid_domain hdr_end(host) -i .netsam.dev

            acl is_valid_domain hdr(host) -i ai-providers.net
            acl is_valid_domain hdr_end(host) -i .ai-providers.net

            acl is_valid_domain hdr(host) -i frfropen.ai
            acl is_valid_domain hdr_end(host) -i .frfropen.ai

            acl is_valid_domain hdr(host) -i andrewlee.cloud
            acl is_valid_domain hdr_end(host) -i .andrewlee.cloud

            acl is_valid_domain hdr(host) -i andrewlee.fun
            acl is_valid_domain hdr_end(host) -i .andrewlee.fun

            http-request deny if !is_valid_domain

            # Protected domains
            acl is_protected_domain hdr_end(host) -i .netsam.dev
            acl is_robot_domain hdr(host) -i oci.netsam.dev s3.netsam.dev

            http-request auth realm "Robot Protected Area" if is_robot_domain !{ http_auth(auth_robot) }
            http-request auth realm "User Protected Area" if is_protected_domain !is_robot_domain !{ http_auth(auth_users) }

            # Cache
            http-request cache-use mycache if { ssl_fc }

            # Redirects
            redirect scheme https code 301 if !{ ssl_fc }

            # HSTS
            http-response set-header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" if { ssl_fc }

            # Cache
            filter cache mycache
            http-response cache-store mycache if { ssl_fc }

            # Compression Offloading
            filter compression
            compression minsize-res 1400
            compression minsize-req 1400
            compression algo gzip
            compression type text/css text/html text/javascript application/javascript text/plain text/xml application/json
            compression offload

            # Server
            default_backend gateway_api

        backend gateway_api
            mode http
            option tcp-check
            balance roundrobin

            # Forwarded headers
            option forwarded proto host by by_port for
            option forwardfor if-none

            # gateway api
            server gateway localhost:30080 check inter 15s send-proxy-v2 check-reuse-pool
      '';
    };
  };
}
