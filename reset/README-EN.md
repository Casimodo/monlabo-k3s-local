# 🧹 Reset the local environment

[Version française](README.md)

The Reset module cleans up development services created by this repository. It avoids deleting namespaces and containers one by one. Two cleanup levels are provided to reduce the risk of accidental deletion.

## ✅ Recommended cleanup

```bash
./reset/reset.sh
```

This command removes:

- namespaces labeled `app.kubernetes.io/managed-by=k8s-local`;
- Docker containers carrying the same label.

Kubernetes system namespaces remain available. Local folders such as `server-data` and `nodejs-dev/app` are preserved.

## ⚠️ Complete cleanup of user resources

```bash
./reset/reset.sh --all
```

The script asks you to type exactly `RESET`. It removes all user namespaces, clears the `default` namespace, and removes Docker containers managed by this project.

Protected namespaces are:

- `default`;
- `kube-system`;
- `kube-public`;
- `kube-node-lease`;
- `local-path-storage`.

This command may remove user resources that were not created by this repository. Check first:

```bash
kubectl get namespaces
```

## Remove one service

Prefer the module-specific `delete.sh` script, for example:

```bash
./maria/delete.sh
./rancher/delete.sh
./fivem/delete.sh
```

## 🗑️ Uninstall K3s

Reset does not uninstall K3s, Colima, WSL2, Docker, Helm, or `k9s`. To remove the complete platform, follow the **Uninstall** section in the [macOS](../docs/en/macos.md), [Linux](../docs/en/linux.md), or [Windows](../docs/en/windows.md) guide.
