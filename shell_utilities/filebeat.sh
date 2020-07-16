sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
echo "[elastic-6.x]
name=Elastic repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" > /etc/yum.repos.d/elastic.repo
sudo yum update -y
sudo yum install filebeat -y
sudo chkconfig --add filebeat
chkconfig filebeat on