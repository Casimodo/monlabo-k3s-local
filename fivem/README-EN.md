# 🎮 Local FiveM server

[Version française](README.md)

FiveM is a multiplayer platform for Grand Theft Auto V. It lets you create custom game modes and resources using Lua, JavaScript, or C#. This module provides an isolated classic FiveM server for local resource development and testing.

## How it works

FiveM requires TCP and UDP on its game port. Because `kubectl port-forward` does not carry UDP, this module uses local Docker instead of K3s. Both protocols are published only on `127.0.0.1:30120` and are not opened to the local network.

Cfx Linux artifacts are x86_64. On an Apple Silicon Mac, Docker uses emulation and performance may be lower.

## Prepare the artifact

1. Open the official [Server Download page](https://docs.fivem.net/docs/server-download/).
2. Copy the URL of the recommended Linux FiveM artifact.
3. Create the local configuration:

```bash
cp fivem/.env-temp.json fivem/.env.json
```

4. Replace `serverDownloadUrl` in `.env.json`:

```json
{
  "serverDownloadUrl": "OFFICIAL_FIVEM_LINUX_URL",
  "localPort": 30120,
  "licenseKey": ""
}
```

The provided configuration enables `sv_lan true` for local tests without a key. A Cfx key can be placed in `licenseKey` when portal features require one. `.env.json` is ignored by Git and must never be shared when it contains a key.

## 🚀 Install and start

```bash
./fivem/deploy.sh
```

The script builds a local image from the official artifact and starts the container.

## Connect and view logs

```bash
./fivem/connect.sh
```

In the FiveM console:

```text
connect 127.0.0.1:30120
```

The information API is available at `http://127.0.0.1:30120/info.json`.

## Develop a resource

Local files are stored in `fivem/server-data/resources/k8s-local-dev`. After a change:

```bash
./fivem/restart.sh
./fivem/connect.sh
```

The `server-data` folder is mounted directly into the container, so no manual copy is required.

## 🧹 Remove

```bash
./fivem/delete.sh
```

The container is removed, but local resources under `server-data` are preserved.

## Troubleshooting

```bash
docker ps -a --filter name=k8s-local-fivem
docker logs k8s-local-fivem
```
