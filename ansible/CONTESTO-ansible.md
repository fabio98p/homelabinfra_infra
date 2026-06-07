# homelab-infra — Contesto per il task: Ansible

## Scopo di questo documento

Fornisce il contesto necessario a una chat dedicata esclusivamente alla parte Ansible del progetto. Riassume l'architettura generale, il punto di partenza ereditato dalla fase Terraform e cosa Ansible deve produrre, lasciando alla chat dedicata l'elaborazione dei singoli passaggi. Le voci sono distinte tra decisioni già prese, raccomandazioni e voci ancora da confermare.

## Contesto del progetto (sintesi)

Laboratorio on-premise per l'esercizio di pratiche DevOps, platform engineering e automazione. Gira su un singolo host Proxmox in virtualizzazione annidata e simula un sistema di produzione. Gli applicativi (frontend, backend, database) sono un pretesto: l'interesse è l'infrastruttura.

Gli strumenti sono separati per fase del ciclo di vita: Terraform crea le VM, Ansible le configura ed esegue il bootstrap della piattaforma, ArgoCD distribuisce gli applicativi e i componenti nel cluster, Vault gestisce i secret a runtime.

## Punto di partenza: output della fase Terraform

La fase Terraform è conclusa e ha prodotto le macchine virtuali. Ansible parte da questo stato:

- Esistono **1 VM Platform Services** e **3 nodi Kubernetes**, tutte Debian 13, con **IP statici noti** (decisi a mano, non dipendenti dal guest agent).
- Terraform espone un output `ansible_inventory` in formato INI, con hostname e IP. È il punto di partenza dell'inventory di Ansible.
- Una **chiave SSH di servizio** è già stata iniettata nelle VM via cloud-init. La chiave privata è sull'host CachyOS; Ansible si connette con quella.
- La cloud-init nativa ha impostato solo hostname, IP statico e chiave SSH. Tutto il resto è demandato ad Ansible.
- Il **qemu-guest-agent non è installato** sulle VM e nel codice Terraform l'agent è disabilitato. La sua installazione è compito di Ansible.

## Ruolo di Ansible nel progetto

Ansible configura il sistema operativo delle VM ed esegue il bootstrap della piattaforma, fino all'installazione di k3s e di ArgoCD. Da quel punto subentra ArgoCD per tutto ciò che gira all'interno del cluster. Ansible non crea VM (compito di Terraform) e non gestisce la distribuzione dei componenti e degli applicativi in-cluster (compito di ArgoCD).

## Ambiente di esecuzione

- Ansible viene eseguito dall'host CachyOS, dove è già installato.
- L'inventory proviene dall'output di Terraform.
- Tutti i target eseguono Debian 13.

## Cosa deve fare Ansible (scope)

### Tutti i nodi (configurazione comune)

- Hardening di base, gestione utenti e configurazione SSH.
- Installazione del `qemu-guest-agent` (la successiva riattivazione dell'agent lato Proxmox è una piccola modifica Terraform di follow-up, non un compito Ansible).
- Pacchetti comuni, aggiornamenti, timezone e sincronizzazione oraria.

### VM Platform Services

- Impostazione di `vm.max_map_count = 262144`, requisito di OpenSearch.
- Runtime container e deploy di OpenSearch, OpenSearch Dashboards e Vault. Raccomandazione: eseguirli come container via Docker Compose, coerentemente con l'esperienza esistente su docker-compose.
- Inizializzazione e unseal di Vault. È un passaggio sensibile per via della gestione delle chiavi di unseal: la modalità (manuale o automatizzata) è una voce aperta.
- Configurazione del metodo di autenticazione Kubernetes di Vault, da eseguire dopo che k3s è operativo. Risolve il problema del primo accesso ("secret zero") per i client in-cluster.

### Nodi Kubernetes (k3s)

- Prerequisiti a livello di sistema operativo per Longhorn: `open-iscsi`, `nfs-common` e i moduli kernel necessari. Nota: Longhorn in sé non viene installato da Ansible (lo farà ArgoCD via Helm), ma questi prerequisiti devono essere presenti sui nodi prima.
- Installazione di k3s in alta disponibilità: tre server con etcd embedded, con inizializzazione del cluster sul primo nodo e join degli altri due.
- Bootstrap di ArgoCD, che funge da punto di ingresso del GitOps. Da lì ArgoCD si autogestisce con il pattern app-of-apps.

## Decisioni aperte per la chat Ansible

- **Endpoint HA del control-plane.** Con tre server e senza load balancer, l'API server non ha un indirizzo stabile unico. Raccomandazione: kube-vip, leggero e standard con k3s, che fornisce un IP virtuale. In alternativa si punta a un singolo nodo, perdendo l'alta disponibilità dell'endpoint. Se si sceglie kube-vip, la sua configurazione rientra nello scope Ansible (tipicamente un manifest collocato durante il setup di k3s).
- **Metodo di installazione di k3s**: script ufficiale invocato da Ansible, oppure una collection/role della community.
- **Gestione dell'unseal di Vault**: manuale o automatizzata, con attenzione alla sicurezza delle chiavi.
- **Runtime container sulla Platform VM**: Docker o Podman per OpenSearch e Vault. Raccomandazione: Docker con Compose.

## Confine con ArgoCD (cosa NON fa Ansible)

A valle del bootstrap, ArgoCD, dalla repository `gitops`, gestirà: Longhorn (Helm), kube-prometheus-stack, ingress-nginx, CloudNativePG con PostgreSQL, l'integrazione di Vault in-cluster (Vault agent o External Secrets Operator), lo stack delle tracce (OpenTelemetry e Tempo) e gli applicativi frontend e backend. Ansible si ferma all'installazione di k3s e al bootstrap di ArgoCD.

## Vincoli da rispettare

- Mantenere la distribuzione uniforme (Debian 13) su tutte le VM, così da consentire ruoli omogenei.
- Budget di RAM al limite (circa 14,5 GB su 14-15 disponibili): non introdurre componenti pesanti senza un nuovo controllo.
- Nota ereditata dalla fase Terraform, rilevante solo lato Proxmox: i ruoli non usano il privilegio `VM.Monitor`, rimosso in PVE 9. Quando si riattiverà il guest agent per la lettura degli IP lato Proxmox, si useranno i nuovi privilegi `VM.GuestAgent.*`.

## Posizionamento nel repository

Il codice Ansible risiede nella repository `provisioning`, in una cartella dedicata (ad esempio `ansible/`), separata da `terraform/`. Suggerimento di struttura: ruoli distinti per la configurazione comune, per la Platform Services e per i nodi k3s; inventory derivato dall'output di Terraform; variabili di gruppo per i parametri.

## Punto di consegna verso ArgoCD

Quando il cluster k3s è in alta disponibilità e ArgoCD è installato e collegato alla repository `gitops`, la responsabilità passa ad ArgoCD. Il task successivo del progetto sarà la configurazione di ArgoCD e dei manifest nella repository `gitops`.
