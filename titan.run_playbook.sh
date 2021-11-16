#!/bin/bash

# Install requirements
ansible-galaxy collection install -r ./roles/titan_awx/requirements.yml

# Uncomment this if using vault
# ansible-playbook --vault-password-file ~/.my_ansible_vault ./titan.playbook.yml -i ./titan.inventory

# This version does not use vault
ansible-playbook ./titan.playbook.yml -i ./titan.inventory
