set -e
# NOTE: as of today java 7 must be used, not 8. With 8 the pipeline works, but logging to S3 not.
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jre-7u80-linux-x64.tar.gz
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
