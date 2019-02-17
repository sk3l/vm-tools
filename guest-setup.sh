#!/bin/bash

USAGE="usage : guest-setup.sh <name> --img <path> --pool <pool> --disk <path>\
 [--vol <size>] [--vcpu <cpu_cnt>] [--ram <size>] "

if [[ $# -lt 5 ]] || [[ $# -gt 11 ]]; then
   echo $#
   echo $USAGE
   exit 2
fi

KS_FILE="$(readlink -qf $(dirname $0))/guest-ks.cfg"

GUEST_NAME=$1
IMG_PATH=""
POOL_NAME=""
DISK_PATH=""
VOL_SIZE=15
VCPU_CNT=2
RAM_SIZE=2048

ARGS=("$@")
IDX=1
while [[ $IDX -lt $# ]]; do
   if [[ ${ARGS[$IDX]} == "--img" ]]; then
      ((IDX++))
      IMG_PATH=${ARGS[$IDX]}
   elif [[ ${ARGS[$IDX]} == "--pool" ]]; then
      ((IDX++))
      POOL_NAME=${ARGS[$IDX]}
    elif [[ ${ARGS[$IDX]} == "--disk" ]]; then
      ((IDX++))
      DISK_PATH=${ARGS[$IDX]}
   elif [[ ${ARGS[$IDX]} == "--vol" ]]; then
      ((IDX++))
      VOL_SIZE=${ARGS[$IDX]}
   elif [[ ${ARGS[$IDX]} == "--vcpu" ]]; then
      ((IDX++))
      VCPU_CNT=${ARGS[$IDX]}
   elif [[ ${ARGS[$IDX]} == "--ram" ]]; then
      ((IDX++))
      RAM_SIZE=${ARGS[$IDX]}
  else
      echo $USAGE
      exit 2
   fi
   ((IDX++))
done

if [[ "$IMG_PATH" == "" ]]; then
      echo "Image FQN is required."
      echo $USAGE
      exit 2
fi

if [[ "$DISK_PATH" == "" ]]; then
      echo "Disk location FQN is required."
      echo $USAGE
      exit 2
fi

$(virsh vol-info --pool $POOL_NAME $GUEST_NAME.qcow2 > /dev/null 2>&1)
if [[ $?  -ne 0 ]]; then
   echo "Creating volume $GUEST_NAME.qcow2"
   virsh vol-create-as $POOL_NAME $GUEST_NAME.qcow2 "$VOL_SIZE"G --format qcow2
fi

   #--location /var/lib/libvirt/images/CentOS-7-x86_64-Minimal-1611.iso \
   #--disk path=/home/mskelton/.vm/images/$GUEST_NAME.qcow2,sparse=false,bus=virtio,size=15 \

virt-install --virt-type kvm \
   --name $GUEST_NAME \
   --ram $RAM_SIZE \
   --vcpu $VCPU_CNT \
   --location $IMG_PATH \
   --disk path=$DISK_PATH/$GUEST_NAME.qcow2,sparse=false,bus=virtio,size=$VOL_SIZE \
   --nographics \
   --network network=default \
   --os-type linux \
   --os-variant rhel7 \
   --initrd-inject $KS_FILE \
   --noautoconsole \
   --extra-args 'ks=file:/guest-ks.cfg console=ttyS0'
   #--debug

