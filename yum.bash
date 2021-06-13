#!/bin/bash

sudo apt update -y
sudo apt-get install default-jdk -y
sudo wget -O artifactory-pro-7.19.4.deb "https://releases.jfrog.io/artifactory/artifactory-pro-debs/pool/jfrog-artifactory-pro/jfrog-artifactory-pro-7.19.4.deb"
sudo dpkg -i artifactory-pro-7.19.4.deb
sudo sleep 10
#if [ $? -ne 0 ]; then { echo "Failed, aborting." >> /tmp/dpkg ; exit 1; } fi
sudo curl -L -o /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/sqljdbc_7.4.1.0_enu.tar.gz https://download.microsoft.com/download/6/9/9/699205CA-F1F1-4DE9-9335-18546C5C8CBD/sqljdbc_7.4.1.0_enu.tar.gz
sudo tar zxvf /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/sqljdbc_7.4.1.0_enu.tar.gz -C /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/
sudo cp /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/sqljdbc_7.4/enu/mssql-jdbc-7.4.1.jre8.jar /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/
sudo chmod +r /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/mssql-jdbc-7.4.1.jre8.jar
sudo cp /opt/jfrog/artifactory/var/etc/system.yaml{,.bak}
sudo cat <<EOF >/opt/jfrog/artifactory/var/etc/system.yaml
configVersion: 1
shared:
    node:
    database:
        type: mssql
        driver: com.microsoft.sqlserver.jdbc.SQLServerDriver
        url: "jdbc:sqlserver://az-dev-sql-server01.database.windows.net:1433;database=az-dev-db-01"
        username: sqluser@az-dev-sql-server01
        password: DxHCB46w8k5B
EOF
##curl http://127.0.0.1:8082/router/api/v1/system/health

sudo service artifactory start