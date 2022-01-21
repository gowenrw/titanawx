# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagranfile for titanawx automation platform
#
# Define Server Variables Here
servers=[
  {
    :hostname => "titanawx-focal",
    :log => "console-titanawx-focal.log",
    :ip => "192.168.65.11",
    :box => "ubuntu-2004-server-amd64",
    :boxurl => "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-vagrant.box",
    :ram => 8192,
    :vram => 16,
    :cpu => 4,
    :fwdguest => 80,
    :fwdhost => 8081
  },
  {
    :hostname => "titantst",
    :log => "console-titantst.log",
    :ip => "192.168.65.12",
    :box => "ubuntu-2004-server-amd64",
    :boxurl => "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-vagrant.box",
    :ram => 2048,
    :vram => 16,
    :cpu => 1,
    :fwdguest => 80,
    :fwdhost => 8082
  },
  {
    :hostname => "titanawx-cent8",
    :log => "console-titanawx-cent8.log",
    :ip => "192.168.65.13",
    :box => "centos/8",
    :boxurl => "https://cloud.centos.org/centos/8/vagrant/x86_64/images/CentOS-8-Vagrant-8.4.2105-20210603.0.x86_64.vagrant-virtualbox.box",
    :ram => 8192,
    :vram => 16,
    :cpu => 4,
    :fwdguest => 80,
    :fwdhost => 8083
  },
  {
    :hostname => "titan",
    :log => "console-titan.log",
    :ip => "192.168.65.10",
    :box => "ubuntu-2004-server-amd64",
    :boxurl => "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-vagrant.box",
    :ram => 8192,
    :vram => 16,
    :cpu => 2,
    :fwdguest => 80,
    :fwdhost => 8080
  }
]
#
# Configure Servers In A Loop
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
            node.vm.box = machine[:box]
            node.vm.box_url = machine[:boxurl]
            node.vm.hostname = machine[:hostname]
            node.vm.network "private_network", ip: machine[:ip]
            node.vm.network "forwarded_port", guest: machine[:fwdguest], host: machine[:fwdhost]
            node.vm.provider "virtualbox" do |vb|
                vb.customize [
                  "modifyvm", :id,
                  "--vram", machine[:vram],
                  "--memory", machine[:ram],
                  "--cpus", machine[:cpu],
                  "--uartmode1", "file", File.join(Dir.pwd, machine[:log])
                ]
            end
            node.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "vagrant", mount_options: ["dmode=700,fmode=700"]
        end
    end
end
