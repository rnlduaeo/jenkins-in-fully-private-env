# Copy jenkins config files to jenkins directories
sudo -ujenkins mkdir -p /var/lib/jenkins/init.groovy.d/
tar -xvf $HOME/upload-to-ami.tar
cd upload-to-ami
sudo cp limits.d/30-jenkins.conf /etc/security/limits.d/30-jenkins.conf
# sudo -ujenkins cp jenkins.yaml /var/lib/jenkins/jenkins.yaml
sudo -ujenkins cp init.groovy.d/* /var/lib/jenkins/init.groovy.d/

# Update JENKINS_HOME ownership
sudo chown -R jenkins:jenkins /var/lib/jenkins

# enable the Jenkins service to start at boot with the command
sudo systemctl enable jenkins

# # start the Jenkins service with the command
sudo systemctl start jenkins
