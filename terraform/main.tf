# --- Risorse principali ---

# 1) Scarica UNA VOLTA la cloud image di Debian 13 dentro Proxmox.
#    content_type = "import" la rende utilizzabile come disco da importare.
resource "proxmox_virtual_environment_download_file" "debian13" {
  content_type = "import"
  datastore_id = var.image_datastore
  node_name    = var.proxmox_node
  url          = var.debian_image_url
  overwrite    = false # non riscaricare a ogni apply se il file c'e' gia'
}

# Legge la chiave pubblica SSH dal disco. pathexpand espande la "~".
# trimspace toglie l'a-capo finale del file, che altrimenti rompe cloud-init.
locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

# 2) Crea TUTTE le VM partendo dalla mappa var.vms.
#    for_each itera sulla mappa: una VM per ogni voce. "each.key" e' il nome
#    (es. "k3s-1"), "each.value" e' l'oggetto con cores/memory/disk/ip.
resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vms

  name      = each.key # diventa anche l'hostname della VM
  node_name = var.proxmox_node
  vm_id     = each.value.vm_id
  tags      = ["terraform", "debian13"]

  # La cloud image non include il qemu-guest-agent: lo installera' Ansible.
  # Finche' non c'e', teniamo l'agent disabilitato per non bloccare l'apply.
  # Quando Ansible l'avra' installato, potrai portare enabled a true.
  agent {
    enabled = false
  }
  # Con l'agent disabilitato serve per spegnere/distruggere la VM in modo pulito.
  stop_on_destroy = true

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES" # baseline sicura; su singolo host puoi usare "host" per piu' performance
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.vm_datastore
    import_from  = proxmox_virtual_environment_download_file.debian13.id
    interface    = "virtio0"
    size         = each.value.disk
    discard      = "on"
  }

  # Cloud-init NATIVA via API: hostname (dal name), IP statico, utente + chiave SSH.
  initialization {
    datastore_id = var.vm_datastore

    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.ip_prefix}"
        gateway = var.gateway
      }
    }

    user_account {
      username = var.ci_user
      keys     = [local.ssh_public_key]
    }

    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }
  }

  network_device {
    bridge = var.network_bridge
  }

  # NOTA: cambiare le chiavi SSH della cloud-init forza la ricreazione della VM.
  # Non e' un problema all'inizio. Se in futuro ti desse fastidio, puoi aggiungere:
  #   lifecycle {
  #     ignore_changes = [initialization[0].user_account]
  #   }
}
