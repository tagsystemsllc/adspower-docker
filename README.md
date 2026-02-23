# adspower-docker

| | Version |
|---|---|
| Latest (adspower.com) | 7.12.29 |
| This repo | 7.12.29 |

[AdsPower](https://www.adspower.com/) Docker image.

## Building

```bash
docker build -t adspower .
```

The image is based on `ubuntu:25.10` and downloads the AdsPower `.deb` package from the official website at build time. It includes Xvfb, LXDE, and x11vnc so AdsPower can run headlessly with optional VNC access.

Exposed ports:

- `5900` — VNC
- `50325` — AdsPower API

## Trying it out

A `docker-compose.yml` is provided at the root of the repo:

```bash
ADSPOWER_API_KEY=your-key-here docker compose up -d
```

This starts AdsPower with host networking (so that the dynamic CDP ports are accessible), 2 GB of shared memory for Chrome, and auto-restart enabled.

Verify that AdsPower is running:

```bash
curl http://localhost:50325/status
# {"code":0,"msg":"success"}
```

List browser profiles:

```bash
curl "http://localhost:50325/api/v1/user/list?page=1&page_size=10"
```

```json
{
  "code": 0,
  "msg": "Success",
  "data": {
    "list": [
      {
        "name": "my-profile",
        "serial_number": "12",
        "remark": "iOS 15",
        "group_name": "default",
        "user_id": "j82xkp41",
        "ip_country": "",
        "user_proxy_config": { "proxy_soft": "...", "proxy_type": "socks5", "proxy_host": "..." },
        "last_open_time": "1770593412",
        "created_time": "1770591837"
      }
    ],
    "page": 1,
    "page_size": 10
  }
}
```

Connect to the VNC server at `localhost:5900` to see the desktop.

## CI-built image

The image is built automatically on each push to `main` and is available at:

```
ghcr.io/tagsystemsllc/adspower-docker:latest
```

Tags pushed per build: `latest`, `main`, and the commit SHA.

## Contact

If the image is outdated, please send an email to camille@tag-systems.net and I'll take care of it.
