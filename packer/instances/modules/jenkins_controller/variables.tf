variable "spot_request_id" {
  description = "ec2 spot request id "
  type        = string
  default     = ""
}

variable "jenkins_controller_ami_id" {
  description = "jenkins controller ami id"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of the private subnet IDs"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
  default     = ""
}