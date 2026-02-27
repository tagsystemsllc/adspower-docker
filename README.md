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

## Kernels

AdsPower uses versioned browser kernels ("SunBrowser") that map directly to Chrome major versions (e.g. kernel `143` = Chrome 143). Profiles are created with a `browser_kernel_config.version` specifying which kernel to use — but the kernel binary must already be installed.

**Kernel 142** is bundled inside the `.deb` and auto-extracted to `~/.config/adspower_global/cwd_global/chrome_142/` on first start.

**Additional kernels** are pre-installed at image build time via the `EXTRA_KERNELS` build argument (default: `"143"`):

```bash
# Default: pre-install kernel 143 (in addition to the bundled 142)
docker build -t adspower .

# Pre-install multiple extra kernels
docker build --build-arg EXTRA_KERNELS="143 134" -t adspower .

# Skip extra kernels entirely
docker build --build-arg EXTRA_KERNELS="" -t adspower .
```

Each extra kernel adds ~220 MB to the image size.

### How kernel downloads work

AdsPower does not publish direct download URLs for kernel binaries. The URL is obtained at build time by calling AdsPower's internal version API (discovered by unpacking the `.deb` and reverse-engineering `app.asar/dist/main.min.js`):

```
GET https://api-global.adspower.net/client/browser/get-browser-version
      ?type=chrome&kernel=143&system=linux_x64&is_self_refresh=1
```

Response:
```json
{
  "data": {
    "download_url": "https://version.adspower.net/software/browsers/chrome/20251212/SunBrowser-linux-143-20251212.zip",
    "version": "20251222",
    "file_md5": "47A2CD05EFC8C7D59D5080DD21F08C67",
    "kernel": "143",
    "size": "220.08MB"
  }
}
```

The zip is extracted to `~/.config/adspower_global/cwd_global/chrome_<N>/` so AdsPower finds it on startup without any download step.

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
