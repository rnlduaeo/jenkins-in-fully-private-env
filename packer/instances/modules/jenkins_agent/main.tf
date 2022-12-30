terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
  }
  required_version = ">= 0.14.5"
}

resource "aws_security_group" "jenkins_agent_sg" {
  name   = "jenkins_agent_sg"
  vpc_id = var.vpc_id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "jenkins-ssh" {
  key_name   = "jenkins-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

resource "aws_iam_instance_profile" "jenkins-agent-instance-profile" {
  name = "jenkins-agent-instance-profile"
  role = aws_iam_role.jenkins_agent_role.name
}

resource "aws_iam_role" "jenkins_agent_role" {
  name = "jenkins_agent_role"
  managed_policy_arns = [var.jenkins_agent_iam_policy_ecr, var.jenkins_agent_iam_policy_codecommit, var.jenkins_agent_iam_policy_ssm]
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}


resource "aws_iam_role" "spot_fleet_role" {
  name                = "AmazonEC2SpotFleetTaggingRole"
  managed_policy_arns = [var.spot_request_iam_policy]

  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "spotfleet.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
  
}

resource "aws_launch_template" "jenkins-spot-agent-launch-template" {
  name                    = "jenkins-spot-agent-launch-template"
  disable_api_stop        = true
  disable_api_termination = true
  ebs_optimized           = "true"
  image_id                = var.jenkins_agent_ami_id
  instance_type           = "t2.medium"
  key_name                = aws_key_pair.jenkins-ssh.key_name
  vpc_security_group_ids  = [aws_security_group.jenkins_agent_sg.id]

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 50
    }
  }
  
  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }

  elastic_gpu_specifications {
    type = "test"
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.jenkins-agent-instance-profile.arn
  }

  instance_market_options {
    market_type = "spot"
  }
}


# Request a Spot fleet
resource "aws_spot_fleet_request" "jenkins-agent-spot-request" {
  excess_capacity_termination_policy  = "NoTermination"
  allocation_strategy                 = "priceCapacityOptimized"
  fleet_type                          = "maintain"
  on_demand_target_capacity           = 0
  target_capacity                     = 1
  iam_fleet_role                      = aws_iam_role.spot_fleet_role.arn

  launch_template_config {
    
    launch_template_specification {
      id = aws_launch_template.jenkins-spot-agent-launch-template.id
      version = aws_launch_template.jenkins-spot-agent-launch-template.latest_version
    }

    overrides {
      instance_type = "t2.large"
      subnet_id     =  var.private_subnet_ids[0]
    }

    overrides {
      instance_type = "t2.large"
      subnet_id     =  var.private_subnet_ids[1]
    }

    overrides {
      instance_type = "t2.large"
      subnet_id     =  var.private_subnet_ids[2]
    }

    overrides {
      instance_type = "t2.medium"
      subnet_id     =  var.private_subnet_ids[0]
    }

    overrides {
      instance_type = "t2.medium"
      subnet_id     =  var.private_subnet_ids[1]
    }

    overrides {
      instance_type = "t2.medium"
      subnet_id     =  var.private_subnet_ids[2]
    }

    overrides {
      instance_type = "t3.large"
      subnet_id     =  var.private_subnet_ids[0]
    }

    overrides {
      instance_type = "t3.large"
      subnet_id     =  var.private_subnet_ids[1]
    }

    overrides {
      instance_type = "t3.large"
      subnet_id     =  var.private_subnet_ids[2]
    }

    overrides {
      instance_type = "t3.medium"
      subnet_id     =  var.private_subnet_ids[0]
    }

    overrides {
      instance_type = "t3.medium"
      subnet_id     =  var.private_subnet_ids[1]
    }

    overrides {
      instance_type = "t3.medium"
      subnet_id     =  var.private_subnet_ids[2]
    }
  }
}


