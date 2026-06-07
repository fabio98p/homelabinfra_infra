# Vincoli di versione: dicono a Terraform di quale motore e di quale
# provider ha bisogno. Al primo "terraform init" il provider bpg/proxmox
# viene scaricato automaticamente: non devi installarlo a mano.

terraform {
  required_version = ">= 1.6"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.97" # consente 0.97.x ... 0.99.x; aggiorna pure se esce una nuova minor
    }
  }
}
