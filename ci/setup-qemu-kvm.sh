#!/bin/bash
# This script sets up QEMU/KVM on the host machine.
set -euo pipefail

case "$(arch)" in
  x86_64)
    QEMU_ARCH=x86
    ;;
  aarch64)
    QEMU_ARCH=arm
    ;;
  *)
    echo "Unsupported architecture: $(arch)"
    exit 1
    ;;
esac

sudo apt update
sudo apt install -y "qemu-system-${QEMU_ARCH}" xorriso
sudo chmod 666 /dev/kvm
