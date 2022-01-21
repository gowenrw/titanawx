# AWX on Ubuntu focal manual installation notes

These are my notes from manual installation of AWX using AWX operator and k8s.

I have noted where we need to use an older version of kubernetes software.
This is because a change they made to the k8s API in the latest version
conflicts with an AWX operator function making installation fail.

## Basics and Prerequisites

Update and reboot
```
sudo apt update && sudo apt -y upgrade
sudo reboot
```

Install some basic packages
```
sudo apt update && sudo apt -y install ansible git build-essential curl jq net-tools python3-virtualenv python3-pip
```

## Docker Install

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
ansible-galaxy collection install community.docker
```

Add user to docker group
```
sudo usermod -aG docker $USER
```

Log out and in again for the group change to take effect

## Kubernetes Install

### Kubernetes kubectl install

Download kubectl version 1.20.12
```
curl -LO "https://dl.k8s.io/release/v1.20.12/bin/linux/amd64/kubectl"
```

Download kubectl latest version - since we are using older minikube we can't use this until that is fixed
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

### Kubernetes minikube install

Install minikube v1.21
```
curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/v1.21.0/minikube-linux-amd64 && sudo install -o root -g root -m 0755 minikube /usr/local/bin/minikube && rm minikube
```

Note this will install the latest version - but that version has issues so don't use until they fix
```
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install -o root -g root -m 0755 minikube /usr/local/bin/minikube && rm minikube
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
NAMESPACE       NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx   ingress-nginx-admission-create-pm8w5        0/1     Completed   0          11m
ingress-nginx   ingress-nginx-admission-patch-8vsqw         0/1     Completed   1          11m
ingress-nginx   ingress-nginx-controller-5d88495688-4q9gz   1/1     Running     0          11m
kube-system     coredns-74ff55c5b-mjdpq                     1/1     Running     0          11m
kube-system     etcd-minikube                               1/1     Running     0          12m
kube-system     kube-apiserver-minikube                     1/1     Running     0          12m
kube-system     kube-controller-manager-minikube            1/1     Running     0          12m
kube-system     kube-flannel-ds-amd64-psr6z                 1/1     Running     0          11m
kube-system     kube-proxy-wn2hg                            1/1     Running     0          11m
kube-system     kube-scheduler-minikube                     1/1     Running     0          12m
kube-system     storage-provisioner                         1/1     Running     0          12m
$ kubectl get nodes
NAME       STATUS   ROLES                  AGE   VERSION
minikube   Ready    control-plane,master   12m   v1.20.7
$ kubectl version --short
Client Version: v1.20.12
Server Version: v1.20.7
```

Show configured values that might be needed later
```
kubectl config view
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

## AWX Operator Install

Clone the AWX operator Repo specific branch that we want to use (In this case 0.14.0)
```
git clone -b 0.14.0 https://github.com/ansible/awx-operator.git && cd awx-operator/
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
awx-operator-controller-manager-5486747db4-qh6xs   2/2     Running   0          49s
```

## Deploy AWX using AWX Operator

### AWX Deployment Manifest File

Create the deployment file for the operator to use to install AWX
```
vim awx-titan.yml

Paste below contents into the file:
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-titan
spec:
  service_type: nodeport
```

### Deploy AWX Manifest

Apply configuration manifest file:
```
kubectl apply -f awx-titan.yml
```

If successful it will show a created message
```
awx.awx.ansible.com/awx-titan created
```

In a few minutes we should be able to see the awx instances deployed using this command
```
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator"
```

When deployed successfully they should move to running status
```
NAME                         READY   STATUS              RESTARTS   AGE
awx-titan-6c75c58b6f-gcgq6   0/4     ContainerCreating   0          28s
awx-titan-postgres-0         1/1     Running             0          35s
```

Wait until all are ready and running before proceeding.

If it seems to be taking a while you can see what the problem is by streaming the log.
Here is the command to stream the log (CTRL-C to exit stream):
```
kubectl logs -f deployments/awx-operator-controller-manager -c manager
```

### AWX Service Port

List all available services and check awx-service Nodeport
```
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"
```

This will show the service running and display the node port
```
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
awx-titan-postgres   ClusterIP   None           <none>        5432/TCP       8m41s
awx-titan-service    NodePort    10.100.32.97   <none>        80:30312/TCP   8m36s
```

We can edit the nodeport but the value must be in the range 30000-32767, we will use 30080
```
kubectl edit svc awx-titan-service
```

Now we need to expose the service locally for testing
```
minikube service awx-titan-service --url -n $NAMESPACE
```

This exposes the service on port 30080 on the bridge IP set up by minikube
So we can connect to it from the host machine like we would localhost but it is not exposed externally

Test this local connection using this string:
```
curl -L -q http://192.168.49.2:30080/api/v2/ping 2>/dev/null | python3 -m json.tool
```

### AWX Service credentials

To find the secret password for the service do this:
```
kubectl get secret awx-titan-admin-password -o jsonpath="{.data.password}" | base64 --decode
```

The string that is returned is the password.

The default login name is admin.

### AWX External Access

To expose this service externally without using a complicated Load Balancer setup we can run this:
```
kubectl port-forward service/awx-titan-service 30080:80 --address='0.0.0.0' > ./awx-titan-svc-pf.log 2>&1 &
```

Note that this port-forward is not dependent upon the local service we stood up.
So we don't need to edit the nodeport for this since it is hitting port 80 in the container.

If you don't put it in the background it will consume your terminal and breaking out will kill it.
This way we can kill it if we need to with ps kill but it will run in background and log

To confirm it is running look for the port listener with something like netstat -tulpn

Connect to the external IP of your server with a web browser on port 30080

http://192.168.65.11:30080/

This will provide you a login page.

Credentials Example:
admin
ogzO316ZuSe9ts5I8UEMl00NX6h1Uk2m

###  Troubleshooting Commands

To fix an AWX service you can delete the pods to have them automatically recreated
```
kubectl delete pods -l "app.kubernetes.io/managed-by=awx-operator"
```

Show information about the cluster
```
kubectl cluster-info
```

###  Ansible Control Box Notes

#### WSL

If running this from ansible within Windows Subsystem for Linux you will probably hit an error
about key files being too opened or other issues related to everything showing as 777 perms

I solved it by creating /etc/wsl.conf with the following content:
```
# Enable extra metadata options by default
[automount]
enabled = true
root = /mnt/
options = "metadata,umask=77,fmask=11"
mountFsTab = false
```

After making this change run this from an elevated powershell
```
Restart-Service -Name "LxssManager"
```

#### Linux VM

If on a Windows system without the Windows Subsystem for Linux, and given the incompatibilities between WSL2 and VirtualBox who can blame you, you may want another linux VM to be your ansible control box so that ansible is running on a differnt host than the one it is modifying.

For this linux VM you will just need a basic config that can be configured manually.

On Ubuntu you can run these commands to the box setup then reboot and its ready to use:
```
sudo apt update && sudo apt -y upgrade
sudo apt -y install ansible putty-tools python3-pip
sudo pip install openshift
```

Working on a separate titan role to allow for the installation of just ansible then running the role to install a number of other packages other than the bare minimum above.  In essence this role should make a nice ansible core platform.
