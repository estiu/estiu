set -e

wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jre-8u65-linux-x64.tar.gz
sudo mv jre-* /usr/local/
cd /usr/local/
sudo chmod a+x jre-*
sudo tar xvzf jre-*
sudo rm jre-*.tar*
echo -e "JAVA_HOME=/usr/local/$(echo jre*) \n\
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin \n\
export JAVA_HOME \n\
export PATH" | sudo tee -a /etc/profile;
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/$(echo jre*)/bin/java" 1
sudo update-alternatives --set java "/usr/local/$(echo jre*)/bin/java"

sudo adduser --disabled-password --gecos "" ec2-user
sudo usermod -a -G sudo ec2-user
echo "ec2-user ALL=(ALL) NOPASSWD:ALL" | sudo dd of=/etc/sudoers.d/ec2-user

sudo su - ec2-user <<ENDCOMMANDS
cd /home/ec2-user;
mkdir .ssh;
chmod 700 .ssh;
touch .ssh/authorized_keys;
chmod 600 .ssh/authorized_keys;
curl -f http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key >> .ssh/authorized_keys;
ENDCOMMANDS