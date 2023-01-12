output "spot_request_id" {
  description = "spot request id"
  value       = aws_spot_fleet_request.jenkins_agent.id
}