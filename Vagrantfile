# -*- mode: ruby -*-
# vi: set ft=ruby :
 
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :octohost do |config|
    config.vm.box = "precise64-3.8"
    config.vm.box_url = "https://dl.dropboxusercontent.com/u/695019/vagrant/precise64-3.8.box"

    # Proper kernel setup from setup.sh has already been done with that VM.
    config.vm.provision "shell", path: "shell/docker.sh"
    config.vm.provision "shell", path: "shell/serf.sh"
    config.vm.provision "shell", path: "shell/hipache.sh"
  end
end