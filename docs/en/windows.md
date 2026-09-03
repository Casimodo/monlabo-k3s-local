# 🪟 Install K3s on Windows

[Version française](../windows.md)

K3s does not provide a native Windows server. This beginner-friendly setup runs it inside Ubuntu with WSL2. Repository scripts run in WSL, while web interfaces and HeidiSQL remain accessible from Windows through `127.0.0.1`.

## 🚀 Install WSL2

Run PowerShell as Administrator:

```powershell
wsl --install -d Ubuntu
```

Restart Windows if requested, open Ubuntu, and finish creating the Linux user. Recent WSL versions enable `systemd` by default. Check it inside Ubuntu:

```bash
systemctl is-system-running
```

## Install K3s inside Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y curl git ca-certificates openssl jq docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"
kubectl config rename-context default k3s-local
kubectl config use-context k3s-local
kubectl cluster-info
```

Close and reopen Ubuntu after joining the `docker` group. Docker runs directly inside WSL2 and does not require Docker Desktop.

Install Helm inside Ubuntu to make Rancher Web available:

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get-helm-3
chmod 700 /tmp/get-helm-3
/tmp/get-helm-3
rm /tmp/get-helm-3
```

Clone and use the repository inside the Linux filesystem, preferably under `$HOME` rather than `/mnt/c`:

```bash
git clone <REPOSITORY_URL> "$HOME/k8s-local"
cd "$HOME/k8s-local"
./scripts/validate.sh
```

Running `./maria/connect.sh` inside Ubuntu lets HeidiSQL on Windows use `127.0.0.1:3306`. Likewise, `./vault/connect.sh` makes the interface available in the Windows browser at `http://127.0.0.1:8200`.

## Install k9s

The simplest approach is to install `k9s` on Windows. With Chocolatey or Scoop:

```powershell
choco install k9s
# or
scoop install k9s
```

Then copy the WSL kubeconfig to Windows from PowerShell:

```powershell
New-Item -ItemType Directory -Force "$HOME\.kube" | Out-Null
wsl -d Ubuntu sh -lc 'cat "$HOME/.kube/config"' | Set-Content -Encoding Ascii "$HOME\.kube\config"
k9s --context k3s-local
```

This depends on WSL2 automatic `localhost` forwarding. If Windows `k9s` cannot reach the API, use the official Linux `k9s` archive directly inside Ubuntu.

## 🧹 Uninstall cleanly

Inside Ubuntu:

```bash
./reset/reset.sh --all
sudo /usr/local/bin/k3s-uninstall.sh
sudo rm -f /usr/local/bin/helm
rm -f "$HOME/.kube/config"
```

In PowerShell, remove Windows tools if needed:

```powershell
choco uninstall k9s
Remove-Item -Force "$HOME\.kube\config"
```

To remove the Ubuntu distribution and all of its data after backing up useful files:

```powershell
wsl --shutdown
wsl --unregister Ubuntu
```

You may then delete the repository folder. These steps remove the local cluster and its configuration without leaving an unused WSL distribution behind.
