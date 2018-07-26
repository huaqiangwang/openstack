#
# qemu-system-x86_64

## version 1
## works with default network
#qemu-system-x86_64 -hda /tmp/vm-disk.qcow2 -m 2048 -boot d \
#-enable-kvm -cpu host -smp cores=44 \

## version 2
# bridge network : works
qemu-system-x86_64 -hda /tmp/vm-disk.qcow2 -m 2048 \
    -boot d -enable-kvm -cpu host -smp cores=20 \
    -net nic \
    -net bridge,br=virbr0
