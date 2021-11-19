#!/bin/bash

# Perform Ansible Ping on all inventory hosts
ansible -i ./titan.inventory all -m ping
