module "jenkins_agent" {
  source                          = "./modules/jenkins_agent"
  vpc_id                          = var.vpc_id
  private_subnet_ids              = var.private_subnet_ids
  jenkins_agent_ami_id            = var.jenkins_agent_ami_id
}

