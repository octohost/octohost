# Changelog

## 0.5 - ami-de72e8ee

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
