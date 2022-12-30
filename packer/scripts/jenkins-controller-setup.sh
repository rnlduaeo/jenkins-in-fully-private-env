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

# Install Jenkins
sudo yum install jenkins -y

# Create directories for Jenkins
sudo -ujenkins mkdir /var/cache/jenkins/tmp
sudo -ujenkins mkdir /var/cache/jenkins/heapdumps
sudo -ujenkins mkdir /var/lib/jenkins/plugins

# Update JENKINS_JAVA_OPTIONS
sudo sed -i 's|JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true.*|JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djenkins.install.runSetupWizard=false -Djava.io.tmpdir=/var/cache/jenkins/tmp/ -Dorg.apache.commons.jelly.tags.fmt.timeZone=Asia/Seoul -Duser.timezone=Asia/Seoul"|' /etc/sysconfig/jenkins

# Update JENKINS_ARGS
sudo sed -i 's|.*JENKINS_ARGS=.*|JENKINS_ARGS="--pluginroot=/var/cache/jenkins/plugins"|' /etc/sysconfig/jenkins

# Download jenkins-plugin-manager
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/tag/2.12.9 -O $HOME/jenkins-plugin-manager.jar

# Run the jenkins-plugin-manager 고쳐야 함 - 여기서부터 확인 
java -jar jenkins-plugin-manager.jar --jenkins-version 2.263.4 --plugin-file plugins.yaml --plugin-download-directory /var/lib/jenkins/plugins

# Update JENKINS_HOME ownership
chown jenkins:jenkins /var/lib/jenkins

# enable the Jenkins service to start at boot with the command
sudo systemctl enable jenkins

# start the Jenkins service with the command
sudo systemctl start jenkins
