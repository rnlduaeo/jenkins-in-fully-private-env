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
