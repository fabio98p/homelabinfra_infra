
# operazioni manuali

### TERRAFORM

sudo dnf -y install terraform

ssh-keygen -t ed25519 -f ~/.ssh/homelab

export TF_VAR_proxmox_api_token='terraform@pve!provider=74bfec2c-de26-4a64-8dd9-c7eb36198a2d'

terraform init
terraform plan
terraform apply
terraform apply -target='proxmox_virtual_environment_vm.vm["platform"]'


### ANSIBLE