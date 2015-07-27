#!/bin/bash
clear

printf %$(tput cols)s |tr " " "="
echo   "CENTOS WEB SERVER AUTO-INSTALLER"
printf %$(tput cols)s |tr " " "="

yum update

if ! rpm -qa | grep -qw epel-release;
        then
                yum install epel-release
        else
                echo "EPEL-RELEASE ALREADY INSTALLED."
        fi

if ! rpm -qa | grep -qw nginx;
        then
                yum install nginx
                sed '37d' /etc/nginx/nginx.conf # IF IPV6 SUPPORTED - DELETE.
        else
                echo "NGINX ALREADY INSTALLED."
        fi
systemctl start nginx
