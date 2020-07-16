sudo yum install java-1.8.0-openjdk-devel -y
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo "[logstash-6.x]
name=Elastic repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" > /etc/yum.repos.d/logstash.repo
sudo yum update -y
sudo yum install logstash -y
chkconfig logstash on