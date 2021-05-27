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

cat <<EOF >/var/opt/jfrog/artifactory/etc/db.properties
  type=psql
  driver=com.mysql.jdbc.Driver
  url=jdbc:mysql://${db_url}/${db_name}??characterEncoding=UTF-8&elideSetAutoCommits=true
  username=${db_user}
  password=${db_password}
EOF

echo "artifactory.ping.allowUnauthenticated=true" >> /var/opt/jfrog/artifactory/etc/artifactory.system.properties
echo "export JAVA_OPTIONS=\"${EXTRA_JAVA_OPTS}\"" >> /var/opt/jfrog/artifactory/etc/default

chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/* && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/*  && chown artifactory:artifactory -R /var/opt/jfrog/artifactory/etc/security
service artifactory start