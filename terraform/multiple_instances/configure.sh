#!/bin/bash
echo "<html>Good, Day</html>" > /home/ubuntu/index.html
apt update -y
apt install -y nginx
systemctl enable nginx
systemctl start nginx
mv /home/ubuntu/index.html /var/www/html/index.nginx-debian.html 
systemctl restart nginx
