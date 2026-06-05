variable "environment" {
  description = "Deployment environment (e.g. homelab, staging, prod)"
  type        = string
  default     = "homelab"
}

variable "network_cidr" {
  description = "CIDR block for the homelab network"
  type        = string
  default     = "192.168.1.0/24"
}

# variable "proxmox_api_url" {
#   description = "Proxmox API endpoint"
#   type        = string
# }

# variable "proxmox_user" {
#   description = "Proxmox API user (e.g. root@pam)"
#   type        = string
# }

# variable "proxmox_password" {
#   description = "Proxmox API password"
#   type        = string
#   sensitive   = true
# }
