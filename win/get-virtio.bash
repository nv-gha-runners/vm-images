#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit
mkdir local
wget -c -O local/virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso
