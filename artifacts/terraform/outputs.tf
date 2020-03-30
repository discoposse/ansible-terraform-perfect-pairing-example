output "public_ip" {
  description = "List of public IP addresses assigned to the instances"
  value       = ["${aws_instance.instance.*.public_ip}"]
}