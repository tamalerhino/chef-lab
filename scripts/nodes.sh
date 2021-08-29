#!/usr/bin/env bash
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8
wget -P /tmp  https://packages.chef.io/files/stable/chef/12.16.42/el/7/chef-12.16.42-1.el7.x86_64.rpm
rpm -Uvh  /tmp/chef-12.16.42-1.el7.x86_64.rpm

# Install other tools
sudo yum update -y
sudo yum upgrade -y
sudo yum install vim ntp -y
sudo yum install tree

# configure hosts file for our internal network defined by Vagrantfile
cat >> /etc/hosts <<EOL
# vagrant environment nodes
10.0.15.10  chef-server
10.0.15.13  chef-automate
10.0.15.15  lb
10.0.15.22  web1
10.0.15.23  web2
EOL
