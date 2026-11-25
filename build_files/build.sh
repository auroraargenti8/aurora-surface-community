#!/bin/bash
# Aurora + linux-surface kernel.
# Takes the official Aurora image as is and swaps only the kernel:
# the stock Fedora kernel goes out, the linux-surface kernel goes in.

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to / (empty for now)
cp -avf "/ctx/system_files"/. /

### 1. linux-surface package repository
# https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup#fedora
dnf5 config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo

### 2. Remove the stock kernel and the kernel modules built only for it
# These out-of-tree modules are compiled for the stock kernel and cannot load
# on the linux-surface kernel: Xbox wireless adapter (xone), virtual camera
# (v4l2loopback), Razer peripherals (openrazer).
# Only packages that are actually installed are removed, so the build does not
# break when Aurora adds or drops one of them.
CANDIDATES=(
    kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra
    kmod-xone xone-kmod-common
    kmod-v4l2loopback v4l2loopback
    kmod-openrazer openrazer-kmod-common openrazer-daemon
)
REMOVE=()
for pkg in "${CANDIDATES[@]}"; do
    if rpm -q "$pkg" &>/dev/null; then
        REMOVE+=("$pkg")
    fi
done
dnf5 -y remove "${REMOVE[@]}"

### 3. Install the linux-surface kernel and Surface utilities
# kernel-surface-modules-extra - the extra drivers that stock Aurora ships as
#                                kernel-modules-extra, built for this kernel
# iptsd           - touchscreen and pen daemon
# surface-control - performance mode and other Surface controls
# libwacom-surface - touchscreen and pen descriptions for Surface devices
#                    (replaces the stock libwacom, as linux-surface recommends)
# kernel-surface-default-watchdog is left out on purpose: it keeps the Surface
# kernel as the GRUB default on classic Fedora, but this image has no other
# kernel, and the script does not understand the ostree /boot layout.
dnf5 -y install --allowerasing --exclude=kernel-surface-default-watchdog \
    kernel-surface kernel-surface-modules-extra \
    iptsd surface-control \
    libwacom-surface libwacom-surface-data

### 4. Make sure the new kernel has its initramfs
# The kernel package tries to generate it through rpm-ostree, which can fail
# inside a container build ("Invalid cross-device link"); in that case run
# dracut directly.
KVER="$(rpm -q kernel-surface-core --qf '%{VERSION}-%{RELEASE}.%{ARCH}')"
if [[ ! -f "/usr/lib/modules/${KVER}/initramfs.img" ]]; then
    dracut --no-hostonly --kver "${KVER}" --reproducible --zstd -v --add ostree \
        -f "/usr/lib/modules/${KVER}/initramfs.img"
fi
test -f "/usr/lib/modules/${KVER}/vmlinuz"
test -f "/usr/lib/modules/${KVER}/initramfs.img"

# Drop module directories left behind by the removed stock kernel
# (only directories without a kernel image in them)
for dir in /usr/lib/modules/*/; do
    if [[ "$(basename "$dir")" != "${KVER}" && ! -f "${dir}vmlinuz" ]]; then
        rm -rf "$dir"
    fi
done

dnf5 clean all
