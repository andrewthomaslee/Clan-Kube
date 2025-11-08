# Kubernetes on NixOS ☸️❄️

This project delivers 2 fully reproducible, highly available K3s Kubernetes clusters on NixOS, leveraging Hetzner Cloud and Clan.lol. It champions an Infrastructure as Code approach, treating cloud VMs as disposable "cattle" to achieve significant cost savings (up to 10x) and robust resilience.

---

## Key Features

*   **Declarative Management:** 🤖 Clan.lol orchestrates machines as "cattle, not pets" via a powerful tagging system.
*   **Immutable Infrastructure:** 🛠️ Built with NixOS for perfect reproducibility and reliability.
*   **Dual Clusters:** 👯 Separate Dev and Prod environments for safe development and deployment.
*   **High Availability & Zone Failure Resilience:** 🌍 Designed to withstand Hetzner zone failures, ensuring continuous operation.
*   **Cost Optimization:** 💰 Achieved a 10x reduction in cloud bills through efficient management.
*   **VPN:** 🌐 Tailscale VPN for seamless remote access and K8s API load balancing.
*   **Longhorn:** 💾 Longhorn is a distributed block storage system for Kubernetes.
*   **ArgoCD:** 🐙 ArgoCD for GitOps deployments and continuous delivery.
*   **Keepalived:** 🔄 Keepalived for high availability and network redundancy.
*   **Traefik:** 🚦 Traefik for load balancing and TLS.
*   **K9s:** 🐶 K9s for interactive terminal access.

---

## Skills Demonstrated

*   Infrastructure as Code
*   Kubernetes Administration
*   Cloud Infrastructure Management
*   System & Network Administration

---

## Technology Stack

Kubernetes, K3s, NixOS, Hetzner, Clan.lol, Nix Flakes, Tailscale, K9s, ArgoCD, Helm, Keepalived, Longhorn, Traefik, Rclone, NAT64
