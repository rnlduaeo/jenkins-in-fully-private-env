variable "region" {
  type        = string
  description = "AWS region"
  default     = "ap-norhteast-2"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the Jenkins will be deployed to"
}

variable "private_subnet_ids" {
  description = "List of the private subnet IDs"
  type        = list(string)
  default     = []
}

variable "jenkins_agent_ami_id" {
  description = "Jenkins Agent AMI ID"
  type        = string
  default     = ""
}

variable "spot_request_iam_policy" {
  description = "Default IAM Role for spot request"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

variable "jenkins_agent_iam_policy_ecr" {
  description = "ARN of Managed IAM policy for ECR"
  type        = string
  default     = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

variable "jenkins_agent_iam_policy_codecommit" {
  description = "ARN of Managed IAM policy for codecommit"
  type        = string
  default     = "arn:aws:iam::aws:policy/AWSCodeCommitPowerUser"
}

variable "jenkins_agent_iam_policy_ssm" {
  description = "ARN of Managed IAM policy for SSM"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}