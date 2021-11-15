# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Vagranfile for titanawx automation platform
#
# Define Server Variables Here
servers=[
  {
    :hostname => "titanawx-focal",
    :log => "console-phoenix-alpha.log",
    :ip => "192.168.65.11",
    :box => "ubuntu-2004-server-amd64",
    :boxurl => "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-vagrant.box",
    :ram => 8192,
    :vram => 16,
    :cpu => 3,
    :fwdguest => 30080,
    :fwdhost => 30080,
  },
  {
    :hostname => "titanawx-cent8",
    :log => "console-phoenix-charlie.log",
    :ip => "192.168.65.12",
    :box => "centos/8",
    :boxurl => "https://cloud.centos.org/centos/8/vagrant/x86_64/images/CentOS-8-Vagrant-8.4.2105-20210603.0.x86_64.vagrant-virtualbox.box",
    :ram => 8192,
    :vram => 16,
    :cpu => 3,
    :fwdguest => 8080,
    :fwdhost => 8082,
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
