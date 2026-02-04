output "ec2_public_ip" {
  description = "EC2のパブリックIPアドレス"
  value       = aws_instance.app_server.public_ip
}