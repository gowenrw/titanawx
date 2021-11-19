# AWX Operator

This is the new way AWX wants to install for x18+ using AWX operator and k8s

I could not get this to work on Ubuntu no matter what I tried so I tried the
older AWX 17 and eventually got that to work.

However, I realized that the earlier issues I was having were related to
API template issues in the latest version of k8s.

So fixed that by using a previous version of kubernetes and continued with latest version of AWX.

Keeping these notes in case they are helpful later.

## Ubuntu focal setup

---------- FIRST ATTEMPT USING AWS 17 WITHOUT OPERATOR ----------
********************************************************************************

### Basics and Prerequisites

Update and reboot
```
sudo apt update && sudo apt -y upgrade
sudo reboot
```

Install some basic packages
```
sudo apt update && sudo apt -y install ansible git build-essential curl jq net-tools python3-virtualenv python3-pip
```

### Docker Install

Install Docker
```
sudo apt-get update -y &&  sudo apt-get install -y docker.io
```

Install Docker Python Module
```
sudo pip install docker
```

Install ansible-galaxy docker collection as user and as root
```
ansible-galaxy collection install community.docker && sudo ansible-galaxy collection install community.docker
```

Add user to docker group
```
sudo usermod -aG docker $USER
```

Log out and in again for the group change to take effect

### Kubernetes Install

Download kubectl
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

Install kubectl
```
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
```

Test it is working
```
kubectl version --client
```

Install minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

Start minikube which will install kubernetes
```
minikube start --addons=ingress --cpus=3 --cni=flannel --install-addons=true \ --kubernetes-version=stable --memory=6g --wait=false
```

When it completes you should see something like this
```
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Check everything is working with
```
kubectl get pods -A
kubectl get nodes
kubectl version --short
```

We should see something like this
```
$ kubectl get pods -A
NAMESPACE       NAME                                        READY   STATUS      RESTARTS      AGE
ingress-nginx   ingress-nginx-admission-create--1-svz4d     0/1     Completed   0             20m
ingress-nginx   ingress-nginx-admission-patch--1-7497r      0/1     Completed   1             20m
ingress-nginx   ingress-nginx-controller-5f66978484-lxhxm   1/1     Running     0             20m
kube-system     coredns-78fcd69978-7lz4g                    1/1     Running     0             20m
kube-system     etcd-minikube                               1/1     Running     0             20m
kube-system     kube-apiserver-minikube                     1/1     Running     0             20m
kube-system     kube-controller-manager-minikube            1/1     Running     0             20m
kube-system     kube-flannel-ds-amd64-p72nw                 1/1     Running     0             20m
kube-system     kube-proxy-q4nfd                            1/1     Running     0             20m
kube-system     kube-scheduler-minikube                     1/1     Running     0             20m
kube-system     storage-provisioner                         1/1     Running     1 (19m ago)   20m
$ kubectl get nodes
NAME       STATUS   ROLES                  AGE   VERSION
minikube   Ready    control-plane,master   20m   v1.22.3
$ kubectl version --short
Client Version: v1.22.3
Server Version: v1.22.3
```

Show configured values such as context that will be needed later
```
kubectl config view
```

Download and install helm 3.7.1
```
curl -o /tmp/helm-linux-amd64.tar.gz -LO "https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz" && tar xvfz /tmp/helm-linux-amd64.tar.gz -C /tmp && sudo install -o root -g root -m 0755 /tmp/linux-amd64/helm /usr/local/bin/helm
```

Test it is working
```
helm version
```

Add helm repositories
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Make sure that the repo downloaded correctly by searching for PostGres in this command output
```
helm search repo bitnami
```

### AWX Download and Setup

Clone the AWX Repo stable branch that we want to use (In this case 17.0.1)
```
git clone -b 17.0.1 https://github.com/ansible/awx.git && cd awx
```

Edit the installer inventory file to update the kubernetes context and namespace and admin_password
```
vim installer/inventory

Find this section:
# Kubernetes Install

Add these lines:
kubernetes_context=minikube
kubernetes_namespace=awx

Find this section:
admin_user=admin

Uncomment this line and change the password value:
admin_password=password
```

### AWX Installer

Run the installer
```
cd awx/installer
ansible-playbook -i inventory install.yml
```

---------- FIRST ATTEMPT USING AWS OPERATOR ----------
********************************************************************************

Update and reboot
```
sudo apt update && sudo apt -y upgrade
sudo reboot
```

Install some basic packages
```
sudo apt -y install ansible git build-essential curl jq net-tools python3-virtualenv python3-pip
```

First step is to setup the repos for Kubernetes and Kubectl

Download Kubectl
```
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
```

Then we need to make it executable
```
chmod +x ./kubectl
```

Then we move it to bin so we can run it as any user
```
sudo mv ./kubectl /usr/local/bin/kubectl
```

Check that we can execute it
```
kubectl version --client
```

Next install Docker
```
sudo apt-get update -y &&  sudo apt-get install -y docker.io
```

Add user to docker group
```
sudo usermod -aG docker $USER
```

Log out and log in again to make sure we are in the docker group before launching minikube

Install minikube
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

Start minikube which will install kubernetes
```
minikube start --addons=ingress --cpus=2 --cni=flannel --install-addons=true \ --kubernetes-version=stable --memory=6g --wait=false
```

When it completes you should see something like this
```
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Check everything is working with
```
kubectl get pods -A
kubectl get nodes
kubectl version --short
```

We should see something like this
```
$ kubectl get pods -A
NAMESPACE       NAME                                        READY   STATUS      RESTARTS      AGE
ingress-nginx   ingress-nginx-admission-create--1-svz4d     0/1     Completed   0             20m
ingress-nginx   ingress-nginx-admission-patch--1-7497r      0/1     Completed   1             20m
ingress-nginx   ingress-nginx-controller-5f66978484-lxhxm   1/1     Running     0             20m
kube-system     coredns-78fcd69978-7lz4g                    1/1     Running     0             20m
kube-system     etcd-minikube                               1/1     Running     0             20m
kube-system     kube-apiserver-minikube                     1/1     Running     0             20m
kube-system     kube-controller-manager-minikube            1/1     Running     0             20m
kube-system     kube-flannel-ds-amd64-p72nw                 1/1     Running     0             20m
kube-system     kube-proxy-q4nfd                            1/1     Running     0             20m
kube-system     kube-scheduler-minikube                     1/1     Running     0             20m
kube-system     storage-provisioner                         1/1     Running     1 (19m ago)   20m
$ kubectl get nodes
NAME       STATUS   ROLES                  AGE   VERSION
minikube   Ready    control-plane,master   20m   v1.22.3
$ kubectl version --short
Client Version: v1.22.3
Server Version: v1.22.3
```

Create a kubernetes namespace to use for AWX
```
export NAMESPACE=awx
kubectl create ns ${NAMESPACE}
kubectl config set-context --current --namespace=$NAMESPACE
```

After a logout we might need to set our working namespace again without needing to recreate it
```
export NAMESPACE=awx
kubectl config set-context --current --namespace=$NAMESPACE
```

Clone AWX operator deployment code and change into that directory
```
git clone https://github.com/ansible/awx-operator.git && cd awx-operator/
```

Switch to current release branch
```
RELEASE_TAG=`curl -s https://api.github.com/repos/ansible/awx-operator/releases/latest | grep tag_name | cut -d '"' -f 4` && echo $RELEASE_TAG && git checkout $RELEASE_TAG
```

If current release branch has issues then specify the release branch manually
```
RELEASE_TAG="0.13.0" && echo $RELEASE_TAG && git checkout $RELEASE_TAG
```

Deploy the AWX operator using Makefile (only available in v0.14+)
```
make deploy
```

We can remove the AWX operator if we need to with this
```
make undeploy
```

If you need to do this you will need to recreate the namespace before you deploy again

Make sure the AWX operator manager is running
```
kubectl get pods
```

It might take a couple minutes but eventually we will see it ready 2/2 running
```
NAME                                               READY   STATUS    RESTARTS   AGE
awx-operator-controller-manager-68d787cfbd-8zxkp   2/2     Running   0          33s
```

Next we need to create the deployment file for the operator to use to install AWX
```
vim awx-deploy.yml

Paste below contents into the file:
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-titan
spec:
  service_type: nodeport
```

Apply configuration manifest file:
```
kubectl apply -f awx-deploy.yml
```
If successful it will show a created message
```
awx.awx.ansible.com/awx-titan created
```

In a few minutes we should be able to see the awx instances deployed using this command
```
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
```

When deployed successfully they should move from pending to running state
```
NAME                   READY   STATUS    RESTARTS   AGE
awx-64bc58f8d6-vs594   0/4     Pending   0          32s
awx-postgres-0         1/1     Running   0          40s
```

Wait until all are ready and running before proceeding.
If it seems to be taking a while you can see what the problem is by streaming the log.
Here is the command to stream the log (CTRL-C to exit stream):
```
kubectl logs -f deployments/awx-operator-controller-manager -c manager
```

BROKEN HANGS ON A TASK THAT TIMES OUT

---------- SECOND ATTEMPT USING AWS OPERATOR ----------
********************************************************************************

Some more dependencies - MAYBE
```
apt install docker python3-pip
pip install docker
ansible-galaxy collection install community.docker
```

Deploy a single node kubernetes using k3s lightweight tool
```
curl -sfL https://get.k3s.io | bash -
chmod 644 /etc/rancher/k3s/k3s.yaml
```

Confirm k3s is up and running
```
kubectl get nodes
kubectl version --short
```

Clone AWX operator deployment code and switch to current release branch
```
git clone https://github.com/ansible/awx-operator.git
cd awx-operator/
RELEASE_TAG=`curl -s https://api.github.com/repos/ansible/awx-operator/releases/latest | grep tag_name | cut -d '"' -f 4`
echo $RELEASE_TAG
git checkout $RELEASE_TAG
```

Create a kubernetes namespace to use for AWX
```
export NAMESPACE=awx
kubectl create ns ${NAMESPACE}
kubectl config set-context --current --namespace=$NAMESPACE
```

After a logout we might need to set our working namespace again without needing to recreate it
```
export NAMESPACE=awx
kubectl config set-context --current --namespace=$NAMESPACE
```

Deploy the AWX operator
```
make deploy
```

We can remove the AWX operator if we need to with this
```
make undeploy
```

Make sure the AWX operator manager is running
```
kubectl get pods
```

It might take a couple minutes but eventually we will see it ready 2/2
```
NAME                                               READY   STATUS    RESTARTS   AGE
awx-operator-controller-manager-68d787cfbd-n8488   2/2     Running   0          56s
```

Create a persistent Volume within kubernetes for AWX to uses for its project folder
```
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: static-data-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 8Gi
EOF
```

Check that it was created
```
kubectl get pvc -n awx
```

Note it will not be bound until AWX is running so it will show pending
```
NAME              STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
static-data-pvc   Pending                                      local-path     66s
```

Next we need to create the deployment file for the operator to use to install AWX
```
vim awx-deploy.yml

Paste below contents into the file:

---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
spec:
  service_type: nodeport
  projects_persistence: true
  projects_storage_access_mode: ReadWriteOnce
  web_extra_volume_mounts: |
    - name: static-data
      mountPath: /var/lib/awx/public
  extra_volumes: |
    - name: static-data
      persistentVolumeClaim:
        claimName: static-data-pvc
```

Apply configuration manifest file:
```
kubectl apply -f awx-deploy.yml
```
If successful it will show a created message
```
awx.awx.ansible.com/awx created
```

In a few minutes we should be able to see the awx instances deployed using this command
```
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
```

When deployed successfully they should move from pending to running state
```
NAME                   READY   STATUS    RESTARTS   AGE
awx-64bc58f8d6-vs594   0/4     Pending   0          32s
awx-postgres-0         1/1     Running   0          40s
```

Wait until all are ready and running before proceeding.
If it seems to be taking a while you can see what the problem is by streaming the log.
Here is the command to stream the log (CTRL-C to exit stream):
```
kubectl logs -f deployments/awx-operator-controller-manager -c manager
```

BROKEN HANGS ON A TASK THAT TIMES OUT
