Octohost
===========================

A [Packer](http://www.packer.io/) template to build:

  1. An AMI using Ubuntu 12.04 in AWS USW-2 (Oregon) region. It's built using [another AMI](https://github.com/octohost/ubuntu-12.0.4-3.8).
  2. A Virtualbox Vagrant box.

Includes:

  1. [Docker](http://www.docker.io/)
  2. [Serf](http://www.serfdom.io/) - Currently unused.
  3. [Hipache](https://github.com/dotcloud/hipache) - to route traffic to the proper docker container.

Purpose
--------

To host any web code possible:

1. Ruby - [1.8.7](https://github.com/octohost/ruby-1.8.7p352), [1.9.3](https://github.com/octohost/ruby-1.9.3p194), [2.0.0](https://github.com/octohost/ruby-2.0.0p247), [Sinatra](https://github.com/octohost/sinatra), [Middleman](https://github.com/octohost/middleman), Rails 2, Rails 3, Rails 4
2. PHP - [5.4.x w/nginx](https://github.com/octohost/php5-nginx), WordPress
3. Node - [0.10.x](https://github.com/octohost/nodejs), [Harp](https://github.com/octohost/harp), Ghost
4. Python - [3.3](https://github.com/octohost/python-3.3), Django
5. Go - [1.2rc3](https://github.com/octohost/go-1.2rc3), [Web.go](https://github.com/octohost/web.go), [Revel](https://github.com/octohost/revel)
6. Openresty - [1.4.2.8](https://github.com/octohost/openresty)
7. Java - [OpenJDK7](https://github.com/octohost/openjdk7)

The goal is to host anything.

To Build the VM's
--------

`vagrant up`

`packer build template.json`

To Install on Rackspace using Ansible:
---------

Create the instance. Add your public key to the root user - use [ssh-copy-id](https://github.com/beautifulcode/ssh-copy-id-for-OSX):

`ssh-copy-id -i ~/.ssh/id_dsa.pub root@ip.address.here`

Upgrade the kernel and reboot:

`ssh root@ip.address.here "apt-get update && apt-get -y upgrade && apt-get -y install linux-image-generic-lts-raring linux-headers-generic-lts-raring && reboot"`

Update your Ansible Inventory file - add a "rackspace" group - then:

`ansible-playbook site.yml`

Additional Instructions to Come
---------
