#!/bin/bash

VM=ftppxy

virsh dominfo ftppxy > /dev/null 2>&1
if [[ $? -ne 0  ]]; then
   echo "No domain named '$VM' exists; exiting."
   exit 1
fi

if [[ $(virsh domstate $VM) != "shut off" ]]; then
   echo "Forcing $VM off."
   virsh destroy $VM
fi

virsh undefine $VM 

virsh vol-delete --pool images $VM.qcow2

