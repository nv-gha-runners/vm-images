# A Dockerfile to build `containerDisk` images for KubeVirt
# see https://kubevirt.io/user-guide/virtual_machines/disks_and_volumes/#containerdisk
FROM scratch
COPY --chown=107:107 output/img.qcow2 /disk/
