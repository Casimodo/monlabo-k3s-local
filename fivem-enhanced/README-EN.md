# 🎮 Local FiveM Enhanced server

[Version française](README.md)

FiveM for GTA V Enhanced targets the Enhanced edition of Grand Theft Auto V. It uses a separate server artifact and offers specific features, including a development mode. This module lets you test resources for that edition without mixing them with classic FiveM configuration.

## How it works

The server uses local Docker to publish TCP and UDP only on `127.0.0.1:30121`. Its configuration enables `sv_devMode true`, OneSync, and an eight-client limit for development.

The Enhanced Linux artifact is x86_64. On Apple Silicon, it runs through Docker emulation and may be slower.

## Prepare the Enhanced artifact

1. Open the official [Server Download page](https://docs.fivem.net/docs/server-download/).
2. Copy the URL of the **GTA V Enhanced** Linux artifact, which differs from the classic FiveM artifact.
3. Create the local file:

```bash
cp fivem-enhanced/.env-temp.json fivem-enhanced/.env.json
```

4. Set `serverDownloadUrl` in that file:

```json
{
  "serverDownloadUrl": "OFFICIAL_FIVEM_ENHANCED_LINUX_URL",
  "localPort": 30121,
  "licenseKey": ""
}
```

The server uses `sv_lan true`. An optional Cfx key belongs in `licenseKey`. `.env.json` is ignored by Git and must never be shared when it contains a key.

## 🚀 Install and start

```bash
./fivem-enhanced/deploy.sh
```

## Connect and view logs

```bash
./fivem-enhanced/connect.sh
```

In the GTA V Enhanced client console:

```text
connect 127.0.0.1:30121
```

The information API is available at `http://127.0.0.1:30121/info.json`.

## Develop a resource

Edit files under `fivem-enhanced/server-data/resources/k8s-local-dev`, then run:

```bash
./fivem-enhanced/restart.sh
./fivem-enhanced/connect.sh
```

## 🧹 Remove

```bash
./fivem-enhanced/delete.sh
```

The local `server-data` folder is preserved.

## Troubleshooting

```bash
docker ps -a --filter name=k8s-local-fivem-enhanced
docker logs k8s-local-fivem-enhanced
```
