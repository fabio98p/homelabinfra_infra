output "environment" {
  description = "Current deployment environment"
  value       = var.environment
}

output "proxmox_node" {
  description = "Proxmox node used for provisioning"
  value       = var.proxmox_node
}

# output "vm_ip_addresses" {
#   description = "IP addresses of provisioned VMs"
#   value       = { for k, v in proxmox_vm_qemu.vms : k => v.default_ipv4_address }
# }
