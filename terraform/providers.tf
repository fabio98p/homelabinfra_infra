# Configurazione del provider: come Terraform si collega al tuo Proxmox.

provider "proxmox" {
  endpoint  = var.proxmox_endpoint  # es. "https://192.168.1.10:8006/"
  api_token = var.proxmox_api_token # "terraform@pve!provider=SECRET" (passato via env var)

  # Proxmox usa di default un certificato self-signed: in un homelab è normale
  # accettarlo. Se un domani metti un certificato valido, porta questo a false.
  insecure = true

  # --- BLOCCO SSH (di norma NON serve con la strada minimale) ---
  # La cloud-init nativa via API non richiede SSH. L'unico punto in cui il
  # provider POTREBBE chiedere SSH è l'import del disco dalla cloud image:
  # su PVE 9 questo avviene via API, ma se durante "terraform apply" vedessi
  # un errore relativo a SSH, decommenta questo blocco e usa la chiave che
  # hai autorizzato su root@pve.
  #
  # ssh {
  #   agent    = false
  #   username = "root"
  #   # private_key = file("~/.ssh/homelab")
  # }
}
