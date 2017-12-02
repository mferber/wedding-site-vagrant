# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile adapted from:
# https://medium.com/@JohnFoderaro/how-to-set-up-a-local-linux-environment-with-vagrant-163f0ba4da77

# Box / OS
VAGRANT_BOX = 'ubuntu/trusty64'

# Memorable name for your VM
VM_NAME = 'wedding-site'

# VM User — 'vagrant' by default
VM_USER = 'vagrant'

# Username on your Mac
MAC_USER = 'matthias'

# Host folder to sync
HOST_PATH = '/Users/' + MAC_USER + '/Projects/Wedding-site/site'

# Where to sync to on Guest — 'vagrant' is the default user name
GUEST_PATH = '/vagrant/'

# # VM Port — uncomment this to use NAT instead of DHCP
# VM_PORT = 8080
Vagrant.configure("2") do |config|

  # Vagrant box from Hashicorp
  config.vm.box = VAGRANT_BOX
  
  # Actual machine name
  config.vm.hostname = VM_NAME

  # Set VM name in Virtualbox
  config.vm.provider "virtualbox" do |v|
    v.name = VM_NAME
    v.memory = 2048
  end

  #DHCP — comment this out if planning on using NAT instead
  config.vm.network :private_network, ip: "192.168.68.8"

  # # Port forwarding — uncomment this to use NAT instead of DHCP
  # config.vm.network "forwarded_port", guest: 80, host: VM_PORT
  # Sync folder
  config.vm.synced_folder HOST_PATH, GUEST_PATH

  # Disable default Vagrant folder, use a unique path per project
  config.vm.synced_folder '.', '/home/'+VM_USER+'', disabled: true

  # Install zsh, Git, Node.js, Latest npm
  config.vm.provision :shell, :path => 'bootstrap.sh'

end
