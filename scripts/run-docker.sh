#!/usr/bin/env bash

# thanks stackoverflow
# https://unix.stackexchange.com/a/634849
# this function doesnt work in zsh for some reason
getdevice() {
    idV=${1%:*}
    idP=${1#*:}
    for path in `find /sys/devices/ -name idVendor | sed 's/idVendor$//'`; do
        if grep -q $idV $path/idVendor && grep -q $idP $path/idProduct; then
            find $path -name 'device' | sed 's/device$//'
        fi
    done
}

device=/dev/$(getdevice 10c4:ea60)

# performance over security /shrug
exec podman --runtime $(which crun) run -a -P --privledged --storage-driver=overlayfs --network host --device $device --rm lidar
