<img src="http://github.froese.org/assets/octohost/octohost-300-words.png" align="right" border="0" />

Purpose
--------

To host any web code possible by adding a Dockerfile to your app's source repository.

Some example languages and frameworks that are already supported:

1. Ruby - [1.8.7](https://github.com/octohost/ruby-1.8.7p352), [1.9.3](https://github.com/octohost/ruby-1.9.3p484), [2.0.0](https://github.com/octohost/ruby-2.0.0p353), [2.1.0](https://github.com/octohost/ruby-2.1.0), [Sinatra](https://github.com/octohost/sinatra), [Middleman](https://github.com/octohost/middleman), [Octopress](https://github.com/octohost/octopress), [Padrino](https://github.com/octohost/padrino), [Rails 2](https://github.com/octohost/rails2), [Rails 3](https://github.com/octohost/rails3), [Rails 4](https://github.com/octohost/rails4), [Ramaze](https://github.com/octohost/ramaze)
2. PHP - [5.4.x w/nginx](https://github.com/octohost/php5-nginx), WordPress
3. Node - [0.10.x](https://github.com/octohost/nodejs), [Harp](https://github.com/octohost/harp), [Ghost](https://github.com/octohost/ghost), [KrakenJS](https://github.com/octohost/kraken), [Sails.js](https://github.com/octohost/sails)
4. Python - [3.3](https://github.com/octohost/python-3.3), Django
5. Go - [1.2](https://github.com/octohost/go-1.2), [Web.go](https://github.com/octohost/web.go), [Revel](https://github.com/octohost/revel), [martini](https://github.com/octohost/martini)
6. Openresty - [1.4.2.8](https://github.com/octohost/openresty)
7. Java - [OpenJDK7](https://github.com/octohost/openjdk7)
8. Clojure - [leiningen](https://github.com/octohost/leiningen), [hoplon](https://github.com/octohost/hoplon)
9. Erlang - [R16B03](https://github.com/octohost/erlang)

The goal is to host anything - more options are being worked on and added.

This repo contains a [Packer](http://www.packer.io/) template [to build](https://github.com/octohost/octohost/blob/master/docs/INSTALL.md):

  1. An AMI using Ubuntu 12.04 in AWS USW-2 (Oregon) region. It's built using [another AMI](https://github.com/octohost/ubuntu-12.0.4-3.8).
  2. A Virtualbox Vagrant box.

As of version 0.7.2, we are building octohost using a fully test driven Chef based [octohost-cookbook](https://github.com/octohost/octohost-cookbook).

There's also an [Ansible playbook](https://github.com/octohost/octohost/blob/master/docs/INSTALL.md) to build on Rackspace and other systems that support it.

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
ec2-run-instances --key your-key -g group-with-22-and-80-open ami-48147278 --user-data-file user-data-file/setup --region us-west-2
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

