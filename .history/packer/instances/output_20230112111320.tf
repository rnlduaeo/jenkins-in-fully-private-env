output "spot-request-id" {
  description = "spot request id"
  value       = module.jenkins_agent.spot-request-id
}

output "jenkins_controller_ip" {
  description = "jenkins controller ip to access jenkins web dashboard"
  value       = module.jenkins_controller.jenkins_controller_ip
}