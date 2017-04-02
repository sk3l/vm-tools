#!/bin/bash
VM=ftppxy

$(virsh vol-info --pool images $VM.qcow2 > /dev/null 2>&1)
if [[ $?  -ne 0 ]]; then 
   echo "Creating volume $VM.qcow2"
   virsh vol-create-as images $VM.qcow2 15G --format qcow2
fi


virt-install --virt-type kvm \
   --name $VM \
   --ram 4096 \
   --vcpu 2 \
   --location /var/lib/libvirt/images/CentOS-7-x86_64-Minimal-1611.iso \
   --disk path=/home/mskelton/.vm/images/$VM.qcow2,sparse=false,bus=virtio,size=15 \
   --nographics \
   --network network=default \
   --os-type linux \
   --os-variant rhel7 \
   --initrd-inject /var/lib/libvirt/images/ftppxy-ks.cfg \
   --noautoconsole \
   --extra-args 'ks=file:/ftppxy-ks.cfg console=ttyS0'
   #--debug

