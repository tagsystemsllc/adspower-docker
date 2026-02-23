# adspower-docker

This repository builds an AdsPower Docker image.

## Building

```bash
docker build -t adspower .
```

The image is based on `ubuntu:25.10` and downloads the AdsPower `.deb` package from the official website at build time. It includes Xvfb, LXDE, and x11vnc so AdsPower can run headlessly with optional VNC access.

Exposed ports:

- `5900` — VNC
- `50325` — AdsPower API

## Trying it out

A `podman-compose.yml` is provided at the root of the repo:

```bash
podman-compose up -d
```

This starts AdsPower with host networking (so that the dynamic CDP ports are accessible), 2 GB of shared memory for Chrome, and auto-restart enabled.

Connect to the VNC server at `localhost:5900` to see the desktop.

## CI-built image

The image is built automatically on each push to `main` and is available at:

```
ghcr.io/tagsystemsllc/adspower-docker:latest
```

Tags pushed per build: `latest`, `main`, and the commit SHA.
