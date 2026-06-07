CLAUDE.md — Contesto progetto homelab-infra (parte Terraform)

File di contesto per Claude Code. Riassume architettura e decisioni prese.
La parte Terraform vive nella repo provisioning, sottocartella terraform/.

Cos'e' il progetto
Homelab on-premise per esercitare DevOps / platform engineering / automazione.
Tutto gira su un singolo host Proxmox in virtualizzazione annidata. Gli
applicativi (frontend/backend/db) sono un pretesto: l'interesse e' l'infrastruttura.
Strumenti separati per fase del ciclo di vita:

Terraform -> crea le VM (provisioning). Solo questo, niente OS/k8s/app.
Ansible -> configura l'OS, fa il bootstrap del cluster k3s, installa gli agent.
ArgoCD -> distribuisce gli applicativi nel cluster (repo gitops).
Vault -> gestisce i secret a runtime.

Confine da rispettare: Terraform produce le macchine e ne comunica gli IP; tutto
il resto e' di Ansible/ArgoCD. Non duplicare responsabilita'.
Ambiente

Terraform eseguito da una VM di supporto CachyOS (con Ansible + Terraform).
Host: 24 GB RAM totali, budget effettivo per le VM ~14-15 GB.
Proxmox VE 9.1.1 (attenzione: in PVE 9 il privilegio VM.Monitor e' stato
RIMOSSO; non includerlo nei ruoli).
Distro target di tutte le VM: Debian 13 "Trixie".

Decisioni prese (NON rimetterle in discussione senza motivo)

Provider: bpg/proxmox (non telmate/proxmox).
Approccio = "Variante B": Terraform scarica la cloud image e crea le VM
importando il disco. NESSUN template "golden" creato a mano -> tutto riproducibile
da codice.
Cloud image: Debian 13 genericcloud qcow2 (cloud.debian.org/.../trixie/latest).
Cloud-init MINIMALE e nativa (via API Proxmox): imposta solo hostname, IP
statico, utente + chiave SSH. NIENTE snippets, NIENTE dipendenza SSH del provider.
Pacchetti, qemu-guest-agent, k3s ecc. -> li fa Ansible a valle.
qemu-guest-agent NON e' nell'immagine -> nel codice agent { enabled = false }
e stop_on_destroy = true. Quando Ansible l'avra' installato si potra' mettere a true.
IP statici decisi a mano -> noti gia' a plan-time, esportati come inventory
per Ansible (non serve il guest-agent per leggerli).
Auth Proxmox: utente dedicato terraform@pve + API token (--privsep=0),
con un ruolo a privilegi minimi. NON usare root.

Layout della cartella terraform/

versions.tf    -> vincoli Terraform + provider bpg/proxmox (~> 0.97).
providers.tf   -> provider proxmox (endpoint + api_token, insecure=true).
Contiene un blocco ssh commentato: serve SOLO se l'import
del disco dovesse lamentare SSH (su PVE 9 di norma no).
variables.tf   -> dichiarazione variabili.
main.tf        -> download cloud image + risorsa VM con for_each su var.vms.
outputs.tf     -> vm_ips (mappa hostname->IP) e ansible_inventory (formato INI).
terraform.tfvars.example -> modello dei valori; copiare in terraform.tfvars.
.gitignore     -> ignora stato e tfvars; il lock file VA committato.

Risorse da creare
VMn.RAMvCPUDiscoRuoloplatform1~2,5 GB2~40 GBOpenSearch + Dashboards + Vaultk3s-1/2/33~4 GB2~40 GBcluster k3s: app, db, Longhorn, ArgoCD…
RAM totale ~14,5 GB: si sta nel budget ma e' al limite -> non aggiungere VM senza
ricontrollare. vCPU e dimensioni disco erano "raccomandazioni da confermare".
Convenzioni / regole operative

Il secret del token NON va nei file: passarlo via env var
export TF_VAR_proxmox_api_token='terraform@pve!provider=SECRET'.
Mai committare *.tfstate (contiene segreti) ne' terraform.tfvars.
Sempre terraform plan prima di terraform apply.
Distro uniforme (Debian 13) su tutte le VM -> ruoli Ansible omogenei a valle.

Prerequisiti manuali gia' previsti

Su Proxmox: creati utente/ruolo/token terraform@pve (privilegi PVE 9, senza VM.Monitor).
Storage local: abilitato content type Import (per scaricare la cloud image).
Generata chiave SSH di servizio sulla VM CachyOS (pubblica iniettata via cloud-init).

Stato attuale / prossimi passi

 Primo terraform init + terraform plan, da rivedere prima dell'apply.
 Confermare nomi reali nell'ambiente: nodo, storage, bridge, gateway, schema IP.
 Dopo le VM: passare alla parte Ansible (stessa repo, cartella separata).

Cosa NON e' di questo task
Configurazione OS, install k3s/agent (Ansible). Deploy applicativi/cluster (ArgoCD,
repo gitops). Le repo gitops/frontend/backend/docs non riguardano Terraform.