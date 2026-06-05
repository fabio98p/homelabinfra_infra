terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # Uncomment the providers you need
    # proxmox = {
    #   source  = "telmate/proxmox"
    #   version = "~> 2.9"
    # }
    # libvirt = {
    #   source  = "dmacvicar/libvirt"
    #   version = "~> 0.7"
    # }
  }

  # backend "s3" {
  #   bucket = "my-tf-state"
  #   key    = "homelab/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}

# provider "proxmox" {
#   pm_api_url      = var.proxmox_api_url
#   pm_user         = var.proxmox_user
#   pm_password     = var.proxmox_password
#   pm_tls_insecure = true
# }
