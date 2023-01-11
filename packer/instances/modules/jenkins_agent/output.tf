output "spot-request-id" {
  description = "spot request id"
  value       = aws_spot_fleet_request.jenkins-agent-spot-request.id
}