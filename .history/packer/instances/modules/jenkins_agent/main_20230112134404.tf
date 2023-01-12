terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.42.0"
    }
  }
  required_version = ">= 0.14.5"
}

resource "aws_security_group" "jenkins_agent" {
  name   = "jenkins_agent"
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

resource "aws_key_pair" "jenkins_agent" {
  key_name   = "jenkins_agent"
  public_key = file("${path.module}/id_ed25519.pub")
}

resource "aws_iam_instance_profile" "jenkins_agent" {
  name = "jenkins_agent"
  role = aws_iam_role.jenkins_agent.name
}

resource "aws_iam_role" "jenkins_agent" {
  name = "jenkins_agent"
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


resource "aws_iam_role" "spot_fleet" {
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

resource "aws_launch_template" "jenkins_spot_agent" {
  name                    = "jenkins_spot_agent"
  image_id                = var.jenkins_agent_ami_id
  instance_type           = "t2.medium"
  key_name                = aws_key_pair.jenkins_agent.key_name
  vpc_security_group_ids  = [aws_security_group.jenkins_agent.id]

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 50
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.jenkins_agent.arn
  }

  instance_market_options {
    market_type = "spot"
  }
}


# Request a Spot fleet
resource "aws_spot_fleet_request" "jenkins_agent" {
  excess_capacity_termination_policy  = "NoTermination"
  allocation_strategy                 = "priceCapacityOptimized"
  fleet_type                          = "maintain"
  on_demand_target_capacity           = 0
  target_capacity                     = 0
  iam_fleet_role                      = aws_iam_role.spot_fleet.arn

  launch_template_config {
    
    launch_template_specification {
      id = aws_launch_template.jenkins_spot_agent.id
      version = aws_launch_template.jenkins_spot_agent.latest_version
    }    

    dynamic overrides {
      for_each = [for s in var.private_subnet_ids: {
        subnet_id = s
      }]

      instance_type = "t2.large"
      subnet_id     =  overrides.value.subnet_id
    }

    
    # overrides {
    #   instance_type = "t2.large"
    #   subnet_id     =  var.private_subnet_ids[0]
    # }

    # overrides {
    #   instance_type = "t2.large"
    #   subnet_id     =  var.private_subnet_ids[1]
    # }

    # overrides {
    #   instance_type = "t2.large"
    #   subnet_id     =  var.private_subnet_ids[2]
    # }

    # overrides {
    #   instance_type = "t2.medium"
    #   subnet_id     =  var.private_subnet_ids[0]
    # }

    # overrides {
    #   instance_type = "t2.medium"
    #   subnet_id     =  var.private_subnet_ids[1]
    # }

    # overrides {
    #   instance_type = "t2.medium"
    #   subnet_id     =  var.private_subnet_ids[2]
    # }

    # overrides {
    #   instance_type = "t3.large"
    #   subnet_id     =  var.private_subnet_ids[0]
    # }

    # overrides {
    #   instance_type = "t3.large"
    #   subnet_id     =  var.private_subnet_ids[1]
    # }

    # overrides {
    #   instance_type = "t3.large"
    #   subnet_id     =  var.private_subnet_ids[2]
    # }

    # overrides {
    #   instance_type = "t3.medium"
    #   subnet_id     =  var.private_subnet_ids[0]
    # }

    # overrides {
    #   instance_type = "t3.medium"
    #   subnet_id     =  var.private_subnet_ids[1]
    # }

    # overrides {
    #   instance_type = "t3.medium"
    #   subnet_id     =  var.private_subnet_ids[2]
    # }
  }
}


