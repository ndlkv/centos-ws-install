#!/bin/bash
clear
printf %$(tput cols)s |tr " " "="
echo   "CENTOS WEB SERVER AUTO-INSTALLER"
printf %$(tput cols)s |tr " " "="

printf "Server IP:"
read SERVER_IP

yum update
yum install epel-release

#NGINX CONFIG

if ! rpm -qa | grep -qw nginx;
        then
                yum install nginx
                sed '37d' /etc/nginx/nginx.conf # IF IPV6 SUPPORTED - DELETE.
        else
                echo "NGINX ALREADY INSTALLED."
        fi

yum install mariadb-server
yum install mariadb
systemctl start mariadb
mysql_secure_installation

#PHP CONFIG

yum install php
yum install php-mysql
yum install php-fpm
sed -i "/;cgi.fix_pathinfo=1/c\cgi.fix_pathinfo=0" /etc/php.ini
sed -i "/listen = 127.0.0.1:9000/c\listen = /var/run/php-fpm/php-fpm.sock" /etc/php-fpm.d/www.conf
systemctl start php-fpm

#DEFAULT CONF FILE /etc/nginx/conf.d/default.conf

cat > /etc/nginx/conf.d/default.conf << EOF 
server {
    listen       80;
    server_name  $SERVER_IP;

    root   /usr/share/nginx/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

#END OF DEFAULT CONF FILE

systemctl start nginx
