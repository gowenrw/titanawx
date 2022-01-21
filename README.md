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

In my first attempt I used minikube like I did for the manual install but found some issue with persistence.  So I switched to using the k3s lightweight kubernetes to resolve these.

### Ansible role "titan_awx"

I created the ansible role "titan_awx" for the purpose of installing the latest version of AWX on an Ubuntu focal 20.04 server.

This role does not stand up the Ubuntu server, it just installs on an already provisioned server.

This installation of AWX requires a minimum of 4 CPU's and 8GB RAM and 20GB of available storage.
My test system had 4 CPUs and 8GB of RAM and worked fine.

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
* ./roles/titan/* - a role to setup a simple ansible core platform to use for deploying AWX from
* titan.playbook.yml - the ansible playbook that calls the "titan_awx" role
* titan.inventory - the ansible inventory file I use with the playbook
* titan.run_playbook.sh - a bash script for installing collection and running the playbook
* titan.test.sh - a bash script for testing the inventory file using ansible ping
* xcodecopy.sh - a bash script that copies this code from within a local ansible core control box


## Local collections and galaxy roles hidden

For ease of use I will be storing ansible collections in the local project directory ansible_collections and ansible galaxy roles in the local directory ansible_galaxy.

Since I do not want these stored in my repository the .gitignore file prevents their inclusion.

To ensure I know what I have installed between machines I have created a requirements file to load them again.

This will install galaxy collections:
```
ansible-galaxy collection install -r roles/requirements.yml
```

This will install galaxy roles:
```
ansible-galaxy role install -r roles/requirements.yml
```

## Azure Ansible Galaxy Collection

The Azure Ansible Galaxy Collection is named azcollection ans is available via galaxy.

This can be installed via a requirements.yml file like this one
```
collections:
  - name: azure.azcollection
    version: latest
```

Or it can be installed from the command line
```
ansible-galaxy collection install azure.azcollection
```

In either case you may need to install required python files.
This list of python requirements is listed in a file in the collection named requirements-azure.txt
```
<path-to-your>/ansible_collections/azure/azcollection/requirements-azure.txt
```

You can use pip to install them from this file
```
pip install -r requirements-azure.txt
```

## Azure credentials

Created an azure service principle for ansible.
Will need to pass the following to ansible azure modules
```
AZURE_SUBSCRIPTION_ID=<SubscriptionID>
AZURE_CLIENT_ID=<ApplicationId>
AZURE_SECRET=<Password>
AZURE_TENANT=<TenantID>
```

This can be done via the shell or via a file named ~/.azure/credentials with the following
```
[default]
subscription_id=xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
client_id=xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
secret=xxxxxxxxxxxxxxxxx
tenant=xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```
