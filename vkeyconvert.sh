#!/bin/bash
echo "copy .vagrant/machines/titanawx-focal/virtualbox/private_key -> titan.titanawx-focal.private_key"
cp .vagrant/machines/titanawx-focal/virtualbox/private_key titan.titanawx-focal.private_key
echo "convert titan.titanawx-focal.private_key -> key_titan-focal-vagrant.ppk"
puttygen titan.titanawx-focal.private_key -o key_titan-focal-vagrant.ppk
echo "copy .vagrant/machines/titan/virtualbox/private_key -> titan.titan.private_key"
cp .vagrant/machines/titan/virtualbox/private_key titan.titan.private_key
echo "convert titan.titan.private_key -> key_titan-vagrant.ppk"
puttygen titan.titan.private_key -o key_titan-vagrant.ppk
