# Dichiarazione delle variabili di input. Qui si DICHIARANO (nome, tipo,
# descrizione, eventuale default); i VALORI reali stanno in terraform.tfvars
# oppure arrivano da variabili d'ambiente (es. il token).

variable "proxmox_endpoint" {
  type        = string
  description = "URL dell'API di Proxmox, es. https://192.168.1.10:8006/"
}

variable "proxmox_api_token" {
  type        = string
  sensitive   = true # cosi' non viene stampato negli output di Terraform
  description = "Token completo: terraform@pve!provider=SECRET. Passalo via env var TF_VAR_proxmox_api_token."
}

variable "proxmox_node" {
  type        = string
  description = "Nome del nodo Proxmox"
  default     = "pve"
}

variable "image_datastore" {
  type        = string
  description = "Storage dove scaricare la cloud image (deve avere il content type 'Import')"
  default     = "local"
}

variable "vm_datastore" {
  type        = string
  description = "Storage per i dischi delle VM"
  default     = "local-lvm"
}

variable "network_bridge" {
  type        = string
  description = "Bridge di rete Proxmox"
  default     = "vmbr0"
}

variable "gateway" {
  type        = string
  description = "Gateway della rete locale, es. 192.168.1.1"
}

variable "ip_prefix" {
  type        = number
  description = "Lunghezza della maschera di rete (24 = /24, rete classe C)"
  default     = 24
}

variable "ssh_public_key_path" {
  type        = string
  description = "Percorso alla chiave PUBBLICA SSH da iniettare nelle VM"
  default     = "~/.ssh/homelab.pub"
}

variable "ci_user" {
  type        = string
  description = "Nome dell'utente creato da cloud-init (lo usera' poi Ansible)"
  default     = "debian"
}

variable "debian_image_url" {
  type        = string
  description = "URL della cloud image di Debian 13 (genericcloud, qcow2)"
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

# La definizione di TUTTE le VM in un'unica mappa. La chiave (es. "k3s-1")
# diventa il nome e l'hostname della VM. I valori reali stanno in terraform.tfvars.
variable "vms" {
  description = "Definizione delle VM da creare"
  type = map(object({
    vm_id  = number # ID numerico univoco in Proxmox
    cores  = number # vCPU
    memory = number # RAM in MB
    disk   = number # disco in GB
    ip     = string # IP statico senza maschera, es. 192.168.1.11
  }))
}
