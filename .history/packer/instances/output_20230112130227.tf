output "spot_request_id" {
  description = "spot request id"
  value       = module.jenkins_agent.spot_request_id
}

output "jenkins_controller_ip" {
  description = "jenkins controller ip to access jenkins web dashboard"
  value       = module.jenkins_controller.jenkins_controller_ip
}