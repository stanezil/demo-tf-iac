#!/bin/bash

# http://[Your_EC2_Public_IP_or_DNS]/helloworld/

# Update the system
yum update -y

# SSH Authorized Key for user ec2-user
echo "ssh-rsa ${PUBLIC_KEY} user@example.com" >> /home/ec2-user/.ssh/authorized_keys
echo "ssh-rsa ${PUBLIC_KEY} user@example.com" >> /home/ec2-user/public_key
echo "ssh-rsa ${PRIVATE_KEY} user@example.com" >> /home/ec2-user/private_key

# Install Java (OpenJDK 8)
yum install -y java-1.8.0-openjdk-devel

# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))

sudo yum install firewalld -y
sudo systemctl enable firewalld
sudo systemctl start firewalld

# Download and Install Apache Tomcat 8
wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.78/bin/apache-tomcat-8.5.78.tar.gz
sudo tar xzf apache-tomcat-8.5.78.tar.gz -C /usr/local
sudo ln -s /usr/local/apache-tomcat-8.5.78 /usr/local/tomcat

sudo useradd -r -m -U -d /usr/local/tomcat -s /bin/false tomcat
sudo chown -R tomcat: /usr/local/apache-tomcat-8.5.78

# Download and setup Log4j 2.14.1
wget https://archive.apache.org/dist/logging/log4j/2.14.1/apache-log4j-2.14.1-bin.tar.gz
tar -xzf apache-log4j-2.14.1-bin.tar.gz -C /usr/local/tomcat/lib/ --strip-components=1
rm apache-log4j-2.14.1-bin.tar.gz

# Create a simple Hello World web application
mkdir -p /usr/local/tomcat/webapps/helloworld/WEB-INF
echo "Hello World from Tomcat!" > /usr/local/tomcat/webapps/helloworld/index.jsp
echo "<web-app></web-app>" > /usr/local/tomcat/webapps/helloworld/WEB-INF/web.xml

## Change Tomcat port to 80 in server.xml
# sudo sed -i 's/port="8080"/port="80"/' /usr/local/tomcat/conf/server.xml
sudo firewall-cmd --zone=public --add-forward-port=port=80:proto=tcp:toport=8080 --permanent
sudo firewall-cmd --reload

# Create Tomcat systemd service file
sudo bash -c 'cat << EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))"
Environment="CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/usr/local/tomcat"
Environment="CATALINA_BASE=/usr/local/tomcat"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# sudo systemctl status tomcat