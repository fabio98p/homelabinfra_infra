# Output: il "punto di consegna" verso Ansible. Espone hostname -> IP.
# Dato che gli IP sono statici e decisi da te, sono gia' noti senza bisogno
# del guest-agent. Dopo l'apply puoi vederli con: terraform output

output "vm_ips" {
  description = "Mappa hostname -> indirizzo IP delle VM create"
  value = {
    for name, cfg in var.vms : name => cfg.ip
  }
}

# Variante gia' pronta in stile inventory INI per Ansible (utile da reindirizzare
# su un file). Esempio: terraform output -raw ansible_inventory > ../ansible/inventory.ini
output "ansible_inventory" {
  description = "Inventory Ansible (formato INI) generato dalle VM"
  value = join("\n", [
    for name, cfg in var.vms :
    "${name} ansible_host=${cfg.ip}"
  ])
}
