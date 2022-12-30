variable "region" {
  type    = string
  default = "ap-northeast-2"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


source "amazon-ebs" "amzn2" {
  ami_name      = "learn-terraform-packer-${local.timestamp}"
  instance_type = "t2.large"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.amzn2"]

  provisioner "file" {
    source      = "../tf-packer.pub"
    destination = "/tmp/tf-packer.pub"
  }
  provisioner "shell" {
    script = "../scripts/jenkins-spot-agent-setup.sh"
  }
}

build {
  sources = ["source.amazon-ebs.amzn2"]

  provisioner "file" {
    source      = "../tf-packer.pub"
    destination = "/tmp/tf-packer.pub"
  }

  provisioner "file" {
    source      = "../files/limits.d/30-jenkins.conf"
    destination = "/etc/security/limits.d/30-jenkins.conf"
  }

  provisioner "file" {
    source      = "../files/plugins.yaml"
    destination = "$HOME/plugins.yaml"
  }

  provisioner "file" {
    source      = "../files/jenkins.yaml"
    destination = "/var/lib/jenkins/jenkins.yaml"
  }

  provisioner "file" {
    source      = "../files/init.groovy.d/"
    destination = "/var/lib/jenkins/init.groovy.d/"
  }

  provisioner "shell" {
    script = "../scripts/jenkins-controller-setup.sh"
  }
}