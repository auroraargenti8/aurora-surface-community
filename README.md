# aurora-surface-community

[![Build container image](https://github.com/auroraargenti8/aurora-surface-community/actions/workflows/build.yml/badge.svg)](https://github.com/auroraargenti8/aurora-surface-community/actions/workflows/build.yml)

> [!IMPORTANT]
> **Unofficial community image.** Not affiliated with or endorsed by [Universal Blue](https://universal-blue.org/) or the [linux-surface](https://github.com/linux-surface/linux-surface) project. Please do not report problems with this image to them; open an issue here instead.

[Aurora](https://getaurora.dev/) (the KDE desktop from Universal Blue) with the [linux-surface](https://github.com/linux-surface/linux-surface) kernel for Microsoft Surface devices.

Universal Blue no longer publishes Surface images. This repository fills the gap: every day it takes the current official `ghcr.io/ublue-os/aurora:stable`, swaps the stock kernel for the linux-surface one, signs the result and publishes it here. Your Surface then updates automatically, exactly like stock Aurora.

## What is changed compared to Aurora

Only the kernel. Everything else is the official Aurora image as published that day.

| | |
|---|---|
| **Added** | the linux-surface package repository; `kernel-surface`; `iptsd` (touchscreen and pen daemon); `surface-control` (performance mode and other Surface controls) |
| **Removed** | the stock Fedora kernel, and out-of-tree kernel modules that are built only for it and cannot load on another kernel: `xone` (Xbox wireless adapter), `v4l2loopback` (virtual camera), `openrazer` (Razer peripherals) |

The full recipe is two short files: [`Containerfile`](./Containerfile) and [`build_files/build.sh`](./build_files/build.sh).

## Tested hardware

| Device | Status |
|---|---|
| Surface Laptop 3 (Intel, i5-1035G7) | ✅ used daily by the maintainer |
| Other Surface models | ❓ untested — check the [linux-surface feature matrix](https://github.com/linux-surface/linux-surface/wiki/Supported-Devices-and-Features) for your device. Reports welcome in Issues. |

## Install

You need a machine already running Aurora (or another Universal Blue / Fedora Atomic image). Install Aurora first from [getaurora.dev](https://getaurora.dev/), then switch:

```bash
sudo bootc switch ghcr.io/auroraargenti8/aurora-surface-community:latest
systemctl reboot
```

If `bootc switch` refuses because you have layered packages (`rpm-ostree install …`), use rpm-ostree instead — it keeps your layered packages:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/auroraargenti8/aurora-surface-community:latest
systemctl reboot
```

After the reboot, check that the Surface kernel is running:

```bash
uname -r    # should end with .surface.fc<NN>.x86_64
```

From now on the image updates by itself, the same way stock Aurora does (`uupd`, daily).

### Secure Boot

The linux-surface kernel is signed with the linux-surface key, not with the Fedora key. With Secure Boot **enabled** you either enroll the linux-surface key once (see [linux-surface wiki → Secure Boot](https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup)), or disable Secure Boot in the Surface UEFI settings. With Secure Boot disabled nothing extra is needed.

## Go back to stock Aurora

The previous system stays available as a boot entry, so a single bad update can be undone with:

```bash
sudo bootc rollback
systemctl reboot
```

To leave this image for good:

```bash
sudo bootc switch ghcr.io/ublue-os/aurora:stable
systemctl reboot
```

(Stock Aurora comes with the stock Fedora kernel, so Surface-specific hardware support goes away.)

## Verify the signature

Images are signed with [cosign](https://github.com/sigstore/cosign). The public key is [`cosign.pub`](./cosign.pub):

```bash
cosign verify --key cosign.pub ghcr.io/auroraargenti8/aurora-surface-community:latest
```

## How it is built

- [`.github/workflows/build.yml`](./.github/workflows/build.yml) runs every day at 10:05 UTC and on every change to `main`.
- If a build fails (for example, linux-surface has not yet caught up with a new Fedora release), nothing is published and installed systems simply stay on the last good image.
- Based on the official [ublue-os/image-template](https://github.com/ublue-os/image-template).

Build locally:

```bash
just build
```

## Made with AI assistance

This repository was set up and is maintained with the help of an AI assistant (Claude, by Anthropic). Every change is reviewed by the maintainer and the image runs on the maintainer's own Surface. Responsibility for the image is the maintainer's.

## Credits

- [Universal Blue](https://universal-blue.org/) and the [Aurora](https://getaurora.dev/) team — the base image and the image template.
- [linux-surface](https://github.com/linux-surface/linux-surface) — the kernel and Surface tools.

## License

[Apache-2.0](./LICENSE), same as the upstream template.
