# 🔐 Local Vault

[Version française](README.md)

HashiCorp Vault is a secrets manager used to centralize passwords, tokens, and API keys. This module starts Vault in development mode so beginners can test its web interface and API without using a remote service.

## What this module installs

- Vault 1.20 in the `k8s-local-vault` namespace;
- the Vault web interface;
- a random root token stored in a Kubernetes Secret;
- an HTTP tunnel bound to `127.0.0.1`.

Development mode is not suitable for production. Vault data disappears when the pod is recreated.

## 🚀 Install

```bash
./vault/deploy.sh
```

## Open the interface

```bash
./vault/connect.sh
```

The terminal displays `http://127.0.0.1:8200` and the token. Keep the tunnel open, visit the URL, select **Token**, and enter the displayed token.

`Ctrl+C` closes only the tunnel.

## Use the API

The API uses the same URL. With the tunnel open:

```bash
curl http://127.0.0.1:8200/v1/sys/health
```

## ⚙️ Configure

Copy the template and change the port if needed:

```bash
cp vault/.env-temp.json vault/.env.json
```

```json
{
  "localPort": 8200
}
```

`.env.json` is ignored by Git.

For a temporary override, the environment variable remains available:

```bash
VAULT_LOCAL_PORT=8201 ./vault/connect.sh
```

## 🧹 Remove

```bash
./vault/delete.sh
```

The namespace and all temporary Vault data are removed.

## Troubleshooting

```bash
kubectl get pods -n k8s-local-vault
kubectl logs -n k8s-local-vault deployment/vault
```
