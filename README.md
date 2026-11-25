# aurora-surface-community

[![Build container image](https://github.com/auroraargenti8/aurora-surface-community/actions/workflows/build.yml/badge.svg)](https://github.com/auroraargenti8/aurora-surface-community/actions/workflows/build.yml)

> [!IMPORTANT]
> **Unofficial community image.** Not affiliated with or endorsed by [Universal Blue](https://universal-blue.org/) or the [linux-surface](https://github.com/linux-surface/linux-surface) project. Please do not report problems with this image to them; open an issue here instead.

[Aurora](https://getaurora.dev/) (the KDE desktop from Universal Blue) with the [linux-surface](https://github.com/linux-surface/linux-surface) kernel for Microsoft Surface devices.

Universal Blue no longer publishes Surface images. This repository fills the gap: every day it takes the current official `ghcr.io/ublue-os/aurora:stable`, swaps the stock kernel for the linux-surface one, signs the result and publishes it here. Your Surface then updates automatically, exactly like stock Aurora.

## What is changed compared to Aurora

Only the kernel and what the linux-surface project recommends around it. Everything else is the official Aurora image as published that day.

| | |
|---|---|
| **Added** | the linux-surface package repository; `kernel-surface` with `kernel-surface-modules-extra` (the same extra drivers stock Aurora ships, built for this kernel); `iptsd` (touchscreen and pen daemon); `surface-control` (performance mode and other Surface controls); `libwacom-surface` (touchscreen and pen descriptions for Surface devices, replaces the stock `libwacom`) |
| **Removed** | the stock Fedora kernel, and out-of-tree kernel modules that are built only for it and cannot load on another kernel: `xone` (Xbox wireless adapter), `v4l2loopback` (virtual camera), `openrazer` (Razer peripherals) |
| **Left out on purpose** | `kernel-surface-default-watchdog`: on classic Fedora it keeps the Surface kernel as the boot default, but this image has no other kernel and the tool does not understand the Aurora (ostree) boot layout |

The full recipe is two short files: [`Containerfile`](./Containerfile) and [`build_files/build.sh`](./build_files/build.sh). Changes over time are listed in [`CHANGELOG.md`](./CHANGELOG.md).

## Tested hardware

| Device | Status |
|---|---|
| Surface Laptop 3 (Intel, i5-1035G7) | ✅ used daily by the maintainer |
| Other Surface models | ❓ untested — check the [linux-surface feature matrix](https://github.com/linux-surface/linux-surface/wiki/Supported-Devices-and-Features) for your device. Reports welcome in Issues. |

## Install

### Already running Aurora

```bash
sudo bootc switch ghcr.io/auroraargenti8/aurora-surface-community:latest
systemctl reboot
```

If `bootc switch` refuses because you have layered packages (`rpm-ostree install …`), use rpm-ostree instead — it keeps your layered packages:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/auroraargenti8/aurora-surface-community:latest
systemctl reboot
```

If Secure Boot is enabled on your Surface, read [Secure Boot](#secure-boot) **before** you switch.

After the reboot, check that the Surface kernel is running:

```bash
uname -r    # should end with .surface.fc<NN>.x86_64
```

From now on the image updates by itself, the same way stock Aurora does (`uupd`, daily).

### Coming from Windows on a Surface

> [!NOTE]
> This is a general path, averaged across Surface models. Key combinations and menus differ between models — follow the linked official guides for the details of yours.

1. **⚠️ Back up your data and save your BitLocker recovery key.** Windows on a Surface is usually encrypted with BitLocker. Installing Linux changes the disk; without the recovery key you may lose access to Windows and its files. Microsoft: [Find your BitLocker recovery key](https://support.microsoft.com/en-us/windows/find-your-bitlocker-recovery-key-6b71ad27-0b89-ea08-f143-056f5ab347d6).
2. **Download the official Aurora ISO** from [getaurora.dev](https://getaurora.dev/) and write it to a USB stick (their [documentation](https://docs.getaurora.dev/) explains how).
3. **Boot the Surface from the USB stick.** Microsoft: [Boot Surface from a USB device](https://support.microsoft.com/en-us/surface/boot-surface-from-a-usb-device-fe7a7323-8d1d-823d-be17-9aec89c4f9f5).
4. **Install Aurora** and boot into it once. The stock Aurora kernel already supports the basics of most Surface models (screen, keyboard, touchpad, Wi-Fi), so the installer and the first boot normally work.
5. **⚠️ Take care of Secure Boot before switching** — see [Secure Boot](#secure-boot). Surface devices ship with Secure Boot enabled. Stock Aurora boots with it, but the linux-surface kernel does not until its key is enrolled. Skipping this step leaves you with a Surface that will not start the new image (the previous system is still in the boot menu).
6. **Switch to this image** as in [Already running Aurora](#already-running-aurora).

### Secure Boot

The linux-surface kernel is signed with the linux-surface key, not with the Fedora key. Check the state first:

```bash
mokutil --sb-state
```

If it says `SecureBoot disabled`, nothing else is needed. If it is **enabled**, choose one:

**A. Enroll the linux-surface key (keeps Secure Boot on).** On the running Aurora:

```bash
curl -LO https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.cer
sudo mokutil --import surface.cer
```

`mokutil` asks for a one-time password you make up. Reboot: a blue *MOK management* screen appears — choose **Enroll MOK → Continue → Yes**, enter that password, reboot. Details: [linux-surface wiki → Installation and Setup](https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup).

**B. Disable Secure Boot** in the Surface UEFI settings. Microsoft: [How to use Surface UEFI](https://support.microsoft.com/en-us/surface/how-to-use-surface-uefi-df2c8942-dfa0-859d-4394-95f45eb1c3f9).

## Image tags

| Tag | Meaning |
|---|---|
| `latest` | the newest build — use this |
| `45` | the newest build on Fedora 45 (stays on 45 when Aurora moves to a newer Fedora) |
| `45.20261126` | one specific build (Fedora release + build date) |
| `20261126-<commit>` | one specific build of one specific recipe commit |

About the last 30 builds are kept; older ones are deleted automatically.

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
- Based on the official [ublue-os/image-template](https://github.com/ublue-os/image-template). How the repository is maintained: [`MAINTAINING.md`](./MAINTAINING.md).

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
