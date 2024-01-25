# vm-images

This repository contains VM images for NVIDIA's self-hosted runners.

The repository uses Packer to create AMIs for AWS and `qcow2` files for KVM VMs.

The `qcow2` files are then packaged and published as a Docker image for use as a `containerDisk` with KubeVirt ([docs](https://kubevirt.io/user-guide/virtual_machines/disks_and_volumes/#containerdisk)).

All images use the latest Ubuntu Jammy image as their base.

## System Requirements for Building `qcow2` files

Install the following packages:

```sh
sudo apt install qemu-system xorriso cloud-utils
```

## Building `qcow2` Files Locally

Create a `variables.auto.pkrvars.hcl` file and run `packer build`:

```sh
cp ./variables.auto.pkrvars.hcl.sample ./variables.auto.pkrvars.hcl

# build linux kvm image variant
packer build -only="*linux-kvm*" .

# build linux AWS image variant
packer build -only="*linux-aws*" .

# build Windows AWS image variant
packer build -only="*win-aws*" .
```

## Running `qcow2` Files Locally

```sh
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -drive file=output/img.qcow2,media=disk,if=virtio
```
