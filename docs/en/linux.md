# 💻 Install K3s on Linux

[Version française](../linux.md)

This beginner-friendly guide targets a Linux distribution using `systemd`. K3s also installs `kubectl` and the local `local-path` StorageClass used by persistent volumes.

## 🚀 Install

```bash
# Debian and Ubuntu
sudo apt-get update
sudo apt-get install -y curl git ca-certificates openssl jq

# Fedora: use this instead of the two commands above
sudo dnf install -y curl git ca-certificates openssl jq

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
```

Install Helm to make Rancher Web available:

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get-helm-3
chmod 700 /tmp/get-helm-3
/tmp/get-helm-3
rm /tmp/get-helm-3
```

To use FiveM or RedM, install a local Docker engine as well. On Debian or Ubuntu:

```bash
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

Log out and back in after joining the `docker` group. For other distributions, follow the official [Docker Engine installation guide](https://docs.docker.com/engine/install/).

Traefik is disabled because the local modules use loopback tunnels and do not require an Ingress controller.

Create a personal kubeconfig and an explicit context:

```bash
mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"
kubectl config rename-context default k3s-local
kubectl config use-context k3s-local
kubectl cluster-info
```

The server address in this file must remain `https://127.0.0.1:6443`.

Install `k9s` with a package manager available on your distribution, for example:

```bash
# Arch Linux
sudo pacman -S k9s

# Linuxbrew
brew install derailed/k9s/k9s
```

Ready-to-use Linux archives are also published in the official [k9s releases](https://github.com/derailed/k9s/releases). Then verify the setup:

```bash
./scripts/validate.sh
k9s
```

## 🧹 Uninstall cleanly

The official uninstall script removes K3s, its workloads, volumes, and local data:

```bash
./reset/reset.sh --all
sudo /usr/local/bin/k3s-uninstall.sh
sudo rm -f /usr/local/bin/helm
rm -f "$HOME/.kube/config"
```

Remove Docker and `k9s` with the package manager used for installation if they are no longer needed. You may then delete the repository folder.
