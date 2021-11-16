# titanawx
titanawx is an Ansible AWX system build that I use for testing

## AWX manual setup on Ubuntu focal

It took several attempts to install AWX manually on Ubuntu focal 20.04

I started with the latest version of AWX using operator on the lightweight kubernetes k3s.  This failed to launch the AWX service after launch of the PostGres database.

Thinking the issue was with k3s and something specific to that lightweight implementation I tried again using a different lightweight kubernetes implementation called minikube with the same results.

Thinking the issue was with the latest version of AWX, I tried again using AWX version 17 which does not use AWX operator but does use kubernetes which I kept as minikube.
This failed with the same exact results.

Digging deep into the AWX installation logs, turning on debug logging I was able to see that there was a conflict with the AWX implementation scripts and the version of kubernetes API.
The AWX implementation calls the kubernetes API and gets a failure returned related to a parameter not being correct.
This was a clear indication that something changed in the latest kubernetes that had not been updated in even the most recent version of AWX.
Since both the lightweight versions of kubernetes I tried earlier pull from the latest k8s code base this change was reflected in both of them.

Finally, knowing what the issue was, I tried the latest version of AWX using operator on a previous version of the minikube lightweight kubernetes.
This worked perfectly.

## AWX automated setup on Ubuntu focal

Having a working manual install I decided to write the automation code to allow this AWX test system to be implemented using ansible.

### Ansible role "titan_awx"

I created the ansible role "titan_awx" for the purpose of installing the latest version of AWX on an Ubuntu focal 20.04 server the same way I did manually.

This role does not stand up the Ubuntu server, it just installs on an already provisioned server.

This installation of AWX requires a minimum of 3vCPU's and 6GB RAM.
My test system had 3 CPUs and 8GB of RAM.

This role uses the Ansible Kubernetes Collection.

I ended up using v 1.2.1 locally because the version of ansible on my control box was 2.9.6
The latest version of community.kubernetes requires ansible v2.9.17 and has issues below that.

You can download v1.2.1 of this collection with this:
ansible-galaxy collection install -r requirements.yml

Or you can download the latest version if your system supports it with this:
ansible-galaxy collection install community.kubernetes

### Playbooks and scripts

I created the following files to help implement AWX using ansible.

* ./roles/titan_awx/* - the role that will install and setup AWX
* titan.playbook.yml - the ansible playbook that calls the "titan_awx" role
* titan.inventory - the ansible inventory file I use with the playbook
* titan.run_playbook.sh - a bash script for installing collection and running the playbook
* xcodecopy.sh - a bash script that copies this code from within a local ansible control box
