moved {
  from = module.jenkins_agent.aws_iam_role.spot_fleet_role
  to   = module.jenkins_agent.aws_iam_role.spot_fleet
}
moved {
  from = module.jenkins_controller.aws_iam_instance_profile.jenkins-controller
  to   = module.jenkins_controller.aws_iam_instance_profile.jenkins_controller
}

moved {
  from = module.jenkins_controller.aws_iam_role.jenkins_controller_role
  to   = module.jenkins_controller.aws_iam_role.jenkins_controlle
}

moved {
  from = module.jenkins_agent.aws_spot_fleet_request.jenkins-agent-spot-request
  to   = module.jenkins_agent.aws_spot_fleet_request.jenkins_agent
}

moved {
  from = module.jenkins_agent.aws_security_group.jenkins_agent_sg
  to   = module.jenkins_agent.aws_security_group.jenkins_agent
}

moved {
  from = module.jenkins_agent.aws_launch_template.jenkins-spot-agent-launch-template
  to   = module.jenkins_agent.aws_launch_template.jenkins_spot_agent
}

moved {
  from = module.jenkins_controller.aws_key_pair.ssh_key
  to   = module.jenkins_controller.aws_key_pair.jenkins_controller
}

moved {
  from = module.jenkins_agent.aws_key_pair.jenkins-ssh
  to   = module.jenkins_agent.aws_key_pair.jenkins_agent
}

moved {
  from = module.jenkins_agent.aws_iam_role.jenkins_agent_role
  to   = module.jenkins_agent.aws_iam_role.jenkins_agent
}

moved {
  from = module.jenkins_agent.aws_iam_instance_profile.jenkins-agent-instance-profile
  to   = module.jenkins_agent.aws_iam_instance_profile.jenkins_agent
}
