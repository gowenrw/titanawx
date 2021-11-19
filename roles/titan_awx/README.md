Titan_AWX
=========

This role will set up AWX on an Ubuntu focal 20.04 server

Requirements
------------

Currently only supports Ubuntu focal.
The server hardware must have a minimum of:
4 CPUs and 8GB RAM and 20GB of available storage.

This role uses the Ansible Kubernetes Collection
Using v 1.2.1 because of ansible version requirements on focal
Download with this:
ansible-galaxy collection install -r requirements.yml

Role Variables
--------------

Defined in vars/main.yml

Dependencies
------------

None.

License
-------

MIT

Author Information
------------------

Author is @alt_bier
