# AI Generation Lab

[Version française](README.md)

This module generates images locally with the Apple Silicon GPU. The API and Web UI run directly on macOS, outside K3s and Colima, so MLX can use Metal. Prompts and results are not sent to a remote AI API.

> This is a local development lab, not a production setup.

## What the module installs

- a FastAPI server bound only to `127.0.0.1`;
- a Web UI and local gallery;
- MFLUX 0.20 with 8-bit `Tongyi-MAI/Z-Image-Turbo`;
- a local queue with one concurrent generation by default;
- an isolated Python environment in `.venv`.

The model is downloaded from Hugging Face on the first generation and inference then runs locally. Video generation remains disabled until a reliable engine is validated on this machine.

## 1. Installation

Requirements: an Apple Silicon Mac, macOS, Python 3.10 or newer, and Internet access for the initial installation.

```bash
cd ai-generation
./deploy.sh
```

## 2. First start

```bash
./connect.sh
```

- Web: `http://127.0.0.1:8180`
- API: `http://127.0.0.1:8180/api`
- Health: `http://127.0.0.1:8180/api/health`

## 3. First generation

Enter a prompt in the **IMAGE** tab, keep `1024 × 1024` and 9 steps, then select **Generate image**. The first request downloads the model. Z-Image-Turbo does not use negative prompts, so that field is intentionally disabled.

The API is asynchronous: `POST /api/images/generate` returns an ID and `GET /api/jobs/{id}` reports `queued`, `running`, `completed`, or `failed`.

## 4. Output location

PNG files and JSON metadata are stored in `outputs/images/`. They survive a normal stop and are never stored as base64 in a database.

## 5. Change the model

```bash
cp .env-temp.json .env.json
```

Only `Tongyi-MAI/Z-Image-Turbo` is currently exposed. The internal provider abstraction supports future engines, but undeclared models are rejected. The host can only be `127.0.0.1` or `localhost`. Image dimensions must be multiples of 16 between 256 and 2048.

## 6. Stop

```bash
./delete.sh
```

This preserves the Python environment, model cache, and generated files.

## 7. Restart

```bash
./deploy.sh
```

## 8. Uninstall

```bash
./delete.sh --all
```

You must type `DELETE` before outputs are removed. The global Hugging Face cache is not deleted automatically.

## 9. Troubleshooting

```bash
tail -f .runtime/server.log
```

- A slow first render usually means the model is downloading.
- For memory pressure, close heavy applications, reduce dimensions, keep 8-bit quantization, and keep one concurrent job.
- Change `port` in `.env.json` if 8180 is busy.
- Run `./delete.sh` then `./deploy.sh` if a stale process remains.

## REST API

The API provides `/api/health`, `/api/models`, image generation and listing routes, `/api/jobs/{id}`, and video routes that clearly return 501 while video is disabled.

A K3s application cannot use `127.0.0.1` to reach the Mac because it refers to the pod. A future integration must use an explicitly configured Colima host route or dedicated local proxy. This module does not change the lab's global network.

## Tests

```bash
.venv/bin/python -m pytest -q
```

Tests use a mock provider and do not download a model.