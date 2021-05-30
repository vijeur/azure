#!/bin/bash

sudo apt update -y
sudo apt-get install default-jdk -y
sudo wget -O artifactory-pro-7.19.4.deb "https://releases.jfrog.io/artifactory/artifactory-pro-debs/pool/jfrog-artifactory-pro/jfrog-artifactory-pro-7.19.4.deb"
sudo dpkg -i artifactory-pro-7.19.4.deb
#if [ $? -ne 0 ]; then { echo "Failed, aborting." >> /tmp/dpkg ; exit 1; } fi
sudo curl -L -o /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/postgresql-42.2.20.jar https://jdbc.postgresql.org/download/postgresql-42.2.20.jar
sudo chmod +r /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/postgresql-42.2.20.jar
sudo cp /opt/jfrog/artifactory/var/etc/system.yaml{,.bak}
sudo cat <<EOF >/opt/jfrog/artifactory/var/etc/system.yaml
configVersion: 1
shared:
    node:
    database:
        type: postgresql
        driver: org.postgresql.Driver
        url: "jdbc:postgresql://test-psqlserver.postgres.database.azure.com:5432/postgres?ssl=true&sslmode=require"
        username: psqladminun@test-psqlserver
        password: H@Sh1CoR3!
EOF
sudo service artifactory start