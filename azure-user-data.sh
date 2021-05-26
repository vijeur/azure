#!/bin/bash

yum update -y
yum install -y java-1.8.0>> /tmp/yum-java8.log
alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
yum -y remove java-1.7.0-openjdk>> /tmp/yum-java7.log 2>&1

##Install Artifactory
wget https://bintray.com/jfrog/artifactory-pro-rpms/rpm -O bintray-jfrog-artifactory-pro-rpms.repo
mv bintray-jfrog-artifactory-pro-rpms.repo /etc/yum.repos.d/
sleep 10
yum install -y jfrog-artifactory-pro-${artifactory_version}>> /tmp/yum-artifactory.log 2>&1
yum install -y nginx>> /tmp/yum-nginx.log 2>&1
curl -L -o  /opt/jfrog/artifactory/tomcat/lib/mysql-connector-java-5.1.38.jar https://bintray.com/artifact/download/bintray/jcenter/mysql/mysql-connector-java/5.1.38/mysql-connector-java-5.1.38.jar
openssl req -nodes -x509 -newkey rsa:4096 -keyout /etc/pki/tls/private/example.key -out /etc/pki/tls/certs/example.pem -days 356 -subj "/C=US/ST=California/L=SantaClara/O=IT/CN=*.localhost"
