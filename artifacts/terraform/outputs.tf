output "public_ip" {
  description = "List of public IP addresses assigned to the instances"
  value       = value = ["${aws_instance.web.*.public_ip}"]
}