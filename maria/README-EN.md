# 🗄️ Local MariaDB

[Version française](README.md)

MariaDB is a relational database management system compatible with MySQL. It stores structured application data and runs SQL queries. This module provides a disposable local database for development and testing without touching a remote database.

## What this module installs

- MariaDB 11.4 in the `k8s-local-maria` namespace;
- a 5 GiB persistent volume;
- a development database and user;
- random passwords stored in a Kubernetes Secret;
- a SQL tunnel bound to `127.0.0.1`.

## 🚀 Install

From the repository root:

```bash
./maria/deploy.sh
```

The first startup may take a few minutes while the image is downloaded. The script can be run again without losing the existing volume or credentials.

## Display credentials

```bash
./maria/credentials.sh
```

The terminal displays the database, user, and passwords. Do not share these values or add them to Git.

## Connect

Open the tunnel and keep the terminal running:

```bash
./maria/connect.sh
```

Configure HeidiSQL, DBeaver, or another SQL client:

| Field | Value |
| --- | --- |
| Type | MariaDB or MySQL TCP/IP |
| Host | `127.0.0.1` |
| Port | `3306` |
| Database | value shown by `credentials.sh` |
| User | value shown by `credentials.sh` |
| Password | value shown by `credentials.sh` |

`Ctrl+C` closes only the tunnel. MariaDB continues running in K3s.

## ⚙️ Customize

`.env-temp.json` lists every configurable value. Copy it before the first deployment:

```bash
cp maria/.env-temp.json maria/.env.json
```

Then edit `.env.json`:

```json
{
  "database": "app",
  "user": "app",
  "localPort": 3306
}
```

`.env.json` stays local and is ignored by Git. Changing the database or user after the Secret has been created requires deleting and recreating the module.

## 🧹 Remove

```bash
./maria/delete.sh
```

This command removes the namespace and persistent volume. All MariaDB data is lost.

## Troubleshooting

If port 3306 is already in use, change `localPort` in `.env.json`.

Inspect the pod with:

```bash
kubectl get pods -n k8s-local-maria
kubectl logs -n k8s-local-maria deployment/mariadb
```
