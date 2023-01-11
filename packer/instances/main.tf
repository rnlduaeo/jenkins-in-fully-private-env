module "jenkins_agent" {
  source                          = "./modules/jenkins_agent"
  vpc_id                          = var.vpc_id
  private_subnet_ids              = var.private_subnet_ids
  jenkins_agent_ami_id            = var.jenkins_agent_ami_id
}

module "jenkins_controller" {
  source                          = "./modules/jenkins_controller"
  private_subnet_ids              = var.private_subnet_ids
  jenkins_controller_ami_id       = var.jenkins_controller_ami_id
  spot_request_id                 = module.jenkins_agent.spot-request-id
  vpc_id                          = var.vpc_id
}
