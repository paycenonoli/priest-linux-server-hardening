output "instance_id" {
  description = "ID of the Linux hardening EC2 instance"
  value       = aws_instance.linux_hardening.id
}

output "public_ip" {
  description = "Public IP address of the Linux hardening server"
  value       = aws_instance.linux_hardening.public_ip
}

output "public_dns" {
  description = "Public DNS name of the Linux hardening server"
  value       = aws_instance.linux_hardening.public_dns
}

output "vpc_id" {
  description = "ID of the Linux hardening VPC"
  value       = aws_vpc.linux_hardening.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the Linux hardening security group"
  value       = aws_security_group.linux_hardening.id
}
