# Changelog

## 0.7.6 - ami-78eb8a48

* Update to Docker 0.7.6.
* Make sure to [remove Hipache route](https://github.com/octohost/octohost/commit/b5d23f433812f3cf9ce2b5cc19770d668d0889a1) when `octo remove` is used.
* [Comment out unused PUBLIC_IP](https://github.com/octohost/octohost-cookbook/commit/49a6a01528dece21104b7ab7d00c44471073c095) when building Vagrant.
* Added proper [OpenJDK7](https://github.com/octohost/openjdk7) and [Play Framework](https://github.com/octohost/play-app).
* Added [Vagrant build](https://github.com/octohost/octovagrant) for local development.
* Added [octodev.io](http://octodev.io/) wildcard dns for local development.
* Added a more consistent [Ubuntu base cookbook](https://github.com/darron/ubuntu_base-cookbook) to the build.
* Added [sysstat](https://github.com/darron/octobase-cookbook/commit/c32167fe8fb044af52c9689caae0efef7fbac152) for some basic server metrics.
* [Properly set en_US.UTF-8](https://github.com/darron/ubuntu_base-cookbook/commit/dbd45aefd79d3c67af01fc886ca9c67cf6ee57e8) as the locale.
* Set [ulimit](https://github.com/darron/octobase-cookbook/commit/6def19aca5abe4e74fbaeba1c55ff3a20d7f7cf0) to 64000 open files.
* Remove old init file and properly use [/etc/default/docker](https://github.com/darron/docker-cookbook/commit/77309c615a848173ad4db3ba110e6bfe3fd0979c).
* Remove the extra .git from the [branch url](https://github.com/octohost/octohost/commit/83ec3c690faed7f3c9abfbadc0f9e043b384f95b).

## 0.7.5 - ami-7e29484e

#### Changes

* Update to [Docker 0.7.5](https://github.com/dotcloud/docker/blob/c348c04fdfb00e013be9db15d37728e04fb94b76/CHANGELOG.md)
* Added [Perl](https://github.com/octohost/perl), [Perl Dancer](https://github.com/octohost/perldancer-app), [Mojolicious](https://github.com/octohost/mojolicious-app) and [Slim](https://github.com/octohost/slim).

## 0.7.3 - ami-48147278

#### Changes

* Update to [Docker 0.7.3](https://github.com/dotcloud/docker/blob/8502ad4ba7b5410eb55f3517a801b33f61b1f625/CHANGELOG.md)
* Added [Ruby 2.1](https://github.com/octohost/ruby-2.1.0), [Ramaze](https://github.com/octohost/ramaze), [Erlang](https://github.com/octohost/erlang), and [Sails.js](https://github.com/octohost/sails)

## 0.7.2 - ami-74690e44

#### Changes

* Update to [Docker 0.7.2](https://github.com/dotcloud/docker/blob/master/CHANGELOG.md)
* Built with new Chef based [octohost-cookbook](https://github.com/octohost/octohost-cookbook)

## 0.7 - ami-2c187c1c

#### Changes

* Updates to Node.JS, Ruby and Go base containers. Lots of small updates to frameworks.
* Updated [base image](https://github.com/octohost/ubuntu-12.0.4-3.8)
* If you push a branch other than master, the domain name is suffixed with -branch.
* If `docker build` fails, stop the rest of bin/receiver.sh
* Always register Xip.io domain names tied to IP address.

## 0.6 - ami-5c5e3b6c

#### Changes

* Update to [Docker 0.7.1](https://github.com/dotcloud/docker/blob/v0.7.1/CHANGELOG.md)
* Fixed a bug when --force pushing that wouldn't update the site.
* Added image cleaning to `octo clean`
* Removed Shipyard.
* Updated to Serf 0.3 - fixed bug with event handler discovery.
* Fixed some bugs with octo cli. 

## 0.5 - ami-e876ecd8

#### Changes

* Update to Docker 0.7
* Add `/usr/bin/octo move` to pull sites from old octohost and relaunch them.
* Allowing SSH Forwarding and keeping SSH\_AUTH\_SOCK so that `/usr/bin/octo move` works.
* Added way to install ssh keys and configure domain name at AMI launch using [user-data](https://github.com/octohost/octohost/blob/master/user-data-file/setup).
* Added `/usr/bin/octo remove $site` - removes active sites / repos.
* Added [documentation](https://github.com/octohost/octohost/blob/master/docs/octo-cli.md) around octo cli.
* Add `/usr/bin/octo clean` - removes old stopped containers.

## 0.4 - ami-da910bea

#### Changes

* Add /usr/bin/octo status|restart - shows status and can reload from an uploaded git repo.
* Update to Serf 0.2.1
* Don't build without a Dockerfile.
* Add a little better error checking on push.
* Added Lynx.

## 0.3 - ami-06fa6036

#### Changes

* Update to Docker 0.6.7.
* Remove apt-get upgrade which was causing Ansible service module requests to fail.

## 0.2 - ami-26d84216

#### Changes

* Make curl in receiver always return IPv4.

## 0.1 - Removed.

* First release.
