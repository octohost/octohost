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

1. Ruby
2. PHP
3. Node
4. Python

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