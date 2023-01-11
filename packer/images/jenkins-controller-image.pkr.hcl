variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "amzn2" {
  ami_name      = "jenkins-controller-${local.timestamp}"
  instance_type = "t2.large"
  region        = var.region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-kernel-5.10-hvm-2.0.20221210.1-x86_64-gp2"
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

  provisioner "file" {
    source      = "../files/plugins.yaml"
    destination = "$HOME/plugins.yaml"
  }

  provisioner "shell" {
    script = "../scripts/jenkins-controller-setup.sh"
  }

  provisioner "file" {
    source      = "../files/upload-to-ami.tar"
    destination = "$HOME/upload-to-ami.tar"
  }

  provisioner "shell" {
    script = "../scripts/jenkins-controller-post-processor.sh"
  }
}