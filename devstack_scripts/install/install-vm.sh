#
# Create a VM with virt-install

# for command refers to https://www.itfromallangles.com/2011/03/kvm-guests-using-virt-install-to-install-vms-from-a-cd-or-iso-imag/

# Prerequisities
# 1. Storage vm hard-disk
# 2. network
# 3. memory

vnc_url=''
vm_name=''

# create disk
# Advantages for qcow2
#  qcow2 images support compression, snapshots and a few other nice things like
#  growing on demand (thin provisioning, sparse file) and a read only base
#  image. There was a performance overhead but nowdays that is almost negligent.
# qemu-img create -f qcow2 foobar.qcow2 100M
check_disk_img() {
  if [ -z $1 ]
  then
    echo "no image file specified."
    return 1
  fi
  if [ ! -f $1 ]
  then
    qemu-img create -f qcow2 $1 10G
    if [ $? == 0 ]
    then
      return 0
    fi
    return 2
  fi
  return 0
}

# Create vm using virsh-install
install_vm() {
  if [ -z $1 ]
  then
    echo "no vm name specified"
  fi

  NO_AT_BRIDGE=1  virt-install \
      --name $1\
      --memory 10240 \
      --disk $2,size=10 \
      --vcpus 8 \
      --os-type kvm\
      --os-variant generic \
      --network bridge=virbr0 \
      --vnc \
      --cdrom /tmp/ubuntu-17.10.1-server-amd64.iso
}

_get_vnc_name() {
  # argument
  # $1 command line result
  if [ -z "$1" ]
  then
    echo ''
  fi
  name=`echo "$1"| awk -F'-' '{for(i=1;i<NF;i++) print $i}' |awk '/name/{print $2}'`
  echo $name
}

_get_vnc_url() {
  if [ -z "$1" ]
  then
    echo ''
  fi
  url=`echo "$1" | awk -F'-' '{for(i=1;i<NF;i++) print $i}'| awk '/vnc/{print $2}'`
  echo $url
}
# using vncviewr (from tigervnc) for connecting vm
connect_vm() {
    local LIBVIRT_STRS=`ps aux|grep libvirt`
    echo "$LIBVIRT_STRS" | while IFS= read -r line ;
    do
      vm_name=$(_get_vnc_name "$line")
      vnc_url=$(_get_vnc_url "$line")
      if [ $vm_name == $1 ]
      then
        vncviewer -display Xdisplay $vnc_url
      fi
      return 0
    done
    return 1
}

#
# main entrance
## Bug. if DISK stores in /home/david, will have permission issue
DISK="/tmp/vm-disk.qcow2"
VMNAME="OpenStackVM"

check_disk_img $DISK
install_vm  $VMNAME $DISK

connect_vm $VMNAME
exit 0
