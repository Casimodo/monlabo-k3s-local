# 🎮 Local RedM server

[Version française](README.md)

RedM is the Cfx multiplayer platform for Red Dead Redemption 2. It lets you build custom game modes and resources using the same general ecosystem as FiveM. This module provides a local RedM server for developing and testing RDR3 scripts.

## How it works

RedM uses the classic Linux FXServer artifact with the `gamename rdr3` command. Docker publishes TCP and UDP only on `127.0.0.1:30122` because standard Kubernetes port forwarding does not support UDP.

The Linux artifact is x86_64, so running it on Apple Silicon uses Docker emulation.

## Prepare the artifact

1. Open the official [Server Download page](https://docs.fivem.net/docs/server-download/).
2. Copy the URL of the recommended Linux FXServer artifact.
3. Create the local configuration:

```bash
cp redm/.env-temp.json redm/.env.json
```

4. Set `serverDownloadUrl`:

```json
{
  "serverDownloadUrl": "OFFICIAL_FXSERVER_LINUX_URL",
  "localPort": 30122,
  "licenseKey": ""
}
```

The configuration enables `sv_lan true`. If a Cfx key is required, place it in `licenseKey`. `.env.json` is ignored by Git and must never be shared when it contains a key.

## 🚀 Install and start

```bash
./redm/deploy.sh
```

## Connect and view logs

```bash
./redm/connect.sh
```

In the RedM console:

```text
connect 127.0.0.1:30122
```

The information API is available at `http://127.0.0.1:30122/info.json`.

## Develop a resource

Edit files under `redm/server-data/resources/k8s-local-dev`, then run:

```bash
./redm/restart.sh
./redm/connect.sh
```

## 🧹 Remove

```bash
./redm/delete.sh
```

Local resources under `server-data` are preserved.

## Troubleshooting

```bash
docker ps -a --filter name=k8s-local-redm
docker logs k8s-local-redm
```
