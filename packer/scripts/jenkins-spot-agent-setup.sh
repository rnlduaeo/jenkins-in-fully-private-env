#!/bin/bash -xe
sudo amazon-linux-extras install epel -y
sudo yum update -y

# remove java old version and install java 11
sudo yum remove java-1.7.0-openjdk
sudo yum install java-11-amazon-corretto -y

# install git and aws cli
sudo yum install git -y
sudo yum -y update aws-cli

# for using ec2 instance profile role instead of git credential 
pip3 install git-remote-codecommit

# install docker and register docker to be running on boot
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
id ec2-user
newgrp docker
sudo systemctl enable docker.service
sudo systemctl start docker.service