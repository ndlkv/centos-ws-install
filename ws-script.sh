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

#NGINX CONFIG

if ! rpm -qa | grep -qw nginx;
        then
                yum install nginx
                sed '37d' /etc/nginx/nginx.conf # IF IPV6 SUPPORTED - DELETE.
        else
                echo "NGINX ALREADY INSTALLED."
        fi

#MARIADB & MYSQL CONFIG

if ! rpm -qa | grep -qw mariadb-server mariadb;
        then
                yum install mariadb-server
                yum install mariadb 
                systemctl start mariadb
                mysql_secure_installation
        else
                echo "MARIADB ALREADY INSTALLED."
        fi

#PHP CONFIG

if ! rpm -qa | grep -qw php php-mysql php-fpm;
        then
                yum install php
                yum install php-mysql
                yum install php-fpm
                sed -i "/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0" /etc/php.ini
                sed -i "/listen = 127.0.0.1:9000/c\listen = /var/run/php-fpm/php-fpm.sock" /etc/php-fpm.d/www.conf
        else
                echo "PHP ALREADY INSTALLED."
        fi
systemctl start php-fpm
systemctl start nginx
