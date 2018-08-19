#!/usr/bin/env bash

apt-get update -y -qq > /dev/null
apt-get upgrade -y -qq > /dev/null
apt-get -y -q install linux-headers-$(uname -r) build-essential > /dev/null

curl https://packages.chef.io/files/current/automate/latest/chef-automate_linux_amd64.zip | gunzip - > chef-automate && chmod +x chef-automate

# Unless you have a key that you can put into here, you will need to login and run this command manualy, Automate asks for you to accept T&C
#    chef-automate deploy

# configure hosts file for our internal network defined by Vagrantfile
cat >> /etc/hosts <<EOL
# vagrant environment nodes
10.0.15.10  chef-server
10.0.15.13  chef-automate
10.0.15.15  lb
10.0.15.22  web1
10.0.15.23  web2
EOL

printf "\033c"
echo "Chef-Automate Console is ready: http://chef-automate  login credentials are located at $PWD/automate-credentials.toml"

