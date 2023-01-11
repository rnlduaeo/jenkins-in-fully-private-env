#!/bin/bash -xe

# Make software packages be up to date
sudo yum update –y

# Add the Jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import a key file from Jenkins-CI to enable installation from the package
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade

# Install Java:
sudo amazon-linux-extras install java-openjdk11 -y

# Install Jenkins with specific version info to avoid 
sudo yum install jenkins-2.375.1-1.1 -y

# Create directories for Jenkins
sudo -ujenkins mkdir /var/cache/jenkins/tmp
sudo -ujenkins mkdir /var/cache/jenkins/heapdumps
sudo -ujenkins mkdir /var/lib/jenkins/plugins

# allow the jenkins plugin manager to copy the plugins to target directory
sudo chmod 777 /var/lib/jenkins/plugins

# Update JENKINS_JAVA_OPTIONS and JENKINS_OPTS
cat <<EOF >$HOME/override.conf
[Service]
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djenkins.install.runSetupWizard=false -Djava.io.tmpdir=/var/cache/jenkins/tmp/ -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Seoul -Duser.timezone=Asia/Seoul"
Environment="JENKINS_OPTS=--pluginroot=/var/cache/jenkins/plugins"
EOF
sudo mkdir -m 644 /etc/systemd/system/jenkins.service.d
sudo cp $HOME/override.conf /etc/systemd/system/jenkins.service.d/

# Download jenkins-plugin-manager
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.9/jenkins-plugin-manager-2.12.9.jar -O $HOME/jenkins-plugin-manager.jar

# Run the jenkins-plugin-manager
java -jar jenkins-plugin-manager.jar --war /usr/share/java/jenkins.war --jenkins-version 2.375.1 --plugin-file plugins.yaml --plugin-download-directory /var/lib/jenkins/plugins --verbose

