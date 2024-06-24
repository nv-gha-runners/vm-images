# vm-images

This repository contains VM images for NVIDIA's self-hosted runners.

The repository uses Packer to create AMIs for AWS and `qcow2` files for VMs.

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

# build linux qemu image variant
packer build -parallel-builds=1 -only="*linux-qemu*" .

# build linux AWS image variant
packer build -parallel-builds=1 -only="*linux-aws*" .

# build Windows AWS image variant
packer build -parallel-builds=1 -only="*windows-aws*" .

# build Windows qemu image variant
packer build -parallel-builds=1 -only="*windows-qemu*" .
```

## Running `qcow2` Files Locally

```sh
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -drive file=output/img.qcow2,media=disk,if=virtio
```

To populate the `jitconfig` file and test the runner service, run the following commands:

```sh
# First, copy the sample files and populate a user-data file with a token:
cp test/linux-init/user-data.sample test/linux-init/user-data
cp test/windows-init/user-data.sample test/windows-init/user-data

# If running Linux, generate a cloud-init image:
cloud-localds test-init.iso test/linux-init/{user,meta}-data

# If running Windows, generate a cloudbase-init image:
cloud-localds test-init.iso test/windows-init/{user,meta}-data

# Then start the VM with the init image:
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -drive file=output/img.qcow2,media=disk,if=virtio \
    -cdrom test-init.iso

# Using `--nographic` will instruct `qemu` to print the output to stdout.
# This is useful to inspect the VM output since our images are programmed to
# shutdown if no token is present.
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -drive file=output/img.qcow2,media=disk,if=virtio \
    -cdrom test-init.iso \
    --nographic
```
