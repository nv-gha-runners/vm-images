# packer-templates

This repository contains VM images for NVIDIA's self-hosted runners.

The repository uses Packer to create AMIs for AWS and `qcow2` files for KVM VMs.

The `qcow2` files are then packaged and published as a Docker image for use as a `containerDisk` with KubeVirt ([docs](https://kubevirt.io/user-guide/virtual_machines/disks_and_volumes/#containerdisk)).

All images use the latest Ubuntu LTS image as their base.
