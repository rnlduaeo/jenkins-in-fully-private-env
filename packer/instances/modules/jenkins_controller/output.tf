output "jenkins_controller_ip" {
  description = "jenkins contoller ip"
  value       = aws_instance.jenkins_controller.private_ip
}