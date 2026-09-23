# 🧰 k8s-local

[Version française](README.md)

`k8s-local` provides ready-to-run services for development and testing on your own computer. Web and data services run in a local K3s cluster. FiveM and RedM use local Docker because their clients require UDP.

This project is intended for local development only. Access is bound to `127.0.0.1`, and the proposed settings are not suitable for production.

## 🌱 Beginner-friendly overview

Kubernetes is a system that starts, monitors, and organizes containerized applications. An application is described using YAML files called *manifests*. Kubernetes then creates its containers, network, and storage in a reproducible way.

K3s is a lightweight Kubernetes distribution suitable for a development computer. This repository intentionally hides much of the complexity behind simple scripts: deploy a resource, open local access, and remove it when finished.

The goal is to provide an isolated development environment where you can test a SQL database, an API, a real-time website, or a Kubernetes interface without using a remote server.

## 🚀 Getting started

Install K3s and the required tools by following the guide for your operating system:

- [macOS with Colima](docs/en/macos.md)
- [Linux with native K3s](docs/en/linux.md)
- [Windows with K3s in WSL2](docs/en/windows.md)

The scripts expect a Kubernetes context named `k3s-local` and reject any API server that is not available through `127.0.0.1` or `localhost`.

Then validate the environment:

```bash
./scripts/validate.sh
```

## 📚 Documentation

### Install the platform

| System | Installation and removal |
| --- | --- |
| macOS | [K3s with Colima](docs/en/macos.md) |
| Linux | [Native K3s](docs/en/linux.md) |
| Windows | [K3s in WSL2](docs/en/windows.md) |

### Use a resource

| Resource | Documentation |
| --- | --- |
| MariaDB | [Local database](maria/README-EN.md) |
| Vault | [Local secrets vault](vault/README-EN.md) |
| Node.js | [Real-time website](nodejs-dev/README-EN.md) |
| Rancher Web | [Kubernetes web interface](rancher/README-EN.md) |
| FiveM | [Classic GTA V server](fivem/README-EN.md) |
| FiveM Enhanced | [GTA V Enhanced server](fivem-enhanced/README-EN.md) |
| RedM | [Red Dead Redemption 2 server](redm/README-EN.md) |
| AI Generation | [Local Apple Silicon generation](ai-generation/README-EN.md) |
| Reset | [Environment cleanup](reset/README-EN.md) |

## 🗂️ Repository structure

```text
k8s-local/
├── README.md              French home page and documentation index
├── README-EN.md           English home page and documentation index
├── docs/                  French operating system guides
│   └── en/                English operating system guides
├── scripts/               Shared functions, validation, and Cfx runtime
├── maria/                 MariaDB database and persistent volume
│   └── k8s/               Kubernetes manifests for the module
├── vault/                 Vault secrets manager in development mode
│   └── k8s/               Kubernetes manifests for the module
├── nodejs-dev/            Node.js site, Socket.IO, and source synchronization
│   ├── app/               Local source code to edit
│   └── k8s/               Kubernetes manifests for the module
├── rancher/               Rancher Web interface installed with Helm
├── fivem/                 Classic FiveM server and local resources
│   └── server-data/       Game configuration and scripts to edit
├── fivem-enhanced/        GTA V Enhanced server
│   └── server-data/       Enhanced configuration and scripts
├── redm/                  RedM server for Red Dead Redemption 2
│   └── server-data/       RedM configuration and scripts
├── ai-generation/         Native Apple Silicon image generation
└── reset/                 Selective or complete environment cleanup
```

Each resource folder is self-contained and includes its own commands and README:

- `deploy.sh` installs or updates the resource;
- `connect.sh` opens local access or displays logs;
- `delete.sh` removes the resource;
- `.env-temp.json` lists the configurable service settings;
- `README.md` explains the tool step by step in French;
- `README-EN.md` provides the same guide in English.

The `reset` module has no persistent configuration. Its destructive `--all` option always requires manual confirmation.

## 📦 Resources

| Resource | Purpose | Local access | Documentation |
| --- | --- | --- | --- |
| MariaDB | MySQL-compatible SQL database | `127.0.0.1:3306` | [MariaDB guide](maria/README-EN.md) |
| Vault | Secrets, tokens, and Vault API | `http://127.0.0.1:8200` | [Vault guide](vault/README-EN.md) |
| Node.js | Real-time Socket.IO website | `http://127.0.0.1:3000` | [Node.js guide](nodejs-dev/README-EN.md) |
| Rancher Web | Kubernetes management interface | `https://127.0.0.1.sslip.io:8443` | [Rancher guide](rancher/README-EN.md) |
| FiveM | Classic GTA V development | TCP/UDP `127.0.0.1:30120` | [FiveM guide](fivem/README-EN.md) |
| FiveM Enhanced | GTA V Enhanced development | TCP/UDP `127.0.0.1:30121` | [FiveM Enhanced guide](fivem-enhanced/README-EN.md) |
| RedM | Red Dead Redemption 2 development | TCP/UDP `127.0.0.1:30122` | [RedM guide](redm/README-EN.md) |
| AI Generation | Local images with MLX and MFLUX | `http://127.0.0.1:8180` | [AI Generation guide](ai-generation/README-EN.md) |
| Reset | Environment cleanup | not applicable | [Reset guide](reset/README-EN.md) |

## ⚙️ JSON configuration

A resource works with its default values without creating a configuration file. To customize it, copy its template:

```bash
cp maria/.env-temp.json maria/.env.json
```

Then edit `.env.json`. The template contains simple JSON:

```json
{
  "database": "app",
  "user": "app",
  "localPort": 3306
}
```

`.env.json` is ignored by Git. It may contain a local key and must not be shared. Environment variables take priority when a temporary override is needed.

## 🧹 Remove everything cleanly

Removal is performed in two steps:

1. [Reset](reset/README-EN.md) removes the services, namespaces, volumes, and containers created for testing.
2. The operating system guide then removes K3s, Colima or WSL2, Docker, Helm, `kubectl`, `k9s`, and the related configuration files.

Start with:

```bash
./reset/reset.sh --all
```

Then follow the **Uninstall** section in the [macOS](docs/en/macos.md), [Linux](docs/en/linux.md), or [Windows](docs/en/windows.md) guide. These steps are designed to avoid leaving an unused cluster, volume, or local configuration behind.

## 🔒 Local safety

Before any Kubernetes operation, the scripts verify:

- the explicit kubeconfig file;
- the `k3s-local` context;
- a local Kubernetes API address;
- actual cluster availability.

Cfx modules also reject remote Docker contexts. AI Generation rejects every bind address except `127.0.0.1` or `localhost`. Every tunnel and published port listens only on the local interface.
