<img src="http://github.froese.org/assets/octohost/octohost-300-words.png" align="right" border="0" />

Purpose
--------

To host any web code possible by adding a Dockerfile to your app's source repository.

Some example languages and frameworks that are already supported is [maintained on the main site](http://www.octohost.io/languages).

The goal is to host anything - more options are being worked on and added.

This repo contains a [Packer](http://www.packer.io/) template [to build](https://github.com/octohost/octohost/blob/master/docs/INSTALL.md):

  1. An AMI using Ubuntu 12.04 in AWS USW-2 (Oregon) region. It's built using [another AMI](https://github.com/octohost/ubuntu-12.0.4-3.8).
  2. A Virtualbox Vagrant box.

As of version 0.7.2, we are building octohost using a fully test driven Chef based [octohost-cookbook](https://github.com/octohost/octohost-cookbook).

You can also [build a local octohost with Vagrant](https://github.com/octohost/octohost-cookbook) - if you run it on 192.168.62.86, you also get a free wildcard dns entry for [*.octodev.io - details here](http://octodev.io).

Deprecated as of 0.7.2: There's also an [Ansible playbook](https://github.com/octohost/octohost/blob/master/docs/INSTALL.md) to build on Rackspace and other systems that support it. Will be replaced by the Chef cookbook at some point.

A full installation includes:

  1. [Docker](http://www.docker.io/)
  2. [Serf](http://www.serfdom.io/) - Currently unused - we have some [plans](https://github.com/darron/serf-docker-events).
  3. [Hipache](https://github.com/dotcloud/hipache) - to route traffic to the proper docker container.
  4. [Gitreceive](https://github.com/progrium/gitreceive) - to receive pushes and do the magic.
  5. [Redis](http://redis.io/) - the storage backend for Hipache.


PLEASE NOTE: There may be security holes, there are rough edges, it is not complete and may eat your data - but *it works for us* at the moment. We are experiencing some container crashing - but it's alpha software so that's to be expected. YMMV.

Advanced Quickstart
---------

These are the minimum amount of commands needed to get started:

```
ec2-run-instances --key your-key -g group-with-22-and-80-open ami-7e29484e --user-data-file user-data-file/setup --region us-west-2
cat ~/.ssh/id_dsa.pub | ssh -i ~/.ssh/your-key.pem ubuntu@ip.address.here "sudo gitreceive upload-key ubuntu"
git clone git@github.com:octohost/harp.git
cd harp && git remote add octohost git@ip.address.here:harp.git
git push octohost master
```

If this doesn't work - please see the [INSTALL document](https://github.com/octohost/octohost/blob/master/docs/INSTALL.md).

The 'octo' cli
--------

In v0.4 we added a small cli to check status of all hosted sites and reload if needed.

More information is located in the [documentation](https://github.com/octohost/octohost/blob/master/docs/octo-cli.md).

