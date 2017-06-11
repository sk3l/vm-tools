#!/bin/bash

GUEST=$1

virsh dominfo ftppxy > /dev/null 2>&1
if [[ $? -ne 0  ]]; then
   echo "No domain named '$GUEST' exists; exiting."
   exit 1
fi

if [[ $(virsh domstate $GUEST) != "shut off" ]]; then
   echo "Forcing $GUEST off."
   virsh destroy $GUEST
fi

virsh undefine $GUEST 

virsh vol-delete --pool images $GUEST.qcow2

