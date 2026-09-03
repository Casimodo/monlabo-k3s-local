# 🖥️ Local Rancher Web

[Version française](README.md)

Rancher is a Kubernetes management web interface. It lets beginners inspect namespaces, pods, deployments, logs, and other resources from a browser. This module installs **Rancher Web inside K3s** only; it does not install Rancher Desktop.

Rancher is heavier than `kubectl` or `k9s`. It is optional and useful when you prefer a graphical interface to discover or inspect Kubernetes.

## What this module installs

- Rancher `2.15.1` using the official Helm chart;
- one replica in `k8s-local-rancher`;
- no additional Ingress, Traefik, or cert-manager;
- a random bootstrap password in a Kubernetes Secret;
- HTTPS access bound to `127.0.0.1`.

Allow at least 4 CPUs and 6 GiB of memory for the local K3s machine or VM.

## Prerequisites

Check Helm:

```bash
helm version
```

Installation is explained in the [macOS](../docs/en/macos.md), [Linux](../docs/en/linux.md), and [Windows](../docs/en/windows.md) guides.

## 🚀 Install

```bash
./rancher/deploy.sh
```

The download and first startup may take several minutes. The chart is pinned to the version in `.env-temp.json`.

## Display credentials

```bash
./rancher/credentials.sh
```

The initial user is `admin`. The displayed password is used for the first login only; Rancher then asks you to set a new one.

## Open the interface

```bash
./rancher/connect.sh
```

Keep the terminal running and visit `https://127.0.0.1.sslip.io:8443`. The certificate is self-signed for local development, so the browser may display a warning that must be accepted explicitly.

`Ctrl+C` closes the tunnel without stopping Rancher.

## ⚙️ Customize

```bash
cp rancher/.env-temp.json rancher/.env.json
```

```json
{
  "localPort": 8443,
  "chartVersion": "2.15.1",
  "hostname": "127.0.0.1.sslip.io",
  "replicas": 1
}
```

This file changes the local port, chart version, hostname, and replica count. Check K3s compatibility before changing the Rancher version. `.env.json` is ignored by Git.

## 🧹 Remove

```bash
./rancher/delete.sh
```

The Helm release and Rancher namespace are removed. Other modules remain active.

## Troubleshooting

```bash
kubectl get pods -n k8s-local-rancher
kubectl logs -n k8s-local-rancher deployment/rancher
helm status rancher -n k8s-local-rancher
```
