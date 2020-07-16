#!/binbash

##########################################################
# Created By: Deepak Kumar Gupta                         #
# Licence: MIT Licence                                   #
##########################################################

sudo apt-get update -y
cd /tmp
sudo wget https://dl.google.com/go/go1.10.2.linux-amd64.tar.gz
sudo tar -C /usr/local/ -xzf go1.10.2.linux-amd64.tar.gz
# vim /etc/profile
# export PATH=$PATH:/usr/local/go/bin
echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
