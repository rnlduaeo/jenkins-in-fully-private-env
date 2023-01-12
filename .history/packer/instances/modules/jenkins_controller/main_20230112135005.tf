data "aws_ssm_parameter" "jenkins_spot_agent_ssh_key" {
    name = "jenkins-spot-agent-ssh-key"
}

data "aws_ssm_parameter" "jenkins-pwd" {
    name = "jenkins-pwd"
}

# data "template_file" jenkins_configuration_def {

#   template = file("${path.module}/files/jenkins.yaml.tpl")

#   vars = {
#     jenkins-agent-private-key = data.aws_ssm_parameter.jenkins_agent.value
#     jenkins-pwd               = data.aws_ssm_parameter.jenkins-pwd.value
#     spot-request-id           = var.spot_request_id
#   }
# }

resource "null_resource" "render_template" {
  triggers = {
    src_hash = file("${path.module}/files/jenkins.yaml.tpl")
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
tee ${path.module}/files/jenkins.yaml <<ENDF
${templatefile("${path.module}/files/jenkins.yaml.tpl", 
              {
                jenkins-agent-private-key = data.aws_ssm_parameter.jenkins_agent.value,
                jenkins-pwd               = data.aws_ssm_parameter.jenkins-pwd.value,
                spot-request-id           = var.spot_request_id
              })}
EOF
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "jenkins-cont-key"
  public_key = file("../tf-packer.pub")
}

resource "aws_security_group" "jenkins_controller_sg" {
  name   = "jenkins_controller_sg"
  vpc_id = var.vpc_id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_iam_instance_profile" "jenkins-controller" {
  name = "jenkins-controller"
  role = aws_iam_role.jenkins_controller_role.name
}

resource "aws_iam_policy" "policy" {
  name = "jenkins-controller-policy"

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeSpotFleetInstances",
        "ec2:ModifySpotFleetRequest",
        "ec2:CreateTags",
        "ec2:DescribeRegions",
        "ec2:DescribeInstances",
        "ec2:TerminateInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeSpotFleetRequests"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:UpdateAutoScalingGroup"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:ListInstanceProfiles",
        "iam:ListRoles"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "ec2.amazonaws.com.cn"
          ]
        }
      }
    }
  ]
})
}

resource "aws_iam_role" "jenkins_controller_role" {
  name = "jenkins_controller_role"
  managed_policy_arns = [aws_iam_policy.policy.arn]
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

resource "aws_instance" "jenkins_controller" {
  key_name               = aws_key_pair.ssh_key.key_name
  ami                    = var.jenkins_controller_ami_id
  instance_type          = "m5.large"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.jenkins_controller_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins-controller.name

  provisioner "file" {
    source      = "${path.module}/files/jenkins.yaml"
    destination = "/home/ec2-user/jenkins.yaml"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("../tf-packer")
      host        = self.private_ip
    }
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("../tf-packer")
    host        = self.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp $HOME/jenkins.yaml /var/lib/jenkins/jenkins.yaml",
      "sudo chown -R jenkins:jenkins /var/lib/jenkins",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart jenkins"
    ]
  }

  tags = {
    Name = "jenkins-controller"
  }

  depends_on = [
    null_resource.render_template
  ]
}

