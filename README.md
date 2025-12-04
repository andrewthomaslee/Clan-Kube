Blog --> [☸️Kubernetes on Bare Metal⚙️](https://blog.andrewlee.fun/post/kubernetes_on_bare_metal/)

# The Dream Setup 💤
Ever thought 🤔💭
- "I want `Cattle not Pets`"
- "I want TRUELY `Reproducible` Infrastructure"
- "I want `Infrastructure as Code`"
- "I want OS `Rollbacks`"

Look no further!

All you have to do is ***Learn Nix***🐇🕳️

At the end of the day **`NixOS`** is just Linux built from source by a bunch bash scripts.

# 🚜RKE2 on NixOS❄️
Host OS Features:
- `Tailscale` for VPN
- `HAProxy` for TLS termination + `keepalived` for load balancing

Cluster Features:
- `Cilium` for networking with Kube-Proxy replacement
- `Traefik` for ingress with Gateway API
- `Longhorn` for persistent storage

## Cluster Architecture 🗺️
![RKE2-Infra](img/RKE2-Infra.png)



## 🔍 Flake Inspection
Hit a `nix flake show github:andrewthomaslee/Clan-Kube` to display the outputs of the `flake.nix` file. Observe the `nixosConfigurations` attribute. These are the three machines this flake builds.

```bash
$ nix flake show
nixosConfigurations
├── hel-m-0
├── hel-m-1
└── hel-m-2
```
Three "manager" nodes somewhere in Helsinki.

`hel-m-0` is the init node. This node differs only three ways:
- Creates the join token
- Initializes the cluster
- Is highest priority `keepalived`

## Zero to Cluster in 3, 2, 1 🚀
Prerequisites:
- 3 machines with ssh
- nix cli with flakes

Enter the dev shell to gain access to the  [Clan.lol](https://clan.lol)  cli and other tools like `k9s`, `kubectl`, `helm`, `rke2`, etc.
```bash
$ git clone https://github.com/andrewthomaslee/Clan-Kube
$ cd Clan-Kube
$ nix develop
```

For all three machines intialize the hardware facts.
```bash
$ clan machines init-hardware-config [MACHINE] --target-host myuser@<IP>
```

To finish the installation, start the init node and copy the token then start the rest.
```bash
$ clan machines install hel-m-0 --target-host root@<IP>
$ fetch-token-and-kubeconfig
$ clan machines install hel-m-1 --target-host root@<IP>
$ clan machines install hel-m-2 --target-host root@<IP>
```

###### *Disclaimer for Prerequisites
- VPN is `Tailscale` so an account or self hosted `Headscale` is required. Edit *`modules/tailscale`* but just use the free tier of `Tailscale`.
- HAProxy has mTLS with `Cloudflare Origin Certs`. Disable mTLS & change the certs in *`modules/haproxy`*.
- Assumes `IPv4` & `IPv6` & `Hetzner vSwitch` is used. Edit *`modules/network`* & *`modules/rke2`*.
- Assumes `x86_64-linux`. Edit `flake.nix` systems attribute.
- Assumes `2 NVME` drives. Edit *`modules/disko`* & *`modules/rke2/longhorn`*
- Assumes `L4 Load Balancer` pointing to each node on port *80* & *443*. Edit *`modules/haproxy`* & *`modules/keepalived`*
- Edit the public `ssh key` in *`users`* & *`clan.nix`*




