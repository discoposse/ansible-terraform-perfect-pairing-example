output "id" {
  description = "List instance ID"
  value       = aws_instance.${var.aws_instance_name}.*.id
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances"
  value       = aws_instance.${var.aws_instance_name}.*.public_ip
}