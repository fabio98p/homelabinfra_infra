locals {
  vms = {
    # "vm-name" = {
    #   vmid      = 101
    #   cores     = 2
    #   memory    = 2048
    #   disk_size = "20G"
    #   ip        = "192.168.1.10/24"
    #   gw        = "192.168.1.1"
    # }
  }
}

resource "proxmox_vm_qemu" "vms" {
  for_each = local.vms

  name        = each.key
  vmid        = each.value.vmid
  target_node = var.proxmox_node
  clone       = var.vm_template
  agent       = 1
  os_type     = "cloud-init"
  cores       = try(each.value.cores, var.vm_default_cores)
  memory      = try(each.value.memory, var.vm_default_memory)
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"

  disk {
    slot    = 0
    size    = each.value.disk_size
    type    = "scsi"
    storage = var.vm_storage
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  lifecycle {
    ignore_changes = [network]
  }

  ipconfig0  = "ip=${each.value.ip},gw=${each.value.gw}"
  sshkeys    = var.vm_ssh_public_key
}
