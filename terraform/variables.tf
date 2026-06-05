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

# ── Proxmox ──────────────────────────────────────────────────────────────────

variable "proxmox_api_url" {
  description = "Proxmox API endpoint (e.g. https://pve.local:8006/api2/json)"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox API user (e.g. root@pam or terraform@pve)"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "proxmox_tls_insecure" {
  description = "Skip TLS certificate verification (useful for self-signed certs)"
  type        = bool
  default     = true
}

variable "proxmox_node" {
  description = "Proxmox node name where VMs will be created"
  type        = string
  default     = "pve"
}

# ── VM defaults ───────────────────────────────────────────────────────────────

variable "vm_template" {
  description = "Name of the cloud-init template to clone"
  type        = string
  default     = "ubuntu-22.04-template"
}

variable "vm_storage" {
  description = "Proxmox storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "vm_default_cores" {
  description = "Default number of vCPU cores per VM"
  type        = number
  default     = 2
}

variable "vm_default_memory" {
  description = "Default RAM per VM in MB"
  type        = number
  default     = 2048
}

variable "vm_ssh_public_key" {
  description = "SSH public key injected via cloud-init"
  type        = string
}
