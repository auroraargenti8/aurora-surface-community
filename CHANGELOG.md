# Changelog

Changes to the **recipe** of this image. The daily builds themselves are not listed: each one is the official Aurora of that day with the same recipe applied.

Newest first. Dates are UTC.

## 2026-11-26

- **Added** `kernel-surface-modules-extra`. Stock Aurora ships `kernel-modules-extra`; it was removed together with the stock kernel, but its linux-surface counterpart was not installed. Now the image has the same set of extra drivers as Aurora.
- **Added** `libwacom-surface` and `libwacom-surface-data` (replace the stock `libwacom`), as recommended by linux-surface for Fedora: touchscreen and pen descriptions for Surface devices.
- **Left out** `kernel-surface-default-watchdog`. It only matters when a stock kernel is installed next to the Surface kernel (not the case here), and its script looks for kernels in `/boot/vmlinuz-*`, which does not exist on Aurora's ostree layout.
- **Image tags** now include the Fedora release: `45` and `45.<date>`.
- **Registry cleanup:** about the last 30 builds are kept, older versions are deleted automatically.
- **Keepalive:** scheduled runs re-enable the workflow through the GitHub API, so GitHub does not switch off the daily build after 60 days without commits.
- README: install path for Surface owners coming from Windows, Secure Boot section, image tags.

## 2026-11-25

- First release. Official `ghcr.io/ublue-os/aurora:stable` with the stock kernel replaced by `kernel-surface`, plus `iptsd` and `surface-control`. Based on `ublue-os/image-template`, built and signed daily.
