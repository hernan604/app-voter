#!/usr/bin/env bash
vagrant box remove ../packer/arch/64/build/web/arch.amd64.virtualbox-web.box
CMD="packer build -only=arch.amd64.virtualbox arch-template.json"
echo EXECUTING: $CMD
$CMD

