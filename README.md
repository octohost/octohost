Octohost
===========================

A [Packer](http://www.packer.io/) template to build:

  1. An AMI using Ubuntu 12.04 in AWS USW-2 (Oregon) region.
  2. A Virtualbox Vagrant box.

Includes:

  1. [Docker](http://www.docker.io/)
  2. [Serf](http://www.serfdom.io/)
  3. [Hipache](https://github.com/dotcloud/hipache) - to route traffic to the proper docker container.

Purpose
--------

To host any web code possible:

1. Ruby - [1.8.7](https://github.com/octohost/ruby-1.8.7p352), [1.9.3](https://github.com/octohost/ruby-1.9.3p194), [2.0.0](https://github.com/octohost/ruby-2.0.0p247), [Sinatra](https://github.com/octohost/sinatra), [Middleman](https://github.com/octohost/middleman), Rails 2, Rails 3, Rails 4
2. PHP - [5.4.x w/nginx](https://github.com/octohost/php5-nginx), WordPress
3. Node - [0.10.x](https://github.com/octohost/nodejs), [Harp](https://github.com/octohost/harp), Ghost
4. Python - [3.3](https://github.com/octohost/python-3.3), Django
5. Go - [1.2rc3](https://github.com/octohost/go-1.2rc3)

The goal is to host anything.

To Build the VM's
--------

`vagrant up`

`packer build template.json`

Configure Serf Roles and adding Handlers
--------------------------

Using [User data](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AESDG-chapter-instancedata.html) we can setup the Serf role:

```
ec2-run-instances --key your-key -g security-group --user-data-file user-data-file/master your-ami --region us-west-2
ec2-run-instances --key your-key -g security-group --user-data-file user-data-file/route your-ami --region us-west-2
ec2-run-instances --key your-key -g security-group --user-data-file user-data-file/build your-ami --region us-west-2
ec2-run-instances --key your-key -g security-group --user-data-file user-data-file/serve your-ami --region us-west-2
```

Configurable Event Handlers
---------------------------

Inside [/etc/default/serf](https://github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/blob/master/config/serf.default) you can configure an EVENTS_DIR that contains all of your handlers.

You can also configure an alternate SUFFIX if you prefer to write your handlers in a language other than Bash/sh.

If that EVENTS_DIR exists the [serf.conf](https://github.com/darron/packer-ubuntu-12.04-docker-serf-hipache/blob/master/config/serf.conf) Upstart script will look for files ending in SUFFIX and add them as event handlers.

TODO
-----------

Better error checking, etc.
Update Serf.
