# ⚡ Real-time Node.js server

[Version française](README.md)

Node.js runs JavaScript on the server. Socket.IO adds two-way real-time communication between the browser and server, useful for chats, notifications, or live dashboards. This beginner-friendly module provides a small website ready to edit with automatic reload.

## What this module installs

- Node.js 22 in the `k8s-local-nodejs-dev` namespace;
- Express, Socket.IO, and `nodemon`;
- an example showing the number of connected browsers;
- a synchronized copy of the local `nodejs-dev/app` folder;
- a web tunnel bound to `127.0.0.1`.

## 🚀 Install

```bash
./nodejs-dev/deploy.sh
```

## Open the website

```bash
./nodejs-dev/connect.sh
```

Keep the terminal running, then open `http://127.0.0.1:3000`.

## Develop

The source code is in `nodejs-dev/app`. In a second terminal, watch and synchronize changes:

```bash
./nodejs-dev/sync.sh --watch
```

After a change, files are copied into the pod and `nodemon` restarts Node.js. Stop watching with `Ctrl+C`.

To synchronize once:

```bash
./nodejs-dev/sync.sh
```

## ⚙️ Configure

Copy the configuration template:

```bash
cp nodejs-dev/.env-temp.json nodejs-dev/.env.json
```

```json
{
  "localPort": 3000,
  "syncIntervalSeconds": 2
}
```

`localPort` sets the website port on the computer. `syncIntervalSeconds` sets how often changes are detected. `.env.json` is ignored by Git.

An environment variable can temporarily override the JSON value:

```bash
NODEJS_LOCAL_PORT=3001 ./nodejs-dev/connect.sh
```

## 🧹 Remove

```bash
./nodejs-dev/delete.sh
```

The source code in the local `app` folder is preserved.

## Troubleshooting

```bash
kubectl get pods -n k8s-local-nodejs-dev
kubectl logs -n k8s-local-nodejs-dev deployment/nodejs-dev
```
