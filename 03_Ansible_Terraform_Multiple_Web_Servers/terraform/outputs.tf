output "webserver_public_ips" {
  description = "Public IPs of all web servers"
  value       = aws_instance.web[*].public_ip
}

output "webserver_public_dns" {
  description = "Public DNS names of all web servers"
  value       = aws_instance.web[*].public_dns
}

output "ansible_inventory_file" {
  description = "Path of the generated Ansible inventory file"
  value       = local_file.ansible_inventory.filename
}
