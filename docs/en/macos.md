# 🍎 Install K3s on macOS

[Version française](../macos.md)

This beginner-friendly guide uses Colima, which provides a small Linux virtual machine and starts K3s without Rancher Desktop. Repository commands continue to run from the macOS terminal.

## 🚀 Install

Install Homebrew from [brew.sh](https://brew.sh) if needed, then run:

```bash
brew install colima docker kubectl helm jq derailed/k9s/k9s
colima start --kubernetes --cpus 4 --memory 6 --disk 30
openssl version
```

Colima normally creates a context named `colima`. Rename it to enable the repository safety checks:

```bash
kubectl config rename-context colima k3s-local
kubectl config use-context k3s-local
kubectl cluster-info
```

Verify that the API is local:

```bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
echo
```

The address must use `127.0.0.1` or `localhost`. Then test the repository:

```bash
./scripts/validate.sh
k9s
```

The `connect.sh` commands expose Vault and MariaDB locally on the Mac. A macOS-compatible MariaDB client such as DBeaver or TablePlus can connect directly to `127.0.0.1:3306`. HeidiSQL is a Windows application and is not available natively on macOS.

## Stop and restart

```bash
colima stop
colima start
kubectl config use-context k3s-local
```

## 🧹 Uninstall cleanly

This operation destroys all workloads and volumes in the Colima VM. Run the reset first so project resources are removed cleanly:

```bash
./reset/reset.sh --all
colima delete --force
kubectl config delete-context k3s-local
kubectl config delete-cluster colima
brew uninstall colima docker kubectl helm jq derailed/k9s/k9s
```

The two `kubectl config delete-*` commands may report that an entry no longer exists. This is harmless. You may then remove the repository folder if it is no longer needed.
