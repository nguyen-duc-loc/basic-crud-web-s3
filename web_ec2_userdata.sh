#!/bin/bash

# Update
sudo apt update

# Change timezone
sudo timedatectl set-timezone Asia/Ho_Chi_Minh

# Install make
sudo apt install -y make

# Install migrate
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.18.1/migrate.linux-amd64.tar.gz | tar xvz
rm LICENSE
rm README.md
sudo mv migrate /usr/bin

# Install apache2
sudo apt install -y apache2

# Config apache2 to forward port 3000 to port 80
sudo a2enmod proxy
sudo a2enmod proxy_http
echo "<VirtualHost *:80>" > /etc/apache2/sites-available/000-default.conf
echo "ProxyRequests Off" >> /etc/apache2/sites-available/000-default.conf
echo "ProxyPreserveHost On" >> /etc/apache2/sites-available/000-default.conf
echo "ProxyVia Full" >> /etc/apache2/sites-available/000-default.conf
echo "<Proxy *>" >> /etc/apache2/sites-available/000-default.conf
echo "       Require all granted" >> /etc/apache2/sites-available/000-default.conf
echo "</Proxy>" >> /etc/apache2/sites-available/000-default.conf
echo "ProxyPass / http://127.0.0.1:3000/" >> /etc/apache2/sites-available/000-default.conf
echo "ProxyPassReverse / http://127.0.0.1:3000/" >> /etc/apache2/sites-available/000-default.conf
echo "ErrorLog ${APACHE_LOG_DIR}/error.log" >> /etc/apache2/sites-available/000-default.conf
echo "CustomLog ${APACHE_LOG_DIR}/access.log combined" >> /etc/apache2/sites-available/000-default.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf
sudo systemctl restart apache2